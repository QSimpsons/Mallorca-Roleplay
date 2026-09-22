





fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Mallorca-Dev'
description 'Mallorca Roleplay store'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/img/**.png',
    'html/img/**.jpg'
}

client_script {'client.lua'}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'server.lua',
    'starter_vipcoins.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua'
}

dependencies {
    'killmessages',
    'mallorca_vipmsg'
}
