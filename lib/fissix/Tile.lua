local Tile = class("fissix.Tile")

function Tile:initialize(tileMap, img, x, y, props)
	self.tileMap = tileMap
	self.img = img
	self.x = x
	self.y = y
	self.props = props or {}
	
	self.invisible = self.props.invisible or false
	self.type = self.props.type or "normal"
	self.angle = self.props.angle or 0

	self.collision = self.props.collision or false
	if self.collision then
		self.collisionTriangulated = love.math.triangulate(self.collision)
	end
	
	if self.type == "normal" then
		self.quad = love.graphics.newQuad((self.x-1)*(self.tileMap.tileSize+self.tileMap.tileMargin), (self.y-1)*(self.tileMap.tileSize+self.tileMap.tileMargin), self.tileMap.tileSize, self.tileMap.tileSize, self.img:getWidth(), self.img:getHeight())
	elseif self.type == "coinAnimation" then
		self.quad = self.tileMap.coinQuad
		self.img = love.graphics.newImage(self.props.img)
	end
end

function Tile:checkCollision(x, y)
	if not self.collision then
		return false
	end
	
	if self.collision == VAR("collision").cube then -- optimization for cubes
		return true
	else
		for _, points in ipairs(self.collisionTriangulated) do
			if pointInTriangle(x, y, points) then
				return true
			end
		end
		
		return false
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