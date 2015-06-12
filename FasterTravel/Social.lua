
local Social = {}

local function GetCampaignLookup()

	local count = GetNumSelectionCampaigns()
	
	local lookup = {}
	
	local id 
	
	for i=1,count do 
		
		id = GetSelectionCampaignId(i)
		
		lookup[id] = { 
			id=id,
			name = GetCampaignName(id),
			group = GetNumSelectionCampaignGroupMembers(i),
			friends = GetNumSelectionCampaignFriends(i),
			guildies = GetNumSelectionCampaignGuildMembers(i),
		}
		
	end 

	
	return lookup
	
end

local function GetSocialLookup()

	local lookup = GetCampaignLookup()
	
	local count = GetNumCampaignSocialConnections()
	
	local accountId, alliance, assignedCampaignId, currentCampaignId, isFriend, isGuildMate
	
	local campaign
	
	for i =1, count do 
		
		accountId, alliance, assignedCampaignId, currentCampaignId, isFriend, isGuildie = GetCampaignSocialConnectionInfo(i)
		campaign = lookup[currentCampaignId] 
		if campaign ~= nil then 
			
			local accounts = campaign.accounts
			
			if accounts == nil then 
				accounts = {}
				campaign.accounts = accounts
			end
			
			local displayName, note,  playerStatus,  secsSinceLogoff = GetFriendInfo(accountId)
		
			local data = accounts[accountId]
			
			if data == nil then 
				data = {accountId=accountId,alliances = {},isFriend=isFriend,isGuildie=isGuildie}
				accounts[accountId] = data 
			end 
			
			data.alliances[alliance] = true 

		end 

		
	end 
	
	return lookup
	
end


local function GetFactionLookup(campaignId,alliance)

	local lookup = {}
	
	local count = GetNumCampaignAllianceLeaderboardEntries(campaignId,alliance)
	
	local isPlayer,  ranking,  charName,  alliancePoints, classId
	
	for i =1, count do 
		
		isPlayer,  ranking,  charName,  alliancePoints, classId = GetCampaignAllianceLeaderboardEntryInfo(campaignId,alliance,i)
		
		if isPlayer == true then 
			lookup[charName] = true
		end 
		
	end 
	
	return lookup
end


local function GetPvpLookup(faction)
	local lookup = GetCampaignLookup()
	
	for cid,c in pairs(lookup) do 
		
		c.players = GetFactionLookup(cid,faction)
		
	end 
	
	return lookup
end

local function GetRaidLookup()

	local lookup = {}

	local count = GetNumRaidLeaderboards()
	
	local entryCount
	
	local name, isWeekly, raidId, category
	
	local ranking, charName,  finishTime, classId, allianceId
	
	
	for i = 1, count do 
	
		name, isWeekly, raidId, category = GetRaidLeaderboardInfo(i)
		
		entryCount = GetNumRaidLeaderboardEntries(i)
		
		lookup[raidId] = {}
		
		for e = 1, entryCount do 
			
			ranking, charName,  finishTime, classId, allianceId = GetRaidLeaderboardEntryInfo(i,e)
		
			lookup[raidId][charName]=true
		
		end 
		
	end 
	
	return lookup
	
end 


local s = Social

s.GetPvpLookup = GetPvpLookup
s.GetRaidLookup = GetRaidLookup

FasterTravel.Social = s 