local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Automation")

local string_lower = string.lower

local BNInviteFriend = _G.BNInviteFriend
local C_BattleNet_GetAccountInfoByID = _G.C_BattleNet.GetAccountInfoByID
local CanCooperateWithGameAccount = _G.CanCooperateWithGameAccount
local IsInGroup = _G.IsInGroup
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local UnitIsGroupLeader = _G.UnitIsGroupLeader

function Module:IsUnitInGuild(unitName)
	if not unitName then
		return
	end

	for i = 1, GetNumGuildMembers() do
		local name = GetGuildRosterInfo(i)
		if name and Ambiguate(name, "none") == Ambiguate(unitName, "none") then
			return true
		end
	end

	return false
end

function Module.SetupWhisperInvite(event, ...)
	local msg, author, _, _, _, _, _, _, _, _, _, guid, presenceID = ...
	if (not IsInGroup() or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and string_lower(msg) == string_lower(C["Automation"].WhisperInvite) then
		if event == "CHAT_MSG_BN_WHISPER" then
			local accountInfo = C_BattleNet_GetAccountInfoByID(presenceID)
			if accountInfo then
				local gameAccountInfo = accountInfo.gameAccountInfo
				local gameID = gameAccountInfo.gameAccountID
				if gameID then
					local charName = gameAccountInfo.characterName
					local realmName = gameAccountInfo.realmName
					if CanCooperateWithGameAccount(accountInfo) and (Module:IsUnitInGuild(charName .. "-" .. realmName)) then
						BNInviteFriend(gameID)
					end
				end
			end
		else
			if IsGuildMember(guid) then
				InviteToGroup(author)
			end
		end
	end
end

function Module:CreateAutoWhisperInvite()
	K:RegisterEvent("CHAT_MSG_WHISPER", Module.SetupWhisperInvite)
	K:RegisterEvent("CHAT_MSG_BN_WHISPER", Module.SetupWhisperInvite)
end
