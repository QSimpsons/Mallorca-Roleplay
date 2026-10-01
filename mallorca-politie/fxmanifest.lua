fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Mallorca Roleplay'
description 'Volledige Nederlandse Politie-job — 10 rangen van aspirant tot eerste hoofdcommissaris'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua',
    'locales/nl.lua'
}

client_scripts {
    'client/main.lua',
    'client/cloakroom.lua',
    'client/armory.lua',
    'client/garage.lua',
    'client/actions.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'oxmysql'
}
