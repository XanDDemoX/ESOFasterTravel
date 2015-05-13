
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
	
	local key, node
	
	for index,known,name,normalizedX, normalizedY, textureName ,textureName,poiType,isShown in GetNodes() do
		
		key = string.lower(name)
		node = lookup[key]
		
		if Utils.stringIsEmpty(name) == false then
			local curNode = {	
					nodeIndex=index,
					known=known,
					name=name,
					normalizedX=normalizedX, 
					normalizedY=normalizedY, 
					textureName=textureName ,
					poiType=poiType,
					isShown=isShown 
				}
		
			if node == nil then 
				node = curNode
				lookup[key] = node
			else -- accumulate additional nodes where there are multiple nodes of the same name e.g The harborage.
				if node.nodes == nil then 
					node.nodes = {Utils.extend(node)}
				end 
				table.insert(node.nodes,curNode)
			end
			
		end
	end
	
	lookup = Wayshrine.Corrections.UpdateLookup(lookup)
	
	return lookup
end

local function GetItemFromLookup(lookup,name,zoneIndex)
	if Utils.stringIsEmpty(name) == true then return nil end
	local item = lookup[string.lower(name)]
	
	item = Wayshrine.Corrections.UpdateNode(item,zoneIndex)
	
	return item 
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

				item = GetItemFromLookup(lookup,name,zoneIndex)
				
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

local function GetKnownWayshrinesByZoneIndex(zoneIndex,nodeIndex)
	local iter = GetNodesByZoneIndex(zoneIndex)
	
	iter = Utils.where(iter,function(data)
		return data.known and (nodeIndex == nil or data.nodeIndex ~= nodeIndex)
	end)
	return iter
end

local function GetNodesZoneLookup(locations)

	local lookup ={}
	for i,loc in ipairs(locations) do 
		lookup[loc.zoneIndex] = Utils.toTable(GetNodesByZoneIndex(loc.zoneIndex))
	end 
	return lookup
end

local function GetKnownNodesZoneLookup(locations)

	local lookup ={}
	for i,loc in ipairs(locations) do 
		lookup[loc.zoneIndex] = Utils.toTable(GetKnownWayshrinesByZoneIndex(loc.zoneIndex))
	end 
	return lookup
end


local w = Wayshrine
w.GetLocations = GetLocations
w.GetNodes = GetNodes
w.GetNodesLookup = GetNodesLookup
w.GetNodesByZoneIndex = GetNodesByZoneIndex
w.GetKnownWayshrinesByZoneIndex = GetKnownWayshrinesByZoneIndex
w.GetNodesZoneLookup = GetNodesZoneLookup
w.GetKnownNodesZoneLookup = GetKnownNodesZoneLookup

FasterTravel.Wayshrine = w
