fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Snelle'
description 'Echte airbags uit het stuur en het dashboard bij een harde botsing'
version '1.1.0'

data_file 'DLC_ITYP_REQUEST' 'stream/prop_carairbag.ytyp'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}
