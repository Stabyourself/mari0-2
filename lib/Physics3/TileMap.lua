local StampMap = require "class.editor.StampMap"
local TileMap = class("Physics3.TileMap")

function TileMap:initialize(path, name)
	self.path = path .. "/"
	self.name = name

	local tileMapCode = love.filesystem.read(self.path .. "settings.lua")

	assert(tileMapCode, string.format("Map tried to tell me that it uses the tilemap \"%s\" but we all know that's bullshit because that tilemap's settings.lua doesn't exist.", name))

    self.data = sandbox.run(tileMapCode, {env={
		VAR = VAR
	}})
	self.tileSize = self.data.tileSize or 16
	self.tileMargin = self.data.tileMargin or 1
	self.img = love.graphics.newImage(self.path .. self.data.tileMap)
	self.imgData = love.image.newImageData(self.path .. self.data.tileMap)

	self.tiles = {}
	self.animatedTiles = {}

	local i = 1
	for y = 1, (self.img:getHeight()+self.tileMargin)/(self.tileSize+self.tileMargin) do
		for x = 1, (self.img:getWidth()+self.tileMargin)/(self.tileSize+self.tileMargin) do
			local tile = Physics3.Tile:new(self, self.img, x, y, i, self.data.tiles[i], self.path)
			table.insert(self.tiles, tile)

			if tile.quads then
				table.insert(self.animatedTiles, tile)
			end

			i = i + 1
		end
	end

	self.stampMaps = {}

	if self.data.stampMaps then
		for _, stampMap in ipairs(self.data.stampMaps) do
			local w = #stampMap.map[1]
			local h = #stampMap.map

			local map = {}

			for x = 1, w do
				map[x] = {}

				for y = 1, h do
					map[x][y] = self.tiles[stampMap.map[y][x]]
				end
			end

			-- sanity checks
			for i = 1, 4 do
				if stampMap.paddings and stampMap.paddings[i] then
					local compareTo = w

					if i%2 == 1 then
						compareTo = h
					end

					assert(stampMap.paddings[i] <= compareTo, string.format("StampMap \"%s\" from the TileMap \"%s\" had a padding[%s] bigger than its own size. I hope I don't have to explain how nonsensical that is.", stampMap.name, name, i))
				end
			end

			table.insert(self.stampMaps, StampMap:new(map, w, h, stampMap.type, stampMap.name, stampMap.paddings))
		end
	end
end

function TileMap:update(dt)
	for _, tile in ipairs(self.animatedTiles) do
		tile:update(dt)
	end
end

function TileMap:setFilter(min, mag)
	self.img:setFilter(min, mag)

	for _, tile in ipairs(self.animatedTiles) do
		tile.img:setFilter(min, mag)
	end
end

return TileMap