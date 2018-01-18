-- ^ctrl !alt +shift
return {
    ["escape"] = "quit",
    
    ["a"] = "left",
    ["d"] = "right",
    ["s"] = "down",
    ["w"] = "up",
    ["space"] = "jump",
    ["lshift"] = {"run", "editor.pipette", "editor.select.add"},
    ["rshift"] = {"run", "editor.pipette", "editor.select.add"},
    ["r"] = "closePortals",
    
    ["delete"] = "editor.delete",
    ["^z"] = "editor.undo",
    ["^y"] = "editor.redo",

    ["^c"] = "editor.copy",
    ["^x"] = "editor.cut",
    ["^v"] = "editor.paste",

    ["lctrl"] = "editor.select.subtract",
    ["lalt"] = "editor.wand.global",
    ["ralt"] = "editor.wand.global",
    
    ["p"] = "debug.star",
}
