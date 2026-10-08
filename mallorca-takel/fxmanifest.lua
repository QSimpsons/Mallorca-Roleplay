fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Mallorca Roleplay'
description 'Mallorca Takel — volledig nieuw takelscript voor fmltow en dlbrickade'
version '2.0.0'

ui_page 'html/index.html'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/tow.lua',
    'client/main.lua',
    'client/target.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

dependencies {
    'es_extended'
}
