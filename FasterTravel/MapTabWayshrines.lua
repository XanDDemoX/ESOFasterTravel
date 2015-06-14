
local MapTabWayshrines = FasterTravel.class(FasterTravel.MapTab)
FasterTravel.MapTabWayshrines = MapTabWayshrines

local Location = FasterTravel.Location
local Wayshrine = FasterTravel.Wayshrine
local Transitus = FasterTravel.Transitus
local Campaign = FasterTravel.Campaign
local Utils = FasterTravel.Utils


local function ShowWayshrineConfirm(data,isRecall)

	local nodeIndex,name,refresh,clicked = data.nodeIndex,data.name,data.refresh,data.clicked
	
	ZO_Dialogs_ReleaseDialog("FAST_TRAVEL_CONFIRM")
	ZO_Dialogs_ReleaseDialog("RECALL_CONFIRM")
	
	name = name or select(2, Wayshrine.Data.GetNodeInfo(nodeIndex)) -- just in case
	
	local id = (isRecall == true and "RECALL_CONFIRM") or "FAST_TRAVEL_CONFIRM"
	
	if isRecall == true then 
		local _, timeLeft = GetRecallCooldown()
		if timeLeft ~= 0 then
			local text = zo_strformat(SI_FAST_TRAVEL_RECALL_COOLDOWN, name, ZO_FormatTimeMilliseconds(timeLeft, TIME_FORMAT_STYLE_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS))
		    ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, text)
			return
		end
	end 
	
	ZO_Dialogs_ShowPlatformDialog(id, {nodeIndex = nodeIndex}, {mainTextParams = {name}})
	
end

local function ShowTransitusConfirm(data,isRecall)
	if isRecall == true then return end
	TravelToKeep(data.nodeIndex)
end

local function AttachRefreshHandler(args,data)
	local refresh = args.refresh
	data.refresh = function(self,control) 
		control.label:SetText(self.name) 
		if refresh then
			refresh(self,control)
		end
	end
end

local function AttachWayshrineDataHandlers(args, data)

	AttachRefreshHandler(args,data)

	local clicked = args.clicked
	
	local isRecall = args.nodeIndex == nil
	local isKeep = args.isKeep
	local inCyrodiil = args.inCyrodiil
	
	data.clicked = function(self,control) 
	
		if inCyrodiil == true and (isRecall == true or isKeep == true) then return end
	
		ShowWayshrineConfirm(self,isRecall) 

	end
	
	return data
end

local function AttachTransitusDataHandlers(args,data)
	
	AttachRefreshHandler(args,data)
	
	local clicked = args.clicked

	data.clicked = function(self,control) 

		ShowTransitusConfirm(self,args.nodeIndex == nil) 

	end
	
	return data
end 

local function AttachCampaignDataHandlers(args,data)
	AttachRefreshHandler(args,data)
	
	data.clicked = function(self,control) 
		local id,name,group,isGroup = data.id,data.name,data.group,data.isGroup
		Campaign.EnterLeaveOrJoin(id,name,group,isGroup)
	end
	
	return data 
end

local function AddRowToLookup(self,control,lookup)
	local nidx = self.nodeIndex
	local lk = lookup[nidx]
	if lk == nil then 
		lookup[nidx] = {control=control,data=self}
	else
		lk.control = control
		lk.data = self 
	end
end

local function IsTransitusDataRequired(isKeep,nodeIndex)
	return (isKeep or nodeIndex == nil)
end

local function GetCyrodiilWayshrinesData(args)
	local nodes = Transitus.GetKnownNodes(args.nodeIndex)
	
	nodes = Utils.map(nodes,function(item) 
		return AttachTransitusDataHandlers(args,item) 
	end)

	return nodes
end

local function GetPlayerCampaignsData(args)
	-- TODO: return player campaigns
	
	local nodes = Campaign.GetPlayerCampaigns()
	
	nodes = Utils.map(nodes,function(item)
		return AttachCampaignDataHandlers(args,item)
	end)
	
	return nodes
end 

local function GetZoneWayshrinesData(args)

	local zoneIndex = args.zoneIndex
	local nodeIndex = args.nodeIndex
	local isKeep = args.isKeep
	
	local inCyrodiil = args.inCyrodiil 
	
	-- special handling for Cyrodiil =(
	if Location.Data.IsZoneIndexCyrodiil(zoneIndex) == true then
		if inCyrodiil == true and IsTransitusDataRequired(isKeep,nodeIndex) == true then 
			return GetCyrodiilWayshrinesData(args)
		elseif inCyrodiil == false then 
			return GetPlayerCampaignsData(args)
		end
	end
	
	local iter = Wayshrine.GetKnownWayshrinesByZoneIndex(zoneIndex,nodeIndex)
			
	iter = Utils.map(iter,function(item) 
		return AttachWayshrineDataHandlers(args,item) 
	end)
	
	local data = Utils.toTable(iter)
	
	table.sort(data,function(x,y) return x.name < y.name end)
	
	return data
end


local function GetRecentWayshrinesData(recentList,args)
	local nodeIndex = args.nodeIndex

	local iter =  Utils.where(recentList:items(), function(v) return (nodeIndex == nil or v.nodeIndex ~= nodeIndex) end)
	
	iter = Utils.map(iter,function(d) 
	
		local known,name = Wayshrine.Data.GetNodeInfo(d.nodeIndex)
		
		d.name = name
	
		return AttachWayshrineDataHandlers(args,d) 
	end)
	
	return Utils.toTable(iter)
end

					
local function HandleCategoryClicked(self,i,item,data,control,c)
	local idx = GetCurrentMapIndex()

	if idx ~= item.mapIndex then 
		if self:IsCategoryHidden(i) == true then 
			self:SetCategoryHidden(i,false)
		end
		ZO_WorldMap_SetMapByIndex(item.mapIndex)
	else
		self:SetCategoryHidden(i, not self:IsCategoryHidden(i) )
	end
	self:OnCategoryClicked(i,item,data,control,c)
end

local function PopualteLookup(lookup,data)
	
	for i,node in ipairs(data) do
		lookup[node.nodeIndex] = {data=node}
	end
	
end

function MapTabWayshrines:init(control,locations,locationsLookup,recentList)
	self.base.init(self,control)	
	
	control.IconMouseEnter = FasterTravel.hook(control.IconMouseEnter,function(base,control,...) 
		base(control,...)
		self:IconMouseEnter(...)
	end)
	
	control.IconMouseExit = FasterTravel.hook(control.IconMouseExit,function(base,control,...)
		base(control,...)
		self:IconMouseExit(...)
	end)
	
	control.IconMouseClicked = FasterTravel.hook(control.IconMouseClicked,function(base,control,...)
		base(control,...)
		self:IconMouseClicked(...)
	end)

	control.RowMouseEnter = FasterTravel.hook(control.RowMouseEnter,function(base,control,...)
		base(control,...)
		self:RowMouseEnter(...)
	end)
	
	control.RowMouseExit = FasterTravel.hook(control.RowMouseExit,function(base,control,...)
		base(control,...)
		self:RowMouseExit(...)
	end)
	
	control.RowMouseClicked = FasterTravel.hook(control.RowMouseClicked,function(base,control,...)
		base(control,...)
		self:RowMouseClicked(...)
	end)
	
	local _first = true
	
	local _rowLookup = {}
	
	local currentZoneIndex
	local currentMapIndex
	
	local _locations = locations
	local _locationsLookup = locationsLookup
	
	local currentNodeIndex,currentIsKeep, currentInCyrodiil
	
	self.IsRecall = function(self)
		return currentNodeIndex == nil
	end
	
	self.IsKeep = function(self)
		return currentIsKeep
	end
	
	self.InCyrodiil = function(self)
		return currentInCyrodiil
	end 
	
	self.GetRowLookups = function(self)
		return _rowLookup
	end
	
	self.GetCurrentZoneMapIndexes = function(self)
		return currentZoneIndex,currentMapIndex
	end
	
	self.SetCurrentZoneMapIndexes = function(self,zoneIndex,mapIndex)
		
		currentZoneIndex = zoneIndex
		
		if zoneIndex == nil then 
			currentMapIndex = nil
		elseif mapIndex == nil then 
			loc = locationsLookup[zoneIndex]
			if loc ~= nil then 
				currentMapIndex = loc.mapIndex
			end
		elseif mapIndex ~= nil then 
			currentMapIndex = mapIndex
		end 
		
	end
	
	self.Refresh = function(self,nodeIndex,isKeep)
		_rowLookup.categories ={}
		_rowLookup.current = {}
		_rowLookup.recent = {}
		_rowLookup.zone = {}
		
		isKeep = isKeep == true 
		
		currentNodeIndex = nodeIndex
		currentIsKeep = isKeep
		
		local inCyrodiil = IsInCampaign() or IsInCyrodiil() or IsInImperialCity() or Location.Data.IsZoneIndexCyrodiil(currentZoneIndex)
		
		currentInCyrodiil = inCyrodiil
		
		local recentlookup = _rowLookup.recent
		local currentlookup = _rowLookup.current
		
		local recent = GetRecentWayshrinesData(recentList,{nodeIndex=nodeIndex, refresh=function(self,control) AddRowToLookup(self,control,recentlookup) end})
		
		local current = GetZoneWayshrinesData({nodeIndex = nodeIndex, zoneIndex = currentZoneIndex, isKeep = isKeep, inCyrodiil = inCyrodiil, refresh=function(self,control) AddRowToLookup(self,control,currentlookup) end})
		
		local curLoc = _locationsLookup[currentZoneIndex] or _locationsLookup["tamriel"]
		local curName = curLoc.name
		
		local categories ={
			{
				name = GetString(SI_MAP_INFO_WAYSHRINES_CATEGORY_RECENT), 
				data = recent,
				hidden= not _first and self:IsCategoryHidden(1)
			},
			{	
				name = GetString(SI_MAP_INFO_WAYSHRINES_CATEGORY_CURRENT).." ("..curName..")",
				data = current, 
				hidden = not _first and self:IsCategoryHidden(2),
				clicked=function(data,control,c) 
					HandleCategoryClicked(self,2,{zoneIndex=currentZoneIndex,mapIndex=currentMapIndex},currentlookup,data,control,c) 
					if self:IsCategoryHidden(2) == false and curLoc.click then 
						curLoc.click()
					end
				end
			}
		}
		
		PopualteLookup(recentlookup,recent)
		
		PopualteLookup(currentlookup,current)
		
		local count = #categories
		
		local zoneLookup = _rowLookup.zone
		
		local locations = _locations
		
		local categoryLookup = _rowLookup.categories
		
		if locations ~= nil then 
		
			local lcount = #locations
		
			for i,item in ipairs(locations) do
				local id = i + count
				local lookup = {}
				zoneLookup[item.zoneIndex]=lookup

				local data = GetZoneWayshrinesData({nodeIndex=nodeIndex,isKeep=isKeep, zoneIndex=item.zoneIndex, inCyrodiil = inCyrodiil ,refresh = function(self,control) AddRowToLookup(self,control,lookup) end})
				
				PopualteLookup(lookup,data)
				
				local category = {
					name = item.name, 
					hidden = _first or self:IsCategoryHidden(id),
					data=data, 
					clicked= function(data,control,c) 
					
						HandleCategoryClicked(self,id,item,lookup,data,control,c) 
						if item.click then 
							item.click()
						end
						if self:IsCategoryHidden(id) == false then 
							for ii=count+1,lcount do
								if ii ~= id and self:IsCategoryHidden(ii) == false then
									self:SetCategoryHidden(ii,true)
								end
							end
						end
					end,
					zoneIndex = item.zoneIndex
				}
				
				table.insert(categories,category)
			end
		end
		
		self:ClearControl()

		local cdata = self:AddCategories(categories)
		
		self:RefreshControl(categories)
		
		for i,c in ipairs(cdata) do
			if c.zoneIndex ~= nil then 
				categoryLookup[c.zoneIndex] = c
			end
		end 
		
		_rowLookup.categoriesTable = cdata
		
		_first = false 
	
	end
	
	self.HideAllZoneCategories = function(self)
		for i, loc in ipairs(locations) do 
			self:SetCategoryHidden(i+2,true)
		end 
	end 
	
end

function MapTabWayshrines:OnCategoryClicked(i,item,lookup,data,control,c)

end

function MapTabWayshrines:IconMouseEnter(...)

end

function MapTabWayshrines:IconMouseExit(...)

end

function MapTabWayshrines:IconMouseClicked(...)

end 

function MapTabWayshrines:RowMouseEnter(...)

end

function MapTabWayshrines:RowMouseExit(...)

end

function MapTabWayshrines:RowMouseClicked(...)

end