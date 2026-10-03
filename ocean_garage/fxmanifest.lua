fx_version "cerulean"
game "gta5"
lua54 "yes"

author 'Vex Shop'
description 'Vex shop | https://discord.gg/T3qfgUHKHr'
version "0.0.0"

ui_page "code/web/dist/index.html"

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
	"@esrp_lib/init.lua",
	"shared/compat.lua",
	"@es_extended/imports.lua",
	"shared/config.lua"
}

files {
	"locales/*",
}

files {
	"code/web/dist/index.html",
	"code/web/dist/**/*"
}

escrow_ignore {
	"locales/*",
	"config.lua"
}

dependencies {
	"esrp_lib",
	"ox_lib",
	"es_extended",
	"oxmysql"
}