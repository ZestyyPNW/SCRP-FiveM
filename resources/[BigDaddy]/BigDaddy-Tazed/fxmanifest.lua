fx_version 'bodacious'
game 'gta5'

name "BigDaddy-Tazed"
description "Tazed Effects"
author "Big Daddy"
version "1.0"

client_scripts {
	'BigDaddy-Tazed.Client.net.dll',
}

server_scripts {
	'BigDaddy-Tazed.Server.net.dll',
	'Newtonsoft.Json.dll',
}

files {
    'settings.ini',
}
