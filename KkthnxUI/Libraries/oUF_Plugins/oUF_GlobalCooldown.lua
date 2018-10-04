local _, ns = ...
local oUF = ns.oUF

if not oUF then
	return
end

-- Sourced: oUF_GCD (ALZA)

local _G = _G

local GetTime = _G.GetTime
local GetSpellCooldown = _G.GetSpellCooldown

local starttime, duration

local function OnEnable(self)
	if not self.GlobalCooldown then
		return
	end

	local bar = self.GlobalCooldown
	local width = bar:GetWidth()

	bar:Hide()

	bar.spark = bar:CreateTexture(nil, "DIALOG")
	bar.spark:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\Spark_128")
	bar.spark:SetVertexColor(1, 1, 1)
	bar.spark:SetHeight(26)
	bar.spark:SetWidth(128)
	bar.spark:SetBlendMode("ADD")
	bar.spark:SetAlpha(0.8)

	local function OnUpdate_Spark()
		if not starttime then
			return bar:Hide()
		end

		bar.spark:ClearAllPoints()
		local perc = (GetTime() - starttime) / duration
		if perc > 1 then
			return bar:Hide()
		else
			bar.spark:SetPoint("CENTER", bar, "LEFT", width * perc, 0)
		end
	end

	local function OnHide_Bar()
		bar:SetScript("OnUpdate", nil)
	end

	local function OnShow_Bar()
		bar:SetScript("OnUpdate", OnUpdate_Spark)
	end

	local function OnUpdate_GlobalCooldown(_, _, unit, _, spell)
		if unit == "player" then
			local start, dur = GetSpellCooldown(spell)
			if dur and dur > 0 and dur <= 1.5 then
				starttime = start
				duration = dur
				bar:Show()
			end
		end
	end

	bar:SetScript("OnShow", OnShow_Bar)
	bar:SetScript("OnHide", OnHide_Bar)

	self:RegisterEvent("UNIT_SPELLCAST_START", OnUpdate_GlobalCooldown)
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", OnUpdate_GlobalCooldown)
end

oUF:AddElement("GlobalCooldown", OnUpdate_GlobalCooldown, OnEnable)