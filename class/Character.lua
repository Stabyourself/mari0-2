CharacterModel = class("character", Mario)

function CharacterModel:initialize(path)
    self.data = sandbox.run(characterData, {env = {
        controls3 = controls3,
        print = print,
        print_r = print_r,
        VAR = VAR,
        ActorState = ActorState,
    }})
end
