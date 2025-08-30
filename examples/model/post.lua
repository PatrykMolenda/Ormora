local Model = require('core.model.base')

local Post = setmetatable({}, Model)
Post.__index = Post

Post._table = "posts"

Post._schema {
    id = {
        type = "INT",
        primary = true,
        auto_increment = true
    },
    user_id = {
        type = "INT",
        null = false
    },
    title = {
        type = "VARCHAR(100)",
        null = false
    },
    body = {
        type = "TEXT",
        null = false
    },
    created_at = {
        type = "TIMESTAMP",
        default = "CURRENT_TIMESTAMP"
    }
}

local User = require('examples.model.user')

-- Post belongs to user
Post:belongsTo(User, 'user_id', 'id')

return Post
