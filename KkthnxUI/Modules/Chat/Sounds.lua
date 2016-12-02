local K, C, L = select(2, ...):unpack()
if C.Chat.Enable ~= true or C.Chat.WhispSound ~= true then return end

-- Wow API
local CreateFrame = CreateFrame
local PlaySoundFile = PlaySoundFile

-- PLAY SOUND FILES SYSTEM(BY TUKZ)
local Whisper = CreateFrame("Frame")
Whisper:RegisterEvent("CHAT_MSG_WHISPER")
Whisper:RegisterEvent("CHAT_MSG_BN_WHISPER")
Whisper:HookScript("OnEvent", function(self, event)
	if (event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_BN_WHISPER") then
		PlaySoundFile(C.Media.Whisp_Sound, "Master")
	end
end)