local Builder = {}
Builder.__index = Builder

function Builder.new(table_name)
    local self = setmetatable({}, Builder)
    self._table = table_name
    self._select = {"*"}
    self._where = {}
    self._limit = nil
    self._order = nil
    self._insert = nil
    self._update = nil
    return self
end

-- SELECT specific columns
function Builder:select(columns)
    if type(columns) == "table" then
        self._select = columns
    elseif type(columns) == "string" then
        self._select = {columns}
    end
    return self
end

-- Add WHERE clause
function Builder:where(column, operator, value)
    if value == nil then
        value = operator
        operator = "="
    end

    table.insert(self._where, {column = column, operator = operator, value = value})
    return self
end

-- Add ORDER BY
function Builder:order_by(column, direction)
    self._order = column .. " " .. (direction or "ASC")
    return self
end

-- Add LIMIT
function Builder:limit(count)
    self._limit = count
    return self
end

-- Build SELECT SQL
function Builder:to_sql()
    local sql = "SELECT " .. table.concat(self._select, ", ") .. " FROM " .. self._table

    if #self._where > 0 then
        local conditions = {}
        for _, w in ipairs(self._where) do
            table.insert(conditions, string.format("%s %s ?", w.column, w.operator))
        end
        sql = sql .. " WHERE " .. table.concat(conditions, " AND ")
    end

    if self._order then
        sql = sql .. " ORDER BY " .. self._order
    end

    if self._limit then
        sql = sql .. " LIMIT " .. tostring(self._limit)
    end

    return sql
end

-- Execute the SELECT query
function Builder:get(driver, cb)
    local sql = self:to_sql()
    local params = {}
    for _, w in ipairs(self._where) do
        table.insert(params, w.value)
    end
    return driver:fetch_all(sql, params, cb)
end

-- Prepare INSERT
function Builder:insert(data)
    self._insert = data
    return self
end

-- Execute INSERT
function Builder:execute_insert(driver, cb)
    if not self._insert then return end

    local columns = {}
    local placeholders = {}
    local values = {}

    for k, v in pairs(self._insert) do
        table.insert(columns, k)
        table.insert(placeholders, "?")
        table.insert(values, v)
    end

    local sql = string.format(
        "INSERT INTO %s (%s) VALUES (%s)",
        self._table,
        table.concat(columns, ", "),
        table.concat(placeholders, ", ")
    )

    driver:execute(sql, values, cb)
end

-- Prepare UPDATE
function Builder:update(data)
    self._update = data
    return self
end

-- Execute UPDATE
function Builder:execute_update(driver, cb)
    if not self._update then return end
    if #self._where == 0 then error("UPDATE without WHERE is dangerous!") end

    local sets = {}
    local values = {}

    for k, v in pairs(self._update) do
        table.insert(sets, string.format("%s = ?", k))
        table.insert(values, v)
    end

    -- Add WHERE values
    for _, w in ipairs(self._where) do
        table.insert(values, w.value)
    end

    local sql = string.format(
        "UPDATE %s SET %s WHERE %s",
        self._table,
        table.concat(sets, ", "),
        table.concat(
            (function()
                local conds = {}
                for _, w in ipairs(self._where) do
                    table.insert(conds, string.format("%s %s ?", w.column, w.operator))
                end
                return conds
            end)(), " AND "
        )
    )

    driver:execute(sql, values, cb)
end

-- Prepare DELETE
function Builder:delete()
    self._delete = true
    return self
end

-- Execute DELETE
function Builder:execute_delete(driver, cb)
    if not self._delete then return end
    if #self._where == 0 then error("DELETE without WHERE is dangerous!") end

    local values = {}
    for _, w in ipairs(self._where) do
        table.insert(values, w.value)
    end

    local conditions = {}
    for _, w in ipairs(self._where) do
        table.insert(conditions, string.format("%s %s ?", w.column, w.operator))
    end

    local sql = string.format(
        "DELETE FROM %s WHERE %s",
        self._table,
        table.concat(conditions, " AND ")
    )

    driver:execute(sql, values, cb)
end