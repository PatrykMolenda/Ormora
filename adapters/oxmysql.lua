local oxmysql = {}

oxmysql.execute = function(sql, params, cb)
    if cb then
        exports.oxmysql.rawExecute(sql, params, cb)
    else
        return exports.oxmysql.rawExecute_async(sql, params)
    end
end

oxmysql.fetch_all = function(sql, params, cb)
    if cb then
        exports.oxmysql.query(sql, params, cb)
    else
        return exports.oxmysql.query_async(sql, params)
    end
end

oxmysql.scalar = function(sql, params, cb)
    if cb then
        exports.oxmysql.scalar(sql, params, cb)
    else
        return exports.oxmysql.scalar_async(sql, params)
    end
end