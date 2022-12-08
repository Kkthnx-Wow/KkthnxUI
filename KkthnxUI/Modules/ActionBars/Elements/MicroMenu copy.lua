local K, C = unpack(KkthnxUI)
local Module = K:GetModule("ActionBar")

-- TODO: Add mouseover back

local _G = _G
local table_insert = _G.table.insert
local pairs = _G.pairs
local type = _G.type

local MAINMENU_BUTTON = _G.MAINMENU_BUTTON
local MicroButtonTooltipText = _G.MicroButtonTooltipText
local RegisterStateDriver = _G.RegisterStateDriver

local buttonList = {}
local MICRO_BUTTONS
local MICRO_COLORS

local function onLeaveBar()
	local KKUI_MB = _G.KKUI_MenuBar
	return C["ActionBar"].FadeMicroBar and UIFrameFadeOut(KKUI_MB, 0.2, KKUI_MB:GetAlpha(), 0)
end

local watcher = 0
local function onUpdate(_, elapsed)
	local KKUI_MB = _G.KKUI_MenuBar
	if watcher > 0.1 then
		if not KKUI_MB:IsMouseOver() then
			KKUI_MB.IsMouseOvered = nil
			KKUI_MB:SetScript("OnUpdate", nil)
			onLeaveBar()
		end
		watcher = 0
	else
		watcher = watcher + elapsed
	end
end

local function onEnter()
	local KKUI_MB = _G.KKUI_MenuBar
	if not KKUI_MB.IsMouseOvered then
		KKUI_MB.IsMouseOvered = true
		KKUI_MB:SetScript("OnUpdate", onUpdate)
		UIFrameFadeIn(KKUI_MB, 0.2, KKUI_MB:GetAlpha(), 1)
	end
end

function Module:MicroButton_Create(parent, data)
	for i, button in pairs(MICRO_BUTTONS) do
		local bu = _G[button]
		local normal = bu:GetNormalTexture()
		local pushed = bu:GetPushedTexture()
		local disabled = bu:GetDisabledTexture()
		bu:SetSize(20, 20 * 1.4)

		bu:SetParent(KKUI_MenuBar)
		bu.SetParent = K.Noop

		bu:SetHighlightTexture(0)
		bu.SetHighlightTexture = K.Noop

		local bg = CreateFrame("Frame", nil, bu)
		bg:SetFrameLevel(1)
		bg:SetFrameStrata("BACKGROUND")
		bg:SetAllPoints(bu)
		bg:CreateBorder()
		bu.frame = bg

		local flash = bu.FlashBorder
		if flash then
			flash:SetInside(bg)
			--flash:SetTexture(C.media.blank)
			flash:SetVertexColor(0.6, 0.6, 0.6)
		end
		if bu.FlashContent then
			bu.FlashContent:SetTexture(nil)
		end

		local highlight = bu:GetHighlightTexture()
		if highlight then
			highlight:SetInside(bg)
		end

		normal:SetTexCoord(0.1, 0.85, 0.12, 0.78)
		normal:ClearAllPoints()
		normal:SetPoint("TOPLEFT", bg, "TOPLEFT", 2, -2)
		normal:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", -2, 2)
		normal:SetVertexColor(unpack(MICRO_COLORS[i]))

		pushed:SetTexCoord(0.1, 0.85, 0.12, 0.78)
		pushed:ClearAllPoints()
		pushed:SetPoint("TOPLEFT", bg, "TOPLEFT", 2, -2)
		pushed:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", -2, 2)

		if disabled then
			disabled:SetTexCoord(0.1, 0.85, 0.12, 0.78)
			disabled:ClearAllPoints()
			disabled:SetPoint("TOPLEFT", bg, "TOPLEFT", 2, -2)
			disabled:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", -2, 2)
		end

		bu:HookScript("OnEnter", onEnter)
		bu:HookScript("OnLeave", onLeaveBar)
	end
end

function Module:MicroMenu()
	if not C["ActionBar"].MicroMenu then
		return
	end

	local menubar = CreateFrame("Frame", "KKUI_MenuBar", K.PetBattleFrameHider)
	menubar:SetSize(280, 20 * 1.4)
	menubar:SetAlpha((C["ActionBar"].FadeMicroBar and not menubar.IsMouseOvered and 0) or 1)
	menubar:EnableMouse(false)
	K.Mover(menubar, "Menubar", "Menubar", { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -4, 4 })

	-- Generate Buttons
	MICRO_BUTTONS = {
		"CharacterMicroButton",
		"SpellbookMicroButton",
		"TalentMicroButton",
		"AchievementMicroButton",
		"QuestLogMicroButton",
		"GuildMicroButton",
		"LFDMicroButton",
		"EJMicroButton",
		"CollectionsMicroButton",
		"MainMenuMicroButton",
		"HelpMicroButton",
		"StoreMicroButton",
	}

	MICRO_COLORS = {
		[1] = { 0.35, 0.65, 1 },
		[2] = { 1, 0.58, 0.65 },
		[3] = { 0.21, 1, 0.95 },
		[4] = { 1, 0.62, 0.1 },
		[5] = { 0.96, 1, 0 },
		[6] = { 0, 1, 0.1 },
		[7] = { 0.7, 0.7, 1 },
		[8] = { 1, 1, 1 },
		[9] = { 1, 0.7, 0.58 },
		[10] = { 1, 0.4, 0.4 },
		[11] = { 1, 1, 1 },
		[12] = { 1, 0.83, 0.50 },
	}

	-- Default elements
	if MainMenuMicroButton.MainMenuBarPerformanceBar then
		K.HideInterfaceOption(MainMenuMicroButton.MainMenuBarPerformanceBar)
	end
	K.HideInterfaceOption(HelpOpenWebTicketButton)
	MainMenuMicroButton:SetScript("OnUpdate", nil)

	MicroButtonAndBagsBar:Hide()
	MicroButtonAndBagsBar:UnregisterAllEvents()
end
