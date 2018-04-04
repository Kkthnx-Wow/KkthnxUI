local _, ns = ...
local oUF = ns.oUF
if not oUF then return end

-- Based on oUF_GCD(by ALZA)

local _G = _G
local select = select

local GetTime = _G.GetTime
local UnitClass = _G.UnitClass
local GetSpellCooldown = _G.GetSpellCooldown

local starttime, duration
local playerClass = select(2, UnitClass("player"))

local function Enable(self)
	if not self.GlobalCooldown then
		return
	end
	local bar = self.GlobalCooldown
	local width = bar:GetWidth()
	bar:Hide()

	bar.spark = bar:CreateTexture(nil, "OVERLAY")
	bar.spark:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\Spark_128")
	bar.spark:SetVertexColor(unpack(bar.Color))
	bar.spark:SetHeight(self.Health:GetHeight())
	bar.spark:SetWidth(128)
	bar.spark:SetBlendMode("ADD")
	bar.spark:SetAlpha(0.8)

	local function OnUpdateSpark()
		bar.spark:ClearAllPoints()
		local elapsed = GetTime() - starttime
		local perc = elapsed / duration
		if perc > 1 then
			return bar:Hide()
		else
			bar.spark:SetPoint("CENTER", bar, "LEFT", width * perc, 0)
		end
	end

	local function OnHide()
		bar:SetScript("OnUpdate", nil)
	end

	local function OnShow()
		bar:SetScript("OnUpdate", OnUpdateSpark)
	end

	local function UpdateGlobalCooldown(self, event, unit, spell)
		if unit == "player" then
			local start, dur = GetSpellCooldown(spell)
			if dur and dur > 0 and dur <= 1.5 then
				starttime = start
				duration = dur
				bar:Show()
				return
			elseif dur == 0 then
				bar:Hide()
			end
		end
	end

	bar:SetScript("OnShow", OnShow)
	bar:SetScript("OnHide", OnHide)

	self:RegisterEvent("UNIT_SPELLCAST_START", UpdateGlobalCooldown)
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", UpdateGlobalCooldown)
end

oUF:AddElement("GlobalCooldown", UpdateGlobalCooldown, Enable)