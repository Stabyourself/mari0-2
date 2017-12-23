Mario = class("Mario", fissix.PhysObj)
    

function Mario:initialize(world, char, x, y)
    fissix.PhysObj.initialize(self, world, x, y, 12, 12)
    
    self.char = char
    
    self.jumping = false
    self.ducking = false

    self.animationState = "idle"
    self.quad = self.char.quad[self.animationState][3]
    
    self.runAnimationFrame = 1
    self.runAnimationTimer = 0
    self.animationDirection = 1
    self.img = self.char.img
    self.centerX = 10
    self.centerY = 10
end

function Mario:update(dt)
    -- Jump physics
    if self.jumping then
        if not keyDown("jump") or self.speedY > 0 then
            self.jumping = false
            self.gravity = GRAVITY
        end
    end

    self.char:movement(dt, self)
    self.char:animation(dt, self)

    self.quad = self.char.quad[self.animationState][3]

    if self.animationState == "running" then
        self.quad = self.char.quad[self.animationState][3][self.runAnimationFrame]
    end
end

function Mario:jump()
    self.onGround = false
    self.jumping = true

    self.gravity = GRAVITYJUMPING
    
    self.char:jump(dt, self)
    
    playSound(jumpSound)
end

function Mario:ceilCollide(obj2)
    if obj2:isInstanceOf(Block) then
        -- See whether it was very close to the edge of a block next to air, in which case allow Mario to keep jumping
        -- Right side
        if self.x > obj2.x+obj2.width - JUMPLEEWAY and not game.level:getTile(obj2.blockX+1, obj2.blockY).collision then
            self.x = obj2.x+obj2.width
            self.speedX = math.max(self.speedX, 0)

            return true
        end
        
        -- Left side
        if self.x + self.width < obj2.x + JUMPLEEWAY and not game.level:getTile(obj2.blockX-1, obj2.blockY).collision then
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
        
        self.speedY = BLOCKHITFORCE
        
        game.level:bumpBlock(x, y)
    end
end

function Mario:floorCollide(obj2)
    if obj2.stompable then
        obj2:stomp()
        self.speedY = -getRequiredSpeed(ENEMYBOUNCEHEIGHT)
        playSound(stompSound)
        
        return true
    end
end

function Mario:startFall()
    self.animationState = "running"
end