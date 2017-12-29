CharacterState = class("CharacterState")

function CharacterState:initialize(name, func)
    self.name = name
    self.func = func
    self.timer = 0
end

function CharacterState:update(dt)
    self.timer = self.timer + dt
end

function CharacterState:checkExit(mario)
    return self.func(mario, self)
end