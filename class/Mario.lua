Mario = class("Mario", fissix.PhysObj)

function Mario:initialize(world, x, y, powerUpState)
    self.powerUpState = powerUpState or "small"
    
    local height = 12
    if self.powerUpState ~= "small" then
        height = 24
    end
    
    fissix.PhysObj.initialize(self, world, x, y, 12, height)
    
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
        {60, 188, 252},
		{232, 130, 30}
    }
end

function Mario:update(dt)
    self:movement(dt)
    self:animation(dt)
    
    self:updateCrosshair()
    
    if CHEAT("tumble") then
        self.r = self.r + self.groundSpeedX*dt*0.1
        self:unRotate(0)
    else
        self:unRotate(dt)
    end
end

function Mario:updateCrosshair()
    local cx, cy = self.x+self.width/2, self.y+self.height/2+2
    local mx, my = (love.mouse.getX())/VAR("scale")+game.level.camera.x, love.mouse.getY()/VAR("scale")+game.level.camera.y
    self.portalGunAngle = math.atan2(my-cy, mx-cx)

    local x, y, absX, absY, side = game.level:rayCast(cx/game.level.tileSize, cy/game.level.tileSize, self.portalGunAngle)

    absX, absY = game.level:mapToWorld(absX, absY)
    
    -- CHANGE THIS
    self.crosshairX = absX
    self.crosshairY = absY
    self.crosshairTileX = x
    self.crosshairTileY = y
    self.crosshairSide = side
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
            self.speedX = math.max(self.speedX, 0)

            return true
        end
        
        -- Left side
        if self.x + self.width < obj2.x + VAR("jumpLeeway") and not game.level:getTile(obj2.blockX-1, obj2.blockY).collision then
            self.x = obj2.x-self.width
            self.speedX = math.min(self.speedX, 0)

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
                obj2 = game.level.blocks[x][y]
            end
        end
        
        self.speedY = VAR("blockHitForce")
        
        game.level:bumpBlock(x, y)
    end
end

function Mario:bottomCollision(obj2)
    if obj2.stompable then
        obj2:stomp()
        self.speedY = -getRequiredSpeed(VAR("enemyBounceHeight"))
        playSound(stompSound)
        
        return true
    end
end

function Mario:leftCollision(obj2)
    self.groundSpeedX = 0
end

function Mario:rightCollision(obj2)
    self.groundSpeedX = 0
end

function Mario:spin() end