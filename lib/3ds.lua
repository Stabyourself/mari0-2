newFrame3ds = function() end

if love.system.getOS() ~= "Horizon" then
    local currentScreen = "top"
    
    love.graphics.set3D = function() end
    love.graphics.setDepth = function() end
    love.system.getLinearMemory = function() return "?" end

    function newFrame3ds()
        currentScreen = "top"
    end
    
	function love.graphics.setScreen(screen)
		if screen ~= currentScreen then
            currentScreen = screen
            
            if screen == "bottom" then
                love.graphics.translate(BOTTOMSCREENOFFSET*SCALE, SCREENHEIGHT*SCALE)
            elseif screen == "top" then
                love.graphics.translate(-BOTTOMSCREENOFFSET*SCALE, -SCREENHEIGHT*SCALE)
            else
                print("wat")
            end
        end
	end
    
	function love.graphics.getScreen()
		return currentScreen
	end

	-- Clamps a number to within a certain range.
	function math.clamp(n, low, high) 
		return math.min(math.max(low, n), high) 
	end

	local oldMousePressed = love.mousepressed
	function love.mousepressed(x, y, button)
		if oldMousePressed then
		    x, y = math.clamp(x, 0, 320), math.clamp(y - 240, 0, 240)

			oldMousePressed(x, y, 1)
		end
	end

	local oldMouseReleased = love.mousereleased
	function love.mousereleased(x, y, button)
		if oldMouseReleased then
		    x, y = math.clamp(x - 40, 0, 320), math.clamp(y - 240, 0, 240)

			oldMouseReleased(x, y, 1)
		end
	end
end