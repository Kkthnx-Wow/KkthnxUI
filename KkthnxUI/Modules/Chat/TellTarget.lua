local K, C, L, _ = select(2, ...):unpack()
if C.Chat.Enable ~= true then return end

local _G = _G
local len = string.len
local sub = string.sub
local NUM_CHAT_WINDOWS = NUM_CHAT_WINDOWS
local SendChatMessage = SendChatMessage
local GetUnitName = GetUnitName

-- Tell Target
for i = 1, NUM_CHAT_WINDOWS do
	local editbox = _G["ChatFrame"..i.."EditBox"]
	editbox:HookScript("OnTextChanged", function(self)
		local text = self:GetText()
		if text:len() < 7 then
			if text:sub(1, 4) == "/tt " or text:sub(1, 6) == "/ее " then
				if UnitCanCooperate("player", "target") then
					ChatFrame_SendTell((GetUnitName("target", true)), ChatFrame1)
				end
			end
		end
	end)
end

-- Slash command
SlashCmdList.TELLTARGET = function(msg)
	SendChatMessage(msg, "WHISPER")
end
SLASH_TELLTARGET1 = "/tt"