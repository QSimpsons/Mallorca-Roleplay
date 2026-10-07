fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Eclipse'
description 'Eclipse-airbags: airbags uit het stuur en dashboard, zonder brand'
version '1.2.0'

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
