-- ^ctrl !alt +shift (the order is important when stacking)
return {
    ["escape"] = {"quit", "editor.select.clear"},

    ["a"] = "left",
    ["d"] = "right",
    ["s"] = "down",
    ["w"] = "up",
    ["space"] = {"jump", "editor.tool.entity"},
    ["lshift"] = {"run", "editor.line", "editor.select.add"},
    ["rshift"] = {"run", "editor.line", "editor.select.add"},
    ["r"] = {"closePortals", "editor.tool.paint"},

    ["delete"] = "editor.delete",
    ["^z"] = "editor.undo",
    ["^y"] = "editor.redo",

    ["^c"] = "editor.copy",
    ["^x"] = "editor.cut",
    ["^v"] = "editor.paste",

    ["^s"] = "editor.save",

    ["lctrl"] = {"editor.select.subtract", "editor.pipette"},
    ["rctrl"] = {"editor.select.subtract", "editor.pipette"},
    ["lalt"] = "editor.wand.global",
    ["ralt"] = "editor.wand.global",

    ["return"] = "editor.select.unFloat",

    ["e"] = "editor.tool.erase",
    ["3"] = "editor.tool.move",
    ["q"] = "editor.tool.select",
    ["g"] = "editor.tool.wand",
    ["f"] = "editor.tool.fill",
    ["t"] = "editor.tool.stamp",

    ["p"] = "debug.star",

    ["pause"] = "debug.pausePlay",
    ["#"] = "debug.frameAdvance"
}
