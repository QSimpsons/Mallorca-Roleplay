fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'staffzaak'
author 'Snelle'
description 'Staffdienst aan en uit met /staffzaak'
version '1.0.0'

shared_script 'config.lua'

client_script 'client.lua'

server_scripts {
    'config.server.lua',
    'server.lua',
}
