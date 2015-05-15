
FasterTravel = {}

local CALLBACK_ID_ON_WORLDMAP_CHANGED = "OnWorldMapChanged"
local CALLBACK_ID_ON_QUEST_TRACKER_TRACKING_STATE_CHANGED = "QuestTrackerTrackingStateChanged"

local function addEvent(id,func)
	EVENT_MANAGER:RegisterForEvent("FasterTravel_"..tostring(id),id,func)
end

local function addCallback(id,func)
	CALLBACK_MANAGER:RegisterCallback(id,func)
end
local function removeCallback(id,func)
	CALLBACK_MANAGER:UnregisterCallback(id,func)
end

local function hook(baseFunc,newFunc)
	return function(...)
		return newFunc(baseFunc,...)
	end
end
	
local function init(func,...)

	local arg = {...}
	addEvent(EVENT_ADD_ON_LOADED,function(eventCode, addOnName)
			if(addOnName ~= "FasterTravel") then
				return
			end
			func(unpack(arg))
	end)

end

local f = FasterTravel
f.hook = hook
f.addEvent = addEvent
f.addCallback = addCallback
f.removeCallback = removeCallback

init(function()

	local _prefix = "[FasterTravel]: "
	
	local Location = f.Location
	local Teleport = f.Teleport
	local Utils = f.Utils
	
	local _locations = {}
	local _locationsLookup = {}
	
	local _settings = {recent={}}
	local _settingsVersion = "5"
	
	_settings = ZO_SavedVars:New("FasterTravel_SavedVariables", _settingsVersion, "", _settings, nil)
	
	local wayshrineControl = FasterTravel_WorldMapWayshrines
	local playersControl = FasterTravel_WorldMapPlayers

	local wayshrinesTab
	local playersTab
	local questTracker
	
	local recentTable = Utils.map(_settings.recent,function(v) return {name=v.name,nodeIndex=v.nodeIndex} end)
	
	local recentList = f.RecentList(recentTable,"name",5)
		
	local function GetZoneLocation(...)
		return Location.GetZoneLocation(_locationsLookup,...)
	end
	

	local _initial = false
	
	local function Setup(callback)
		
		local InitFunc = function(locations,key)
		
			_locations = Location.InitLocations(locations)
			_locationsLookup = Location.CreateLocationsLookup(_locations)
			
			local loc = (key ~= nil and GetZoneLocation(key)) or GetZoneLocation()
			
			callback(loc)

		end
		
		if _settings.version ~= _settingsVersion or _settings.locations == nil or #_settings.locations < 1 then 
			_initial = true 
			local locationFunc  
			-- hack for zoneIndexes
			locationFunc = Location.GetLocations(function(locations,key)   
			
				removeCallback(CALLBACK_ID_ON_WORLDMAP_CHANGED,locationFunc)
				_settings.locations = locations
				
				d(_prefix.."First run location data initialised...")
				InitFunc(locations,key)
				
			end)

			addCallback(CALLBACK_ID_ON_WORLDMAP_CHANGED,locationFunc)
		else
			InitFunc(_settings.locations)
		end
	end
	

		
	local function PushRecent(name,nodeIndex)
		recentList:push("name",{name=name,nodeIndex=nodeIndex})
		_settings.recent = {}
		local i = 0
		for v in recentList:items() do
			i = i + 1
			_settings.recent[i] = {name=v.name,nodeIndex=v.nodeIndex}
		end
	end
	
	local function SetCurrentZoneMapIndexes(loc)
		if wayshrinesTab == nil then return end 
		wayshrinesTab:SetCurrentZoneMapIndexes(loc.zoneIndex,loc.mapIndex)
	end
	
	local function SetWayshrinesDirty()
		if wayshrinesTab == nil then return end
		wayshrinesTab:SetDirty()
	end
	
	local function RefreshWayshrinesIfRequired(nodeIndex)
		if wayshrinesTab == nil then return end 
		 wayshrinesTab:RefreshIfRequired(nodeIndex)
	end
		
	local function SetPlayersDirty()
		if playersTab == nil then return end 
		playersTab:SetDirty()
	end
	
	local function RefreshPlayersIfRequired()
		if playersTab == nil then return end 
		playersTab:RefreshIfRequired()
	end
	
	local function SetQuestsDirty()
		if questTracker == nil then return end 
		questTracker:SetDirty()
	end
	
	local function RefreshQuestsIfRequired()
		if questTracker == nil then return end 
		questTracker:RefreshIfRequired()
	end
	
	local function IsWorldMapHidden()
		return ZO_WorldMap:IsHidden()
	end
	
	addEvent(EVENT_PLAYER_ACTIVATED,function(eventCode)
		-- prevent setting on first activate of first run as map maybe incorrect
		if _initial == true then
			_initial = false
			return 
		end	
		
		local func = function()
			local loc = GetZoneLocation()
			SetCurrentZoneMapIndexes(loc)
			SetWayshrinesDirty()
			SetQuestsDirty()
		end 
		
		-- handle the map changing from Tamriel 
		if GetCurrentMapIndex() == 1 then 
			local onChange
			onChange = function()
				func()
				removeCallback(CALLBACK_ID_ON_WORLDMAP_CHANGED,onChange)
			end 
			addCallback(CALLBACK_ID_ON_WORLDMAP_CHANGED,onChange)
		else
			func()
		end 

	end)
	
	addEvent(EVENT_START_FAST_TRAVEL_INTERACTION, function(eventCode,nodeIndex)
		
		SetWayshrinesDirty()
		SetQuestsDirty()
		
		RefreshWayshrinesIfRequired(nodeIndex)
		RefreshQuestsIfRequired()
		
		WORLD_MAP_INFO:SelectTab(SI_MAP_INFO_MODE_WAYSHRINES)
		
	end)
	
	addEvent(EVENT_END_FAST_TRAVEL_INTERACTION,function(eventCode)
		SetWayshrinesDirty()
		SetQuestsDirty()
	end)
	
	addEvent(EVENT_FAST_TRAVEL_NETWORK_UPDATED,function(eventCode,nodeIndex)
		SetWayshrinesDirty()
	end)
	
	addEvent(EVENT_FRIEND_ADDED,function(eventCode)
		SetPlayersDirty()
	end)
	
	addEvent(EVENT_FRIEND_REMOVED,function(eventCode,DisplayName)
		SetPlayersDirty()
	end)
	
	addEvent(EVENT_FRIEND_CHARACTER_ZONE_CHANGED,function(eventCode, DisplayName, CharacterName, newZone)
		SetPlayersDirty()
	end)
	
	addEvent(EVENT_GROUP_INVITE_RESPONSE,function(eventCode, inviterName, response)
		if response == GROUP_INVITE_RESPONSE_ACCEPTED then
			SetPlayersDirty()
		end
	end)
	
	addEvent(EVENT_GROUP_MEMBER_JOINED,function(eventCode,memberName)
		SetPlayersDirty()
	end)
	
	addEvent(EVENT_GROUP_MEMBER_LEFT,function(eventCode,memberName,reason,wasLocalPlayer)
		SetPlayersDirty()
	end)
	
	addEvent(EVENT_GUILD_MEMBER_ADDED,function(eventCode, guildId, DisplayName)
		SetPlayersDirty()
	end)
	
	addEvent(EVENT_GUILD_MEMBER_REMOVED,function(eventCode,guildId, DisplayName, CharacterName)
		SetPlayersDirty()
	end)
	
	addEvent(EVENT_GROUP_MEMBER_CONNECTED_STATUS,function(eventCode, unitTag, isOnline)
		SetPlayersDirty()
	end)
	
	addEvent(EVENT_GUILD_SELF_JOINED_GUILD,function(eventCode, guildId, guildName)
		SetPlayersDirty()
	end)
	
	addEvent(EVENT_GUILD_SELF_LEFT_GUILD,function(eventCode, guildId, guildName)
		SetPlayersDirty()
	end)
	
	addEvent(EVENT_GUILD_MEMBER_CHARACTER_ZONE_CHANGED,function(eventCode, guildId, DisplayName, CharacterName, newZone)
		SetPlayersDirty()
	end)
	
	addEvent(EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED,function(eventCode, guildId, DisplayName, oldStatus, newStatus)
		if newStatus == PLAYER_STATUS_OFFLINE or (oldStatus == PLAYER_STATUS_OFFLINE and newStatus == PLAYER_STATUS_ONLINE) then
			SetPlayersDirty()
		end
	end)
	
	addEvent(EVENT_QUEST_ADDED ,function(eventCode, journalIndex, questName, objectiveName)
		SetQuestsDirty()
	end)
	
	addEvent(EVENT_QUEST_ADVANCED,function(eventCode, journalIndex, questName, isPushed, isComplete, mainStepChanged)
		SetQuestsDirty()
	end)
	
	addEvent(EVENT_QUEST_REMOVED,function(eventCode, isCompleted, journalIndex, questName, zoneIndex, poiIndex)
		SetQuestsDirty()
	end)
	
	addEvent(EVENT_QUEST_OPTIONAL_STEP_ADVANCED,function(eventCode,  text)
		SetQuestsDirty()
	end)
	
	-- hack for detecting tracked quest change
	FOCUSED_QUEST_TRACKER.FireCallbacks = hook(FOCUSED_QUEST_TRACKER.FireCallbacks,function(base,self,id,control,assisted, trackType,arg1,arg2)
		if base then base(self,id,control,assisted, trackType,ar1, arg2) end
		
		if id ~= CALLBACK_ID_ON_QUEST_TRACKER_TRACKING_STATE_CHANGED then return end 

		SetQuestsDirty()
		
		if IsWorldMapHidden() == false then
			RefreshQuestsIfRequired()
		end

	end)
	
	ZO_Dialogs_ShowPlatformDialog = hook(ZO_Dialogs_ShowPlatformDialog,function(base,id,node,params,...)
		base(id,node,params,...)
		if id ~= "RECALL_CONFIRM" and id ~= "FAST_TRAVEL_CONFIRM" then return end
		-- hack to get fast travel node for recent list from the map
		local nodeIndex,name = node.nodeIndex,params.mainTextParams[1]
				
		local dialog = ZO_Dialogs_FindDialog(id)
		local acceptButton = dialog.buttonControls[1]
		local cancelButton = dialog.buttonControls[2]
		
		local acceptButton_m_callback = acceptButton.m_callback
		local cancelButton_m_callback = cancelButton.m_callback
		
		--get accept and cancel buttons
		acceptButton.m_callback = function(...)
			if acceptButton_m_callback ~= nil then acceptButton_m_callback(...) end
			PushRecent(name,nodeIndex)
			acceptButton.m_callback = acceptButton_m_callback
			cancelButton.m_callback = cancelButton_m_callback
		end
		
		cancelButton.m_callback = function(...)
			if cancelButton_m_callback ~= nil then cancelButton_m_callback(...) end
			acceptButton.m_callback = acceptButton_m_callback
			cancelButton.m_callback = cancelButton_m_callback
		end
	end)
		
	ZO_WorldMap.SetHidden = hook(ZO_WorldMap.SetHidden,function(base,self,value)
		base(self,value)
		if value == false then
			RefreshWayshrinesIfRequired() 
			RefreshQuestsIfRequired()
			RefreshPlayersIfRequired()
		elseif value == true and wayshrinesTab ~= nil then 
			wayshrinesTab:HideAllZoneCategories()
			questTracker:HideToolTip()
			--SetQuestsDirty()
		end
	end)
	
	local function AddWorldMapFragment(strId,fragment,normal,highlight,pressed)
	    WORLD_MAP_INFO.modeBar:Add(strId, { fragment }, {pressed = pressed,highlight =highlight,normal = normal})
	end

	Setup(function(loc)
		
		wayshrinesTab = FasterTravel.MapTabWayshrines(wayshrineControl,_locations,_locationsLookup,recentList)
		playersTab = FasterTravel.MapTabPlayers(playersControl)
		questTracker = FasterTravel.QuestTracker(_locations,_locationsLookup,wayshrinesTab)

		SetCurrentZoneMapIndexes(loc)

		addCallback(CALLBACK_ID_ON_WORLDMAP_CHANGED,function()
			SetQuestsDirty()
			if IsWorldMapHidden() == false then 
				RefreshQuestsIfRequired()
			end
		end)
		
	end)

	-- finally add the controls
	local path = "/esoui/art/treeicons/achievements_indexicon_alliancewar_"

	AddWorldMapFragment(SI_MAP_INFO_MODE_WAYSHRINES,wayshrineControl.fragment,path.."up.dds",path.."over.dds",path.."down.dds")

	path = "/esoui/art/mainmenu/menubar_group_"

	AddWorldMapFragment(SI_MAP_INFO_MODE_PLAYERS,playersControl.fragment,path.."up.dds",path.."over.dds",path.."down.dds")

	
	SLASH_COMMANDS["/goto"] = function(args)
		if Utils.stringIsEmpty(args) == true then return end
		local result,name
		if Teleport.IsPlayerTeleportable(args) == true then
			result,name = Teleport.TeleportToPlayer(args)
		else
			result,name = Teleport.TeleportToZone(args)
		end
		if result == true then 
			d(_prefix.."Teleporting to "..name)
		elseif result == false and name ~= nil then 
			d(_prefix.."Invalid teleport target "..name)
		end
	end
	
	SLASH_COMMANDS["/zk"] = function()
		d(Location.GetMapZoneKey(),GetCurrentMapZoneIndex(),GetMapTileTexture())
	end
end)


