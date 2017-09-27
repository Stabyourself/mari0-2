function love.load()
    JSON = require "lib/JSON"
    class = require "lib/Class"
    Camera = require "lib/camera"

    require "variables"

    require "class/physics/World"
    require "class/physics/PhysObj"

    require "class/TileMap"
    require "class/Tile"
    require "class/Level"
    require "class/Mario"
    require "class/Block"

    require "game"

    game.load()
end

function love.update(dt)
    if gameState == "game" then
        game.update(dt)
    end
end

function love.draw()
    if gameState == "game" then
        game.draw()
    end
end