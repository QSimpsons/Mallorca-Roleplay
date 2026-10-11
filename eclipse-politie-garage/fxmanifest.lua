fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Eclipse Roleplay'
description 'ECLIPSE RP politiegarage — donkerblauw NUI voor dienstvoertuigen'
version '1.2.0'

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
    'html/img/logo.png',
    'html/img/vehicles/polargento1.png',
    'html/img/vehicles/polargent01.png',
    'html/img/vehicles/*.png',
    'html/img/vehicles/*.webp',
    'html/img/vehicles/*.jpg',
    'html/img/vehicles/*.jpeg',
    'html/fonts/exo2-500.ttf',
    'html/fonts/exo2-600.ttf',
    'html/fonts/exo2-700.ttf',
    'html/fonts/exo2-800.ttf'
}

dependencies {
    'es_extended'
}
