fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'ND Framework'
description 'Taxi Job for ND Framework'
version '1.0.0'

dependencies {
    'ox_lib',
    'ox_target',
    'ND_Core'
}

ui_page 'html/meter.html'

shared_scripts {
    '@ox_lib/init.lua',
    '@ND_Core/init.lua',
    'config.lua'
}

client_script 'client/main.lua'
server_script 'server/main.lua'

files {
    'html/meter.css',
    'html/meter.html',
    'html/meter.js',
    'html/reset.css',
    'html/g5-meter.png'
}
