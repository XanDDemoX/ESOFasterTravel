
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
			lookup[string.lower(name)] = {	
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
	-- corrections where names differ ={
	lookup["baandari post wayshrine"] = lookup["baandari tradepost wayshrine"]
	lookup["bloodtoil valley wayshrine"] = lookup["bloodtoil wayshrine"]
	lookup["wilding vale wayshrine"] = lookup["wilding run wayshrine"]
	
	lookup["camp tamrith wayshrine"] = lookup["tamrith camp wayshrine"]
	
	lookup["seaside sanctuary wayshrine"] = lookup["seaside sanctuary"]
	lookup["seaside sanctuary"].name = "Seaside Sanctuary Wayshrine" -- renamed for consistency
	
	lookup["north morrowind gate wayshrine"] = lookup["north morrowind wayshrine"]
	lookup["south morrowind gate wayshrine"] = lookup["south morrowind wayshrine"]
	
	lookup["western elsweyr gate wayshrine"] = lookup["western elsweyr wayshrine"]
	lookup["eastern elsweyr gate wayshrine"] = lookup["eastern elsweyr wayshrine"]
	
	lookup["north highrock gate wayshrine"] = lookup["northern high rock wayshrine"]
	lookup["south highrock gate wayshrine"] = lookup["southern high rock wayshrine"]
	
	return lookup
end

local function GetItemFromLookup(lookup,name)
	if Utils.stringIsEmpty(name) == true then return nil end
	local item = lookup[string.lower(name)]
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

				item = GetItemFromLookup(lookup,name)
				
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
