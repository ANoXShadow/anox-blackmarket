fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'anox-blackmarket'
author 'ANoXStudio'
description 'Black Market script compatible with ESX, QBCore, and QBox'
version '1.0.1'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

files {
    'locales/*.json'
}

dependencies {
    'ox_lib',
    'oxmysql'
}
