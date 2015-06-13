
local Campaign = {}

local ZONE_INDEX_CYRODIIL = FasterTravel.Location.Data.ZONE_INDEX_CYRODIIL

local _campaignIcons = {
	home = "EsoUI/Art/Campaign/campaignBrowser_homeCampaign.dds",
	guest = "EsoUI/Art/Campaign/campaignBrowser_guestCampaign.dds"
}

local _populationFactionIcons = {
	"EsoUI/Art/Campaign/campaignBrowser_columnHeader_AD.dds",
	"EsoUI/Art/Campaign/campaignBrowser_columnHeader_EP.dds",
	"EsoUI/Art/Campaign/campaignBrowser_columnHeader_DC.dds"
}

local _populationFactionColors = {
function() return GetInterfaceColor(INTERFACE_COLOR_TYPE_ALLIANCE,ALLIANCE_ALDMERI_DOMINION) end ,
function() return GetInterfaceColor(INTERFACE_COLOR_TYPE_ALLIANCE,ALLIANCE_EBONHEART_PACT) end ,
function() return GetInterfaceColor(INTERFACE_COLOR_TYPE_ALLIANCE,ALLIANCE_DAGGERFALL_COVENANT) end
}

local function GetCampaignNodeInfo(id)
	if id == nil or id == 0 then return nil end 
	local rulesetId = GetCampaignRulesetId(id)
    local rulesetType = GetCampaignRulesetType(rulesetId)
	local rulesetName = GetCampaignRulesetName(rulesetId)
	local rulesetDesc = GetCampaignRulesetDescription(rulesetId)
	
	local node = { 
			id=id,
			name = zo_strformat(SI_CAMPAIGN_NAME, GetCampaignName(id)),
			group = GetNumSelectionCampaignGroupMembers(i),
			friends = GetNumSelectionCampaignFriends(i),
			guildies = GetNumSelectionCampaignGuildMembers(i),
			nodeIndex = id,
			zoneIndex = ZONE_INDEX_CYRODIIL,
			assigned = GetAssignedCampaignId() == id,
			guest = GetGuestCampaignId() == id,
			home = GetCurrentCampaignId() == id,
			isCampaign = true,
			rulesetId = rulesetId,
			rulesetType = rulesetType,
			rulesetName = rulesetName,
			rulesetDesc = rulesetDesc
		}
		
	return node 
end


local function GetCampaignPopulation(index)
	return {
		GetSelectionCampaignPopulationData(i, 1),
		GetSelectionCampaignPopulationData(i, 2),
		GetSelectionCampaignPopulationData(i, 3)
	}
end 

local function GetCampaignLookup()

	local count = GetNumSelectionCampaigns()
	
	local lookup = {}
	
	local id 
	
	local node 
	
	for i=1,count do 
		
		id = GetSelectionCampaignId(i)
		
		node = GetCampaignNodeInfo(id)
		
		node.population = GetCampaignPopulation(i)
		
		lookup[id] = node
		
	end 

	return lookup
end


local function GetPlayerCampaignsLookup()
	local nodes = {
		
		home = GetCurrentCampaignId(),
		guest = GetGuestCampaignId(),
		assigned = GetAssignedCampaignId()
	}
	
	local lookup = GetCampaignLookup()
	
	for k,v in pairs(nodes) do
		nodes[k] = lookup[k]
	end
	
	return nodes
end

local function GetPlayerCampaigns()
	
	local ids = {GetCurrentCampaignId(),GetGuestCampaignId()}
	
	local lookup = GetCampaignLookup()
	
	local nodes = {}
	local node
	
	for i,id in ipairs(ids) do
	
		node = lookup[id]
		if node ~= nil then 
			table.insert(nodes,node)
		end
	end
	
	if #nodes > 1 then 
		table.sort(nodes,function(x,y)
			return x.name < y.name
		end)
	end
	
	return nodes
end 

local function GetPopulationText(population)
	return GetString("SI_CAMPAIGNPOPULATIONTYPE", population)
end

local c = Campaign

c.ICON_ID_HOME = "home"
c.ICON_ID_GUEST = "guest"
c.ICONS_FACTION_POPULATION = _populationFactionIcons
c.COLOURS_FACTION_POPULATION = _populationFactionColors

c.GetIcon = function(key)
	return _campaignIcons[key]
end

c.GetPopulationText = GetPopulationText

c.GetPlayerCampaigns = GetPlayerCampaigns


FasterTravel.Campaign = c 