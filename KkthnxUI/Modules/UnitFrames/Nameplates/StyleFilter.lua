--[[-----------------------------------------------------------------------------
-- Priority NPC style filters (scale, color, pulse) and custom-unit coloring.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")
local NP = Module.NP

local unpack = unpack

local customUnits = NP.customUnits
local ShowTargetNPCs = NP.ShowTargetNPCs

local StyleFilters = {
	[120651] = { scale = 1.35, color = { 1, 1, 1 } },
	[174773] = { scale = 1.25, color = { 0.8, 0.2, 0.8 }, desaturate = true },
	[164702] = { scale = 1.20 },
	[165251] = { scale = 1.20 },
	[190120] = { scale = 1.30, color = { 0, 1, 0.5 } },
	[196115] = { scale = 1.30, color = { 1, 1, 0 } },
	[212450] = { scale = 1.25, color = { 1, 0.5, 0 } },
	[212451] = { scale = 1.25, color = { 1, 0.5, 0 } },
	[216364] = { scale = 1.25 },
	[216365] = { scale = 1.25 },
}

local TRASH_UNIT_FILTER = { color = { 0.6, 0.6, 0.6 }, desaturate = true }
-- Priority NPC whitelist: scale when targeted — do NOT paint TargetColor on Health
-- (that cyan override fought Colors.lua reaction / unit-frame tint).
local TARGET_NPC_FILTER = { scale = 1.2 }

function Module:ApplyStyleFilter(unit)
	local npcID = self.npcID
	local name = self.unitName
	local isTarget = K.UnitIsUnit(unit, "target")

	if self._styleFiltered then
		self:SetScale(1)
		Module:RefreshCastOverlay(self)
		local element = self.Health:GetStatusBarTexture()
		if element and element.SetDesaturated then
			element:SetDesaturated(false)
		end
		self._styleFiltered = false
	end

	if self._priorityPulse then
		self._priorityPulse:Stop()
	end

	local isCustom = customUnits[name] or customUnits[npcID]
	if isCustom then
		local customColor = C["Nameplate"].CustomColor
		self.Health:SetStatusBarColor(unpack(customColor))
		self._styleFiltered = true
	end

	if npcID then
		local filter = StyleFilters[npcID]
		if not filter then
			if C.NameplateTrashUnits[npcID] then
				filter = TRASH_UNIT_FILTER
			elseif ShowTargetNPCs[npcID] and isTarget then
				filter = TARGET_NPC_FILTER
			end
		end

		if filter then
			if filter.scale then
				self:SetScale(filter.scale)
				-- Cast overlay lives on UIParent; re-apply lift scale after plate SetScale.
				Module:RefreshCastOverlay(self)
			end

			if filter.color then
				self.Health:SetStatusBarColor(unpack(filter.color))
			end

			if filter.desaturate then
				local element = self.Health:GetStatusBarTexture()
				if element and element.SetDesaturated then
					element:SetDesaturated(true)
				end
			end

			if filter.scale and filter.scale > 1.2 then
				if not self._priorityPulse then
					local anim = self.Health:CreateAnimationGroup()
					local fadeOut = anim:CreateAnimation("Alpha")
					fadeOut:SetFromAlpha(1)
					fadeOut:SetToAlpha(0.6)
					fadeOut:SetDuration(0.6)
					fadeOut:SetOrder(1)
					fadeOut:SetSmoothing("IN_OUT")

					local fadeIn = anim:CreateAnimation("Alpha")
					fadeIn:SetFromAlpha(0.6)
					fadeIn:SetToAlpha(1)
					fadeIn:SetDuration(0.6)
					fadeIn:SetOrder(2)
					fadeIn:SetSmoothing("IN_OUT")

					anim:SetLooping("REPEAT")
					self._priorityPulse = anim
				end
				self._priorityPulse:Play()
			end

			self._styleFiltered = true
		end
	end

	-- ColoredTarget used to paint TargetColor on the health bar, which fought
	-- Colors.lua reaction tints (cyan plate vs red unit frame). Target highlight
	-- is arrows/glow via TargetIndicator — leave Health to UpdateColor.
	return self._styleFiltered
end