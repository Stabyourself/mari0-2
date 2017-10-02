-- 3DS test thing, written for Mari0 3DS - MIT License.
if love.system.getOS() ~= "Horizon" then
    local currentScreen = "top"
    
    love.graphics.set3D = function() end
    love.graphics.setDepth = function() end
    love.system.getLinearMemory = function() return "?" end

	function love.graphics.setScreen(screen)
		if screen ~= currentScreen then
            currentScreen = screen
            
			if screen == "bottom" then
				love.graphics.translate(BOTTOMSCREENOFFSET, SCREENHEIGHT)
			elseif screen == "top" then
				love.graphics.translate(-BOTTOMSCREENOFFSET, -SCREENHEIGHT)
			end
        end
	end
    
	function love.graphics.getScreen()
		return currentScreen
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