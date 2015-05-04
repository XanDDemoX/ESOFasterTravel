
local Location = FasterTravel.Location or {}
local Utils = FasterTravel.Utils

local function DistanceSquared(x1,y1,x2,y2)
	local dx,dy = (x2-x1),(y2-y1)
	return (dx * dx),(dy * dy)
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
	
	local cur = 0
	local count = #locations
	local mouseClickQuest,mouseDownLoc,mouseUpLoc=WORLD_MAP_QUESTS.QuestHeader_OnClicked,WORLD_MAP_LOCATIONS.RowLocation_OnMouseDown,WORLD_MAP_LOCATIONS.RowLocation_OnMouseUp
	d(count)
	local done = false 
	-- hack to get location zoneIndexes by changing the map and using GetCurrentMapZoneIndex() (eugh >_<)
	return function()
		if done == true then 
			callback(locations,curZoneIndex,curIndex)
			return 
		end
		
		if cur == 0 then
			WORLD_MAP_QUESTS.QuestHeader_OnClicked = function() end -- prevent mouse use on map locations whilst this is happening.
			WORLD_MAP_LOCATIONS.RowLocation_OnMouseDown = function() end 
			WORLD_MAP_LOCATIONS.RowLocation_OnMouseUp = function() end
			
			curIndex = GetCurrentMapIndex()
			curZoneIndex = GetCurrentMapZoneIndex()
			cur = cur + 1
			
			ZO_WorldMap_SetMapByIndex(locations[cur].mapIndex)
			
			return
		end
		
		locations[cur].zoneIndex = GetCurrentMapZoneIndex()
		
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
	for i,loc in ipairs(locations) do 
		lookup[loc.zoneIndex] = func(loc)
	end
	return lookup
end

local function GetClosestLocation(normalizedX,normalizedY,locations)
	if zoneIndex== nil or poiIndex == nil or locations == nil then return end
	
	local count = #locations 
	
	if count < 1 then return end 
	
	if normalizedX == nil or normalizedY == nil then return end
	
	local closest = locations[1]
	local dist = DistanceSquared(normalizedX,normalizedY,closest.normalizedX,closest.normalizedY)
	
	local loc,cur
	
	local x,y
	
	for i=2, count do 
		loc = zoneLocations[i]
		
		x,y = loc.normalizedX,loc.normalizedY
		if x ~= nil and y ~= nil then 
			cur = DistanceSquared(normalizedX,normalizedY,x,y)
			
			if cur < dist then
				closest = loc 
				dist = cur 
			end
		end
	end
	
	return closest
end

local l = Location

l.GetClosestLocation = GetClosestLocation
l.GetLocations = GetLocations
l.CreateLocationsLookup = CreateLocationsLookup

FasterTravel.Location = l 