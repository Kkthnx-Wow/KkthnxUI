--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Tooltip/Core.lua
	Purpose:
		The Tooltip module entry point. Creates the module and, on enable, wires up
		the sibling files: skinning (Skin.lua), the health bar (HealthBar.lua), the
		movable anchor (Anchor.lua), the unit enrichments (UnitInfo.lua), and the
		inspect / id add-ons (Inspect.lua, IDs.lua).
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:NewModule("Tooltip")

function Module:OnEnable()
	if not C.Tooltip.Enable then
		return
	end

	self:SetupSkins()
	self:StyleHealthBar()
	self:SetupAnchor()
	self:SetupUnitInfo()

	if self.SetupInspect then
		self:SetupInspect()
	end
	if self.SetupIDs then
		self:SetupIDs()
	end
	if self.SetupIcons then
		self:SetupIcons()
	end
	if self.SetupMountSource then
		self:SetupMountSource()
	end
	if self.SetupItemLevel then
		self:SetupItemLevel()
	end
end
