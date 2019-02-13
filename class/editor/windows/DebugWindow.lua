local DebugWindow = class("DebugWindow")

DebugWindow.x = 14
DebugWindow.y = 14
DebugWindow.width = 8*17+21
DebugWindow.height = 200


local function changeTemplate(template)
    game.players[1].actor:loadActorTemplate(template)
end

function DebugWindow:initialize(editor)
    self.editor = editor
    self.level = self.editor.level

    self.element = Gui3.Box:new(self.x, self.y, self.width, self.height)
    self.element:setDraggable(true)
    self.element.resizeable = true
    self.element.closeable = true
    self.element.background = {0.5, 0.5, 0.5, 1}
    self.element.scrollable = {true, true}
    self.element.title = "debug"
    self.editor.canvas:addChild(self.element)

    self.element:addChild(Gui3.Text:new("change actorstate", 0, 0))
    self.element:addChild(Gui3.TextButton:new(0, 10, "small", true, 0, function(button) changeTemplate(actorTemplates.smb3_small) end))
    self.element:addChild(Gui3.TextButton:new(50, 10, "fire", true, 0, function(button) changeTemplate(actorTemplates.smb3_fire) end))
    self.element:addChild(Gui3.TextButton:new(92, 10, "hammer", true, 0, function(button) changeTemplate(actorTemplates.smb3_hammer) end))
    self.element:addChild(Gui3.TextButton:new(0, 28, "big", true, 0, function(button) changeTemplate(actorTemplates.smb3_big) end))
    self.element:addChild(Gui3.TextButton:new(34, 28, "racc.", true, 0, function(button) changeTemplate(actorTemplates.smb3_raccoon) end))
    self.element:addChild(Gui3.TextButton:new(84, 28, "tanooki", true, 0, function(button) changeTemplate(actorTemplates.smb3_tanooki) end))
end


return DebugWindow
