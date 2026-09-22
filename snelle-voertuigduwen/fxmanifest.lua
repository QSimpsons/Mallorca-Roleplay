fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Snelle / Mallorca Roleplay'
description 'Duw een voertuig met de hand of schuif het aan de kant van de weg'
version '1.0.0'

dependencies {
    'es_extended'
}

-- Zonder ox_lib: comment de regel @ox_lib/init.lua uit.
shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'locales/en.lua',
    'locales/nl.lua',
    'shared/locale.lua',
    'shared/utils.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}
