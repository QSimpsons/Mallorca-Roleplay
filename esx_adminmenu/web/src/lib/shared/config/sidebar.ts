import PlayersIcon from "../components/icons/PlayersIcon.svelte";
import ServerIcon from "../components/icons/ServerIcon.svelte";
import CarIcon from "../components/icons/CarIcon.svelte";
import LogsIcon from "../components/icons/LogsIcon.svelte";
import StaffIcon from "../components/icons/StaffIcon.svelte";
import type { SidebarOption } from "../types/sidebar";

export const sidebarOptions: SidebarOption[] = [
  {
    label: "dashboard_home",
    value: "dashboard_home",
    icon: ServerIcon,
  },
  {
    label: "staff_desk",
    value: "staff_desk",
    icon: StaffIcon,
  },
  {
    label: "player_management",
    value: "ply_management",
    icon: PlayersIcon,
    subOptions: [
      { label: "bans_list", value: "ply_bans", icon: PlayersIcon },
      { label: "vehicles_list", value: "ply_vehicles", icon: CarIcon },
      { label: "player_search", value: "ply_data", icon: PlayersIcon },
      { label: "recent_players", value: "ply_recent", icon: PlayersIcon },
    ],
  },
  {
    label: "server_management",
    value: "srv_management",
    icon: ServerIcon,
  },
  {
    label: "admin_logs",
    value: "admin_logs",
    icon: LogsIcon,
  },
];

