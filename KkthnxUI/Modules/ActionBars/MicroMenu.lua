local K, C = unpack(select(2, ...))
local Module = K:NewModule("MicroBar", "AceHook-3.0", "AceEvent-3.0")

local _G = _G
local assert = assert

local CreateFrame = _G.CreateFrame
local C_StorePublic_IsEnabled = _G.C_StorePublic.IsEnabled
local UpdateMicroButtonsParent = _G.UpdateMicroButtonsParent
local InCombatLockdown = _G.InCombatLockdown

local function onLeave()
	if C["ActionBar"].MicroBarMouseover then
		K.UIFrameFadeOut(KkthnxUI_MicroBar, 0.2, KkthnxUI_MicroBar:GetAlpha(), 0.25)
	end
end

local watcher = 0
local function onUpdate(self, elapsed)
	if watcher > 0.1 then
		if not self:IsMouseOver() then
			self.IsMouseOvered = nil
			self:SetScript("OnUpdate", nil)
			onLeave()
		end

		watcher = 0
	else
		watcher = watcher + elapsed
	end
end

local function onEnter()
	if C["ActionBar"].MicroBarMouseover and not KkthnxUI_MicroBar.IsMouseOvered then
		KkthnxUI_MicroBar.IsMouseOvered = true
		KkthnxUI_MicroBar:SetScript("OnUpdate", onUpdate)
		K.UIFrameFadeIn(KkthnxUI_MicroBar, 0.2, KkthnxUI_MicroBar:GetAlpha(), 1)
	end
end

function Module:HandleMicroButton(button)
	assert(button, "Invalid micro button name.")

	local pushed = button:GetPushedTexture()
	local normal = button:GetNormalTexture()
	local disabled = button:GetDisabledTexture()

	local f = CreateFrame("Frame", nil, button)
	K.CreateBorder(f)
	f:SetOutside(button)
	button.backdrop = f

	button:SetParent(KkthnxUI_MicroBar)
	button:GetHighlightTexture():Kill()
	button:HookScript("OnEnter", onEnter)
	button:SetHitRectInsets(0, 0, 0, 0)

	if button.Flash then
		button.Flash:SetInside()
		button.Flash:SetTexture(nil)
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

function Module:MainMenuMicroButton_SetNormal()
	MainMenuBarPerformanceBar:SetPoint("TOPLEFT", MainMenuMicroButton, "TOPLEFT", 9, -36)
end

function Module:MainMenuMicroButton_SetPushed()
	MainMenuBarPerformanceBar:SetPoint("TOPLEFT", MainMenuMicroButton, "TOPLEFT", 8, -37)
end

function Module:UpdateMicroButtonsParent()
	for i = 1, #MICRO_BUTTONS do
		_G[MICRO_BUTTONS[i]]:SetParent(KkthnxUI_MicroBar)
	end
end

-- we use this table to sort the micro buttons on our bar to match Blizzard"s button placements.
local __buttonIndex = {
	[8] = "CollectionsMicroButton",
	[9] = "EJMicroButton",
	[10] = (not C_StorePublic_IsEnabled() and GetCurrentRegionName() == "CN") and "HelpMicroButton" or "StoreMicroButton",
	[11] = "MainMenuMicroButton"
}

function Module:UpdateMicroPositionDimensions()
	if not KkthnxUI_MicroBar then
		return
	end

	local numRows = 1
	local prevButton = KkthnxUI_MicroBar
	local offset = K.Scale(4)
	local spacing = K.Scale(offset + 2)

	for i = 1, #MICRO_BUTTONS-1 do
		local button = _G[__buttonIndex[i]] or _G[MICRO_BUTTONS[i]]
		local lastColumnButton = i - 11
		lastColumnButton = _G[__buttonIndex[lastColumnButton]] or _G[MICRO_BUTTONS[lastColumnButton]]

		button:SetSize(20, 20 * 1.4)
		button:ClearAllPoints()

		if prevButton == KkthnxUI_MicroBar then
			button:SetPoint("TOPLEFT", prevButton, "TOPLEFT", offset, -offset)
		else
			button:SetPoint("LEFT", prevButton, "RIGHT", spacing, 0)
		end

		prevButton = button
	end

	if C["ActionBar"].MicroBarMouseover and not KkthnxUI_MicroBar:IsMouseOver() then
		KkthnxUI_MicroBar:SetAlpha(0.25)
	else
		KkthnxUI_MicroBar:SetAlpha(1)
	end

	Module.MicroWidth = (((_G["CharacterMicroButton"]:GetWidth() + spacing) * 11) - spacing) + (offset * 2)
	Module.MicroHeight = (((_G["CharacterMicroButton"]:GetHeight() + spacing) * numRows) - spacing) + (offset * 2)
	KkthnxUI_MicroBar:SetSize(Module.MicroWidth, Module.MicroHeight)
end

function Module:UpdateMicroButtons()
	GuildMicroButtonTabard:SetInside(GuildMicroButton)

	GuildMicroButtonTabard.background:SetInside(GuildMicroButton)
	GuildMicroButtonTabard.background:SetTexCoord(0.17, 0.87, 0.5, 0.908)

	GuildMicroButtonTabard.emblem:ClearAllPoints()
	GuildMicroButtonTabard.emblem:SetPoint("TOPLEFT", GuildMicroButton, "TOPLEFT", 4, -4)
	GuildMicroButtonTabard.emblem:SetPoint("BOTTOMRIGHT", GuildMicroButton, "BOTTOMRIGHT", -4, 8)

	self:UpdateMicroPositionDimensions()
end

function Module:OnEnable()
	if C["ActionBar"].MicroBar ~= true then
		return
	end

	local microBar = CreateFrame("Frame", "KkthnxUI_MicroBar", UIParent)
	microBar:SetPoint("TOP", UIParent, "TOP", 0, 0)
	microBar:EnableMouse(false)

	for i = 1, #MICRO_BUTTONS do
		self:HandleMicroButton(_G[MICRO_BUTTONS[i]])
	end

	MicroButtonPortrait:SetInside(CharacterMicroButton.backdrop)

	self:SecureHook("MainMenuMicroButton_SetPushed")
	self:SecureHook("MainMenuMicroButton_SetNormal")
	self:SecureHook("UpdateMicroButtonsParent")
	self:SecureHook("MoveMicroButtons", "UpdateMicroPositionDimensions")
	self:SecureHook("UpdateMicroButtons")

	UpdateMicroButtonsParent(microBar)

	self:MainMenuMicroButton_SetNormal()
	self:UpdateMicroPositionDimensions()

	K.Movers:RegisterFrame(microBar)
end