fx_version "cerulean"
game "gta5"
lua54 "yes"

author "Vex Shop"
version "1.0.0"
description "Vex shop | https://discord.gg/T3qfgUHKHr"

dependencies {
	"esrp_lib",
	"oxmysql"
}

shared_scripts {
	"@esrp_lib/init.lua",
	"config.shared.lua"
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"src/server.lua"
}
