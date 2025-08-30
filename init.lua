local Driver = require('core.driver')
local adapter = require('adapters.oxmysql')

local driver = Driver:new(adapter)

driver:fetch_all("SELECT 1 AS test", {}, function(result)
    print("Database connected, test query result:", result[1].test)
end)

return {
    Driver = Driver
}