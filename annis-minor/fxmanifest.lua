fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Snelle'
description 'Annis Minor — lore-friendly compacte coupé, viercilinder en V6'
version '1.0.0'

files {
    'data/handling.meta',
    'data/vehicles.meta',
    'data/carvariations.meta',
}

data_file 'HANDLING_FILE' 'data/handling.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/carvariations.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/vehicles.meta'

client_script 'client/main.lua'
server_script 'server/main.lua'
