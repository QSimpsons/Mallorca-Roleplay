fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'eclipse-hud'
author 'Eclipse Roleplay'
description 'Volledige custom HUD voor Eclipse Roleplay — blauw thema met logo, voeding, drinken, ID en jobs'
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
    'html/img/logo.jpg'
}
