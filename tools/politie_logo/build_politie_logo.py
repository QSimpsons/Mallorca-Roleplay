#!/usr/bin/env python3
"""Build a FiveM/GTA V .ydr of the Dutch POLITIE 3D wordmark.

The golden emblem is shifted slightly upward compared to the source photo.
"""

from __future__ import annotations

import math
from pathlib import Path

import numpy as np
import trimesh
from shapely.geometry import MultiPolygon, Point, Polygon
from shapely.geometry.polygon import orient
from shapely.ops import unary_union
from shapely.validation import make_valid
from svgelements import Close, Line, Move, Path as SvgPath, Polygon as SvgPolygon, Rect, SVG
from trimesh.visual.material import SimpleMaterial

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parent.parent
SVG_PATH = ROOT / "logo.svg"
OUT_DIR = REPO / "politie_logo" / "stream"
PREVIEW_DIR = Path("/tmp/politie")

# Source photo is a 3D extrusion of the official wordmark. Raise the gold
# emblem a little so more of the blue O stays visible underneath.
GOLD_LIFT_SVG = 1.5
TARGET_WIDTH_M = 6.0
DEPTH_M = 0.22
BEVEL_M = 0.042
GOLD_FORWARD_M = 0.03
BEVEL_STEPS = 6
RING_SAMPLES = 96

# Match the supplied 3D render (brighter than the flat #004682 / #BE965A).
BLUE_RGBA = (22, 108, 230, 255)
GOLD_RGBA = (226, 190, 68, 255)


def _pt(value) -> tuple[float, float]:
    if hasattr(value, "real"):
        return float(value.real), float(value.imag)
    return float(value.x), float(value.y)


def sample_path_rings(path: SvgPath, curve_samples: int = 36) -> list[list[tuple[float, float]]]:
    rings: list[list[tuple[float, float]]] = []
    current: list[tuple[float, float]] = []
    for seg in path:
        if isinstance(seg, Move):
            if len(current) >= 3:
                rings.append(current)
            current = [_pt(seg.end)]
            continue
        if isinstance(seg, Close):
            if len(current) >= 3:
                rings.append(current)
            current = []
            continue
        steps = 1 if isinstance(seg, Line) else curve_samples
        for i in range(1, steps + 1):
            current.append(_pt(seg.point(i / steps)))
    if len(current) >= 3:
        rings.append(current)
    return rings


def rings_to_polygon(rings: list[list[tuple[float, float]]]) -> Polygon | MultiPolygon | None:
    polys: list[Polygon] = []
    for ring in rings:
        coords = list(ring)
        if coords[0] != coords[-1]:
            coords = coords + [coords[0]]
        poly = Polygon(coords)
        if not poly.is_valid:
            poly = make_valid(poly)
        if poly.is_empty:
            continue
        if poly.geom_type == "Polygon":
            polys.append(poly)
        elif poly.geom_type == "MultiPolygon":
            polys.extend(p for p in poly.geoms if not p.is_empty)
    if not polys:
        return None
    polys = sorted(polys, key=lambda p: p.area, reverse=True)
    result = polys[0]
    for extra in polys[1:]:
        if result.contains(extra):
            result = result.difference(extra)
        elif extra.contains(result):
            result = extra.difference(result)
        else:
            result = unary_union([result, extra])
    result = make_valid(result)
    if result.is_empty:
        return None
    return result


def svg_polygon_to_shapely(elem: SvgPolygon) -> Polygon:
    pts = [(float(p.x), float(p.y)) for p in elem]
    if pts[0] != pts[-1]:
        pts.append(pts[0])
    return make_valid(Polygon(pts))


def svg_rect_to_shapely(elem: Rect) -> Polygon:
    x, y, w, h = float(elem.x), float(elem.y), float(elem.width), float(elem.height)
    return Polygon([(x, y), (x + w, y), (x + w, y + h), (x, y + h)])


def complete_o_ring() -> Polygon:
    # Measured from the official wordmark path: outer r=14, inner r=7.2.
    center = Point(45.3, 55.1)
    return center.buffer(14.0, resolution=64).difference(center.buffer(7.2, resolution=64))


def load_logo_polygons(gold_lift: float) -> tuple[list[Polygon], list[Polygon]]:
    svg = SVG.parse(SVG_PATH)
    blue: list[Polygon] = []
    gold: list[Polygon] = []
    for elem in svg.elements():
        fill = str(getattr(elem, "fill", "") or "").lower()
        geom = None
        if isinstance(elem, SvgPath):
            geom = rings_to_polygon(sample_path_rings(elem))
        elif isinstance(elem, SvgPolygon):
            geom = svg_polygon_to_shapely(elem)
        elif isinstance(elem, Rect):
            geom = svg_rect_to_shapely(elem)
        if geom is None or geom.is_empty:
            continue
        geoms = list(geom.geoms) if geom.geom_type == "MultiPolygon" else [geom]
        if fill == "#be965a":
            gold.extend(geoms)
        elif fill == "#004682":
            minx, miny, maxx, maxy = geom.bounds
            # Replace the open bottom-O with a full ring like the 3D photo.
            if minx > 25 and maxy > 60:
                continue
            blue.extend(geoms)
    blue.append(complete_o_ring())
    lifted = []
    for poly in gold:
        lifted.append(shapely_translate(poly, 0.0, -gold_lift))
    return [_orient_clean(p) for p in blue if not p.is_empty], [
        _orient_clean(p) for p in lifted if not p.is_empty
    ]


def shapely_translate(poly, dx: float, dy: float):
    from shapely.affinity import translate

    return translate(poly, xoff=dx, yoff=dy)


def _orient_clean(poly):
    poly = make_valid(poly)
    if poly.geom_type == "Polygon":
        return orient(poly, sign=1.0)
    if poly.geom_type == "MultiPolygon":
        return unary_union([orient(p, sign=1.0) for p in poly.geoms])
    return poly


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
    if len(pts) < 3:
        raise ValueError("ring is too small to resample")
    closed = np.vstack([pts, pts[0]])
    seg = np.diff(closed, axis=0)
    dist = np.linalg.norm(seg, axis=1)
    dist[dist < 1e-10] = 1e-10
    u = np.concatenate([[0.0], np.cumsum(dist)])
    u /= u[-1]
    t = np.linspace(0.0, 1.0, count, endpoint=False)
    x = np.interp(t, u, closed[:, 0])
    y = np.interp(t, u, closed[:, 1])
    return np.column_stack([x, y])


def align_ring(ring: np.ndarray, reference: np.ndarray) -> np.ndarray:
    idx = int(np.argmin(np.linalg.norm(ring - reference[0], axis=1)))
    aligned = np.roll(ring, -idx, axis=0)
    # Keep winding consistent with the reference ring.
    if winding(aligned) != winding(reference):
        aligned = aligned[::-1]
        idx = int(np.argmin(np.linalg.norm(aligned - reference[0], axis=1)))
        aligned = np.roll(aligned, -idx, axis=0)
    return aligned


def winding(ring: np.ndarray) -> float:
    closed = np.vstack([ring, ring[0]])
    return float(np.sum(closed[:-1, 0] * closed[1:, 1] - closed[1:, 0] * closed[:-1, 1]))


def triangulate(poly: Polygon) -> tuple[np.ndarray, np.ndarray]:
    from trimesh.creation import triangulate_polygon

    vertices, faces = triangulate_polygon(poly, triangle_args="p")
    return np.asarray(vertices, dtype=np.float64), np.asarray(faces, dtype=np.int64)


def safe_inset(poly: Polygon, distance: float) -> tuple[Polygon | MultiPolygon, float]:
    if distance <= 0:
        return poly, 0.0
    for scale in (1.0, 0.7, 0.45, 0.25, 0.12, 0.0):
        inset = distance * scale
        candidate = poly if inset <= 1e-8 else poly.buffer(-inset)
        candidate = make_valid(candidate)
        if candidate.is_empty:
            continue
        if candidate.area >= poly.area * 0.18:
            return candidate, inset
    return poly, 0.0


def layer_profile(depth: float, bevel: float, steps: int) -> list[tuple[float, float]]:
    """Return (z, inset) samples: straight body, then a rounded front bevel."""
    body_z = max(depth - bevel, depth * 0.55)
    used_bevel = depth - body_z
    layers = [(0.0, 0.0), (body_z, 0.0)]
    for i in range(1, steps + 1):
        t = i / steps
        angle = t * math.pi / 2.0
        z = body_z + used_bevel * math.sin(angle)
        inset = used_bevel * (1.0 - math.cos(angle))
        layers.append((z, inset))
    return layers


def stitch_sides(r0: np.ndarray, r1: np.ndarray, z0: float, z1: float) -> tuple[np.ndarray, np.ndarray]:
    n = len(r0)
    verts = np.zeros((n * 2, 3), dtype=np.float64)
    verts[:n, 0] = r0[:, 0]
    verts[:n, 1] = r0[:, 1]
    verts[:n, 2] = z0
    verts[n:, 0] = r1[:, 0]
    verts[n:, 1] = r1[:, 1]
    verts[n:, 2] = z1
    faces = []
    for i in range(n):
        j = (i + 1) % n
        a, b = i, j
        c, d = n + j, n + i
        faces.append((a, b, c))
        faces.append((a, c, d))
    return verts, np.asarray(faces, dtype=np.int64)


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
    # Keep emblem cut-outs; only drop tiny bezier oversampling.
    poly = poly.simplify(0.035, preserve_topology=True)
    poly = orient(make_valid(poly), sign=1.0)
    mesh = trimesh.creation.extrude_polygon(poly, height=float(depth))
    if bevel > 1e-5:
        inset, used = safe_inset(poly, bevel)
        if used > bevel * 0.35 and _same_topology(poly, inset):
            lip = trimesh.creation.extrude_polygon(inset, height=float(max(depth * 0.06, used * 0.2)))
            lip.apply_translation([0.0, 0.0, float(depth)])
            mesh = trimesh.util.concatenate([mesh, lip])
    mesh.merge_vertices()
    mesh.remove_unreferenced_vertices()
    trimesh.repair.fix_normals(mesh)
    return mesh


def _same_topology(a: Polygon, b) -> bool:
    if b.geom_type != "Polygon":
        return False
    if len(a.interiors) != len(b.interiors):
        return False
    # Reject insets that swallow thin negative space (gold emblem).
    if b.area > a.area * 1.08:
        return False
    return True


def svg_to_world(poly: Polygon, scale: float, bounds) -> Polygon:
    minx, miny, maxx, maxy = bounds
    cx = (minx + maxx) / 2.0
    cy = (miny + maxy) / 2.0

    def _map(x, y, z=None):
        # Flip SVG Y so letters stand on +Y before the GTA axis convert.
        return ((x - cx) * scale, -(y - cy) * scale)

    return shapely_transform(poly, _map)


def shapely_transform(poly, func):
    from shapely.ops import transform

    return transform(lambda x, y, z=None: func(x, y, z), poly)


def color_mesh(mesh: trimesh.Trimesh, rgba: tuple[int, int, int, int], name: str) -> trimesh.Trimesh:
    mesh = mesh.copy()
    mesh.visual = trimesh.visual.TextureVisuals(
        uv=_box_uvs(mesh.vertices),
        material=SimpleMaterial(diffuse=np.array(rgba, dtype=np.uint8), name=name),
    )
    mesh.visual.vertex_colors = np.tile(np.array(rgba, dtype=np.uint8), (len(mesh.vertices), 1))
    _ = mesh.vertex_normals
    return mesh


def _box_uvs(vertices: np.ndarray) -> np.ndarray:
    mins = vertices.min(axis=0)
    span = np.maximum(vertices.max(axis=0) - mins, 1e-6)
    uv = np.zeros((len(vertices), 2), dtype=np.float64)
    uv[:, 0] = (vertices[:, 0] - mins[0]) / span[0]
    uv[:, 1] = (vertices[:, 1] - mins[1]) / span[1]
    return uv


def build_meshes() -> tuple[trimesh.Trimesh, trimesh.Trimesh, tuple]:
    blue_polys, gold_polys = load_logo_polygons(GOLD_LIFT_SVG)
    bounds = unary_union(blue_polys + gold_polys).bounds
    flipped_blue = [svg_to_world(p, 1.0, bounds) for p in blue_polys]
    flipped_gold = [svg_to_world(p, 1.0, bounds) for p in gold_polys]
    flip_bounds = unary_union(flipped_blue + flipped_gold).bounds
    scale = TARGET_WIDTH_M / (flip_bounds[2] - flip_bounds[0])
    world_bevel = BEVEL_M / scale
    depth_svg = DEPTH_M / scale
    gold_z = GOLD_FORWARD_M / scale

    blue_mesh = _loft_group(flipped_blue, depth_svg, 0.0, world_bevel, scale)
    gold_mesh = _loft_group(flipped_gold, depth_svg, gold_z, 0.0, scale)
    mins, maxs = combined_bounds(blue_mesh, gold_mesh)
    shift = np.array(
        [-(mins[0] + maxs[0]) / 2.0, -(mins[1] + maxs[1]) / 2.0, -mins[2]],
        dtype=np.float64,
    )
    blue_mesh.apply_translation(shift)
    gold_mesh.apply_translation(shift)
    return blue_mesh, gold_mesh, (scale, flip_bounds)


def _loft_group(
    polys: list[Polygon],
    depth_svg: float,
    z_offset: float,
    bevel_svg: float,
    scale: float,
) -> trimesh.Trimesh:
    meshes = []
    for poly in polys:
        for part in iter_polygons(poly):
            mesh = loft_polygon(part, depth=depth_svg, bevel=bevel_svg)
            mesh.apply_translation([0.0, 0.0, z_offset])
            meshes.append(mesh)
    combined = trimesh.util.concatenate(meshes)
    combined.apply_scale(scale)
    return combined


def render_preview(blue: trimesh.Trimesh, gold: trimesh.Trimesh, path: Path) -> None:
    import matplotlib.pyplot as plt
    from mpl_toolkits.mplot3d.art3d import Poly3DCollection

    fig = plt.figure(figsize=(14, 5.4), facecolor="#303030")
    ax = fig.add_subplot(111, projection="3d", facecolor="#303030")
    combined = trimesh.util.concatenate([blue, gold])
    center = combined.bounds.mean(axis=0)

    def add(mesh: trimesh.Trimesh, color: tuple[float, float, float]) -> None:
        verts = mesh.vertices - center
        # Keep the preview interactive: draw a decimated front-facing subset.
        faces = mesh.faces[::3]
        tris = verts[faces]
        col = Poly3DCollection(
            tris,
            linewidths=0.0,
            shade=False,
            facecolors=[(*color, 1.0)],
            edgecolors="none",
        )
        ax.add_collection3d(col)

    add(blue, tuple(c / 255.0 for c in BLUE_RGBA[:3]))
    add(gold, tuple(c / 255.0 for c in GOLD_RGBA[:3]))
    extents = combined.extents
    ax.set_xlim(-extents[0] / 1.6, extents[0] / 1.6)
    ax.set_ylim(-extents[1] / 1.6, extents[1] / 1.6)
    ax.set_zlim(-extents[2] / 1.2, extents[2] * 1.4)
    ax.view_init(elev=78, azim=-92)
    ax.set_axis_off()
    ax.set_box_aspect((extents[0], max(extents[1], 0.35), extents[2]))
    path.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(path, dpi=130, bbox_inches="tight", facecolor=fig.get_facecolor())
    plt.close(fig)


def render_front(blue: trimesh.Trimesh, gold: trimesh.Trimesh, path: Path) -> None:
    import matplotlib.pyplot as plt
    from matplotlib.collections import PolyCollection

    fig, ax = plt.subplots(figsize=(14, 5.2), facecolor="#2d2d2d")
    ax.set_facecolor("#2d2d2d")

    def add(mesh: trimesh.Trimesh, color) -> None:
        normals = mesh.face_normals
        faces = mesh.faces[normals[:, 2] > 0.15]
        tris = mesh.vertices[faces][:, :, :2]
        col = PolyCollection(tris, facecolors=color, edgecolors="none")
        ax.add_collection(col)

    add(blue, tuple(c / 255.0 for c in BLUE_RGBA[:3]))
    add(gold, tuple(c / 255.0 for c in GOLD_RGBA[:3]))
    mins, maxs = combined_bounds(blue, gold)
    pad = 0.15
    ax.set_xlim(mins[0] - pad, maxs[0] + pad)
    ax.set_ylim(mins[1] - pad, maxs[1] + pad)
    ax.set_aspect("equal")
    ax.axis("off")
    path.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(path, dpi=140, bbox_inches="tight", facecolor=fig.get_facecolor())
    plt.close(fig)


def export_ydr(blue: trimesh.Trimesh, gold: trimesh.Trimesh) -> Path:
    from fivefury import Texture, Ytd, Ytyp, create_ydr
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
    meshes = [
        mesh_to_ydr_input(blue_c, identity, "politie_blue", default_colour=None),
        mesh_to_ydr_input(gold_c, identity, "politie_gold", default_colour=None),
    ]
    materials = [
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
    ]
    embedded = Ytd()
    embedded.texture(_solid_colour_texture("politie_blue", BLUE_RGBA))
    embedded.texture(_solid_colour_texture("politie_gold", GOLD_RGBA))
    build = create_ydr(
        meshes=meshes,
        materials=materials,
        embedded_textures=embedded,
        name="politie_logo",
    )
    ydr_path = OUT_DIR / "politie_logo.ydr"
    build.save(ydr_path)
    from fivefury import read_ydr

    drawable = read_ydr(ydr_path)
    try:
        drawable.ensure_bound_from_render_geometry()
        drawable.save(ydr_path)
    except Exception as exc:
        print(f"Skipping embedded collision: {exc}")

    mins, maxs = combined_bounds(blue, gold)
    # Bounds after GTA axis convert: (x, y, z) -> (x, -z, y)
    gta_min = np.array([mins[0], -maxs[2], mins[1]])
    gta_max = np.array([maxs[0], -mins[2], maxs[1]])
    bb_min = Vector3(float(gta_min[0]), float(gta_min[1]), float(gta_min[2]))
    bb_max = Vector3(float(gta_max[0]), float(gta_max[1]), float(gta_max[2]))
    centre = Vector3(
        float((gta_min[0] + gta_max[0]) / 2.0),
        float((gta_min[1] + gta_max[1]) / 2.0),
        float((gta_min[2] + gta_max[2]) / 2.0),
    )
    radius = float(np.linalg.norm(gta_max - gta_min) / 2.0)
    ytyp = Ytyp(name="politie_logo_meta")
    ytyp.archetypes.append(
        Archetype(
            name="politie_logo",
            asset_name="politie_logo",
            asset_type=ArchetypeAssetType.DRAWABLE,
            bb_min=bb_min,
            bb_max=bb_max,
            bs_centre=centre,
            bs_radius=radius,
            lod_dist=220.0,
            hd_texture_dist=180.0,
        )
    )
    ytyp.save(OUT_DIR / "politie_logo.ytyp")
    return ydr_path


def _solid_colour_texture(name: str, rgba: tuple[int, int, int, int]):
    from fivefury import Texture
    from fivefury.ytd.defs import TextureFormat

    width = height = 16
    r, g, b, a = rgba
    pixel = bytes((b & 255, g & 255, r & 255, a & 255))
    data = pixel * (width * height)
    return Texture.from_raw(
        data,
        width,
        height,
        TextureFormat.A8R8G8B8,
        1,
        name=name,
    )


def combined_bounds(a: trimesh.Trimesh, b: trimesh.Trimesh):
    mins = np.minimum(a.bounds[0], b.bounds[0])
    maxs = np.maximum(a.bounds[1], b.bounds[1])
    return mins, maxs


def main() -> None:
    PREVIEW_DIR.mkdir(parents=True, exist_ok=True)
    blue, gold, meta = build_meshes()
    print("blue verts", len(blue.vertices), "faces", len(blue.faces))
    print("gold verts", len(gold.vertices), "faces", len(gold.faces))
    print("blue bounds", blue.bounds)
    print("gold bounds", gold.bounds)
    preview = PREVIEW_DIR / "politie_logo_preview.png"
    try:
        render_preview(blue, gold, preview)
        print("preview", preview)
    except Exception as exc:
        print("preview failed", exc)
    front = PREVIEW_DIR / "politie_logo_front.png"
    render_front(blue, gold, front)
    print("front", front)
    ydr_path = export_ydr(blue, gold)
    print("ydr", ydr_path, "size", ydr_path.stat().st_size)


if __name__ == "__main__":
    main()
