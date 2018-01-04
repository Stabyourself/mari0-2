GUI = class("GUI")

GUI.Element = require("class/gui/Element")
GUI.Canvas = require("class/gui/Canvas")
GUI.Box = require("class/gui/Box")
GUI.Text = require("class/gui/Text")
GUI.Button = require("class/gui/Button")
GUI.Slider = require("class/gui/Slider")

function GUI:initialize(folder)
    self.folder = folder
    
    self.img = {}
    self.img.box = love.graphics.newImage(folder .. "/box.png")
    self.img.boxTitled = love.graphics.newImage(folder .. "/box-titled.png")
    
    self.img.scrollBar = love.graphics.newImage(folder .. "/scrollbar.png")
    self.img.scrollBarHover = love.graphics.newImage(folder .. "/scrollbar-hover.png")
    self.img.scrollBarBack = love.graphics.newImage(folder .. "/scrollbar-back.png")
    
    self.img.boxResize = love.graphics.newImage(folder .. "/box-resize.png")
    self.img.boxResizeHover = love.graphics.newImage(folder .. "/box-resize-hover.png")
    self.img.boxResizeActive = love.graphics.newImage(folder .. "/box-resize-active.png")
    
    self.img.boxClose = love.graphics.newImage(folder .. "/box-close.png")
    self.img.boxCloseHover = love.graphics.newImage(folder .. "/box-close-hover.png")
    self.img.boxCloseActive = love.graphics.newImage(folder .. "/box-close-active.png")
    
    self.img.button = love.graphics.newImage(folder .. "/button.png")
    self.img.buttonHover = love.graphics.newImage(folder .. "/button-hover.png")
    
    self.img.sliderBar = love.graphics.newImage(folder .. "/slider-bar.png")
    self.img.slider = love.graphics.newImage(folder .. "/slider.png")
    self.img.sliderHover = love.graphics.newImage(folder .. "/slider-hover.png")
end
