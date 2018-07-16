function love.run()
	love.load(love.arg.parseGameArguments(arg), arg)

	-- We don't want the first frame's dt to include time taken by love.load.
	love.timer.step()

	local dt

	-- Main loop time.
	return function()
		prof.push("frame")
		-- Process events.
		love.event.pump()
		for name, a,b,c,d,e,f in love.event.poll() do
			if name == "quit" then
				prof.pop("frame")
				if not love.quit() then
					return a or 0
				end
			end
			love.handlers[name](a,b,c,d,e,f)
		end

		-- Update dt, as we'll be passing it to update
		dt = love.timer.step()

		-- Call update and draw
		love.update(dt)

		love.graphics.origin()
		love.graphics.clear(love.graphics.getBackgroundColor())

		love.draw()
		prof.pop("frame")

		love.graphics.present()

		love.timer.sleep(0.001)
	end
end
