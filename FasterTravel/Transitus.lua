
local Transitus = {}

local Utils = FasterTravel.Utils
local ZONE_INDEX_CYRODIIL = FasterTravel.Location.Data.ZONE_INDEX_CYRODIIL

local function GetNodes(ctx)

	ctx = ctx or BGQUERY_UNKNOWN

	local nodes = {} 

	local count = GetNumKeepTravelNetworkNodes(ctx)
	
	local keepId, accessible, normalizedX,  normalizedY
	
	local name 
	
	for i=1,count do 
	
		keepId, accessible, normalizedX,  normalizedY = GetKeepTravelNetworkNodeInfo(i,ctx)
	
		name = GetKeepName(keepId)
		
		local node = {nodeIndex = keepId, zoneIndex = ZONE_INDEX_CYRODIIL, name=name ,known=accessible,normalizedX=normalizedX,normalizedY=normalizedY}
		
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

t.GetNodes = GetNodes
t.GetKnownNodes = GetKnownNodes

FasterTravel.Transitus = t 