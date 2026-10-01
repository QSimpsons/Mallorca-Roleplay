fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Snelle'
description 'Pas de tijd en het weer aan met /time'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/logic.js',
    'html/app.js'
}
