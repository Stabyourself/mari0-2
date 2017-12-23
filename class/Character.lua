Character = class("character")

function Character:initialize(path)
    local characterData = love.filesystem.read(path .. "/code.lua")
    self.data = sandbox.run(characterData, {env = {
        keyDown = keyDown,
        print = print
    }})
    
    self.img = love.graphics.newImage(path .. "/graphics.png")
    

    self.quad = {}
    self.quad.idle = {}
    self.quad.running = {}
    self.quad.sliding = {}
    self.quad.jumping = {}
    
    for y = 1, 4 do
        self.quad.idle[y] = love.graphics.newQuad(0, (y-1)*20, 20, 20, self.img:getWidth(), self.img:getHeight())

        self.quad.running[y] = {}
        for i = 1, self.data.runFrames do
            self.quad.running[y][i] = love.graphics.newQuad(i*20, (y-1)*20, 20, 20, self.img:getWidth(), self.img:getHeight())
        end
        
        self.quad.sliding[y] = love.graphics.newQuad(60, (y-1)*20, 20, 20, self.img:getWidth(), self.img:getHeight())
        self.quad.jumping[y] = love.graphics.newQuad(80, (y-1)*20, 20, 20, self.img:getWidth(), self.img:getHeight())
    end
end

function Character:movement(dt, mario)
    return self.data.movement(dt, mario)
end

function Character:animation(dt, mario)
    return self.data.animation(dt, mario)
end

function Character:jump(dt, mario)
    return self.data.jump(dt, mario)
end
