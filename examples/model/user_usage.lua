local Driver = require("core.driver")
local adapter = require("adapters.oxmysql")
local driver = Driver:new(adapter)

local UserModel = require("models.user")
UserModel:use_driver(driver)

local Migration = require("core.migration")
local UserModel = require("examples.model.user")
local PostModel = require("examples.model.post")

UserModel:use_driver(driver)
PostModel:use_driver(driver)

-- Create User
local user = UserModel:create({
    first_name = "John",
    last_name = "Doe",
    age = 25
})

-- Modify user
user.last_name = "Smith"

-- Save User
user:save()

-- Delete User
user:delete()