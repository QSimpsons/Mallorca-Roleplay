fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'eclipse-identity'
author 'Eclipse Roleplay'
description 'Burgerregistratie voor ECLIPSE RP'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts {
    'config.lua',
    'shared/validate.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'html/index.html',
    'html/preview.html',
    'html/style.css',
    'html/app.js',
    'html/img/logo.png',
    'html/fonts/exo2-500.ttf',
    'html/fonts/exo2-600.ttf',
    'html/fonts/exo2-700.ttf',
    'html/fonts/exo2-800.ttf'
}
