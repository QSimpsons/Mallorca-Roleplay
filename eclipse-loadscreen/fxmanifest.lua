fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'eclipse-loadscreen'
author 'Eclipse Roleplay'
description 'Custom loadingscreen voor Eclipse Roleplay'
version '1.0.0'

loadscreen 'index.html'
loadscreen_cursor 'yes'
loadscreen_manual_shutdown 'yes'

client_script 'client.lua'
server_script 'server.lua'

files {
    'index.html',
    'style.css',
    'script.js',
    'config.js',
    'assets/background.mp4',
    'assets/poster.jpg',
    'assets/theme.ogg',
    'assets/fonts/Cinzel-Bold.ttf',
    'assets/fonts/Cinzel-Medium.ttf',
    'assets/fonts/Inter-Regular.ttf',
    'assets/fonts/Inter-Medium.ttf',
    'assets/fonts/Inter-SemiBold.ttf',
}
