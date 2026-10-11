--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/ActionBars/Bars.lua
	Purpose:
		Bar creation, grid layout, paging, and mouseover fade. Each bar always
		spawns 12 LAB buttons once. UpdateBar then lays out and shows only the
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

-- Mirrors Blizzard's own paging. Its order of precedence is: a vehicle or
-- override bar, a temporary shapeshift bar, the page chosen by hand, and only
-- then the bonus bar of a form or stance, which applies on page 1 alone. The
-- override, vehicle and shapeshift page numbers are read from the client the
-- way Blizzard's own controller reads them, not hardcoded.
--
-- A form only gets a page here if the game really gives it one. Many forms and
-- stances have no bonus bar at all, and paging to a page nothing lives on would
-- leave the bar looking empty. The starting table is for the classes known to
-- have them, and anything else the game reports is learned and kept (see
-- LearnBonusBars), so no form is guessed at.
local STARTING_BONUS_PAGES = {
	DRUID = { [1] = 7, [3] = 9, [4] = 10 },
	ROGUE = { [1] = 7 },
}

-- Page for the skyriding mount bar, shared by every class.
local SKYRIDING_BONUS_BAR = 5
local SKYRIDING_PAGE = 11

local function BonusPages()
	local pages = {}
	for offset, page in pairs(STARTING_BONUS_PAGES[K.Class] or {}) do
		pages[offset] = page
	end
	-- What the game has reported for this class, on top of the starting table.
	local learned = K.DB and K.DB.bonusBarPages and K.DB.bonusBarPages[K.Class]
	if learned then
		for offset, page in pairs(learned) do
			pages[offset] = page
		end
	end
	return pages
end

local function GetPageDriver()
	local override = C_ActionBar.GetOverrideBarIndex()
	local vehicle = C_ActionBar.GetVehicleBarIndex()
	local shapeshift = C_ActionBar.GetTempShapeshiftBarIndex()

	local parts = {
		format("[overridebar] %d", override),
		format("[vehicleui][possessbar] %d", vehicle),
		format("[shapeshift] %d", shapeshift),
	}
	for page = 2, 6 do
		parts[#parts + 1] = format("[bar:%d] %d", page, page)
	end

	local pages = BonusPages()
	local offsets = {}
	for offset in pairs(pages) do
		offsets[#offsets + 1] = offset
	end
	table.sort(offsets)
	for _, offset in ipairs(offsets) do
		-- Prowl and plain cat form share a page, so one clause covers both.
		parts[#parts + 1] = format("[bonusbar:%d] %d", offset, pages[offset])
	end

	if not pages[SKYRIDING_BONUS_BAR] then
		parts[#parts + 1] = format("[bonusbar:%d] %d", SKYRIDING_BONUS_BAR, SKYRIDING_PAGE)
	end
	parts[#parts + 1] = "1"
	return table.concat(parts, "; ")
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

-- Which way a flyout opens from this bar, chosen the way the stock bars do it:
-- a wide bar opens up or down toward the middle of the screen, a tall bar opens
-- sideways toward the middle, so a flyout never lands on top of its own bar.
-- Before the bar has a position there is nothing to go on, so it opens upward.
function Module:GetFlyoutDirection(bar, cfg)
	local x, y = bar:GetCenter()
	if not (x and y) then
		return "UP"
	end
	local rows = ceil(cfg.Buttons / cfg.PerRow)
	if cfg.PerRow >= rows then
		return y < GetScreenHeight() / 2 and "UP" or "DOWN"
	end
	return x > GetScreenWidth() / 2 and "LEFT" or "RIGHT"
end

-- The "cast on key press" choice for our buttons. "Default" hands it back to the
-- game's own setting. An older boolean in a saved profile still counts.
function Module:GetKeyDownSetting()
	local value = C.ActionBar.KeyDown
	if value == "Press" or value == true then
		return true
	elseif value == "Release" or value == false then
		return false
	end
	return nil
end

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
	buttonConfig.flyoutDirection = self:GetFlyoutDirection(bar, cfg)
	local keyDown = self:GetKeyDownSetting()
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
			-- nil leaves the choice to the game's own "cast on key press" setting.
			button:SetAttribute("useOnKeyDown", keyDown)
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
		K.DeferCombat("ActionBarBindings", function()
			Module:ReassignBindings()
		end)
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
	K.DeferCombat("ActionBar:" .. key, function()
		Module:UpdateBar(key)
	end)
end

-- ---------------------------------------------------------------------------
-- Mouseover fade
-- ---------------------------------------------------------------------------

-- How fast the bar glides between hidden and shown, in alpha per second.
local FADE_SPEED = 5

-- While a bar is thought to be hovered, how often that is double checked. Hover
-- comes from OnEnter and OnLeave, but hiding the button under the cursor (dragging
-- a spell off its slot, say) never sends OnLeave, so a hovered bar re-verifies on
-- this throttle until the pointer is really gone.
local HOVER_RECHECK = 0.1

-- Per bar fade state, kept in weak tables so a bar that goes away takes its entry
-- with it. Nothing is written onto the bars themselves.
local faders = setmetatable({}, { __mode = "k" })
local hooked = setmetatable({}, { __mode = "k" })
local fadeEvents

local FadeTick

-- Work out where a bar should be resting and start the glide if it is not there.
-- Called when something that decides that changes: a hover, or combat starting or
-- ending. Between those the bar has no per frame cost at all.
local function Retarget(bar)
	local state = faders[bar]
	if not state then
		return
	end

	-- Full while fighting, and (for mouseover bars) while hovered. Otherwise the bar
	-- rests at the faded alpha. A combat fade bar therefore hides out of combat and
	-- comes up the moment a fight starts.
	local want = (InCombatLockdown() or (state.mouseover and state.hovered)) and state.target or state.faded
	state.want = want

	if state.current ~= want or state.hovered then
		bar:SetScript("OnUpdate", FadeTick)
	end
end

-- Runs only while the bar is gliding or hovered, and removes itself the moment it
-- is neither.
FadeTick = function(bar, delta)
	local state = faders[bar]
	if not state then
		bar:SetScript("OnUpdate", nil)
		return
	end

	if state.hovered then
		state.recheck = (state.recheck or 0) + delta
		if state.recheck >= HOVER_RECHECK then
			state.recheck = 0
			if not bar:IsMouseOver() then
				state.hovered = false
				Retarget(bar)
			end
		end
	end

	local current, want = state.current, state.want
	if current ~= want then
		local step = FADE_SPEED * delta
		if want > current then
			current = current + step
			if current > want then
				current = want
			end
		else
			current = current - step
			if current < want then
				current = want
			end
		end
		state.current = current
		bar:SetAlpha(current)
	end

	if state.current == state.want and not state.hovered then
		bar:SetScript("OnUpdate", nil)
	end
end

local function OnFadeEvent()
	for bar in pairs(faders) do
		Retarget(bar)
	end
end

-- One shared frame for the combat events. It is its own frame rather than the
-- module's event registry on purpose: a split module can lose a handler when
-- another file unregisters the same event by name.
local function EnsureFadeEvents()
	if fadeEvents then
		return
	end
	fadeEvents = CreateFrame("Frame")
	fadeEvents:RegisterEvent("PLAYER_REGEN_DISABLED")
	fadeEvents:RegisterEvent("PLAYER_REGEN_ENABLED")
	fadeEvents:SetScript("OnEvent", OnFadeEvent)
end

-- Apply a static alpha, or a fader that shows the bar on hover and in combat.
function Module:SetupFade(bar, cfg)
	-- No fader: a plain static alpha.
	if not (cfg.Mouseover or cfg.FadeCombat) then
		faders[bar] = nil
		bar:SetScript("OnUpdate", nil)
		bar:SetAlpha(cfg.Alpha)
		return
	end

	local state = {
		target = cfg.Alpha,
		-- Alpha the bar rests at while faded. Zero for a pure mouseover bar, or the
		-- configured value for a combat fade that leaves the bar dimly visible.
		faded = cfg.FadeAlpha or 0,
		mouseover = cfg.Mouseover and true or false,
		hovered = false,
	}
	state.current = state.target
	faders[bar] = state
	bar:SetAlpha(state.target)

	-- The hooks read the live state through the weak table, so they are added once
	-- and a later SetupFade with new settings just swaps the state under them.
	if state.mouseover and not hooked[bar] then
		hooked[bar] = true

		local function Enter()
			local s = faders[bar]
			if s then
				s.hovered = true
				Retarget(bar)
			end
		end
		local function Leave()
			local s = faders[bar]
			if s then
				-- Moving between buttons fires a leave then an enter, and the pointer
				-- is still over the bar for the first of those.
				s.hovered = bar:IsMouseOver()
				Retarget(bar)
			end
		end

		bar:HookScript("OnEnter", Enter)
		bar:HookScript("OnLeave", Leave)
		for _, button in ipairs(bar.buttons or {}) do
			button:HookScript("OnEnter", Enter)
			button:HookScript("OnLeave", Leave)
		end

		-- A bar that hides while hovered (a vehicle taking over) must not come back
		-- believing the pointer is still on it.
		bar:HookScript("OnHide", function()
			local s = faders[bar]
			if s then
				s.hovered = false
				Retarget(bar)
			end
		end)
	end

	EnsureFadeEvents()
	Retarget(bar)
end

-- ---------------------------------------------------------------------------
-- Paging
-- ---------------------------------------------------------------------------

-- Main bar paging using LAB's state system. Each button carries an action for
-- every page state, the secure header switches states through the page driver.
-- Ask the game which page a form or stance really pages to, once, and remember
-- it. This is how a form that is not in the starting table gets its page without
-- anyone guessing. It only learns while nothing else is overriding the bar, with
-- the first page selected, out of combat, since those are the same conditions the
-- game itself pages the bonus bar under.
local function LearnBonusBars()
	if InCombatLockdown() or not K.DB then
		return
	end
	local api = C_ActionBar
	if api.HasOverrideActionBar() or api.HasVehicleActionBar() or api.HasTempShapeshiftActionBar() or api.IsPossessBarVisible() then
		return
	end
	if api.GetActionBarPage() ~= 1 then
		return
	end
	local offset = api.GetBonusBarOffset()
	if not offset or offset == 0 or offset == SKYRIDING_BONUS_BAR then
		return
	end

	-- Only a bar the game confirms is recorded. A form with no bar simply never
	-- gets a clause, and one reading of "no bar" during a form change is not
	-- trusted enough to take a page away.
	if not api.HasBonusActionBar() then
		return
	end
	local page = api.GetBonusBarIndex()
	if not page or page == 0 then
		return
	end
	local store = K.DB.bonusBarPages
	if not store then
		store = {}
		K.DB.bonusBarPages = store
	end
	local byClass = store[K.Class]
	if not byClass then
		byClass = {}
		store[K.Class] = byClass
	end

	local known = BonusPages()[offset]
	if known == page then
		return
	end
	byClass[offset] = page

	local stream = K.Debug and K.Debug.Register("actionbars", "Action bar paging decisions")
	if stream then
		stream:Log("bonus bar %d on %s: page %d (was %s)", offset, K.Class, page, tostring(known))
	end

	local main = Module.bars.Bar1
	if main then
		RegisterStateDriver(main, "page", GetPageDriver())
	end
end

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

	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR", LearnBonusBars)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
		C_Timer.After(1, LearnBonusBars)
	end)
end

-- Point every button on a bar at a fixed page of the action table.
function Module:AssignPage(bar, page)
	local base = (page - 1) * 12
	for i, button in ipairs(bar.buttons) do
		button:SetState(0, "action", base + i)
		button:SetAttribute("action", base + i)
	end
end
