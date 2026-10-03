fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'mallorca_speedometer'
author 'Mallorca'
description 'Voertuig speedometer HUD'
version '1.4.2'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

shared_script 'config.lua'
client_script 'client.lua'
server_script 'server.lua'
