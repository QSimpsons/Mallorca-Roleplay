fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'eclipse-store'
author 'Eclipse Roleplay'
description 'In-game /store gekoppeld aan de Tebex Headless API (Eclipse Store)'
version '1.0.0'

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
    'html/preview.html',
    'html/logo.png'
}