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
	if C["ActionBar"].FadeMicroBar then
		UIFrameFadeOut(Module.MicroBar, 0.2, Module.MicroBar:GetAlpha(), 0)
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

local function onEnter(button)
	if button.backdrop and button:IsEnabled() then
		if C["General"].ColorTextures then
			button.backdrop.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
		else
			button.backdrop.KKUI_Border:SetVertexColor(102/255, 157/255, 255/255)
		end
	end

	if C["ActionBar"].FadeMicroBar and not Module.MicroBar.IsMouseOvered then
		Module.MicroBar.IsMouseOvered = true
		Module.MicroBar:SetScript("OnUpdate", onUpdate)
		UIFrameFadeIn(Module.MicroBar, 0.2, Module.MicroBar:GetAlpha(), 1)
	end
end

local function onLeave(button)
	if button.backdrop and button:IsEnabled() then
		if C["General"].ColorTextures then
			button.backdrop.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
		else
			button.backdrop.KKUI_Border:SetVertexColor(1, 1, 1)
		end
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
	f:SetAllPoints(button)
	button.backdrop = f

	button:SetParent(Module.MicroBar)
	button:GetHighlightTexture():Kill()
	button:HookScript("OnEnter", onEnter)
	button:HookScript("OnLeave", onLeave)
	button:SetHitRectInsets(0, 0, 0, 0)

	if button.Flash then
		button.Flash:SetPoint("TOPLEFT", button, "TOPLEFT", 0, -0)
		button.Flash:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -0, 0)
		button.Flash:SetTexture()
	end

	pushed:SetTexCoord(0.22, 0.81, 0.26, 0.82)
	pushed:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -0)
	pushed:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -0, 0)

	normal:SetTexCoord(0.22, 0.81, 0.21, 0.82)
	normal:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -0)
	normal:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -0, 0)

	if disabled then
		disabled:SetTexCoord(0.22, 0.81, 0.21, 0.82)
		disabled:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -0)
		disabled:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -0, 0)
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
		_G[x]:SetParent(Module.MicroBar)
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

	RegisterStateDriver(Module.MicroBar.visibility, "visibility", (C["ActionBar"].MicroBar and visibility) or "hide")
end

function Module.UpdateMicroPositionDimensions()
	if not Module.MicroBar then
		return
	end

	local numRows = 1
	local prevButton = Module.MicroBar
	local offset = 4
	local spacing = offset + 2

	for i = 1, #MICRO_BUTTONS - 1 do
		local button = _G[__buttonIndex[i]] or _G[MICRO_BUTTONS[i]]
		button:SetSize(20, 20 * 1.4)
		button:ClearAllPoints()

		if prevButton == Module.MicroBar then
			button:SetPoint("TOPLEFT", prevButton, "TOPLEFT", offset, -offset)
		else
			button:SetPoint("LEFT", prevButton, "RIGHT", spacing, 0)
		end

		prevButton = button
	end

	if C["ActionBar"].FadeMicroBar and not Module.MicroBar:IsMouseOver() then
		Module.MicroBar:SetAlpha(0)
	else
		Module.MicroBar:SetAlpha(1)
	end

	Module.MicroWidth = (((_G["CharacterMicroButton"]:GetWidth() + spacing) * 11) - spacing) + (offset * 2)
	Module.MicroHeight = (((_G["CharacterMicroButton"]:GetHeight() + spacing) * numRows) - spacing) + (offset * 2)
	Module.MicroBar:SetSize(Module.MicroWidth, Module.MicroHeight)

	Module.UpdateMicroBarVisibility()
end

function Module.UpdateMicroButtons()
	GuildMicroButtonTabard:SetPoint("TOPLEFT", GuildMicroButton, "TOPLEFT", 2, -2)
	GuildMicroButtonTabard:SetPoint("BOTTOMRIGHT", GuildMicroButton, "BOTTOMRIGHT", -2, 2)

	GuildMicroButtonTabard.background:SetPoint("TOPLEFT", GuildMicroButton, "TOPLEFT", 2, -2)
	GuildMicroButtonTabard.background:SetPoint("BOTTOMRIGHT", GuildMicroButton, "BOTTOMRIGHT", -2, 2)
	GuildMicroButtonTabard.background:SetTexCoord(0.17, 0.87, 0.5, 0.908)

	GuildMicroButtonTabard.emblem:ClearAllPoints()
	GuildMicroButtonTabard.emblem:SetPoint("TOPLEFT", GuildMicroButton, "TOPLEFT", 4, -4)
	GuildMicroButtonTabard.emblem:SetPoint("BOTTOMRIGHT", GuildMicroButton, "BOTTOMRIGHT", -4, 8)

	Module.UpdateMicroPositionDimensions()
end

function Module:CreateMicroMenu()
	if not C["ActionBar"].MicroBar then
		return
	end

	Module.MicroBar = CreateFrame("Frame", "KKUI_MicroBar", UIParent)
	Module.MicroBar:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
	Module.MicroBar:EnableMouse(false)

	Module.MicroBar.visibility = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
	Module.MicroBar.visibility:SetScript("OnShow", function()
		Module.MicroBar:Show()
	end)

	Module.MicroBar.visibility:SetScript("OnHide", function()
		Module.MicroBar:Hide()
	end)

	for _, x in pairs(MICRO_BUTTONS) do
		Module.HandleMicroButton(_G[x])
	end

	MicroButtonPortrait:SetAllPoints(CharacterMicroButton.backdrop)

	hooksecurefunc("UpdateMicroButtonsParent", Module.UpdateMicroButtonsParent)
	hooksecurefunc("MoveMicroButtons", Module.UpdateMicroPositionDimensions)
	hooksecurefunc("UpdateMicroButtons", Module.UpdateMicroButtons)

	UpdateMicroButtonsParent(Module.MicroBar)

	Module.MainMenuMicroButton_SetNormal()
	Module.UpdateMicroPositionDimensions()

	-- With this method we might don't taint anything. Instead of using :Kill()
	MainMenuBarPerformanceBar:SetAlpha(0)
	MainMenuBarPerformanceBar:SetScale(0.00001)

	K.Mover(Module.MicroBar, "MicroBar", "MicroBar", {"BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0}, Module.MicroWidth, Module.MicroHeight)
end