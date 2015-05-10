
local MapTabWayshrines = FasterTravel.class(FasterTravel.MapTab)
FasterTravel.MapTabWayshrines = MapTabWayshrines

local Location = FasterTravel.Location
local Wayshrine = FasterTravel.Wayshrine
local Utils = FasterTravel.Utils


local function ShowWayshrineConfirm(data,isRecall)
	local nodeIndex,name,refresh,clicked = data.nodeIndex,data.name,data.refresh,data.clicked
	ZO_Dialogs_ReleaseDialog("FAST_TRAVEL_CONFIRM")
	ZO_Dialogs_ReleaseDialog("RECALL_CONFIRM")
	name = name or select(2, GetFastTravelNodeInfo(nodeIndex))
	local id = (isRecall == true and "RECALL_CONFIRM") or "FAST_TRAVEL_CONFIRM"
	ZO_Dialogs_ShowPlatformDialog(id, {nodeIndex = nodeIndex}, {mainTextParams = {name}})
end

local function AttachWayshrineDataHandlers(args, data)
	local refresh = args.refresh
	local clicked = args.clicked

	data.refresh = function(self,control) 
		control.label:SetText(self.name) 
		if refresh then
			refresh(self,control)
		end
	end
	data.clicked = function(self,control) 

		ShowWayshrineConfirm(self,args.nodeIndex == nil) 

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

local function GetZoneWayshrinesData(args)

	local zoneIndex = args.zoneIndex
	local nodeIndex = args.nodeIndex

	local iter = Wayshrine.GetKnownWayshrinesByZoneIndex(zoneIndex,nodeIndex)
			
	iter = Utils.map(iter,function(d) return AttachWayshrineDataHandlers(args,d) end)
	
	local data = Utils.toTable(iter)
	
	table.sort(data,function(x,y) return x.name < y.name end)
	
	return data
end


local function GetRecentWayshrinesData(recentList,args)
	local nodeIndex = args.nodeIndex

	local iter =  Utils.where(recentList:items(), function(v) return (nodeIndex == nil or v.nodeIndex ~= nodeIndex) end)
	
	iter = Utils.map(iter,function(d) return AttachWayshrineDataHandlers(args,d) end)
	
	return Utils.toTable(iter)
end

local function GetCurrentWayshrinesData(locationsLookup, currentlookup,zoneIndex,nodeIndex)
	if Location.IsCurrentZoneCyrodiil(locationsLookup) == true then 
		return {}
	else
		return GetZoneWayshrinesData({
									nodeIndex=nodeIndex, 
									zoneIndex = zoneIndex,
									refresh = function(self,control) AddRowToLookup(self,control,currentlookup) end
								})
	end 
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
	
	control.IconMouseClicked = FasterTravel.hook(control.iconMouseClicked,function(base,control,...)
		base(control,...)
		
	end)

	
	local _first = true
	
	local _rowLookup = {}
	
	local currentZoneIndex
	local currentMapIndex
	
	local _locations = locations
	local _locationsLookup = locationsLookup
	
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
	
	self.Refresh = function(self,nodeIndex)
		_rowLookup.categories ={}
		_rowLookup.current = {}
		_rowLookup.recent = {}
		_rowLookup.zone = {}

		local recentlookup = _rowLookup.recent
		local currentlookup = _rowLookup.current
		
		local recent = GetRecentWayshrinesData(recentList,{nodeIndex=nodeIndex, refresh=function(self,control) AddRowToLookup(self,control,recentlookup) end})
		
		local current = GetCurrentWayshrinesData(locationsLookup,currentlookup,currentZoneIndex,nodeIndex)
			
		local curName = _locationsLookup[currentZoneIndex].name
		
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
				clicked=function(data,control,c) HandleCategoryClicked(self,2,{zoneIndex=currentZoneIndex,mapIndex=currentMapIndex},currentlookup,data,control,c) end
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

				local data = GetZoneWayshrinesData({nodeIndex=nodeIndex, zoneIndex=item.zoneIndex,refresh = function(self,control) AddRowToLookup(self,control,lookup) end})
				
				PopualteLookup(lookup,data)
				
				local category = {
					name = item.name, 
					hidden = _first or self:IsCategoryHidden(id),
					data=data, 
					clicked= function(data,control,c) 
					
						HandleCategoryClicked(self,id,item,lookup,data,control,c) 
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
	
end

function MapTabWayshrines:OnCategoryClicked(i,item,lookup,data,control,c)

end

function MapTabWayshrines:IconMouseEnter(...)

end

function MapTabWayshrines:IconMouseExit(...)

end