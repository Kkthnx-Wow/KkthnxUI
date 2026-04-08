--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Replaces the default Blizzard micro menu with a KkthnxUI styled version.
-- - Design: Reparents existing micro buttons and applies custom square textures.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("ActionBar")

-- ---------------------------------------------------------------------------
-- LOCALS & CACHING
-- ---------------------------------------------------------------------------

local insert = table.insert
local table_wipe = table.wipe
local ipairs = ipairs
local type = type
local _G = _G
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local C_Timer_NewTimer = C_Timer.NewTimer
local UIParent = UIParent
local MicroButtonTooltipText = MicroButtonTooltipText
local MAINMENU_BUTTON = MAINMENU_BUTTON

local MicroButtons = {}

-- ---------------------------------------------------------------------------
-- MICRO MENU UTILITIES
-- ---------------------------------------------------------------------------

-- REASON: Ensures the button stays anchored to its custom parent frame even if the Blizzard UI tries to move it.
local function ResetButtonProperties(button)
	button:ClearAllPoints()
	button:SetAllPoints(button.__owner)
end

-- NOTE: Standardizes the texture coordinates and positioning to fit the square KkthnxUI aesthetic.
local function SetTextureProperties(button, texture)
	texture:SetTexCoord(0.2, 0.80, 0.22, 0.8)
	texture:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -5)
	texture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 5)
end

-- REASON: Replaces Blizzard's rounded or irregular highlight/normal textures with uniform square ones.
local function SetupMicroButtonTextures(button)
	local highlight, normal, pushed, disabled, flash = button:GetHighlightTexture(), button:GetNormalTexture(), button:GetPushedTexture(), button:GetDisabledTexture(), button.FlashBorder
	local flashTexture = K.MediaFolder .. "Skins\\HighlightMicroButtonWhite"

	if highlight then
		local normalTex = normal and normal.GetTexture and normal:GetTexture()
		local normalAtlas = normal and normal.GetAtlas and normal:GetAtlas()
		if normalAtlas then
			highlight:SetAtlas(normalAtlas, true)
		elseif normalTex then
			button:SetHighlightTexture(normalTex)
		end
		highlight:SetBlendMode("ADD")
		highlight:SetAlpha(0.35)
		highlight:SetTexCoord(0.2, 0.80, 0.22, 0.8)
		highlight:ClearAllPoints()
		highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -5)
		highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 5)
	end

	if normal then
		SetTextureProperties(button, normal)
	end

	if pushed then
		SetTextureProperties(button, pushed)
	end

	if disabled then
		SetTextureProperties(button, disabled)
	end

	if flash then
		flash:SetTexture(flashTexture)
		flash:SetVertexColor(K.r, K.g, K.b)
		flash:SetPoint("TOPLEFT", button, "TOPLEFT", -24, 18)
		flash:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 24, -18)
	end

	if button.FlashContent then
		button.FlashContent:SetTexture(nil)
	end

	if button.Background then
		button.Background:SetAlpha(0)
	end

	if button.PushedBackground then
		button.PushedBackground:SetAlpha(0)
	end
end

-- ---------------------------------------------------------------------------
-- FADING LOGIC
-- ---------------------------------------------------------------------------

local function FadeOutMicroMenu()
	local KKUI_MenuBar = _G.KKUI_MenuBar
	if KKUI_MenuBar then
		K.UIFrameFadeOut(KKUI_MenuBar, 0.2, KKUI_MenuBar:GetAlpha(), 0)
	end
end

-- PERF: Use C_Timer instead of OnUpdate to reduce CPU cycles while handling menu fading.
local fadeTimer
local function StartFadeTimer()
	if fadeTimer then
		fadeTimer:Cancel()
	end
	fadeTimer = C_Timer_NewTimer(0.5, function()
		local KKUI_MenuBar = _G.KKUI_MenuBar
		if KKUI_MenuBar and not KKUI_MenuBar:IsMouseOver() then
			KKUI_MenuBar.IsMouseOvered = nil
			FadeOutMicroMenu()
		end
	end)
end

local function StopFadeTimer()
	if fadeTimer then
		fadeTimer:Cancel()
		fadeTimer = nil
	end
end

local function OnMicroButtonEnter()
	local KKUI_MenuBar = _G.KKUI_MenuBar
	if KKUI_MenuBar and not KKUI_MenuBar.IsMouseOvered then
		KKUI_MenuBar.IsMouseOvered = true
		StopFadeTimer()
		K.UIFrameFadeIn(KKUI_MenuBar, 0.2, KKUI_MenuBar:GetAlpha(), 1)
	end
end

local function OnMicroButtonLeave()
	StartFadeTimer()
end

-- ---------------------------------------------------------------------------
-- MICRO MENU CREATION
-- ---------------------------------------------------------------------------

-- REASON: Wraps individual buttons (either existing Blizzard ones or new custom ones)
-- into a styled parent frame with border support.
local function CreateMicroButton(parent, data, FadeMicroMenuEnabled)
	local method, tooltip = unpack(data)
	local buttonFrame = CreateFrame("Frame", nil, parent)
	insert(MicroButtons, buttonFrame)
	buttonFrame:SetSize(22, 30)
	buttonFrame:CreateBorder()

	if type(method) == "string" then
		local button = _G[method]
		if not button then
			return
		end

		button:SetHitRectInsets(0, 0, 0, 0)
		button:SetParent(buttonFrame)
		button.__owner = buttonFrame

		-- NOTE: We use a safe hook to force properties back if the game resets them on state change.
		local hooking = false
		local function SafeReset()
			if hooking then
				return
			end
			hooking = true
			ResetButtonProperties(button)
			hooking = false
		end

		hooksecurefunc(button, "SetParent", SafeReset)
		SafeReset()
		hooksecurefunc(button, "SetPoint", SafeReset)

		if tooltip then
			K.AddTooltip(button, "ANCHOR_RIGHT", tooltip)
		end

		if FadeMicroMenuEnabled then
			button:HookScript("OnEnter", OnMicroButtonEnter)
			button:HookScript("OnLeave", OnMicroButtonLeave)
		end

		SetupMicroButtonTextures(button)
	else
		buttonFrame:SetScript("OnMouseUp", method)
		K.AddTooltip(buttonFrame, "ANCHOR_RIGHT", tooltip)

		if FadeMicroMenuEnabled then
			buttonFrame:HookScript("OnEnter", OnMicroButtonEnter)
			buttonFrame:HookScript("OnLeave", OnMicroButtonLeave)
		end

		local highlight = buttonFrame:CreateTexture(nil, "HIGHLIGHT")
		highlight:SetTexture(K.MediaFolder .. "Skins\\HighlightMicroButtonWhite")
		highlight:SetVertexColor(K.r, K.g, K.b)
		highlight:SetPoint("TOPLEFT", buttonFrame, "TOPLEFT", -22, 18)
		highlight:SetPoint("BOTTOMRIGHT", buttonFrame, "BOTTOMRIGHT", 24, -18)
	end
end

function Module:CreateMicroMenu()
	-- COMMENT: Verification - disable if conflicting or unneeded.
	if C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("ConsolePort") then
		if _G.KKUI_MenuBar then
			_G.KKUI_MenuBar:Hide()
		end
		self:CleanupMicroMenu()
		return
	end

	if not C["ActionBar"].MicroMenu then
		if _G.KKUI_MenuBar then
			_G.KKUI_MenuBar:Hide()
		end
		self:CleanupMicroMenu()
		return
	end

	if _G.KKUI_MenuBar then
		_G.KKUI_MenuBar:Show()
		return
	end

	local FadeMicroMenuEnabled = C["ActionBar"].FadeMicroMenu

	local KKUI_MenuBar = CreateFrame("Frame", "KKUI_MenuBar", K.PetBattleFrameHider)
	KKUI_MenuBar:SetSize(302, 30)
	KKUI_MenuBar:SetAlpha(FadeMicroMenuEnabled and not KKUI_MenuBar.IsMouseOvered and 0 or 1)
	KKUI_MenuBar:EnableMouse(false)
	K.Mover(KKUI_MenuBar, "Menubar", "Menubar", { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -32, 4 })

	local buttonInfo = {
		{ "CharacterMicroButton" },
		{ "ProfessionMicroButton" },
		{ "PlayerSpellsMicroButton" },
		{ "AchievementMicroButton" },
		{ "QuestLogMicroButton" },
		{ "HousingMicroButton" },
		{ "GuildMicroButton" },
		{ "LFDMicroButton" },
		{ "EJMicroButton" },
		{ "CollectionsMicroButton" },
		{ "StoreMicroButton" },
		{ "MainMenuMicroButton", MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU") },
	}

	for i, info in ipairs(buttonInfo) do
		CreateMicroButton(KKUI_MenuBar, info, FadeMicroMenuEnabled)
		if i > 1 then
			MicroButtons[i]:SetPoint("LEFT", MicroButtons[i - 1], "RIGHT", 6, 0)
		else
			MicroButtons[i]:SetPoint("LEFT")
		end
	end

	-- NOTE: Skin the performance bar (latency/fps display) in the main menu button.
	local MainMenuMicroButton = _G.MainMenuMicroButton
	if MainMenuMicroButton and MainMenuMicroButton.MainMenuBarPerformanceBar then
		MainMenuMicroButton.MainMenuBarPerformanceBar:SetTexture(K.GetTexture(C["General"].Texture))
		MainMenuMicroButton.MainMenuBarPerformanceBar:SetSize(16, 2)
		MainMenuMicroButton.MainMenuBarPerformanceBar:SetPoint("BOTTOM", MainMenuMicroButton, "BOTTOM", 0, 0)
	end

	-- NOTE: Character Portrait requires special scaling to fit the square crop.
	local CharacterMicroButton = _G.CharacterMicroButton
	if CharacterMicroButton then
		local function SkinCharacterPortrait(self)
			self.Portrait:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -5)
			self.Portrait:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 5)
		end

		hooksecurefunc(CharacterMicroButton, "SetPushed", SkinCharacterPortrait)
		hooksecurefunc(CharacterMicroButton, "SetNormal", SkinCharacterPortrait)
	end

	-- REASON: Purge Blizzard legacy elements and hooks to prevent UI clutter.
	if MainMenuMicroButton and MainMenuMicroButton.MainMenuBarPerformanceBar then
		K.HideInterfaceOption(MainMenuMicroButton.MainMenuBarPerformanceBar)
	end
	if _G.HelpOpenWebTicketButton then
		K.HideInterfaceOption(_G.HelpOpenWebTicketButton)
	end
	MainMenuMicroButton:SetScript("OnUpdate", nil)

	local BagsBar = _G.BagsBar
	local MicroButtonAndBagsBar = _G.MicroButtonAndBagsBar
	if BagsBar then
		BagsBar:Hide()
		BagsBar:UnregisterAllEvents()
	end
	if MicroButtonAndBagsBar then
		MicroButtonAndBagsBar:Hide()
		MicroButtonAndBagsBar:UnregisterAllEvents()
	end

	local MicroMenu = _G.MicroMenu
	if MicroMenu and MicroMenu.UpdateHelpTicketButtonAnchor then
		MicroMenu.UpdateHelpTicketButtonAnchor = K.Noop
	end

	-- NOTE: Handle interactive area for the entire menu bar for auto-fading.
	if FadeMicroMenuEnabled then
		KKUI_MenuBar:EnableMouse(true)
		KKUI_MenuBar:HookScript("OnEnter", OnMicroButtonEnter)
		KKUI_MenuBar:HookScript("OnLeave", OnMicroButtonLeave)
	end
end

-- ---------------------------------------------------------------------------
-- CLEANUP
-- ---------------------------------------------------------------------------

function Module:CleanupMicroMenu()
	table_wipe(MicroButtons)
	StopFadeTimer()
end
