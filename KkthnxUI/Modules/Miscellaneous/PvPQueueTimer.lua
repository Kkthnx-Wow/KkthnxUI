local K, C, L = unpack(select(2, ...))
if K.CheckAddOn("DBM-Core") then return end

-- Wow API
local GetTime = GetTime

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: PVPReadyDialog

-- </ Queue timer on PVPReadyDialog > --
local frame = CreateFrame("Frame", nil, PVPReadyDialog)
frame:SetPoint("TOP", PVPReadyDialog, "BOTTOM", 0, -10)
frame:SetSize(280, 10)
frame.t = frame:CreateTexture(nil, "OVERLAY")
frame.t:SetTexture("Interface\\CastingBar\\UI-CastingBar-Border")
frame.t:SetSize(375, 64)
frame.t:SetPoint("TOP", 0, 28)

frame.bar = CreateFrame("StatusBar", nil, frame)
frame.bar:SetStatusBarTexture(C.Media.Texture)
frame.bar:SetAllPoints()
frame.bar:SetFrameLevel(PVPReadyDialog:GetFrameLevel() + 1)
frame.bar:SetStatusBarColor(1, 0.7, 0)

PVPReadyDialog.nextUpdate = 0

local function UpdateBar()
	local obj = PVPReadyDialog
	local oldTime = GetTime()
	local flag = 0
	local duration = 90
	local interval = 0.1
	obj:SetScript("OnUpdate", function(self, elapsed)
		obj.nextUpdate = obj.nextUpdate + elapsed
		if obj.nextUpdate > interval then
			local newTime = GetTime()
			if (newTime - oldTime) < duration then
				local width = frame:GetWidth() * (newTime - oldTime) / duration
				frame.bar:SetPoint("BOTTOMRIGHT", frame, 0 - width, 0)
				flag = flag + 1
				if flag >= 10 then
					flag = 0
				end
			else
				obj:SetScript("OnUpdate", nil)
			end
			obj.nextUpdate = 0
		end
	end)
end

frame:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
frame:SetScript("OnEvent", function(self)
	if PVPReadyDialog:IsShown() then
		UpdateBar()
	end
end)