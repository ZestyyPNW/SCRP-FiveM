fx_version 'bodacious'
game 'gta5'

author 'Big Daddy'
version '1.5.0'
description 'More Realistic Vehicle Damage, Tire/Wheel Damage, Cinematic Rollovers, Hydroplaning'

client_scripts {
	'*Client.net.dll',
	'Newtonsoft.Json.dll',
	'BigDaddy-*.js'
} 
server_scripts {
	'*Server.net.dll',
	'Newtonsoft.Json.dll',
	'BigDaddy-*.js'
}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/assets/BADABB_.TTF',
	'html/assets/*.css',
	'html/assets/img/*.svg',
	'html/assets/img/*.png',
	'settings.ini',
	'menu.json',
	'menu.ini'
}
