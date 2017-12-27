CharacterState = class("CharacterState")

function CharacterState:initialize(name, func)
    self.name = name
    self.func = func
end

function CharacterState:checkExit(mario)
    return self.func(mario)
end