fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'
lua54 'yes'

author 'Ssomemore'
description 'sm-boats'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'locale.lua',
    'languages/*.lua',
    '@jo_libs/init.lua'   
}

jo_libs {
    'menu',
    'prompt',
    'notification'
}

ui_page "nui://jo_libs/nui/index.html"

client_scripts {
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}



dependencies {
    'rsg-core',
    'jo_libs',
    'oxmysql'
}
