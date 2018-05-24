local Gui3 = ...
Gui3.Text = class("Gui3.Text", Gui3.Element)

function Gui3.Text:initialize(s, x, y)
    self.s = s
    self.text = love.graphics.newText(fontOutlined, s)
    
    Gui3.Element.initialize(self, x, y, #self.s*8, 8)
end

function Gui3.Text:setString(s)
    if self.s ~= s then
        self.s = s
        self.text:set(self.s)
        self.w = #self.s*8
    end
end

function Gui3.Text:draw(level)
    Gui3.Element.translate(self)
    
    Gui3.Element.draw(self, level)
    
    love.graphics.draw(self.text, 0, 0)

    Gui3.Element.unTranslate(self)
end

return Gui3.Text
