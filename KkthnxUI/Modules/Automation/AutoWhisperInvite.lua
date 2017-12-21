----------------------------------------------------------------------------------------
--	Auto invite by whisper(by Tukz)
----------------------------------------------------------------------------------------
local autoinvite = CreateFrame("Frame")
autoinvite:RegisterEvent("CHAT_MSG_WHISPER")
autoinvite:RegisterEvent("CHAT_MSG_BN_WHISPER")
autoinvite:SetScript("OnEvent", function(self, event, arg1, arg2, ...)
	if ((not UnitExists("party1") or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and arg1:lower():match(C.misc.invite_keyword)) and SavedOptionsPerChar.AutoInvite == true and not QueueStatusMinimapButton:IsShown() then
		if event == "CHAT_MSG_WHISPER" then
			InviteUnit(arg2)
		elseif event == "CHAT_MSG_BN_WHISPER" then
			local bnetIDAccount = select(11, ...)
			local bnetIDGameAccount = select(6, BNGetFriendInfoByID(bnetIDAccount))
			BNInviteFriend(bnetIDGameAccount)
		end
	end
end)

SlashCmdList.AUTOINVITE = function(msg)
	if msg == "off" then
		SavedOptionsPerChar.AutoInvite = false
		print("|cffffff00"..L_INVITE_DISABLE..".|r")
	elseif msg == "" then
		SavedOptionsPerChar.AutoInvite = true
		print("|cffffff00"..L_INVITE_ENABLE..C.misc.invite_keyword..".|r")
		C.misc.invite_keyword = C.misc.invite_keyword
	else
		SavedOptionsPerChar.AutoInvite = true
		print("|cffffff00"..L_INVITE_ENABLE..msg..".|r")
		C.misc.invite_keyword = msg
	end
end
SLASH_AUTOINVITE1 = "/ainv"
SLASH_AUTOINVITE2 = "/фштм"