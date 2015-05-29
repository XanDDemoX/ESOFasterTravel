
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

local _breadcrumbQuestPinTextures =
{
	[MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION] = "EsoUI/Art/Compass/quest_icon_door_assisted.dds",
	[MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/quest_icon_door_assisted.dds",
	[MAP_PIN_TYPE_ASSISTED_QUEST_ENDING] = "EsoUI/Art/Compass/quest_icon_door_assisted.dds",
	[MAP_PIN_TYPE_TRACKED_QUEST_CONDITION] = "EsoUI/Art/Compass/quest_icon_door.dds",
	[MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/quest_icon_door.dds",
	[MAP_PIN_TYPE_TRACKED_QUEST_ENDING] = "EsoUI/Art/Compass/quest_icon_door.dds",
}

local _iconWidth = 25 
local _iconHeight = 25 

local function GetQuestIconPath(quest)
	local pinType = quest.pinType
	if quest.isBreadcrumb then 
		return _breadcrumbQuestPinTextures[pinType]
	else
		return _questPinTextures[pinType]
	end
end

local function ClearRowIcons(row)
	if row == nil then return end
	if type(row) == "table" then
		local data = row.data 
		if data ~= nil  then 
			if data.iconHidden ~= nil then 
				 data.iconHidden = nil
			end 
			
			if data.quests ~= nil then 
				data.quests = nil
			end
		end
	end
end

local function ClearNodeIndexIcons(nodeIndex,lookups)
	for i,lookup in ipairs(lookups) do
		ClearRowIcons(lookup[nodeIndex])
	end
end 

local function ClearIcons(lookup,...)
	local count = select('#',...)
	local lookups = count > 0 and {...}
	for nodeIndex,row in pairs(lookup) do
		ClearRowIcons(row)
		if lookups ~= nil then 
			ClearNodeIndexIcons(nodeIndex,lookups)
		end
	end
end

local function AddQuest(data, result ,iconWidth,iconHeight)

	local questIndex, stepIndex, conditionIndex,assisted = result.questIndex,result.stepIndex,result.conditionIndex,result.assisted

	if data.quests == nil then 
		data.quests = {}
	end
	
	local questInfo = data.quests[questIndex]
	
	if questInfo == nil then
		local name = GetJournalQuestInfo(questIndex)
		name = Utils.FormatStringCurrentLanguage(name)
		questInfo = { index = questIndex, steps = {}, name = name, assisted = assisted }
		data.quests[questIndex] = questInfo
	end

	local stepInfo = questInfo.steps[stepIndex]
	
	if stepInfo == nil then 
		stepInfo = {index = stepIndex, conditions = {}}
		questInfo.steps[stepIndex] = stepInfo
	end 
	
	if stepInfo.conditions[conditionIndex] == nil then 
		
		local text = GetJournalQuestConditionInfo(questIndex, stepIndex, conditionIndex)
		
		local iconPath = GetQuestIconPath(result)
		
		if iconPath ~= nil then 
			text = zo_iconTextFormat(iconPath,iconWidth,iconHeight,text)
		end
		
		stepInfo.conditions[conditionIndex] = text
	end
end

local function SetIcon(lookup,closest,result)
	if lookup == nil or closest == nil or result == nil then return false end 
	local row = lookup[closest.nodeIndex]
	if row ~= nil then 
		local data = row.data 

		AddQuest(data,result,_iconWidth,_iconHeight)
		
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
	if result == nil then return false end 
	return result.hasPosition == true and result.insideBounds == true
end

local function RefreshCategories(categories,locations,locationsLookup,quests)
	if categories == nil or locations == nil or locationsLookup == nil or quests == nil then return end 
	
	local counts ={}
	
	for i,loc in ipairs(locations) do 
		categories[loc.zoneIndex].name = loc.name
	end 
	
	for i,quest in ipairs(quests) do 
		counts[quest.zoneIndex] = (counts[quest.zoneIndex] or 0) + 1
	end 
	
	for zoneIndex,count in pairs(counts) do
		local c = categories[zoneIndex] 
		if c ~= nil then 
			c.name = table.concat({locationsLookup[zoneIndex].name," (",tostring(count),")"})
		end
	end
	
end

local function ClearQuestIcons(currentZoneIndex,loc,curLookup,zoneLookup,recLookup)

	if currentZoneIndex == nil or loc == nil or curLookup == nil or zoneLookup == nil then return end 

	if loc.zoneIndex == currentZoneIndex then
		ClearIcons(curLookup,recLookup)
	end
	
	ClearIcons(zoneLookup[loc.zoneIndex],recLookup)
end

local function RefreshQuests(currentZoneIndex,loc,tab,curLookup,zoneLookup,quests,wayshrines,recLookup)

	if currentZoneIndex == nil or loc == nil or tab == nil or curLookup == nil or zoneLookup == nil or quests == nil or wayshrines == nil then return end
	
	local mapshrines = wayshrines[loc.zoneIndex]
		
	for i,quest in ipairs(quests) do
	    -- always request where zoneIndex is nil
		if (quest.zoneIndex == nil or quest.zoneIndex == loc.zoneIndex) then 
			Quest.GetQuestLocations(quest.index,function(result)
			
				if IsValidResult(result) == true then

					local closest 
									
					if result.insideCurrentMapWorld == true then
						closest = Location.GetClosestLocation(result.normalizedX,result.normalizedY,mapshrines)
					end
					
					if closest ~= nil then 

						if UpdateLookups(closest,result,curLookup,zoneLookup[closest.zoneIndex],recLookup) == true then
							tab:RefreshControl()
						end
						
					end
					
				end

			end)
		end 
	end
	
end


local function AddTextToTooltip(tooltip,text,color)
	color = color or ZO_TOOLTIP_DEFAULT_COLOR
	tooltip:AddLine(text,"",color:UnpackRGB())
end

local function AddDividerToTooltip(tooltip)
	ZO_Tooltip_AddDivider(tooltip)
end

local function AddQuestTasksToTooltip(tooltip, quest)

	AddTextToTooltip(tooltip, quest.name,ZO_SELECTED_TEXT)
	
	local questIndex = quest.index
	
	local label
	
	for stepIndex,stepInfo in pairs(quest.steps) do 
	
		for conditionIndex,text in pairs(stepInfo.conditions) do 
			AddTextToTooltip(tooltip, text)
		end
	end 
end

local function AddRecallToTooltip(tooltip)
	local cost = GetRecallCost()
	local hasEnough = CURRENCY_HAS_ENOUGH
	if cost > GetCurrentMoney() then 
		hasEnough = CURRENCY_NOT_ENOUGH
	end
	tooltip:AddMoney(tooltip, cost, SI_TOOLTIP_RECALL_COST, hasEnough)
end

local function CreateQuestsTable(quests)
	
	local questTable = {}
	
	for index,quest in pairs(quests) do
		table.insert(questTable,quest)
	end 
	
	table.sort(questTable,function(x,y)
		if x.assisted == true then 
			return true
		elseif y.assisted == true then 
			return false 
		end
		return x.index < y.index
	end)
	
	return questTable
end

local function ShowToolTip(tooltip, control,data,offsetX,isRecall)
	InitializeTooltip(tooltip, control, RIGHT, offsetX)
	
	AddTextToTooltip(tooltip, data.name,ZO_SELECTED_TEXT)
	
	if isRecall == true then 
		AddRecallToTooltip(tooltip)
	end
	
	if data.quests == nil then return end 

	AddDividerToTooltip(tooltip)
	
	local first = true
	
	local questsTable = data.quests.table
	
	if questsTable == nil then 
		questsTable = CreateQuestsTable(data.quests)
		data.quests.table = questsTable
	end 

	for i,quest in ipairs(questsTable) do 
		if first == false then AddDividerToTooltip(tooltip) end
		AddQuestTasksToTooltip(tooltip, quest)
		first = false
	end 
end

local function HideToolTip(tooltip) 
	ClearTooltip(tooltip)
end 

local function ForceAssistAndPanToQuest(questIndex)
	ZO_WorldMap_PanToQuest(questIndex)
	QUEST_TRACKER:ForceAssist(questIndex)
end 

local function ShowQuestMenu(owner,data)
	ClearMenu()
	
	if data == nil or data.quests == nil or data.quests.table == nil then return end 
	
	local name
	local questIndex
	
	local quests = data.quests.table
	
	local count = #quests 
	
	if count == 1 then
	
		questIndex = quests[1].index
		
		ForceAssistAndPanToQuest(questIndex)
		
	elseif count > 1 then
		
		for i,quest in ipairs(quests) do 
			name = quest.name
			
			questIndex = quest.index
			
			AddMenuItem(name, function()
				ForceAssistAndPanToQuest(questIndex)
				ClearMenu()
			end)
		end 
		
		ShowMenu(owner)
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
		
		local lookups = _tab:GetRowLookups()
		
		local currentZoneIndex = _tab:GetCurrentZoneMapIndexes()
		
		local loc = Location.Data.GetZoneLocation(_locationsLookup)
			
		local curLookup,zoneLookup,recLookup = lookups.current,lookups.zone,lookups.recent
		
		self:HideToolTip()
		
		ClearQuestIcons(currentZoneIndex,loc,curLookup,zoneLookup,recLookup)
		
		local quests = Quest.GetQuests()
		
		RefreshCategories(lookups.categories,_locations,_locationsLookup,quests)
		
		_tab:RefreshControl(lookups.categoriesTable)
		
		local wayshrines = Wayshrine.GetKnownNodesZoneLookup(_locations)
		
		RefreshQuests(currentZoneIndex,loc,_tab,curLookup,zoneLookup,quests,wayshrines,recLookup)
		
		_refreshing = false
	end
	
	self.RefreshIfRequired = function(self,...)
		if _refreshing == true or _isDirty == false then return end
		self:Refresh(...)
		_isDirty = false
	end

	self.HideToolTip = function(self) HideToolTip(InformationTooltip) end 
	
	tab.IconMouseEnter = FasterTravel.hook(tab.IconMouseEnter,function(base,control,icon,data) 
		base(control,icon,data)
	
		ShowToolTip(InformationTooltip, icon,data,-25,tab:IsRecall())

	end)
	
	tab.IconMouseExit = FasterTravel.hook(tab.IconMouseExit,function(base,control,icon,data)
		base(control,icon,data)
		self:HideToolTip()
	end)
	
	tab.IconMouseClicked = FasterTravel.hook(tab.IconMouseClicked,function(base,control,icon,data)
		base(control,icon,data)
		ShowQuestMenu(control,data)
	end)
	
	tab.RowMouseEnter = FasterTravel.hook(tab.RowMouseEnter,function(base,control,row,label,data)
		base(control,row,label,data)
		
		ShowToolTip(InformationTooltip, row.icon,data,-25,tab:IsRecall())
	end)
	
	tab.RowMouseExit = FasterTravel.hook(tab.RowMouseExit,function(base,control,row,label,data)
		base(control,row,label,data)
		
		self:HideToolTip()
	end)
	
	tab.RowMouseClicked = FasterTravel.hook(tab.RowMouseClicked,function(base,control,row,data)
		base(control,row,data)
	end)
	
end
