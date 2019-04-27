local Location = FasterTravel.Location
local Utils = FasterTravel.Utils
local Data = {}

local ALLIANCE_ALL = -2147483646
local ALLIANCE_SHARED = -2147483647
local ALLIANCE_WORLD = -2147483648

local _factionZoneOrderLookup = {
	[ALLIANCE_ALDMERI_DOMINION] = {
		"khenarthisroost","auridon","grahtwood","greenshade","malabaltor","reapersmarch"
	},
	[ALLIANCE_DAGGERFALL_COVENANT] = {
		"strosmkai","betnihk","glenumbra","stormhaven","rivenspire","alikr","bangkorai"
	},
	[ALLIANCE_EBONHEART_PACT] = {
		"bleakrock","balfoyen","stonefalls","deshaan","shadowfen","eastmarch","therift"
	},
	[ALLIANCE_ALL] = { "cyrodiil" },
	[ALLIANCE_SHARED] = {
		"coldharbor", "craglorn", "eyevea", "artaeum", "clockwork", "brassfortress", "imperialcity",
		"summerset", "vvardenfell", "hewsbane", "goldcoast", "wrothgar", "norgtzel"
	},
	[ALLIANCE_WORLD] = { "tamriel", "mundus" }
}

local _factionAllianceOrderLookup = {
	[ALLIANCE_ALDMERI_DOMINION] = {
		ALLIANCE_ALL, ALLIANCE_ALDMERI_DOMINION,
		ALLIANCE_EBONHEART_PACT, ALLIANCE_DAGGERFALL_COVENANT, ALLIANCE_SHARED, ALLIANCE_WORLD
	},
	[ALLIANCE_DAGGERFALL_COVENANT] = {
		ALLIANCE_ALL, ALLIANCE_DAGGERFALL_COVENANT,
		ALLIANCE_ALDMERI_DOMINION, ALLIANCE_EBONHEART_PACT, ALLIANCE_SHARED, ALLIANCE_WORLD
	},
	[ALLIANCE_EBONHEART_PACT] = {
		ALLIANCE_ALL, ALLIANCE_EBONHEART_PACT,
		ALLIANCE_DAGGERFALL_COVENANT, ALLIANCE_ALDMERI_DOMINION, ALLIANCE_SHARED, ALLIANCE_WORLD
	}
}

local _factionAllianceIcons = {
	[ALLIANCE_ALDMERI_DOMINION] = "/esoui/art/compass/ava_borderkeep_pin_aldmeri.dds",
	[ALLIANCE_DAGGERFALL_COVENANT] = "/esoui/art/compass/ava_borderkeep_pin_daggerfall.dds",
	[ALLIANCE_EBONHEART_PACT] = "/esoui/art/compass/ava_borderkeep_pin_ebonheart.dds",
	[ALLIANCE_ALL] = "/esoui/art/compass/ava_3way.dds",
	[ALLIANCE_SHARED] = "/esoui/art/compass/ava_outpost_neutral.dds",
	[ALLIANCE_WORLD] = "/esoui/art/ava/ava_rankicon_palatine.dds"
}

-- generated locations list
local _locationsList = {
	{["subzone"] = "tamriel",			["zone"] = "tamriel",			["name"] = "Tamriel",			["key"] = "tamriel/tamriel",			["zoneIndex"] = -2147483648,	["mapIndex"] = 1,	["tile"] = "art/maps/tamriel/tamriel_0.dds",				},
	{["subzone"] = "glenumbra",			["zone"] = "glenumbra",			["name"] = "Glenumbra",			["key"] = "glenumbra/glenumbra",		["zoneIndex"] = 2,				["mapIndex"] = 2,	["tile"] = "art/maps/glenumbra/glenumbra_base_0.dds",		},
	{["subzone"] = "rivenspire",		["zone"] = "rivenspire",		["name"] = "Rivenspire",		["key"] = "rivenspire/rivenspire",		["zoneIndex"] = 5,				["mapIndex"] = 3,	["tile"] = "art/maps/rivenspire/rivenspire_base_0.dds",		},
	{["subzone"] = "stormhaven",		["zone"] = "stormhaven",		["name"] = "Stormhaven",		["key"] = "stormhaven/stormhaven",		["zoneIndex"] = 4,				["mapIndex"] = 4,	["tile"] = "art/maps/stormhaven/stormhaven_base_0.dds",		},
	{["subzone"] = "alikr",				["zone"] = "alikr",				["name"] = "Alik'r Desert",		["key"] = "alikr/alikr",				["zoneIndex"] = 17,				["mapIndex"] = 5,	["tile"] = "art/maps/alikr/alikr_base_0.dds",				},
	{["subzone"] = "bangkorai",			["zone"] = "bangkorai",			["name"] = "Bangkorai",			["key"] = "bangkorai/bangkorai",		["zoneIndex"] = 14,				["mapIndex"] = 6,	["tile"] = "art/maps/bangkorai/bangkorai_base_0.dds",		},
	{["subzone"] = "grahtwood",			["zone"] = "grahtwood",			["name"] = "Grahtwood",			["key"] = "grahtwood/grahtwood",		["zoneIndex"] = 180,			["mapIndex"] = 7,	["tile"] = "art/maps/grahtwood/grahtwood_base_0.dds",		},
	{["subzone"] = "malabaltor",		["zone"] = "malabaltor",		["name"] = "Malabal Tor",		["key"] = "malabaltor/malabaltor",		["zoneIndex"] = 11,				["mapIndex"] = 8,	["tile"] = "art/maps/malabaltor/malabaltor_base_0.dds",		},
	{["subzone"] = "shadowfen",			["zone"] = "shadowfen",			["name"] = "Shadowfen",			["key"] = "shadowfen/shadowfen",		["zoneIndex"] = 19,				["mapIndex"] = 9,	["tile"] = "art/maps/shadowfen/shadowfen_base_0.dds",		},
	{["subzone"] = "deshaan",			["zone"] = "deshaan",			["name"] = "Deshaan",			["key"] = "deshaan/deshaan",			["zoneIndex"] = 10,				["mapIndex"] = 10,	["tile"] = "art/maps/deshaan/deshaan_base_0.dds",			},
	{["subzone"] = "stonefalls",		["zone"] = "stonefalls",		["name"] = "Stonefalls",		["key"] = "stonefalls/stonefalls",		["zoneIndex"] = 9,				["mapIndex"] = 11,	["tile"] = "art/maps/stonefalls/stonefalls_base_0.dds",		},
	{["subzone"] = "therift",			["zone"] = "therift",			["name"] = "The Rift",			["key"] = "therift/therift",			["zoneIndex"] = 16,				["mapIndex"] = 12,	["tile"] = "art/maps/therift/therift_base_0.dds",			},
	{["subzone"] = "eastmarch",			["zone"] = "eastmarch",			["name"] = "Eastmarch",			["key"] = "eastmarch/eastmarch",		["zoneIndex"] = 15,				["mapIndex"] = 13,	["tile"] = "art/maps/eastmarch/eastmarch_base_0.dds",		},
	{["subzone"] = "ava",				["zone"] = "cyrodiil",			["name"] = "Cyrodiil",			["key"] = "cyrodiil/ava",				["zoneIndex"] = 37,				["mapIndex"] = 14,	["tile"] = "art/maps/cyrodiil/ava_whole_0.dds",				},
	{["subzone"] = "auridon",			["zone"] = "auridon",			["name"] = "Auridon",			["key"] = "auridon/auridon",			["zoneIndex"] = 178,			["mapIndex"] = 15,	["tile"] = "art/maps/auridon/auridon_base_0.dds",			},
	{["subzone"] = "greenshade",		["zone"] = "greenshade",		["name"] = "Greenshade",		["key"] = "greenshade/greenshade",		["zoneIndex"] = 18,				["mapIndex"] = 16,	["tile"] = "art/maps/greenshade/greenshade_base_0.dds",		},
	{["subzone"] = "reapersmarch",		["zone"] = "reapersmarch",		["name"] = "Reaper's March",	["key"] = "reapersmarch/reapersmarch",	["zoneIndex"] = 179,			["mapIndex"] = 17,	["tile"] = "art/maps/reapersmarch/reapersmarch_base_0.dds",	},
	{["subzone"] = "balfoyen",			["zone"] = "stonefalls",		["name"] = "Bal Foyen",			["key"] = "stonefalls/balfoyen",		["zoneIndex"] = 110,			["mapIndex"] = 18,	["tile"] = "art/maps/stonefalls/balfoyen_base_0.dds",		},
	{["subzone"] = "strosmkai",			["zone"] = "glenumbra",			["name"] = "Stros M'Kai",		["key"] = "glenumbra/strosmkai",		["zoneIndex"] = 299,			["mapIndex"] = 19,	["tile"] = "art/maps/Glenumbra/strosmkai_base_0.dds",		},
	{["subzone"] = "betnihk",			["zone"] = "glenumbra",			["name"] = "Betnikh",			["key"] = "glenumbra/betnihk",			["zoneIndex"] = 300,			["mapIndex"] = 20,	["tile"] = "art/maps/Glenumbra/betnihk_base_0.dds",			},
	{["subzone"] = "khenarthisroost",	["zone"] = "auridon",			["name"] = "Khenarthi's Roost",	["key"] = "auridon/khenarthisroost",	["zoneIndex"] = 301,			["mapIndex"] = 21,	["tile"] = "art/maps/auridon/khenarthisroost_base_0.dds",	},
	{["subzone"] = "bleakrock",			["zone"] = "stonefalls",		["name"] = "Bleakrock Isle",	["key"] = "stonefalls/bleakrock",		["zoneIndex"] = 109,			["mapIndex"] = 22,	["tile"] = "art/maps/stonefalls/bleakrock_base_0.dds",		},
	{["subzone"] = "coldharbour",		["zone"] = "coldharbor",		["name"] = "Coldharbour",		["key"] = "coldharbor/coldharbour",		["zoneIndex"] = 154,			["mapIndex"] = 23,	["tile"] = "art/maps/coldharbor/coldharbour_base_0.dds",	},
	{["subzone"] = "mundus",			["zone"] = "tamriel",			["name"] = "The Aurbis",		["key"] = "tamriel/mundus",				["zoneIndex"] = -2147483648,	["mapIndex"] = 24,	["tile"] = "art/maps/tamriel/mundus_base_0.dds",			},
	{["subzone"] = "craglorn",			["zone"] = "craglorn",			["name"] = "Craglorn",			["key"] = "craglorn/craglorn",			["zoneIndex"] = 526,			["mapIndex"] = 25,	["tile"] = "art/maps/craglorn/craglorn_base_0.dds",			},
	{["subzone"] = "imperialcity",		["zone"] = "cyrodiil",			["name"] = "Imperial City",		["key"] = "cyrodiil/imperialcity",		["zoneIndex"] = 341,			["mapIndex"] = 26,	["tile"] = "art/maps/cyrodiil/imperialcity_base_0.dds",		},
	{["subzone"] = "wrothgar",			["zone"] = "wrothgar",			["name"] = "Wrothgar",			["key"] = "wrothgar/wrothgar",			["zoneIndex"] = 374,			["mapIndex"] = 27,	["tile"] = "art/maps/wrothgar/wrothgar_base_0.dds",			},
	{["subzone"] = "hewsbane",			["zone"] = "thievesguild",		["name"] = "Hew's Bane",		["key"] = "thievesguild/hewsbane",		["zoneIndex"] = 468,			["mapIndex"] = 28,	["tile"] = "art/maps/thievesguild/hewsbane_base_0.dds",		},
	{["subzone"] = "goldcoast",			["zone"] = "darkbrotherhood",	["name"] = "Gold Coast",		["key"] = "darkbrotherhood/goldcoast",	["zoneIndex"] = 474,			["mapIndex"] = 29,	["tile"] = "art/maps/darkbrotherhood/goldcoast_base_0.dds",	},
	{["subzone"] = "vvardenfell",		["zone"] = "vvardenfell",		["name"] = "Vvardenfell",		["key"] = "vvardenfell/vvardenfell",	["zoneIndex"] = 493,			["mapIndex"] = 30,	["tile"] = "art/maps/vvardenfell/vvardenfell_base_0.dds",	},
	{["subzone"] = "clockwork",			["zone"] = "clockwork",			["name"] = "Clockwork City",	["key"] = "clockwork/clockwork",		["zoneIndex"] = 618,			["mapIndex"] = 31,	["tile"] = "art/maps/clockwork/clockwork_base_0.dds",		},
	{["subzone"] = "brassfortress",		["zone"] = "clockwork",			["name"] = "The Brass Fortress",["key"] = "clockwork/brassfortress",	["zoneIndex"] = 619,			["mapIndex"] = nil,	["tile"] = "art/maps/clockwork/brassfortress_base_0.dds",	},
	{["subzone"] = "summerset",			["zone"] = "summerset",			["name"] = "Summerset",			["key"] = "summerset/summerset",		["zoneIndex"] = 642,			["mapIndex"] = 32,	["tile"] = "art/maps/summerset/summerset_base_0.dds",		},
	{["subzone"] = "artaeum",			["zone"] = "summerset",			["name"] = "Artaeum",			["key"] = "summerset/artaeum",			["zoneIndex"] = 658,			["mapIndex"] = 33,	["tile"] = "art/maps/summerset/artaeum_base_0.dds",			},
	{["subzone"] = "norgtzel",			["zone"] = "norgtzel",			["name"] = "Norg-Tzel",			["key"] = "norgtzel/norgtzel",			["zoneIndex"] = 687,			["mapIndex"] = 34,	["tile"] = "art/maps/norgtzel/norgtzel_base_0.dds",			},
	{ -- manually added
		["zoneIndex"] = 99,
		["tile"] = "art/maps/guildmaps/eyevea_base_0.dds",
		["click"] = function()
			zo_callLater(function()
				ProcessMapClick(0.077777777777778,0.58395061728395)
				CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
			end,1)
		end
	}
}

local ZONE_INDEX_CYRODIIL = 37

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
			loc.name = loc.mapIndex ~= nil and GetMapInfo(loc.mapIndex) or GetZoneNameByIndex(loc.zoneIndex)
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

local function GetFactionOrderedList(faction,lookup,args)
	args = args or {}
	local zoneSortFunc = args.zoneSortFunc
	local allianceSortFunc = args.allianceSortFunc
	local transform = args.transform
	local alliances = Utils.copy(_factionAllianceOrderLookup[faction])
	if allianceSortFunc ~= nil then
		table.sort(alliances,allianceSortFunc)
	end
	local list = {}
	local zones
	for i,alliance in ipairs(alliances) do
		zones = GetAllianceZones(alliance,lookup,zoneSortFunc)
		if transform ~= nil then
			zones = transform(alliance,zones) or {}
		end
		Utils.copy(zones,list)
	end
	return list
end

local function RemoveArticle(name)
	local r = name
	return string.gsub(r, "^The ", "", 1)
end

local function GetDirectionValue(direction,x,y)
	-- Cyrodiil sorts before other zones
	if IsZoneIndexCyrodiil(x.zoneIndex) and not IsZoneIndexCyrodiil(y.zoneIndex) then
		return true
	elseif IsZoneIndexCyrodiil(y.zoneIndex) then
		return false
	elseif direction == LocationDirection.ASCENDING then
		return RemoveArticle(x.name) < RemoveArticle(y.name)
	elseif direction == LocationDirection.DESCENDING then
		return RemoveArticle(y.name) < RemoveArticle(x.name)
	end
end

local function AddSharedAndWorld(tbl,lookup,sortFunc)
	local shared = GetAllianceZones(ALLIANCE_SHARED,lookup)
	local world = GetAllianceZones(ALLIANCE_WORLD,lookup)
	local newtbl = {}
	Utils.copy(tbl,    newtbl)
	Utils.copy(shared, newtbl)
	Utils.copy(world,  newtbl)
	return newtbl
end

local _locationSortOrder = {
	[LocationOrder.A_Z] = function(direction,currentFaction)
		local list = Utils.copy(GetList())
		table.sort(list,function(x,y)
			return GetDirectionValue(direction,x,y)
		end)
		return list
	end,
	[LocationOrder.FACTION_A_Z] = function(direction,currentFaction)
		local lookup = GetLookup()
		local tbl = GetFactionOrderedList(currentFaction, lookup, {
			zoneSortFunc = function(x,y)
				return GetDirectionValue(direction,x,y)
			end
		})
		return tbl
	end,
	[LocationOrder.FACTION_LEVEL] = function(direction,currentFaction)
		local lookup = GetLookup()
		local tbl = GetFactionOrderedList(currentFaction, lookup, {
			transform = function(alliance,zones)
				if direction == LocationDirection.DESCENDING and IsFactionWorldOrShared(alliance) == false and alliance ~= ALLIANCE_ALL then
					return Utils.reverseTable(zones)
				end
				return zones
			end
		})
		return tbl
	end
}

local function UpdateLocationOrder(locations,order,direction,...)
	local newList
	local func = _locationSortOrder[order]
	if func ~= nil then
		newList = func(direction,...)
		if newList ~= nil then
			for i = 1, #locations do
				locations[i] = nil
			end
			for i,v in ipairs(newList) do
				locations[#locations+1] = v
			end
		end
	end
end

local _sortOrders = {
	{id = LocationOrder.A_Z, text = GetString(SI_CHAT_CHANNEL_NAME_ZONE)},
	{id = LocationOrder.FACTION_A_Z, text = GetString(SI_CAMPAIGNLEADERBOARDTYPE2)},
	{id = LocationOrder.FACTION_LEVEL, text = GetString(SI_FRIENDS_LIST_PANEL_TOOLTIP_LEVEL)}
}

local _directionsAlphabetical = {
	{ id = LocationDirection.ASCENDING, text = "A-Z" },
	{ id = LocationDirection.DESCENDING, text = "Z-A" }
}

local _directionsLevel = {
	{ id = LocationDirection.ASCENDING, text = "1-v14" },
	{ id = LocationDirection.DESCENDING, text = "v14-1" }
}

local _sortDirections = {
	[LocationOrder.A_Z] = _directionsAlphabetical,
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

