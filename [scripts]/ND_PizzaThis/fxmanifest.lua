fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'ND Framework'
description 'Pizza This Restaurant for ND Framework'
version '1.0.0'

dependencies {
    'ox_lib',
    'ox_inventory',
    'ox_target',
    'ND_Core'
}

shared_scripts {
    '@ox_lib/init.lua',
    '@ND_Core/init.lua',
    'config.lua',
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    'client/*.lua',
}

server_script 'server/*.lua'
