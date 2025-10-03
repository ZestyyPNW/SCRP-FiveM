fx_version 'bodacious'

game 'gta5'

description 'Control Traffic with Road Flares, Traffic Cones, Traffic Barrels, Flagman stuff, Road Blocks'
author 'Big Daddy'
version '1.7.0'

client_scripts {
	'*.Client.net.dll',
	'Newtonsoft.Json.dll',
}

server_scripts {
	'*.Server.net.dll',
	'Newtonsoft.Json.dll',
	'BigDaddy-Server.js'
}

ui_page 'nui/ui.html'

files {
	'data/explosionfx.dat',
	'data/weapons.meta',
	'settings.ini',
	'stream/big_daddy_prop_sign_slow_stop.ytyp',
	'stream/bzzz_prop_vehicle_triangle_a.ytyp',
	'nui/ui.html',
	'nui/assets/img/*.png',
	'nui/assets/img/*.svg',
	'nui/assets/*.css',
	'nui/assets/*.TTF',
	'menu.ini',
	'menu.json'
}

data_file 'EXPLOSIONFX_FILE' 'data/explosionfx.dat'
data_file 'WEAPONINFO_FILE_PATCH' 'data/weapons.meta'
data_file 'DLC_ITYP_REQUEST' 'stream/big_daddy_prop_sign_slow_stop.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/bzzz_prop_vehicle_triangle_a.ytyp'
