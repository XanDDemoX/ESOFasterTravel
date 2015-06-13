
local Location = FasterTravel.Location
local WorldMap = FasterTravel.WorldMap

local Timer = FasterTravel.Timer

local GetPinTypeIconPath = WorldMap.GetPinTypeIconPath
local GetQuestIconPath = WorldMap.GetQuestIconPath
local ConvertQuestPinType = WorldMap.ConvertQuestPinType
local GetPinTexture = WorldMap.GetPinTexture

local WayshrineTooltip = FasterTravel.class()

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

local function ShowKeepTooltip(tooltip,control, offsetX, data)

	-- guessed defaults for last values 
	tooltip:SetKeep(data.nodeIndex, BGQUERY_ASSIGNED_AND_LOCAL, 1.0)
	
	AppendQuestsToTooltip(tooltip,data)
	
	tooltip:Show(control,offsetX)
	
end

function WayshrineTooltip:init(tab,infoTooltip,keepTooltip) 

	local recallTimer
	
	local function StartRecallTimer()
		if tab:IsRecall() == false then return end
		
		if recallTimer == nil then
			recallTimer = Timer(function()
				UpdateRecallAmount(infoTooltip)
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
			ShowToolTip(infoTooltip, icon,data,-25,isRecall,isKeep, inCyrodiil)
		end
		
		StartRecallTimer()
	end
	
	self.Show = function(self,...)
		ShowCurrentTooltip(...)
	end 
	
	self.Hide = function(self)
		StopRecallTimer()
		
		HideToolTip(infoTooltip) 
		
		keepTooltip:Hide()
	end 
	
end

FasterTravel.WayshrineTooltip = WayshrineTooltip