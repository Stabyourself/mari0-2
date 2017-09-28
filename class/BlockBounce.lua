BlockBounce = class("BlockBounce")

local halfblockbouncetime = BLOCKBOUNCETIME/2

function BlockBounce:initialize(x, y)
    self.x = x
    self.y = y
    self.t = 0
    
    self.offset = 0
end

function BlockBounce:update(dt)
    self.t = self.t + dt
    
    if self.t < halfblockbouncetime then
        self.offset = (self.t/halfblockbouncetime)*BLOCKBOUNCEHEIGHT
    else
        self.offset = (1-(self.t-halfblockbouncetime)/halfblockbouncetime)*BLOCKBOUNCEHEIGHT
    end
    
    return self.t > BLOCKBOUNCETIME
end