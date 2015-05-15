local CALLBACK_ID_ON_WORLDMAP_CHANGED = "OnWorldMapChanged"

local function GetLocations(callback)
    local locations = {}
	
    for i = 1, GetNumMaps() do
        local mapName, mapType, mapContentType, zoneId = GetMapInfo(i)
		if Utils.stringIsEmpty(mapName) == false then
			table.insert(locations,{ name = mapName, mapIndex = i })
		end
    end
	
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
			callback(locations) -- ensure callback is called
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


local function Generate(callback)
	local locationFunc  
	-- hack for zoneIndexes
	locationFunc = Location.GetLocations(function(...)   
		removeCallback(CALLBACK_ID_ON_WORLDMAP_CHANGED,locationFunc)
		callback(...)
	end)

	addCallback(CALLBACK_ID_ON_WORLDMAP_CHANGED,locationFunc)
end