Test = {}
Test.__index = Test
local Model = require('core.model.base')
local Driver = Core.resolveDriver()
local Migration = require('core.migration')

function Test:register_model()
    local TestModel = setmetatable({}, Model)
    TestModel.__index = TestModel

    TestModel._table = "test_table"

    TestModel._schema {
        id = {
            type = "INT",
            primary = true,
            auto_increment = true
        },
        name = {
            type = "VARCHAR(100)",
            null = false
        },
        created_at = {
            type = "TIMESTAMP",
            default = "CURRENT_TIMESTAMP"
        }
    }

    return TestModel
end

function Test:create_migraiton()
    -- Register a Model
    local TestModel = self:register_model()

    Migration.migrate(Driver, TestModel)

    local tableExists = Driver.execute("TestModel", "SHOW TABLES LIKE 'test_table'", {})

    if #tableExists == 0 then
        return false
    end

    return TestModel
end

function Test:run()
    local tests = {
        false
    }

    local TestModel = self:create_migraiton()
    if not TestModel then
        return tests
    end
    tests[1] = true
    
    return tests
end

return Test