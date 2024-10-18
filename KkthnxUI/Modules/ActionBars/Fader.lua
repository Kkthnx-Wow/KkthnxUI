local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("ActionBar")

-- Credit: ElvUI

local fadeParent
Module.handledbuttons = {}

local function CancelTimer(timer)
	if timer and not timer:IsCancelled() then
		timer:Cancel()
	end
end

local function ClearTimers(object)
	CancelTimer(object.delayTimer)
	object.delayTimer = nil
end

local function DelayFadeOut(frame, timeToFade, startAlpha, endAlpha)
	ClearTimers(frame)

	if C["ActionBar"].BarFadeDelay > 0 then
		frame.delayTimer = C_Timer.NewTimer(C["ActionBar"].BarFadeDelay, function()
			K.UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
		end)
	else
		K.UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
	end
end

function Module:FadeBlingTexture(cooldown, alpha)
	if cooldown then
		cooldown:SetBlingTexture(alpha > 0.5 and [[Interface\Cooldown\star4]] or C["Media"].Textures.BlankTexture)
	end
end

function Module:FadeBlings(alpha)
	for _, button in pairs(Module.buttons) do
		Module:FadeBlingTexture(button.cooldown, alpha)
	end
end

function Module:Button_OnEnter()
	if not fadeParent.mouseLock then
		ClearTimers(fadeParent)
		K.UIFrameFadeIn(fadeParent, 0.2, fadeParent:GetAlpha(), 1)
		Module:FadeBlings(1)
	end
end

function Module:Button_OnLeave()
	if not fadeParent.mouseLock then
		DelayFadeOut(fadeParent, 0.38, fadeParent:GetAlpha(), C["ActionBar"].BarFadeAlpha)
		Module:FadeBlings(C["ActionBar"].BarFadeAlpha)
	end
end

local function flyoutButtonAnchor(frame)
	local parent = frame:GetParent()
	if not parent then
		return
	end

	local _, parentAnchorButton = parent:GetPoint()
	if parentAnchorButton and Module.handledbuttons[parentAnchorButton] then
		return parentAnchorButton
	end
end

function Module:FlyoutButton_OnEnter()
	local anchor = flyoutButtonAnchor(self)
	if anchor then
		Module.Button_OnEnter(anchor)
	end
end

function Module:FlyoutButton_OnLeave()
	local anchor = flyoutButtonAnchor(self)
	if anchor then
		Module.Button_OnLeave(anchor)
	end
end

function Module:FadeParent_OnEvent(event)
	local inCombat = C["ActionBar"].BarFadeCombat and UnitAffectingCombat("player")
	local hasTarget = C["ActionBar"].BarFadeTarget and UnitExists("target")
	local isCasting = C["ActionBar"].BarFadeCasting and (UnitCastingInfo("player") or UnitChannelInfo("player"))
	local lowHealth = C["ActionBar"].BarFadeHealth and (UnitHealth("player") < UnitHealthMax("player"))
	local inVehicle = C["ActionBar"].BarFadeVehicle and UnitHasVehicleUI("player")

	if event == "ACTIONBAR_SHOWGRID" or inCombat or hasTarget or isCasting or lowHealth or inVehicle then
		self.mouseLock = true
		ClearTimers(self)
		K.UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
		Module:FadeBlings(1)
	else
		self.mouseLock = false
		DelayFadeOut(self, 0.38, self:GetAlpha(), C["ActionBar"].BarFadeAlpha)
		Module:FadeBlings(C["ActionBar"].BarFadeAlpha)
	end
end

local options = {
	BarFadeCombat = {
		enable = function(self)
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
			self:RegisterEvent("PLAYER_REGEN_DISABLED")
			self:RegisterUnitEvent("UNIT_FLAGS", "player")
		end,
		events = { "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED", "UNIT_FLAGS" },
	},
	BarFadeTarget = {
		enable = function(self)
			self:RegisterEvent("PLAYER_TARGET_CHANGED")
		end,
		events = { "PLAYER_TARGET_CHANGED" },
	},
	BarFadeCasting = {
		enable = function(self)
			self:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
			self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
			self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
			self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player")
		end,
		events = { "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_STOP" },
	},
	BarFadeHealth = {
		enable = function(self)
			self:RegisterUnitEvent("UNIT_HEALTH", "player")
		end,
		events = { "UNIT_HEALTH" },
	},
	BarFadeVehicle = {
		enable = function(self)
			self:RegisterEvent("UNIT_ENTERED_VEHICLE")
			self:RegisterEvent("UNIT_EXITED_VEHICLE")
			self:RegisterEvent("VEHICLE_UPDATE")
		end,
		events = { "UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE", "VEHICLE_UPDATE" },
	},
}

function Module:UpdateFaderSettings()
	for key, option in pairs(options) do
		if C["ActionBar"][key] then
			if option.enable then
				option.enable(fadeParent)
			end
		else
			if option.events and next(option.events) then
				for _, event in ipairs(option.events) do
					fadeParent:UnregisterEvent(event)
				end
			end
		end
	end
end

local KKUI_ActionBars = {
	["Bar1Fade"] = "KKUI_ActionBar1",
	["Bar2Fade"] = "KKUI_ActionBar2",
	["Bar3Fade"] = "KKUI_ActionBar3",
	["Bar4Fade"] = "KKUI_ActionBar4",
	["Bar5Fade"] = "KKUI_ActionBar5",
	["Bar6Fade"] = "KKUI_ActionBar6",
	["Bar7Fade"] = "KKUI_ActionBar7",
	["Bar8Fade"] = "KKUI_ActionBar8",
	["BarPetFade"] = "KKUI_ActionBarPet",
	["BarStanceFade"] = "KKUI_ActionBarStance",
}

local function updateAfterCombat(event)
	Module:UpdateFaderState()
	K:UnregisterEvent(event, updateAfterCombat)
end

function Module:UpdateFaderState()
	if InCombatLockdown() then
		K:RegisterEvent("PLAYER_REGEN_ENABLED", updateAfterCombat)
		return
	end

	for key, name in pairs(KKUI_ActionBars) do
		local bar = _G[name]
		if bar then
			bar:SetParent(C["ActionBar"][key] and fadeParent or UIParent)
		end
	end

	if not Module.isHooked then
		for _, button in ipairs(Module.buttons) do
			button:HookScript("OnEnter", Module.Button_OnEnter)
			button:HookScript("OnLeave", Module.Button_OnLeave)

			Module.handledbuttons[button] = true
		end

		Module.isHooked = true
	end
end

function Module:SetupFlyoutButton(button)
	button:HookScript("OnEnter", Module.FlyoutButton_OnEnter)
	button:HookScript("OnLeave", Module.FlyoutButton_OnLeave)
end

function Module:LAB_FlyoutCreated(button)
	Module:SetupFlyoutButton(button)
end

function Module:SetupLABFlyout()
	for _, button in next, K.LibActionButton.FlyoutButtons do
		Module:SetupFlyoutButton(button)
	end

	K.LibActionButton:RegisterCallback("OnFlyoutButtonCreated", Module.LAB_FlyoutCreated)
end

function Module:CreateBarFadeGlobal()
	if not C["ActionBar"].BarFadeGlobal then
		return
	end

	fadeParent = CreateFrame("Frame", "KKUI_BarFader", _G.UIParent, "SecureHandlerStateTemplate")
	RegisterStateDriver(fadeParent, "visibility", "[petbattle] hide; show")
	fadeParent:SetAlpha(C["ActionBar"].BarFadeAlpha)
	fadeParent:RegisterEvent("ACTIONBAR_SHOWGRID")
	fadeParent:RegisterEvent("ACTIONBAR_HIDEGRID")
	fadeParent:SetScript("OnEvent", Module.FadeParent_OnEvent)

	Module:UpdateFaderSettings()
	Module:UpdateFaderState()
	Module:SetupLABFlyout()
end
