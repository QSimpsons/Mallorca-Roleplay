fx_version 'adamant'
game 'gta5'
author 'Vex Shop'
description 'Vex shop | https://discord.gg/T3qfgUHKHr'

lua54 'yes'

server_scripts {
    'src/server/main.lua',
    '@mysql-async/lib/MySQL.lua'
}

client_scripts {
    'src/client/main.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'config.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'mysql-async',
    'ox_target',
    'tk_ambulancejob'
}

escrow_ignore {
    "config.lua",
    "src/server/main.lua",
    "src/client/main.lua",
}
