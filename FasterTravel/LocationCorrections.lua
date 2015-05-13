
local Location = FasterTravel.Location
local Corrections = {}
Location.Corrections = Corrections

local _extraLocations ={
	{
		zoneIndex = 100,
		path = "Art/maps/guildmaps/eyevea_base_0.dds",
		click = function()        
			zo_callLater(function() 
				ProcessMapClick(0.077777777777778,0.58395061728395)
				CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
			end,1)
		end
	}
}

local function UpdateLocations(locations)
	for i,loc in ipairs(_extraLocations) do 
		loc.name = GetZoneNameByIndex(loc.zoneIndex)
		loc.key,loc.zone,loc.subzone = Location.GetMapZoneKey(loc.path)
		table.insert(locations,loc)
	end
	return locations
end 

local c = Corrections
c.UpdateLocations = UpdateLocations