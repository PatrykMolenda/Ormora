# Ormora

Lightweight ORM Library for Lua 5.4 in FiveM

## Features

- Simple model definition
- Query builder for flexible SQL
- Relationships: `hasMany`, `belongsTo`, `hasOne`
- Migration support
- Multiple database adapters (oxmysql, ghmattimysql)

## Usage

### Defining Models

```lua
-- user.lua
local Model = require('core.model.base')
local User = setmetatable({}, Model)
User.__index = User
User._table = "users"
User._schema {
    id = { type = "INT", primary = true, auto_increment = true },
    first_name = { type = "VARCHAR(50)", null = false },
    last_name = { type = "VARCHAR(50)", null = false },
    age = { type = "INT", null = false, default = 0 },
    created_at = { type = "TIMESTAMP", default = "CURRENT_TIMESTAMP" }
}
return User
```

### Relationships

```lua
-- post.lua
local Model = require('core.model.base')
local Post = setmetatable({}, Model)
Post.__index = Post
Post._table = "posts"
Post._schema {
    id = { type = "INT", primary = true, auto_increment = true },
    user_id = { type = "INT", null = false },
    title = { type = "VARCHAR(100)", null = false },
    body = { type = "TEXT", null = false },
    created_at = { type = "TIMESTAMP", default = "CURRENT_TIMESTAMP" }
}
local User = require('examples.model.user')
Post:belongsTo(User, 'user_id', 'id')
return Post

-- user.lua (add relationship)
local Post = require('examples.model.post')
User:hasMany(Post, 'user_id', 'id')
```

### Example Usage

```lua
local UserModel = require('examples.model.user')
local PostModel = require('examples.model.post')
UserModel:use_driver(driver)
PostModel:use_driver(driver)

-- Create user
local user = UserModel:create({ first_name = "John", last_name = "Doe", age = 25 })

-- Create post for user
local post = PostModel:create({ user_id = user.id, title = "Hello World", body = "This is my first post!" })

-- Fetch user's posts
local posts = user:posts()

-- Fetch post's user
local post_user = post:user()
```

## Adapters

- oxmysql
- ghmattimysql

## License

MIT License

Copyright (c) 2025 PatrykMolenda

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.