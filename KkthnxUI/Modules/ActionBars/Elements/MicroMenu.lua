local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("ActionBar")

local table_insert = table.insert
local pairs = pairs
local type = type

local buttonList = {}
local watcher = 0

local function onLeaveBar()
	local KKUI_MB = KKUI_MenuBar
	if C["ActionBar"].FadeMicroMenu then
		UIFrameFadeOut(KKUI_MB, 0.2, KKUI_MB:GetAlpha(), 0)
	end
end

local function onUpdate(_, elapsed)
	local KKUI_MB = KKUI_MenuBar
	watcher = watcher + elapsed
	if watcher > 0.1 then
		if not KKUI_MB:IsMouseOver() then
			KKUI_MB.IsMouseOvered = nil
			KKUI_MB:SetScript("OnUpdate", nil)
			onLeaveBar()
		end
		watcher = 0
	end
end

local function onEnter()
	local KKUI_MB = KKUI_MenuBar
	if not KKUI_MB.IsMouseOvered then
		KKUI_MB.IsMouseOvered = true
		KKUI_MB:SetScript("OnUpdate", onUpdate)
		UIFrameFadeIn(KKUI_MB, 0.2, KKUI_MB:GetAlpha(), 1)
	end
end

local function ResetButtonParent(button, parent)
	if parent ~= button.__owner then
		button:SetParent(button.__owner)
	end
end

local function ResetButtonAnchor(button)
	button:ClearAllPoints()
	button:SetAllPoints()
end

function Module:MicroButton_Create(parent, data)
	local method, tooltip = unpack(data)

	local bu = CreateFrame("Frame", "KKUI_MicroButtons", parent)
	table_insert(buttonList, bu)
	bu:SetSize(20, 20 * 1.4)
	bu:CreateBorder()

	if type(method) == "string" then
		local button = _G[method]
		button:SetHitRectInsets(0, 0, 0, 0)
		button:SetParent(bu)
		button.__owner = bu
		hooksecurefunc(button, "SetParent", ResetButtonParent)
		ResetButtonAnchor(button)
		hooksecurefunc(button, "SetPoint", ResetButtonAnchor)

		if tooltip then
			K.AddTooltip(button, "ANCHOR_RIGHT", tooltip)
		end

		if C["ActionBar"].FadeMicroMenu then
			button:HookScript("OnEnter", onEnter)
		end

		local normal = button:GetNormalTexture()
		local pushed = button:GetPushedTexture()
		local disabled = button:GetDisabledTexture()
		local highlight = button:GetHighlightTexture()

		if pushed then -- Blizzard improve the micromenu? Bugged!
			pushed:SetTexCoord(0.1, 0.85, 0.12, 0.78)
			pushed:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -4)
			pushed:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 4)
		end

		-- if normal then -- Blizzard improve the micromenu? Bugged!
		-- 	normal:SetTexCoord(0.1, 0.85, 0.12, 0.78)
		-- 	normal:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -4)
		-- 	normal:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 4)
		-- end

		-- if disabled then -- Blizzard improve the micromenu? Bugged!
		-- 	disabled:SetTexCoord(0.1, 0.85, 0.12, 0.78)
		-- 	disabled:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -4)
		-- 	disabled:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 4)
		-- end

		-- if highlight then -- Blizzard improve the micromenu? Bugged!
		-- 	highlight:SetTexture(K.MediaFolder .. "Skins\\HighlightMicroButtonWhite")
		-- 	highlight:SetVertexColor(K.r, K.g, K.b)
		-- 	highlight:SetPoint("TOPLEFT", button, "TOPLEFT", -22, 18)
		-- 	highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 24, -18)
		-- end

		if button.FlashBorder then
			button.FlashBorder:SetTexture()
		end

		if button.FlashContent then
			button.FlashContent:SetTexture(K.MediaFolder .. "Skins\\HighlightMicroButtonYellow")
			button.FlashContent:SetPoint("TOPLEFT", button, "TOPLEFT", -22, 18)
			button.FlashContent:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 24, -18)
		end

		if button.Flash then
			button.Flash:SetTexture()
		end
	else
		bu:SetScript("OnMouseUp", method)
		K.AddTooltip(bu, "ANCHOR_RIGHT", tooltip)

		local highlight = bu:CreateTexture(nil, "HIGHLIGHT")
		highlight:SetTexture(K.MediaFolder .. "Skins\\HighlightMicroButtonWhite")
		highlight:SetVertexColor(K.r, K.g, K.b)
		highlight:SetPoint("TOPLEFT", bu, "TOPLEFT", -22, 18)
		highlight:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", 24, -18)
	end
end

function Module:MicroMenu()
	if not C["ActionBar"].MicroMenu then
		return
	end

	local menubar = CreateFrame("Frame", "KKUI_MenuBar", K.PetBattleFrameHider)
	menubar:SetSize(280, 20 * 1.4)
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
		Module:MicroButton_Create(menubar, info)
	end

	-- Order Positions
	for i = 1, #buttonList do
		if i == 1 then
			buttonList[i]:SetPoint("LEFT")
		else
			buttonList[i]:SetPoint("LEFT", buttonList[i - 1], "RIGHT", 6, 0)
		end
	end

	-- Default elements
	if MainMenuMicroButton.MainMenuBarPerformanceBar then
		K.HideInterfaceOption(MainMenuMicroButton.MainMenuBarPerformanceBar)
	end
	K.HideInterfaceOption(HelpOpenWebTicketButton)
	MainMenuMicroButton:SetScript("OnUpdate", nil)

	BagsBar:Hide()
	BagsBar:UnregisterAllEvents()
end
