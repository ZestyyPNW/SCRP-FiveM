fx_version 'bodacious'
game 'gta5'
clr_disable_task_scheduler 'yes'

name "BigDaddy-Fuel"
description "refuel vehicles"
author "Big Daddy"
version "1.7.2"

client_scripts {
	'*.Client.net.dll',
	'Newtonsoft.Json.dll',
	'evchargers.json',
	'GasStations.json'
}

server_scripts {
	'*.Server.net.dll',
	'Newtonsoft.Json.dll',
	'server.lua',
	'BigDaddy*.js'
}

ui_page 'nui/ui.html'

files {
    'settings.ini',
    'nui/ui.html',
	'nui/*.png',
	'nui/digital.ttf',
	'stream/evcharger_ytyp.ytyp',
    'data/*.meta',
    'data/fuel_sounds.dat54.rel',
    'audiodirectory/fuel_sounds.awc',
}

data_file 'DLC_ITYP_REQUEST' 'stream/evcharger_ytyp.ytyp'
data_file 'VEHICLE_VARIATION_FILE' 'data/carvariations*.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/vehicles.meta'
data_file 'CARCOLS_FILE' 'data/carcols.meta'
data_file 'AUDIO_WAVEPACK' 'audiodirectory'
data_file 'AUDIO_SOUNDDATA' 'data/fuel_sounds.dat'

