fx_version 'cerulean'
games { 'gta5' }

author "Swkeep#7049"

shared_scripts {
     '@qb-core/shared/locale.lua',
     'locale/en.lua',
     'config.lua',
     'shared/shared_main.lua'
}

client_scripts {
     '@PolyZone/client.lua',
     '@PolyZone/BoxZone.lua',
     'client/mailer.lua',
     'client/client_main.lua',
     'client/client_lib/menu.lua'
}

server_scripts {
     'server/lib.lua',
     'server/blueprints.lua',
     'server/server_main.lua',
     'server/server_lib/server_lib_entry.lua'
}

-- dependency 'oxmysql'

lua54 'yes'
