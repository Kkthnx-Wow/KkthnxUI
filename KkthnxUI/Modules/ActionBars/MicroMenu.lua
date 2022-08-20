local K, C = unpack(KkthnxUI)
local Module = K:GetModule("ActionBar")

-- TODO: Add mouseover back

local _G = _G
local table_insert = _G.table.insert
local pairs = _G.pairs
local type = _G.type

local MAINMENU_BUTTON = _G.MAINMENU_BUTTON
local MicroButtonTooltipText = _G.MicroButtonTooltipText

local buttonList = {}

function Module:MicroButton_SetupTexture(icon, texture)
	icon:SetPoint("TOPLEFT", texture, "TOPLEFT", -9, 5)
	icon:SetPoint("BOTTOMRIGHT", texture, "BOTTOMRIGHT", 10, -6)
	icon:SetTexture(K.MediaFolder .. "Skins\\" .. texture)
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
	local texture, method, tooltip = unpack(data)

	local bu = CreateFrame("Frame", "KKUI_MicroButtons", parent)
	table_insert(buttonList, bu)
	bu:SetSize(20, 20 * 1.4)
	bu:CreateBorder()

	local icon = bu:CreateTexture(nil, "ARTWORK")
	Module:MicroButton_SetupTexture(icon, texture)

	if type(method) == "string" then
		local button = _G[method]
		button:SetHitRectInsets(0, 0, 0, 0)
		button:SetParent(bu)
		button.__owner = bu
		hooksecurefunc(button, "SetParent", ResetButtonParent)
		ResetButtonAnchor(button)
		hooksecurefunc(button, "SetPoint", ResetButtonAnchor)
		button:UnregisterAllEvents()
		button:SetNormalTexture(nil)

		if tooltip then
			K.AddTooltip(button, "ANCHOR_RIGHT", tooltip)
		end

		local pushed = button:GetPushedTexture()
		local disabled = button:GetDisabledTexture()
		local highlight = button:GetHighlightTexture()
		local flash = button.Flash

		pushed:SetColorTexture(1, 0.84, 0, 0.2)
		pushed:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
		pushed:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)

		if disabled then
			disabled:SetColorTexture(1, 0, 0, 0.4)
			disabled:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
			disabled:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
		end

		highlight:SetTexture(K.MediaFolder .. "Skins\\HighlightMicroButton")
		highlight:SetVertexColor(K.r, K.g, K.b)
		highlight:SetPoint("TOPLEFT", button, "TOPLEFT", -22, 18)
		highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 24, -18)

		if flash then
			flash:SetTexture(K.MediaFolder .. "Skins\\HighlightMicroButton")
			flash:SetPoint("TOPLEFT", button, "TOPLEFT", -22, 18)
			flash:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 24, -18)
		end
	else
		bu:SetScript("OnMouseUp", method)
		K.AddTooltip(bu, "ANCHOR_RIGHT", tooltip)

		local highlight = bu:CreateTexture(nil, "HIGHLIGHT")
		highlight:SetTexture(K.MediaFolder .. "Skins\\HighlightMicroButton")
		highlight:SetVertexColor(K.r, K.g, K.b)
		highlight:SetPoint("TOPLEFT", bu, "TOPLEFT", -22, 18)
		highlight:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", 24, -18)
	end
end

function Module:CreateMicroMenu()
	if not C["ActionBar"].MicroBar then
		return
	end

	local menubar = CreateFrame("Frame", "KKUI_MenuBar", UIParent)
	menubar:SetSize(280, 20 * 1.4)
	K.Mover(menubar, "Menubar", "Menubar", { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -4, 4 })

	-- Generate Buttons
	local buttonInfo = {
		{ "CharacterMicroButton", "CharacterMicroButton" },
		{ "SpellbookMicroButton", "SpellbookMicroButton" },
		{ "TalentMicroButton", "TalentMicroButton" },
		{ "AchievementMicroButton", "AchievementMicroButton" },
		{ "QuestLogMicroButton", "QuestLogMicroButton" },
		{ "GuildMicroButton", "GuildMicroButton" },
		{ "LFDMicroButton", "LFDMicroButton" },
		{ "EJMicroButton", "EJMicroButton" },
		{ "CollectionsMicroButton", "CollectionsMicroButton" },
		{ "StoreMicroButton", "StoreMicroButton" },
		{ "MainMenuMicroButton", "MainMenuMicroButton", MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU") },
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
	K.HideInterfaceOption(MicroButtonPortrait)
	K.HideInterfaceOption(GuildMicroButtonTabard)
	K.HideInterfaceOption(MainMenuBarDownload)
	K.HideInterfaceOption(HelpOpenWebTicketButton)
	K.HideInterfaceOption(MainMenuBarPerformanceBar)
	MainMenuMicroButton:SetScript("OnUpdate", nil)
end
