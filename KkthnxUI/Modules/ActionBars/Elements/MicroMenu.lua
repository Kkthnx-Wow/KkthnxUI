-- Import necessary variables and modules
local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("ActionBar")

-- Import Lua functions
local table_insert = table.insert
local pairs = pairs
local type = type

-- Global variables
local buttonList = {}
local watcher = 0

-- Callback for fading out the micro menu
local function LeaveBarFadeOut()
	local KKUI_MB = KKUI_MenuBar
	if C["ActionBar"].FadeMicroMenu then
		UIFrameFadeOut(KKUI_MB, 0.2, KKUI_MB:GetAlpha(), 0)
	end
end

-- Callback for updating when the mouse is over the micro menu
local function UpdateOnMouseOver(_, elapsed)
	local KKUI_MB = KKUI_MenuBar
	watcher = watcher + elapsed
	if watcher > 0.1 then
		if not KKUI_MB:IsMouseOver() then
			KKUI_MB.IsMouseOvered = nil
			KKUI_MB:SetScript("OnUpdate", nil)
			LeaveBarFadeOut()
		end
		watcher = 0
	end
end

-- Callback for handling micro button hover
local function OnMicroButtonEnter()
	local KKUI_MB = KKUI_MenuBar
	if not KKUI_MB.IsMouseOvered then
		KKUI_MB.IsMouseOvered = true
		KKUI_MB:SetScript("OnUpdate", UpdateOnMouseOver)
		UIFrameFadeIn(KKUI_MB, 0.2, KKUI_MB:GetAlpha(), 1)
	end
end

-- Callbacks for resetting button parent and anchor
local function ResetButtonParent(button, parent)
	if parent ~= button.__owner then
		button:SetParent(button.__owner)
	end
end

local function ResetButtonAnchor(button)
	button:ClearAllPoints()
	button:SetAllPoints()
end

-- Function for setting up button textures
local function SetupButtonTextures(button)
	local function SetTextureProperties(texture)
		texture:SetTexCoord(0.2, 0.80, 0.22, 0.8)
		texture:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -5)
		texture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 5)
	end

	local normal = button:GetNormalTexture()
	local pushed = button:GetPushedTexture()
	local disabled = button:GetDisabledTexture()
	local flash = button.FlashBorder

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

-- Function for creating micro buttons
local function MicroButtonCreate(parent, data)
	local method, tooltip = unpack(data)

	local buttonFrame = CreateFrame("Frame", "KKUI_MicroButtons", parent)
	table_insert(buttonList, buttonFrame)
	buttonFrame:SetSize(22, 30)
	buttonFrame:CreateBorder()

	if type(method) == "string" then
		local button = _G[method]
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

		SetupButtonTextures(button)
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

-- Function for setting up the micro menu
function Module:MicroMenu()
	if not C["ActionBar"].MicroMenu then
		return
	end

	local menubar = CreateFrame("Frame", "KKUI_MenuBar", K.PetBattleFrameHider)
	menubar:SetSize(302, 30)
	menubar:SetAlpha((C["ActionBar"].FadeMicroMenu and not menubar.IsMouseOvered and 0) or 1)
	menubar:EnableMouse(false)
	K.Mover(menubar, "Menubar", "Menubar", { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -4, 4 })

	-- Generate Buttons
	local buttonInfo = {
		{ "CharacterMicroButton" },
		{ "SpellbookMicroButton" },
		{ "TalentMicroButton" },
		{ "AchievementMicroButton" },
		{ "QuestLogMicroButton" },
		{ "GuildMicroButton" },
		{ "LFDMicroButton" },
		{ "EJMicroButton" },
		{ "CollectionsMicroButton" },
		{ "StoreMicroButton" },
		{ "MainMenuMicroButton", MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU") },
	}

	for _, info in pairs(buttonInfo) do
		MicroButtonCreate(menubar, info)
	end

	-- Order Positions
	for i, buttonFrame in ipairs(buttonList) do
		if i == 1 then
			buttonFrame:SetPoint("LEFT")
		else
			buttonFrame:SetPoint("LEFT", buttonList[i - 1], "RIGHT", 6, 0)
		end
	end

	-- Fix textures for buttons
	MainMenuMicroButton.MainMenuBarPerformanceBar:SetTexture(K.GetTexture(C["General"].Texture))
	MainMenuMicroButton.MainMenuBarPerformanceBar:SetSize(16, 2)
	MainMenuMicroButton.MainMenuBarPerformanceBar:SetPoint("BOTTOM", MainMenuMicroButton, "BOTTOM", 0, 0)

	if CharacterMicroButton then
		local function SkinCharacterPortrait(self)
			self.Portrait:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -5)
			self.Portrait:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 5)
		end

		hooksecurefunc(CharacterMicroButton, "SetPushed", SkinCharacterPortrait)
		hooksecurefunc(CharacterMicroButton, "SetNormal", SkinCharacterPortrait)
	end

	K.HideInterfaceOption(HelpOpenWebTicketButton)
	BagsBar:Hide()
	BagsBar:UnregisterAllEvents()
end
