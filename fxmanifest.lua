fx_version 'cerulean'
game 'gta5'

author 'Pratheek'
description 'SSRP Parking Meter Robbery'
version '1.0.0'

shared_scripts { 'config.lua' }

client_scripts { 'client/main.lua' }
server_scripts { 'server/main.lua' }

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

dependencies {
    'qb-core'
}