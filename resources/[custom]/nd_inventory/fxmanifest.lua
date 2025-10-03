fx_version 'cerulean'
game 'gta5'

name 'nd_inventory'
author 'Custom Build'
version '1.0.0'
description 'Custom inventory system built for NDCore'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/commands.lua',
    'server/db_check.lua'
}

client_scripts {
    'client/*.lua'
}

ui_page 'ui/build/index.html'

files {
    'ui/build/index.html',
    'ui/build/**/*',
    'items.json'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
