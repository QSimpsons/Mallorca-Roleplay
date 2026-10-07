fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'mallorca-speedometer'
author 'Eclipse Roleplay'
description 'Complete voertuig speedometer in Eclipse-blauw: tank (SQL), motor, schade, pinkers, handrem, lichten'
version '1.4.2'

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
    'html/app.js',
    'html/voorbeeld.html',
    'html/auto-demo.html',
    'html/fonts/exo2-600.ttf',
    'html/fonts/exo2-700.ttf',
    'html/fonts/exo2-800.ttf'
}
