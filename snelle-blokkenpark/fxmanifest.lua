fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'snelle-blokkenpark'
author 'Snelle / Mallorca Roleplay'
description 'Volledig custom Blokkenpark (Legion Square) met ondergrondse parking'
version '1.0.0'

shared_script 'config.lua'

client_scripts {
    'client/util.lua',
    'client/logos.lua',
    'client/props.lua',
    'client/parking.lua',
}

server_script 'server/main.lua'

files {
    'html/sign.html',
    'html/img/logo.png',
}
