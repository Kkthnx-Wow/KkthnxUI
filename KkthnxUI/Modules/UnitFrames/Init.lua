local K, C, L = select(2, ...):unpack()
if C.Unitframe.Enable ~= true then return end

local _, ns = ...
local oUF = ns.oUF or oUF

-- Lua API
local pairs = pairs
local select = select
local unpack = unpack

-- Wow API
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: TimerTracker

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
	self:RegisterEvent("MODIFIER_STATE_CHANGED")

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

-- View Auras
function oUFKkthnx:MODIFIER_STATE_CHANGED(event, key, state)
	if
	(IsControlKeyDown() and (key == "LALT" or key == "RALT")) or
	(IsAltKeyDown() and (key == "LCTRL" or key == "RCTRL"))
	then
		local a, b
		if state == 1 then
			a, b = "CustomFilter", "__CustomFilter"
		else
			a, b = "__CustomFilter", "CustomFilter"
		end
		for i = 1, #oUF.objects do
			local object = oUF.objects[i]
			if object.style == "oUF_Kkthnx" then
				local buffs = object.Auras or object.Buffs
				local debuffs = object.Debuffs
				if buffs and buffs[a] then
					buffs[b] = buffs[a]
					buffs[a] = nil
					buffs:ForceUpdate()
				end
				if debuffs and debuffs[a] then
					debuffs[b] = debuffs[a]
					debuffs[a] = nil
					debuffs:ForceUpdate()
				end
			end
		end
	end
end