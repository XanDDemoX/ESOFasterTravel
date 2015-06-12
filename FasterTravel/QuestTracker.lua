
local QuestTracker = FasterTravel.class()

FasterTravel.QuestTracker = QuestTracker

local Location = FasterTravel.Location
local Wayshrine = FasterTravel.Wayshrine
local Transitus = FasterTravel.Transitus
local Quest = FasterTravel.Quest
local WorldMap = FasterTravel.WorldMap
local Utils = FasterTravel.Utils

local Timer = FasterTravel.Timer

local GetPinTypeIconPath = WorldMap.GetPinTypeIconPath
local GetQuestIconPath = WorldMap.GetQuestIconPath
local ConvertPinType = WorldMap.ConvertPinType

local _iconWidth = 28 
local _iconHeight = 28 

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

	local questIndex, stepIndex, conditionIndex,assisted,zoneIndex = result.questIndex,result.stepIndex,result.conditionIndex,result.assisted, result.zoneIndex

	if data.quests == nil then 
		data.quests = {}
	end
	
	local questInfo = data.quests[questIndex]
	
	if questInfo == nil then
		local name = GetJournalQuestInfo(questIndex)
		name = Utils.FormatStringCurrentLanguage(name)
		questInfo = { index = questIndex, steps = {}, name = name, assisted = assisted, zoneIndex = zoneIndex,
					 setAssisted = function(self,value)
						self.path = nil
						self.assisted = value
						for stepIndex,step in pairs(self.steps) do
							for conditionIndex, condition in pairs(step.conditions) do
								condition:setAssisted(value)
								if self.path == nil then
									self.path = condition.path
								end
							end
						end
						
						
					 end
		}
		data.quests[questIndex] = questInfo
	end

	local stepInfo = questInfo.steps[stepIndex]
	
	if stepInfo == nil then 
		stepInfo = {index = stepIndex, conditions = {}}
		questInfo.steps[stepIndex] = stepInfo
	end 
	
	if stepInfo.conditions[conditionIndex] == nil then 
		
		local text = GetJournalQuestConditionInfo(questIndex, stepIndex, conditionIndex)
		
		local iconPath,pinType,textures = GetQuestIconPath(result)
		
		local condition = {
							text="",
							setAssisted = function(self,assisted)
								local path = GetPinTypeIconPath(textures,ConvertPinType(pinType,assisted))
								self.path = path
								self.text = zo_iconTextFormat(path,iconWidth,iconHeight,text)
							end
						}
		condition:setAssisted(result.assisted)
		stepInfo.conditions[conditionIndex] = condition
											
	end
end

local function SetIcon(data,path,hidden)
	if data == nil then return false end 
	
	hidden = hidden or (path == nil or path == "")
	
	data.iconPath = path
	
	data.iconHidden = hidden
	
	return true 
end

local function SetQuestIcon(data,closest,result)

	if data == nil or closest == nil or result == nil then return false end 
	
	if (data.iconHidden == nil or data.iconHidden == true) or result.assisted == true then  
		
		local iconPath,pinType,textures = GetQuestIconPath(result)
		
		data.setAssisted = data.setAssisted or function(self,questIndex)
			if self.quests == nil then return end 
			
			for idx,q in pairs(self.quests) do
				if q.setAssisted ~= nil then 
					q:setAssisted(idx == questIndex)
				end
			end
		
			local quest = self.quests[questIndex]
			if quest ~= nil then 
				self.iconPath = quest.path
			else
				self.iconPath = GetPinTypeIconPath(textures,ConvertPinType(pinType,false))
			end
		end
		
		return SetIcon(data,iconPath)
	end
	
	return false

end


local function UpdateLookups(closest,result,...)

	result.zoneIndex = result.zoneIndex or closest.zoneIndex

	local count = select('#',...)
	local set = false 
	local lookup
	
	local row,data 
	
	for i=1, count do 
		lookup = select(i,...)
		
		row = lookup[closest.nodeIndex]
		
		if row ~= nil then
		
			data = row.data 
			
			AddQuest(data,result,_iconWidth,_iconHeight)
			
			if SetQuestIcon(data,closest,result) == true then 
				set = true 
			end 
			
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

local function IsQuestValidForZone(quest,loc)
 local zoneIndex,questType = quest.zoneIndex,quest.questType
 return zoneIndex == loc.zoneIndex or (questType == QUEST_TYPE_MAIN_STORY or questType == QUEST_TYPE_CRAFTING)
end

local function RefreshQuests(loc,tab,curLookup,zoneLookup,quests,wayshrines,recLookup)

	if loc == nil or tab == nil or curLookup == nil or zoneLookup == nil or quests == nil or wayshrines == nil then return end
	
	for i,quest in ipairs(quests) do
	    -- always request where zoneIndex is nil
		if IsQuestValidForZone(quest,loc,zoneLookup) == true then 
			Quest.GetQuestLocations(quest.index,function(result)
			
				if IsValidResult(result) == true then

					local closest 
									
					if result.insideCurrentMapWorld == true then
						closest = Location.GetClosestLocation(result.normalizedX,result.normalizedY,wayshrines)
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
	
		for conditionIndex,condition in pairs(stepInfo.conditions) do 
			AddTextToTooltip(tooltip, condition.text)
		end
	end 
end

local function GetRecallCostInfo()
	local cost = GetRecallCost()
	local hasEnough = CURRENCY_HAS_ENOUGH
	if cost > GetCurrentMoney() then 
		hasEnough = CURRENCY_NOT_ENOUGH
	end
	return cost,hasEnough
end

local REASON_CURRENCY_SPACING = 3
local function AddRecallToTooltip(tooltip,inCyrodiil)

	if inCyrodiil == true then 
	
		AddTextToTooltip(tooltip,GetString(SI_TOOLTIP_WAYSHRINE_CANT_RECALL_AVA), ZO_ERROR_COLOR)
		
	else
	
		local _, timeLeft = GetRecallCooldown()
		
		if timeLeft == 0 then
		
			local cost,hasEnough = GetRecallCostInfo()
		
			tooltip:AddMoney(tooltip, cost, SI_TOOLTIP_RECALL_COST, hasEnough)
			
			local moneyLine = GetControl(tooltip, "SellPrice")  
			local reasonLabel = GetControl(moneyLine, "Reason")
			local currencyControl = GetControl(moneyLine, "Currency")
			
			-- fix vertical align 
			currencyControl:ClearAnchors()
			currencyControl:SetAnchor(TOPLEFT, reasonLabel, TOPRIGHT, REASON_CURRENCY_SPACING, 0)
			
		else
		
			local text = zo_strformat(SI_TOOLTIP_WAYSHRINE_RECALL_COOLDOWN, ZO_FormatTimeMilliseconds(timeLeft, TIME_FORMAT_STYLE_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS))
			
            AddTextToTooltip(tooltip,text, ZO_HIGHLIGHT_TEXT)
		
		end
		
	end 
end

local function SetRecallAmount(tooltip,amount,hasEnough)
	local currencyControl = GetControl(GetControl(tooltip, "SellPrice"), "Currency")
	if currencyControl ~= nil then 
		ZO_CurrencyControl_SetSimpleCurrency(currencyControl, CURRENCY_TYPE_MONEY, amount, {showTooltips = false}, CURRENCY_DONT_SHOW_ALL, hasEnough)
	end
end

local function SetCooldownTimeleft(tooltip,timeLeft)
	-- TODO: Set cooldown line
end

local function UpdateRecallAmount(tooltip)

	local _, timeLeft = GetRecallCooldown()
	
	if timeLeft == 0 then
	
		local cost,hasEnough = GetRecallCostInfo()
		SetRecallAmount(tooltip,cost,hasEnough)
	else
		SetCooldownTimeleft(tooltip,timeLeft)
	end
	
end

local function SortQuestsTable(questTable)
	table.sort(questTable,function(x,y)
		if x.assisted == true then 
			return true
		elseif y.assisted == true then 
			return false 
		end
		return x.index < y.index
	end)
end 

local function CreateQuestsTable(quests)
	
	local questTable = {}
	
	for index,quest in pairs(quests) do
		table.insert(questTable,quest)
	end 
	
	return questTable
end

local function IsCyrodiilRow(data)
	if data == nil then return false end 
	return Location.Data.IsZoneIndexCyrodiil(data.zoneIndex)
end

local function IsKeepRow(data,isRecall,isKeep)
	if IsCyrodiilRow(data) == false then return false end 
	return isRecall == true or isKeep == true
end 

local function AppendQuestsToTooltip(tooltip,data)
	if data.quests == nil then return end 

	AddDividerToTooltip(tooltip)
	
	local first = true
	
	local questsTable = data.quests.table
	
	if questsTable == nil then 
		questsTable = CreateQuestsTable(data.quests)
		data.quests.table = questsTable
	end 
	SortQuestsTable(questsTable)
	for i,quest in ipairs(questsTable) do 
		if first == false then AddDividerToTooltip(tooltip) end
		AddQuestTasksToTooltip(tooltip, quest)
		first = false
	end 
end

local function ShowToolTip(tooltip, control,data,offsetX,isRecall,isKeep,inCyrodiil)
	InitializeTooltip(tooltip, control, RIGHT, offsetX)
	
	AddTextToTooltip(tooltip, data.name, ZO_SELECTED_TEXT)
	
	if isRecall == true or (isKeep == true and IsCyrodiilRow(data) == false) then 
		AddRecallToTooltip(tooltip,inCyrodiil)
	elseif isRecall == false then 
		AddTextToTooltip(tooltip,GetString(SI_TOOLTIP_WAYSHRINE_CLICK_TO_FAST_TRAVEL), ZO_HIGHLIGHT_TEXT)
	end
	
	AppendQuestsToTooltip(tooltip,data)

end

local function HideToolTip(tooltip) 
	ClearTooltip(tooltip)
end 

local function ShowQuestMenu(owner,data,func)
	ClearMenu()
	
	if data == nil or data.quests == nil or data.quests.table == nil then return end 
	
	local name
	local quest
	
	local quests = data.quests.table
	
	local count = #quests 
	
	if count == 1 then
		func(quests[1])
	elseif count > 1 then
		
		for i,quest in ipairs(quests) do 
			name = quest.name

			if quest.assisted == false then 
				AddMenuItem(name, function()
					func(quest)
					ClearMenu()
				end)
			end
		end 
		
		ShowMenu(owner)
	end 
end

local function SetAssistedInLookup(questIndex, lookup)
	for k,row in pairs(lookup) do 
		if type(row) == "table" then
			if row.data ~= nil and row.data.setAssisted ~= nil then 
				row.data:setAssisted(questIndex)
			end 
		end
	end
end 

local function SetAssisted(questIndex,curLookup,recLookup,zoneLookup)
	QUEST_TRACKER:ForceAssist(questIndex)
	SetAssistedInLookup(questIndex,curLookup)
	SetAssistedInLookup(questIndex,recLookup)
	if zoneLookup ~= nil then 
		for zoneIndex,lookup in pairs(zoneLookup) do
			SetAssistedInLookup(questIndex,lookup)
		end
	end 
end

local function ShowKeepTooltip(tooltip,control, offsetX, data)

	-- guessed defaults for last values 
	tooltip:SetKeep(data.nodeIndex, BGQUERY_ASSIGNED_AND_LOCAL, 1.0)
	
	AppendQuestsToTooltip(tooltip,data)
	
	tooltip:Show(control,offsetX)
	
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
	
	local recallTimer
	
	local keepTooltip = WorldMap.GetKeepTooltip()
	
	local function StartRecallTimer()
		if tab:IsRecall() == false then return end
		
		if recallTimer == nil then
			recallTimer = Timer(function()
				UpdateRecallAmount(InformationTooltip)
			end,500)
		end 
		recallTimer:Start()
	end 
	
	local function StopRecallTimer()
		if recallTimer == nil then return end
		recallTimer:Stop()
	end
	
	local function ShowCurrentTooltip(icon,data)
		if data == nil then return end
		
		local isRecall,isKeep,inCyrodiil = tab:IsRecall(),tab:IsKeep(),tab:InCyrodiil()
		
		if IsKeepRow(data,isRecall,isKeep) == true then 
			ShowKeepTooltip(keepTooltip,icon,-25,data)
		else
			ShowToolTip(InformationTooltip, icon,data,-25,isRecall,isKeep, inCyrodiil)
		end
		
		StartRecallTimer()
	end
	
	local function GetWayshrinesData(isRecall,isKeep,inCyrodiil,loc)
		if loc == nil then return {} end 
		
		local zoneIndex = loc.zoneIndex
		
		local locIsCyrodiil = Location.Data.IsCyrodiil(loc)

		if inCyrodiil == true and (isRecall == true or isKeep == true) and locIsCyrodiil == true then 
			return Transitus.GetKnownNodes(BGQUERY_ASSIGNED_AND_LOCAL)
		elseif inCyrodiil == false or locIsCyrodiil == false then 
			return Utils.toTable(Wayshrine.GetKnownWayshrinesByZoneIndex(zoneIndex))
		else
			return {}
		end 
	
		return wayshrines
	end
	
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
		
		local wayshrines = GetWayshrinesData(_tab:IsRecall(),_tab:IsKeep(),_tab:InCyrodiil(),loc)
		
		RefreshQuests(loc,_tab,curLookup,zoneLookup,quests,wayshrines,recLookup)

		_refreshing = false
	end
	
	self.RefreshIfRequired = function(self,...)
		if _refreshing == true or _isDirty == false then return end
		self:Refresh(...)
		_isDirty = false
	end

	self.HideToolTip = function(self) 
	
		StopRecallTimer()
		
		HideToolTip(InformationTooltip) 
		
		keepTooltip:Hide()
		
	end 
	
	tab.IconMouseEnter = FasterTravel.hook(tab.IconMouseEnter,function(base,control,icon,data) 
		base(control,icon,data)
		
		ShowCurrentTooltip(icon,data)
	end)
	
	tab.IconMouseExit = FasterTravel.hook(tab.IconMouseExit,function(base,control,icon,data)
		base(control,icon,data)
		self:HideToolTip()
	end)
	
	tab.IconMouseClicked = FasterTravel.hook(tab.IconMouseClicked,function(base,control,icon,data)
		base(control,icon,data)
		ShowQuestMenu(control,data,function(quest)
			
			local loc = _locationsLookup[data.zoneIndex]
			
			if loc == nil then 
				loc = _locationsLookup[quest.zoneIndex]
			end 
			
			local mapIndex = loc.mapIndex
			
			local questIndex = quest.index
			local lookups = _tab:GetRowLookups()
			
			local curLookup,zoneLookup,recLookup = lookups.current,lookups.zone,lookups.recent
			
			_refreshing = true 
			
			SetAssisted(questIndex,curLookup,recLookup,zoneLookup)
			
			data:setAssisted(questIndex)
			
			_tab:RefreshControl()
			
			_refreshing = false
			
			if mapIndex ~= GetCurrentMapIndex() then 
				ZO_WorldMap_SetMapByIndex(mapIndex)
			end

		end)
	end)
	
	tab.RowMouseEnter = FasterTravel.hook(tab.RowMouseEnter,function(base,control,row,label,data)
		base(control,row,label,data)

		ShowCurrentTooltip(row.icon,data)
		
	end)
	
	tab.RowMouseExit = FasterTravel.hook(tab.RowMouseExit,function(base,control,row,label,data)
		base(control,row,label,data)
		
		self:HideToolTip()
	end)
	
	tab.RowMouseClicked = FasterTravel.hook(tab.RowMouseClicked,function(base,control,row,data)
		base(control,row,data)
		
		local nodeIndex = data.nodeIndex
		local isTransitus = data.isTransitus
		if nodeIndex == nil then return end
		
		local loc = _locationsLookup[data.zoneIndex]
		
		if loc ~= nil then 
			WorldMap.PanToPoint(loc.mapIndex,function()
				local x,y 
				if isTransitus == true then 
					local pinType
					pinType, x,y = GetKeepPinInfo(nodeIndex, BGQUERY_LOCAL)
				else
					local known,name 
					known,name,x,y = Wayshrine.Data.GetNodeInfo(nodeIndex)
				end
				return x,y
			end)
		end 
	end)
	
end
