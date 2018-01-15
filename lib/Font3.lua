local Font3 = class("Font3")
    
function Font3:initialize(img, glyphs)
    self.img = img
    self.glyphs = glyphs
    self.quad = {}
    
    local i = 1
    local glyphNum = 1
    local inLongName = false
    local currentGlyph = ""
    local glyphSize = 8
    local glyphWidth = self.img:getWidth()/glyphSize
    
    for i = 1, #self.glyphs do
        local glyph = string.sub(self.glyphs, i, i)
        local byte = string.byte(glyph)
        
        if byte ~= string.byte("\n") and byte ~= string.byte(" ") then
            local assign = false

            if byte == string.byte(";") and inLongName then
                if inLongName then
                    assign = currentGlyph
                    currentGlyph = ""
                    inLongName = false
                end
            elseif byte == string.byte("&") then
                inLongName = true
                currentGlyph = ""
            else
                if inLongName then
                    currentGlyph = currentGlyph .. glyph
                else
                    assign = glyph
                end
            end

            if assign then
                local x = math.floor((glyphNum-1)%glyphWidth+1)
                local y = math.ceil(glyphNum/glyphWidth)
                
                self.quad[assign] = love.graphics.newQuad((x-1)*glyphSize, (y-1)*glyphSize, glyphSize, glyphSize, self.img:getDimensions())

                glyphNum = glyphNum + 1    
            end
        end
    end
    
    self.quad[" "] = self.quad["Space"]
end

function Font3:print(s, x, y)
    local longGlyph = false
    local char = 0
    
    local charX = 0
    local charY = 0
    
    for i = 1, #s do
        local toPrint = false
        local glyph = string.sub(s, i, i)
        local byte = string.byte(glyph)
        
        if byte == string.byte("&") then
            longGlyph = ""
        elseif byte == string.byte(";") and longGlyph then
            toPrint = longGlyph
            longGlyph = false
        elseif byte == string.byte("\n") then
            charY = charY + 1
            charX = 0
        else
            if longGlyph then
                longGlyph = longGlyph .. glyph
            else
                toPrint = glyph
            end
        end
        
        if toPrint then
            love.graphics.draw(self.img, self.quad[toPrint], charX*8+x, charY*8+y)
            charX = charX + 1
        end
    end
end

function Font3:getLength(s)
    local withoutSpecialChars = string.gsub(s, "&.-;", "x")
    
    return #withoutSpecialChars
end

return Font3
