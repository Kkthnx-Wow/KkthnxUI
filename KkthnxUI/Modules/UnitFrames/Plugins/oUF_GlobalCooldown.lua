local K = unpack(select(2, ...))

-- Sourced: oUF_GCD (ALZA)

local _G = _G

local GetTime = _G.GetTime
local GetSpellCooldown = _G.GetSpellCooldown

local duration
local starttime
local usingspell

local function OnEnable(self)
	if not self.GlobalCooldown then
		return
	end

	local bar = self.GlobalCooldown
	local width = bar:GetWidth()

	bar:Hide()

	bar.spark = bar:CreateTexture(nil, "OVERLAY")
	bar.spark:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\Spark_128")
	bar.spark:SetVertexColor(1, 1, 1 or unpack(bar.Color))
	bar.spark:SetHeight(26 or bar.Height)
	bar.spark:SetWidth(128 or bar.Width)
	bar.spark:SetBlendMode("ADD")
	bar.spark:SetAlpha(0.6)

	local function OnUpdate_Spark()
		bar.spark:ClearAllPoints()
		local elapsed = GetTime() - starttime
		local perc = elapsed / duration
		if perc > 1 then
			return bar:Hide()
		else
			bar.spark:SetPoint("CENTER", bar, "LEFT", width * perc, 0)
		end
	end

	local function OnHide_Bar()
		bar:SetScript("OnUpdate", nil)
		usingspell = nil
	end

	local function OnShow_Bar()
		bar:SetScript("OnUpdate", OnUpdate_Spark)
	end

	local function OnUpdate_GlobalCooldown()
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

	bar:SetScript("OnShow", OnShow_Bar)
	bar:SetScript("OnHide", OnHide_Bar)

	self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", OnUpdate_GlobalCooldown, true)
end

K.oUF:AddElement("GlobalCooldown", OnUpdate_GlobalCooldown, OnEnable)