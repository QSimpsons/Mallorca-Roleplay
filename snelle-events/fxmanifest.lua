fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Snelle / Mallorca Roleplay'
description 'ESX event-beheersysteem met NUI panel, teleportatie en meerdere eventtypes'
version '1.1.0'

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
    'server/events.lua',
    'server/main.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'locales/*.lua'
}
