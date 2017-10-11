local TileMap = class("fissix.TileMap")

function TileMap:initialize(path)
	self.path = path .. "/"
	self.data = require(self.path .. "props")
	self.tileSize = self.data.tileSize
	self.tileMargin = self.data.tileMargin or 1

	self.img = love.graphics.newImage(self.path .. self.data.tileMap)
	
	if self.data.collisionMap then
		self.collisionImg = love.graphics.newImage(self.path .. self.data.collisionMap)
		self.collisionImgData = love.image.newImageData(self.path .. self.data.collisionMap)
	end
	
	self.tiles = {}
	
	self.coinQuad = {}
	for i = 1, 5 do
		self.coinQuad[i] = love.graphics.newQuad((i-1)*16, 0, TILESIZE, TILESIZE, TILESIZE*5, TILESIZE)
	end

	local i = 1
	for y = 1, self.img:getHeight()/(self.tileSize+self.tileMargin) do
		for x = 1, self.img:getWidth()/(self.tileSize+self.tileMargin) do
			table.insert(self.tiles, fissix.Tile:new(self, self.img, self.collisionImg, self.collisionImgData, x, y, self.data.tiles[i]))
			i = i + 1
		end
	end
end

return TileMap