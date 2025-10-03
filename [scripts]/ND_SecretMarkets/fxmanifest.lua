fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'ND_SecretMarkets'
author 'ND Framework'
description 'Underground marketplace system with configurable AI dealers'
version '1.0.0'

dependencies {
    'ND_Core',
    'ox_lib',
    'ox_target'
}

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

files {
    'config/*.lua',
    'zipper-sound-effect-336780.mp3',
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

ui_page 'html/index.html'

data_file 'AUDIO_WAVEPACK' 'zipper-sound-effect-336780.mp3'