local WorldMap = {}

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

local _pinManager
local function GetPinManager()
	if _pinManager == nil then 
		_pinManager = PinManager()
	end 
	return _pinManager
end

local function PanToPoint(mapIndex,x,y)

	local manager = GetPinManager()

	manager:PanToPoint(x,y)
end

local w = WorldMap

w.PanToPoint = PanToPoint

FasterTravel.WorldMap = w 