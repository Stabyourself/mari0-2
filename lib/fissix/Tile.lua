local Tile = class("fissix.Tile")

function Tile:initialize(tileMap, img, collisionImg, collisionImgData, x, y, props)
	self.tileMap = tileMap
	self.img = img
	self.collisionImg = collisionImg
	self.collisionImgData = collisionImgData
	self.x = x
	self.y = y
	self.props = props or {}

	self.collision = self.props.collision or false
	self.mesh = self.props.mesh or false
	self.partialCollision = self.props.partialCollision or false
	self.invisible = self.props.invisible or false
	self.type = self.props.type or "normal"
	
	if self.type == "normal" then
		self.quad = love.graphics.newQuad((self.x-1)*(self.tileMap.tileSize+self.tileMap.tileMargin), (self.y-1)*(self.tileMap.tileSize+self.tileMap.tileMargin), self.tileMap.tileSize, self.tileMap.tileSize, self.img:getWidth(), self.img:getHeight())
	elseif self.type == "coinAnimation" then
		self.quad = self.tileMap.coinQuad
		self.img = love.graphics.newImage(self.props.img)
	end
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
		if self.type == "normal" then
			worldDraw(self.img, self.quad, x, y)
		elseif self.type == "coinAnimation" then
			worldDraw(self.img, self.quad[game.coinAnimationFrame], x, y)
		end
	end
end

return Tile