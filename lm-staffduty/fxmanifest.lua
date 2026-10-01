

fx_version 'cerulean'
game 'gta5'
description 'Vex shop | https://discord.gg/T3qfgUHKHr'

use_fxv2_oal 'yes'
lua54 'yes'

name 'lm-staffduty'
author 'Vex Shop'
version '1.0.0'

dependencies {
	'ox_lib'
}

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'src/client/*.lua'
}

server_scripts {
    'src/server/*.lua'
}

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/css/style.css',
    'html/js/script.js',
    'locales/*.json',
    'shared/*.lua'
}

ox_libs {
    'locale'
}
