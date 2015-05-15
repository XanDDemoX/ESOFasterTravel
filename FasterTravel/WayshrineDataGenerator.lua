
local function CreateNodesLookup(nodes,...)
	local count = select('#',...)
	local lookup ={}
	local key
	table.sort(nodes,function(x,y) return x.nodeIndex < y.nodeIndex end) 
	for i=1,count do
		key = select(i,...)
		lookup[key] = nodes[i]
	end 
	return lookup
end

local function UpdateLookup(lookup)

	-- corrections where names differ ={
	-- likely needs entries for other languages
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
	
	lookup["eyevea wayshrine"] = lookup["eyevea"]
	
	-- correction to handle multiple harboridges
	local harborage = lookup["the harborage"]
	if harborage ~= nil and harborage.nodes ~= nil then 
		-- not convinced order can be relied on >_<
		harborage.nodes = CreateNodesLookup(harborage.nodes,2,179,9)
	end
	
	return lookup
end 


local function UpdateNode(item,zoneIndex)
	if item ~= nil and zoneIndex ~= nil and item.nodes ~= nil then -- handle multiple nodes - a manual lookup is required >_<
		local node = item.nodes[zoneIndex]
		if node ~= nil then 
			item = Utils.extend(node) -- shallow copy 
			item.nodes = nil -- drop reference to nodes in copy 
		end 
	end 
	return item
end 


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
	
	lookup = UpdateLookup(lookup)
	
	return lookup
end

local function GetItemFromLookup(lookup,name,zoneIndex)
	if Utils.stringIsEmpty(name) == true then return nil end
	local item = lookup[string.lower(name)]
	
	item = UpdateNode(item,zoneIndex)
	
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
					item.poiIndex = i 
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

local function GetNodesZoneLookup(locations,func)
	func = func or GetNodesByZoneIndex
	local lookup ={}
	for i,loc in ipairs(locations) do 
		lookup[loc.zoneIndex] = Utils.toTable(func(loc.zoneIndex))
	end 
	return lookup
end


local function Generate(locations)
	local lookup = GetNodesZoneLookup(locations)
	
	local newLookup = {}
	
	for zoneIndex,nodes in pairs(lookup) do 
		newLookup[zoneIndex]={}
		for i,node in ipairs(nodes) do
			table.insert(newLookup[zoneIndex],{nodeIndex = node.nodeIndex, pIndex = node.poiIndex})
		end 
	end 
	return newLookup
end 

FasterTravel.WayshrineDataGenerator = {
	Generate = Generate
}
