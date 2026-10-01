fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Snelle'
description 'Flitspalen met een maximum per paal, en een flits als je door rood rijdt'
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
    'html/app.js'
}
