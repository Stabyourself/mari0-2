CharacterModel = class("character", Mario)

function CharacterModel:initialize(path)
    self.data = sandbox.run(characterData, {env = {
        cmdDown = cmdDown,
        print = print,
        print_r = print_r,
        VAR = VAR,
        CharacterState = CharacterState,
    }})
    
end
