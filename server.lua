require = lib.require

local DbConfig = require 'config.database'
local GitHub = require 'core.util.github':new()
local fs = require 'core.util.fs':new()

local dbDriver = DbConfig.adapter or 'oxmysql'

AddEventHandler('onResourceStart', function (resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end


    print('^2[Ormora]^7 Initializing...')

    local startTime
    if DbConfig.debug then
        startTime = os.clock()
        print('^3[Ormora]^7 Debug mode is enabled')
    end

    -- Checks for updates
    lib.versionCheck("PatrykMolenda/Ormora")

    -- Checks adapter exists
    if not fs:file_exists(string.format('adapters/%s.lua', dbDriver)) then
        error(string.format('^1[Ormora]^7 Database adapter not found: ^3%s^7', dbDriver))
        return
    end

    print(string.format('^2[Ormora]^7 Using database adapter: ^3%s^7', dbDriver))
    if DbConfig.debug then
        print(string.format('^3[Ormora]^7 Initialization completed in ^2%.4f^7 seconds', os.clock() - startTime))
    else
        print('^2[Ormora]^7 Initialization completed.')
    end
end)