local Grammar = {}

function Grammar.escape_identifier(name)
    return "`" .. name:gsub("`", "``") .. "`"
end

function Grammar.quote(value)
    if type(value) == "string" then
        return "'" .. value:gsub("'", "''") .. "'"
    elseif type(value) == "boolean" then
        return value and "1" or "0"
    elseif value == nil then
        return "NULL"
    else
        return tostring(value)
    end
end

function Grammar.set_clause(data)
    local sets = {}
    for k, v in pairs(data) do
        table.insert(sets, string.format("%s = ?", k))
    end
    return table.concat(sets, ", ")
end

function Grammar.insert_clause(data)
    local columns, placeholders = {}, {}
    for k, _ in pairs(data) do
        table.insert(columns, k)
        table.insert(placeholders, "?")
    end
    return table.concat(columns, ", "), table.concat(placeholders, ", ")
end

return Grammar