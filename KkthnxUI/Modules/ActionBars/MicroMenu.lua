local K, C = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")

local _G = _G
local assert = _G.assert

local C_StorePublic_IsEnabled = _G.C_StorePublic.IsEnabled
local CharacterMicroButton = _G.CharacterMicroButton
local CreateFrame = _G.CreateFrame
local GetCurrentRegionName = _G.GetCurrentRegionName
local GuildMicroButton = _G.GuildMicroButton
local GuildMicroButtonTabard = _G.GuildMicroButtonTabard
local InCombatLockdown = _G.InCombatLockdown
local MICRO_BUTTONS = _G.MICRO_BUTTONS
local MainMenuBarPerformanceBar = _G.MainMenuBarPerformanceBar
local MainMenuMicroButton = _G.MainMenuMicroButton
local MicroButtonPortrait = _G.MicroButtonPortrait
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent
local UpdateMicroButtonsParent = _G.UpdateMicroButtonsParent
local hooksecurefunc = _G.hooksecurefunc

local function onLeaveBar()
	if C["ActionBar"].MicroBarMouseover then
		K.UIFrameFadeOut(KKUI_MicroBar, 0.2, KKUI_MicroBar:GetAlpha(), 0.25)
	end
end

local watcher = 0
local function onUpdate(self, elapsed)
	if watcher > 0.1 then
		if not self:IsMouseOver() then
			self.IsMouseOvered = nil
			self:SetScript("OnUpdate", nil)
			onLeaveBar()
		end
		watcher = 0
	else
		watcher = watcher + elapsed
	end
end

local function onEnter()
	if C["ActionBar"].MicroBarMouseover and not KKUI_MicroBar.IsMouseOvered then
		KKUI_MicroBar.IsMouseOvered = true
		KKUI_MicroBar:SetScript("OnUpdate", onUpdate)
		K.UIFrameFadeIn(KKUI_MicroBar, 0.2, KKUI_MicroBar:GetAlpha(), 1)
	end
end

local function onLeave(button)
	if button.backdrop and button:IsEnabled() then
		button.backdrop:SetBackdropBorderColor()
	end
end

function Module.HandleMicroButton(button)
	assert(button, "Invalid micro button name.")

	local pushed = button:GetPushedTexture()
	local normal = button:GetNormalTexture()
	local disabled = button:GetDisabledTexture()

	local f = CreateFrame("Frame", nil, button)
	f:SetFrameLevel(button:GetFrameLevel())
	f:CreateBorder()
	f:CreateInnerShadow()
	f:SetAllPoints(button)
	button.backdrop = f

	button:SetParent(KKUI_MicroBar)
	button:GetHighlightTexture():Kill()
	button:HookScript("OnEnter", onEnter)
	button:HookScript("OnLeave", onLeave)
	button:SetHitRectInsets(0, 0, 0, 0)

	if button.Flash then
		button.Flash:SetInside()
		button.Flash:SetTexture()
	end

	pushed:SetTexCoord(0.22, 0.81, 0.26, 0.82)
	pushed:SetInside(f)

	normal:SetTexCoord(0.22, 0.81, 0.21, 0.82)
	normal:SetInside(f)

	if disabled then
		disabled:SetTexCoord(0.22, 0.81, 0.21, 0.82)
		disabled:SetInside(f)
	end
end

function Module.MainMenuMicroButton_SetNormal()
	MainMenuBarPerformanceBar:SetPoint("TOPLEFT", MainMenuMicroButton, "TOPLEFT", 9, -36)
end

function Module.MainMenuMicroButton_SetPushed()
	MainMenuBarPerformanceBar:SetPoint("TOPLEFT", MainMenuMicroButton, "TOPLEFT", 8, -37)
end

function Module.UpdateMicroButtonsParent()
	for _, x in pairs(MICRO_BUTTONS) do
		_G[x]:SetParent(KKUI_MicroBar)
	end
end

-- We use this table to sort the micro buttons on our bar to match Blizzard's button placements.
local __buttonIndex = {
	[8] = "CollectionsMicroButton",
	[9] = "EJMicroButton",
	[10] = (not C_StorePublic_IsEnabled() and GetCurrentRegionName() == "CN") and "HelpMicroButton" or "StoreMicroButton",
	[11] = "MainMenuMicroButton"
}

function Module:PLAYER_REGEN_ENABLED()
	if Module.NeedsUpdateMicroBarVisibility then
		Module.UpdateMicroBarVisibility()
		Module.NeedsUpdateMicroBarVisibility = nil
	end

	K:UnregisterEvent("PLAYER_REGEN_ENABLED", Module.PLAYER_REGEN_ENABLED)
end

function Module.UpdateMicroBarVisibility()
	if InCombatLockdown() then
		Module.NeedsUpdateMicroBarVisibility = true
		K:RegisterEvent("PLAYER_REGEN_ENABLED", Module.PLAYER_REGEN_ENABLED)
		return
	end

	local visibility = "show"
	if visibility and visibility:match("[\n\r]") then
		visibility = visibility:gsub("[\n\r]","")
	end

	RegisterStateDriver(KKUI_MicroBar.visibility, "visibility", (C["ActionBar"].MicroBar and visibility) or "hide")
end

function Module.UpdateMicroPositionDimensions()
	if not KKUI_MicroBar then
		return
	end

	local numRows = 1
	local prevButton = KKUI_MicroBar
	local offset = 4
	local spacing = offset + 2

	for i = 1, #MICRO_BUTTONS-1 do
		local button = _G[__buttonIndex[i]] or _G[MICRO_BUTTONS[i]]
		button:SetSize(20, 20 * 1.4)
		button:ClearAllPoints()

		if prevButton == KKUI_MicroBar then
			button:SetPoint("TOPLEFT", prevButton, "TOPLEFT", offset, -offset)
		else
			button:SetPoint("LEFT", prevButton, "RIGHT", spacing, 0)
		end

		prevButton = button
	end

	if C["ActionBar"].MicroBarMouseover and not KKUI_MicroBar:IsMouseOver() then
		KKUI_MicroBar:SetAlpha(0.25)
	else
		KKUI_MicroBar:SetAlpha(1)
	end

	Module.MicroWidth = (((_G["CharacterMicroButton"]:GetWidth() + spacing) * 11) - spacing) + (offset * 2)
	Module.MicroHeight = (((_G["CharacterMicroButton"]:GetHeight() + spacing) * numRows) - spacing) + (offset * 2)
	KKUI_MicroBar:SetSize(Module.MicroWidth, Module.MicroHeight)

	Module.UpdateMicroBarVisibility()
end

function Module.UpdateMicroButtons()
	GuildMicroButtonTabard:SetInside(GuildMicroButton)

	GuildMicroButtonTabard.background:SetInside(GuildMicroButton)
	GuildMicroButtonTabard.background:SetTexCoord(0.17, 0.87, 0.5, 0.908)

	GuildMicroButtonTabard.emblem:ClearAllPoints()
	GuildMicroButtonTabard.emblem:SetPoint("TOPLEFT", GuildMicroButton, "TOPLEFT", 4, -4)
	GuildMicroButtonTabard.emblem:SetPoint("BOTTOMRIGHT", GuildMicroButton, "BOTTOMRIGHT", -4, 8)

	Module.UpdateMicroPositionDimensions()
end

function Module:CreateMicroMenu()
	if not C["ActionBar"].Enable then
		return
	end

	if C["ActionBar"].MicroBar ~= true then
		return
	end

	local microBar = CreateFrame("Frame", "KKUI_MicroBar", UIParent)
	microBar:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
	microBar:EnableMouse(false)

	microBar.visibility = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
	microBar.visibility:SetScript("OnShow", function()
		microBar:Show()
	end)

	microBar.visibility:SetScript("OnHide", function()
		microBar:Hide()
	end)

	for _, x in pairs(MICRO_BUTTONS) do
		Module.HandleMicroButton(_G[x])
	end

	MicroButtonPortrait:SetAllPoints(CharacterMicroButton.backdrop)

	hooksecurefunc("MainMenuMicroButton_SetPushed", Module.MainMenuMicroButton_SetPushed)
	hooksecurefunc("MainMenuMicroButton_SetNormal", Module.MainMenuMicroButton_SetNormal)
	hooksecurefunc("UpdateMicroButtonsParent", Module.UpdateMicroButtonsParent)
	hooksecurefunc("MoveMicroButtons", Module.UpdateMicroPositionDimensions)
	hooksecurefunc("UpdateMicroButtons", Module.UpdateMicroButtons)

	UpdateMicroButtonsParent(microBar)

	Module.MainMenuMicroButton_SetNormal()
	Module.UpdateMicroPositionDimensions()

	if MainMenuBarPerformanceBar then
		MainMenuBarPerformanceBar:SetTexture(nil)
		MainMenuBarPerformanceBar:SetVertexColor(0, 0, 0, 0)
		MainMenuBarPerformanceBar:Hide()
	end

	K.Mover(microBar, "MicroBar", "MicroBar", {"BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0}, (((_G["CharacterMicroButton"]:GetWidth() + 6) * 11) - 6) + (4 * 2), (((_G["CharacterMicroButton"]:GetHeight() + 6) * 1) - 6) + (4 * 2))
end