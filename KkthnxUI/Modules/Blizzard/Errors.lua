local K, C, L, _ = select(2, ...):unpack()

-- CLEAR UIERRORSFRAME(MODULE FROM KOUSEI BY HASTE)
if C.Error.White == true or C.Error.Black == true then
	local frame = CreateFrame("Frame")
	frame:SetScript("OnEvent", function(self, event, _, text)
		if C.Error.White == true and C.Error.Black == false then
			if K.WhiteList[text] then
				UIErrorsFrame:AddMessage(text, 1, 0 ,0)
			else
				L_INFO_ERRORS = text
			end
		elseif C.Error.Black == true and C.Error.White == false then
			if K.BlackList[text] then
				L_INFO_ERRORS = text
			else
				UIErrorsFrame:AddMessage(text, 1, 0 ,0)
			end
		end
	end)
	SlashCmdList.ERROR = function()
		UIErrorsFrame:AddMessage(L_INFO_ERRORS, 1, 0, 0)
	end
	SLASH_ERROR1 = "/error"
	UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
	frame:RegisterEvent("UI_ERROR_MESSAGE")
end

-- CLEAR ALL UIERRORS FRAME IN COMBAT
if C.Error.Combat == true then
	local frame = CreateFrame("Frame")
	local OnEvent = function(self, event, ...) self[event](self, event, ...) end
	frame:SetScript("OnEvent", OnEvent)
	local function PLAYER_REGEN_DISABLED()
		UIErrorsFrame:Hide()
	end
	local function PLAYER_REGEN_ENABLED()
		UIErrorsFrame:Show()
	end
	frame:RegisterEvent("PLAYER_REGEN_DISABLED")
	frame["PLAYER_REGEN_DISABLED"] = PLAYER_REGEN_DISABLED
	frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	frame["PLAYER_REGEN_ENABLED"] = PLAYER_REGEN_ENABLED
end