local K, C, L = select(2, ...):unpack()
if C.Unitframe.Enable ~= true then return end

local _, ns = ...
local oUF = ns.oUF or oUF

local pairs = pairs
local select = select
local unpack = unpack

local hooksecurefunc = hooksecurefunc
local SetOverrideBindingClick = SetOverrideBindingClick
local IsControlKeyDown = IsControlKeyDown
local IsAltKeyDown = IsAltKeyDown

-- Event handler
local oUFKkthnx = CreateFrame("Frame", "oUFKkthnx")
oUFKkthnx:RegisterEvent("ADDON_LOADED")
oUFKkthnx:SetScript("OnEvent", function(self, event, ...)
	return self[event] and self[event](self, event, ...)
end)

function oUFKkthnx:ADDON_LOADED(event, addon)
	if (addon ~= "KkthnxUI") then
		return
	end

	self:UnregisterEvent(event)

	-- Skin the Countdown/BG timers
	self:RegisterEvent("START_TIMER")

	self.ADDON_LOADED = nil
end

-- Skin the blizzard Countdown Timers
function oUFKkthnx:START_TIMER(event)
	for _, b in pairs(TimerTracker.timerList) do
		local bar = b["bar"]
		if (not bar.borderTextures) then
			bar:SetScale(1)
			bar:SetSize(220, 18)

			for i = 1, select("#", bar:GetRegions()) do
				local region = select(i, bar:GetRegions())

				if (region and region:GetObjectType() == "Texture") then
					region:SetTexture(nil)
				end

				if (region and region:GetObjectType() == "FontString") then
					region:ClearAllPoints()
					region:SetPoint("CENTER", bar)
				end
			end

			K.CreateBorder(bar, 11, 3)

			local backdrop = select(1, bar:GetRegions())
			backdrop:SetTexture(C.Media.Blank)
			backdrop:SetVertexColor(unpack(C.Media.Backdrop_Color))
			backdrop:SetAllPoints(bar)
		end

		bar:SetStatusBarTexture(C.Media.Texture)
		for i = 1, select("#", bar:GetRegions()) do
			local region = select(i, bar:GetRegions())
			if (region and region:GetObjectType() == "FontString") then
				region:SetFont(C.Media.Font, 13, C.Media.Font_Style)
			end
		end
	end
end