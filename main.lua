-- Stubs for testing
love.graphics.set3D = love.graphics.set3D or function() end
love.graphics.setDepth = love.graphics.setDepth or function() end

is3DS = love.system.getOS() == "Horizon"

function love.load()
    JSON = require "lib/JSON"
    class = require "lib/Class"
    Camera = require "lib/camera"

    require "variables"
    require "environment"

    require "class/physics/World"
    require "class/physics/PhysObj"

    require "class/TileMap"
    require "class/Tile"
    require "class/Level"
    require "class/Mario"
    require "class/Block"

    require "game"
    
    love.graphics.set3D(true)

    game.load()
end

function love.update(dt)
    dt = math.min(1/10, dt)

    if skipNext then
        skipNext = false
        return
    end

	if FFKEYS then
		for _, v in ipairs(FFKEYS) do
			if love.keyboard.isDown(v.key) then
				dt = dt * v.val
			end
		end
	end
    
    if gameState == "game" then
        game.update(dt)
    end
end

function love.draw()
    if gameState == "game" then
        game.draw()
    end
end

function love.keypressed(key)
    if key == CONTROLS.quit then
        love.event.quit()
    end
    
    if gameState == "game" then
        game.keypressed(key)
    end
end

function updateGroup(group, dt)
	local delete = {}
	
	for i, v in ipairs(group) do
		if v:update(dt) or v.deleteMe then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for _, v in ipairs(delete) do
		table.remove(group, v) --remove
	end
end

function keyDown(cmd)
    return love.keyboard.isDown(CONTROLS[cmd])
end

function skipUpdate()
    skipNext = true
end