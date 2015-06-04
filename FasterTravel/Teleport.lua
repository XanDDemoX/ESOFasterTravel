local Teleport = FasterTravel.Teleport or {}
local Utils = FasterTravel.Utils

-- cache for formatted zone names
local _zoneNameCache = {}

local function GetZoneName(zoneName)
	if Utils.stringIsEmpty(zoneName) == true then return zoneName end
	local localeName = _zoneNameCache[zoneName]
	if localeName == nil then 
		localeName = Utils.FormatStringCurrentLanguage(zoneName)
		_zoneNameCache[zoneName] = localeName
	end 
	return localeName
end 

local function GetGuildPlayers(guildId)
	if guildId == nil then return {} end 
	
	local tbl = {}
	
	local pAlliance = GetUnitAlliance("player")
	local playerIndex = GetPlayerGuildMemberIndex(guildId)
	for i=1,GetNumGuildMembers(guildId) do
		if i ~= playerIndex then
			local name, note, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, i)
			
			if playerStaus ~= PLAYER_STATUS_OFFLINE and secsSinceLogoff == 0 then
			
				local hasChar, charName, zoneName,classtype,alliance = GetGuildMemberCharacterInfo(guildId,i)
				
				if hasChar == true and alliance == pAlliance then 
					zoneName = GetZoneName(zoneName)
					table.insert(tbl,{name=name,zoneName=zoneName})
				end
				
			end
		end
	end
	
	table.sort(tbl,function(x,y) return x.name < y.name end)
	
	return tbl
end

-- get a table of zoneName->{playerName,alliance} from guilds
local function GetZonesGuildLookup()
	local returnValue = {}
	local gCount = GetNumGuilds()
	local pCount = 0
	local cCount = 0
	
	local pAlliance = GetUnitAlliance("player")
	local pName = string.lower(GetDisplayName())
	
	local id
	
	for g = 1, gCount do 
		
		id = GetGuildId(g)
		
		pCount = GetNumGuildMembers(id)
		
		for p = 1, pCount do
			local playerName,note,rankindex,playerStaus,secsSinceLogoff = GetGuildMemberInfo(id,p)
			-- only get players that are online >_<
			if  playerStaus ~= PLAYER_STATUS_OFFLINE and secsSinceLogoff == 0 and pName ~= string.lower(playerName) then 
				local hasChar, charName, zoneName,classtype,alliance = GetGuildMemberCharacterInfo(id,p)
				
				if hasChar == true and alliance == pAlliance then 
					zoneName = GetZoneName(zoneName)
					local lowerZoneName = string.lower(zoneName)
					returnValue[lowerZoneName] = returnValue[lowerZoneName] or {}
					table.insert(returnValue[lowerZoneName],{name=playerName,zoneName=zoneName,alliance=alliance,charName=charName})
				end
			end
		end
	
	end
	return returnValue
end

	-- get a table of {displayName,zoneName,alliance} from friends list
local function GetFriendsInfo()
	local returnValue = {}
	local fCount = GetNumFriends()
	local pAlliance = GetUnitAlliance("player")
	
	for i = 1, fCount do
		local displayName, note, playerstaus,secsSinceLogoff = GetFriendInfo(i)
		
		-- only get players that are online >_<
		if playerstaus ~= PLAYER_STATUS_OFFLINE and secsSinceLogoff == 0 then 
			
			local hasChar, charName, zoneName,classtype,alliance = GetFriendCharacterInfo(i)
			if hasChar == true and pAlliance == alliance then 
				zoneName = GetZoneName(zoneName)
				table.insert(returnValue,{name=displayName,zoneName=zoneName,alliance=alliance})
			end
		end
		
	end
	return returnValue
end


	-- get a table of {playerName?,zoneName,alliance,groupLeader} from group list
local function GetGroupInfo()
	local returnValue = {}
	
	local gCount = GetGroupSize()
	
	local pChar = string.lower(GetUnitName("player"))
	
	for i = 1, gCount do 
		local unitTag = GetGroupUnitTagByIndex(i)
		local unitName = GetUnitName(unitTag)
		-- only get players that are online >_<
		if unitTag ~= nil and IsUnitOnline(unitTag) and string.lower(unitName) ~= pChar then 
			local zoneName = GetUnitZone(unitTag)
			zoneName = GetZoneName(zoneName)
			table.insert(returnValue,{name=unitName,zoneName=zoneName,alliance=GetUnitAlliance(unitTag),isLeader=IsUnitGroupLeader(unitTag),charName=GetUniqueNameForCharacter(GetUnitName(unitTag))})
		end 
		
	end
	
	return returnValue
end

local function IsPlayerReallyInGroup(playerName)
	local gCount = GetGroupSize()
	local pName = string.lower(playerName)

	for i = 1, gCount do 
		local unitTag = GetGroupUnitTagByIndex(i)
		-- only get players that are online >_<
		if unitTag ~= nil and string.lower(GetUnitName(unitTag)) == pName then
			return true
		end
	end
	return IsPlayerInGroup(playerName)
end

-- search all guilds for playerName
local function IsPlayerInGuild(playerName)
	local gCount = GetNumGuilds()
	
	local pCount = 0
	local id
	for g = 1, gCount do 
		
		id = GetGuildId(g)
		pCount = GetNumGuildMembers(id)
		
		for p = 1, pCount do
			local name = GetGuildMemberInfo(id,p)
			if string.lower(playerName) == string.lower(name) then
				return true
			end
		end
	
	end
	return false
end

local function GetPlayerName(playerName)
	local unitName
	
	if playerName == "group" then
		unitName = GetGroupLeaderUnitTag()
		if IsCurrentPlayerName(unitName) == true then 
			local info = GetGroupInfo() -- first group member if current player is the leader
			unitName = info[1] ~= nil and info[1].name
		end 
	else
		unitName = GetUnitName(string.lower(playerName))
	end
	
	if Utils.stringIsEmpty(unitName) == false then 
		playerName = unitName
	end
	
	return playerName
end

local function IsCurrentPlayerName(playerName)
	return string.lower(playerName) == string.lower(GetUnitName("player"))
end 

local function IsPlayerTeleportable(playerName)
	if playerName == nil then return false end 
	playerName = GetPlayerName(playerName)
	return (not IsCurrentPlayerName(playerName)) and ( IsPlayerReallyInGroup(playerName) or IsFriend(playerName) or IsPlayerInGuild(playerName) )
end

local function TeleportToPlayer(playerName)
	if playerName == nil then return false end 
	
	playerName = GetPlayerName(playerName)
	
	if IsPlayerReallyInGroup(playerName) then
		JumpToGroupMember(playerName)
	elseif IsFriend(playerName) then 
		JumpToFriend(playerName)
	elseif IsPlayerInGuild(playerName) then 
		JumpToGuildMember(playerName)
	else
		return false,playerName
	end
	return true,playerName
end

local function TeleportToZone(zoneName)

	local lowerZoneName = string.lower(zoneName)
	
	local locTable = GetGroupInfo()
	
	for i,v in ipairs(locTable) do 
		if string.lower(v.zoneName) == lowerZoneName then
			TeleportToPlayer(v.name)
			return true,zoneName
		end
	end

	locTable = GetFriendsInfo()
	
	for i,v in ipairs(locTable) do 
		if string.lower(v.zoneName) == lowerZoneName then
			TeleportToPlayer(v.name)
			return true,zoneName
		end
	end
	
	locTable = GetZonesGuildLookup()[lowerZoneName]
	
	if locTable ~= nil then
		local count = #locTable
		if count > 0 then
			TeleportToPlayer(locTable[math.random(1,count)].name)
			return true,zoneName
		end
	end

	return false, zoneName
end

local t = Teleport
t.GetGuildPlayers = GetGuildPlayers
t.GetZonesGuildLookup = GetZonesGuildLookup
t.GetFriendsInfo = GetFriendsInfo
t.GetGroupInfo = GetGroupInfo
t.IsPlayerReallyInGroup = IsPlayerReallyInGroup
t.IsPlayerInGuild = IsPlayerInGuild
t.IsPlayerTeleportable = IsPlayerTeleportable
t.TeleportToPlayer = TeleportToPlayer
t.TeleportToZone = TeleportToZone


FasterTravel.Teleport = t
