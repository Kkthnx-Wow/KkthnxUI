local K, C, L = unpack(select(2, ...))

-- Wow API
local UIErrorsFrame = UIErrorsFrame

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: SLASH_ERROR1

-- Clear UIErrorsFrame(module from Kousei by Haste)
if C.Error.White == true or C.Error.Black == true then
	local KkthnxUIErrors = CreateFrame("Frame")
	KkthnxUIErrors:SetScript("OnEvent", function(self, event, _, text)
		if C.Error.White == true and C.Error.Black == false then
			if K.ErrorWhiteList[text] then
				UIErrorsFrame:AddMessage(text, 1, .1, .1)
			else
				L.Info.Errors = text
			end
		elseif C.Error.Black == true and C.Error.White == false then
			if K.ErrorBlackList[text] then
				L.Info.Errors = text
			else
				UIErrorsFrame:AddMessage(text, 1, .1, .1)
			end
		end
	end)

	SlashCmdList.ERROR = function()
		UIErrorsFrame:AddMessage(L.Info.Errors, 1, .1, .1)
	end

	SLASH_ERROR1 = "/error"
	UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
	KkthnxUIErrors:RegisterEvent("UI_ERROR_MESSAGE")
end

-- Clear all UIErrors frame in combat
if C.Error.Combat == true then
	local CombatErrors = CreateFrame("Frame")
	local OnEvent = function(self, event, ...) self[event](self, event, ...) end
	CombatErrors:SetScript("OnEvent", OnEvent)

	local function PLAYER_REGEN_DISABLED()
		UIErrorsFrame:Hide()
	end
	local function PLAYER_REGEN_ENABLED()
		UIErrorsFrame:Show()
	end

	CombatErrors:RegisterEvent("PLAYER_REGEN_DISABLED")
	CombatErrors["PLAYER_REGEN_DISABLED"] = PLAYER_REGEN_DISABLED
	CombatErrors:RegisterEvent("PLAYER_REGEN_ENABLED")
	CombatErrors["PLAYER_REGEN_ENABLED"] = PLAYER_REGEN_ENABLED
end