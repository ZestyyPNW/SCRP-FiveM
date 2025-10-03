fx_version "adamant"
game "gta5"

name "Radio Animation"
description "radio animations when using the radio tied to PTT key"
author "Big Daddy"
version "1.3"

ui_page "index.html"

files {
	"index.html",
	"*.ogg",
	"settings.ini"
}

client_scripts {
	"BigDaddy-RadioAnimation.Client.net.dll",
	"Newtonsoft.Json.dll",
	"MenuAPI.dll",
}

server_scripts {
	"BigDaddy-RadioAnimation.Server.net.dll",
}