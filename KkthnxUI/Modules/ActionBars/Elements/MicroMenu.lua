local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("ActionBar")

-- Import Lua functions
local insert = table.insert
local ipairs, pairs = ipairs, pairs
local type = type

-- Global variables
local MicroButtons = {}
local updateWatcher = 0

-- Fade out the micro menu
local function FadeOutMicroMenu()
	local microMenuBar = KKUI_MenuBar
	if C["ActionBar"].FadeMicroMenu then
		UIFrameFadeOut(microMenuBar, 0.2, microMenuBar:GetAlpha(), 0)
	end
end

-- Update micro menu on mouse over
local function UpdateOnMouseOver(_, elapsed)
	local microMenuBar = KKUI_MenuBar
	updateWatcher = updateWatcher + elapsed
	if updateWatcher > 0.1 then
		if not microMenuBar:IsMouseOver() then
			microMenuBar.IsMouseOvered = nil
			microMenuBar:SetScript("OnUpdate", nil)
			FadeOutMicroMenu()
		end
		updateWatcher = 0
	end
end

-- Handle micro button hover
local function OnMicroButtonEnter()
	local microMenuBar = KKUI_MenuBar
	if not microMenuBar.IsMouseOvered then
		microMenuBar.IsMouseOvered = true
		microMenuBar:SetScript("OnUpdate", UpdateOnMouseOver)
		UIFrameFadeIn(microMenuBar, 0.2, microMenuBar:GetAlpha(), 1)
	end
end

-- Reset button parent to its original owner
local function ResetButtonParent(button, parent)
	if parent ~= button.__owner then
		button:SetParent(button.__owner)
	end
end

-- Reset button anchor to its owner
local function ResetButtonAnchor(button)
	button:ClearAllPoints()
	button:SetAllPoints()
end

-- Setup textures for the micro buttons
local function SetupMicroButtonTextures(button)
	local function SetTextureProperties(texture)
		texture:SetTexCoord(0.2, 0.80, 0.22, 0.8)
		texture:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -5)
		texture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 5)
	end

	local highlight = button:GetHighlightTexture()
	local normal = button:GetNormalTexture()
	local pushed = button:GetPushedTexture()
	local disabled = button:GetDisabledTexture()
	local flash = button.FlashBorder

	if highlight then
		highlight:SetAlpha(0)
		highlight:SetTexCoord(0.1, 0.9, 0.12, 0.9)
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
		flash:SetTexture(K.MediaFolder .. "Skins\\HighlightMicroButtonWhite")
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
			print(method)
			return
		end
		button:SetHitRectInsets(0, 0, 0, 0)
		button:SetParent(buttonFrame)
		button.__owner = buttonFrame
		hooksecurefunc(button, "SetParent", ResetButtonParent)
		ResetButtonAnchor(button)
		hooksecurefunc(button, "SetPoint", ResetButtonAnchor)

		if tooltip then
			K.AddTooltip(button, "ANCHOR_RIGHT", tooltip)
		end

		if C["ActionBar"].FadeMicroMenu then
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
	microMenuBar:SetAlpha((C["ActionBar"].FadeMicroMenu and not microMenuBar.IsMouseOvered and 0) or 1)
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

	-- Create micro buttons
	for _, info in pairs(buttonInfo) do
		CreateMicroButton(microMenuBar, info)
	end

	-- Arrange micro buttons
	for i, buttonFrame in ipairs(MicroButtons) do
		if i == 1 then
			buttonFrame:SetPoint("LEFT")
		else
			buttonFrame:SetPoint("LEFT", MicroButtons[i - 1], "RIGHT", 6, 0)
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

	-- Hide HelpOpenWebTicketButton and BagsBar
	K.HideInterfaceOption(HelpOpenWebTicketButton)
	BagsBar:Hide()
	BagsBar:UnregisterAllEvents()
end
