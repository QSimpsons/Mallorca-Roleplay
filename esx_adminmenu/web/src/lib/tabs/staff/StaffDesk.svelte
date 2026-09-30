<script lang="ts">
	import { onMount } from "svelte";
	import { t } from "$lib/shared/util/util";
	import { uiState } from "$lib/shared/stores/user.svelte";
	import { fetchStaffDesk, gotoPlayer, runAdminMenuAction, spectatePlayer, toggleStaffDuty, type StaffMember } from "$lib/shared/nui/admin";

	let onDuty = $state(false);
	let startedAt = $state<number | null>(null);
	let staff = $state<StaffMember[]>([]);
	let now = $state(Date.now());
	let busy = $state(false);

	const map = { minX: -3400, maxX: 4500, minY: -3700, maxY: 8000 };

	function formatDuration(seconds: number) {
		const total = Math.max(0, Math.floor(seconds));
		const hours = Math.floor(total / 3600);
		const minutes = Math.floor((total % 3600) / 60);
		const secs = total % 60;
		return [hours, minutes, secs].map((part) => String(part).padStart(2, "0")).join(":");
	}

	function shiftSeconds(memberStartedAt?: number | null) {
		if (!memberStartedAt) return 0;
		return now / 1000 - memberStartedAt;
	}

	function applyState(next: { onDuty?: boolean; startedAt?: number | null; staff?: StaffMember[] } | null) {
		if (!next) return;
		onDuty = next.onDuty === true;
		startedAt = next.startedAt ?? null;
		staff = next.staff ?? [];
		uiState.setAdminMenuState("staffDuty", onDuty);
	}

	async function refresh() {
		const res = await fetchStaffDesk();
		if (res?.success) applyState(res);
	}

	async function toggleDuty() {
		if (busy) return;
		busy = true;
		try {
			const res = await toggleStaffDuty();
			if (res?.success) applyState(res);
		} finally {
			busy = false;
		}
	}

	async function runTool(action: string) {
		if (busy) return;
		busy = true;
		try {
			await runAdminMenuAction(action);
		} finally {
			busy = false;
		}
	}

	function markerStyle(member: StaffMember) {
		if (member.x == null || member.y == null) return "display: none;";
		const x = ((member.x - map.minX) / (map.maxX - map.minX)) * 100;
		const y = ((member.y - map.minY) / (map.maxY - map.minY)) * 100;
		const left = Math.max(2, Math.min(98, x));
		const top = Math.max(2, Math.min(98, 100 - y));
		return `left: ${left}%; top: ${top}%;`;
	}

	const tools = [
		{ action: "flipVehicle", label: "flip_vehicle" },
		{ action: "repairVehicle", label: "repair_vehicle" },
		{ action: "cleanVehicle", label: "clean_vehicle" },
		{ action: "refuelVehicle", label: "refuel_vehicle" },
		{ action: "unlockVehicle", label: "unlock_vehicle" },
		{ action: "deleteNearestVehicle", label: "delete_nearby_vehicle" },
	];

	onMount(() => {
		refresh();
		const poll = window.setInterval(refresh, 2000);
		const clock = window.setInterval(() => {
			now = Date.now();
		}, 1000);
		return () => {
			window.clearInterval(poll);
			window.clearInterval(clock);
		};
	});
</script>

<section class="staff-desk">
	<header class="staff-header">
		<div>
			<h2>{t("staff_desk")}</h2>
			<p>{t("staff_desk_hint")}</p>
		</div>
		<button class="duty-button" class:on={onDuty} onclick={toggleDuty} disabled={busy}>
			<span>{onDuty ? t("clock_out") : t("clock_in")}</span>
			<strong>{onDuty ? formatDuration(shiftSeconds(startedAt)) : t("off_duty")}</strong>
		</button>
	</header>

	<div class="staff-layout">
		<div class="map-card">
			<div class="map-board" aria-hidden="true">
				{#each staff as member (member.id)}
					{#if member.x != null && member.y != null}
						<button class="map-marker" class:self={member.self} style={markerStyle(member)} title={member.name} onclick={() => gotoPlayer(member.id)}>
							<span>{member.name}</span>
						</button>
					{/if}
				{/each}
			</div>
			<div class="tool-grid">
				{#each tools as tool}
					<button class="tool" onclick={() => runTool(tool.action)} disabled={busy}>{t(tool.label)}</button>
				{/each}
			</div>
		</div>

		<div class="roster">
			<div class="roster-title">
				<h3>{t("staff_live")}</h3>
				<span>{staff.length}</span>
			</div>
			{#if staff.length === 0}
				<p class="empty">{t("no_staff_on_duty")}</p>
			{:else}
				<ul>
					{#each staff as member (member.id)}
						<li>
							<div class="who">
								<strong>{member.name} {member.self ? `(${t("you")})` : ""}</strong>
								<small>{member.street || t("street")} · {member.inVehicle ? t("in_vehicle") : t("on_foot")}</small>
							</div>
							<div class="meta">
								<span>{t("duty_time")} {formatDuration(shiftSeconds(member.startedAt))}</span>
								<span>{member.distance != null ? `${member.distance} m` : "—"}</span>
							</div>
							{#if !member.self}
								<div class="row-actions">
									<button onclick={() => gotoPlayer(member.id)}>{t("goto")}</button>
									<button onclick={() => spectatePlayer(member.id)}>{t("spectate")}</button>
								</div>
							{/if}
						</li>
					{/each}
				</ul>
			{/if}
		</div>
	</div>
</section>

<style>
	.staff-desk {
		display: flex;
		flex-direction: column;
		gap: 1.4vh;
		height: 100%;
		min-height: 0;
	}

	.staff-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		gap: 1.6vh;
	}

	.staff-header h2 {
		margin: 0;
		font-size: 2vh;
		font-weight: 600;
	}

	.staff-header p {
		margin: 0.3vh 0 0;
		color: rgba(242, 242, 242, 0.62);
		font-size: 1.25vh;
	}

	.duty-button {
		border: 1px solid rgba(242, 242, 242, 0.14);
		background: #202020;
		color: #f2f2f2;
		border-radius: 0.8vh;
		padding: 1vh 1.4vh;
		min-width: 16vh;
		display: flex;
		flex-direction: column;
		align-items: flex-start;
		gap: 0.2vh;
		cursor: pointer;
	}

	.duty-button strong {
		font-size: 1.7vh;
	}

	.duty-button.on {
		border-color: rgba(251, 155, 4, 0.8);
		background: rgba(251, 155, 4, 0.16);
	}

	.staff-layout {
		display: grid;
		grid-template-columns: 1.4fr 1fr;
		gap: 1.4vh;
		min-height: 0;
		flex: 1;
	}

	.map-card,
	.roster {
		background: #1c1c1c;
		border: 1px solid rgba(242, 242, 242, 0.06);
		border-radius: 0.9vh;
		padding: 1.2vh;
		min-height: 0;
	}

	.map-board {
		position: relative;
		height: 28vh;
		border-radius: 0.7vh;
		background:
			linear-gradient(rgba(242, 242, 242, 0.05) 1px, transparent 1px),
			linear-gradient(90deg, rgba(242, 242, 242, 0.05) 1px, transparent 1px),
			radial-gradient(circle at 50% 55%, rgba(251, 155, 4, 0.16), transparent 42%),
			#121212;
		background-size: 8% 8%, 8% 8%, auto, auto;
		overflow: hidden;
	}

	.map-marker {
		position: absolute;
		transform: translate(-50%, -50%);
		border: 0;
		background: #60a5fa;
		color: #101010;
		border-radius: 999px;
		padding: 0.35vh 0.7vh;
		font-size: 1.05vh;
		font-weight: 600;
		cursor: pointer;
		max-width: 14vh;
	}

	.map-marker span {
		display: block;
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
	}

	.map-marker.self {
		background: #fb9b04;
	}

	.tool-grid {
		display: grid;
		grid-template-columns: repeat(3, minmax(0, 1fr));
		gap: 0.7vh;
		margin-top: 1vh;
	}

	.tool,
	.row-actions button {
		border: 1px solid rgba(242, 242, 242, 0.1);
		background: #262626;
		color: #f2f2f2;
		border-radius: 0.55vh;
		padding: 0.8vh 0.7vh;
		font-size: 1.15vh;
		cursor: pointer;
	}

	.tool:hover,
	.row-actions button:hover,
	.duty-button:hover {
		border-color: rgba(251, 155, 4, 0.7);
	}

	.roster {
		display: flex;
		flex-direction: column;
		overflow: hidden;
	}

	.roster-title {
		display: flex;
		justify-content: space-between;
		align-items: center;
	}

	.roster-title h3 {
		margin: 0;
		font-size: 1.5vh;
	}

	.roster-title span,
	.empty,
	.who small,
	.meta {
		color: rgba(242, 242, 242, 0.62);
		font-size: 1.15vh;
	}

	.roster ul {
		list-style: none;
		margin: 1vh 0 0;
		padding: 0;
		overflow: auto;
		display: flex;
		flex-direction: column;
		gap: 0.8vh;
	}

	.roster li {
		background: #141414;
		border-radius: 0.7vh;
		padding: 0.9vh;
		display: flex;
		flex-direction: column;
		gap: 0.45vh;
	}

	.who strong {
		display: block;
		font-size: 1.3vh;
	}

	.meta,
	.row-actions {
		display: flex;
		justify-content: space-between;
		gap: 0.8vh;
	}

	.row-actions button {
		flex: 1;
	}

	button:disabled {
		opacity: 0.6;
		cursor: default;
	}
</style>
