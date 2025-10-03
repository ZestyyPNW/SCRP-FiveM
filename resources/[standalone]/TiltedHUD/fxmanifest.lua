-- Unified Tilted HUD System
-- Combines TiltedHUD health/armor display with UnifiedHUD priority and location features

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Unified HUD System'
description 'Tilted perspective HUD with priority system, location info, health/armor display, and BigDaddy-Fuel integration'
version '2.1.0'

dependency 'BigDaddy-Fuel'

shared_scripts {
    'config.lua',
    'postals.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/imgs/health.png',
    'html/imgs/armor.png',
    'html/imgs/stamina.png'
}

exports {
    'getAOP',
    'getPostal',
    'getSocalStatus',
    'getNocalStatus',
    'getHealth',
    'getArmor',
    'isHudVisible',
    'setHudVisibility',
    'UpdateFuelDisplay',
    'HideFuelDisplay'
}

server_exports {
    'getPostal'
}

provide 'nearest-postal'