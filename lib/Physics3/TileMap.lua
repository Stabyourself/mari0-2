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
	
	self.tiles = {}
	self.updateTiles = {}

	local i = 1
	for y = 1, (self.img:getHeight()+self.tileMargin)/(self.tileSize+self.tileMargin) do
		for x = 1, (self.img:getWidth()+self.tileMargin)/(self.tileSize+self.tileMargin) do
			local tile = Physics3.Tile:new(self, self.img, x, y, i, self.data.tiles[i], self.path)
			table.insert(self.tiles, tile)

			if tile.quads then
				table.insert(self.updateTiles, tile)
			end

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

function TileMap:update(dt)
	for _, v in ipairs(self.updateTiles) do
		v:update(dt)
	end
end

return TileMap