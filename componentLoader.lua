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
        components[name].name = name
        
        assert(type(components[name].code) == "table", string.format("Component \"%s\" didn't return a table.", name))
    end
end
