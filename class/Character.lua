CharacterModel = class("character", Mario)

function CharacterModel:initialize(path)
    self.data = sandbox.run(characterData, {env = {
        keyDown = keyDown,
        print = print,
        print_r = print_r,
        VAR = VAR,
        CharacterState = CharacterState,
    }})
    
end
