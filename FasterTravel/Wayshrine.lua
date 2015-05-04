
local Wayshrine = FasterTravel.Wayshrine or {}
local Utils = FasterTravel.Utils

local function GetNodes()
	local cur = 0
	local count = GetNumFastTravelNodes()
	return function()
		if cur < count then	
			cur = cur + 1
			return cur,GetFastTravelNodeInfo(cur)
		end
		return nil
	end
end

local function GetNodesLookup()
	local lookup = {}
	for index,known,name,normalizedX, normalizedY, textureName ,textureName,poiType,isShown in GetNodes() do
		if Utils.stringIsEmpty(name) == false then
			lookup[name] = {	
				nodeIndex=index,
				known=known,
				name=name,
				normalizedX=normalizedX, 
				normalizedY=normalizedY, 
				textureName=textureName ,
				poiType=poiType,
				isShown=isShown 
			}
		end
	end
	return lookup
end

local function GetNodesByZoneIndex(zoneIndex)
	zoneIndex = zoneIndex or GetCurrentMapZoneIndex()

	local i = 0
	local count = GetNumPOIs(zoneIndex)
	local lookup = GetNodesLookup()
	local name
	local item 
	
	return function()
		
		local isWayshrine = false 
		
		while i < count and isWayshrine == false do
			i = i + 1
			isWayshrine = IsPOIWayshrine(zoneIndex,i) or IsPOIGroupDungeon(zoneIndex,i)
			
			if isWayshrine == true then
			
				name = GetPOIInfo(zoneIndex, i)
				
				if Utils.stringIsEmpty(name) == false then
					item = lookup[name]
				end
				
				if item ~= nil then 
					item.zoneIndex = zoneIndex
					return item
				else
					-- if not in lookup then skip
					isWayshrine = false
				end
				
			end
			
		end
		
		return nil
	end
end

local w = Wayshrine
w.GetLocations = GetLocations
w.GetNodes = GetNodes
w.GetNodesLookup = GetNodesLookup
w.GetNodesByZoneIndex = GetNodesByZoneIndex

FasterTravel.Wayshrine = w
