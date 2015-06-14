
local Transitus = {}

local Utils = FasterTravel.Utils
local ZONE_INDEX_CYRODIIL = FasterTravel.Location.Data.ZONE_INDEX_CYRODIIL

local function GetNodeInfo(ctx,nodeIndex)
		
	local keepId, accessible, normalizedX,  normalizedY = GetKeepTravelNetworkNodeInfo(nodeIndex,ctx)
		
	local pinType,nx,ny  = GetKeepPinInfo(keepId, ctx)
	
	if normalizedX == 0 and normalizedY == 0 then 
		normalizedX,normalizedY = nx,ny
	end 
	
	local name  = GetKeepName(keepId)
	
	local alliance =  GetKeepAlliance(keepId,ctx)
	
	accessible = accessible or GetKeepAccessible(keepId,ctx)
	
	local node = {nodeIndex = keepId, zoneIndex = ZONE_INDEX_CYRODIIL, name=name ,known=accessible,alliance=alliance,normalizedX=normalizedX,normalizedY=normalizedY, isTransitus = true, pinType=pinType}
	
	return node
end

local function GetNodes(ctx)
	
	ZO_WorldMap_RefreshKeeps()
	
	ctx = ctx or ZO_WorldMap_GetBattlegroundQueryType()

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

local function GetKnownNodes(nodeIndex,known,ctx)

	local nodes = GetNodes(ctx)

	local alliance = GetUnitAlliance("player")
	
	nodes = Utils.where(nodes,function(node) 
		return (known == nil or node.known == known) and node.alliance == alliance and (nodeIndex == nil or node.nodeIndex ~= nodeIndex) 
	end)
	
	return nodes
end

local t = Transitus

t.GetNodeInfo = GetNodeInfo
t.GetNodes = GetNodes
t.GetKnownNodes = GetKnownNodes

FasterTravel.Transitus = t 