fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Snelle / Mallorca Roleplay'
description 'Pop & Bangs stage 1 t/m 6 als inventory-items, zonder SQL'
version '1.0.0'

dependencies {
    'es_extended'
}

-- Geen ox_lib? Zet de regel hieronder uit. Het script valt dan terug op ESX-notificaties.
shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'locales/en.lua',
    'locales/nl.lua',
    'shared/locale.lua',
    'shared/utils.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}
