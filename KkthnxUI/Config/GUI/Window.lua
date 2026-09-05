--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Config/GUI/Window.lua
	Purpose:
		The options window: a movable panel with a category list on the left and
		a scrollable content area on the right. Standard categories are laid out
		from the schema. A category may instead point to a custom panel builder
		(used by Profiles).
-----------------------------------------------------------------------------]]

local K, L = KkthnxUI[1], KkthnxUI[3]

local tinsert = table.insert

-- Theme colours from the palette so the window tracks any palette change.
local ACCENT = K.Colors.accent
local PANEL = K.Colors.panel

-- Category name to a game icon. These come from the client's own icon library so
-- there is no art of ours to ship or keep current. A category with no entry here
-- simply draws no icon.
local CATEGORY_ICON = {
	General = "INV_Misc_Gear_01",
	ActionBar = "INV_Misc_EngGizmos_30",
	Unitframe = "Achievement_Character_Human_Male",
	Minimap = "INV_Misc_Map_01",
	Auras = "Spell_Holy_PowerWordShield",
	Cooldown = "Spell_Nature_TimeStop",
	Chat = "INV_Letter_15",
	Nameplate = "Ability_Hunter_MarkedForDeath",
	Tooltip = "INV_Misc_Note_01",
	ExperienceBar = "Achievement_Level_10",
	AlertFrames = "INV_Misc_Bell_01",
	PullCountdown = "INV_Misc_PocketWatch_01",
	GroupTools = "INV_Misc_GroupLooking",
	Loot = "INV_Box_01",
	MicroMenu = "INV_Misc_Book_09",
	Bags = "INV_Misc_Bag_08",
	Automation = "Trade_Engineering",
	Skins = "Trade_Engraving",
	Movers = "Ability_Hunter_Pathfinding",
	Profiles = "INV_Misc_ScrollUnrolled01",
}

local GUI = K.GUI
GUI.CustomPanels = GUI.CustomPanels or {}

local window, reloadHint

-- ---------------------------------------------------------------------------
-- Panel layout
-- ---------------------------------------------------------------------------

-- Split a flat control list into sections. Every "header" starts a new section
-- whose title is the header label, controls before the first header form an
-- untitled section so nothing is ever dropped.
local function SplitSections(controls)
	local sections, current = {}, nil
	for _, control in ipairs(controls) do
		if control.kind == "header" then
			current = { title = control.label, fullWidth = control.fullWidth, controls = {} }
			sections[#sections + 1] = current
		else
			if not current then
				current = { controls = {} }
				sections[#sections + 1] = current
			end
			current.controls[#current.controls + 1] = control
		end
	end
	return sections
end

-- Build one titled card: a soft box holding a section's controls, stacked by
-- each widget's height. Returns the card and its measured height.
local function BuildCard(host, section, width)
	local card = CreateFrame("Frame", nil, host)
	card:SetWidth(width)
	-- A subtle top-lit gradient lifts each card off the flat panel behind it.
	K.GradientBG(card, 0.16, 0.17, 0.19, 0.55, 0.10, 0.10, 0.12, 0.55)

	local contentWidth = width - 30
	local y = -10
	if section.title then
		local fs = card:CreateFontString(nil, "OVERLAY")
		K.SetFont(fs, 13, "OUTLINE")
		fs:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3])
		fs:SetPoint("TOPLEFT", card, "TOPLEFT", 12, -10)
		fs:SetText(section.title)

		local rule = card:CreateTexture(nil, "ARTWORK")
		rule:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.25)
		rule:SetHeight(1)
		rule:SetPoint("TOPLEFT", card, "TOPLEFT", 10, -28)
		rule:SetPoint("TOPRIGHT", card, "TOPRIGHT", -10, -28)
		y = -36
	end

	for _, control in ipairs(section.controls) do
		local builder = GUI.Builders[control.kind]
		if builder then
			local widget = builder(card, control)
			-- Stretch width-aware widgets (sliders, dropdowns) to fill the card so
			-- their left and right edges share one grid line.
			if widget.KKUI_SetWidth then
				widget.KKUI_SetWidth(contentWidth)
			end
			-- Descriptions wrap, refit them to the card so text never spills past
			-- the edge and the stored height matches the wrapped text.
			if control.kind == "description" and widget.SetWidth then
				widget:SetWidth(contentWidth)
				widget.height = (widget:GetStringHeight() or 12) + 8
			end
			widget:ClearAllPoints()
			local indent = control.kind == "description" and 12 or 16
			widget:SetPoint("TOPLEFT", card, "TOPLEFT", indent, y)
			y = y - (widget.height or 28)
		end
	end

	local height = -y + 10
	card:SetHeight(height)
	return card, height
end

-- Lay a control list into titled cards and flow the cards down `columns`
-- columns, always dropping the next card into the shortest column so mixed
-- section heights stay balanced. A header may set `fullWidth` to span all
-- columns. Exposed on GUI so flyouts reuse the same logic (they pass 1 column).
function GUI.LayoutControls(host, controls, opts)
	opts = opts or {}
	local columns = opts.columns or 1
	local hostWidth = host:GetWidth()
	if hostWidth <= 1 then
		hostWidth = 520
	end
	local gutter = 12
	local colWidth = math.floor((hostWidth - gutter * (columns - 1)) / columns)

	local topPad = 8
	local cardGap = 14
	local used = {}
	for i = 1, columns do
		used[i] = 0
	end

	local function Shortest()
		local idx = 1
		for i = 2, columns do
			if used[i] < used[idx] then
				idx = i
			end
		end
		return idx
	end

	for _, section in ipairs(SplitSections(controls)) do
		local fullWidth = section.fullWidth or columns == 1
		if fullWidth then
			local card, height = BuildCard(host, section, hostWidth)
			local top = 0
			for i = 1, columns do
				top = math.max(top, used[i])
			end
			card:SetPoint("TOPLEFT", host, "TOPLEFT", 0, -(topPad + top))
			for i = 1, columns do
				used[i] = top + height + cardGap
			end
		else
			local col = Shortest()
			local card, height = BuildCard(host, section, colWidth)
			local x = (col - 1) * (colWidth + gutter)
			card:SetPoint("TOPLEFT", host, "TOPLEFT", x, -(topPad + used[col]))
			used[col] = used[col] + height + cardGap
		end
	end

	local total = 0
	for i = 1, columns do
		total = math.max(total, used[i])
	end
	total = total + topPad
	host:SetHeight(total)
	return total
end

-- Build one category panel (a scroll frame + child) on demand.
local function BuildPanel(parent, category)
	local scroll = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
	-- Leave room at the top for the section title and its rule.
	scroll:SetPoint("TOPLEFT", 4, -34)
	scroll:SetPoint("BOTTOMRIGHT", -26, 4)

	K.SkinScrollBar(scroll.ScrollBar)

	local child = CreateFrame("Frame", nil, scroll)
	child:SetSize(1, 1)
	scroll:SetScrollChild(child)
	child:SetWidth(parent:GetWidth() - 34)

	if category.custom and GUI.CustomPanels[category.custom] then
		GUI.CustomPanels[category.custom](child)
	else
		GUI.LayoutControls(child, category.controls, { columns = category.columns })
	end

	scroll:Hide()
	return scroll
end

-- ---------------------------------------------------------------------------
-- Window
-- ---------------------------------------------------------------------------

local function BuildWindow()
	window = CreateFrame("Frame", "KKUI_ConfigWindow", UIParent)
	window:SetSize(780, 560)
	window:SetPoint("CENTER")
	window:SetFrameStrata("HIGH")
	window:EnableMouse(true)
	window:SetMovable(true)
	window:RegisterForDrag("LeftButton")
	window:SetScript("OnDragStart", window.StartMoving)
	window:SetScript("OnDragStop", window.StopMovingOrSizing)
	K.CreateGradientBackground(window)
	K.CreateBorder(window)
	tinsert(UISpecialFrames, "KKUI_ConfigWindow")
	GUI.window = window
	window:HookScript("OnHide", function()
		if GUI.HideExtras then
			GUI.HideExtras()
		end
	end)

	local header = window:CreateFontString(nil, "OVERLAY")
	K.SetFont(header, 18, "OUTLINE")
	header:SetPoint("TOP", 0, -14)
	header:SetText("|cff5C8BCFKkthnxUI|r  " .. K.Version)

	local close = CreateFrame("Button", nil, window, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -6, -6)
	K.SkinCloseButton(close)

	-- Left category column, scrollable so it never runs into the footer no matter
	-- how many categories exist.
	local nav = CreateFrame("Frame", nil, window)
	nav:SetPoint("TOPLEFT", 12, -46)
	nav:SetPoint("BOTTOMLEFT", 12, 44)
	nav:SetWidth(160)
	K.CreateBackground(nav, PANEL[1], PANEL[2], PANEL[3], 0.85)
	K.CreateBorder(nav)

	-- Search box to filter the category list by name.
	local search = CreateFrame("EditBox", nil, nav, "InputBoxTemplate")
	search:SetHeight(20)
	search:SetPoint("TOPLEFT", nav, "TOPLEFT", 8, -6)
	search:SetPoint("TOPRIGHT", nav, "TOPRIGHT", -8, -6)
	search:SetAutoFocus(false)
	search:SetTextInsets(4, 4, 0, 0)
	K.SkinEditBox(search)

	local searchHint = search:CreateFontString(nil, "OVERLAY")
	K.SetFont(searchHint, 11)
	searchHint:SetTextColor(K.Colors.disabled[1], K.Colors.disabled[2], K.Colors.disabled[3])
	searchHint:SetPoint("LEFT", search, "LEFT", 4, 0)
	searchHint:SetText(L["Search..."])

	local navScroll = CreateFrame("ScrollFrame", nil, nav)
	navScroll:SetPoint("TOPLEFT", 3, -32)
	navScroll:SetPoint("BOTTOMRIGHT", -3, 4)
	navScroll:EnableMouseWheel(true)
	navScroll:SetScript("OnMouseWheel", function(self, delta)
		local range = self:GetVerticalScrollRange()
		local target = self:GetVerticalScroll() - delta * 34
		if target < 0 then
			target = 0
		elseif target > range then
			target = range
		end
		self:SetVerticalScroll(target)
	end)

	local navChild = CreateFrame("Frame", nil, navScroll)
	navChild:SetSize(154, 1)
	navScroll:SetScrollChild(navChild)

	-- Right content area.
	local content = CreateFrame("Frame", nil, window)
	content:SetPoint("TOPLEFT", nav, "TOPRIGHT", 10, 0)
	content:SetPoint("BOTTOMRIGHT", -12, 44)
	K.CreateBackground(content, PANEL[1], PANEL[2], PANEL[3], 0.85)
	K.CreateBorder(content)

	-- Section title so it is always clear which page is open.
	local contentTitle = content:CreateFontString(nil, "OVERLAY")
	K.SetFont(contentTitle, 15, "OUTLINE")
	contentTitle:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3])
	contentTitle:SetPoint("TOPLEFT", content, "TOPLEFT", 12, -8)
	local titleRule = content:CreateTexture(nil, "ARTWORK")
	titleRule:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.35)
	titleRule:SetHeight(1)
	titleRule:SetPoint("TOPLEFT", content, "TOPLEFT", 8, -28)
	titleRule:SetPoint("TOPRIGHT", content, "TOPRIGHT", -8, -28)

	local panels = {}
	local buttons = {}
	local function Select(name)
		for key, panel in pairs(panels) do
			panel:SetShown(key == name)
			local btn = buttons[key]
			if btn then
				local active = key == name
				btn.KKUI_Background:SetVertexColor(active and 0.2 or 0.16, active and 0.35 or 0.16, active and 0.6 or 0.16, active and 0.9 or 0.5)
				btn.Accent:SetShown(active)
				btn.Text:SetTextColor(active and 0.4 or 0.85, active and 0.6 or 0.85, active and 1 or 0.85)
			end
		end
		contentTitle:SetText(GUI.categoryTitles and GUI.categoryTitles[name] or "")
	end

	GUI.categoryTitles = {}

	local order = {}
	for _, category in ipairs(GUI.schema) do
		panels[category.name] = BuildPanel(content, category)
		GUI.categoryTitles[category.name] = category.title

		local btn = CreateFrame("Button", nil, navChild)
		btn:SetSize(148, 30)
		order[#order + 1] = { btn = btn, title = category.title }
		-- No per-button border: a clean rail where only the accent bar and a soft
		-- background mark the active tab.
		K.CreateBackground(btn, 0.16, 0.16, 0.16, 0.5)

		-- Accent bar on the left marks the active tab.
		local acc = btn:CreateTexture(nil, "OVERLAY")
		acc:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 1)
		acc:SetPoint("TOPLEFT", btn.KKUI_Background, "TOPLEFT", 0, 0)
		acc:SetPoint("BOTTOMLEFT", btn.KKUI_Background, "BOTTOMLEFT", 0, 0)
		acc:SetWidth(3)
		acc:Hide()
		btn.Accent = acc

		local iconName = CATEGORY_ICON[category.name]
		local hasIcon = iconName ~= nil or category.icon
		if hasIcon then
			-- Each icon sits in its own small chip: a gradient face with our border
			-- around it, the same framed treatment the close button uses, so the row
			-- reads as a set of buttons rather than loose artwork.
			local chip = CreateFrame("Frame", nil, btn)
			chip:SetSize(24, 24)
			chip:SetPoint("LEFT", 6, 0)
			K.GradientBG(chip, 0.16, 0.17, 0.19, 0.9, 0.10, 0.10, 0.12, 0.9)
			K.CreateBorder(chip)

			local icon = chip:CreateTexture(nil, "ARTWORK")
			-- Fill the chip, leaving the 1px border visible.
			icon:SetPoint("TOPLEFT", 1, -1)
			icon:SetPoint("BOTTOMRIGHT", -1, 1)
			-- A game icon for the category, falling back to whatever texture the
			-- category itself supplied.
			if iconName and K.SetGUIIcon then
				K.SetGUIIcon(icon, iconName)
			else
				icon:SetTexture(category.icon)
				icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			end
		end

		local text = btn:CreateFontString(nil, "OVERLAY")
		K.SetFont(text, 12)
		text:SetPoint("LEFT", hasIcon and 34 or 12, 0)
		text:SetText(category.title)
		btn.Text = text

		local hl = btn:CreateTexture(nil, "HIGHLIGHT")
		hl:SetAllPoints(btn.KKUI_Background)
		hl:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.2)

		btn:SetScript("OnClick", function()
			Select(category.name)
		end)
		buttons[category.name] = btn
	end

	-- Stack the buttons that match the search text and size the scroll child to
	-- them. An empty query shows everything.
	local function Relayout(query)
		query = query and query:lower() or ""
		local y = -10
		for _, entry in ipairs(order) do
			local match = query == "" or entry.title:lower():find(query, 1, true)
			if match then
				entry.btn:ClearAllPoints()
				entry.btn:SetPoint("TOP", navChild, "TOP", 0, y)
				entry.btn:Show()
				y = y - 34
			else
				entry.btn:Hide()
			end
		end
		navChild:SetHeight(-y + 10)
		navScroll:SetVerticalScroll(0)
	end
	Relayout("")

	search:SetScript("OnTextChanged", function(self)
		local text = self:GetText()
		searchHint:SetShown(text == "")
		Relayout(text)
	end)
	search:SetScript("OnEscapePressed", function(self)
		self:SetText("")
		self:ClearFocus()
	end)

	-- Footer: reload button and hint.
	local reload = CreateFrame("Button", nil, window, "UIPanelButtonTemplate")
	reload:SetSize(140, 26)
	reload:SetPoint("BOTTOMRIGHT", -12, 12)
	reload:SetText(L["Reload UI"])
	K.SkinButton(reload, true)
	reload:SetScript("OnClick", ReloadUI)

	reloadHint = window:CreateFontString(nil, "OVERLAY")
	K.SetFont(reloadHint, 11)
	reloadHint:SetPoint("BOTTOMLEFT", 16, 18)
	reloadHint:SetText(L["Changes marked with a reload take effect after /reload."])

	Select(GUI.schema[1].name)
	GUI.RefreshDependencies()
	window:Hide()
	return window
end

-- Highlight the reload hint when a reload-flagged setting changes.
function GUI.MarkReload()
	if reloadHint then
		reloadHint:SetTextColor(1, 0.5, 0.1)
		reloadHint:SetText(L["Reload needed for some changes to apply."])
	end
end

function K.ToggleConfigGUI()
	if not window then
		BuildWindow()
	end
	window:SetShown(not window:IsShown())
end

-- Used by controls that hand the screen over to something else, like unlocking
-- the movers.
function GUI.Hide()
	if window then
		if GUI.HideExtras then
			GUI.HideExtras()
		end
		window:Hide()
	end
end
