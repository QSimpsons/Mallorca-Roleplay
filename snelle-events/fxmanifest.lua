fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Snelle / Mallorca Roleplay'
description 'Uitgebreid ESX event-systeem: 10 types, roster, race, zone, invites, spectate'
version '2.0.0'

dependencies {
    'es_extended'
}

ui_page 'html/index.html'

shared_scripts {
    'config.lua',
    'shared/locale.lua',
    'shared/utils.lua'
}

client_scripts {
    'client/main.lua',
    'client/events.lua',
    'client/nui.lua'
}

server_scripts {
    'server/permissions.lua',
    'server/buckets.lua',
    'server/announce.lua',
    'server/database.lua',
    'server/events.lua',
    'server/main.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'locales/*.lua'
}
