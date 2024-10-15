fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

author 'Project Sloth & OK1ez'
version '2.0.2'
description 'Admin Menu'
repository 'https://github.com/KentaNo1/ps-adminmenu'

ui_page 'html/index.html'

files {
  'html/**',
  'data/ped.lua',
  'data/object.lua',
}

shared_scripts {
  '@es_extended/locale.lua',
  'locales/*.lua',
  '@es_extended/imports.lua',
  '@ox_lib/init.lua',
  'shared/*.lua',
}

client_scripts {
  'client/*.lua'
}

server_scripts {
  'server/*.lua',
  '@oxmysql/lib/MySQL.lua',
}

dependencies {
  'es_extended',
  'oxmysql',
  'ox_lib',
}
