local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("ActionBar")

local insert = table.insert
local ipairs, pairs = ipairs, pairs
local type = type

local MicroButtons = {}
local updateWatcher = 0

local function ResetButtonProperties(button)
	button:ClearAllPoints()
	button:SetAllPoints(button.__owner)
end

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

local function FadeOutMicroMenu()
	local KKUI_MenuBar = _G.KKUI_MenuBar
	if KKUI_MenuBar then
		K.UIFrameFadeOut(KKUI_MenuBar, 0.2, KKUI_MenuBar:GetAlpha(), 0)
	end
end

-- Improved mouse detection using timer instead of OnUpdate
local fadeTimer
local function StartFadeTimer()
	if fadeTimer then
		fadeTimer:Cancel()
	end
	fadeTimer = C_Timer.NewTimer(0.5, function()
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

local function CreateMicroButton(parent, data, FadeMicroMenuEnabled)
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
			button:HookScript("OnLeave", OnMicroButtonLeave)
		end

		button:SetHighlightTexture(0)
		button.SetHighlightTexture = K.Noop

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
	if not C["ActionBar"].MicroMenu then
		-- Clean up if feature is disabled
		if _G.KKUI_MenuBar then
			_G.KKUI_MenuBar:Hide()
		end
		self:CleanupMicroMenu()
		return
	end

	-- Show existing frame if it exists
	if _G.KKUI_MenuBar then
		_G.KKUI_MenuBar:Show()
		return
	end

	local FadeMicroMenuEnabled = C["ActionBar"].FadeMicroMenu

	local KKUI_MenuBar = CreateFrame("Frame", "KKUI_MenuBar", K.PetBattleFrameHider)
	KKUI_MenuBar:SetSize(302, 30)
	KKUI_MenuBar:SetAlpha(FadeMicroMenuEnabled and not KKUI_MenuBar.IsMouseOvered and 0 or 1)
	KKUI_MenuBar:EnableMouse(false)
	K.Mover(KKUI_MenuBar, "Menubar", "Menubar", { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -4, 4 })

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

	for i, info in ipairs(buttonInfo) do
		CreateMicroButton(KKUI_MenuBar, info, FadeMicroMenuEnabled)
		if i > 1 then
			MicroButtons[i]:SetPoint("LEFT", MicroButtons[i - 1], "RIGHT", 6, 0)
		else
			MicroButtons[i]:SetPoint("LEFT")
		end
	end

	local MainMenuMicroButton = _G.MainMenuMicroButton
	if MainMenuMicroButton then
		MainMenuMicroButton.MainMenuBarPerformanceBar:SetTexture(K.GetTexture(C["General"].Texture))
		MainMenuMicroButton.MainMenuBarPerformanceBar:SetSize(16, 2)
		MainMenuMicroButton.MainMenuBarPerformanceBar:SetPoint("BOTTOM", MainMenuMicroButton, "BOTTOM", 0, 0)
	end

	local CharacterMicroButton = _G.CharacterMicroButton
	if CharacterMicroButton then
		local function SkinCharacterPortrait(self)
			self.Portrait:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -5)
			self.Portrait:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 5)
		end

		hooksecurefunc(CharacterMicroButton, "SetPushed", SkinCharacterPortrait)
		hooksecurefunc(CharacterMicroButton, "SetNormal", SkinCharacterPortrait)
	end

	K.HideInterfaceOption(MainMenuMicroButton.MainMenuBarPerformanceBar)
	K.HideInterfaceOption(_G.HelpOpenWebTicketButton)
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

	-- Add mouse enter/leave handlers for the entire menu bar
	if FadeMicroMenuEnabled then
		KKUI_MenuBar:EnableMouse(true)
		KKUI_MenuBar:HookScript("OnEnter", OnMicroButtonEnter)
		KKUI_MenuBar:HookScript("OnLeave", OnMicroButtonLeave)
	end
end

-- Add cleanup function for when feature is disabled
function Module:CleanupMicroMenu()
	K.ClearTable(MicroButtons)
	StopFadeTimer()
	updateWatcher = 0
end
