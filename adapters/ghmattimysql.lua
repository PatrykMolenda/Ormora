local ghmatti = {}

ghmatti.execute = function(sql, params, cb)
    exports.ghmattimysql:execute(sql, params or {}, cb)
end

ghmatti.fetch_all = function(sql, params, cb)
    exports.ghmattimysql:execute(sql, params or {}, cb) -- ghmatti uses execute for both
end

ghmatti.scalar = function(sql, params, cb)
    exports.ghmattimysql:scalar(sql, params or {}, cb)
end

return ghmatti