local Driver = {}
Driver.__index = Driver

function Driver:new(adapter)
    return setmetatable({ adapter = adapter }, self)
end

function Driver:execute(sql, params, cb)
    return self.adapter:execute(sql, params or {}, cb)
end

function Driver:fetch_all(sql, params, cb)
    return self.adapter:fetch_all(sql, params or {}, cb)
end

function Driver:scalar(sql, params, cb)
    return self.adapter:scalar(sql, params or {}, cb)
end

return Driver