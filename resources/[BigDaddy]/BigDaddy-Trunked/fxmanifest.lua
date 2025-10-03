fx_version 'bodacious'
game 'gta5'
clr_disable_task_scheduler 'yes'

name "BigDaddy-Trunked"
description "Vehicle Trunk Interaction"
author "Big Daddy"
version "1.8.3"

client_scripts {
	'*.Client.net.dll',
}

server_scripts {
	'*.Server.net.dll',
	'BigDaddy*.js',
	'Newtonsoft.Json.dll'
}

files {
	'settings.ini',
}