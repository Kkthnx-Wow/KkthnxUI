local K, C = unpack(KkthnxUI)
local Module = K:GetModule("ActionBar")

-- Texture credit: 胡里胡涂
local _G = _G
local tinsert, pairs, type = table.insert, pairs, type
local buttonList = {}

function Module:MicroButton_SetupTexture(icon, texture)
	icon:SetPoint("TOPLEFT", texture, "TOPLEFT", -10, 6)
	icon:SetPoint("BOTTOMRIGHT", texture, "BOTTOMRIGHT", 12, -6)
	icon:SetTexture(K.MediaFolder .. "Skins\\" .. texture)
	icon:SetVertexColor(1, 1, 1)
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

	local bu = CreateFrame("Frame", nil, parent)
	tinsert(buttonList, bu)
	bu:SetSize(20, 28)
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
		button:SetPushedTexture(nil)
		button:SetDisabledTexture(nil)
		if tooltip then
			K.AddTooltip(button, "ANCHOR_RIGHT", tooltip)
		end

		local hl = button:GetHighlightTexture()
		Module:MicroButton_SetupTexture(hl, texture)
		hl:SetVertexColor(1, 1, 0)

		local flash = button.Flash
		Module:MicroButton_SetupTexture(flash, texture)
		flash:SetVertexColor(1, 1, 0)
	else
		bu:SetScript("OnMouseUp", method)
		K.AddTooltip(bu, "ANCHOR_RIGHT", tooltip)

		local hl = bu:CreateTexture(nil, "HIGHLIGHT")
		hl:SetBlendMode("ADD")
		Module:MicroButton_SetupTexture(hl, texture)
		hl:SetVertexColor(1, 1, 0)
	end
end

function Module:CreateMicroMenu()
	if not C["ActionBar"].MicroBar then
		return
	end

	local menubar = CreateFrame("Frame", nil, UIParent)
	menubar:SetSize(280, 28)
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
