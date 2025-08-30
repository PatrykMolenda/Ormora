local GitHub = {}
GitHub.__index = GitHub

function GitHub:new()
    local instance = setmetatable({}, GitHub)
    instance.repo = LoadResourceFile(GetCurrentResourceName(), 'repository') or 'unknown/repo'
    return instance
end

function GitHub:get_repository()
    return self.repo
end

function GitHub:get_latest_release(callback)
    local url = string.format("https://api.github.com/repos/%s/releases/latest", self.repo)
    PerformHttpRequest(url, function(statusCode, responseBody, headers)
        if statusCode == 200 then
            local data = json.decode(responseBody)
            if data and data.tag_name then
                callback(true, data.tag_name)
            else
                callback(false, "Invalid response structure")
            end
        else
            callback(false, "HTTP Error: " .. tostring(statusCode))
        end
    end, 'GET', '', { ['Content-Type'] = 'application/json' })
end

function GitHub:getCurrentVersion()
    local versionFile = LoadResourceFile(GetCurrentResourceName(), 'version')
    if versionFile then
        return versionFile:match("^%s*(.-)%s*$") -- Trim whitespace
    else
        return nil, "Version file not found"
    end
end

return GitHub