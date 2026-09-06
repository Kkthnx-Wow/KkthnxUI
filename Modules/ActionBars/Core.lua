--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/ActionBars/Core.lua
	Purpose:
		ActionBars module entry point. Defines the module, resolves the action
		button library, and orchestrates enable: hide the stock bars, then build
		each configured bar. Concerns live in sibling files:
			ButtonStyle.lua     LAB config and per button styling
			Bars.lua            bar creation, layout, paging, fade
			DisableBlizzard.lua removing the default bars
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:NewModule("ActionBars")

-- Our embedded copy registers under a KkthnxUI suffixed name to avoid clashing
-- with any other addon's LibActionButton.
Module.LAB = LibStub and LibStub("LibActionButton-1.0-KkthnxUI", true)

Module.bars = {}
Module.buttons = {}

-- Static definition of each bar: which config key it reads, its action page
-- (or "main" for the paged primary bar), and where it anchors by default. Anchor
-- targets that are strings resolve to another bar created earlier.
-- Layout matches the original KkthnxUI: three stacked bars along the bottom
-- (main, then bar 2, then bar 3), and two vertical bars on the right.
-- bindName is the Blizzard binding prefix for that bar's action page, it drives
-- both the hotkey text and the override bindings that make keys click our
-- buttons (Blizzard's own hidden buttons would not cast).
Module.BarDefs = {
	{ key = "Bar1", page = "main", bindName = "ACTIONBUTTON", point = { "BOTTOM", "UIParent", "BOTTOM", 0, 4 } },
	{ key = "Bar2", page = 6, bindName = "MULTIACTIONBAR1BUTTON", point = { "BOTTOM", "Bar1", "TOP", 0, 6 } },
	{ key = "Bar3", page = 5, bindName = "MULTIACTIONBAR2BUTTON", point = { "BOTTOM", "Bar2", "TOP", 0, 6 } },
	{ key = "Bar4", page = 3, bindName = "MULTIACTIONBAR3BUTTON", point = { "RIGHT", "UIParent", "RIGHT", -4, 0 } },
	{ key = "Bar5", page = 4, bindName = "MULTIACTIONBAR4BUTTON", point = { "RIGHT", "Bar4", "LEFT", -6, 0 } },
	-- The extra multibars, stacked near the center and off by default.
	{ key = "Bar6", page = 13, bindName = "MULTIACTIONBAR5BUTTON", point = { "CENTER", "UIParent", "CENTER", 0, 0 } },
	{ key = "Bar7", page = 14, bindName = "MULTIACTIONBAR6BUTTON", point = { "CENTER", "UIParent", "CENTER", 0, 44 } },
	{ key = "Bar8", page = 15, bindName = "MULTIACTIONBAR7BUTTON", point = { "CENTER", "UIParent", "CENTER", 0, 88 } },
}

-- Resolve an anchor target token to a real frame.
function Module:ResolveAnchor(token)
	if token == "UIParent" then
		return UIParent
	end
	local bar = self.bars[token]
	return bar or UIParent
end

-- Give a bar its own mover. Bars that default to sitting on another bar anchor
-- their mover to that bar's mover, so the stacked default layout is preserved
-- until the user drags one loose.
function Module:AttachMover(def, bar)
	local p = def.point
	local relFrame = UIParent
	if p[2] ~= "UIParent" then
		local other = self.bars[p[2]]
		relFrame = (other and other.KKUI_Mover) or UIParent
	end

	local label = "Action Bar " .. (def.key:gsub("Bar", ""))
	K.CreateMover(bar, "ActionBar_" .. def.key, label, { p[1], relFrame, p[3], p[4], p[5] }, bar:GetWidth(), bar:GetHeight())
end

function Module:OnEnable()
	if not C.ActionBar.Enable then
		return
	end
	if not self.LAB then
		K.Print("LibActionButton is missing, action bars disabled.")
		return
	end

	self:DisableBlizzardBars()

	if self.SetupProcGlow then
		self:SetupProcGlow()
	end

	for _, def in ipairs(self.BarDefs) do
		local bar = self:CreateBar(def)
		if bar then
			if def.page == "main" then
				self:SetupMainBar(bar)
				-- Main bar only hides during a pet battle.
				RegisterStateDriver(bar, "visibility", "[petbattle] hide; show")
			else
				self:AssignPage(bar, def.page)
				-- Secondary bars also step aside for vehicle/override/possess/shapeshift.
				RegisterStateDriver(bar, "visibility", "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show")
			end
			-- Size the bar first so the mover box matches it, then attach a mover.
			self:UpdateBar(def.key)
			self:AttachMover(def, bar)
		end
	end

	-- Flyout popup buttons (mount, class ability, and profession flyouts) are
	-- created lazily by LibActionButton, so they never pass through CreateBar.
	-- Skin each one as it is built so the popup matches the bars.
	if self.LAB.RegisterCallback then
		self.LAB.RegisterCallback(self, "OnFlyoutButtonCreated", function(_, button)
			Module:StyleButton(button)
		end)
	end

	-- Pet, stance, possess, and the extra/zone/vehicle buttons.
	self:CreatePetBar()
	self:CreateStanceBar()
	self:CreatePossessBar()
	self:CreateExtras()

	-- Bind keys to our buttons and keep them in sync with binding changes.
	self:ReassignBindings()
	self:RegisterEvent("UPDATE_BINDINGS", "ReassignBindings")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "ReassignBindings")

	self:UpdateBorders()
end

-- Refresh every button border colour, used by the config GUI.
function Module:UpdateBorders()
	K.RefreshBorderColors()
end
