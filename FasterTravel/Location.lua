
local Location = FasterTravel.Location or {}
local Utils = FasterTravel.Utils

local function DistanceSquared(x1,y1,x2,y2)
	local dx,dy = (x2-x1),(y2-y1)
	return (dx * dx)+(dy * dy)
end

local function GetMapZone(path)
	path = path or GetMapTileTexture()
	path = string.lower(path)
	local zone,subzone = string.match(path,"^.-/.-/(.-)/(.-)_")
	if zone == nil and subzone == nil then 
		-- splits if path is actually a zone key 
		zone,subzone = string.match(path,"^(.-)/(.-)$")
	end
	return zone,subzone
end

local function GetMapZoneKey(zone,subzone)
	if zone == nil and subzone == nil then 
		zone,subzone = GetMapZone()
	elseif subzone == nil then
		zone,subzone = GetMapZone(zone)
	end
	return zone.."/"..subzone,zone,subzone
end

local function GetZoneLocation(lookup,zone,subzone)

	local key,zone,subzone = GetMapZoneKey(zone,subzone)
	
	-- try by zone/subzone key first
	loc = lookup[key]
	
	-- subzone next to handle places like khenarthis roost
	if loc == nil then
		loc = lookup[subzone]
	end
	-- then zone to handle locations within main zones which cannot be matched by key e.g coldharbor's hollow city
	if loc == nil then 
		loc = lookup[zone]
	end 
	-- if zone cant be found then return tamriel
	if loc == nil then 
		loc = lookup["tamriel"]
	end
	
	return loc
end

local function GetLocations(callback)
    local locations = {}
	
    for i = 1, GetNumMaps() do
        local mapName, mapType, mapContentType, zoneId = GetMapInfo(i)
		if Utils.stringIsEmpty(mapName) == false then
			table.insert(locations,{ name = mapName, mapIndex = i })
		end
    end
	
    table.sort(locations, function(x,y)
        return x.name < y.name
    end)
	
	local curIndex
	local curZoneIndex
	local curZoneKey
	
	local cur = 0
	local count = #locations
	local mouseClickQuest,mouseDownLoc,mouseUpLoc=WORLD_MAP_QUESTS.QuestHeader_OnClicked,WORLD_MAP_LOCATIONS.RowLocation_OnMouseDown,WORLD_MAP_LOCATIONS.RowLocation_OnMouseUp

	local done = false 
	local complete = false 
	-- hack to get location zoneIndexes by changing the map and using GetCurrentMapZoneIndex() (eugh >_<)
	return function()
		
		if complete == true then 
			return 
		end
		
		if done == true then 
			complete = true 
			ZO_WorldMap_SetMapByIndex(curIndex)
			callback(locations,GetMapZoneKey(curZoneKey)) -- ensure callback is called
			return 
		end
		
		if cur == 0 then
			WORLD_MAP_QUESTS.QuestHeader_OnClicked = function() end -- prevent mouse use on map locations whilst this is happening.
			WORLD_MAP_LOCATIONS.RowLocation_OnMouseDown = function() end 
			WORLD_MAP_LOCATIONS.RowLocation_OnMouseUp = function() end
			
			curIndex = GetCurrentMapIndex()
			curZoneIndex = GetCurrentMapZoneIndex()
			curZoneKey = GetMapTileTexture()
			cur = cur + 1
			
			ZO_WorldMap_SetMapByIndex(locations[cur].mapIndex)
			
			return
		end
		
		local item = locations[cur]
		item.zoneIndex = GetCurrentMapZoneIndex()
		
		local path = GetMapTileTexture()
		
		item.tile = path
		item.key,item.zone,item.subzone = GetMapZoneKey(path)
		
		if cur >= count then
			done = true 
			
			ZO_WorldMap_SetMapByIndex(curIndex)
			
			WORLD_MAP_QUESTS.QuestHeader_OnClicked = mouseClickQuest -- restore mouse use
			WORLD_MAP_LOCATIONS.RowLocation_OnMouseDown = mouseDownLoc
			WORLD_MAP_LOCATIONS.RowLocation_OnMouseUp = mouseUpLoc
			
		elseif cur > 0 and cur < count then 
			cur = cur + 1
			ZO_WorldMap_SetMapByIndex(locations[cur].mapIndex)
		end
	end
	
end

local function CreateLocationsLookup(locations,func)
	local lookup = {}
	func = func or function(l) return l end 
	local item
	for i,loc in ipairs(locations) do 
		item = func(loc)
		
		lookup[loc.zoneIndex] = item
		lookup[loc.key] = item

		if lookup[loc.zone] == nil then 
			lookup[loc.zone] = item
		end
		
		if lookup[loc.subzone] == nil then 
			lookup[loc.subzone] = item
		end

	end
	return lookup
end


local function GetClosestLocation(normalizedX,normalizedY,locations)
	if normalizedX == nil or normalizedY == nil or locations == nil then return end
	
	local count = #locations 
	
	if count <= 1 then return locations[1] end 
	
	local closest = locations[1]
	
	local loc
	local cur
	local x,y = closest.normalizedX,closest.normalizedY
	local dist = DistanceSquared(normalizedX,normalizedY,x,y)

	for i=2, count do 
		loc = locations[i]
		
		x,y = loc.normalizedX,loc.normalizedY

		cur = DistanceSquared(normalizedX,normalizedY,x,y)
		
		if cur < dist then
			closest = loc 
			dist = cur
		end

	end
	
	return closest
end



local function IsCyrodiil(loc)
	if loc == nil then return false end
	return string.lower(loc.name) == "cyrodiil"
end

local function IsCurrentZoneCyrodiil(lookup)
	local loc = GetZoneLocation(lookup)
	return IsCyrodiil(loc)
end

local l = Location

l.GetClosestLocation = GetClosestLocation
l.GetLocations = GetLocations
l.CreateLocationsLookup = CreateLocationsLookup
l.GetZoneLocation = GetZoneLocation
l.IsCyrodil = IsCyrodiil
l.IsCurrentZoneCyrodiil = IsCurrentZoneCyrodiil
l.GetMapZoneKey = GetMapZoneKey
l.GetMapZone = GetMapZone

FasterTravel.Location = l 