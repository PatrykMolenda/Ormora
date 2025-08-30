game 'gta5'
fx_version 'cerulean'

name 'Ormora'
description 'Lightweight ORM Library for Lua 5.4 in FiveM'
author 'PatrykMolenda'
repository 'PatrykMolenda/ormora'
version '0.1.0'

lua54 'yes'

server_only 'yes'

server_scripts {
    'config/*.lua',
    'adapters/*.lua',
    'core/query/*.lua',
    'core/model/base.lua',
    'core/util/*.lua',
    'core/driver.lua',
    'core/migration.lua',
    'main.lua'
}