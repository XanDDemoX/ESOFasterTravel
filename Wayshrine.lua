
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

local function GetNodesByZoneIndex(zoneIndex)

	local nodes = Wayshrine.Data.GetNodesByZoneIndex(zoneIndex)

	local known,name,normalizedX, normalizedY, textureName ,textureName,poiType,isShown

	local cur = 0
	local count = #nodes

	return function()
		if cur < count then
			cur = cur + 1

			local node = nodes[cur]

			local known,name,normalizedX, normalizedY, textureName ,textureName,poiType,isShown = Wayshrine.Data.GetNodeInfo(node.nodeIndex)

			return {
					zoneIndex=zoneIndex,
					nodeIndex=node.nodeIndex,
					poiIndex=node.poiIndex,
					known=known,
					name=name,
					normalizedX=normalizedX,
					normalizedY=normalizedY,
					textureName=textureName,
					poiType=poiType,
					isShown=isShown,
				}
		end
	end
end

local function GetKnownWayshrinesByZoneIndex(zoneIndex,nodeIndex)
	local iter = GetNodesByZoneIndex(zoneIndex)

	iter = Utils.where(iter,function(data)
		return data.known and (nodeIndex == nil or data.nodeIndex ~= nodeIndex)
	end)
	return iter
end

local function GetNodesZoneLookup(locations,func)
	func = func or GetNodesByZoneIndex
	local lookup ={}
	for i,loc in ipairs(locations) do
		lookup[loc.zoneIndex] = Utils.toTable(func(loc.zoneIndex))
	end
	return lookup
end


local w = Wayshrine
w.GetNodes = GetNodes
w.GetNodesByZoneIndex = GetNodesByZoneIndex
w.GetKnownWayshrinesByZoneIndex = GetKnownWayshrinesByZoneIndex
w.GetNodesZoneLookup = GetNodesZoneLookup

w.GetKnownNodesZoneLookup = function(locations)
	return GetNodesZoneLookup(locations,GetKnownWayshrinesByZoneIndex)
end

FasterTravel.Wayshrine = w
