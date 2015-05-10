
local QuestTracker = FasterTravel.class()

FasterTravel.QuestTracker = QuestTracker

local Location = FasterTravel.Location
local Wayshrine = FasterTravel.Wayshrine
local Quest = FasterTravel.Quest
local Utils = FasterTravel.Utils

local _questPinTextures ={
	[MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION] = "EsoUI/Art/Compass/quest_icon_assisted.dds",
	[MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/quest_icon_assisted.dds",
	[MAP_PIN_TYPE_ASSISTED_QUEST_ENDING] = "EsoUI/Art/Compass/quest_icon_assisted.dds",
	[MAP_PIN_TYPE_TRACKED_QUEST_CONDITION] = "EsoUI/Art/Compass/quest_icon.dds",
	[MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/quest_icon.dds",
	[MAP_PIN_TYPE_TRACKED_QUEST_ENDING] = "EsoUI/Art/Compass/quest_icon.dds",
}

local breadcrumbQuestPinTextures =
{
	[MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION] = "EsoUI/Art/Compass/quest_icon_door_assisted.dds",
	[MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/quest_icon_door_assisted.dds",
	[MAP_PIN_TYPE_ASSISTED_QUEST_ENDING] = "EsoUI/Art/Compass/quest_icon_door_assisted.dds",
	[MAP_PIN_TYPE_TRACKED_QUEST_CONDITION] = "EsoUI/Art/Compass/quest_icon_door.dds",
	[MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/quest_icon_door.dds",
	[MAP_PIN_TYPE_TRACKED_QUEST_ENDING] = "EsoUI/Art/Compass/quest_icon_door.dds",
}

local function GetQuestIconPath(quest)
	local pinType = quest.pinType
	if quest.isBreadcrumb then 
		return breadcrumbQuestPinTextures[pinType]
	else
		return _questPinTextures[pinType]
	end
end

local function GetQuestLocations(quest,callback)
	
	return Quest.GetQuestLocations(quest.index,function(result)
		callback(quest,result)
	end)
	
end

local function ClearIcons(lookup)
	for nodeIndex,row in pairs(lookup) do
		if type(row) == "table" then
			local data = row.data 
			if data ~= nil and data.iconHidden ~= nil then 
				data.iconHidden = nil 
				data.questIndexes = nil
			end
		end
	end
end

local function AddQuest(data, index)
	if data.questIndexes == nil then 
		data.questIndexes = {}
	end
	if data.questIndexes.table == nil then 
		data.questIndexes.table = {}
	end
	if data.questIndexes[index] == nil then
		table.insert(data.questIndexes.table,index)
		data.questIndexes[index] = index
	end
end

local function SetIcon(lookup,closest,result)
	local row = lookup[closest.nodeIndex]
	if row ~= nil then 
		local data = row.data 
		
		AddQuest(data,result.questIndex)
		
		if (data.iconHidden == nil or data.iconHidden == true) or result.assisted == true then  
			data.iconHidden = false
			data.iconPath = GetQuestIconPath(result)
			return true
		end
	end
	return false
end

local function UpdateLookups(closest,result,...)
	local count = select('#',...)
	local set = false 
	local lookup
	for i=1, count do 
		lookup = select(i,...)
		if SetIcon(lookup,closest,result) == true then 
			set = true 
		end 
	end 
	return set
end

local function IsValidResult(result)
	return result.hasPosition == true and result.insideBounds == true
end

local function RefreshCategories(categories,locations,locationsLookup,quests)

	local counts ={}
	
	for i,loc in ipairs(locations) do 
		categories[loc.zoneIndex].name = loc.name
	end 
	
	for i,quest in ipairs(quests) do 
		counts[quest.zoneIndex] = (counts[quest.zoneIndex] or 0) + 1
	end 
	
	for zoneIndex,count in pairs(counts) do
		local c =categories[zoneIndex] 
		if c ~= nil then 
			c.name = table.concat({locationsLookup[zoneIndex].name," (",tostring(count),")"})
		end
	end
	
end

local function RefreshQuests(locations,locationsLookup,tab)
	if locations == nil or tab == nil then return end

	local quests = Quest.GetQuests()
	
	local wayshrines = Wayshrine.GetKnownNodesZoneLookup(locations)

	local lookups = tab:GetRowLookups()
	
	if lookups == nil then return end 
	
	local curLookup = lookups.current
	local recLookup = lookups.recent
	local zoneLookup = lookups.zone
	
	if curLookup == nil or recLookup == nil or zoneLookup == nil then return end 
	
	local currentZoneIndex = tab:GetCurrentZoneMapIndexes()
	local loc = Location.GetZoneLocation(locationsLookup)
	
	if loc.zoneIndex == currentZoneIndex then
	
		ClearIcons(curLookup)
		
		for zoneIndex,lookup in pairs(zoneLookup) do
			ClearIcons(lookup)
		end
		
	else
		for zoneIndex,lookup in pairs(zoneLookup) do
			if zoneIndex ~= currentZoneIndex then 
				ClearIcons(lookup)
			end
		end
	end
			
	RefreshCategories(lookups.categories,locations,locationsLookup,quests)
	
	tab:RefreshControl(lookups.categoriesTable)
	
	local lookups = tab:GetRowLookups()

	local recentRowLookup = lookups.recent

	local currentRowLookup = lookups.current

	local zoneRowLookup = lookups.zone

	
	local curshrines = wayshrines[currentZoneIndex]
	local mapshrines = wayshrines[loc.zoneIndex]
	local questshrines
	
	for i,quest in ipairs(quests) do

		questshrines = wayshrines[quest.zoneIndex]

		Quest.GetQuestLocations(quest.index,function(result)
		
			if IsValidResult(result) == true then

				local closest 
				
				if questshrines ~= nil then
					closest = Location.GetClosestLocation(result.normalizedX,result.normalizedY,questshrines)
				elseif currentZoneIndex == loc.zoneIndex and result.insideCurrentMapWorld == true then
					closest = Location.GetClosestLocation(result.normalizedX,result.normalizedY,curshrines)
				elseif result.insideCurrentMapWorld == true then
					closest = Location.GetClosestLocation(result.normalizedX,result.normalizedY,mapshrines)
				end
				
				if closest ~= nil then 

					if UpdateLookups(closest,result,currentRowLookup,zoneRowLookup[closest.zoneIndex]) == true then
						tab:RefreshControl()
					end
					
				end
				
			end

		end)
			
	end
	
end

local function AddQuestToolTip(questIndex)
	local labels, width = ZO_WorldMapQuests_Shared_SetupQuestDetails(ZO_MapQuestDetailsTooltip, questIndex)

	for i,label in ipairs(labels) do 
		ZO_MapQuestDetailsTooltip:AddControl(label)
		label:SetAnchor(CENTER)
		ZO_MapQuestDetailsTooltip:AddVerticalPadding(-8)
	end
end

local CALLBACK_ID_ON_WORLDMAP_CHANGED = "OnWorldMapChanged"

local addCallback = FasterTravel.addCallback
local removeCallback = FasterTravel.removeCallback

function QuestTracker:init(locations,locationsLookup,tab)
	
	local _locations = locations
	local _locationsLookup = locationsLookup
	local _tab = tab
	
	local _refreshing = false
	
	local _isDirty = true 
	
	self.SetDirty = function(self)
		_isDirty = true
	end
	
	self.Refresh = function(self)
		if _refreshing == true then return end 
		RefreshQuests(_locations,_locationsLookup,_tab)
		_refreshing = false
	end
	
	self.RefreshIfRequired = function(self,...)
		if _refreshing == true or _isDirty == false then return end
		self:Refresh(...)
		_isDirty = false
	end
	
	tab.IconMouseEnter = FasterTravel.hook(tab.IconMouseEnter,function(base,control,icon,data) 
		base(control,icon,data)
		if data.questIndexes == nil or data.questIndexes.table == nil or #data.questIndexes.table == 0 then return end 
		
		InitializeTooltip(ZO_MapQuestDetailsTooltip, icon, RIGHT, -25)
		for i,index in ipairs(data.questIndexes.table) do 
			AddQuestToolTip(index)
		end 

	end)
	
	tab.IconMouseExit = FasterTravel.hook(tab.IconMouseExit,function(base,control,icon,data)
		base(control,icon,data)
		if data.questIndexes == nil then return end 
		ClearTooltip(ZO_MapQuestDetailsTooltip)
	end)
	
end
