GUI = class("GUI")

local current_folder = (...):gsub('%.init$', '')

GUI.Element = require(current_folder.. ".Element")
GUI.Canvas = require(current_folder.. ".Canvas")
GUI.Box = require(current_folder.. ".Box")
GUI.Text = require(current_folder.. ".Text")
GUI.Button = require(current_folder.. ".Button")
GUI.Slider = require(current_folder.. ".Slider")
GUI.ButtonGrid = require(current_folder.. ".ButtonGrid")
GUI.Checkbox = require(current_folder.. ".Checkbox")

GUI.boxQuad = {
    love.graphics.newQuad(0, 0, 2, 3, 5, 7),
    love.graphics.newQuad(2, 0, 1, 3, 5, 7),
    love.graphics.newQuad(3, 0, 2, 3, 5, 7),
    love.graphics.newQuad(0, 3, 2, 1, 5, 7),
    love.graphics.newQuad(2, 3, 1, 1, 5, 7),
    love.graphics.newQuad(3, 3, 2, 1, 5, 7),
    love.graphics.newQuad(0, 4, 2, 3, 5, 7),
    love.graphics.newQuad(2, 4, 1, 3, 5, 7),
    love.graphics.newQuad(3, 4, 2, 3, 5, 7),
}

GUI.titledBoxQuad = {
    love.graphics.newQuad(0, 0, 3, 12, 7, 17),
    love.graphics.newQuad(3, 0, 1, 12, 7, 17),
    love.graphics.newQuad(4, 0, 3, 12, 7, 17),
    love.graphics.newQuad(0, 12, 3, 1, 7, 17),
    love.graphics.newQuad(3, 12, 1, 1, 7, 17),
    love.graphics.newQuad(4, 12, 3, 1, 7, 17),
    love.graphics.newQuad(0, 13, 3, 4, 7, 17),
    love.graphics.newQuad(3, 13, 1, 4, 7, 17),
    love.graphics.newQuad(4, 13, 3, 4, 7, 17),
}

function GUI:initialize(folder)
    self.folder = folder
    
    self.img = {}
    self.img.box = love.graphics.newImage(folder .. "/box.png")
    self.img.boxTitled = love.graphics.newImage(folder .. "/box-titled.png")
    
    self.img.scrollbar = love.graphics.newImage(folder .. "/scrollbar.png")
    self.img.scrollbarHover = love.graphics.newImage(folder .. "/scrollbar-hover.png")
    self.img.scrollbarActive = love.graphics.newImage(folder .. "/scrollbar-active.png")
    self.img.scrollbarBack = love.graphics.newImage(folder .. "/scrollbar-back.png")
    
    self.img.boxResize = love.graphics.newImage(folder .. "/box-resize.png")
    self.img.boxResizeHover = love.graphics.newImage(folder .. "/box-resize-hover.png")
    self.img.boxResizeActive = love.graphics.newImage(folder .. "/box-resize-active.png")
    
    self.img.boxClose = love.graphics.newImage(folder .. "/box-close.png")
    self.img.boxCloseHover = love.graphics.newImage(folder .. "/box-close-hover.png")
    self.img.boxCloseActive = love.graphics.newImage(folder .. "/box-close-active.png")
    
    self.img.button = love.graphics.newImage(folder .. "/button.png")
    self.img.buttonHover = love.graphics.newImage(folder .. "/button-hover.png")
    self.img.buttonActive = love.graphics.newImage(folder .. "/button-active.png")
    
    self.img.slider = love.graphics.newImage(folder .. "/slider.png")
    self.img.sliderHover = love.graphics.newImage(folder .. "/slider-hover.png")
    self.img.sliderActive = love.graphics.newImage(folder .. "/slider-active.png")
    self.img.sliderBar = love.graphics.newImage(folder .. "/slider-bar.png")
    
    self.img.checkbox = {
        on = love.graphics.newImage(folder .. "/checkbox-on.png"),
        off = love.graphics.newImage(folder .. "/checkbox-off.png"),
    }
    self.img.checkboxHover = {
        on = love.graphics.newImage(folder .. "/checkbox-on-hover.png"),
        off = love.graphics.newImage(folder .. "/checkbox-off-hover.png"),
    }
    self.img.checkboxActive = {
        on = love.graphics.newImage(folder .. "/checkbox-on-active.png"),
        off = love.graphics.newImage(folder .. "/checkbox-off-active.png"),
    }
end

function GUI.drawBox(img, quad, x, y, w, h)
    local _, _, w1 = quad[1]:getViewport()
    local _, _, w2 = quad[2]:getViewport()
    local _, _, w3 = quad[3]:getViewport()
    
    local _, _, _, h1 = quad[1]:getViewport()
    local _, _, _, h2 = quad[4]:getViewport()
    local _, _, _, h3 = quad[7]:getViewport()
    
    love.graphics.draw(img, quad[1], x, y)
    love.graphics.draw(img, quad[2], x+w1, y, 0, w-w1-w3, 1)
    love.graphics.draw(img, quad[3], x+w-w3, y)
    love.graphics.draw(img, quad[4], x, y+h1, 0, 1, h-h1-h3)
    love.graphics.draw(img, quad[5], x+w1, y+h1, 0, w-w1-w3, h-h1-h3)
    love.graphics.draw(img, quad[6], x+w-w3, y+h1, 0, 1, h-h1-h3)
    love.graphics.draw(img, quad[7], x, y+h-h3)
    love.graphics.draw(img, quad[8], x+w1, y+h-h3, 0, w-w1-w3, 1)
    love.graphics.draw(img, quad[9], x+w-w3, y+h-h3)
end