local Builder = require('core.query.builder.lua')

local Model = {}
Model.__index = Model
Model._driver = nil
Model._table = nil
Model._relations = {}

local function Entity(model, data)
    local self = {}
    self._model = model
    self._data = data or {}

    -- Relationship access
    function self:relation(name, cb)
        local rel = model._relations[name]
        if not rel then return nil end
        local rel_type = rel.type
        local rel_model = rel.model
        local foreign_key = rel.foreign_key
        local local_key = rel.local_key
        if rel_type == 'hasMany' then
            local query = rel_model:query():where(foreign_key, self._data[local_key])
            if cb then
                query:get(rel_model._driver, cb)
            else
                return query:get(rel_model._driver)
            end
        elseif rel_type == 'hasOne' then
            local query = rel_model:query():where(foreign_key, self._data[local_key])
            if cb then
                query:get(rel_model._driver, function(results)
                    cb(results[1] or nil)
                end)
            else
                local results = query:get(rel_model._driver)
                return results[1] or nil
            end
        elseif rel_type == 'belongsTo' then
            local query = rel_model:query():where(local_key, self._data[foreign_key])
            if cb then
                query:get(rel_model._driver, function(results)
                    cb(results[1] or nil)
                end)
            else
                local results = query:get(rel_model._driver)
                return results[1] or nil
            end
        end
    end

    setmetatable(self, {
        __index = function(_, key)
            -- access columns or model methods
            if self._data[key] ~= nil then return self._data[key] end
            if model[key] then return model[key] end
                if model._relations and model._relations[key] then
                    return function(_, cb)
                        return self:relation(key, cb)
                    end
                end
        end,
        __newindex = function(_, key, value)
            self._data[key] = value
        end
    })

    -- Save changes to DB
    function self:save(cb)
        local builder = model:query()
        builder:where("id", self._data.id):update(self._data):execute_update(model._driver, cb)
    end

    -- Delete this entity
    function self:delete(cb)
        local builder = model:query()
        builder:where("id", self._data.id):delete():execute_delete(model._driver, cb)
    end

    return self
end

function Model:use_driver(driver)
    self._driver = driver
    return self
end

function Model:query()
    return Builder.new(self._table)
end

function Model:all(cb)
    if cb then
        self:query():get(self._driver, function(results)
            local entities = {}
            for _, row in ipairs(results) do
                table.insert(entities, Entity(self, row))
            end
            cb(entities)
        end)
    else
        local results = self:query():get(self._driver)
        local entities = {}
        for _, row in ipairs(results) do
            table.insert(entities, Entity(self, row))
        end
        return entities
    end
end

function Model:find(id, cb)
    if cb then
        self:query():where("id", id):get(self._driver, function(results)
            if #results > 0 then
                cb(Entity(self, results[1]))
            else
                cb(nil)
            end
        end)
    else
        local results = self:query():where("id", id):get(self._driver)
        if #results > 0 then
            return Entity(self, results[1])
        else
            return nil
        end
    end
end

function Model:create(data, cb)
    if cb then
        self:query():insert(data):execute_insert(self._driver, function()
            self:query():where("id", self._driver.adapter.last_insert_id):get(self._driver, function(results)
                if #results > 0 then
                    cb(Entity(self, results[1]))
                else
                    cb(nil)
                end
            end)
        end)
    else
        self:query():insert(data):execute_insert(self._driver)
        local results = self:query():where("id", self._driver.adapter.last_insert_id):get(self._driver)
        if #results > 0 then
            return Entity(self, results[1])
        else
            return nil
        end
    end
end

function Model:update(data, cb)
    if cb then
        self:query():where("id", self._data.id):update(data):execute_update(self._driver, function()
            self:query():where("id", self._data.id):get(self._driver, function(results)
                if #results > 0 then
                    cb(Entity(self, results[1]))
                else
                    cb(nil)
                end
            end)
        end)
    else
        self:query():where("id", self._data.id):update(data):execute_update(self._driver)
        local results = self:query():where("id", self._data.id):get(self._driver)
        if #results > 0 then
            return Entity(self, results[1])
        else
            return nil
        end
    end
end

function Model:delete(cb)
    if cb then
        self:query():where("id", self._data.id):delete():execute_delete(self._driver, function()
            cb(true)
        end)
    else
        self:query():where("id", self._data.id):delete():execute_delete(self._driver)
        return true
    end
end

-- Relationship definition methods
function Model:hasMany(rel_model, foreign_key, local_key)
    self._relations = self._relations or {}
    self._relations[rel_model._table] = {
        type = 'hasMany',
        model = rel_model,
        foreign_key = foreign_key,
        local_key = local_key or 'id'
    }
end

function Model:hasOne(rel_model, foreign_key, local_key)
    self._relations = self._relations or {}
    self._relations[rel_model._table] = {
        type = 'hasOne',
        model = rel_model,
        foreign_key = foreign_key,
        local_key = local_key or 'id'
    }
end

function Model:belongsTo(rel_model, foreign_key, owner_key)
    self._relations = self._relations or {}
    self._relations[rel_model._table] = {
        type = 'belongsTo',
        model = rel_model,
        foreign_key = foreign_key,
        local_key = owner_key or 'id'
    }
end

return Model