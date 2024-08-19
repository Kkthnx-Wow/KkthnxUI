local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("ActionBar")

local insert = table.insert
local ipairs, pairs = ipairs, pairs
local type = type

local MicroButtons = {}
local updateWatcher = 0
local FadeMicroMenuEnabled = C["ActionBar"].FadeMicroMenu

local KKUI_MenuBar = _G.KKUI_MenuBar
local MainMenuMicroButton = _G.MainMenuMicroButton
local CharacterMicroButton = _G.CharacterMicroButton
local BagsBar = _G.BagsBar
local MicroButtonAndBagsBar = _G.MicroButtonAndBagsBar

-- Fade out the micro menu
local function FadeOutMicroMenu()
	if FadeMicroMenuEnabled then
		UIFrameFadeOut(KKUI_MenuBar, 0.2, KKUI_MenuBar:GetAlpha(), 0)
	end
end

-- Update micro menu on mouse over
local function UpdateOnMouseOver(_, elapsed)
	updateWatcher = updateWatcher + elapsed
	if updateWatcher > 0.1 then
		if not KKUI_MenuBar:IsMouseOver() then
			KKUI_MenuBar.IsMouseOvered = nil
			KKUI_MenuBar:SetScript("OnUpdate", nil)
			FadeOutMicroMenu()
		end
		updateWatcher = 0
	end
end

-- Handle micro button hover
local function OnMicroButtonEnter()
	if not KKUI_MenuBar.IsMouseOvered then
		KKUI_MenuBar.IsMouseOvered = true
		KKUI_MenuBar:SetScript("OnUpdate", UpdateOnMouseOver)
		UIFrameFadeIn(KKUI_MenuBar, 0.2, KKUI_MenuBar:GetAlpha(), 1)
	end
end

-- Reset button properties
local function ResetButtonProperties(button)
	button:ClearAllPoints()
	button:SetAllPoints(button.__owner)
end

-- Setup textures for the micro buttons
local function SetupMicroButtonTextures(button)
	local function SetTextureProperties(texture)
		texture:SetTexCoord(0.2, 0.80, 0.22, 0.8)
		texture:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -5)
		texture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 5)
	end

	local highlight, normal, pushed, disabled, flash = button:GetHighlightTexture(), button:GetNormalTexture(), button:GetPushedTexture(), button:GetDisabledTexture(), button.FlashBorder
	local flashTexture = K.MediaFolder .. "Skins\\HighlightMicroButtonWhite"

	if highlight then
		highlight:SetAlpha(0)
	end
	if normal then
		SetTextureProperties(normal)
	end
	if pushed then
		SetTextureProperties(pushed)
	end
	if disabled then
		SetTextureProperties(disabled)
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

-- Create micro buttons
local function CreateMicroButton(parent, data)
	local method, tooltip = unpack(data)
	local buttonFrame = CreateFrame("Frame", "KKUI_MicroButtons", parent)
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

		hooksecurefunc(button, "SetParent", ResetButtonProperties)
		ResetButtonProperties(button)
		hooksecurefunc(button, "SetPoint", ResetButtonProperties)

		if tooltip then
			K.AddTooltip(button, "ANCHOR_RIGHT", tooltip)
		end
		if FadeMicroMenuEnabled then
			button:HookScript("OnEnter", OnMicroButtonEnter)
		end

		button:SetHighlightTexture(0)
		button.SetHighlightTexture = K.Noop

		SetupMicroButtonTextures(button)
	else
		buttonFrame:SetScript("OnMouseUp", method)
		K.AddTooltip(buttonFrame, "ANCHOR_RIGHT", tooltip)

		local highlight = buttonFrame:CreateTexture(nil, "HIGHLIGHT")
		highlight:SetTexture(K.MediaFolder .. "Skins\\HighlightMicroButtonWhite")
		highlight:SetVertexColor(K.r, K.g, K.b)
		highlight:SetPoint("TOPLEFT", buttonFrame, "TOPLEFT", -22, 18)
		highlight:SetPoint("BOTTOMRIGHT", buttonFrame, "BOTTOMRIGHT", 24, -18)
	end
end

-- Set up the micro menu
function Module:CreateMicroMenu()
	if not C["ActionBar"].MicroMenu then
		return
	end

	local microMenuBar = CreateFrame("Frame", "KKUI_MenuBar", K.PetBattleFrameHider)
	microMenuBar:SetSize(302, 30)
	microMenuBar:SetAlpha(FadeMicroMenuEnabled and not microMenuBar.IsMouseOvered and 0 or 1)
	microMenuBar:EnableMouse(false)
	K.Mover(microMenuBar, "Menubar", "Menubar", { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -4, 4 })

	-- Define micro buttons
	local buttonInfo = {
		{ "CharacterMicroButton" },
		{ "ProfessionMicroButton" },
		{ "PlayerSpellsMicroButton" },
		{ "AchievementMicroButton" },
		{ "QuestLogMicroButton" },
		{ "GuildMicroButton" },
		{ "LFDMicroButton" },
		{ "EJMicroButton" },
		{ "CollectionsMicroButton" },
		{ "StoreMicroButton" },
		{ "MainMenuMicroButton", MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU") },
	}

	-- Create and arrange micro buttons
	for i, info in ipairs(buttonInfo) do
		CreateMicroButton(microMenuBar, info)
		if i > 1 then
			MicroButtons[i]:SetPoint("LEFT", MicroButtons[i - 1], "RIGHT", 6, 0)
		else
			MicroButtons[i]:SetPoint("LEFT")
		end
	end

	-- Adjust MainMenuMicroButton textures
	MainMenuMicroButton.MainMenuBarPerformanceBar:SetTexture(K.GetTexture(C["General"].Texture))
	MainMenuMicroButton.MainMenuBarPerformanceBar:SetSize(16, 2)
	MainMenuMicroButton.MainMenuBarPerformanceBar:SetPoint("BOTTOM", MainMenuMicroButton, "BOTTOM", 0, 0)

	-- Skin CharacterMicroButton
	if CharacterMicroButton then
		local function SkinCharacterPortrait(self)
			self.Portrait:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -5)
			self.Portrait:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 5)
		end

		hooksecurefunc(CharacterMicroButton, "SetPushed", SkinCharacterPortrait)
		hooksecurefunc(CharacterMicroButton, "SetNormal", SkinCharacterPortrait)
	end

	-- Default elements and adjustments
	K.HideInterfaceOption(MainMenuMicroButton.MainMenuBarPerformanceBar)
	K.HideInterfaceOption(HelpOpenWebTicketButton)
	MainMenuMicroButton:SetScript("OnUpdate", nil)

	BagsBar:Hide()
	BagsBar:UnregisterAllEvents()
	MicroButtonAndBagsBar:Hide()
	MicroButtonAndBagsBar:UnregisterAllEvents()

	if MicroMenu and MicroMenu.UpdateHelpTicketButtonAnchor then
		MicroMenu.UpdateHelpTicketButtonAnchor = K.Noop
	end
end
