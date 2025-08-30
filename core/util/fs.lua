local fs = {}
fs.__index = fs

function fs:new()
    local instance = setmetatable({}, fs)
    return instance
end

function fs:read_file(file_path)
    local file = io.open(file_path, "r")
    if not file then
        return nil, "Could not open file: " .. file_path
    end
    local content = file:read("*a")
    file:close()
    return content
end

function fs:write_file(file_path, content)
    local file = io.open(file_path, "w")
    if not file then
        return false, "Could not open file for writing: " .. file_path
    end
    file:write(content)
    file:close()
    return true
end

function fs:file_exists(file_path)
    local file = io.open(file_path, "r")
    if file then
        file:close()
        return true
    else
        return false
    end
end


return fs