local Wayshrine = FasterTravel.Wayshrine
local Utils = FasterTravel.Utils
local Corrections = {}
Wayshrine.Corrections = Corrections


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

local c = Corrections
c.UpdateLookup = UpdateLookup
c.UpdateNode = UpdateNode