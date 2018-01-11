Mario = class("Mario", fissix.PhysObj)

function Mario:initialize(world, x, y, powerUpState)
    self.powerUpState = powerUpState or "small"
    
    local width = 12
    local height = 12
    if self.powerUpState ~= "small" then
        height = 24
    end
    
    fissix.PhysObj.initialize(self, world, x-width/2, y-height, width, height)
    
    self.jumping = false
    self.ducking = false
    self.portals = {}

    self.animationState = "idle"
    
    self.animationDirection = 1
    
    self.pMeter = 0
    self.pMeterTimer = 0
    self.pMeterTime = 8/60
    
    self.hasPortalGun = true--true
    self.portalGunAngle = 0
    
    self.portalColor = {
        Color.fromHSV(200/360, 0.76, 0.99),
        Color.fromHSV(30/360, 0.87, 0.91),
        Color.fromHSV(30/360, 0.87, 0.91),
    }
    
    self.crosshair = DottedCrosshair:new(self)
end

function Mario:update(dt)
    self:movement(dt)
    
    if CHEAT("tumble") then
        self.angle = self.angle + self.groundSpeedX*dt*0.1
        self:unRotate(0)
    else
        self:unRotate(dt)
    end
end

function Mario:postMovementUpdate(dt)
    self:animation(dt)
    
    local x, y = self.x+self.width/2, self.y+self.height/2+2
    self.crosshair.origin = {
        x = x,
        y = y,
    }
    
    local mx, my = self.world:mousePosition(0, 0, CAMERAWIDTH, CAMERAHEIGHT)
    
    self.crosshair.angle = math.atan2(my-y, mx-x)
    
    self.portalGunAngle = self.crosshair.angle
    
    self.crosshair:update(dt)
end

function Mario:closePortals()
    for i = 1, 2 do
        if self.portals[i] then
            self.portals[i].deleteMe = true
            self.portals[i] = nil
        end
    end
end

function Mario:jump()
    if self.onGround then
        self.onGround = false
        self.jumping = true

        self.gravity = VAR("gravityjumping")
        
        playSound(jumpSound)
        
        return true
    end
end

function Mario:getAngleFrame(angle)
    if not self.hasPortalGun then
        return 5
    end
    
    if angle > math.pi*.5 then
        angle = math.pi - angle
    elseif angle < -math.pi*.5 then
        angle = -math.pi - angle
    end
    
	if angle < -math.pi*0.375 then
		return 1
	elseif angle < -math.pi*0.125 then
		return 2
	elseif angle < math.pi*0.125  then
		return 3
	elseif angle < math.pi*0.375 then
		return 4
	else -- Downward frame looks dumb
		return 4
    end
end

function Mario:ceilCollision(obj2)
    if obj2:isInstanceOf(Block) then
        -- See whether it was very close to the edge of a block next to air, in which case allow Mario to keep jumping
        -- Right side
        if self.x > obj2.x+obj2.width - VAR("jumpLeeway") and not game.level:getTile(obj2.blockX+1, obj2.blockY).collision then
            self.x = obj2.x+obj2.width
            self.speed[1] = math.max(self.speed[1], 0)

            return true
        end
        
        -- Left side
        if self.x + self.width < obj2.x + VAR("jumpLeeway") and not game.level:getTile(obj2.blockX-1, obj2.blockY).collision then
            self.x = obj2.x-self.width
            self.speed[1] = math.min(self.speed[1], 0)

            return true
        end

        -- See if there's a better matching block (because Mario jumped near the edge of a block)
        local toCheck = 0
        local x, y = obj2.blockX, obj2.blockY

        if self.x+self.width/2 > obj2.x+obj2.width then
            toCheck = 1
        elseif self.x+self.width/2 < obj2.x then
            toCheck = -1
        end

        if toCheck ~= 0 then
            if game.level:getTile(x+toCheck, y).collision then
                x = x + toCheck
            end
        end
        
        self.speed[2] = VAR("blockHitForce")
        
        game.level:bumpBlock(x, y)
    end
end

function Mario:bottomCollision(obj2)
    if obj2.stompable then
        obj2:stomp()
        self.speed[2] = -getRequiredSpeed(VAR("enemyBounceHeight"))
        playSound(stompSound)
        
        return true
    end
end

function Mario:leftCollision(obj2)
    
end

function Mario:rightCollision(obj2)
    
end

function Mario:spin() end