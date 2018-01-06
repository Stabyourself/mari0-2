GUI = class("GUI")

local current_folder = (...):gsub('%.init$', '')

GUI.Element = require(current_folder .. "/Element")
GUI.Canvas = require(current_folder .. "/Canvas")
GUI.Box = require(current_folder .. "/Box")
GUI.Text = require(current_folder .. "/Text")
GUI.Button = require(current_folder .. "/Button")
GUI.Slider = require(current_folder .. "/Slider")

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
    
    self.img.slider = love.graphics.newImage(folder .. "/slider.png")
    self.img.sliderHover = love.graphics.newImage(folder .. "/slider-hover.png")
    self.img.sliderActive = love.graphics.newImage(folder .. "/slider-active.png")
    self.img.sliderBar = love.graphics.newImage(folder .. "/slider-bar.png")
end
