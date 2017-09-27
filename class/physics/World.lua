World = class("World")

function World:initialize()
	self.objects = {}
	self.collisionObjects = {}
	
	self.blockLookup = {}
end

function World:addObject(obj)
	table.insert(self.objects, obj)
	
	if obj.block then -- add to lookup table
		if not self.blockLookup[obj.blockX] then
			self.blockLookup[obj.blockX] = {}
		end
		
		self.blockLookup[obj.blockX][obj.blockY] = obj
	else -- add to generic collision check table
		table.insert(self.collisionObjects, obj)
	end
end

function World:draw()
	for _, obj in ipairs(self.objects) do
		self:drawObject(obj)
	end
end

function World:drawObject(obj)
	love.graphics.rectangle("fill", obj.x*TILESIZE+.5, obj.y*TILESIZE+.5, obj.width*TILESIZE, obj.height*TILESIZE)
end

function World:update(dt)
	for _, obj1 in ipairs(self.objects) do
		if obj1.static == false and obj1.active then
			obj1.prevSpeedY = obj1.speedY
			obj1.prevSpeedX = obj1.speedX
			
			--GRAVITY
			obj1.speedY = obj1.speedY + (obj1.gravity or GRAVITY)*dt*0.5
			
			if obj1.speedY > MAXYSPEED then
				obj1.speedY = MAXYSPEED
			end
			
			--COLLISIONS ROFL
			local horcollision = false
			local vercollision = false
			
			--VS OTHER OBJECTS --but not: portalwall, castlefirefire
			for _, obj2 in ipairs(self.collisionObjects) do
				if obj1 ~= obj2 and obj2.active then
					local hor, ver = checkcollision(obj1, obj2, dt)

					if hor then
						horcollision = true
					end
					if ver then
						vercollision = true
					end
				end
			end
			
			
			--VS TILES (Because I only wanna check close ones)
			local xstart = math.floor(obj1.x+obj1.prevSpeedX*dt-2/16)
			local ystart = math.floor(obj1.y+obj1.prevSpeedY*dt-2/16)
			
			local xto = xstart+math.ceil(obj1.width)
			local dir = 1
			
			if obj1.speedX < 0 then
				xstart, xto = xto, xstart
				dir = -1
			end
			
			for x = xstart, xto, dir do
				for y = ystart, ystart+math.ceil(obj1.height) do
					--check if invisible block
					local obj2 = self.blockLookup[x] and self.blockLookup[x][y]
					if obj2 and obj2.active then
						local collision1, collision2 = checkcollision(obj1, obj2, dt)
						if collision1 then
							horcollision = true
						elseif collision2 then
							vercollision = true
						end
					end
				end
			end
			--]]
			
			--Move the object
			if vercollision == false then
				obj1.y = obj1.y + obj1.speedY*dt
				
				if obj1.onGround then
					obj1.onGround = false
					if obj1.speedY >= 0 then
						obj1:startFall()
					end
				end
			else
				obj1.onGround = true
			end
			
			if horcollision == false then
				obj1.x = obj1.x + obj1.speedX*dt
			end
			
			--GRAVITY
			obj1.speedY = obj1.speedY + (obj1.gravity or GRAVITY)*dt*0.5
		end
	end
end

function checkcollision(obj1, obj2, dt)
	local hadhorcollision = false
	local hadvercollision = false
	
	if math.abs(obj1.x+obj1.speedX*dt-obj2.x) < math.max(obj1.width, obj2.width)+1 and math.abs(obj1.y+obj1.speedY*dt-obj2.y) < math.max(obj1.height, obj2.height)+1 then
		--check if it's a passive collision (Object is colliding anyway)
		if aabb(obj1.x, obj1.y, obj1.width, obj1.height, obj2.x, obj2.y, obj2.width, obj2.height) then --passive collision! (oh noes!)
			if passivecollision(obj1, obj2) then
				hadvercollision = true
			end
			
		elseif aabb(obj1.x + obj1.speedX*dt, obj1.y + obj1.speedY*dt, obj1.width, obj1.height, obj2.x, obj2.y, obj2.width, obj2.height) then
			if aabb(obj1.x + obj1.speedX*dt, obj1.y, obj1.width, obj1.height, obj2.x, obj2.y, obj2.width, obj2.height) then --Collision is horizontal!
				if horcollision(obj1, obj2) then
					hadhorcollision = true
				end
				
			elseif aabb(obj1.x, obj1.y+obj1.speedY*dt, obj1.width, obj1.height, obj2.x, obj2.y, obj2.width, obj2.height) then --Collision is vertical!
				if vercollision(obj1, obj2) then
					hadvercollision = true
				end
				
			else 
				--We're fucked, it's a diagonal collision! run!
				--Okay actually let's take this slow okay. Let's just see if we're moving faster horizontally than vertically, aight?
				local grav = GRAVITY
				if self and self.gravity then
					grav = self.gravity
				end
				if math.abs(obj1.speedY-grav*dt) < math.abs(obj1.speedX) then
					--vertical collision it is.
					if vercollision(obj1, obj2) then
						hadvercollision = true
					end
				else 
					--okay so we're moving mainly vertically, so let's just pretend it was a horizontal collision? aight cool.
					if horcollision(obj1, obj2) then
						hadhorcollision = true
					end
				end
			end
		end
	end
	
	return hadhorcollision, hadvercollision
end

function passivecollision(obj1, obj2)
	obj1:passiveCollide(obj2)
	obj2:passiveCollide(obj1)
	
	return false
end

function horcollision(obj1, obj2)
	if obj1.speedX < 0 then
		--move object RIGHT (because it was moving left)
		if obj2:rightCollide(obj1) ~= false then
			if obj2.speedX and obj2.speedX > 0 then
				obj2.speedX = 0
			end
		end

		if obj1:leftCollide(obj2) ~= false then
			if obj1.speedX < 0 then
				obj1.speedX = 0
			end
			obj1.x = obj2.x + obj2.width
			return true
		end
	else
		--move object LEFT (because it was moving right)
		if obj2:leftCollide(obj1) ~= false then
			if obj2.speedX and obj2.speedX < 0 then
				obj2.speedX = 0
			end
		end
		
		if obj1:rightCollide(obj2) ~= false then
			if obj1.speedX > 0 then
				obj1.speedX = 0
			end
			obj1.x = obj2.x - obj1.width
			return true
		end
	end
	
	return false
end

function vercollision(obj1, obj2)
	if obj1.speedY < 0 then
		--move object DOWN (because it was moving up)
		if obj2:floorCollide(obj1) ~= false then
			if obj2.speedY and obj2.speedY > 0 then
				obj2.speedY = 0
			end
		end
		
		if obj1:ceilCollide(obj2) ~= false then
			if obj1.speedY < 0 then
				obj1.speedY = 0
			end
			obj1.y = obj2.y  + obj2.height
			return true
		end
	else					
		if obj2:ceilCollide(obj1) ~= false then
			if obj2.speedY and obj2.speedY < 0 then
				obj2.speedY = 0
			end
		end

		if obj1:floorCollide(obj2) ~= false then
			if obj1.speedY > 0 then
				obj1.speedY = 0
			end
			obj1.y = obj2.y - obj1.height
			return true
		end
	end
	return false
end

function aabb(ax, ay, awidth, aheight, bx, by, bwidth, bheight)
	return ax+awidth > bx and ax < bx+bwidth and ay+aheight > by and ay < by+bheight
end
