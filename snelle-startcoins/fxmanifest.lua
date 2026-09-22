fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Snelle'
description 'Geeft elke nieuwe speler eenmalig startcoins'
version '1.0.0'

dependencies {
    'es_extended',
    'oxmysql'
}

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/grant.lua',
    'server/main.lua'
}
