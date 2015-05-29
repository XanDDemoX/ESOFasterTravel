
--xml backend

local MapWayshrines = FasterTravel_WorldMapWayshrines
FasterTravel.WorldMapInfoControl.Initialise(MapWayshrines)

MapWayshrines.rowOffsetX = 20

function MapWayshrines:IconMouseEnter(...)

end

function MapWayshrines:IconMouseExit(...)

end

function MapWayshrines:IconMouseDown(icon, button,data )
    if(button == 1) then
	
	end
end

function MapWayshrines:IconMouseUp(icon, button,data)
    if(button == 1) then
		self:IconMouseClicked(icon,data)
	end
end

function MapWayshrines:IconMouseClicked(...)

end


function MapWayshrines:RowMouseEnter(control, label,data)
	ZO_SelectableLabel_OnMouseEnter(label)

end 

function MapWayshrines:RowMouseExit(control,label,data)
	ZO_SelectableLabel_OnMouseExit(label)

end

function MapWayshrines:OnRefreshRow(control,data)
	local icon = control.icon 
	
	control.RowMouseEnter = function(c,label) self:RowMouseEnter(c,label,data) end 
	control.RowMouseExit = function(c,label) self:RowMouseExit(c,label,data) end
	
	if icon then
	
		control.IconMouseEnter = function(c,icon) self:IconMouseEnter(icon,data) end 
		control.IconMouseExit = function(c,icon) self:IconMouseExit(icon,data) end 
		control.IconMouseDown = function(c,icon,button) self:IconMouseDown(icon,button,data) end 
		control.IconMouseUp = function(c,icon,button) self:IconMouseUp(icon,button,data) end 
		
		icon:SetHidden((data == nil or data.iconHidden == nil or (data.iconHidden ~= nil and data.iconHidden == true)))
		
		if data.iconPath ~= nil then 
			icon:SetResizeToFitFile(false)
			icon:SetTexture(data.iconPath)
		end 
	end
end

