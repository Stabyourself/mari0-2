local TileMap = class("fissix.TileMap")

function TileMap:initialize(path)
	self.path = path .. "/"
	local tileMapCode = love.filesystem.read(self.path .. "props.lua")
    self.data = sandbox.run(tileMapCode, {env={
		VAR = VAR
	}})
	self.tileSize = self.data.tileSize
	self.tileMargin = self.data.tileMargin or 1

	self.img = love.graphics.newImage(self.path .. self.data.tileMap)
	self.quad = {}
	
	self.tiles = {}
	
	self.coinQuad = {}
	for i = 1, 5 do
		self.coinQuad[i] = love.graphics.newQuad((i-1)*16, 0, VAR("tileSize"), VAR("tileSize"), VAR("tileSize")*5, VAR("tileSize"))
	end

	local i = 1
	for y = 1, self.img:getHeight()/(self.tileSize+self.tileMargin) do
		for x = 1, self.img:getWidth()/(self.tileSize+self.tileMargin) do
			local quad = love.graphics.newQuad((x-1)*(self.tileSize+self.tileMargin), (y-1)*(self.tileSize+self.tileMargin), self.tileSize, self.tileSize, self.img:getWidth(), self.img:getHeight())
			
			table.insert(self.tiles, fissix.Tile:new(self, self.img, quad, x, y, self.data.tiles[i]))
			table.insert(self.quad, quad)
			i = i + 1
		end
	end
end

return TileMap