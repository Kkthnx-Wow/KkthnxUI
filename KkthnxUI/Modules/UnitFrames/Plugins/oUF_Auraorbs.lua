local K, C, L = select(2, ...):unpack()
if C.Unitframe.Enable ~= true then return end

--[==================================[

	Widget

	AuraOrbs - An array consisting of x UI widgets.

	AuraOrbs.spellID = The spell ID to track
	AuraOrbs.filter = "HARMFUL" / "HELPFUL"
	AuraOrbs.maxStacks = max stacks

	AuraOrbs[i].HideOrb(self) or AuraOrbs[i].Hide(self)
	AuraOrbs[i].ShowOrb(self) or AuraOrbs[i].Show(self)

Example
	local AuraOrbs = {
		spellID = 36032,
		filter = "HARMFUL",
		maxStacks = 4,
	}
	for i = 1, 4 do
		local orb = self:CreateTexture(nil, 'BACKGROUND')
		-- pos/size/texture stuff

		AuraOrbs[i] = orb
	end

	self.AuraOrbs = AuraOrbs

Hooks

 Override(self) - Used to completely override the internal update function.
                  Removing the table key entry will make the element fall-back
                  to its internal function again.

 OverrideVisibility(self) - Used to completely override the internal visibility function.
                  Removing the table key entry will make the element fall-back
                  to its internal function again.
--]==================================]

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_AuraOrbs could not find oUF")

local Update = function(self, event, unit)
	if (unit ~= self.unit) then return end
	local orbs = self.AuraOrbs

	local name, _, _, stack = UnitAura(unit, orbs.spellName, orbs.rank, orbs.filter)
	stack = stack or 0

	if stack == orbs.lastNumCount then return; end
	orbs.lastNumStacks = stack;

	for i = 1, orbs.maxStacks do
		local orb = orbs[i]
		if i > stack then
			if (orb.active) then
				(orb.HideOrb or orb.Hide)(orb)
				orb.active = false
			end
		elseif (not orb.active) then
			(orb.ShowOrb or orb.Show)(orb)
			orb.active = true
		end
	end
end

local function Path(self, ...)
	return (self.AuraOrbs.Override or Update) (self, ...)
end

local Visibility = function(self, event, unit)
	local orbs = self.AuraOrbs
	local shouldshow = true
	if orbs.Visibility then
		shouldshow = orbs.Visibility(self, event, unit)
	end

	if UnitHasVehicleUI("player")
		or ((HasVehicleActionBar() and UnitVehicleSkin("player") and UnitVehicleSkin("player") ~= "")
		or (HasOverrideActionBar() and GetOverrideBarSkin() and GetOverrideBarSkin() ~= ""))
		or (not shouldshow)
	then
		self:UnregisterEvent("UNIT_AURA", Path)
		for i = 1, orbs.maxStacks do
			local orb = orbs[i]
			if (orb.active) then
				orb:Hide()
				orb.active = false
			end
		end
	else
		self:RegisterEvent("UNIT_AURA", Path)
		orbs:ForceUpdate()
	end
end

local function VisibilityPath(self, ...)
	return (self.AuraOrbs.OverrideVisibility or Visibility)(self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self, unit)
	local orbs = self.AuraOrbs
	if (orbs) then
		orbs.__owner = self
		orbs.ForceUpdate = ForceUpdate

		if not orbs.filter then orbs.filter = "HELPFUL" end
		assert(type(orbs.maxStacks) == "number", "AuraOrbs.maxStacks isn't a number")
		assert(type(orbs.spellID) == "number", "AuraOrbs.spellID isn't a number")

		orbs.spellName, orbs.rank = GetSpellInfo(orbs.spellID)

		self:RegisterEvent("PLAYER_TALENT_UPDATE", VisibilityPath)
		self:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR", VisibilityPath, true)
		self:RegisterEvent("UNIT_ENTERED_VEHICLE", VisibilityPath)
		self:RegisterEvent("UNIT_EXITED_VEHICLE", VisibilityPath)

		VisibilityPath(self, "ForceUpdate", unit)
		self:RegisterEvent("UNIT_AURA", Path)

		return true
	end
end

local function Disable(self)
	local orbs = self.AuraOrbs
	if(orbs) then
		self:UnregisterEvent("UNIT_AURA", Path)

		self:UnregisterEvent("PLAYER_TALENT_UPDATE", VisibilityPath)
		self:UnregisterEvent("UPDATE_OVERRIDE_ACTIONBAR", VisibilityPath)
		self:UnregisterEvent("UNIT_ENTERED_VEHICLE", VisibilityPath)
		self:UnregisterEvent("UNIT_EXITED_VEHICLE", VisibilityPath)

		orbs:Hide()
	end
end

oUF:AddElement("AuraOrbs", Path, Enable, Disable)
