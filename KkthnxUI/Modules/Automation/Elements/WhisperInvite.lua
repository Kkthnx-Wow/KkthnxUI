local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local string_lower = string.lower
local IsInGroup = IsInGroup
local UnitIsGroupAssistant = UnitIsGroupAssistant
local UnitIsGroupLeader = UnitIsGroupLeader

local BNInviteFriend = BNInviteFriend
local C_BattleNet_GetAccountInfoByID = C_BattleNet.GetAccountInfoByID
local CanCooperateWithGameAccount = CanCooperateWithGameAccount

local isGuildMember = {}
local isGroupLeaderOrAssistant = false

-- Check if the player is in a group and is the leader or assistant
local function checkGroupStatus()
	isGroupLeaderOrAssistant = IsInGroup() and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player"))
end

-- Check if a unit name is in the guild roster
local function isUnitInGuild(unitName)
	if isGuildMember[unitName] ~= nil then
		return isGuildMember[unitName]
	end

	for i = 1, GetNumGuildMembers() do
		local name = GetGuildRosterInfo(i)
		if name and Ambiguate(name, "none") == Ambiguate(unitName, "none") then
			isGuildMember[unitName] = true
			return true
		end
	end

	isGuildMember[unitName] = false
	return false
end

-- Handle whisper invite events
local function handleWhisperInvite(event, msg, author, _, _, _, _, _, _, _, _, guid, presenceID)
	local lowerMsg = string_lower(msg)
	local lowerAuthor = string_lower(author)

	-- Check if the message matches the whisper invite keyword and the player is in a group and is the leader or assistant
	if lowerMsg == string_lower(C["Automation"].WhisperInvite) and isGroupLeaderOrAssistant then
		if event == "CHAT_MSG_BN_WHISPER" then
			local accountInfo = C_BattleNet_GetAccountInfoByID(presenceID)
			if accountInfo then
				local gameAccountInfo = accountInfo.gameAccountInfo
				local gameID = gameAccountInfo.gameAccountID
				if gameID then
					local charName = gameAccountInfo.characterName
					local realmName = gameAccountInfo.realmName
					if CanCooperateWithGameAccount(accountInfo) and isUnitInGuild(charName .. "-" .. realmName) then
						BNInviteFriend(gameID)
					end
				end
			end
		else
			if isUnitInGuild(author) then
				InviteToGroup(author)
			end
		end
	end
end

function Module:CreateAutoWhisperInvite()
	-- Check if the player is in a group and is the leader or assistant
	checkGroupStatus()

	-- Register events
	K:RegisterEvent("CHAT_MSG_WHISPER", handleWhisperInvite)
	K:RegisterEvent("CHAT_MSG_BN_WHISPER", handleWhisperInvite)
end
