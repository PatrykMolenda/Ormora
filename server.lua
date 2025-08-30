require = function(name)
    if type(name) ~= 'string' then
        error(("module name must be a string (received '%s')"):format(name), 3)
    end

    local module = loaded[name]

    if module == '__loading' then
        error(("^1circular-dependency occurred when loading module '%s'^0"):format(modName), 2)
    end

    if module ~= nil then return module end

    loaded[modName] = '__loading'

    local err = {}

    for i = 1, #package.searchers do
        local result, errMsg = package.searchers[i](modName)

        if result then
            if type(result) == 'function' then result = result() end
            loaded[modName] = result or result == nil

            return loaded[modName]
        end

        err[#err + 1] = errMsg
    end

    error(("%s"):format(table.concat(err, "\n\t")))
end

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
    GitHub:get_latest_release(function(success, version)
        if success then
            local currentVersion, err = GitHub:getCurrentVersion()
            if not currentVersion then
                print('^1[Ormora]^7 Error reading current version: ' .. err)
                return
            end

            if currentVersion ~= version then
                print(string.format('^3[Ormora]^7 New version available: ^2%s^7 (current: ^1%s^7)', version, currentVersion))
                print(string.format('^3[Ormora]^7 Please update at: ^2https://github.com/%s', GitHub:get_repository()))
            else
                print('^2[Ormora]^7 You are using the latest version: ^3' .. currentVersion)
            end
        else
            print('^1[Ormora]^7 Failed to check for updates: ' .. version)
        end
    end)

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