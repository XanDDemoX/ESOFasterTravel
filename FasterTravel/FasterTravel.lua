
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

--[[f.addEvent = addEvent
f.hook = hook
f.addCommand = addCommand]]--



init(function()

	local _prefix = "[FasterTravel]: "
	local Wayshrine = f.Wayshrine
	local Teleport = f.Teleport
	local UI = f.UI
	local Utils = f.Utils
	
	local _settings = {recent={}}

	local GetRecallCost = GetRecallCost
	local FastTravelToNode = FastTravelToNode
	
	local wayshrineControl = FasterTravel_WorldMapWayshrines
	local playersControl = FasterTravel_WorldMapPlayers

	_settings = ZO_SavedVars:New("FasterTravel_SavedVariables", "1", "", _settings, nil)
	
	local recentTable = {}
	
	for i,v in ipairs(_settings.recent) do
		table.insert(recentTable,{name=v.name,nodeIndex=v.nodeIndex})
	end
	
	local recentList = f.RecentList(recentTable,"name",5)
	
	ZO_CreateStringId("SI_MAP_INFO_MODE_WAYSHRINES","Wayshrines")
	ZO_CreateStringId("SI_MAP_INFO_MODE_PLAYERS","Players")
	
	ZO_CreateStringId("SI_MAP_INFO_WAYSHRINES_CATEGORY_RECENT","Recent")
	ZO_CreateStringId("SI_MAP_INFO_WAYSHRINES_CATEGORY_CURRENT","Current")
	
	ZO_CreateStringId("SI_MAP_INFO_PLAYERS_CATEGORY_FRIENDS","Friends")
	ZO_CreateStringId("SI_MAP_INFO_PLAYERS_CATEGORY_GROUP","Group")
	ZO_CreateStringId("SI_MAP_INFO_PLAYERS_CATEGORY_ZONE","Zone")

	local currentZoneIndex
	local currentMapIndex
	local currentNodeIndex
	
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
	
	local function ShowWayshrineConfirm(data,isRecall)
		local nodeIndex,name,refresh,clicked = data.nodeIndex,data.name,data.refresh,data.clicked
		ZO_Dialogs_ReleaseDialog("FAST_TRAVEL_CONFIRM")
		ZO_Dialogs_ReleaseDialog("RECALL_CONFIRM")
		name = name or select(2, GetFastTravelNodeInfo(nodeIndex))
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
		local isRecall = nodeIndex == nil
		
		tbl = Utils.map(tbl,function(data)
			data.refresh = function(self,control) control.label:SetText(self.name) end
			data.clicked = function(self,control) ShowWayshrineConfirm(self,isRecall) end
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
		
		local isRecall = nodeIndex == nil
		
		iter = Utils.map(iter,function(data)
			data.refresh = function(self,control) control.label:SetText(self.name) end
			data.clicked = function(self,control) ShowWayshrineConfirm(self,isRecall) end
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
	
	local _locations = {}
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
	
	local function AddWorldMapFragment(strId,fragment,normal,highlight,pressed)
	    WORLD_MAP_INFO.modeBar:Add(strId, { fragment }, {pressed = pressed,highlight =highlight,normal = normal})
	end
	
	ZO_WorldMap.SetHidden = hook(ZO_WorldMap.SetHidden,
	function(base,self,value)
		base(self,value)
		if value == true then
			currentZoneIndex = nil
			currentMapIndex = nil
		else
			currentZoneIndex = GetCurrentMapZoneIndex()
			currentMapIndex = GetCurrentMapIndex()
			RefreshWayshrines(currentNodeIndex) 
			RefreshContacts(currentNodeIndex)
		end
	end)
	
	_locations = _settings.locations or Wayshrine.GetLocations()
	
	local cur = 0
	local count = #_locations
	local _zoneIndexFunc 
	
	
	local _curIndex 
	
	local _refreshFunc =  function() 
		if currentZoneIndex == nil and currentMapIndex == nil then -- prevent refresh whilst player is changing map
			RefreshWayshrines(currentNodeIndex) 
		end
	end
	
	local _mouseClickQuest,_mouseDownLoc,_mouseUpLoc =WORLD_MAP_QUESTS.QuestHeader_OnClicked,WORLD_MAP_LOCATIONS.RowLocation_OnMouseDown,WORLD_MAP_LOCATIONS.RowLocation_OnMouseUp
	
	-- hack to get location zoneIndexes by changing the map and using GetCurrentMapZoneIndex() (eugh >_<)
	_zoneIndexFunc = function()
		if cur == 0 then
			WORLD_MAP_QUESTS.QuestHeader_OnClicked = function() end -- prevent mouse use on map locations whilst this is happening.
			WORLD_MAP_LOCATIONS.RowLocation_OnMouseDown = function() end 
			WORLD_MAP_LOCATIONS.RowLocation_OnMouseUp = function() end
			_curIndex = GetCurrentMapIndex()
			cur = cur + 1
			ZO_WorldMap_SetMapByIndex(_locations[cur].mapIndex)
			return
		end
		
		_locations[cur].zoneIndex = GetCurrentMapZoneIndex()
		
		if cur >= count then
			removeCallback("OnWorldMapChanged",_zoneIndexFunc)
			addCallback("OnWorldMapChanged",_refreshFunc) -- remove this func attach normal refresh func restore initial map
			ZO_WorldMap_SetMapByIndex(_curIndex)
			_settings.locations = _locations -- save to settings to avoid doing this again - this will need cleaning if new locations are added!
			WORLD_MAP_QUESTS.QuestHeader_OnClicked = _mouseClickQuest -- restore mouse use
			WORLD_MAP_LOCATIONS.RowLocation_OnMouseDown = _mouseDownLoc
			WORLD_MAP_LOCATIONS.RowLocation_OnMouseUp = _mouseUpLoc
			d(_prefix.."First run location data initialised...")
		elseif cur > 0 and cur < count then 
			cur = cur + 1
			ZO_WorldMap_SetMapByIndex(_locations[cur].mapIndex)
		end
	end
	
	if _settings.locations == nil then 
		addCallback("OnWorldMapChanged",_zoneIndexFunc)
	else
		addCallback("OnWorldMapChanged",_refreshFunc)
	end

	addEvent(EVENT_START_FAST_TRAVEL_INTERACTION, function(eventCode,nodeIndex)
		currentNodeIndex = nodeIndex
		RefreshWayshrines(nodeIndex)	
		RefreshContacts(nodeIndex)
		WORLD_MAP_INFO:SelectTab(SI_MAP_INFO_MODE_WAYSHRINES)
	end)
	
	addEvent(EVENT_END_FAST_TRAVEL_INTERACTION,function(eventCode)
		currentNodeIndex = nil
	end)
	
	addEvent(EVENT_FAST_TRAVEL_NETWORK_UPDATED,function(eventCode,nodeIndex)
		RefreshWayshrines()
	end)
	
	addEvent(EVENT_JUMP_FAILED,function(eventCode,reason)
		d("Failed "..tostring(reason))
	end)
	
	FastTravelToNode = hook(FastTravelToNode,function(base,nodeIndex)
		base(nodeIndex)
		d("Travel "..tostring(nodeIndex))
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


