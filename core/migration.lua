local Grammar = require 'core.query.grammar'

local Migration = {}

function Migration.create_table_sql(model)
    local parts = {}
    local primary_keys = {}

    for col, def in pairs(model._schema) do
        local part = Grammar.escape_identifier(col) .. " " .. def.type

        if def.null == false then
            part = part .. " NOT NULL"
        end

        if def.auto_increment then
            part = part .. " AUTO_INCREMENT"
        end

        if def.default then
            part = part .. " DEFAULT " .. def.default
        end

        table.insert(parts, part)

        if(def.primary) then
            table.insert(primary_keys, col)
        end
    end

    if #primary_keys >  0 then
        table.insert(parts, "PRIMARY KEY (" .. table.concat(primary_keys, ", ") .. ")")
    end

    local sql = string.format("CREATE TABLE IF NOT EXISTS %s (%s)",
        Grammar.escape_identifier(model._table),
        table.concat(parts, ", ")
    )

    return sql
end

function Migration.migrate(driver, models, cb)
    if type(models) == "table" then
        for _, model in ipairs(models) do
            local sql = Migration.create_table_sql(model)
            driver:execute(sql, {}, function()
                print("^1[Ormora]^7 Migration: Created table " .. model._table)
            end)
        end
        if cb then cb() end
        return
    end
    local sql = Migration.create_table_sql(models)
    driver:execute(sql, {}, cb)
    print("^1[Ormora]^7 Migration: Created table " .. models._table)
end

return Migration