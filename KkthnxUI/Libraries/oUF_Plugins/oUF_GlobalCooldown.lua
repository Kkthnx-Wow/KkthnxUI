--	Based on oUF_GCD(by ALZA)
local _, ns = ...
local oUF = ns.oUF
if not oUF then return end

local starttime, duration, usingspell, spellid
local GetTime = GetTime

local playerClass = select(2, UnitClass("player"))

--[[local spells = {
	["DEATHKNIGHT"] = 50977,
	["DEMONHUNTER"] = 204157,
	["DRUID"] = 8921,
	["HUNTER"] = 982,
	["MAGE"] = 118,
	["MONK"] = 100780,
	["PALADIN"] = 35395,
	["PRIEST"] = 585,
	["ROGUE"] = 1752,
	["SHAMAN"] = 403,
	["WARLOCK"] = 686,
	["WARRIOR"] = 57755,
}--]]

local Enable = function(self)
	if not self.GCD then return end
	local bar = self.GCD
	local width = bar:GetWidth()
	bar:Hide()

	bar.spark = bar:CreateTexture(nil, "OVERLAY")
	bar.spark:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\Spark_128")
	--bar.spark:SetVertexColor(unpack(bar.Color))
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

	--[[local function Init()
		spellid = 61304
		if spellid == nil then
			return
		end
		return spellid
	end--]]

	local function OnHide()
		bar:SetScript("OnUpdate", nil)
		usingspell = nil
	end

	local function OnShow()
		bar:SetScript("OnUpdate", OnUpdateSpark)
	end

	local function UpdateGCD()
		--[[if spellid == nil then
			if Init() == nil then
				return
			end
		end--]]
		local start, dur = GetSpellCooldown(61304)
		if dur and dur > 0 and dur <= 2 then
			usingspell = 1
			starttime = start
			duration = dur
			bar:Show()
			return
		elseif usingspell == 1 and dur == 0 then
			bar:Hide()
		end
	end

	bar:SetScript("OnShow", OnShow)
	bar:SetScript("OnHide", OnHide)

	self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", UpdateGCD)
end

oUF:AddElement("GCD", UpdateGCD, Enable)