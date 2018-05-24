local Tile = class("Physics3.Tile")
Tile:include(Physics3collisionMixin)

function Tile:initialize(tileMap, img, x, y, num, props, path)
	self.tileMap = tileMap
	self.x = x
	self.y = y
	self.num = num
	self.props = props or {}
	self.path = path
	
	self.type = self.props.type or "normal"
	self.angle = self.props.angle or 0

	self.collision = self.props.collision or false

	self:cacheCollisions()
	
	if self.props.img then
		self.img = love.graphics.newImage(self.path .. self.props.img)

		self.quads = {}

		for x = 1, (self.img:getWidth()+1)/self.tileMap.tileSize do
			table.insert(self.quads, love.graphics.newQuad((x-1)*17, 0, 16, 16, self.img:getWidth(), self.img:getHeight()))
		end

		self.timer = 0
		self.frame = 1

		self.quad = self.quads[self.frame]
	else
		self.img = img
		self.quad = love.graphics.newQuad((self.x-1)*(self.tileMap.tileSize+self.tileMap.tileMargin), (self.y-1)*(self.tileMap.tileSize+self.tileMap.tileMargin), self.tileMap.tileSize, self.tileMap.tileSize, self.img:getWidth(), self.img:getHeight())
	end
end

function Tile:getDelay()
	return self.props.delays[(self.frame-1)%#self.props.delays+1]
end

function Tile:update(dt)
	self.timer = self.timer + dt

	while self.timer >= self:getDelay() do
		self.timer = self.timer - self:getDelay()

		self.frame = self.frame + 1
		
		if self.frame > #self.quads then
			self.frame = 1
		end

		self.quad = self.quads[self.frame]
	end
end

function Tile:cacheCollisions()
	if not self.collision or self.collision == VAR("tileTemplates").cube then
		-- don't need to calculate collisions for this
		return
	end

	if self.collision and type(self.collision) == "table" then
		self.collisionTriangulated = love.math.triangulate(self.collision)
	end

	self.collisionCache = {}

	for x = 0, 15 do
		self.collisionCache[x] = {}
		for y = 0, 15 do
			local col = false

			for _, points in ipairs(self.collisionTriangulated) do
				if pointInTriangle(x, y, points) then
					col = true
					break
				end
			end

			self.collisionCache[x][y] = col
		end
	end
end

function Tile:checkCollision(x, y)
	if not self.collision then
		return false
	end
	
	if self.collision == VAR("tileTemplates").cube then -- optimization for cubes
		return true
	else
		x = math.floor(x)
		y = math.floor(y)

		return self.collisionCache[x][y]
	end
end

function Tile:draw(x, y)
	love.graphics.draw(self.img, self.quad, x, y)
end

return Tile