fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'ND Framework'
description 'Small resources and quality of life features'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/idle.lua'
}

server_scripts {
    'server/main.lua'
}
