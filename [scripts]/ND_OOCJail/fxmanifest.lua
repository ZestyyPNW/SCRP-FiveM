fx_version 'cerulean'
game 'gta5'

author 'Your Server'
description 'OOC Jail System with Discord Integration'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    'server/main.lua',
    'server/discord.lua'
}

client_scripts {
    'client/main.lua',
    'client/restrictions.lua'
}

dependencies {
    'ox_lib',
    'ND_Core'
}
