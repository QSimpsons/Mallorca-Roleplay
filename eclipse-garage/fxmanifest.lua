fx_version "cerulean"
game "gta5"
lua54 "yes"

author 'Vex Shop'
description 'Vex shop | https://discord.gg/T3qfgUHKHr'
version "0.0.0"

ui_page "html/index.html"

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"code/server/functions.lua",
	"code/server/impound.lua",
	"code/server/main.lua"
}

client_scripts {
	"code/client/functions.lua",
	"code/client/main.lua"
}

shared_scripts {
	"@ox_lib/init.lua",
	"@es_extended/imports.lua",
	"shared/esrp_lib.lua",
	"shared/config.lua"
}

files {
	"locales/*",
	"html/index.html"
}

escrow_ignore {
	"locales/*",
	"config.lua"
}

dependencies {
	"ox_lib",
	"es_extended",
	"oxmysql"
}