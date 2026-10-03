fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'mallorca-speedometer'
author 'Mallorca'
description 'Voertuig speedometer HUD'
version '1.4.0'

ui_page 'html/index.html'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}
