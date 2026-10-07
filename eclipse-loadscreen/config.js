// Pas dit bestand aan voor jullie server. De video en de muziek staan in assets/.
const Config = {
    serverName: "Eclipse Roleplay",
    statusLabel: "Server online",
    slots: null,

    discordLabel: "discord.gg/eclipserp",
    discordUrl: "https://discord.gg/eclipserp",

    music: {
        enabled: true,
        file: "assets/theme.ogg",
        title: "Eclipse Theme",
        volume: 0.32,
    },

    rulesTitle: "Regels",
    rules: [
        "Geen RDM of VDM",
        "Blijf in character",
        "Respecteer iedere speler",
        "Volg aanwijzingen van staff",
    ],

    keys: [
        { key: "T", label: "Chat" },
        { key: "F2", label: "Inventaris" },
        { key: "L", label: "Slot" },
        { key: "X", label: "Handen omhoog" },
    ],

    tips: [
        "Een sterk verhaal wint het van een sterk wapen.",
        "Blijf in character. Overleg buiten je rol via /b of Discord.",
        "Metagaming en powergaming horen niet in de stad.",
        "Nieuw hier? Lees de regels en meld je op Discord.",
        "Gebruik /report als iets misgaat. Houd het netjes.",
        "Je personage wil morgen ook nog leven.",
        "Geen random deathmatch en geen vehicle deathmatch.",
    ],
    tipInterval: 6500,
    showLog: true,
    hint: "Spatie  ·  geluid aan of uit",
};
