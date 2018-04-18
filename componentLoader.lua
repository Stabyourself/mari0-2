components = {}

toLoad = recursiveEnumerate("components")

for _, path in ipairs(toLoad) do
    if path:sub(-3) == "lua" then
        -- clean up the string
    
        path = path:gsub("/", ".") -- replace / with .
        path = path:sub(1, -5) -- remove .lua
        name = path:sub(12) -- really?
        components[name] = {}

        components[name].code = require(path)
        components[name].name = path

        assert(type(components[name]) == "table", "Component \"" .. path .. "\" didn't return a table.")
    end
end
