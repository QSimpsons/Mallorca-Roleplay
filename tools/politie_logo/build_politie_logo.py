#!/usr/bin/env python3
"""Build a FiveM/GTA V .ydr of the 3D POLITIE sign from the reference photo.

Letters and the gold shield are traced from the photo, extruded with a rounded
bevel, and the gold emblem is shifted slightly upward.
"""

from __future__ import annotations

import math
from pathlib import Path

import numpy as np
import trimesh
from PIL import Image, ImageDraw
from scipy import ndimage
from shapely.geometry import MultiPolygon, Point, Polygon
from shapely.geometry.polygon import orient
from shapely.ops import transform as shapely_transform
from shapely.ops import unary_union
from shapely.validation import make_valid
from skimage import measure
from trimesh.visual.material import SimpleMaterial

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parent.parent
PHOTO_PATH = ROOT / "reference.jpg"
OUT_DIR = REPO / "politie_logo" / "stream"
PREVIEW_DIR = Path("/tmp/politie")

# A small lift so more of the blue O stays visible under the shield.
GOLD_LIFT_PX = 11.0  # at 2x photo resolution
TARGET_WIDTH_M = 6.0
DEPTH_M = 0.30
BEVEL_M = 0.055
GOLD_FORWARD_M = 0.04
UPSAMPLE = 2.0

# Match the 3D render colours.
BLUE_RGBA = (22, 108, 230, 255)
GOLD_RGBA = (226, 190, 68, 255)


def _pt_xy(contour: np.ndarray) -> np.ndarray:
    # skimage contours are (row, col) = (y, x)
    return np.column_stack([contour[:, 1], contour[:, 0]])


def mask_from_photo(path: Path) -> tuple[np.ndarray, np.ndarray]:
    arr = np.asarray(Image.open(path).convert("RGB")).astype(np.float32)
    r, g, b = arr[:, :, 0], arr[:, :, 1], arr[:, :, 2]
    blue = (b > 90) & (b > r + 25) & (b > g + 15) & (b > 1.15 * g)
    gold = (r > 140) & (g > 110) & (r > b + 30) & (g > b + 15) & ((r + g) > 2.2 * b)
    blue = ndimage.zoom(blue.astype(np.float32), UPSAMPLE, order=1)
    gold = ndimage.zoom(gold.astype(np.float32), UPSAMPLE, order=1)
    blue = ndimage.gaussian_filter(blue, 0.55) > 0.45
    gold = ndimage.gaussian_filter(gold, 0.55) > 0.45
    blue = ndimage.binary_closing(blue, iterations=1)
    gold = ndimage.binary_closing(gold, iterations=1)
    return blue, gold


def contours_to_polygon(mask: np.ndarray, min_area: float) -> Polygon | MultiPolygon | None:
    contours = measure.find_contours(mask.astype(float), 0.5)
    polys: list[Polygon] = []
    for contour in contours:
        if len(contour) < 10:
            continue
        poly = Polygon(_pt_xy(contour))
        if not poly.is_valid:
            poly = make_valid(poly)
        if poly.is_empty:
            continue
        if poly.geom_type == "MultiPolygon":
            polys.extend(p for p in poly.geoms if p.area >= min_area)
        elif poly.area >= min_area:
            polys.append(poly)
    if not polys:
        return None
    polys = sorted(polys, key=lambda p: p.area, reverse=True)
    result = polys[0]
    for extra in polys[1:]:
        if result.contains(extra) or result.contains(extra.representative_point()):
            result = result.difference(extra)
        else:
            result = unary_union([result, extra])
    result = make_valid(result)
    return None if result.is_empty else result


def smooth_poly(poly: Polygon, round_px: float, simplify: float) -> Polygon:
    if round_px > 0:
        poly = poly.buffer(round_px, join_style=1).buffer(-round_px, join_style=1)
    poly = make_valid(poly.simplify(simplify, preserve_topology=True))
    if poly.geom_type == "Polygon":
        return orient(poly, sign=1.0)
    if poly.geom_type == "MultiPolygon":
        return unary_union([orient(p, sign=1.0) for p in poly.geoms if not p.is_empty])
    return poly


def complete_o_ring(o_mask: np.ndarray) -> Polygon:
    ys, xs = np.where(o_mask)
    r_out = (float(xs.max() - xs.min())) / 2.0
    cx = (float(xs.min()) + float(xs.max())) / 2.0
    cy = float(ys.max()) - r_out
    # Stroke width is close to the 'I' width; keep a thick torus like the photo.
    r_in = r_out - 95.0
    return Point(cx, cy).buffer(r_out, resolution=72).difference(
        Point(cx, cy).buffer(r_in, resolution=72)
    )


def load_logo_polygons() -> tuple[list[Polygon], list[Polygon]]:
    blue_mask, gold_mask = mask_from_photo(PHOTO_PATH)
    labels, count = ndimage.label(blue_mask)
    blue: list[Polygon] = []
    o_mask = None
    for index in range(1, count + 1):
        component = labels == index
        if int(component.sum()) < 800:
            continue
        ys, _xs = np.where(component)
        if ys.max() > blue_mask.shape[0] * 0.78:
            o_mask = component
            continue
        geom = contours_to_polygon(component, min_area=400)
        if geom is None:
            continue
        for part in iter_polygons(geom):
            blue.append(smooth_poly(part, round_px=2.2, simplify=0.9))
    if o_mask is not None:
        blue.append(complete_o_ring(o_mask))
    gold_geom = contours_to_polygon(gold_mask, min_area=300)
    gold: list[Polygon] = []
    if gold_geom is not None:
        from shapely.affinity import translate

        for part in iter_polygons(gold_geom):
            part = smooth_poly(part, round_px=1.1, simplify=0.55)
            gold.append(translate(part, xoff=0.0, yoff=-GOLD_LIFT_PX))
    return blue, gold


def iter_polygons(geom):
    if geom is None or geom.is_empty:
        return
    if geom.geom_type == "Polygon":
        yield geom
    elif geom.geom_type == "MultiPolygon":
        yield from geom.geoms


def resample_closed(points: np.ndarray, count: int) -> np.ndarray:
    pts = np.asarray(points, dtype=np.float64)
    if len(pts) >= 2 and np.allclose(pts[0], pts[-1]):
        pts = pts[:-1]
    closed = np.vstack([pts, pts[0]])
    dist = np.linalg.norm(np.diff(closed, axis=0), axis=1)
    dist[dist < 1e-9] = 1e-9
    u = np.concatenate([[0.0], np.cumsum(dist)])
    u /= u[-1]
    t = np.linspace(0.0, 1.0, count, endpoint=False)
    return np.column_stack(
        [np.interp(t, u, closed[:, 0]), np.interp(t, u, closed[:, 1])]
    )


def winding(ring: np.ndarray) -> float:
    closed = np.vstack([ring, ring[0]])
    return float(np.sum(closed[:-1, 0] * closed[1:, 1] - closed[1:, 0] * closed[:-1, 1]))


def align_ring(ring: np.ndarray, reference: np.ndarray) -> np.ndarray:
    idx = int(np.argmin(np.linalg.norm(ring - reference[0], axis=1)))
    aligned = np.roll(ring, -idx, axis=0)
    if np.sign(winding(aligned)) != np.sign(winding(reference)):
        aligned = aligned[::-1]
        idx = int(np.argmin(np.linalg.norm(aligned - reference[0], axis=1)))
        aligned = np.roll(aligned, -idx, axis=0)
    return aligned


def triangulate(poly: Polygon) -> tuple[np.ndarray, np.ndarray]:
    from trimesh.creation import triangulate_polygon

    vertices, faces = triangulate_polygon(poly)
    return np.asarray(vertices, dtype=np.float64), np.asarray(faces, dtype=np.int64)


def safe_inset(poly: Polygon, distance: float) -> tuple[Polygon | MultiPolygon, float]:
    if distance <= 0:
        return poly, 0.0
    for scale in (1.0, 0.65, 0.4, 0.22, 0.1, 0.0):
        inset = distance * scale
        candidate = poly if inset <= 1e-8 else poly.buffer(-inset)
        candidate = make_valid(candidate)
        if candidate.is_empty:
            continue
        if candidate.area >= poly.area * 0.25:
            return candidate, inset
    return poly, 0.0


def stitch_sides(r0: np.ndarray, r1: np.ndarray, z0: float, z1: float) -> trimesh.Trimesh:
    n = len(r0)
    verts = np.zeros((n * 2, 3), dtype=np.float64)
    verts[:n, 0:2] = r0
    verts[:n, 2] = z0
    verts[n:, 0:2] = r1
    verts[n:, 2] = z1
    faces = []
    for i in range(n):
        j = (i + 1) % n
        faces.append((i, j, n + j))
        faces.append((i, n + j, n + i))
    return trimesh.Trimesh(vertices=verts, faces=np.asarray(faces), process=False)


def cap_mesh(poly: Polygon, z: float, flip: bool) -> trimesh.Trimesh:
    vertices, faces = triangulate(poly)
    verts3 = np.column_stack([vertices, np.full(len(vertices), z)])
    if flip:
        faces = faces[:, ::-1]
    return trimesh.Trimesh(vertices=verts3, faces=faces, process=False)


def loft_polygon(poly: Polygon, depth: float, bevel: float) -> trimesh.Trimesh:
    poly = orient(make_valid(poly), sign=1.0)
    if poly.is_empty or poly.area < 1e-6:
        raise ValueError("empty polygon")
    inset_poly, used_bevel = safe_inset(poly, bevel)
    if used_bevel < bevel * 0.25 or inset_poly.geom_type != "Polygon":
        mesh = trimesh.creation.extrude_polygon(poly, height=float(depth))
        trimesh.repair.fix_normals(mesh)
        return mesh

    steps = 5
    body_z = depth - used_bevel
    layers = [(0.0, 0.0), (body_z, 0.0)]
    for i in range(1, steps + 1):
        t = i / steps
        angle = t * math.pi / 2.0
        layers.append((body_z + used_bevel * math.sin(angle), used_bevel * (1.0 - math.cos(angle))))

    sample_n = int(np.clip(poly.exterior.length / 2.4, 72, 280))
    parts = [cap_mesh(poly, 0.0, flip=True)]
    front = inset_poly if inset_poly.geom_type == "Polygon" else poly
    if layers[-1][1] > 0:
        front, _ = safe_inset(poly, layers[-1][1])
        if front.geom_type == "MultiPolygon":
            front = max(front.geoms, key=lambda p: p.area)
        front = orient(front, sign=1.0)
    parts.append(cap_mesh(front, layers[-1][0], flip=False))

    prev_ext = resample_closed(np.asarray(poly.exterior.coords), sample_n)
    prev_holes = [
        resample_closed(np.asarray(inner.coords), max(36, sample_n // 2))
        for inner in poly.interiors
    ]
    prev_z = 0.0
    for z, inset in layers[1:]:
        current, _ = safe_inset(poly, inset)
        if current.geom_type == "MultiPolygon":
            current = max(current.geoms, key=lambda p: p.area)
        current = orient(current, sign=1.0)
        ext = align_ring(resample_closed(np.asarray(current.exterior.coords), sample_n), prev_ext)
        parts.append(stitch_sides(prev_ext, ext, prev_z, z))
        new_holes = []
        unused = [
            resample_closed(np.asarray(inner.coords), max(36, sample_n // 2))
            for inner in current.interiors
        ]
        for prev in prev_holes:
            if not unused:
                break
            dists = [np.linalg.norm(u.mean(0) - prev.mean(0)) for u in unused]
            hole = align_ring(unused.pop(int(np.argmin(dists))), prev)
            parts.append(stitch_sides(prev, hole, prev_z, z))
            new_holes.append(hole)
        prev_ext, prev_holes, prev_z = ext, new_holes, z

    mesh = trimesh.util.concatenate(parts)
    mesh.merge_vertices()
    mesh.remove_unreferenced_vertices()
    trimesh.repair.fix_normals(mesh)
    return mesh


def svg_to_world(poly: Polygon, bounds) -> Polygon:
    minx, miny, maxx, maxy = bounds
    cx = (minx + maxx) / 2.0
    cy = (miny + maxy) / 2.0
    return shapely_transform(lambda x, y, z=None: ((x - cx), -(y - cy)), poly)


def color_mesh(mesh: trimesh.Trimesh, rgba: tuple[int, int, int, int], name: str) -> trimesh.Trimesh:
    mesh = mesh.copy()
    mins = mesh.vertices.min(axis=0)
    span = np.maximum(mesh.vertices.max(axis=0) - mins, 1e-6)
    uv = np.zeros((len(mesh.vertices), 2), dtype=np.float64)
    uv[:, 0] = (mesh.vertices[:, 0] - mins[0]) / span[0]
    uv[:, 1] = (mesh.vertices[:, 1] - mins[1]) / span[1]
    mesh.visual = trimesh.visual.TextureVisuals(
        uv=uv,
        material=SimpleMaterial(diffuse=np.array(rgba, dtype=np.uint8), name=name),
    )
    mesh.visual.vertex_colors = np.tile(np.array(rgba, dtype=np.uint8), (len(mesh.vertices), 1))
    _ = mesh.vertex_normals
    return mesh


def combined_bounds(a: trimesh.Trimesh, b: trimesh.Trimesh):
    return np.minimum(a.bounds[0], b.bounds[0]), np.maximum(a.bounds[1], b.bounds[1])


def build_meshes() -> tuple[trimesh.Trimesh, trimesh.Trimesh]:
    blue_polys, gold_polys = load_logo_polygons()
    bounds = unary_union(blue_polys + gold_polys).bounds
    flipped_blue = [svg_to_world(p, bounds) for p in blue_polys]
    flipped_gold = [svg_to_world(p, bounds) for p in gold_polys]
    flip_bounds = unary_union(flipped_blue + flipped_gold).bounds
    scale = TARGET_WIDTH_M / (flip_bounds[2] - flip_bounds[0])
    bevel_svg = BEVEL_M / scale
    depth_svg = DEPTH_M / scale
    gold_z = GOLD_FORWARD_M / scale

    def loft_group(polys: list[Polygon], z_off: float, bevel: float) -> trimesh.Trimesh:
        meshes = []
        for poly in polys:
            for part in iter_polygons(poly):
                mesh = loft_polygon(part, depth=depth_svg, bevel=bevel)
                mesh.apply_translation([0.0, 0.0, z_off])
                meshes.append(mesh)
        combined = trimesh.util.concatenate(meshes)
        combined.apply_scale(scale)
        return combined

    blue_mesh = loft_group(flipped_blue, 0.0, bevel_svg)
    gold_mesh = loft_group(flipped_gold, gold_z, bevel_svg * 0.22)
    mins, maxs = combined_bounds(blue_mesh, gold_mesh)
    shift = np.array(
        [-(mins[0] + maxs[0]) / 2.0, -(mins[1] + maxs[1]) / 2.0, -mins[2]],
        dtype=np.float64,
    )
    blue_mesh.apply_translation(shift)
    gold_mesh.apply_translation(shift)
    return blue_mesh, gold_mesh


def _rotation(yaw: float, pitch: float) -> np.ndarray:
    cy, sy = math.cos(yaw), math.sin(yaw)
    cp, sp = math.cos(pitch), math.sin(pitch)
    ry = np.array([[cy, 0.0, sy], [0.0, 1.0, 0.0], [-sy, 0.0, cy]])
    rx = np.array([[1.0, 0.0, 0.0], [0.0, cp, -sp], [0.0, sp, cp]])
    return rx @ ry


def render_photo_like(blue: trimesh.Trimesh, gold: trimesh.Trimesh, path: Path) -> None:
    width, height = 1600, 680
    img = Image.new("RGB", (width, height), (45, 45, 45))
    draw = ImageDraw.Draw(img)
    rot = _rotation(math.radians(9), math.radians(-5))
    combined = trimesh.util.concatenate([blue, gold])
    center = combined.bounds.mean(axis=0)
    light = np.array([-0.38, 0.62, 0.68], dtype=np.float64)
    light /= np.linalg.norm(light)
    view = np.array([0.08, 0.10, 0.99], dtype=np.float64)
    view /= np.linalg.norm(view)

    projected = []
    for mesh, rgb in ((blue, BLUE_RGBA[:3]), (gold, GOLD_RGBA[:3])):
        verts = (mesh.vertices - center) @ rot.T
        normals = mesh.face_normals @ rot.T
        faces = mesh.faces
        facing = normals[:, 2] > 0.02
        tris = verts[faces[facing]]
        nrm = normals[facing]
        lambert = np.clip(nrm @ light, 0.0, 1.0)
        half = light + view
        half /= np.linalg.norm(half)
        spec = np.clip(nrm @ half, 0.0, 1.0) ** 28
        depth = tris[:, :, 2].mean(axis=1)
        for i in range(len(tris)):
            shade = 0.28 + 0.72 * float(lambert[i])
            color = tuple(
                max(0, min(255, int(c * shade + 255 * 0.22 * float(spec[i]))))
                for c in rgb
            )
            projected.append((float(depth[i]), tris[i], color))

    projected.sort(key=lambda item: item[0])
    xs = [float(p[0]) for _z, tri, _c in projected for p in tri]
    ys = [float(p[1]) for _z, tri, _c in projected for p in tri]
    minx, maxx, miny, maxy = min(xs), max(xs), min(ys), max(ys)
    pad = 0.08 * max(maxx - minx, maxy - miny)
    minx -= pad
    maxx += pad
    miny -= pad
    maxy += pad
    scale = min(width / (maxx - minx), height / (maxy - miny))
    ox = width * 0.5 - (minx + maxx) * 0.5 * scale
    oy = height * 0.5 + (miny + maxy) * 0.5 * scale
    for _z, tri, color in projected:
        pts = [(ox + float(p[0]) * scale, oy - float(p[1]) * scale) for p in tri]
        draw.polygon(pts, fill=color)
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path)


def export_ydr(blue: trimesh.Trimesh, gold: trimesh.Trimesh) -> Path:
    from fivefury import Texture, Ytd, Ytyp, create_ydr, read_ydr
    from fivefury.vector import Vector3
    from fivefury.ytd.defs import TextureFormat
    from fivefury.ydr.build_types import YdrMaterialInput
    from fivefury.ydr.trimesh.geometry import mesh_to_ydr_input
    from fivefury.ytyp.archetypes import Archetype
    from fivefury.ytyp.asset_types import ArchetypeAssetType

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    identity = np.eye(4, dtype=np.float64)
    blue_c = color_mesh(blue, BLUE_RGBA, "politie_blue")
    gold_c = color_mesh(gold, GOLD_RGBA, "politie_gold")
    build = create_ydr(
        meshes=[
            mesh_to_ydr_input(blue_c, identity, "politie_blue", default_colour=None),
            mesh_to_ydr_input(gold_c, identity, "politie_gold", default_colour=None),
        ],
        materials=[
            YdrMaterialInput(
                name="politie_blue",
                shader="default.sps",
                textures={"DiffuseSampler": "politie_blue"},
            ),
            YdrMaterialInput(
                name="politie_gold",
                shader="default.sps",
                textures={"DiffuseSampler": "politie_gold"},
            ),
        ],
        embedded_textures=_embedded_colours(),
        name="politie_logo",
    )
    ydr_path = OUT_DIR / "politie_logo.ydr"
    build.save(ydr_path)
    drawable = read_ydr(ydr_path)
    try:
        drawable.ensure_bound_from_render_geometry()
        drawable.save(ydr_path)
    except Exception as exc:
        print(f"Skipping embedded collision: {exc}")

    mins, maxs = combined_bounds(blue, gold)
    gta_min = np.array([mins[0], -maxs[2], mins[1]])
    gta_max = np.array([maxs[0], -mins[2], maxs[1]])
    ytyp = Ytyp(name="politie_logo_meta")
    ytyp.archetypes.append(
        Archetype(
            name="politie_logo",
            asset_name="politie_logo",
            asset_type=ArchetypeAssetType.DRAWABLE,
            bb_min=Vector3(*map(float, gta_min)),
            bb_max=Vector3(*map(float, gta_max)),
            bs_centre=Vector3(*map(float, (gta_min + gta_max) / 2.0)),
            bs_radius=float(np.linalg.norm(gta_max - gta_min) / 2.0),
            lod_dist=220.0,
            hd_texture_dist=180.0,
        )
    )
    ytyp.save(OUT_DIR / "politie_logo.ytyp")
    return ydr_path


def _embedded_colours() -> "Ytd":
    from fivefury import Texture, Ytd
    from fivefury.ytd.defs import TextureFormat

    ytd = Ytd()
    for name, rgba in (("politie_blue", BLUE_RGBA), ("politie_gold", GOLD_RGBA)):
        r, g, b, a = rgba
        pixel = bytes((b, g, r, a))
        ytd.texture(
            Texture.from_raw(pixel * (16 * 16), 16, 16, TextureFormat.A8R8G8B8, 1, name=name)
        )
    return ytd


def main() -> None:
    PREVIEW_DIR.mkdir(parents=True, exist_ok=True)
    blue, gold = build_meshes()
    print("blue verts", len(blue.vertices), "faces", len(blue.faces), "bounds", blue.bounds)
    print("gold verts", len(gold.vertices), "faces", len(gold.faces), "bounds", gold.bounds)
    preview = PREVIEW_DIR / "politie_logo_photo_like.png"
    render_photo_like(blue, gold, preview)
    print("preview", preview)
    ydr_path = export_ydr(blue, gold)
    print("ydr", ydr_path, "size", ydr_path.stat().st_size)


if __name__ == "__main__":
    main()
