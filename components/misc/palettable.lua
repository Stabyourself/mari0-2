local component = {}

function component.setup(actor, dt, actorEvent, args)
    actor.imgPalette = convertPalette(args["imgPalette"])

    actor.defaultPalette = convertPalette(args["defaultPalette"] or args["imgPalette"])
    
    actor.palette = actor.defaultPalette
end

return component
