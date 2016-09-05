local K, C, L, _ = select(2, ...):unpack()

local RequireRestart = false

if (C.General.AutoScale) then
	C.General.UIScale = min(2, max(0.32, 768 / string.match(K.Resolution, "%d+x(%d+)")))
end

StaticPopupDialogs["CLIENT_RESTART"] = {
	text = L_POPUP_RESOLUTIONCHANGED,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self) RequireRestart = false ForceQuit() end,
	OnCancel = function(self) RequireRestart = false end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3
}

-- OPTIMIZE GRAPHIC AFTER WE ENTER WORLD
local PixelPerfect = CreateFrame("Frame")
PixelPerfect:RegisterEvent("PLAYER_ENTERING_WORLD")
PixelPerfect:SetScript("OnEvent", function(self, event)
	if (event == "DISPLAY_SIZE_CHANGED") then
		if C.General.AutoScale and not RequireRestart then
			StaticPopup_Show("CLIENT_RESTART")
		end

		RequireRestart = true
	else
		local UseUIScale = GetCVar("useUiScale")

		if (UseUIScale ~= "1") then
			SetCVar("useUiScale", 1)
		end

		if (format("%.2f", GetCVar("uiScale")) ~= format("%.2f", C.General.UIScale)) then
			SetCVar("uiScale", C.General.UIScale)
		end

		-- ALLOW 4K AND WQHD RESOLUTION TO HAVE AN UISCALE LOWER THAN 0.64, WHICH IS
		-- THE LOWEST VALUE OF UIPARENT SCALE BY DEFAULT
		if (C.General.UIScale < 0.64) then
			UIParent:SetScale(C.General.UIScale)
		end

		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("DISPLAY_SIZE_CHANGED")
	end
end)
