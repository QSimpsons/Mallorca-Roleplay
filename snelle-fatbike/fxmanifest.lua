fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'snelle-fatbike'
author 'Snelle'
description 'Fatbike spawn/opbergen + licht streammodel snellefat'
version '1.3.1'

shared_script 'config.lua'
client_script 'client.lua'
server_script 'server.lua'

files {
    'data/vehicles.meta',
    'data/handling.meta',
    'data/carvariations.meta',
}

data_file 'HANDLING_FILE' 'data/handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/carvariations.meta'
