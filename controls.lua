-- ^ctrl !alt +shift (the order is important)
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
    
    ["1"] = "editor.tool.paint",
    ["2"] = "editor.tool.erase",
    ["3"] = "editor.tool.move",
    ["4"] = "editor.tool.portal",
    ["5"] = "editor.tool.select",
    ["6"] = "editor.tool.wand",
    ["7"] = "editor.tool.fill",
    ["8"] = "editor.tool.stamp",
    
    ["p"] = "debug.star",
}
