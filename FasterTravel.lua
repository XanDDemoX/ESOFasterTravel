FasterTravel = {}

ADDON_NAME = "FasterTravel"
ADDON_VERSION = "2.2.8"

local CALLBACK_ID_ON_WORLDMAP_CHANGED = "OnWorldMapChanged"
local CALLBACK_ID_ON_QUEST_TRACKER_TRACKING_STATE_CHANGED = "QuestTrackerTrackingStateChanged"
local _events = {}
local GROUP_ALIAS = "group"

local predefined_aliases = {
	["al"] = "Alik'r",
	["ar"] = "Artaeum",
	["au"] = "Auridon",
	["br"] = "The Brass Fortress",
	["cr"] = "Craglorn",
	["co"] = "Coldharbour",
	["cc"] = "Clockwork City",
	["cl"] = "Clockwork City",
	["de"] = "Deshaan",
	["ea"] = "Eastmarch",
	["gl"] = "Glenumbra",
	["gc"] = "Gold Coast",
	["go"] = "Gold Coast",
	["gra"] = "Grahtwood",
	["gw"] = "Grahtwood",
	["gs"] = "Greenshade",
	["he"] = "Hew's Bane",
	["hb"] = "Hew's Bane",
	["ma"] = "Malabal Tor",
	["mt"] = "Malabal Tor",
	["mu"] = "Murkmire",
	["re"] = "Reaper's March",
	["rm"] = "Reaper's March",
	["rif"] = "The Rift",
	["tr"] = "The Rift",
	["riv"] = "Rivenspire",
	["rs"] = "Rivenspire",
	["sf"] = "Stonefalls",
	["sh"] = "Stormhaven",
	["sm"] = "Stros M'Kai",
	["su"] = "Summerset",
}

local function GetUniqueEventId(id)
    local count = _events[id] or 0
    count = count + 1
    _events[id] = count
    return count
end

local function GetEventName(id)
    return table.concat({ "FasterTravel_", tostring(id), "_", tostring(GetUniqueEventId(id)) })
end

local function addEvent(id, func)
    local name = GetEventName(id)
    EVENT_MANAGER:RegisterForEvent(name, id, func)
end

local function addEvents(func, ...)
    local count = select('#', ...)
    local id
    for i = 1, count do
	id = select(i, ...)
	if not id then
	    df('FasterTravel: element %d is nil.  Please report.', i)
	else
	    addEvent(id, func)
	end
    end
end

local function addCallback(id, func)
    CALLBACK_MANAGER:RegisterCallback(id, func)
end

local function removeCallback(id, func)
    CALLBACK_MANAGER:UnregisterCallback(id, func)
end

local function hook(baseFunc, newFunc)
    return function(...)
	return newFunc(baseFunc, ...)
    end
end

local function init(func, ...)
    local arg = { ... }
    addEvent(EVENT_ADD_ON_LOADED, function(eventCode, addOnName)
	if (addOnName ~= "FasterTravel") then
	    return
	end
	func(unpack(arg))
    end)
end

local function bold(arg)
	return string.format("|c%s%s|r", "ffaa00", arg)
end

local f = FasterTravel
f.CALLBACK_ID_ON_WORLDMAP_CHANGED = CALLBACK_ID_ON_WORLDMAP_CHANGED
f.hook = hook
f.addEvent = addEvent
f.addEvents = addEvents
f.addCallback = addCallback
f.removeCallback = removeCallback
f.bold = bold

init(function()

    local _prefix = string.format("[%s]: ", ADDON_NAME)

    local Location = f.Location
    local DropDown = f.DropDown
    local Teleport = f.Teleport
    local Utils = f.Utils

    local _locations
    local _locationsLookup

    local _settings = {
		recent = {},
		locationOrder = Location.Data.LocationOrder.A_Z,
		locationDirection = Location.Data.LocationDirection.ASCENDING,
	}

    local _account_settings = {
		favourites = {},
		aliases = predefined_aliases,
		WfDpatchEnabled = true
	}

    local _settingsVersion = "10"

	_settings = ZO_SavedVars:New("FasterTravel_SavedVariables", _settingsVersion, "", _settings, nil)
    _account_settings = ZO_SavedVars:NewAccountWide("FasterTravel_SavedVariables", _settingsVersion, "", _account_settings, nil)

    if _settings.locations then _settings.locations = nil end -- cleanup old saved vars

    -- Introduced to use shorthand form of names.
    if not _account_settings.aliases then _account_settings.aliases = {} end

    local wayshrineControl = FasterTravel_WorldMapWayshrines
    local playersControl = FasterTravel_WorldMapPlayers

    local wayshrinesTab
    local playersTab
    local questTracker

    local currentWayshrineArgs

	local recentTable = Utils.map(_settings.recent, function(v) return { name = v.name, nodeIndex = v.nodeIndex } end)

    local favouritesTable = Utils.map(_account_settings.favourites, function(v) return { name = v.name, nodeIndex = v.nodeIndex } end)

    local recentList = f.List(recentTable, "nodeIndex", 5)

    local favouritesList = f.List(favouritesTable, "nodeIndex", 15)

    local currentFaction
    local locationsDirty = true

	FasterTravel.IsWfDpatchEnabled = function()
		return _account_settings.WfDpatchEnabled
	end

    local function GetZoneLocation(...)
	return Location.Data.GetZoneLocation(_locationsLookup, ...)
    end

    local function UpdateSavedVarTable(tbl, list, func)
	local i = 0
	for v in list:items() do
	    i = i + 1
	    tbl[i] = func(v)
	end
    end

    local function UpdateFavouritesSavedVar()
	local favourites = {}
	UpdateSavedVarTable(favourites, favouritesList, function(v) return { nodeIndex = v.nodeIndex } end)
	_account_settings.favourites = favourites
    end

    local function UpdateRecentSavedVar()
	local recent = {}
	UpdateSavedVarTable(recent, recentList, function(v) return { nodeIndex = v.nodeIndex } end)
	_settings.recent = recent
    end

    local function PushRecent(nodeIndex)
	recentList:push("nodeIndex", { nodeIndex = nodeIndex })
	UpdateRecentSavedVar()
    end

    local function SetLocationsDirty()
	locationsDirty = true
    end

    local function RefreshLocationsIfRequired()
	if wayshrinesTab ~= nil and locationsDirty and wayshrinesTab:IsDirty() then
			Location.Data.UpdateLocationOrder(_locations, _settings.locationOrder, _settings.locationDirection, currentFaction)
			locationsDirty = false
		end
    end

    local function SetWayshrinesDirty()
	if wayshrinesTab == nil then return end
	wayshrinesTab:SetDirty()
    end

    local function RefreshWayshrinesIfRequired(...)
	if wayshrinesTab == nil then return end
	if wayshrinesTab:IsDirty() then
	    FasterTravel.Campaign.RefreshIfRequired()
	end

	RefreshLocationsIfRequired()

	local count = select('#', ...)

	if count == 0 and currentWayshrineArgs ~= nil then
	    wayshrinesTab:RefreshIfRequired(unpack(currentWayshrineArgs))
	else
	    if count > 0 then
		currentWayshrineArgs = { ... }
	    end
	    wayshrinesTab:RefreshIfRequired(...)
	end
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

    local function SetCurrentFaction(loc)

	local oldfaction = currentFaction

	if currentFaction == nil then
	    currentFaction = GetUnitAlliance("player")
	end

	local faction = Location.Data.GetZoneFaction(loc)

	if Location.Data.IsFactionWorldOrShared(faction) == false then
	    currentFaction = faction
	end

	if oldfaction ~= currentFaction then
	    SetLocationsDirty()
	end
    end

    local function SetCurrentZoneMapIndexes(zoneIndex)
	if wayshrinesTab == nil then return end

	local loc = GetZoneLocation(zoneIndex)

	SetCurrentFaction(loc)

	wayshrinesTab:SetCurrentZoneMapIndexes(loc.zoneIndex, loc.mapIndex)
    end

    local function IsWorldMapHidden()
	return ZO_WorldMap:IsHidden()
    end

    local function SetLocationOrder(order)

	local oldOrder = _settings.locationOrder

	if oldOrder ~= order then
	    _settings.locationOrder = order
	    return true
	end
	return false
    end

    local function SetLocationDirection(direction)
	local oldDirection = _settings.locationDirection

	if oldDirection ~= direction then
	    _settings.locationDirection = direction
	    return true
	end
	return false
    end

    local function SetLocationOrdering(func, ...)
	if func(...) == true then
	    SetLocationsDirty()
	    SetWayshrinesDirty()
	    SetQuestsDirty()
	    RefreshWayshrinesIfRequired()
	    RefreshQuestsIfRequired()
	    wayshrinesTab:HideAllZoneCategories()
	end
    end

    local function RefreshDirectionDropDown(order, direction)

	local sortDirectionDropDown = wayshrineControl.sortDirectionDropDown
	local sortDirections = Location.Data.GetSortDirections(order)

	direction = direction or _settings.locationDirection

	DropDown.Refresh(sortDirectionDropDown, sortDirections, function(control, text, data)
	    if data == nil then return end

	    local item = data.item

	    if item == nil then return end

	    local id = item.id

	    if id == nil then return end

	    SetLocationOrdering(SetLocationDirection, id)
	end,
	    function(lookup)
		return lookup[direction]
	    end)
    end

    local function RefreshOrderDropDown(order, direction)

	local sortOrderDropDown = wayshrineControl.sortOrderDropDown
	local sortOrders = Location.Data.GetSortOrders()

	DropDown.Refresh(sortOrderDropDown, sortOrders, function(control, text, data)
	    if data == nil then return end

	    local item = data.item

	    if item == nil then return end

	    local id = item.id

	    if id == nil then return end

	    RefreshDirectionDropDown(id)

	    SetLocationOrdering(SetLocationOrder, id)
	end,
	    function(lookup)
		return lookup[order]
	    end)
    end

    local function RefreshWayshrineDropDowns(args)
	args = args or {}

	local order = args.order or _settings.locationOrder
	local direction = args.direction or _settings.locationDirection

	RefreshOrderDropDown(order)

	RefreshDirectionDropDown(order, direction)
    end

    local function AddFavourite(nodeIndex)
	favouritesList:add("nodeIndex", { nodeIndex = nodeIndex })

	SetQuestsDirty()
	SetWayshrinesDirty()

	UpdateFavouritesSavedVar()

	RefreshWayshrinesIfRequired()
	RefreshQuestsIfRequired()
    end

    local function RemoveFavourite(nodeIndex)
	favouritesList:remove("nodeIndex", { nodeIndex = nodeIndex })

	SetQuestsDirty()
	SetWayshrinesDirty()

	UpdateFavouritesSavedVar()

	RefreshWayshrinesIfRequired()
	RefreshQuestsIfRequired()
    end

    -- refresh to init campaigns
    FasterTravel.Campaign.RefreshIfRequired()

    addEvent(EVENT_PLAYER_ACTIVATED, function(eventCode)

	local func = function()
	    SetCurrentZoneMapIndexes(GetCurrentMapZoneIndex())
	    currentWayshrineArgs = nil
	    SetWayshrinesDirty()
	    SetQuestsDirty()
	end

	local idx = GetCurrentMapIndex()

	-- handle the map changing from Tamriel
	if idx == nil or idx == 1 then
	    local onChange
	    onChange = function()
		func()
		removeCallback(CALLBACK_ID_ON_WORLDMAP_CHANGED, onChange)
	    end
	    addCallback(CALLBACK_ID_ON_WORLDMAP_CHANGED, onChange)
	else
	    func()
	end
    end)

    local function StartFastTravelInteract(...)
	SetWayshrinesDirty()
	SetQuestsDirty()

	RefreshWayshrinesIfRequired(...)
	RefreshQuestsIfRequired()

	WORLD_MAP_INFO:SelectTab(SI_MAP_INFO_MODE_WAYSHRINES)
    end

    addEvent(EVENT_START_FAST_TRAVEL_INTERACTION, function(eventCode, nodeIndex)
	StartFastTravelInteract(nodeIndex, false)
    end)

    addEvent(EVENT_START_FAST_TRAVEL_KEEP_INTERACTION, function(eventCode, nodeIndex)
	StartFastTravelInteract(nodeIndex, true)
    end)

    addEvent(EVENT_GROUP_INVITE_RESPONSE, function(eventCode, inviterName, response)
	if response == GROUP_INVITE_RESPONSE_ACCEPTED then
	    SetPlayersDirty()
	end
    end)

    addEvent(EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, function(eventCode, guildId, DisplayName, oldStatus, newStatus)
	if newStatus == PLAYER_STATUS_OFFLINE or (oldStatus == PLAYER_STATUS_OFFLINE and newStatus == PLAYER_STATUS_ONLINE) then
	    SetPlayersDirty()
	end
    end)

    addEvents(function()
	currentWayshrineArgs = nil
	SetWayshrinesDirty()
	SetQuestsDirty()
    end,
	EVENT_END_FAST_TRAVEL_INTERACTION,
	EVENT_END_FAST_TRAVEL_KEEP_INTERACTION)

    addEvents(function()
	SetWayshrinesDirty()
	SetQuestsDirty()
    end,
		EVENT_FAST_TRAVEL_NETWORK_UPDATED,
		EVENT_FAST_TRAVEL_KEEP_NETWORK_UPDATED,
		EVENT_FAST_TRAVEL_KEEP_NETWORK_LINK_CHANGED,
		EVENT_CAMPAIGN_STATE_INITIALIZED,
		EVENT_CAMPAIGN_SELECTION_DATA_CHANGED,
		EVENT_CURRENT_CAMPAIGN_CHANGED,
		EVENT_ASSIGNED_CAMPAIGN_CHANGED,
--[[
	-- causes error
		EVENT_PREFERRED_CAMPAIGN_CHANGED,
]]
		EVENT_KEEPS_INITIALIZED,
		EVENT_KEEP_ALLIANCE_OWNER_CHANGED,
		EVENT_KEEP_UNDER_ATTACK_CHANGED
	)

    addEvents(function() SetPlayersDirty() end,
	EVENT_GROUP_MEMBER_JOINED, EVENT_GROUP_MEMBER_LEFT, EVENT_GROUP_MEMBER_CONNECTED_STATUS,
	EVENT_GUILD_SELF_JOINED_GUILD, EVENT_GUILD_SELF_LEFT_GUILD, EVENT_GUILD_MEMBER_ADDED, EVENT_GUILD_MEMBER_REMOVED,
	EVENT_GUILD_MEMBER_CHARACTER_ZONE_CHANGED, EVENT_FRIEND_CHARACTER_ZONE_CHANGED,
	EVENT_FRIEND_ADDED, EVENT_FRIEND_REMOVED)


	addEvents(function() SetQuestsDirty() end,
	EVENT_QUEST_ADDED, EVENT_QUEST_ADVANCED, EVENT_QUEST_REMOVED,
	EVENT_QUEST_OPTIONAL_STEP_ADVANCED, EVENT_QUEST_COMPLETE,
	EVENT_OBJECTIVES_UPDATED, EVENT_OBJECTIVE_COMPLETED, EVENT_KEEP_RESOURCE_UPDATE, EVENT_CAMPAIGN_HISTORY_WINDOW_CHANGED)

    local function RefreshQuestsIfMapVisible()
	SetQuestsDirty()

	if IsWorldMapHidden() == false then
	    RefreshQuestsIfRequired()
	end
    end

    addEvents(function() RefreshQuestsIfMapVisible() end, EVENT_CAMPAIGN_QUEUE_JOINED, EVENT_CAMPAIGN_QUEUE_LEFT, EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED, EVENT_KEEP_UNDER_ATTACK_CHANGED)

    addEvent(EVENT_CAMPAIGN_QUEUE_STATE_CHANGED, function(eventCode, campaignId, isGroup, state)
	if state == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING then
	    RefreshQuestsIfMapVisible()
	else
	    SetQuestsDirty()
	end
    end)

    addCallback(CALLBACK_ID_ON_WORLDMAP_CHANGED, RefreshQuestsIfMapVisible)

    -- hack for detecting tracked quest change
    FOCUSED_QUEST_TRACKER.FireCallbacks = hook(FOCUSED_QUEST_TRACKER.FireCallbacks, function(base, self, id, control, assisted, trackType, arg1, arg2)
	if base then base(self, id, control, assisted, trackType, ar1, arg2) end

	if id ~= CALLBACK_ID_ON_QUEST_TRACKER_TRACKING_STATE_CHANGED then return end

	RefreshQuestsIfMapVisible()
    end)

	FasterTravel.WfDpatch = function(enabled)
		-- the patch from WfD to fix F5 house preview problem
		FasterTravel.__old_ZO_Dialogs_ShowPlatformDialog = ZO_Dialogs_ShowPlatformDialog

		FasterTravel.__new_ZO_Dialogs_ShowPlatformDialog = function(name, node, params, ...)
			if name ~= "RECALL_CONFIRM" and name ~= "FAST_TRAVEL_CONFIRM" then return end

			FasterTravel.__old_ZO_Dialogs_ShowPlatformDialog(name, node, params, ...)

			-- d("In func... "..name)
			-- hack to get fast travel node for recent list from the map
			local nodeIndex = node.nodeIndex

			local dialog = ZO_Dialogs_FindDialog(name)
			local acceptButton = dialog.buttonControls[1]
			local cancelButton = dialog.buttonControls[2]

			local acceptButton_m_callback = acceptButton.m_callback
			local cancelButton_m_callback = cancelButton.m_callback

			--get accept and cancel buttons
			acceptButton.m_callback = function(...)
				if acceptButton_m_callback ~= nil then acceptButton_m_callback(...) end
				PushRecent(nodeIndex)
				acceptButton.m_callback = acceptButton_m_callback
				cancelButton.m_callback = cancelButton_m_callback
			end

			cancelButton.m_callback = function(...)
				if cancelButton_m_callback ~= nil then cancelButton_m_callback(...) end
				acceptButton.m_callback = acceptButton_m_callback
				cancelButton.m_callback = cancelButton_m_callback
			end
		end

		if enabled then

			FasterTravel.__Fast_Travel_Hook_Checker = function(name, ...)
				if name ~= "RECALL_CONFIRM" and name ~= "FAST_TRAVEL_CONFIRM" then
					if ZO_Dialogs_ShowPlatformDialog ~= FasterTravel.__old_ZO_Dialogs_ShowPlatformDialog then
						ZO_Dialogs_ShowPlatformDialog = FasterTravel.__old_ZO_Dialogs_ShowPlatformDialog
						if name ~= "HOUSE_PREVIEW_PURCHASE" then
							FasterTravel.__new_ZO_Dialogs_ShowPlatformDialog(name, ...)
						end
					end
				elseif ZO_Dialogs_ShowPlatformDialog ~= FasterTravel.__new_ZO_Dialogs_ShowPlatformDialog then
					ZO_Dialogs_ShowPlatformDialog = FasterTravel.__new_ZO_Dialogs_ShowPlatformDialog
					FasterTravel.__new_ZO_Dialogs_ShowPlatformDialog(name, ...)
				end
				ZO_PreHook("ZO_Dialogs_ShowPlatformDialog", FasterTravel.__Fast_Travel_Hook_Checker)
			end

			ZO_PreHook("ZO_Dialogs_ShowPlatformDialog", FasterTravel.__Fast_Travel_Hook_Checker)

		else -- not enabled
			if ZO_Dialogs_ShowPlatformDialog ~= FasterTravel.__old_ZO_Dialogs_ShowPlatformDialog then
				ZO_Dialogs_ShowPlatformDialog = FasterTravel.__old_ZO_Dialogs_ShowPlatformDialog
			end
		end
	end

	FasterTravel.WfDpatch(_account_settings.WfDpatchEnabled)

    ZO_WorldMap.SetHidden = hook(ZO_WorldMap.SetHidden, function(base, self, value)
	base(self, value)
	if value == false then
	    RefreshWayshrinesIfRequired()
	    RefreshQuestsIfRequired()
	    RefreshPlayersIfRequired()
	elseif value == true and wayshrinesTab ~= nil then
	    wayshrinesTab:HideAllZoneCategories()
	    questTracker:HideToolTip()
	    ClearMenu()
	end
    end)

    local function GetPaths(path, ...)
	return unpack(Utils.map({ ... }, function(p)
	    return path .. p
	end))
    end

    local function AddWorldMapFragment(strId, fragment, normal, highlight, pressed)
	WORLD_MAP_INFO.modeBar:Add(strId, { fragment }, { pressed = pressed, highlight = highlight, normal = normal })
    end

    _locationsLookup = Location.Data.GetLookup()

    _locations = {}

    wayshrinesTab = FasterTravel.MapTabWayshrines(wayshrineControl, _locations, _locationsLookup, recentList, { list = favouritesList, add = AddFavourite, remove = RemoveFavourite })

    playersTab = FasterTravel.MapTabPlayers(playersControl)
    questTracker = FasterTravel.QuestTracker(_locations, _locationsLookup, wayshrinesTab)

    RefreshWayshrineDropDowns()

    -- finally add the controls
    local normal, highlight, pressed = GetPaths("/esoui/art/treeicons/achievements_indexicon_alliancewar_", "up.dds", "over.dds", "down.dds")

    AddWorldMapFragment(SI_MAP_INFO_MODE_WAYSHRINES, wayshrineControl.fragment, normal, highlight, pressed)

    normal, highlight, pressed = GetPaths("/esoui/art/mainmenu/menubar_group_", "up.dds", "over.dds", "down.dds")

    AddWorldMapFragment(SI_MAP_INFO_MODE_PLAYERS, playersControl.fragment, normal, highlight, pressed)

    SetCurrentZoneMapIndexes()

    -- scenes which don't hide themselves on EndInteration.
    local _interactionScenes = { "smithing" }
    local function EndCurrentInteraction()

	local interaction = GetInteractionType()

	if interaction == nil then return end

	local provisionSceneName = ZO_Provisioner_GetVisibleSceneName()

	if provisionScene ~= nil then
	    SCENE_MANAGER:Hide(provisionScene)
	else
	    for i, sceneName in ipairs(_interactionScenes) do
		if SCENE_MANAGER:IsShowing(sceneName) then
		    SCENE_MANAGER:Hide(sceneName)
		end
	    end
	end

	EndInteraction(interaction)
    end

    --- Parses alias arguments for goto slash command. ""
    local function parseAlias(args)
	if not args or args == "" then return end
		args = Utils.stringTrim(args)
	-- Check pattern "SimpleAlphaNumericAlias ValueWithSpacesOrOtherCharacters"
	local key = string.match(args, "^[%d%a]+")
	local value = Utils.stringTrim(args:gsub(key, "", 1))
	return key, value
    end

    --- Tries to teleport to specified destination.
    local function processTeleport(destination)
	-- fix for teleport bug during interactions
	EndCurrentInteraction()

	local result, name
	if GROUP_ALIAS == destination then
	    result, name = Teleport.TeleportToGroup()
	elseif Teleport.IsPlayerTeleportable(destination) == true then
	    result, name = Teleport.TeleportToPlayer(destination)
	else
	    result, name = Teleport.TeleportToZone(destination)
	end

	if result then
	    df("%s Teleporting to %s", _prefix, f.bold(name))
	elseif name ~= nil then
	    df("%s Invalid teleport target %s", _prefix, f.bold(name))
	end
    end

	SLASH_COMMANDS["/goto"] = function(args)
	if Utils.stringIsEmpty(args) then return end

	args = Utils.stringTrim(args)

	local aliasValue = _account_settings.aliases[args]
	if aliasValue then
	    df("%s Alias %s for %s used.", _prefix, f.bold(args), f.bold(aliasValue))
	    processTeleport(aliasValue)
	else
	    processTeleport(args)
	end
    end

    -- Command to remember name macro.
    SLASH_COMMANDS["/agoto"] = function(args)
	local key, value = parseAlias(args)
		if Utils.stringIsEmpty(key) then
			d(f.bold("Aliases:"))
		    for key, value in Utils.pairsByKeys(_account_settings.aliases) do
				df("%s	 %s -> %s", _prefix, f.bold(key), f.bold(value))
			end
	elseif Utils.stringIsEmpty(value) then
			if _account_settings.aliases[key] then
				df("%s GOTO alias %s for %s deleted", _prefix, f.bold(_account_settings.aliases[key]), f.bold(key))
				_account_settings.aliases[key] = nil
			end
		else
	    _account_settings.aliases[key] = value
	    df("%s GOTO alias saved: %s -> %s", _prefix, f.bold(key), f.bold(value))
	end
    end

    SLASH_COMMANDS["/recents"] = function(args)
		if Utils.stringIsEmpty(args) then
			df("%s WfD's patch is %s", _prefix, f.bold(_account_settings.WfDpatchEnabled and "enabled" or "disabled"))
	else
			args = Utils.stringTrim(args)
			if args == "on" then
				_account_settings.WfDpatchEnabled = true
			elseif args == "off" then
				_account_settings.WfDpatchEnabled = false
			else
				df("Sorry, I understand only %s or %s", f.bold("on"), f.bold("off"))
				return
			end
			FasterTravel.WfDpatch(_account_settings.WfDpatchEnabled)
			df("%s WfD's patch %s; reloading UI", _prefix, f.bold(_account_settings.WfDpatchEnabled and "enabled" or "disabled"))
			ReloadUI("ingame")
		end
    end

	df("%s %s initialized with WfD's patch %s (use \"/recents on||off\" to change).", ADDON_NAME, ADDON_VERSION, _account_settings.WfDpatchEnabled and "enabled" or "disabled")
end)


