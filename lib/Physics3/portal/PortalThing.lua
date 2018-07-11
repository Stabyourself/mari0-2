local PortalThing = class("PortalThing")

function PortalThing:initialize(img, offset)
    self.img = img
    self.offset = offset
    self.a = offset
end

function PortalThing:update(dt, a)
    self.a = a + self.offset
    self.a = normalizeAngle(self.a)
end

function PortalThing:draw(side, color, mult)
    if  side == "foreground" and self.a <= math.pi*0.5 and self.a > -math.pi*0.5 or
        side == "background" and (self.a > math.pi*0.5 or self.a <= -math.pi*0.5) then
        --darken based on distance to "front"
        local darken = math.abs(self.a)/math.pi*0.8

        love.graphics.setColor(color:darken(darken))

        local x = math.sin(self.a)

        -- make portal more oval shaped by squaring the result
        if x > 0 then
            x = 1-(1-x)^1.5
        else
            x = -(1-(1+x)^1.5)
        end

        x = x

        local sx = (1-(math.abs(x)))*0.7+0.3

        love.graphics.draw(self.img, x*mult, 0, 0, sx, 1, self.img:getWidth()/2, self.img:getHeight()+1)
    end
end

return PortalThing
