// Pas dit bestand aan voor jullie server. De video en de muziek staan in assets/.
const Config = {
    serverName: "Eclipse Roleplay",
    statusLabel: "Server online",
    slots: null,

    discordLabel: "discord.gg/eclipserp",
    discordUrl: "https://discord.gg/eclipserp",

    // YouTube-clip als achtergrond. Het geluid komt uit die video.
    // Eclipse Roleplay verschijnt pas als het laden klaar is.
    // Lukt de video niet, dan valt het scherm terug op assets/background.mp4.
    // Zet enabled op false om meteen die eigen mp4 te gebruiken.
    clip: {
        enabled: true,
        // Deze video zet insluiten uit. Het scherm gebruikt dan assets/background.mp4.
        url: "https://www.youtube.com/watch?v=Hr4NFyCIsMk",
        title: "MonsterMash",
    },

    // Muziek. Zet enabled op false om het paneel en het geluid weg te laten.
    // file is een eigen nummer in deze resource. title is de naam op het scherm.
    music: {
        enabled: true,
        file: "assets/theme.ogg",
        title: "Eclipse Theme",
        volume: 0.32,
    },

    // Staffteam. Zet enabled op false om het paneel te verbergen.
    // role is de functie, name is de weergavenaam. Lege namen worden overgeslagen.
    staff: {
        enabled: true,
        title: "Staffteam",
        members: [
            { role: "Eigenaar", name: "Invullen" },
            { role: "Beheer", name: "Invullen" },
            { role: "Hoofdadmin", name: "Invullen" },
            { role: "Admin", name: "Invullen" },
            { role: "Moderator", name: "Invullen" },
        ],
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
