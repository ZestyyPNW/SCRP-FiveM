fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'ND Framework'
description 'McDonald\'s Job for ND Framework'
version '1.0.0'

dependencies {
    'ox_lib',
    'ox_inventory',
    'ND_Core'
}

shared_scripts {
    '@ox_lib/init.lua',
    '@ND_Core/init.lua',
    'config.lua',
}

client_scripts {
    'client/main.lua',
    'client/menu.lua'
}

server_script 'server/main.lua'
