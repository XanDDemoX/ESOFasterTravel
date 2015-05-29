local Location = FasterTravel.Location
local Utils = FasterTravel.Utils
local Data = {}
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

local _locations
local _locationsLookup

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

local d = Data
d.Initialise = Initialise
d.GetMapZoneKey = GetMapZoneKey
d.GetList = GetList
d.GetLookup = GetLookup
d.GetZoneLocation = GetZoneLocation

FasterTravel.Location.Data = d
	
	