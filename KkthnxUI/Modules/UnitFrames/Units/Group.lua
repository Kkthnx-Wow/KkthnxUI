--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/UnitFrames/Units/Group.lua
	Purpose:
		Party and raid. Both are header children, which means the header owns the
		spacing, so nothing here may stack outside the frame bounds. The name goes
		on the health bar, numbers go on the power bar, and the status icons take
		the health bar corners.

		Raid is the compact variant: health takes almost the whole frame and the
		power bar is a hairline along the bottom, so there is no room for numbers.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("UnitFrames")
local Build = Module.Build

local UnitPowerType = UnitPowerType
local IsSecret = K.IsSecret

-- Anchor the raid health bar: it fills from the top down to the power bar when
-- power is shown, or to the frame bottom when it is not, so a hidden power bar
-- never leaves a dead gap.
local function RaidHealthFill(self, powerShown)
	local health, power = self.Health, self.Power
	local gap = self.__raidGap or 0
	health:ClearAllPoints()
	health:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
	health:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
	if powerShown and power then
		health:SetPoint("BOTTOMLEFT", power, "TOPLEFT", 0, gap)
		health:SetPoint("BOTTOMRIGHT", power, "TOPRIGHT", 0, gap)
	else
		health:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
		health:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
	end
end

-- Mana-only mode: show the power bar for mana users and let health fill for the
-- rest. Fires from oUF's power PostUpdate, so it tracks form and unit changes.
-- Enum.PowerType.Mana is 0, the type is guarded in case it ever reads secret.
local function ManaPowerPostUpdate(power, unit)
	local self = power.__owner
	if not self then
		return
	end
	local ptype = unit and UnitPowerType(unit)
	local isMana = ptype == 0 and not IsSecret(ptype)
	power:SetShown(isMana)
	RaidHealthFill(self, isMana)
end

Module.Styles.Party = function(self)
	local cfg = C.Unitframe.Party

	Module.EnableInteraction(self, "party")

	Build.Health(self, cfg.Height)
	Build.Power(self, Module.PowerHeight(cfg))
	-- Square portrait hanging off the left, sized to the child's full height.
	if cfg.Portrait then
		Build.Portrait(self, "left", Module.TotalHeight(cfg))
	end
	-- Name on the gradient strip above health, value centred on the bar.
	Build.Name(self, 11)
	Build.HealthText(self, 11)
	Build.PowerText(self, 9)

	Build.Indicators(self, 14)
	Build.GroupIndicators(self)

	if cfg.Debuffs then
		-- Right side so they clear the left-hand portrait.
		Build.GroupDebuffs(self, 3, cfg.Height, "right")
	end
	if cfg.DispelHighlight then
		Build.DispelHighlight(self)
	end
	-- Corner heal-over-time dots for the player's tracked auras.
	Build.AuraWatch(self, 8)
	-- Red border when a member pulls aggro (dispel colour still wins over it).
	-- Range fade is set up inside Build.GroupIndicators.
	Build.Threat(self)
end

Module.Styles.Raid = function(self)
	local cfg = C.Unitframe.Raid

	Module.EnableInteraction(self, "raid")

	local mode = cfg.PowerMode or "All"
	local powerHeight = (mode ~= "None") and (cfg.PowerHeight or 0) or 0
	local gap = powerHeight > 0 and (cfg.PowerGap or 6) or 0
	self.__raidGap = gap

	-- Health is anchor-driven (no fixed height) so it can fill down to the power
	-- bar, or the whole frame when there is no power bar to show.
	Build.Health(self)
	if powerHeight > 0 then
		Build.Power(self, powerHeight, gap, true)
		RaidHealthFill(self, true)
		if mode == "Mana" then
			self.Power.PostUpdate = ManaPowerPostUpdate
		end
	else
		RaidHealthFill(self, false)
	end

	Build.NameCenter(self, 10, 0, "[kkui:namecolor][kkui:nameshort]")
	Build.Indicators(self, 12)
	Build.GroupIndicators(self)

	if cfg.DispelHighlight then
		Build.DispelHighlight(self)
	end
	Build.AuraWatch(self, 7)
	Build.Threat(self)
end
