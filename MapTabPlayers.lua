local MapTabPlayers = FasterTravel.class(FasterTravel.MapTab)

FasterTravel.MapTabPlayers = MapTabPlayers

local Teleport = FasterTravel.Teleport
local Utils = FasterTravel.Utils

function MapTabPlayers:init(control)
    self.base.init(self, control)

    local _first = true

    local addHandlers = function(data)
        data.refresh = function(self, control) control.label:SetText(self.tag .. " [" .. self.zoneName .. "] ") end
        data.clicked = function(self, control) Teleport.TeleportToPlayer(self.tag) ZO_WorldMap_HideWorldMap() end
        return data
    end

    self.Refresh = function()
        local group = Teleport.GetGroupInfo()
        local friends = Teleport.GetFriendsInfo()

        group = Utils.map(group, addHandlers)
        friends = Utils.map(friends, addHandlers)

        local zones = {}
        local categories = {
            {
                name = GetString(SI_MAP_INFO_PLAYERS_CATEGORY_GROUP) .. " (" .. tostring(#group) .. ")",
                data = group,
                hidden = not _first and self:IsCategoryHidden(1)
            },
            {
                name = GetString(SI_MAP_INFO_PLAYERS_CATEGORY_FRIENDS) .. " (" .. tostring(#friends) .. ")",
                data = friends,
                hidden = not _first and self:IsCategoryHidden(2)
            },
            {
                name = GetString(SI_MAP_INFO_PLAYERS_CATEGORY_ZONE),
                data = zones,
                hidden = not _first and self:IsCategoryHidden(3)
            }
        }

        local _lookup = {}
        local gCount = GetNumGuilds()
        local id
        local name, data
        for i = 1, gCount do
            id = GetGuildId(i)
            name = GetGuildName(id)
            data = Teleport.GetGuildPlayers(id)
            data = Utils.map(data, function(d)
                local zoneName = d.zoneName
                local zone = _lookup[zoneName]
                if zone == nil then
                    zone = {}
                    _lookup[zoneName] = zone
                end
                table.insert(zone, { name = d.name })
                return addHandlers(d)
            end)
            table.insert(categories,
                {
                    name = name .. " (" .. tostring(#data) .. ")",
                    data = data,
                    hidden = _first or self:IsCategoryHidden(i + 3)
                })
        end

        for k, v in pairs(_lookup) do
            table.insert(zones, {
                name = k .. " (" .. tostring(#v) .. ")",
                zoneName = k,
                refresh = function(self, control) control.label:SetText(self.name) end,
                clicked = function(self, control)
                    local result, zoneName = Teleport.TeleportToZone(self.zoneName)
                    if result == true then
                        ZO_WorldMap_HideWorldMap()
                    end
                end
            })
        end

        table.sort(zones, function(x, y) return x.zoneName < y.zoneName end)

        self:ClearControl()

        self:AddCategories(categories)

        self:RefreshControl(categories)

        _first = false
    end
end
