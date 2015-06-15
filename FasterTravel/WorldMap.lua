local WorldMap = {}

-- PinManager wrapper

local PinManager = FasterTravel.class()

function PinManager:init()

	local _manager
	
	local _pinType = "FasterTravel_Fake_Pin"
	
	local function GetFakePinType()
		return _G[_pinType]
	end
	
	ZO_WorldMap_AddCustomPin(_pinType, function(manager)
		_manager = manager
		ZO_WorldMap_SetCustomPinEnabled(GetFakePinType(), false)
	end , nil, { level = 0, size = 0, texture = "" })
	
	ZO_WorldMap_SetCustomPinEnabled(GetFakePinType(), true)
	ZO_WorldMap_RefreshCustomPinsOfType(GetFakePinType())
	
	self.PanToPoint = function(self,x,y)
		local pin = _manager:CreatePin(GetFakePinType(), _pinType, x, y)

		local orig_getPlayerPin = _manager.GetPlayerPin
		_manager.GetPlayerPin = function() return pin end

		ZO_WorldMap_PanToPlayer()

		_manager.GetPlayerPin = orig_getPlayerPin
		_manager:RemovePins(_pinType)
	end
	
end

-- Keep tooltip wrapper
local KeepToolTip = FasterTravel.class()

local LINE_SPACING = 3
--local MAX_WIDTH = 500
local BORDER = 8

local function KeepToolTipAddControl(self,control,width,height,spacing)
    spacing = spacing or self.extraSpace or LINE_SPACING
    if(self.lastLine) then
        control:SetAnchor(TOPLEFT, self.lastLine, BOTTOMLEFT, 0, spacing)
    else
        control:SetAnchor(TOPLEFT, GetControl(self, "Name"), BOTTOMLEFT, 0, spacing)
    end

    self.extraSpace = nil
    self.lastLine = control

    if(width > self.width) then
        self.width = width
    end

    self.height = self.height + height + LINE_SPACING
	
    self:SetDimensions(self.width + BORDER * 2, self.height)
end

local function KeepToolTipAddLine(self, text, _,r,g,b)
    local line = self.linePool:AcquireObject()
    line:SetHidden(false)
    line:SetDimensionConstraints(0, 0, 0, 0)
    line:SetText(text)

	line:SetColor(r,g,b)

	local width, height = line:GetTextDimensions()
	
	KeepToolTipAddControl(self,line,width,height)
	
end

local function KeepToolTipAddDivider(self)
	if not self.dividerPool then
        self.dividerPool = ZO_ControlPool:New("ZO_BaseTooltipDivider", self, "Divider")
    end

    local divider = self.dividerPool:AcquireObject()
	KeepToolTipAddControl(self,divider,0,30,10)
	self.extraSpace = 10
end

local function KeepToolTipHide(self)
	if self.dividerPool then
		self.dividerPool:ReleaseAllObjects()
	end
	self:Reset()
	self:SetHidden(true)
end

function KeepToolTip:init(tooltip)
	local _tooltip = tooltip
	
	self.AddDivider = function(self)
		KeepToolTipAddDivider(_tooltip)
	end
	
	self.AddLine = function(self,...)
		KeepToolTipAddLine(_tooltip,...)
	end 
	
	self.SetKeep = function(self,...)
		_tooltip:SetKeep(...)
	end
	
	self.Show = function(self,control, offsetX,nodeIndex)
		_tooltip:ClearAnchors()
		_tooltip:SetAnchor(TOPRIGHT,control,TOPLEFT,offsetX,0)
		_tooltip:SetHidden(false)
	end
	
	self.Hide = function(self)
		KeepToolTipHide(_tooltip)
	end
	
end 

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

local _iconWidth = 28 
local _iconHeight = 28 

local function GetPinTypeIconPath(textures,pinType)
	return textures[pinType],pinType,textures
end

local function GetQuestIconPath(quest)
	local pinType = quest.pinType
	if quest.isBreadcrumb then 
		return GetPinTypeIconPath(_breadcrumbQuestPinTextures,pinType)
	else
		return GetPinTypeIconPath(_questPinTextures,pinType)
	end
end

local function ConvertQuestPinType(pinType,assisted)
	if assisted == true then 
		if pinType == MAP_PIN_TYPE_TRACKED_QUEST_CONDITION then 
			return MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION
		elseif pinType == MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION then
			return MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION
		elseif pinType == MAP_PIN_TYPE_TRACKED_QUEST_ENDING then 
			return MAP_PIN_TYPE_ASSISTED_QUEST_ENDING
		end 
	else
		if pinType == MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION then 
			return MAP_PIN_TYPE_TRACKED_QUEST_CONDITION
		elseif pinType == MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION then
			return MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION
		elseif pinType == MAP_PIN_TYPE_ASSISTED_QUEST_ENDING then 
			return MAP_PIN_TYPE_TRACKED_QUEST_ENDING
		end 
	end
	return pinType
end

local function GetPinTexture(pinType)
	if pinType == nil then return end 
	
	local data = ZO_MapPin.PIN_DATA
	
	local pinData = data[pinType]
	
	if pinData == nil then return end 
	
	local texture = pinData.texture
	
	return texture
end 


local _pinManager
local function GetPinManager()
	if _pinManager == nil then 
		_pinManager = PinManager()
	end 
	return _pinManager
end

local function OnMap(mapIndex,func)
	if mapIndex ~= GetCurrentMapIndex() then 
		
		local callback 
		callback = function()
			FasterTravel.removeCallback(FasterTravel.CALLBACK_ID_ON_WORLDMAP_CHANGED,callback)
			func()
		end
	
		FasterTravel.addCallback(FasterTravel.CALLBACK_ID_ON_WORLDMAP_CHANGED,callback)
		
		ZO_WorldMap_SetMapByIndex(mapIndex)

	else
		func()
	end
end 


local function PanToPoint(mapIndex,func)

	local manager = GetPinManager()
	
	
	OnMap(mapIndex,function()
		local x,y = func()
		manager:PanToPoint(x,y)
	end)

end

local _keepTooltip

local function GetKeepTooltip()
	if _keepTooltip == nil then 
		
		_keepTooltip = KeepToolTip(ZO_KeepTooltip)
	
	end 
	
	return _keepTooltip
end 

local w = WorldMap

w.PanToPoint = PanToPoint
w.GetKeepTooltip = GetKeepTooltip

w.GetPinTypeIconPath = GetPinTypeIconPath
w.GetQuestIconPath = GetQuestIconPath
w.ConvertQuestPinType = ConvertQuestPinType
w.GetPinTexture = GetPinTexture

FasterTravel.WorldMap = w 