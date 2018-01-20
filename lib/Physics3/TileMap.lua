local TileMap = class("Physics3.TileMap")

function TileMap:initialize(path, name)
	self.path = path .. "/"
	self.name = name
	
	local tileMapCode = love.filesystem.read(self.path .. "props.lua")
    self.data = sandbox.run(tileMapCode, {env={
		VAR = VAR
	}})
	self.tileSize = self.data.tileSize or 16
	self.tileMargin = self.data.tileMargin or 1
	self.img = love.graphics.newImage(self.path .. self.data.tileMap)
	self.quad = {}
	
	self.tiles = {}
	
	self.coinQuad = {}
	for i = 1, 5 do
		self.coinQuad[i] = love.graphics.newQuad((i-1)*16, 0, VAR("tileSize"), VAR("tileSize"), VAR("tileSize")*5, VAR("tileSize"))
	end

	local i = 1
	for y = 1, (self.img:getHeight()+self.tileMargin)/(self.tileSize+self.tileMargin) do
		for x = 1, (self.img:getWidth()+self.tileMargin)/(self.tileSize+self.tileMargin) do
			local quad = love.graphics.newQuad((x-1)*(self.tileSize+self.tileMargin), (y-1)*(self.tileSize+self.tileMargin), self.tileSize, self.tileSize, self.img:getWidth(), self.img:getHeight())
			
			table.insert(self.tiles, Physics3.Tile:new(self, self.img, quad, x, y, i, self.data.tiles[i]))
			table.insert(self.quad, quad)
			i = i + 1
		end
	end

	self.stampMaps = {}

	if self.data.stampMaps then
		for _, v in ipairs(self.data.stampMaps) do
			local w = #v.map[1]
			local h = #v.map

			local map = {}

			for x = 1, w do
				map[x] = {}

				for y = 1, h do
					map[x][y] = self.tiles[v.map[y][x]]
				end
			end
			
			local stampMap = StampMap:new(map, w, h) 
			stampMap.type = v.type or "simple"
			stampMap.name = v.name or ""
			stampMap.paddings = v.paddings or {}
			
			table.insert(self.stampMaps, stampMap)
		end
	end

end

return TileMap