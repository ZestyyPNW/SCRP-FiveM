fx_version 'bodacious'

game 'gta5'

description 'Personal Protection'
author 'Big Daddy'
version '1.0'

client_scripts {
	'*.Client.net.dll',
	'settings.ini'
}

server_scripts {
	'*.Server.net.dll',
	'Newtonsoft.Json.dll',
	'settings.ini'
}

files {
	'stream/bzzz_bigdaddy_prop_pepper_spray.ytyp'
}

data_file 'DLC_ITYP_REQUEST' 'stream/bzzz_bigdaddy_prop_pepper_spray.ytyp'