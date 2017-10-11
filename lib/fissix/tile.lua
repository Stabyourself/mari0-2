local Tile = class("fissix.Tile")

function Tile:initialize(tileMap, img, collisionImg, collisionImgData, x, y, t)
	self.tileMap = tileMap
	self.img = img
	self.collisionImg = collisionImg
	self.collisionImgData = collisionImgData
	self.x = x
	self.y = y
	self.t = t or {}

	self.collision = self.t.collision or false
	self.partialCollision = self.t.partialCollision or false
	self.invisible = self.t.invisible or false
	
	self.quad = love.graphics.newQuad((self.x-1)*(self.tileMap.tileSize+self.tileMap.tileMargin), (self.y-1)*(self.tileMap.tileSize+self.tileMap.tileMargin), self.tileMap.tileSize, self.tileMap.tileSize, self.img:getWidth(), self.img:getHeight())
end

function Tile:checkCollision(x, y)
	mainPerformanceTracker:track("pixel collision checks")
	if not self.collision then
		return false
	end
	
	if self.partialCollision then
		local r, g, b, a = self.collisionImgData:getPixel((self.x-1)*(self.tileMap.tileSize+self.tileMap.tileMargin)+x, (self.y-1)*(self.tileMap.tileSize+self.tileMap.tileMargin)+y)

		return a > 127
	else
		return true
	end
end

function Tile:draw(x, y)
	if not self.invisible then
		worldDraw(self.img, self.quad, x, y)
	end
end

return Tile