--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/ActionBars/Bars.lua
	Purpose:
		Bar creation, grid layout, paging, and mouseover fade. Each bar always
		spawns 12 LAB buttons once; UpdateBar then lays out and shows only the
		configured count, applies size/spacing/opacity, and refreshes button
		config live. This keeps count and size changes working out of combat
		without recreating secure frames.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("ActionBars")

local ceil = math.ceil
local floor = math.floor
local format = string.format
local select = select
local InCombatLockdown = InCombatLockdown
local ClearOverrideBindings = ClearOverrideBindings
local SetOverrideBindingClick = SetOverrideBindingClick
local GetBindingKey = GetBindingKey

-- Mirrors Blizzard's own paging (stances, stealth, vehicles, bonus bars). The
-- override / vehicle / shapeshift page numbers come from the client rather than
-- being hardcoded, the way Blizzard's OverrideActionBar builds them, so
-- vehicle abilities always land on the right page.
local function GetPageDriver()
	local override = GetOverrideBarIndex and GetOverrideBarIndex() or 14
	local vehicle = GetVehicleBarIndex and GetVehicleBarIndex() or 12
	local shapeshift = GetTempShapeshiftBarIndex and GetTempShapeshiftBarIndex() or 13
	return format(
		"[overridebar] %d; [vehicleui][possessbar] %d; [shapeshift] %d; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6; [bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10; [bonusbar:5] 11; 1",
		override, vehicle, shapeshift
	)
end

local MAX_BUTTONS = 12

-- ---------------------------------------------------------------------------
-- Creation
-- ---------------------------------------------------------------------------

-- Create a bar with all 12 buttons. Layout and visibility come from UpdateBar.
function Module:CreateBar(def)
	local cfg = C.ActionBar[def.key]
	if not cfg or not cfg.Enable then
		return
	end

	local barName = "KKUI_ActionBar_" .. def.key
	local bar = CreateFrame("Frame", barName, UIParent, "SecureHandlerStateTemplate")
	bar.key = def.key
	bar.bindName = def.bindName
	bar.buttons = {}

	local config = self:GetButtonConfig(def.key)
	for i = 1, MAX_BUTTONS do
		local button = self.LAB:CreateButton(i, format("%sButton%d", barName, i), bar, config)
		self:StyleButton(button)
		bar.buttons[i] = button
		self.buttons[#self.buttons + 1] = button
	end

	self.bars[def.key] = bar
	return bar
end

-- ---------------------------------------------------------------------------
-- Layout / live update
-- ---------------------------------------------------------------------------

-- Re-lay a bar from its current config. Safe to call any time out of combat.
function Module:UpdateBar(key)
	local bar = self.bars[key]
	local cfg = C.ActionBar[key]
	if not bar or not cfg then
		return
	end
	if InCombatLockdown() then
		self:QueueCombatUpdate(key)
		return
	end

	local size = cfg.Size
	local space = cfg.Space
	local perRow = cfg.PerRow
	local count = cfg.Buttons
	local rows = ceil(count / perRow)

	bar:SetSize(perRow * size + (perRow - 1) * space, rows * size + (rows - 1) * space)

	local buttonConfig = self:GetButtonConfig(key)
	for i, button in ipairs(bar.buttons) do
		if i <= count then
			button:SetSize(size, size)
			local col = (i - 1) % perRow
			local row = floor((i - 1) / perRow)
			button:ClearAllPoints()
			button:SetPoint("TOPLEFT", bar, "TOPLEFT", col * (size + space), -row * (size + space))
			-- Point LAB at the matching Blizzard binding so it shows the hotkey.
			-- merge copies this into each button's own config, so reusing the
			-- shared table per iteration is fine.
			buttonConfig.keyBoundTarget = bar.bindName and (bar.bindName .. i) or false
			button:UpdateConfig(buttonConfig)
			-- LAB has no count hide flag, so toggle its alpha per bar.
			if button.Count then
				button.Count:SetAlpha(cfg.Count and 1 or 0)
			end
			button:Show()
		else
			button:Hide()
		end
	end

	self:SetupFade(bar, cfg)
end

-- Update every bar (used after a global change like font or texture).
function Module:UpdateAllBars()
	for _, def in ipairs(self.BarDefs) do
		self:UpdateBar(def.key)
	end
end

-- Route each Blizzard action binding to our button via an override binding, so
-- the key clicks our (visible) button rather than Blizzard's hidden one. Out of
-- combat only, re-run whenever bindings change.
function Module:ReassignBindings()
	if InCombatLockdown() then
		return
	end
	for _, def in ipairs(self.BarDefs) do
		local bar = self.bars[def.key]
		if bar and def.bindName then
			ClearOverrideBindings(bar)
			for i, button in ipairs(bar.buttons) do
				local binding = def.bindName .. i
				for k = 1, select("#", GetBindingKey(binding)) do
					local key = select(k, GetBindingKey(binding))
					if key and key ~= "" then
						SetOverrideBindingClick(bar, false, key, button:GetName())
					end
				end
			end
		end
	end
end

-- Defer a layout change until combat ends.
function Module:QueueCombatUpdate(key)
	self.pendingUpdates = self.pendingUpdates or {}
	self.pendingUpdates[key] = true
	if not self.combatWatcher then
		self:RegisterEvent("PLAYER_REGEN_ENABLED", function()
			if self.pendingUpdates then
				for pending in pairs(self.pendingUpdates) do
					self:UpdateBar(pending)
				end
				self.pendingUpdates = nil
			end
		end)
		self.combatWatcher = true
	end
end

-- ---------------------------------------------------------------------------
-- Mouseover fade
-- ---------------------------------------------------------------------------

-- Apply a static alpha, or a mouseover fader that shows the bar on hover.
function Module:SetupFade(bar, cfg)
	if not cfg.Mouseover then
		bar:SetScript("OnUpdate", nil)
		bar:SetAlpha(cfg.Alpha)
		return
	end

	bar:SetAlpha(0)
	local elapsed = 0
	bar:SetScript("OnUpdate", function(self, delta)
		elapsed = elapsed + delta
		if elapsed < 0.1 then
			return
		end
		elapsed = 0
		self:SetAlpha(self:IsMouseOver() and cfg.Alpha or 0)
	end)
end

-- ---------------------------------------------------------------------------
-- Paging
-- ---------------------------------------------------------------------------

-- Main bar paging using LAB's state system. Each button carries an action for
-- every page state, the secure header switches states through the page driver.
function Module:SetupMainBar(bar)
	for i, button in ipairs(bar.buttons) do
		-- Cover all 18 possible page states (the original mapped the same range).
		for state = 1, 18 do
			button:SetState(state, "action", (state - 1) * 12 + i)
		end
		button:SetState(0, "action", i)
	end
	bar:SetAttribute("_onstate-page", [[ control:ChildUpdate("state", newstate) ]])
	RegisterStateDriver(bar, "page", GetPageDriver())
end

-- Point every button on a bar at a fixed page of the action table.
function Module:AssignPage(bar, page)
	local base = (page - 1) * 12
	for i, button in ipairs(bar.buttons) do
		button:SetState(0, "action", base + i)
		button:SetAttribute("action", base + i)
	end
end
