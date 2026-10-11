--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/ActionBars/PossessBar.lua
	Purpose:
		The possess bar: the small set of buttons shown while you control another
		unit (mind control, some vehicles and cutscene mounts). We reuse Blizzard's
		possess buttons, reparent them onto our own movable bar, skin them, and lay
		them in a row. Blizzard still handles what a click does.

		What Blizzard no longer does is fill the buttons in: that was the stock
		controller's job, and it is switched off with the other stock bars. The
		buttons are also created hidden, because the stock bar only reveals them
		when it updates. So both are done here: the buttons are shown once, out of
		combat, and the icons are set from the possess events.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local Module = K:GetModule("ActionBars")

local _G = _G
local ceil = math.ceil
local floor = math.floor

local InCombatLockdown = InCombatLockdown
local GetPossessInfo = GetPossessInfo

local NUM_POSSESS_SLOTS = _G.NUM_POSSESS_SLOTS or 2

-- Icon for each possess slot (the second is always the cancel button). Plain
-- texture calls, so it can run in combat, which is when mind control tends to
-- begin.
function Module:UpdatePossessState()
	local bar = self.bars and self.bars.PossessBar
	if not bar then
		return
	end
	for index, button in ipairs(bar.buttons) do
		local texture = GetPossessInfo(index)
		button.icon:SetTexture(texture)
		button.icon:SetDesaturated(false)
		button.icon:SetVertexColor(1, 1, 1)
		if button.cooldown then
			button.cooldown:Hide()
		end
		button:SetChecked(false)
	end
end

function Module:CreatePossessBar()
	local cfg = C.ActionBar.PossessBar
	if not cfg or not cfg.Enable then
		return
	end

	local bar = CreateFrame("Frame", "KKUI_PossessBar", UIParent, "SecureHandlerStateTemplate")
	bar.key = "PossessBar"
	bar.buttons = {}

	for i = 1, NUM_POSSESS_SLOTS do
		local button = _G["PossessButton" .. i]
		if button then
			button:SetParent(bar)
			self:StyleAuxButton(button)
			bar.buttons[i] = button
		end
	end

	if #bar.buttons == 0 then
		return
	end

	local size, space, perRow = cfg.Size, cfg.Space, cfg.PerRow
	local count = #bar.buttons
	local rows = ceil(count / perRow)
	bar:SetSize(perRow * size + (perRow - 1) * space, rows * size + (rows - 1) * space)
	for i, button in ipairs(bar.buttons) do
		button:SetSize(size, size)
		local col = (i - 1) % perRow
		local row = floor((i - 1) / perRow)
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", bar, "TOPLEFT", col * (size + space), -row * (size + space))
	end

	-- Show both buttons while it is safe to. Whether the bar itself is on screen is
	-- the visibility driver's job, so the buttons can simply stay shown. If the UI
	-- is loaded in combat, wait for the fight to end.
	local function ShowButtons()
		if InCombatLockdown() then
			return
		end
		self:UnregisterEvent("PLAYER_REGEN_ENABLED", ShowButtons)
		for _, button in ipairs(bar.buttons) do
			button:SetAttribute("statehidden", nil)
			button:Show()
		end
	end
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED", ShowButtons)
	else
		ShowButtons()
	end

	K.CreateMover(bar, "PossessBar", L["Possess Bar"], { "BOTTOM", UIParent, "BOTTOM", 0, 280 }, bar:GetWidth(), bar:GetHeight())

	-- Only visible while possessing something, never in a pet battle, and never in
	-- a vehicle UI. The last one mirrors Blizzard's own bar, which shows only when
	-- the possess bar is visible and the player does not have the vehicle UI
	-- (PossessActionBarMixin:Update). Without it ours stayed up in situations
	-- where Blizzard's would have been hidden, leaving a stray pair of buttons.
	--
	-- overridebar is left out on purpose. It is not established that mind control
	-- never sets it, and hiding the bar there would hide the cancel button.
	RegisterStateDriver(bar, "visibility", "[petbattle][vehicleui] hide; [possessbar] show; hide")
	self:SetupFade(bar, cfg)

	self.bars.PossessBar = bar
	for _, event in ipairs({ "UPDATE_POSSESS_BAR", "UPDATE_VEHICLE_ACTIONBAR", "UPDATE_OVERRIDE_ACTIONBAR", "PLAYER_ENTERING_WORLD" }) do
		self:RegisterEvent(event, function()
			Module:UpdatePossessState()
		end)
	end
	self:UpdatePossessState()

	-- Record the states that decide visibility each time the bar shows, so a bad
	-- case can be read instead of guessed at. Off until /kkdebug possess.
	local stream = K.Debug and K.Debug.Register("possess", "Possess bar visibility and the states behind it")
	if stream then
		bar:HookScript("OnShow", function(self)
			stream:Log(
				"possess bar shown: IsPossessBarVisible=%s UnitHasVehicleUI=%s HasOverrideActionBar=%s HasVehicleActionBar=%s slot1=%s slot2=%s",
				tostring(C_ActionBar.IsPossessBarVisible()),
				tostring(UnitHasVehicleUI("player")),
				tostring(C_ActionBar.HasOverrideActionBar()),
				tostring(C_ActionBar.HasVehicleActionBar()),
				tostring((GetPossessInfo(1))),
				tostring((GetPossessInfo(2)))
			)
		end)
		bar:HookScript("OnHide", function()
			stream:Log("possess bar hidden")
		end)
	end

	self.bars.PossessBar = bar
	return bar
end
