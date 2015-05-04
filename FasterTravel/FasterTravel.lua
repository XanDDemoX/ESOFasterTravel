
FasterTravel = {}

local function addEvent(id,func)
	EVENT_MANAGER:RegisterForEvent("FasterTravel_"..tostring(id),id,func)
end

local function addCallback(id,func)
	CALLBACK_MANAGER:RegisterCallback(id,func)
end
local function removeCallback(id,func)
	CALLBACK_MANAGER:UnregisterCallback(id,func)
end

local function extend(source,target)
	if source == nil then return {} end
	
	target = target or {}
	
	for k,v in pairs(source) do
		target[k] = v
	end
	
	return {}
end

local function hook(baseFunc,newFunc)
	return function(...)
		return newFunc(baseFunc,...)
	end
end
	
local function addCommand(name,func)
	if string.sub(name,1,string.len("/")) ~= "/" then
		name = "/"..name
	end
	
	if SLASH_COMMANDS[name] ~= nil then
		SLASH_COMMANDS[name] = hook(SLASH_COMMANDS[name],
			function(base,...)
				base(...)
				func(...)
			end)
	else
		SLASH_COMMANDS[name] = func
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

init(function()

	local _prefix = "[FasterTravel]: "
	local Wayshrine = f.Wayshrine
	local Teleport = f.Teleport
	local Location = f.Location
	
	local UI = f.UI
	local Utils = f.Utils
	
	local _locations = {}
	local _locationsLookup = {}
	
	local _settings = {recent={}}

	local wayshrineControl = FasterTravel_WorldMapWayshrines
	local playersControl = FasterTravel_WorldMapPlayers

	_settings = ZO_SavedVars:New("FasterTravel_SavedVariables", "1", "", _settings, nil)
	
	local recentTable = {}
	
	for i,v in ipairs(_settings.recent) do
		table.insert(recentTable,{name=v.name,nodeIndex=v.nodeIndex})
	end
	
	local recentList = f.RecentList(recentTable,"name",5)
	
	local currentZoneIndex
	local currentMapIndex
	local currentNodeIndex
	
	local wayshrinesRefreshRequired = true
	local contactsRefreshRequired = true

	local function SetCurrentZoneMapIndexes(zoneIndex,mapIndex)

		currentZoneIndex = zoneIndex
		
		if zoneIndex == nil then 
			currentMapIndex = nil
		elseif mapIndex == nil then 
			local loc = _locationsLookup[zoneIndex]
		
			if loc ~= nil then 
				currentMapIndex = loc.mapIndex
			end
		elseif mapIndex ~= nil then 
			currentMapIndex = mapIndex
		end 
		
	end
	
	local function IsWayshrineRefreshRequired()
		return wayshrinesRefreshRequired
	end
	
	local function IsContactsRefreshRequired()
		return contactsRefreshRequired
	end
	
	local function SetWayshrinesDirty()
		wayshrinesRefreshRequired = true
	end
	
	local function SetContactsDirty()
		contactsRefreshRequired = true
	end
	
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
			recentList:push("name",{name=name,nodeIndex=nodeIndex})
			_settings.recent = {}
			for i,v in ipairs(recentTable) do
				_settings.recent[i] = {name=v.name,nodeIndex=v.nodeIndex}
			end
			acceptButton.m_callback = acceptButton_m_callback
			cancelButton.m_callback = cancelButton_m_callback
		end
		
		cancelButton.m_callback = function(...)
			if cancelButton_m_callback ~= nil then cancelButton_m_callback(...) end
			acceptButton.m_callback = acceptButton_m_callback
			cancelButton.m_callback = cancelButton_m_callback
		end
	end)
	
	local function ShowWayshrineConfirm(data)
		local nodeIndex,name,refresh,clicked = data.nodeIndex,data.name,data.refresh,data.clicked
		ZO_Dialogs_ReleaseDialog("FAST_TRAVEL_CONFIRM")
		ZO_Dialogs_ReleaseDialog("RECALL_CONFIRM")
		name = name or select(2, GetFastTravelNodeInfo(nodeIndex))
		local isRecall = currentNodeIndex == nil 
		local id = (isRecall == true and "RECALL_CONFIRM") or "FAST_TRAVEL_CONFIRM"
		ZO_Dialogs_ShowPlatformDialog(id, {nodeIndex = nodeIndex}, {mainTextParams = {name}})
	end
	
	local function AddCategory(control,categoryId,item)
		local name,clicked = item.name,item.clicked
		local header = { 
							name=name, 
							refresh = function(self,c) c.label:SetText(self.name) end,
							clicked = function(self,c) 
								if clicked then 
									clicked(self,control,c)
								else
									control:ToggleCategoryHidden(control.list,categoryId) 
								end
							end,
						}
						
		control:AddCategory(control.list,header,categoryId)
	end
	
	local function AddCategories(control,data)
		local categoryId = 1
		local parentId
		for i,item in ipairs(data) do 
			AddCategory(control,categoryId,item)
			if #item.data > 0 then
				control:AddEntries(control.list,item.data,1,categoryId)
				item.categoryId=categoryId
			end
			categoryId = categoryId + 1
		end
	end
	
	local function GetRecentWayshrinesData(args)
		local nodeIndex = args.nodeIndex
		local tbl =  Utils.where(recentTable, function(v) return (nodeIndex == nil or v.nodeIndex ~= nodeIndex) end)
		
		tbl = Utils.map(tbl,function(data)
			data.refresh = function(self,control) control.label:SetText(self.name) end
			data.clicked = function(self,control) ShowWayshrineConfirm(self) end
			return data
		end)
		
		return tbl
	end
	
	local function GetZoneWayshrinesData(args)

		local zoneIndex = args.zoneIndex
		local nodeIndex = args.nodeIndex
	
		local iter = Wayshrine.GetNodesByZoneIndex(zoneIndex)
		
		iter = Utils.where(iter,function(data)
			return data.known and (nodeIndex == nil or data.nodeIndex ~= nodeIndex)
		end)
				
		iter = Utils.map(iter,function(data)
			data.refresh = function(self,control) control.label:SetText(self.name) end
			data.clicked = function(self,control) ShowWayshrineConfirm(self) end
			return data
		end)
		
		local data = Utils.toTable(iter)
		
		table.sort(data,function(x,y) return x.name < y.name end)
		
		return data
	end
	
	local function RefreshControl(control,categories)
		if control == nil then return end
		control:Refresh(control.list)
		if categories == nil then return end
		for i,item in ipairs(categories) do
			control:SetCategoryHidden(control.list,item.categoryId,item.hidden)
		end
	end
	

	
	local _wsfirst = true
	local _ctfirst = true 
	
	local function RefreshWayshrines(nodeIndex)

		local recent = GetRecentWayshrinesData({nodeIndex=nodeIndex})
		local current = GetZoneWayshrinesData({nodeIndex=nodeIndex, zoneIndex = currentZoneIndex})
		
		local categories ={
			{
				name = GetString(SI_MAP_INFO_WAYSHRINES_CATEGORY_RECENT), 
				data = recent,
				hidden= not _wsfirst and wayshrineControl:GetCategoryHidden(wayshrineControl.list,1)
			},
			{	
				name = GetString(SI_MAP_INFO_WAYSHRINES_CATEGORY_CURRENT).." ("..GetZoneNameByIndex(currentZoneIndex)..")",
				data = current, 
				hidden = not _wsfirst and wayshrineControl:GetCategoryHidden(wayshrineControl.list,2),
				clicked=function(self)
					local idx = GetCurrentMapIndex()
					if idx ~= currentMapIndex then 
						ZO_WorldMap_SetMapByIndex(currentMapIndex) 
						if wayshrineControl:GetCategoryHidden(wayshrineControl.list,2) == true then 
							wayshrineControl:SetCategoryHidden(wayshrineControl.list,2,false)
						end
					elseif idx == currentMapIndex then
						wayshrineControl:ToggleCategoryHidden(wayshrineControl.list,2)
					end
				end
			}
		}
		
		local locations = _locations
		if locations ~= nil then 
			local data 
			for i,item in ipairs(locations) do
				data = GetZoneWayshrinesData({nodeIndex=nodeIndex, zoneIndex=item.zoneIndex})
				table.insert(categories,{name = item.name, hidden=_wsfirst or wayshrineControl:GetCategoryHidden(wayshrineControl.list,i+2),data=data, clicked= function(self) 
					local idx = GetCurrentMapIndex()
					if idx ~= item.mapIndex then 
						ZO_WorldMap_SetMapByIndex(item.mapIndex) 
						if wayshrineControl:GetCategoryHidden(wayshrineControl.list,i+2) == true then 
							wayshrineControl:SetCategoryHidden(wayshrineControl.list,i+2,false)
						end
					elseif idx == item.mapIndex then 
						wayshrineControl:ToggleCategoryHidden(wayshrineControl.list,i+2)
					end
				end })
			end
		end
		

		wayshrineControl:Clear(wayshrineControl.list)
		
		AddCategories(wayshrineControl,categories)
		
		RefreshControl(wayshrineControl,categories)
		_wsfirst = false 
	end
	
	local function RefreshContacts(nodeIndex)
		local group = Teleport.GetGroupInfo()
		local friends = Teleport.GetFriendsInfo()
		
		local addHandlers = function(data)
			data.refresh = function(self,control) control.label:SetText(self.name.." ["..self.zoneName.."] ") end
			data.clicked = function(self,control) Teleport.TeleportToPlayer(self.name) ZO_WorldMap_HideWorldMap() end
			return data
		end
		
		group = Utils.map(group,addHandlers)
		friends = Utils.map(friends,addHandlers)
		
		local zones = {}
		local categories ={
		
			{name = GetString(SI_MAP_INFO_PLAYERS_CATEGORY_GROUP).." ("..tostring(#group)..")", data = group, hidden= not _ctfirst and playersControl:GetCategoryHidden(playersControl.list,1)},
			{name = GetString(SI_MAP_INFO_PLAYERS_CATEGORY_FRIENDS).." ("..tostring(#friends)..")",data = friends, hidden= not _ctfirst and playersControl:GetCategoryHidden(playersControl.list,2)},
			{name = GetString(SI_MAP_INFO_PLAYERS_CATEGORY_ZONE),data=zones,hidden= not _ctfirst and playersControl:GetCategoryHidden(playersControl.list,3)}
		}
		
		local _lookup = {}
		local gCount = GetNumGuilds()
		local id
		local name,data
		for i=1, gCount do 
			id = GetGuildId(i)
			name = GetGuildName(id)
			data = Teleport.GetGuildPlayers(id)
			data = Utils.map(data,function(d) 
				local zoneName = d.zoneName
				local zone = _lookup[zoneName]
				if zone == nil then
					zone = {}
					_lookup[zoneName] = zone
				end
				table.insert(zone,{name=d.name})
				return addHandlers(d) 
			end)
			table.insert(categories,{name=name.." ("..tostring(#data)..")",data=data,hidden=_ctfirst or playersControl:GetCategoryHidden(playersControl.list,i+3)})
		end

		for k,v in pairs(_lookup) do
			table.insert(zones,{name=k.." ("..tostring(#v)..")",
								zoneName = k,
								refresh = function(self,control) control.label:SetText(self.name) end,
								clicked = function(self,control) 
									local result,zoneName = Teleport.TeleportToZone(self.zoneName)
									if result == true then 
										ZO_WorldMap_HideWorldMap()
									end
								end})
		end
		
		table.sort(zones,function(x,y) return x.zoneName < y.zoneName end)
		
		playersControl:Clear(playersControl.list)
		
		AddCategories(playersControl,categories)
		
		RefreshControl(playersControl,categories)
		
		_ctfirst = false 
		
	end
	
	local function RefreshContactsIfRequired(nodeIndex)
		if IsContactsRefreshRequired() == true then 
			RefreshContacts(nodeIndex)
			contactsRefreshRequired = false
		end
	end

	local function RefreshWayshrinesIfRequired(nodeIndex)
		if IsWayshrineRefreshRequired() == true then
			RefreshWayshrines(nodeIndex)
			wayshrinesRefreshRequired = false
		end
	end
	
	local function AddWorldMapFragment(strId,fragment,normal,highlight,pressed)
	    WORLD_MAP_INFO.modeBar:Add(strId, { fragment }, {pressed = pressed,highlight =highlight,normal = normal})
	end
	
	ZO_WorldMap.SetHidden = hook(ZO_WorldMap.SetHidden,function(base,self,value)
		base(self,value)
		if value == true then
			SetCurrentZoneMapIndexes(nil)
		else
		
			SetCurrentZoneMapIndexes(GetCurrentMapZoneIndex())

			RefreshWayshrinesIfRequired() 

			RefreshContactsIfRequired()
		end
	end)
	
	local _refreshFunc =  function() 
		if currentZoneIndex == nil and currentMapIndex == nil then -- prevent refresh whilst player is changing map
			SetWayshrinesDirty()
		end
	end
	
	if _settings.locations == nil or _settings.locationsLookup == nil then 
		local locationFunc  
		-- hack for zoneIndexes
		locationFunc = Location.GetLocations(function(locations,zoneIndex,mapIndex)
			
			removeCallback("OnWorldMapChanged",locationFunc)
			
			_locations = locations
			_settings.locations = locations
			
			_locationsLookup = Location.CreateLocationsLookup(locations)
			
			_settings.locationsLookup = _locationsLookup
			
			addCallback("OnWorldMapChanged",_refreshFunc)
			
			SetCurrentZoneMapIndexes(zoneIndex)
			RefreshWayshrinesIfRequired()

			d(_prefix.."First run location data initialised...")
		end)
		
		addCallback("OnWorldMapChanged",locationFunc)
	else
		_locations = _settings.locations
		_locationsLookup = _settings.locationsLookup
		addCallback("OnWorldMapChanged",_refreshFunc)
	end


	addEvent(EVENT_START_FAST_TRAVEL_INTERACTION, function(eventCode,nodeIndex)
		currentNodeIndex = nodeIndex
		SetWayshrinesDirty()
		WORLD_MAP_INFO:SelectTab(SI_MAP_INFO_MODE_WAYSHRINES)
	end)
	
	addEvent(EVENT_END_FAST_TRAVEL_INTERACTION,function(eventCode)
		currentNodeIndex = nil
		SetWayshrinesDirty()
	end)
	
	addEvent(EVENT_FAST_TRAVEL_NETWORK_UPDATED,function(eventCode,nodeIndex)
		SetWayshrinesDirty()
	end)
	
	addEvent(EVENT_FRIEND_ADDED,function(eventCode)
		SetContactsDirty()
	end)
	
	addEvent(EVENT_FRIEND_REMOVED,function(eventCode,DisplayName)
		SetContactsDirty()
	end)
	
	addEvent(EVENT_FRIEND_CHARACTER_ZONE_CHANGED,function(eventCode, DisplayName, CharacterName, newZone)
		SetContactsDirty()
	end)
	
	addEvent(EVENT_GROUP_INVITE_RESPONSE,function(eventCode, inviterName, response)
		if response == GROUP_INVITE_RESPONSE_ACCEPTED then
			SetContactsDirty()
		end
	end)
	
	addEvent(EVENT_GROUP_MEMBER_JOINED,function(eventCode,memberName)
		SetContactsDirty()
	end)
	
	addEvent(EVENT_GROUP_MEMBER_LEFT,function(eventCode,memberName,reason,wasLocalPlayer)
		SetContactsDirty()
	end)
	
	addEvent(EVENT_GUILD_MEMBER_ADDED,function(eventCode, guildId, DisplayName)
		SetContactsDirty()
	end)
	
	addEvent(EVENT_GUILD_MEMBER_REMOVED,function(eventCode,guildId, DisplayName, CharacterName)
		SetContactsDirty()
	end)
	
	addEvent(EVENT_GROUP_MEMBER_CONNECTED_STATUS,function(eventCode, unitTag, isOnline)
		SetContactsDirty()
	end)
	
	addEvent(EVENT_GUILD_SELF_JOINED_GUILD,function(eventCode, guildId, guildName)
		SetContactsDirty()
	end)
	
	addEvent(EVENT_GUILD_SELF_LEFT_GUILD,function(eventCode, guildId, guildName)
		SetContactsDirty()
	end)
	
	addEvent(EVENT_GUILD_MEMBER_CHARACTER_ZONE_CHANGED,function(eventCode, guildId, DisplayName, CharacterName, newZone)
		SetContactsDirty()
	end)
	
	addEvent(EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED,function(eventCode, guildId, DisplayName, oldStatus, newStatus)
		if newStatus == PLAYER_STATUS_OFFLINE or (oldStatus == PLAYER_STATUS_OFFLINE and newStatus == PLAYER_STATUS_ONLINE) then
			SetContactsDirty()
		end
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
	

	
end)


