fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'VertexScripts'
description 'Staff menu voor jouw FiveM stad'

dependencies {
  'ox_lib',
  'oxmysql',
  'es_extended',
}

shared_scripts {
  '@ox_lib/init.lua',
  '@es_extended/imports.lua',
  'src/vx_compat.lua',
  'config.lua',
  'data/comserve.lua',
  'src/shared.lua',
}

client_scripts {
  'src/client/client.lua',
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'src/server/logger.lua',
  'src/server/database.lua',
  'src/server/blacklist.lua',
  'src/server/server.lua',
  'src/server/utils.lua',
  'data/config.lua',
}

escrow_ignore {
  'config.lua',
  'data/comserve.lua',
  'data/config.lua',
  'types.lua',
  'src/vx_compat.lua',
}
