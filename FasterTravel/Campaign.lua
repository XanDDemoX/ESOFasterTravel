
local Utils = FasterTravel.Utils

local Campaign = {}

local ZONE_INDEX_CYRODIIL = FasterTravel.Location.Data.ZONE_INDEX_CYRODIIL

local _campaignIcons = {
	home = "EsoUI/Art/Campaign/campaignBrowser_homeCampaign.dds",
	guest = "EsoUI/Art/Campaign/campaignBrowser_guestCampaign.dds",
	joining = "EsoUI/Art/Campaign/campaignBrowser_queued.dds"
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



local _alliances = {1,2,3}

local function GetSelectionCampaignPopulation(index)
	return Utils.map(_alliances,function(i)
		return GetSelectionCampaignPopulationData(index, i)
	end)
end 

local function GetSelectionCampaignTimesTable(index)
	local start,finish = GetSelectionCampaignTimes(index)
	return {start=start,finish=finish}
end


local function GetCampaignScores(id)

	local keepScore, resourceValue, outpostValue, defensiveScrollValue, offensiveScrollValue = GetCampaignHoldingScoreValues(id)
	local underdogLeaderAlliance = GetCampaignUnderdogLeaderAlliance(id)
	
	return Utils.map(_alliances,function(i)
		
		local score = GetCampaignAllianceScore(id, i)
        local keeps = GetTotalCampaignHoldings(id, HOLDINGTYPE_KEEP, i)
        local resources = GetTotalCampaignHoldings(id, HOLDINGTYPE_RESOURCE, i)
        local outposts = GetTotalCampaignHoldings(id, HOLDINGTYPE_OUTPOST, i)
        local defensiveScrolls = GetTotalCampaignHoldings(id, HOLDINGTYPE_DEFENSIVE_ARTIFACT, i)
        local offensiveScrolls = GetTotalCampaignHoldings(id, HOLDINGTYPE_OFFENSIVE_ARTIFACT, i)
        local potentialScore = GetCampaignAlliancePotentialScore(id, i)
        local isUnderpop = IsUnderpopBonusEnabled(id, i)

		return {
            alliance = i,
            score = score,
            keeps = keeps,
            resources = resources,
            outposts = outposts,
			offensiveScrolls = offensiveScrolls,
			defensiveScrolls = defensiveScrolls,
            scrolls = defensiveScrolls + offensiveScrolls,
            potentialScore = potentialScore,
            isUnderdog = underdogLeaderAlliance ~= 0 and underdogLeaderAlliance ~= i,
            isUnderpop = isUnderpop,
        }
	
	end)
  
end

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
			rulesetDesc = rulesetDesc,
			scores = GetCampaignScores(id)
		}
		
	return node 
end

local function UpdateWithSelectionCampainScores(index,scores)
	
	local underdogLeaderAlliance = GetSelectionCampaignUnderdogLeaderAlliance(index)

	return Utils.map(_alliances,function(i)
		local s = scores[i]
		s.score = GetSelectionCampaignAllianceScore(index,i)
		s.isUnderdog = underdogLeaderAlliance ~= 0 and underdogLeaderAlliance ~= i
		return s
	end)
end

local function GetCampaignLookup()

	local count = GetNumSelectionCampaigns()
	
	local lookup = {}
	
	local id 
	
	local node 
	
	for i=1,count do 
		
		id = GetSelectionCampaignId(i)
		
		node = GetCampaignNodeInfo(id)
		
		node.population = GetSelectionCampaignPopulation(i)
		
		node.times = GetSelectionCampaignTimesTable(i)
		
		UpdateWithSelectionCampainScores(i,node.scores)
		
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

local _nextRefresh = 0 
local _refreshTimeout = 60000
local _dirty = true 
local function SetDirty()
	_dirty = true
end

local function Refresh()
	QueryCampaignSelectionData()
end

local function RefreshIfRequired()
	if _dirty == true then 
		Refresh()
		_dirty = false
	end 
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

local function IsPlayerQueued(id,group)
	if group == true then 
		return IsQueuedForCampaign(id, CAMPAIGN_QUEUE_GROUP)
	elseif group == false then 
		return IsQueuedForCampaign(id, CAMPAIGN_QUEUE_INDIVIDUAL)
	end
	return IsQueuedForCampaign(id, CAMPAIGN_QUEUE_INDIVIDUAL) or IsQueuedForCampaign(id, CAMPAIGN_QUEUE_GROUP)
end

local function GetQueueState(id,group)
	if group == true then 
		return GetCampaignQueueState(id, CAMPAIGN_QUEUE_GROUP)
	else
		return GetCampaignQueueState(id, CAMPAIGN_QUEUE_INDIVIDUAL)
	end 
end

local function IsQueueState(id,state)
	return GetQueueState(id,false) == state or GetQueueState(id,true) == state
end 

local function IsGroupOnline()
	local count = GetGroupSize()
	
	local pChar = string.lower(GetUnitName("player"))
	
	for i = 1, count do 
		local unitTag = GetGroupUnitTagByIndex(i)
		local unitName = GetUnitName(unitTag)

		if unitTag ~= nil and IsUnitOnline(unitTag) == true and string.lower(unitName) ~= pChar then 
			return true
		end
	end
	
	return false 
end

local function CanQueue(id,group)
	group = group or 0 
	
    local canQueueIndividual = false
    local canQueueGroup = false
	
	if(GetCurrentCampaignId() ~= id and DoesPlayerMeetCampaignRequirements(id)) then
		if(GetAssignedCampaignId() == id or GetGuestCampaignId() == id) then
			canQueueIndividual = not IsQueuedForCampaign(id, CAMPAIGN_QUEUE_INDIVIDUAL)
			if(not IsQueuedForCampaign(id, CAMPAIGN_QUEUE_GROUP)) then
				if(IsUnitGrouped("player") and IsUnitGroupLeader("player") ) then
					canQueueGroup = IsGroupOnline()
				end
			end        
		end
	end

    return canQueueIndividual, canQueueGroup
	
end

local function EnterQueue(id,name,group)

	local canQueueIndividual, canQueueGroup = CanQueue(id)
	
	if canQueueIndividual == true and canQueueGroup == true  then
		ZO_Dialogs_ShowDialog("CAMPAIGN_QUEUE", {campaignId = id}, {mainTextParams = {name}})
	elseif canQueueGroup == true then
		QueueForCampaign(id, CAMPAIGN_QUEUE_GROUP)
	elseif canQueueIndividual == true then 
		QueueForCampaign(id, CAMPAIGN_QUEUE_INDIVIDUAL)
	end
	
end

local function EnterLeaveOrJoin(id,name,group,isGroup)
	if IsPlayerQueued(id) == true then
		
		local state = GetQueueState(id,isGroup)
		if state == CAMPAIGN_QUEUE_REQUEST_STATE_WAITING then 
			LeaveCampaignQueue(id, isGroup)
		elseif state == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING then 
			ZO_Dialogs_ReleaseDialog("CAMPAIGN_QUEUE_READY")
			ZO_Dialogs_ShowDialog("CAMPAIGN_QUEUE_READY", {campaignId = id, isGroup = isGroup}, {mainTextParams = {name}})
			--ConfirmCampaignEntry(id, isGroup, false)
		end
	else
		return EnterQueue(id,name,group)
	end 

end



local c = Campaign

c.FACTION_IDS = _alliances

c.ICON_ID_HOME = "home"
c.ICON_ID_GUEST = "guest"
c.ICON_ID_JOINING = "joining"
c.ICONS_FACTION_POPULATION = _populationFactionIcons
c.COLOURS_FACTION_POPULATION = _populationFactionColors

c.GetIcon = function(key)
	return _campaignIcons[key]
end

c.GetPopulationText = GetPopulationText

c.GetPlayerCampaigns = GetPlayerCampaigns
c.IsPlayerQueued = IsPlayerQueued
c.GetQueueState = GetQueueState
c.IsQueueState = IsQueueState
c.EnterLeaveOrJoin =  EnterLeaveOrJoin

c.SetDirty = SetDirty
c.RefreshIfRequired = RefreshIfRequired

FasterTravel.Campaign = c 