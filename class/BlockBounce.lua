BlockBounce = class("BlockBounce")

local halfblockbouncetime = VAR("blockBounceTime")/2

function BlockBounce:initialize(x, y)
    self.x = x
    self.y = y
    self.t = 0
    
    self.offset = 0
end

function BlockBounce:update(dt)
    self.t = self.t + dt
    
    if self.t < halfblockbouncetime then
        self.offset = (self.t/halfblockbouncetime)*VAR("blockBounceHeight")
    else
        self.offset = (1-(self.t-halfblockbouncetime)/halfblockbouncetime)*VAR("blockBounceHeight")
    end
    
    return self.t >= VAR("blockBounceTime")
end