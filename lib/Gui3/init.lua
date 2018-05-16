-- GUI library thing for Mari0 2. Feel free to use it, MIT License

Gui3 = class("Gui3")

local current_folder = (...):gsub('%.init$', '')

Gui3.Element = require(current_folder.. ".Element")
Gui3.Canvas = require(current_folder.. ".Canvas")
Gui3.Box = require(current_folder.. ".Box")
Gui3.Text = require(current_folder.. ".Text")
Gui3.Image = require(current_folder.. ".Image")
Gui3.Button = require(current_folder.. ".Button")
Gui3.Slider = require(current_folder.. ".Slider")
Gui3.TileGrid = require(current_folder.. ".TileGrid")
Gui3.Checkbox = require(current_folder.. ".Checkbox")
Gui3.Dropdown = require(current_folder.. ".Dropdown")

function Gui3.makeBoxCache(quads)
    local _, _, w1 = quads[1]:getViewport()
    local _, _, w2 = quads[2]:getViewport()
    local _, _, w3 = quads[3]:getViewport()
    
    local _, _, _, h1 = quads[1]:getViewport()
    local _, _, _, h2 = quads[4]:getViewport()
    local _, _, _, h3 = quads[7]:getViewport()

    local out = {}

    out[1] = {0, 0, 1, 1}
    out[2] = {w1, 0, -w1-w3, 1}
    out[3] = {-w3, 0, 1, 1}
    out[4] = {0, h1, 1, -h1-h3}
    out[5] = {w1, h1, -w1-w3, -h1-h3}
    out[6] = {-w3, h1, 1, -h1-h3}
    out[7] = {0, -h3, 1, 1}
    out[8] = {w1, -h3, -w1-w3, 1}
    out[9] = {-w3, -h3, 1, 1}

    return out
end

Gui3.boxCache = {}
Gui3.boxQuad = {
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

Gui3.titledBoxQuad = {
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

Gui3.boxCache[Gui3.boxQuad] = Gui3.makeBoxCache(Gui3.boxQuad)
Gui3.boxCache[Gui3.titledBoxQuad] = Gui3.makeBoxCache(Gui3.titledBoxQuad)

function Gui3:initialize(folder)
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

function Gui3.drawBox(img, quads, x, y, w, h)
    local v = Gui3.boxCache[quads]

    love.graphics.push()
    love.graphics.translate(x, y)
    
    love.graphics.draw(img, quads[1], v[1][1], v[1][2], 0, 1, 1)
    love.graphics.draw(img, quads[2], v[2][1], v[2][2], 0, w+v[2][3], 1)
    love.graphics.draw(img, quads[3], w+v[3][1], v[3][2], 0, 1, 1)
    love.graphics.draw(img, quads[4], v[4][1], v[4][2], 0, 1, h+v[4][4])
    love.graphics.draw(img, quads[5], v[5][1], v[5][2], 0, w+v[5][3], h+v[5][4])
    love.graphics.draw(img, quads[6], w+v[6][1], v[6][2], 0, 1, h+v[6][4])
    love.graphics.draw(img, quads[7], v[7][1], h+v[7][2], 0, 1, 1)
    love.graphics.draw(img, quads[8], v[8][1], h+v[8][2], 0, w+v[8][3], 1)
    love.graphics.draw(img, quads[9], w+v[9][1], h+v[9][2], 0, 1, 1)

    love.graphics.pop()
end
