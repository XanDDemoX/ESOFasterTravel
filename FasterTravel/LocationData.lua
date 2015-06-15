local Location = FasterTravel.Location
local Utils = FasterTravel.Utils
local Data = {}

local ALLIANCE_ALL = -2147483646
local ALLIANCE_SHARED = -2147483647
local ALLIANCE_WORLD = -2147483648

local _factionZoneOrderLookup = {

	[ALLIANCE_ALDMERI_DOMINION]={"khenarthisroost","auridon","grahtwood","greenshade","malabaltor","reapersmarch"},
	
	[ALLIANCE_DAGGERFALL_COVENANT]={"strosmkai","betnihk","glenumbra","stormhaven","rivenspire","alikr","bangkorai"},
	
	[ALLIANCE_EBONHEART_PACT]= {"bleakrock","balfoyen","stonefalls","deshaan","shadowfen","eastmarch","therift"},
	
	[ALLIANCE_ALL] = {"cyrodiil"},
	
	[ALLIANCE_SHARED] = {"coldharbor","craglorn","eyevea"},
	
	[ALLIANCE_WORLD] = {"tamriel","mundus"}
	
}

local _factionAllianceOrderLookup = {

	[ALLIANCE_ALDMERI_DOMINION] = {ALLIANCE_ALL, ALLIANCE_ALDMERI_DOMINION, ALLIANCE_EBONHEART_PACT, ALLIANCE_DAGGERFALL_COVENANT,},
	
	[ALLIANCE_DAGGERFALL_COVENANT] = {ALLIANCE_ALL,ALLIANCE_DAGGERFALL_COVENANT,  ALLIANCE_ALDMERI_DOMINION, ALLIANCE_EBONHEART_PACT,ALLIANCE_SHARED, ALLIANCE_WORLD  },
	
	[ALLIANCE_EBONHEART_PACT] ={ALLIANCE_ALL,ALLIANCE_EBONHEART_PACT,  ALLIANCE_DAGGERFALL_COVENANT, ALLIANCE_ALDMERI_DOMINION,ALLIANCE_SHARED, ALLIANCE_WORLD  }

}

local _factionAllianceIcons = {
	[ALLIANCE_ALDMERI_DOMINION]="/esoui/art/compass/ava_borderkeep_pin_aldmeri.dds",
	
	[ALLIANCE_DAGGERFALL_COVENANT]="/esoui/art/compass/ava_borderkeep_pin_daggerfall.dds",
	
	[ALLIANCE_EBONHEART_PACT]= "/esoui/art/compass/ava_borderkeep_pin_ebonheart.dds",
	
	[ALLIANCE_ALL] = "/esoui/art/compass/ava_3way.dds",
	
	[ALLIANCE_SHARED] = "/esoui/art/compass/ava_outpost_neutral.dds",
	
	[ALLIANCE_WORLD]= "/esoui/art/ava/ava_rankicon_palatine.dds"
}

-- generated locations list
local _locationsList = {
	[1] = 
	{
		["zoneIndex"] = -2147483648,
		["mapIndex"] = 1,
		["tile"] = "art/maps/tamriel/tamriel_0.dds",
	},
	[2] = 
	{
		["zoneIndex"] = 2,
		["mapIndex"] = 2,
		["tile"] = "art/maps/glenumbra/glenumbra_base_0.dds",
	},
	[3] = 
	{
		["zoneIndex"] = 5,
		["mapIndex"] = 3,
		["tile"] = "art/maps/rivenspire/rivenspire_base_0.dds",
	},
	[4] = 
	{
		["zoneIndex"] = 4,
		["mapIndex"] = 4,
		["tile"] = "art/maps/stormhaven/stormhaven_base_0.dds",
	},
	[5] = 
	{
		["zoneIndex"] = 18,
		["mapIndex"] = 5,
		["tile"] = "art/maps/alikr/alikr_base_0.dds",
	},
	[6] = 
	{
		["zoneIndex"] = 15,
		["mapIndex"] = 6,
		["tile"] = "art/maps/bangkorai/bangkorai_base_0.dds",
	},
	[7] = 
	{
		["zoneIndex"] = 181,
		["mapIndex"] = 7,
		["tile"] = "art/maps/grahtwood/grahtwood_base_0.dds",
	},
	[8] = 
	{
		["zoneIndex"] = 12,
		["mapIndex"] = 8,
		["tile"] = "art/maps/malabaltor/malabaltor_base_0.dds",
	},
	[9] = 
	{
		["zoneIndex"] = 20,
		["mapIndex"] = 9,
		["tile"] = "art/maps/shadowfen/shadowfen_base_0.dds",
	},
	[10] = 
	{
		["zoneIndex"] = 11,
		["mapIndex"] = 10,
		["tile"] = "art/maps/deshaan/deshaan_base_0.dds",
	},
	[11] = 
	{
		["zoneIndex"] = 9,
		["mapIndex"] = 11,
		["tile"] = "art/maps/stonefalls/stonefalls_base_0.dds",
	},
	[12] = 
	{
		["zoneIndex"] = 17,
		["mapIndex"] = 12,
		["tile"] = "art/maps/therift/therift_base_0.dds",
	},
	[13] = 
	{
		["zoneIndex"] = 16,
		["mapIndex"] = 13,
		["tile"] = "art/maps/eastmarch/eastmarch_base_0.dds",
	},
	[14] = 
	{
		["zoneIndex"] = 38,
		["mapIndex"] = 14,
		["tile"] = "art/maps/cyrodiil/ava_whole_0.dds",
	},
	[15] = 
	{
		["zoneIndex"] = 179,
		["mapIndex"] = 15,
		["tile"] = "art/maps/auridon/auridon_base_0.dds",
	},
	[16] = 
	{
		["zoneIndex"] = 19,
		["mapIndex"] = 16,
		["tile"] = "art/maps/greenshade/greenshade_base_0.dds",
	},
	[17] = 
	{
		["zoneIndex"] = 180,
		["mapIndex"] = 17,
		["tile"] = "art/maps/reapersmarch/reapersmarch_base_0.dds",
	},
	[18] = 
	{
		["zoneIndex"] = 111,
		["mapIndex"] = 18,
		["tile"] = "art/maps/stonefalls/balfoyen_base_0.dds",
	},
	[19] = 
	{
		["zoneIndex"] = 293,
		["mapIndex"] = 19,
		["tile"] = "art/maps/Glenumbra/strosmkai_base_0.dds",
	},
	[20] = 
	{
		["zoneIndex"] = 294,
		["mapIndex"] = 20,
		["tile"] = "art/maps/Glenumbra/betnihk_base_0.dds",
	},
	[21] = 
	{
		["zoneIndex"] = 295,
		["mapIndex"] = 21,
		["tile"] = "art/maps/auridon/khenarthisroost_base_0.dds",
	},
	[22] = 
	{
		["zoneIndex"] = 110,
		["mapIndex"] = 22,
		["tile"] = "art/maps/stonefalls/bleakrock_base_0.dds",
	},
	[23] = 
	{
		["zoneIndex"] = 155,
		["mapIndex"] = 23,
		["tile"] = "art/maps/coldharbor/coldharbour_base_0.dds",
	},
	[24] = 
	{
		["zoneIndex"] = -2147483648,
		["mapIndex"] = 24,
		["tile"] = "art/maps/tamriel/mundus_base_0.dds",
	},
	[25] = 
	{
		["zoneIndex"] = 353,
		["mapIndex"] = 25,
		["tile"] = "art/maps/craglorn/craglorn_base_0.dds",
	},
	[26] =
	{ -- manually added
		["zoneIndex"] = 100,
		["tile"] = "art/maps/guildmaps/eyevea_base_0.dds",
		["click"] = function()        
			zo_callLater(function() 
				ProcessMapClick(0.077777777777778,0.58395061728395)
				CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
			end,1)
		end
	}
}

local ZONE_INDEX_CYRODIIL = 38

local LocationOrder = {
	A_Z = 1,
	FACTION_A_Z = 2,
	FACTION_LEVEL = 3,
}

local LocationDirection = {
	ASCENDING = 1,
	DESCENDING = 2
}

local _locations
local _locationsLookup
local _zoneFactionLookup

local function GetMapZone(path)
	path = path or GetMapTileTexture()
	path = string.lower(path)
	local zone,subzone = string.match(path,"^.-/.-/(.-)/(.-)_")
	if zone == nil and subzone == nil then 
		-- splits if path is actually a zone key 
		zone,subzone = string.match(path,"^(.-)/(.-)$")
	end
	return zone,subzone
end

local function GetMapZoneKey(zone,subzone)
	if zone == nil and subzone == nil then 
		zone,subzone = GetMapZone()
	elseif subzone == nil then
		zone,subzone = GetMapZone(zone)
	end
	return table.concat({zone,"/",subzone}),zone,subzone
end

local function GetList()
	if _locations == nil then
		_locations = _locationsList
		for i,loc in ipairs(_locations) do
			loc.name = (loc.mapIndex~=nil and GetMapInfo(loc.mapIndex)) or GetZoneNameByIndex(loc.zoneIndex)
			loc.name = Utils.FormatStringCurrentLanguage(loc.name) -- cache not required as this as the locations list itself is a cache =)
			loc.key,loc.zone,loc.subzone = GetMapZoneKey(loc.tile)
		end
		table.sort(_locations,function(x,y)
			return x.name < y.name
		end)
	end 
	return _locations
end

local function CreateLocationsLookup(locations,func)
	local lookup = {}
	func = func or function(l) return l end 
	local item
	for i,loc in ipairs(locations) do 
		item = func(loc)
		
		lookup[loc.zoneIndex] = item
		lookup[loc.key] = item

		if lookup[loc.subzone] == nil then 
			lookup[loc.subzone] = item
		elseif lookup[loc.zone] == nil then 
			lookup[loc.zone] = item
		end
		
	end
	
	for i,loc in ipairs(locations) do 
		if lookup[loc.zone] == nil then 
			lookup[loc.zone] = lookup[loc.zoneIndex]
		end
	end
	
	return lookup
end

local function GetLookup()
	if _locationsLookup == nil then
		_locationsLookup = CreateLocationsLookup(GetList())
	end 
	return _locationsLookup
end

local function GetZoneLocation(lookup,zone,subzone)
	local loc
	
	if type(zone) == "number" then 
		loc = lookup[zone]
		zone = nil 
	end 
	if loc == nil then
		local key,zone,subzone = Location.Data.GetMapZoneKey(zone,subzone)
		
		-- try by zone/subzone key first
		loc = lookup[key]
		-- subzone next to handle places like khenarthis roost
		if loc == nil then
			loc = lookup[subzone]
		end
		-- then zone to handle locations within main zones which cannot be matched by key e.g coldharbor's hollow city
		if loc == nil then 
			loc = lookup[zone]
		end 
	end 

	-- if zone cant be found then return tamriel
	if loc == nil then 
		loc = lookup["tamriel"]
	end
	
	return loc
end

local function IsZoneIndexCyrodiil(zoneIndex)
	return zoneIndex == ZONE_INDEX_CYRODIIL
end

local function IsCyrodiil(loc)
	if loc == nil then return end 
	return IsZoneIndexCyrodiil(loc.zoneIndex)
end

local function GetZoneFactionLookup()

	local zoneLookup = GetLookup()
	
	if _zoneFactionLookup == nil then 
		local lookup = {}
		
		for faction,zones in pairs(_factionZoneOrderLookup) do
			for i,zone in ipairs(zones) do 
				lookup[zoneLookup[zone]] = faction
			end
		end
		
		_zoneFactionLookup = lookup
	end 
	
	return _zoneFactionLookup
end 

local function GetZoneFaction(loc)
	local lookup = GetZoneFactionLookup()
	return lookup[loc]
end 


local function GetAllianceZones(alliance, lookup,sortFunc)
	local zones = _factionZoneOrderLookup[alliance]
	zones = Utils.map(zones,function(key) return lookup[key] end)
	if sortFunc ~= nil then 
		table.sort(zones,sortFunc)
	end
	return zones
end

local function IsFactionWorldOrShared(faction)
	return faction == ALLIANCE_SHARED or faction == ALLIANCE_WORLD or faction == ALLIANCE_ALL
end

local function GetFactionOrderedList(faction,lookup,includeShared,sortFunc)

	local alliances = Utils.copy(_factionAllianceOrderLookup[faction])
	
	local zoneOrder
	
	local list = {}
	
	local zones
	
	for i,alliance in ipairs(alliances) do 
		if includeShared == false and IsFactionWorldOrShared(alliance) == true then 
		else
			zones = GetAllianceZones(alliance,lookup,sortFunc)
			Utils.copy(zones,list)
		end 
	end
	
	return list
end



local function GetDirectionValue(direction,x,y,value)
	if IsZoneIndexCyrodiil(x.zoneIndex) == true and IsZoneIndexCyrodiil(y.zoneIndex) == false then
		return true
	elseif IsZoneIndexCyrodiil(x.zoneIndex) == false and IsZoneIndexCyrodiil(y.zoneIndex) == true then 
		return false
	end
	if direction == LocationDirection.ASCENDING then return value 
	elseif direction == LocationDirection.DESCENDING then return not value 
	end 
end

local function AddSharedAndWorld(tbl,lookup,sortFunc)
	local shared = GetAllianceZones(ALLIANCE_SHARED,lookup)
	local world = GetAllianceZones(ALLIANCE_WORLD,lookup)
	
	local newtbl = {}
	
	Utils.copy(tbl,newtbl)
	Utils.copy(shared,newtbl)
	Utils.copy(world,newtbl)
	
	return newtbl
end

local _locationSortOrder = {
	[LocationOrder.A_Z] = function(direction,currentFaction)
		
		local list = Utils.copy(GetList())
		table.sort(list,function(x,y)
			return GetDirectionValue(direction,x,y,x.name < y.name)
		end)
		
		return list
	end,
	[LocationOrder.FACTION_A_Z] = function(direction,currentFaction) 
		local lookup = GetLookup()

		local tbl = GetFactionOrderedList(currentFaction, lookup, false, function(x,y) 
			return GetDirectionValue(direction,x,y,x.name < y.name)
		end)
		
		return AddSharedAndWorld(tbl,lookup)
	end, 
	[LocationOrder.FACTION_LEVEL] = function(direction,currentFaction)
		local lookup = GetLookup()
		
		local tbl = GetFactionOrderedList(currentFaction, lookup,false)
		
		if direction == LocationDirection.DESCENDING then 
			tbl = Utils.reverseTable(tbl)
		end 
		
		return AddSharedAndWorld(tbl,lookup)
	end
}

local function UpdateLocationOrder(locations,order,direction,...)
	local newList 
	
	local func = _locationSortOrder[order] 
	
	if func == nil then return end
	
	newList = func(direction,...)
	
	if newList == nil then return end
	for i = 1, #locations do
		locations[i] = nil
	end
	for i,v in ipairs(newList) do
		locations[#locations+1] = v 
	end 
end

local _sortOrders = {
	{id = LocationOrder.A_Z, text = "Alphabetical"},
	{id = LocationOrder.FACTION_A_Z, text = "Alliance A-Z"},
	{id = LocationOrder.FACTION_LEVEL, text = "Alliance Level"}
}

local _directionsAlphabetical = {{id = LocationDirection.ASCENDING, text = "A-Z"},{id = LocationDirection.DESCENDING, text = "Z-A"}}

local _directionsLevel = {{id = LocationDirection.ASCENDING, text = "1-v14"},{id = LocationDirection.DESCENDING, text = "v14-1"}}

local _sortDirections = {

	[LocationOrder.A_Z]=_directionsAlphabetical,
	[LocationOrder.FACTION_A_Z] = _directionsAlphabetical,
	[LocationOrder.FACTION_LEVEL] = _directionsLevel
}

local function GetSortOrders()
	return _sortOrders
end 

local function GetSortDirections(order)
	return _sortDirections[order] or _directionsAlphabetical
end 

local function GetZoneFactionIcon(loc)
	local faction = GetZoneFaction(loc)
	return _factionAllianceIcons[faction]
end

local d = Data

d.ZONE_INDEX_CYRODIIL = ZONE_INDEX_CYRODIIL

d.GetMapZoneKey = GetMapZoneKey
d.GetList = GetList
d.GetLookup = GetLookup
d.GetZoneLocation = GetZoneLocation
d.IsZoneIndexCyrodiil = IsZoneIndexCyrodiil
d.IsCyrodiil = IsCyrodiil
d.GetZoneFaction = GetZoneFaction
d.GetFactionOrderedList = GetFactionOrderedList
d.IsFactionWorldOrShared = IsFactionWorldOrShared
d.LocationOrder = LocationOrder
d.LocationDirection = LocationDirection
d.UpdateLocationOrder = UpdateLocationOrder

d.GetSortOrders = GetSortOrders
d.GetSortDirections = GetSortDirections

d.GetZoneFactionIcon = GetZoneFactionIcon

FasterTravel.Location.Data = d
	
	