local Model = require('core.model.base')

local User = setmetatable({}, Model)
User.__index = User

User._table = "users"

User._schema {
    id = {
        type = "INT",
        primary = true,
        auto_increment = true
    },
    first_name = {
        type = "VARCHAR(50)",
        null = false
    },
    last_name = {
        type = "VARCHAR(50)",
        null = false
    },
    age = {
        type = "INT",
        null = false,
        default = 0
    },
    created_at = {
        type = "TIMESTAMP",
        default = "CURRENT_TIMESTAMP"
    }
}

function User:full_name(user)
    return (user.first_name or "") .. " " .. (user.last_name or "")
end

local Post = require('examples.model.post')

-- User has many posts
User:hasMany(Post, 'user_id', 'id')

return User