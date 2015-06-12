
local Transitus = {}

local Utils = FasterTravel.Utils
local ZONE_INDEX_CYRODIIL = FasterTravel.Location.Data.ZONE_INDEX_CYRODIIL

local function GetNodeInfo(ctx,nodeIndex)
		
	local keepId, accessible, normalizedX,  normalizedY = GetKeepTravelNetworkNodeInfo(nodeIndex,ctx)
		
	if normalizedX == 0 and normalizedY == 0 then -- if position isn't resolved try again (mainly for quest trackers benefit in theory >_<)
		local pinType
		pinType, normalizedX, normalizedY = GetKeepPinInfo(keepId, BGQUERY_LOCAL)
	end
	
	local name  = GetKeepName(keepId)
	
	local node = {nodeIndex = keepId, zoneIndex = ZONE_INDEX_CYRODIIL, name=name ,known=accessible,normalizedX=normalizedX,normalizedY=normalizedY, isTransitus = true}
	
	return node
end

local function GetNodes(ctx)

	ctx = ctx or BGQUERY_UNKNOWN

	local nodes = {} 

	local count = GetNumKeepTravelNetworkNodes(ctx)
	
	local node
	
	for i=1,count do 
	
		node = GetNodeInfo(ctx,i)

		table.insert(nodes, node)
	
	end 
	
	table.sort(nodes,function(x,y)
	
		return x.name < y.name
	
	end)
	
	return nodes
end

local function GetKnownNodes(ctx,nodeIndex)

	local nodes = GetNodes(ctx)
	
	return Utils.where(nodes,function(node) return node.known and (nodeIndex == nil or node.nodeIndex ~= nodeIndex) end)
end

local t = Transitus

t.GetNodeInfo = GetNodeInfo
t.GetNodes = GetNodes
t.GetKnownNodes = GetKnownNodes

FasterTravel.Transitus = t 