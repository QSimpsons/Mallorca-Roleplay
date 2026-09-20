fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Snelle / Mallorca Roleplay'
description 'ESX handwas voor voertuigen: items, emmer vullen, winkel, ox_inventory + ox_target'
version '1.0.0'

dependencies {
    'es_extended'
}

-- Als je geen ox_lib hebt: zet de regel @ox_lib/init.lua uit.
shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'locales/en.lua',
    'locales/nl.lua',
    'shared/locale.lua',
    'shared/utils.lua'
}

client_scripts {
    'client/main.lua',
    'client/wash.lua',
    'client/shop.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'locales/*.lua'
}
