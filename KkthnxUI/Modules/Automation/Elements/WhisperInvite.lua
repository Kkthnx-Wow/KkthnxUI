local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- Auto-invite players to group when they whisper a specified keyword,
-- and optionally when they're in the same guild.

local C_PartyInfo_InviteUnit = C_PartyInfo.InviteUnit
local C_BattleNet_GetAccountInfoByID = C_BattleNet.GetAccountInfoByID
local C_GuildInfo_GuildRoster = C_GuildInfo.GuildRoster

-- Create an empty table to hold the list of whisper keywords
local whisperList = {}

-- Function to update the whisper keyword list
local function updateWhisperList()
	-- Clear the table
	table.wipe(whisperList)

	-- Get the list of keywords from the saved settings
	local inviteKeyword = string.lower(C["Automation"].WhisperInvite)
	if inviteKeyword and inviteKeyword ~= "" then
		local keywords = { strsplit(",", inviteKeyword) }
		for _, keyword in ipairs(keywords) do
			-- Add each keyword to the table, converted to lowercase for case-insensitive matching
			whisperList[string.lower(keyword)] = true
		end
	end
end

-- Function to check if a unit is in the player's guild
local function isUnitInGuild(unitName)
	if not unitName then
		return false
	end
	-- Get the list of guild members
	local guildMembers = C_GuildInfo_GuildRoster()
	for _, memberInfo in ipairs(guildMembers) do
		-- Compare the unit name to the guild member name, using Ambiguate to handle cross-realm names
		local name = Ambiguate(memberInfo.name, "none")
		if name == Ambiguate(unitName, "none") then
			-- Return true if the unit is found in the guild
			return true
		end
	end
	-- Return false if the unit is not found in the guild
	return false
end

-- Function to handle incoming whispers
local function onChatWhisper(event, msg, author, _, _, _, _, _, _, _, _, presenceID)
	-- Convert the message and author names to lowercase for case-insensitive matching
	local lowerMsg = string.lower(msg)
	for keyword in pairs(whisperList) do
		-- Check if the message contains any of the keywords, and if the player is eligible to invite
		if string.find(lowerMsg, keyword) and (not IsInGroup() or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
			if event == "CHAT_MSG_BN_WHISPER" then
				-- If the whisper is from a Battle.net friend, get their account info
				local accountInfo = C_BattleNet_GetAccountInfoByID(presenceID)
				if accountInfo then
					-- Get the game account info and ID from the Battle.net account info
					local gameAccountInfo = accountInfo.gameAccountInfo
					local gameID = gameAccountInfo.gameAccountID
					if gameID then
						-- Get the character name and realm name from the game account info
						local charName = gameAccountInfo.characterName
						local realmName = gameAccountInfo.realmName
						-- Check if the player can cooperate with the friend's game account, and if the friend is in the player's guild
						if CanCooperateWithGameAccount(accountInfo) and isUnitInGuild(charName .. "-" .. realmName) then
							-- Invite the friend to the player's group
							BNInviteFriend(gameID)
						end
					end
				end
			else
				-- If the whisper is from a player, check if they are in the player's guild
				if isUnitInGuild(author) then
					C_PartyInfo_InviteUnit(author)
				end
			end
		end
	end
end

function Module:CreateAutoWhisperInvite()
	-- Update the list of keywords to trigger auto-invites
	updateWhisperList()
	-- Register the onChatWhisper function to handle incoming whispers
	K:RegisterEvent("CHAT_MSG_WHISPER", onChatWhisper)
	-- Register the onChatWhisper function to handle incoming Battle.net whispers
	K:RegisterEvent("CHAT_MSG_BN_WHISPER", onChatWhisper)
end
