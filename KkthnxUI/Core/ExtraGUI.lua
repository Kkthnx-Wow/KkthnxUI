--[[-----------------------------------------------------------------------------
Addon: KkthnxUI
Author: Josh "Kkthnx" Russell
Notes:
- Purpose: Side panel GUI for supplemental configuration options.
- Design: Dynamic registration, search-enabled, and profile-aware.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

-- ---------------------------------------------------------------------------
-- Locals & Global Caching
-- ---------------------------------------------------------------------------

-- PERF: Cache frequent APIs and globals to minimize table lookups.
local _G = _G
local _, max, min = math.floor, math.max, math.min
local format = string.format
local ipairs, pairs, type = ipairs, pairs, type

-- WoW API
local CreateFrame = CreateFrame
local UIParent = UIParent

-- ---------------------------------------------------------------------------
-- UTILITY HELPERS
-- ---------------------------------------------------------------------------


-- ---------------------------------------------------------------------------
-- STATIC EVENT HANDLERS
-- ---------------------------------------------------------------------------

-- NOTE: Handles cogwheel clicks in the main GUI to toggle the ExtraGUI panel.
local function OnCogwheelClicked(self)
	local configPath = self.configPath
	local optionTitle = self.optionTitle
	local icon = self.icon

	if not configPath then
		return
	end

	-- Visual feedback
	if icon then
		icon:SetVertexColor(1, 1, 1, 1)
		C_Timer.After(0.1, function()
			if icon and icon.SetVertexColor then
				icon:SetVertexColor(K.r, K.g, K.b, 1)
			end
		end)
	end

	-- REASON: Close Profile GUI if open to prevent window overlap and visual clutter.
	if K.ProfileGUI and K.ProfileGUI.Frame and K.ProfileGUI.Frame:IsShown() then
		K.ProfileGUI:Hide()
	end

	-- REASON: Toggle the panel off if the same config is clicked again.
	local ExtraGUI = K.ExtraGUI
	if ExtraGUI and ExtraGUI.IsVisible and ExtraGUI.CurrentConfig and ExtraGUI.CurrentConfig.configPath == configPath then
		-- Same config is open, close it (toggle off)
		ExtraGUI:Hide()
	elseif ExtraGUI then
		-- Different config or not open, show it (toggle on or switch)
		ExtraGUI:ShowExtraConfig(configPath, optionTitle)
	end

	-- Play sound feedback
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

local function OnCogwheelEnter(self)
	local icon = self.icon
	if not icon then
		return
	end

	local ACCENT_COLOR = { K.r, K.g, K.b }
	icon:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)

	-- Add subtle scaling effect
	icon:SetSize(30, 30)

	-- Show tooltip
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(L["Extra Configuration"] or "Extra Configuration", 1, 1, 1, 1, true)
	local optionTitle = self.optionTitle or self.configPath or ""
	local tipMsg = format(L["Click to open additional options for %s"] or "Click to open additional options for %s", optionTitle)
	GameTooltip:AddLine(tipMsg, 0.7, 0.7, 0.7, true)
	GameTooltip:Show()
end

local function OnCogwheelLeave(self)
	local icon = self.icon
	if not icon then
		return
	end

	icon:SetVertexColor(0.8, 0.8, 0.8, 0.9)

	-- Return to normal size
	icon:SetSize(22, 22)

	GameTooltip:Hide()
end

-- ---------------------------------------------------------------------------
-- CONFIGURATION API
-- ---------------------------------------------------------------------------

-- Get default value for a config path
local function GetDefaultValue(configPath)
	return K.GUIConfigService:GetDefaultValue(configPath)
end

-- Get extra configuration value by path
local function GetExtraConfigValue(configPath)
	return K.GUIConfigService:GetValue(configPath)
end

-- REASON: Propagates changes to main GUI and handles reload tracking/hooks.
local function SetExtraConfigValue(configPath, value, settingName)
	-- NOTE: Prefers K.NewGUI:SetConfigValue to ensure consistent behavior across all parts of the addon.
	if K.NewGUI and K.NewGUI.SetConfigValue then
		-- Main GUI's SetConfigValue handles everything: saving, hooks, and reload tracking
		K.NewGUI:SetConfigValue(configPath, value, false, settingName)
		return true
	end

	-- Fallback if main GUI not available (shouldn't happen in normal operation).
	-- GUIConfigService owns the runtime + SavedVariables write path.
	local oldValue = K.GUIConfigService:SetValue(configPath, value)

	-- Execute real-time update hooks (if available from main GUI)
	if oldValue ~= value then
		if K.NewGUI and K.NewGUI.TriggerHooks and type(K.NewGUI.TriggerHooks) == "function" then
			K.NewGUI:TriggerHooks(configPath, value, oldValue)
		end
	end

	return true
end

-- ---------------------------------------------------------------------------
-- RESET TO DEFAULT FUNCTIONALITY
-- ---------------------------------------------------------------------------

-- REASON: Provides a way for users to revert individual settings without a full GUI reset.
local function ResetToDefault(configPath, widget, settingName)
	local defaultValue = GetDefaultValue(configPath)
	if defaultValue == nil then
		-- No default found, show warning
		print("|cffff6b6bKkthnxUI:|r No default value found for " .. (settingName or configPath))
		return false
	end

	local currentValue = GetExtraConfigValue(configPath)
	if currentValue == defaultValue then
		-- Already at default, provide feedback
		print("|cff669DFFKkthnxUI:|r " .. (settingName or configPath) .. " is already at default value")
		return false
	end

	-- Set to default value
	SetExtraConfigValue(configPath, defaultValue, settingName)

	-- Update widget display
	if widget and widget.UpdateValue then
		widget:UpdateValue()
	end

	-- Visual feedback - brief highlight
	if widget then
		local originalBg = widget.KKUI_Background
		if not originalBg then
			-- Try to find the background texture
			for i = 1, widget:GetNumRegions() do
				local region = select(i, widget:GetRegions())
				if region and region:GetObjectType() == "Texture" and region:GetDrawLayer() == "BACKGROUND" then
					originalBg = region
					break
				end
			end
		end

		if originalBg and originalBg.SetVertexColor then
			-- Brief green flash to indicate reset
			originalBg:SetVertexColor(0.3, 0.9, 0.3, 0.6)
			C_Timer.After(0.2, function()
				originalBg:SetVertexColor(0.12, 0.12, 0.12, 0.8)
			end)
		end
	end

	-- Audio feedback
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

	-- Print success message
	print("|cff669DFFKkthnxUI:|r Reset " .. (settingName or configPath) .. " to default")
	return true
end

-- ---------------------------------------------------------------------------
-- CONTROL KEY CHECKER (RESET BUTTONS)
-- ---------------------------------------------------------------------------

-- REASON: Attaches a hidden reset button to a widget that appears only when Ctrl is held.
local function AddResetToDefaultFunctionality(widget, label, configPath, cleanText)
	return K.GUIResetButtons:Attach(widget, label, configPath, cleanText, ResetToDefault, 5)
end

-- ---------------------------------------------------------------------------
-- CONSTANTS & LAYOUT CONFIG
-- ---------------------------------------------------------------------------

-- REASON: Panel dimensions are now actually derived from the shared K.GUILayout
-- (WidgetFactory.lua), so "consistent with the main GUI" is true by construction.
local layout = K.GUILayout
local PANEL_WIDTH = layout.PanelWidth
local PANEL_HEIGHT = layout.PanelHeight
local EXTRA_PANEL_WIDTH = PANEL_WIDTH / 2 -- Half the width of main GUI
local SPACING = layout.Spacing
local HEADER_HEIGHT = layout.HeaderHeight

-- Colors: pull from the shared K.GUITheme (WidgetFactory.lua) for a uniform look.
-- NOTE: ExtraGUI intentionally uses the FULL-strength accent (not the dimmed one
-- the main config uses), so it reads theme.Accent. Don't "fix" this to AccentDim.
local theme = K.GUITheme
local ACCENT_COLOR = theme.Accent
local TEXT_COLOR = theme.Text
local BG_COLOR = C["Media"].Backdrops.ColorBackdrop

-- ---------------------------------------------------------------------------
-- INTERNAL HELPERS
-- ---------------------------------------------------------------------------

-- PERF: Use unified widget factory to reduce individual texture allocations.
local CreateColoredBackground = K.WidgetFactory.CreateBackdrop

-- Create section header with background (reduces code duplication)
local function CreateSectionHeader(parent, text, width, yOffset)
	local headerFrame = CreateFrame("Frame", nil, parent)
	headerFrame:SetSize(width or (EXTRA_PANEL_WIDTH - 40), 30)
	headerFrame:SetPoint("TOPLEFT", 0, yOffset or 0)

	-- Section header background
	local headerBg = headerFrame:CreateTexture(nil, "BACKGROUND")
	headerBg:SetAllPoints()
	headerBg:SetTexture(C["Media"].Textures.White8x8Texture)
	headerBg:SetVertexColor(0.1, 0.1, 0.1, 0.8)

	local headerText = headerFrame:CreateFontString(nil, "OVERLAY")
	headerText:SetFontObject(K.UIFont)
	headerText:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
	headerText:SetText(text)
	headerText:SetPoint("LEFT", headerFrame, "LEFT", 10, 0)

	return headerFrame, headerText
end

-- ---------------------------------------------------------------------------
-- EXTRAGUI MODULE CORE
-- ---------------------------------------------------------------------------

local ExtraGUI = {
	ExtraConfigs = {},
	CurrentConfig = nil,
	IsVisible = false,
	IsInitialized = false,
}

-- ---------------------------------------------------------------------------
-- CONFIGURATION REGISTRATION
-- ---------------------------------------------------------------------------

-- REASON: Allows other modules to hook into the GUI and provide supplemental settings.
function ExtraGUI:RegisterExtraConfig(configPath, createContentFunc, title)
	if not configPath or not createContentFunc then
		error("ExtraGUI config must have configPath and createContentFunc")
		return false
	end

	local config = {
		configPath = configPath,
		createContent = createContentFunc,
		title = title or configPath,
	}

	self.ExtraConfigs[configPath] = config
	return config
end

-- Check if a config path has extra configuration
function ExtraGUI:HasExtraConfig(configPath)
	return self.ExtraConfigs[configPath] ~= nil
end

-- ---------------------------------------------------------------------------
-- UI COMPONENT: SIDE PANEL FRAME
-- ---------------------------------------------------------------------------

-- REASON: Creates the physical frame for the side panel; lazy-loaded when needed.
function ExtraGUI:CreateFrame()
	if self.Frame then
		return self.Frame
	end

	-- Create the extra panel frame
	local frame = CreateFrame("Frame", "KkthnxUI_ExtraGUI", UIParent)
	frame:SetSize(EXTRA_PANEL_WIDTH, PANEL_HEIGHT)
	frame:SetFrameStrata("HIGH")
	frame:SetFrameLevel(105) -- Slightly higher than main GUI
	frame:EnableMouse(true)
	frame:Hide()

	-- REASON: Position to the right of main GUI; set dynamically during Show().

	-- Main background with same styling as main GUI
	local mainBg = frame:CreateTexture(nil, "BACKGROUND")
	mainBg:SetAllPoints()
	mainBg:SetTexture(C["Media"].Textures.White8x8Texture)
	mainBg:SetVertexColor(0.08, 0.08, 0.08, 0.95)

	-- Subtle shadow effect
	local shadow = CreateFrame("Frame", nil, frame)
	shadow:SetPoint("TOPLEFT", -8, 8) -- Smaller shadow since it's a side panel
	shadow:SetPoint("BOTTOMRIGHT", 8, -8)
	shadow:SetFrameLevel(frame:GetFrameLevel() - 1)
	local shadowTexture = shadow:CreateTexture(nil, "BACKGROUND")
	shadowTexture:SetAllPoints()
	shadowTexture:SetTexture(C["Media"].Textures.White8x8Texture)
	shadowTexture:SetVertexColor(0, 0, 0, 0.3)

	-- Title Bar
	local titleBar = CreateFrame("Frame", nil, frame)
	titleBar:SetPoint("TOPLEFT", 0, 0)
	titleBar:SetPoint("TOPRIGHT", 0, 0)
	titleBar:SetHeight(HEADER_HEIGHT)

	CreateColoredBackground(titleBar, ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3])

	-- NOTE: Center-aligned title text for the side panel.
	local title = titleBar:CreateFontString(nil, "OVERLAY")
	title:SetFontObject(K.UIFont)
	title:SetTextColor(1, 1, 1, 1)
	title:SetText(L["Extra Configuration"] or "Extra Configuration")
	title:SetPoint("CENTER", 0, -1)

	-- REASON: Standardized close button using atlas icons.
	local closeButton = CreateFrame("Button", nil, titleBar)
	closeButton:SetSize(32, 32)
	closeButton:SetPoint("RIGHT", -8, 0)

	-- Close button background
	local closeBg = closeButton:CreateTexture(nil, "BACKGROUND")
	closeBg:SetAllPoints()
	closeBg:SetTexture(C["Media"].Textures.White8x8Texture)
	closeBg:SetVertexColor(0, 0, 0, 0) -- Transparent by default

	-- Use atlas icon for close button
	closeButton.Icon = closeButton:CreateTexture(nil, "ARTWORK")
	closeButton.Icon:SetSize(16, 16)
	closeButton.Icon:SetPoint("CENTER")
	closeButton.Icon:SetAtlas("uitools-icon-close")
	closeButton.Icon:SetVertexColor(1, 1, 1, 0.8)

	closeButton:SetScript("OnClick", function()
		self:Hide()
	end)

	closeButton:SetScript("OnEnter", function(self)
		self.Icon:SetVertexColor(1, 1, 1, 1)
		closeBg:SetVertexColor(1, 0.2, 0.2, 0.3)
	end)

	closeButton:SetScript("OnLeave", function(self)
		self.Icon:SetVertexColor(1, 1, 1, 0.8)
		closeBg:SetVertexColor(0, 0, 0, 0)
	end)

	-- ---------------------------------------------------------------------------
	-- Scrolling Content Area
	-- ---------------------------------------------------------------------------
	local content = CreateFrame("Frame", nil, frame)
	content:SetPoint("TOPLEFT", 0, -HEADER_HEIGHT)
	content:SetPoint("BOTTOMRIGHT", 0, 0)

	CreateColoredBackground(content, BG_COLOR[1], BG_COLOR[2], BG_COLOR[3], BG_COLOR[4])

	-- Scroll Frame for content
	local scrollFrame = CreateFrame("ScrollFrame", nil, content)
	scrollFrame:SetPoint("TOPLEFT", SPACING, -SPACING)
	scrollFrame:SetPoint("BOTTOMRIGHT", -SPACING, SPACING)

	-- NOTE: Attaches the KkthnxUI custom scroll logic to handle mousewheel interaction.
	if K and K.GUIHelpers and K.GUIHelpers.AttachSimpleScroll then
		K.GUIHelpers.AttachSimpleScroll(scrollFrame, 40)
	end

	local scrollChild = CreateFrame("Frame", nil, scrollFrame)
	scrollChild:SetWidth(scrollFrame:GetWidth() - 10)
	scrollChild:SetHeight(1)
	scrollFrame:SetScrollChild(scrollChild)

	-- Keep scroll child responsive on size changes
	scrollFrame:SetScript("OnSizeChanged", function(self)
		if self:GetWidth() and scrollChild then
			scrollChild:SetWidth(math.max(1, self:GetWidth() - 10))
		end
	end)

	-- Store references
	self.Frame = frame
	self.TitleBar = titleBar
	self.Title = title
	self.Content = content
	self.ScrollFrame = scrollFrame
	self.ScrollChild = scrollChild

	self.IsInitialized = true
	return frame
end

-- ---------------------------------------------------------------------------
-- PANEL POSITIONING LOGIC
-- ---------------------------------------------------------------------------

-- REASON: Ensures the panel is always flush with the main GUI's right edge.
function ExtraGUI:PositionPanel()
	if not self.Frame then
		return
	end

	-- Get main GUI frame reference
	local mainGUI = K.NewGUI and K.NewGUI.Frame
	-- Also try the module reference
	if not mainGUI and K.GUI and K.GUI.GUI and K.GUI.GUI.Frame then
		mainGUI = K.GUI.GUI.Frame
	end

	if not mainGUI or not mainGUI:IsShown() then
		-- If main GUI isn't available or shown, position relative to screen center
		self.Frame:SetPoint("CENTER", UIParent, "CENTER", PANEL_WIDTH / 2 + 20, 0)
		return
	end

	-- Position to the right of the main GUI with a small gap
	self.Frame:ClearAllPoints()
	self.Frame:SetPoint("TOPLEFT", mainGUI, "TOPRIGHT", 18, 0)
	self.Frame:SetSize(EXTRA_PANEL_WIDTH, mainGUI:GetHeight())
end

-- ---------------------------------------------------------------------------
-- VISIBILITY CONTROL
-- ---------------------------------------------------------------------------

-- REASON: Main entry point for displaying a specific configuration module.
function ExtraGUI:ShowExtraConfig(configPath, optionTitle)
	-- Close ProfileGUI if it's open
	if K.ProfileGUI and K.ProfileGUI.Hide then
		K.ProfileGUI:Hide()
	end

	local config = self.ExtraConfigs[configPath]
	if not config then
		return
	end

	-- Container cache by configPath to avoid recreating content every time
	self.ConfigContainers = self.ConfigContainers or {}

	if not self.Frame then
		self:CreateFrame()
	end

	-- Hook main GUI close event if not already hooked
	if not self.MainGUIHooked then
		self:HookMainGUIClose()
	end

	-- Hide existing containers; we'll show or create for the requested path
	for _, container in pairs(self.ConfigContainers) do
		if container and container.Hide then
			container:Hide()
		end
	end

	-- Update title bar only (remove duplicate titles)
	local displayTitle = optionTitle or config.title
	self.Title:SetText(format(L["Extra: %s"] or "Extra: %s", displayTitle))

	-- Start content layout with proper spacing
	local yOffset = -20

	-- NOTE: Category headers use a subtle background to delineate sections.
	if not self.CategoryTitleFrame then
		self.CategoryTitleFrame = CreateFrame("Frame", nil, self.ScrollChild)
		self.CategoryTitleFrame:SetSize(EXTRA_PANEL_WIDTH - 40, 30)

		local categoryBg = self.CategoryTitleFrame:CreateTexture(nil, "BACKGROUND")
		categoryBg:SetAllPoints()
		categoryBg:SetTexture(C["Media"].Textures.White8x8Texture)
		categoryBg:SetVertexColor(0.09, 0.09, 0.09, 0.8)

		self.CategoryTitleText = self.CategoryTitleFrame:CreateFontString(nil, "OVERLAY")
		self.CategoryTitleText:SetFontObject(K.UIFont)
		self.CategoryTitleText:SetTextColor(0.9, 0.9, 0.9, 1)
		self.CategoryTitleText:SetPoint("CENTER", self.CategoryTitleFrame, "CENTER", 0, 0)
	end

	-- Update existing objects instead of creating new ones
	self.CategoryTitleFrame:ClearAllPoints()
	self.CategoryTitleFrame:SetPoint("TOPLEFT", 15, yOffset)
	self.CategoryTitleText:SetText(displayTitle)
	self.CategoryTitleFrame:Show()

	-- Update yOffset after category title
	yOffset = yOffset - 45

	-- Create the extra configuration content once per configPath and reuse
	if config.createContent then
		local contentContainer = self.ConfigContainers[configPath]
		if not contentContainer then
			contentContainer = CreateFrame("Frame", nil, self.ScrollChild)
			contentContainer:SetPoint("TOPLEFT", 15, yOffset)
			contentContainer:SetSize(EXTRA_PANEL_WIDTH - 40, 1) -- Proper width with margins

			-- Add subtle content background like main GUI
			local contentBg = contentContainer:CreateTexture(nil, "BACKGROUND")
			contentBg:SetAllPoints()
			contentBg:SetTexture(C["Media"].Textures.White8x8Texture)
			contentBg:SetVertexColor(0.05, 0.05, 0.05, 0.4)

			config.createContent(contentContainer)
			self.ConfigContainers[configPath] = contentContainer
		else
			contentContainer:ClearAllPoints()
			contentContainer:SetPoint("TOPLEFT", 15, yOffset)
		end
		contentContainer:Show()

		-- Calculate proper height from actual content
		local contentHeight = 0
		for _, child in ipairs({ contentContainer:GetChildren() }) do
			if child:IsShown() then
				local childTop = child:GetTop() or 0
				local childBottom = child:GetBottom() or 0
				local containerTop = contentContainer:GetTop() or 0
				if childTop > 0 and childBottom > 0 and containerTop > 0 then
					local relativeTop = containerTop - childTop
					local relativeBottom = containerTop - childBottom
					contentHeight = max(contentHeight, relativeBottom - relativeTop)
				end
			end
		end

		-- Set proper container height with padding
		contentContainer:SetHeight(max(contentHeight + 40, 200))
		yOffset = yOffset - contentContainer:GetHeight() - 20
	end

	-- Add some bottom padding
	yOffset = yOffset - 20

	-- Set proper scroll child height
	local totalHeight = math.abs(yOffset) + 40
	self.ScrollChild:SetHeight(max(totalHeight, self.Content:GetHeight() - 20))

	-- Reset scroll position
	self.ScrollFrame:SetVerticalScroll(0)

	-- Position and show the panel
	self:PositionPanel()
	self.CurrentConfig = config
	self.Frame:Show()
	self.IsVisible = true
end

-- ---------------------------------------------------------------------------
-- GUI HOOKS
-- ---------------------------------------------------------------------------

-- REASON: Automatically closes the side panel when the main GUI is hidden.
function ExtraGUI:HookMainGUIClose()
	if self.MainGUIHooked then
		return
	end

	-- Try to find the main GUI frame
	local mainGUI = K.NewGUI and K.NewGUI.Frame
	if not mainGUI and K.GUI and K.GUI.GUI and K.GUI.GUI.Frame then
		mainGUI = K.GUI.GUI.Frame
	end

	if not mainGUI then
		return
	end

	-- Hook the main GUI's OnHide event
	-- Hook without overriding existing handlers
	mainGUI:HookScript("OnHide", function()
		self:Hide()
	end)

	self.MainGUIHooked = true
end

-- Hide the extra panel
function ExtraGUI:Hide()
	if self.Frame then
		self.Frame:Hide()
	end
	self.IsVisible = false
	self.CurrentConfig = nil
end

-- Toggle a config panel: open it, or close it if it's already the open one.
-- REASON: Launcher buttons (Open GUI / Open / Manage) should behave like the cogwheel - clicking
-- the same launcher again closes the panel instead of silently doing nothing.
function ExtraGUI:ToggleExtraConfig(configPath, optionTitle)
	if not configPath then
		return
	end

	if self.IsVisible and self.CurrentConfig and self.CurrentConfig.configPath == configPath then
		self:Hide()
	else
		self:ShowExtraConfig(configPath, optionTitle)
	end
end

-- Show/Toggle the extra panel
function ExtraGUI:Show()
	if self.IsVisible then
		self:Hide()
	end
end

function ExtraGUI:Toggle()
	if self.IsVisible then
		self:Hide()
	else
		self:Show()
	end
end

-- ---------------------------------------------------------------------------
-- COGWHEEL MANAGEMENT
-- ---------------------------------------------------------------------------

-- REASON: Injects a clickable icon into main GUI widgets to link to extra settings.
function ExtraGUI:CreateCogwheelIcon(widget, configPath, optionTitle)
	if not self:HasExtraConfig(configPath) then
		return nil
	end

	-- Find the label in the widget to position cogwheel next to it
	local label = nil

	-- Check for direct FontString children first
	for i = 1, widget:GetNumRegions() do
		local region = select(i, widget:GetRegions())
		if region and region:GetObjectType() == "FontString" then
			local point = region:GetPoint()
			if point == "LEFT" then
				label = region
				break
			end
		end
	end

	-- If no direct FontString found, check child frames
	if not label then
		for _, child in ipairs({ widget:GetChildren() }) do
			if child:GetObjectType() == "FontString" then
				local point = child:GetPoint()
				if point == "LEFT" then
					label = child
					break
				end
			end
		end
	end

	local cogwheel = CreateFrame("Button", nil, widget)
	cogwheel:SetSize(26, 26) -- Increased from 20x20 to 22x22 (2 more sizes up)

	-- Position next to the label
	if label then
		-- Position to the right of the label
		cogwheel:SetPoint("LEFT", label, "RIGHT", 0, 0)
	else
		-- Fallback: position after estimated text width
		cogwheel:SetPoint("LEFT", widget, "LEFT", 200, 0)
	end

	-- Cogwheel icon using a better gear atlas
	local icon = cogwheel:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints()

	-- Use the specified atlas for cogwheel with better error handling
	local success = pcall(function()
		icon:SetAtlas("GM-icon-settings", true)
		icon:SetSize(26, 26) -- Increased from 20x20 to 22x22
	end)

	if not success then
		-- Fallback to transmog icon if atlas fails
		local fallbackSuccess = pcall(function()
			icon:SetAtlas("transmog-icon-revert", true)
			icon:SetSize(26, 26) -- Increased from 20x20 to 22x22
		end)

		if not fallbackSuccess then
			-- Final fallback to a simple texture
			icon:SetTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
			icon:SetTexCoord(0, 1, 0, 1)
		end
	end

	icon:SetVertexColor(0.8, 0.8, 0.8, 0.9) -- Slightly brighter and more opaque

	-- Store config data in the button for static handlers to access
	cogwheel.configPath = configPath
	cogwheel.optionTitle = optionTitle
	cogwheel.icon = icon

	-- Use static handlers to prevent memory leaks
	cogwheel:SetScript("OnEnter", OnCogwheelEnter)
	cogwheel:SetScript("OnLeave", OnCogwheelLeave)
	cogwheel:SetScript("OnClick", OnCogwheelClicked)

	return cogwheel
end

-- ---------------------------------------------------------------------------
-- MODULE INITIALIZATION
-- ---------------------------------------------------------------------------

-- REASON: Ensures the module is only enabled once and pulls in initial configs.
function ExtraGUI:Enable()
	if self.IsInitialized or self._enabled then
		return true
	end

	-- Register the built-in extra configurations
	self:RegisterBuiltinConfigs()

	self.IsInitialized = true
	self._enabled = true
	return true
end

-- ---------------------------------------------------------------------------
-- WIDGET HELPERS
-- ---------------------------------------------------------------------------

-- NOTE: Standardizes spacing within the side panel.
local function GetExtraContentWidth()
	return EXTRA_PANEL_WIDTH - 40 -- Account for margins
end

-- REASON: Strips ISNEW markers from strings and returns a boolean for visual tagging.
local function ProcessNewTag(name)
	-- Handle nil or empty strings gracefully
	if not name or name == "" then
		return "", false
	end

	if K and K.GUIHelpers and K.GUIHelpers.ProcessNewTag then
		return K.GUIHelpers.ProcessNewTag(name)
	end

	local cleanName, hasNewTag = string.gsub(name, "ISNEW", "")
	return cleanName, (hasNewTag > 0)
end

-- NOTE: Reuses the system feature label template for a consistent "NEW" visual indicator.
local function AddNewTag(parent, anchor)
	if K and K.GUIHelpers and K.GUIHelpers.AddNewTag then
		return K.GUIHelpers.AddNewTag(parent, anchor)
	end
	local tag = CreateFrame("Frame", nil, parent, "NewFeatureLabelTemplate")
	tag:SetPoint("LEFT", anchor or parent, -29, 11)
	tag:SetScale(0.85)
	tag:Show()
	return tag
end

-- ---------------------------------------------------------------------------
-- WIDGET CREATION: SWITCH
-- ---------------------------------------------------------------------------

-- REASON: Toggle-based setting widget; features visual feedback and support for 'NEW' tags.
function ExtraGUI:CreateSwitch(parent, configPath, text, tooltip, hookFunction, isNew)
	local widget = CreateFrame("Frame", nil, parent)
	widget:SetSize(GetExtraContentWidth(), 28)
	widget.ConfigPath = configPath

	-- Background
	CreateColoredBackground(widget, 0.12, 0.12, 0.12, 0.8)

	-- Process NEW tag from text
	local cleanText, hasNewTag = ProcessNewTag(text)
	local showNewTag = isNew or hasNewTag

	-- Label
	local label = widget:CreateFontString(nil, "OVERLAY")
	label:SetFontObject(K.UIFont)
	label:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	label:SetText(cleanText)
	label:SetPoint("LEFT", 8, 0)

	-- Make label clickable for reset functionality
	if configPath then
		local labelButton = CreateFrame("Button", nil, widget)
		labelButton:SetAllPoints(label)
		labelButton:SetScript("OnClick", function(self, button)
			if button == "LeftButton" and IsControlKeyDown() then
				ResetToDefault(configPath, widget, cleanText)
			end
		end)

		-- Add reset-to-default functionality with undo icon
		AddResetToDefaultFunctionality(widget, label, configPath, cleanText)
	end

	-- Add NEW tag if specified
	if showNewTag then
		AddNewTag(widget, label)
	end

	-- Switch Button
	local switchButton = CreateFrame("Button", nil, widget)
	switchButton:SetSize(40, 16)
	switchButton:SetPoint("RIGHT", -8, 0)

	local switchBg = switchButton:CreateTexture(nil, "BACKGROUND")
	switchBg:SetAllPoints()
	switchBg:SetTexture(C["Media"].Textures.White8x8Texture)
	switchBg:SetVertexColor(0.3, 0.3, 0.3, 1)

	-- Switch Thumb
	local thumb = switchButton:CreateTexture(nil, "OVERLAY")
	thumb:SetSize(14, 14)
	thumb:SetTexture(C["Media"].Textures.White8x8Texture)
	thumb:SetVertexColor(1, 1, 1, 1)

	-- Tooltip
	if tooltip and K and K.GUIHelpers and K.GUIHelpers.CreateEnhancedTooltip then
		K.GUIHelpers.CreateEnhancedTooltip(widget, cleanText, tooltip)
	end

	-- Register hook function with main GUI's hook system
	if hookFunction and type(hookFunction) == "function" and configPath then
		if K.NewGUI and K.NewGUI.RegisterHook then
			K.NewGUI:RegisterHook(configPath, hookFunction)
		end
	end

	-- Update function using proper config system
	function widget:UpdateValue()
		if not self.ConfigPath then
			-- Default to false for switches without config path
			switchBg:SetVertexColor(0.3, 0.3, 0.3, 1)
			thumb:ClearAllPoints()
			thumb:SetPoint("LEFT", switchButton, "LEFT", 1, 0)
			label:SetTextColor(0.5, 0.5, 0.5, 1)
			return
		end

		local value = GetExtraConfigValue(self.ConfigPath)
		if value == nil then
			value = false -- Default for switches
		end

		if value then
			switchBg:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
			thumb:ClearAllPoints()
			thumb:SetPoint("RIGHT", switchButton, "RIGHT", -1, 0)
			-- White text when enabled
			label:SetTextColor(1, 1, 1, 1)
		else
			switchBg:SetVertexColor(0.3, 0.3, 0.3, 1)
			thumb:ClearAllPoints()
			thumb:SetPoint("LEFT", switchButton, "LEFT", 1, 0)
			-- Grey text when disabled
			label:SetTextColor(0.5, 0.5, 0.5, 1)
		end
	end

	-- Click handler using proper config system
	switchButton:SetScript("OnClick", function()
		if not configPath then
			-- For switches without config paths, we can't save the value
			-- Just call the hook function if provided for custom handling
			if hookFunction and type(hookFunction) == "function" then
				hookFunction(true, false, nil) -- Just provide dummy values
			end
			return
		end

		local currentValue = GetExtraConfigValue(configPath)
		if currentValue == nil then
			currentValue = false -- Default for switches
		end

		local newValue = not currentValue

		SetExtraConfigValue(configPath, newValue, cleanText)
		widget:UpdateValue()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

		-- Call hook function if provided
		if hookFunction and type(hookFunction) == "function" then
			hookFunction(newValue, currentValue, configPath)
		end
	end)

	-- Initialize with debugging
	widget:UpdateValue()
	return widget
end

-- ---------------------------------------------------------------------------
-- DEPENDENCY MANAGEMENT
-- ---------------------------------------------------------------------------

-- REASON: Allows widgets to be shown/hidden based on the value of another setting.
function ExtraGUI:DependsOn(childWidget, parentConfigPath, expectedValue, predicate)
	if K and K.GUIHelpers and K.GUIHelpers.BindDependency then
		return K.GUIHelpers.BindDependency(childWidget, parentConfigPath, expectedValue, predicate)
	end
	return childWidget
end

-- ---------------------------------------------------------------------------
-- WIDGET CREATION: SLIDER
-- ---------------------------------------------------------------------------

-- REASON: Range-based setting widget; supports fine adjustment via mousewheel.
function ExtraGUI:CreateSlider(parent, configPath, text, minVal, maxVal, step, tooltip, hookFunction, isNew)
	local widget = CreateFrame("Frame", nil, parent)
	widget:SetSize(GetExtraContentWidth(), 28)
	widget.ConfigPath = configPath

	-- Background
	CreateColoredBackground(widget, 0.12, 0.12, 0.12, 0.8)

	-- Process NEW tag from text
	local cleanText, hasNewTag = ProcessNewTag(text)
	local showNewTag = isNew or hasNewTag

	-- Label
	local label = widget:CreateFontString(nil, "OVERLAY")
	label:SetFontObject(K.UIFont)
	label:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	label:SetText(cleanText)
	label:SetPoint("LEFT", 8, 0)

	-- Make label clickable for reset functionality
	if configPath then
		local labelButton = CreateFrame("Button", nil, widget)
		labelButton:SetAllPoints(label)
		labelButton:SetScript("OnClick", function(self, button)
			if button == "LeftButton" and IsControlKeyDown() then
				ResetToDefault(configPath, widget, cleanText)
			end
		end)

		-- Add reset-to-default functionality with undo icon
		AddResetToDefaultFunctionality(widget, label, configPath, cleanText)
	end

	-- Add NEW tag if specified
	if showNewTag then
		AddNewTag(widget, label)
	end

	-- Value Display
	local valueText = widget:CreateFontString(nil, "OVERLAY")
	valueText:SetFontObject(K.UIFont)
	valueText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	valueText:SetPoint("RIGHT", -8, 0)

	-- Slider Container
	local sliderContainer = CreateFrame("Frame", nil, widget)
	sliderContainer:SetSize(80, 16) -- Smaller for extra panel
	sliderContainer:SetPoint("RIGHT", -40, 0)

	-- Slider Track
	local sliderTrack = sliderContainer:CreateTexture(nil, "BACKGROUND")
	sliderTrack:SetAllPoints()
	sliderTrack:SetTexture(C["Media"].Textures.White8x8Texture)
	sliderTrack:SetVertexColor(0.2, 0.2, 0.2, 1)

	-- Slider Thumb
	local thumbFrame = CreateFrame("Frame", nil, sliderContainer)
	thumbFrame:SetSize(12, 16)
	thumbFrame:EnableMouse(true)

	local thumbTexture = thumbFrame:CreateTexture(nil, "OVERLAY")
	thumbTexture:SetAllPoints()
	thumbTexture:SetTexture(C["Media"].Textures.White8x8Texture)
	thumbTexture:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)

	local currentValue = minVal
	local committedValue = minVal
	local isDragging = false

	-- Update thumb position
	local function UpdateThumbPosition(value)
		if not value then
			return
		end
		local percentage = (value - minVal) / (maxVal - minVal)
		local maxThumbPos = sliderContainer:GetWidth() - thumbFrame:GetWidth()
		local thumbPos = maxThumbPos * percentage
		thumbFrame:ClearAllPoints()
		thumbFrame:SetPoint("LEFT", sliderContainer, "LEFT", thumbPos, 0)
	end

	-- Get value from position
	local function GetValueFromPosition(x)
		local containerLeft = sliderContainer:GetLeft()
		local containerWidth = sliderContainer:GetWidth()
		local thumbWidth = thumbFrame:GetWidth()
		if not containerLeft then
			return currentValue
		end
		local relativeX = x - containerLeft
		local maxThumbPos = containerWidth - thumbWidth
		local percentage = math.max(0, math.min(1, relativeX / maxThumbPos))
		local rawValue = minVal + (maxVal - minVal) * percentage
		return math.floor(rawValue / step + 0.5) * step
	end

	-- Register hook function with main GUI's hook system
	if hookFunction and type(hookFunction) == "function" and configPath then
		if K.NewGUI and K.NewGUI.RegisterHook then
			K.NewGUI:RegisterHook(configPath, hookFunction)
		end
	end

	-- Update function
	function widget:UpdateValue()
		local value = GetExtraConfigValue(self.ConfigPath)
		if type(value) ~= "number" then
			value = minVal
		end

		value = math.max(minVal, math.min(maxVal, value))
		currentValue = value
		committedValue = value
		valueText:SetText(tostring(value))
		UpdateThumbPosition(value)
	end

	-- Mouse handling
	thumbFrame:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			isDragging = true

			-- PERF: Throttled OnUpdate to avoid excessive config writes and string operations during drag.
			local lastUpdate = 0
			local sinceLastCommit = 0

			self:SetScript("OnUpdate", function(self, elapsed)
				if not isDragging then
					self:SetScript("OnUpdate", nil)
					return
				end

				lastUpdate = lastUpdate + elapsed
				if lastUpdate < 0.033 then -- ~30 FPS visual updates
					return
				end
				lastUpdate = 0
				sinceLastCommit = sinceLastCommit + elapsed

				local x = GetCursorPosition()
				local scale = UIParent:GetEffectiveScale()
				x = x / scale

				local newValue = GetValueFromPosition(x)
				if newValue ~= currentValue then
					currentValue = newValue
					valueText:SetText(tostring(newValue))
					UpdateThumbPosition(newValue)
				end

				-- PERF: Coalesce config writes while dragging to minimize database and hook overhead.
				if currentValue ~= committedValue and sinceLastCommit >= 0.12 then
					SetExtraConfigValue(configPath, currentValue, cleanText)
					local oldValue = committedValue
					committedValue = currentValue
					sinceLastCommit = 0

					-- Call hook function if provided
					if hookFunction and type(hookFunction) == "function" then
						hookFunction(currentValue, oldValue, configPath)
					end
				end
			end)
		end
	end)

	thumbFrame:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" and isDragging then
			isDragging = false
			self:SetScript("OnUpdate", nil)

			if currentValue ~= committedValue then
				SetExtraConfigValue(configPath, currentValue, cleanText)
				local oldValue = committedValue
				committedValue = currentValue

				if hookFunction and type(hookFunction) == "function" then
					hookFunction(currentValue, oldValue, configPath)
				end
			end

			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end
	end)

	-- Mouse wheel support for fine adjustment
	sliderContainer:EnableMouseWheel(true)
	sliderContainer:SetScript("OnMouseWheel", function(self, delta)
		local newValue = currentValue + (step * delta)
		newValue = max(minVal, min(maxVal, newValue))

		if newValue ~= currentValue then
			local oldValue = currentValue
			currentValue = newValue
			committedValue = newValue
			valueText:SetText(tostring(newValue))
			UpdateThumbPosition(newValue)
			SetExtraConfigValue(configPath, newValue, cleanText)

			-- Call hook function if provided
			if hookFunction and type(hookFunction) == "function" then
				hookFunction(newValue, oldValue, configPath)
			end

			-- Play feedback sound
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end
	end)

	-- Tooltip support with mousewheel hint
	if tooltip and K and K.GUIHelpers and K.GUIHelpers.CreateEnhancedTooltip then
		K.GUIHelpers.CreateEnhancedTooltip(widget, cleanText, tooltip .. "\n\nTip: Use mouse wheel for fine adjustment!")
	end

	-- Initialize
	widget:UpdateValue()
	return widget
end

-- ---------------------------------------------------------------------------
-- WIDGET CREATION: DROPDOWN
-- ---------------------------------------------------------------------------

-- REASON: Selection-based setting widget; utilizes a shared overlay menu system.
function ExtraGUI:CreateDropdown(parent, configPath, text, options, tooltip, hookFunction, isNew)
	local widget = CreateFrame("Frame", nil, parent)
	widget:SetSize(GetExtraContentWidth(), 28)
	widget.ConfigPath = configPath

	-- Background
	CreateColoredBackground(widget, 0.12, 0.12, 0.12, 0.8)

	-- Process NEW tag from text
	local cleanText, hasNewTag = ProcessNewTag(text)
	local showNewTag = isNew or hasNewTag

	-- Label
	local label = widget:CreateFontString(nil, "OVERLAY")
	label:SetFontObject(K.UIFont)
	label:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	label:SetText(cleanText)
	label:SetPoint("LEFT", 8, 0)

	-- Make label clickable for reset functionality
	if configPath then
		local labelButton = CreateFrame("Button", nil, widget)
		labelButton:SetAllPoints(label)
		labelButton:SetScript("OnClick", function(self, button)
			if button == "LeftButton" and IsControlKeyDown() then
				ResetToDefault(configPath, widget, cleanText)
			end
		end)

		-- Add reset-to-default functionality with undo icon
		AddResetToDefaultFunctionality(widget, label, configPath, cleanText)
	end

	-- Add NEW tag if specified
	if showNewTag then
		AddNewTag(widget, label)
	end

	-- Register hook function with main GUI's hook system
	if hookFunction and type(hookFunction) == "function" and configPath then
		if K.NewGUI and K.NewGUI.RegisterHook then
			K.NewGUI:RegisterHook(configPath, hookFunction)
		end
	end

	-- Dropdown Button
	local dropdown = CreateFrame("Button", nil, widget)
	dropdown:SetSize(140, 18) -- Slightly wider; still compact for ExtraGUI
	dropdown:SetPoint("RIGHT", -8, 0)

	local dropdownBg = dropdown:CreateTexture(nil, "BACKGROUND")
	dropdownBg:SetAllPoints()
	dropdownBg:SetTexture(C["Media"].Textures.White8x8Texture)
	dropdownBg:SetVertexColor(0.15, 0.15, 0.15, 1)

	-- Dropdown Text
	local dropdownText = dropdown:CreateFontString(nil, "OVERLAY")
	dropdownText:SetFontObject(K.UIFont)
	dropdownText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	dropdownText:SetPoint("LEFT", 8, 0)
	dropdownText:SetJustifyH("LEFT")

	-- Arrow Icon with safe fallback
	local arrowTex = dropdown:CreateTexture(nil, "OVERLAY")
	arrowTex:SetSize(18, 12)
	arrowTex:SetPoint("RIGHT", -6, 0)
	local arrowText

	local function UseArrowText(char)
		if not arrowText then
			arrowText = dropdown:CreateFontString(nil, "OVERLAY")
			arrowText:SetFontObject(K.UIFont)
			arrowText:SetPoint("RIGHT", -6, 0)
		end
		arrowTex:Hide()
		arrowText:Show()
		arrowText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		arrowText:SetText(char)
	end

	local function UseArrowTexture(atlas)
		arrowTex:Show()
		if arrowText then
			arrowText:Hide()
		end
		arrowTex:SetAtlas(atlas, true)
		arrowTex:SetSize(18, 12)
	end

	local function SetArrowDown()
		local ok = pcall(function()
			UseArrowTexture("minimal-scrollbar-small-arrow-bottom")
		end)
		if not ok then
			UseArrowText("▼")
		end
	end
	local function SetArrowUp()
		local ok = pcall(function()
			UseArrowTexture("minimal-scrollbar-small-arrow-top")
		end)
		if not ok then
			UseArrowText("▲")
		end
	end

	SetArrowDown()

	-- Tooltip
	if tooltip and K and K.GUIHelpers and K.GUIHelpers.CreateEnhancedTooltip then
		K.GUIHelpers.CreateEnhancedTooltip(widget, cleanText, tooltip)
	end

	-- Menu state: open overlay menu via shared helper
	local function OpenMenu()
		K.GUIHelpers.OpenDropdownMenu(dropdown, {
			options = options,
			getValue = function()
				return configPath and GetExtraConfigValue(configPath) or nil
			end,
			onSelect = function(option)
				if configPath then
					local prev = GetExtraConfigValue(configPath)
					SetExtraConfigValue(configPath, option.value, cleanText)
					widget:UpdateValue()
					if hookFunction and type(hookFunction) == "function" then
						hookFunction(option.value, prev, configPath)
					end
				else
					-- No config path means this is a transient dropdown (e.g., category switchers)
					-- Still update the visible text and invoke the hook so callers can react.
					dropdownText:SetText(option.text)
					if hookFunction and type(hookFunction) == "function" then
						hookFunction(option.value, nil, configPath)
					end
				end
				SetArrowDown()
			end,
			menuWidth = 180,
			visibleCount = 10,
			showSearchOver = 10,
		})
		SetArrowUp()
	end

	-- Hover effect for dropdown button
	dropdown:SetScript("OnEnter", function(self)
		dropdownBg:SetVertexColor(0.2, 0.2, 0.2, 1)
		if arrowTex and arrowTex.SetVertexColor then
			arrowTex:SetVertexColor(1, 1, 1, 1)
		elseif arrowText and arrowText.SetTextColor then
			arrowText:SetTextColor(1, 1, 1, 1)
		end
	end)

	dropdown:SetScript("OnLeave", function(self)
		dropdownBg:SetVertexColor(0.15, 0.15, 0.15, 1)
		if arrowTex and arrowTex.SetVertexColor then
			arrowTex:SetVertexColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		elseif arrowText and arrowText.SetTextColor then
			arrowText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		end
	end)

	-- Click handler for dropdown button
	dropdown:SetScript("OnClick", function()
		OpenMenu()
	end)

	-- Update function
	function widget:UpdateValue()
		if not self.ConfigPath then
			if options[1] then
				dropdownText:SetText(options[1].text)
			end
			return
		end

		local value = GetExtraConfigValue(self.ConfigPath)
		local matched = false
		for _, option in ipairs(options) do
			if option.value == value then
				dropdownText:SetText(option.text)
				matched = true
				break
			end
		end
		if not matched then
			dropdownText:SetText(options[1] and options[1].text or "Select...")
		end
	end

	-- Close menu function for external use
	function widget:CloseMenu()
		-- Use shared helper state if present
		if K.GUIHelpers and K.GUIHelpers._menu then
			K.GUIHelpers._menu:Hide()
		end
	end

	-- Expose properties for external access
	widget.dropdownText = dropdownText
	widget.dropdown = dropdown

	-- Initialize
	widget:UpdateValue()

	return widget
end

-- ---------------------------------------------------------------------------
-- SHARED LIST-EDITOR INFRASTRUCTURE
--
-- REASON: Five ExtraGUI panels (Mute SoundIDs, Custom Units, Power Units,
-- Nameplate aura filters, Auto-Quest ignore NPCs) all reimplemented the same
-- "searchable, scrollable list of numeric IDs with add/remove" widget by hand.
-- That copy-paste was ~1500 lines and bred drift + latent bugs (e.g. the Mute
-- editor read its input via a non-existent :GetText(), Power Units crashed on
-- PLAYER_TARGET_CHANGED). This single factory + a few store adapters own the
-- behavior now; each panel is a small declarative spec.
-- ---------------------------------------------------------------------------

-- Resolve an NPC's name by ID, learning names from nearby units (async via K.GetNPCName).
local function GetNPCNameByID(npcID, callback)
	if not npcID then
		return "Unknown"
	end

	if K.GetNPCName then
		local name = K.GetNPCName(npcID, callback)
		if name and name ~= "" and name ~= "..." then
			return name
		end
	end

	K.NPCNameCache = K.NPCNameCache or {}
	if K.NPCNameCache[npcID] then
		return K.NPCNameCache[npcID]
	end

	return "Unknown"
end

-- Set a creature portrait onto a texture, falling back to a question mark until a
-- matching unit (target/mouseover/focus/nameplate/boss) is visible to read from.
local function TrySetNPCPortrait(texture, npcID)
	texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
	texture:SetVertexColor(1, 1, 1, 1)
	texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	local function checkUnit(u)
		if UnitExists(u) then
			local guid = UnitGUID(u)
			local id = guid and K.GetNPCID(guid)
			if id and id == npcID then
				SetPortraitTexture(texture, u)
				texture:SetTexCoord(0.15, 0.85, 0.15, 0.85)
				return true
			end
		end
	end

	local directUnits = { "target", "mouseover", "focus" }
	for _, u in ipairs(directUnits) do
		if checkUnit(u) then
			return
		end
	end
	for i = 1, 40 do
		if checkUnit("nameplate" .. i) then
			return
		end
	end
	for i = 1, 8 do
		if checkUnit("boss" .. i) then
			return
		end
	end
end

-- Store adapter: numeric IDs persisted as a space-joined string config value,
-- merged with an optional read-only defaults table (defaults are non-removable).
-- Covers Mute Sound IDs (no defaults), Custom Units, and Power Units.
function ExtraGUI.MakeStringSetStore(opts)
	local store = {}

	local function parse()
		local current = tostring(K.GetValueByPath(C, opts.configPath) or "")
		local numeric, nonNumeric = {}, {}
		for w in string.gmatch(current, "%S+") do
			local id = tonumber(w)
			if id then
				numeric[id] = true
			else
				nonNumeric[#nonNumeric + 1] = w
			end
		end
		return numeric, nonNumeric
	end

	local function save(numeric, nonNumeric)
		local ids = {}
		for id in pairs(numeric) do
			ids[#ids + 1] = id
		end
		table.sort(ids)

		local parts = {}
		for _, t in ipairs(nonNumeric or {}) do
			parts[#parts + 1] = tostring(t)
		end
		for _, id in ipairs(ids) do
			parts[#parts + 1] = tostring(id)
		end

		SetExtraConfigValue(opts.configPath, table.concat(parts, " "), opts.settingName)
		if opts.applyFn then
			opts.applyFn()
		end
	end

	function store:GetEntries()
		local numeric = parse()
		local combined = {}
		if opts.defaultsTable then
			for id in pairs(opts.defaultsTable) do
				combined[id] = false -- default = present but not removable
			end
		end
		for id in pairs(numeric) do
			if combined[id] == nil then
				combined[id] = true
			end
		end

		local list = {}
		for id, removable in pairs(combined) do
			list[#list + 1] = { id = id, removable = removable }
		end
		table.sort(list, function(a, b)
			return a.id < b.id
		end)
		return list
	end

	function store:Add(id)
		local numeric, nonNumeric = parse()
		numeric[id] = true
		save(numeric, nonNumeric)
	end

	function store:Remove(id)
		local numeric, nonNumeric = parse()
		numeric[id] = nil
		save(numeric, nonNumeric)
	end

	function store:Clear()
		save({}, {})
	end

	return store
end

-- Store adapter: per-character flat additions in KkthnxUIDB.Variables, merged with
-- an optional read-only defaults table. Covers Auto-Quest ignore NPCs.
function ExtraGUI.MakeCharFlatStore(opts)
	local store = {}

	local function raw()
		KkthnxUIDB.Variables[K.Realm] = KkthnxUIDB.Variables[K.Realm] or {}
		KkthnxUIDB.Variables[K.Realm][K.Name] = KkthnxUIDB.Variables[K.Realm][K.Name] or {}
		local charData = KkthnxUIDB.Variables[K.Realm][K.Name]
		charData[opts.varKey] = charData[opts.varKey] or {}
		return charData[opts.varKey]
	end

	local function key(id)
		return opts.stringKeys and tostring(id) or id
	end

	function store:GetEntries()
		local user = raw()
		local combined = {}
		if opts.defaultsTable then
			for id in pairs(opts.defaultsTable) do
				combined[tonumber(id) or id] = false
			end
		end
		for id, v in pairs(user) do
			if v then
				local nid = tonumber(id) or id
				if combined[nid] == nil then
					combined[nid] = true
				end
			end
		end

		local list = {}
		for id, removable in pairs(combined) do
			list[#list + 1] = { id = id, removable = removable }
		end
		table.sort(list, function(a, b)
			return (tonumber(a.id) or 0) < (tonumber(b.id) or 0)
		end)
		return list
	end

	function store:Add(id)
		raw()[key(id)] = true
		if opts.applyFn then
			opts.applyFn()
		end
	end

	function store:Remove(id)
		raw()[key(id)] = nil
		if opts.applyFn then
			opts.applyFn()
		end
	end

	return store
end

-- Store adapter: per-character add/removed deltas layered over the live nameplate
-- aura data tables (C[category]), keyed by the 6 aura categories. The deltas are
-- re-applied at login by Unitframes:ApplyNameplateAuraOverrides(). Covers the
-- Nameplate aura filter editor (category-aware).
function ExtraGUI.MakeAuraDeltaStore()
	local store = {}

	local function filterStore()
		KkthnxUIDB.Variables[K.Realm] = KkthnxUIDB.Variables[K.Realm] or {}
		KkthnxUIDB.Variables[K.Realm][K.Name] = KkthnxUIDB.Variables[K.Realm][K.Name] or {}
		local charData = KkthnxUIDB.Variables[K.Realm][K.Name]
		charData.NameplateAuraFilters = charData.NameplateAuraFilters or {}
		return charData.NameplateAuraFilters
	end

	local function catDelta(category)
		local s = filterStore()
		local cs = s[category]
		if type(cs) ~= "table" then
			cs = {}
			s[category] = cs
		end
		cs.added = cs.added or {}
		cs.removed = cs.removed or {}
		return cs
	end

	function store:GetEntries(category)
		local base = category and C[category]
		local list = {}
		if base then
			for id in pairs(base) do
				list[#list + 1] = { id = id, removable = true }
			end
		end
		table.sort(list, function(a, b)
			return a.id < b.id
		end)
		return list
	end

	function store:Add(id, category)
		if not category then
			return
		end
		if not C[category] then
			C[category] = {}
		end
		C[category][id] = true
		local cs = catDelta(category)
		cs.added[id] = true
		cs.removed[id] = nil
	end

	function store:Remove(id, category)
		if not category then
			return
		end
		if C[category] then
			C[category][id] = nil
		end
		local cs = catDelta(category)
		cs.removed[id] = true
		cs.added[id] = nil
	end

	return store
end

-- The single list-editor engine. `spec` drives every variation; see the call sites
-- in RegisterBuiltinConfigs for concrete examples.
--   spec.title / description / descAfterGap (padding below measured description height)
--   spec.categories            -> array {text,value}; renders the category header + dropdown
--   spec.search                -> bool; renders a search box (filters spell rows by id/name)
--   spec.addStyle              -> "stacked" (input then button) | "container" (input + button inline)
--   spec.inputLabel/inputPlaceholder/inputTooltip/addLabel
--   spec.showClear             -> bool; adds a Clear button beside Add
--   spec.invalidMessage        -> printed when validation fails (nil => play the reject sound instead)
--   spec.validate(text)        -> id|nil (default: positive integer)
--   spec.listHeaderText        -> optional section header above the list
--   spec.listHeight            -> list frame height (default 300)
--   spec.rowKind               -> "text" | "npc" | "spell"
--   spec.npcPortraitStyle      -> "framed" | "plain"
--   spec.liveNPC               -> bool; refresh NPC portraits/names on unit events
--   spec.defaultTag            -> suffix for non-removable rows (default "  [Default]")
--   spec.footerText/footerGapBefore/footerGapAfter
--   spec.parentHeight(listTopY, listHeight) -> number (used when there is no footer)
--   spec.store                 -> store adapter (required)
function ExtraGUI:CreateListEditor(parent, spec)
	local yOffset = -10
	local contentWidth = GetExtraContentWidth()
	local store = spec.store
	local rowKind = spec.rowKind or "text"
	local validate = spec.validate or function(text)
		local id = tonumber(text)
		if id and id > 0 then
			return id
		end
	end
	local currentCategory = spec.categories and spec.categories[1] and spec.categories[1].value or nil

	local rows = {}
	local refresh -- forward declaration (referenced by handlers below)
	local addCurrent -- forward declaration
	local searchEdit

	-- Header (optional; the aura filter panel leads with its category dropdown instead)
	if spec.title then
		local header = parent:CreateFontString(nil, "OVERLAY")
		header:SetFontObject(K.UIFont)
		header:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		header:SetText(spec.title)
		header:SetPoint("TOPLEFT", 10, yOffset)
		yOffset = yOffset - 25
	end

	-- Description
	if spec.description then
		local desc = parent:CreateFontString(nil, "OVERLAY")
		desc:SetFontObject(K.UIFont)
		desc:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		desc:SetJustifyH("LEFT")
		desc:SetWidth(contentWidth - 20)
		desc:SetText(spec.description)
		desc:SetPoint("TOPLEFT", 10, yOffset)
		-- Measure wrapped height so multi-line descriptions never overlap the input below.
		yOffset = yOffset - desc:GetStringHeight() - (spec.descAfterGap or 10)
	end

	-- Category header + dropdown (aura filter)
	if spec.categories then
		local categoryHeader = CreateFrame("Frame", nil, parent)
		categoryHeader:SetSize(contentWidth - 20, 30)
		categoryHeader:SetPoint("TOPLEFT", 10, yOffset)

		local headerBg = categoryHeader:CreateTexture(nil, "BACKGROUND")
		headerBg:SetAllPoints()
		headerBg:SetTexture(C["Media"].Textures.White8x8Texture)
		headerBg:SetVertexColor(0.05, 0.05, 0.05, 0.8)

		local categoryLabel = categoryHeader:CreateFontString(nil, "OVERLAY")
		categoryLabel:SetFontObject(K.UIFont)
		categoryLabel:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		categoryLabel:SetText(L["Aura Category:"] or "Aura Category:")
		categoryLabel:SetPoint("LEFT", categoryHeader, "LEFT", 10, 0)
		yOffset = yOffset - 40

		local dropdown = self:CreateDropdown(parent, nil, (L["Select Category"] or "Select Category"), spec.categories, (L["Choose which aura list to manage"] or "Choose which aura list to manage"), function(newValue)
			currentCategory = newValue
			if refresh then
				refresh()
			end
		end)
		dropdown:SetPoint("TOPLEFT", 0, yOffset)
		dropdown.dropdownText:SetText(spec.categories[1].text)
		yOffset = yOffset - 45
	end

	-- Search box (spell rows)
	if spec.search then
		local searchLabel = parent:CreateFontString(nil, "OVERLAY")
		searchLabel:SetFontObject(K.UIFont)
		searchLabel:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		searchLabel:SetText(spec.searchLabel or (L["Search Auras:"] or "Search Auras:"))
		searchLabel:SetPoint("TOPLEFT", 10, yOffset)
		yOffset = yOffset - 20

		local searchInput = self:CreateTextInput(parent, nil, "", (L["Enter Spell ID"] or "Enter Spell ID"), (L["Filter displayed auras"] or "Filter displayed auras"))
		searchInput:SetPoint("TOPLEFT", 0, yOffset)
		searchEdit = searchInput.editBox
		searchEdit:HookScript("OnTextChanged", function()
			if refresh then
				refresh()
			end
		end)
		yOffset = yOffset - 35
	end

	-- Add section
	local addEdit
	if spec.addStyle == "container" then
		local addLabel = parent:CreateFontString(nil, "OVERLAY")
		addLabel:SetFontObject(K.UIFont)
		addLabel:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		addLabel:SetText(spec.inputLabel or (L["Add New Spell ID:"] or "Add New Spell ID:"))
		addLabel:SetPoint("TOPLEFT", 10, yOffset)
		yOffset = yOffset - 20

		local addContainer = CreateFrame("Frame", nil, parent)
		addContainer:SetSize(contentWidth, 28)
		addContainer:SetPoint("TOPLEFT", 0, yOffset)

		local input = self:CreateTextInput(addContainer, nil, "", spec.inputPlaceholder or (L["Enter Spell ID"] or "Enter Spell ID"), spec.inputTooltip or (L["Add a new spell to the current category"] or "Add a new spell to the current category"), nil, false, contentWidth - 110)
		input:SetPoint("TOPLEFT", 0, 0)
		addEdit = input.editBox

		local addButton = self:CreateButton(addContainer, spec.addLabel or (L["Add Spell"] or "Add Spell"), 100, 28, function() end)
		addButton:SetPoint("LEFT", input, "RIGHT", 10, 0)
		addButton:SetScript("OnClick", function()
			addCurrent()
		end)
		yOffset = yOffset - 35
	else
		local input = self:CreateTextInput(parent, nil, spec.inputLabel, spec.inputPlaceholder, spec.inputTooltip)
		input:SetPoint("TOPLEFT", 0, yOffset)
		addEdit = input.editBox
		yOffset = yOffset - 35

		local addButton = self:CreateButton(parent, spec.addLabel or (L["Add"] or "Add"), 90, 24, function() end)
		addButton:SetPoint("TOPLEFT", 0, yOffset)
		addButton:SetScript("OnClick", function()
			addCurrent()
		end)

		if spec.showClear then
			local clearButton = self:CreateButton(parent, L["Clear"] or "Clear", 90, 24, function() end)
			clearButton:SetPoint("LEFT", addButton, "RIGHT", 10, 0)
			clearButton:SetScript("OnClick", function()
				if store.Clear then
					store:Clear(currentCategory)
				end
				refresh()
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			end)
		end
		yOffset = yOffset - 35
	end

	-- Optional list section header (boxed, used by the NPC ID lists)
	if spec.listHeaderText then
		CreateSectionHeader(parent, spec.listHeaderText, contentWidth, yOffset)
		yOffset = yOffset - 40
	end

	-- Optional plain accent label above the list (used by the aura filter panel)
	if spec.listLabel then
		local listLabel = parent:CreateFontString(nil, "OVERLAY")
		listLabel:SetFontObject(K.UIFont)
		listLabel:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		listLabel:SetText(spec.listLabel)
		listLabel:SetPoint("TOPLEFT", 10, yOffset)
		yOffset = yOffset - 25
	end

	local listTopY = yOffset
	local listHeight = spec.listHeight or 300

	-- List frame + internal scroll
	local listFrame = CreateFrame("Frame", nil, parent)
	listFrame:SetPoint("TOPLEFT", 10, yOffset)
	listFrame:SetSize(contentWidth - 20, listHeight)
	local listBg = listFrame:CreateTexture(nil, "BACKGROUND")
	listBg:SetAllPoints()
	listBg:SetTexture(C["Media"].Textures.White8x8Texture)
	listBg:SetVertexColor(0.05, 0.05, 0.05, 0.8)

	local scrollFrame = CreateFrame("ScrollFrame", nil, listFrame)
	scrollFrame:SetPoint("TOPLEFT", 5, -5)
	scrollFrame:SetPoint("BOTTOMRIGHT", -5, 5)
	scrollFrame:EnableMouseWheel(true)

	local scrollChild = CreateFrame("Frame", nil, scrollFrame)
	scrollChild:SetWidth(contentWidth - 30)
	scrollChild:SetHeight(1)
	scrollFrame:SetScrollChild(scrollChild)

	if K and K.GUIHelpers and K.GUIHelpers.AttachSimpleScroll then
		K.GUIHelpers.AttachSimpleScroll(scrollFrame, 30)
	end

	-- Row builder: plain ID or NPC portrait+name
	local function buildIdRow(entry, y)
		local removable = entry.removable
		local row = CreateFrame("Frame", nil, scrollChild)

		if rowKind == "text" then
			row:SetPoint("TOPLEFT", 0, y)
			row:SetPoint("TOPRIGHT", 0, y)
			row:SetHeight(24)

			local text = row:CreateFontString(nil, "OVERLAY")
			text:SetFontObject(K.UIFont)
			text:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
			text:SetPoint("LEFT", 6, 0)
			text:SetText(tostring(entry.id))

			if removable then
				local removeBtn = self:CreateButton(row, L["Remove"] or "Remove", 80, 20, function() end)
				removeBtn:SetPoint("RIGHT", -6, 0)
				removeBtn:SetScript("OnClick", function()
					store:Remove(entry.id, currentCategory)
					refresh()
					PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
				end)
			end
			return row
		end

		-- NPC row
		row:SetSize(contentWidth - 40, 28)
		row:SetPoint("TOPLEFT", 10, y)

		local bg = row:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints()
		bg:SetTexture(C["Media"].Textures.White8x8Texture)
		bg:SetVertexColor(0.08, 0.08, 0.08, 0.7)

		local portrait, nameAnchor
		if spec.npcPortraitStyle == "framed" then
			local portraitFrame = CreateFrame("Frame", nil, row)
			portraitFrame:SetSize(24, 24)
			portraitFrame:SetPoint("LEFT", 6, 0)
			CreateColoredBackground(portraitFrame, 0.12, 0.12, 0.12, 1)
			local portraitBorder = portraitFrame:CreateTexture(nil, "BORDER")
			portraitBorder:SetPoint("TOPLEFT", -1, 1)
			portraitBorder:SetPoint("BOTTOMRIGHT", 1, -1)
			portraitBorder:SetTexture(C["Media"].Textures.White8x8Texture)
			portraitBorder:SetVertexColor(0.3, 0.3, 0.3, 0.8)
			portrait = portraitFrame:CreateTexture(nil, "ARTWORK")
			portrait:SetPoint("TOPLEFT", 2, -2)
			portrait:SetPoint("BOTTOMRIGHT", -2, 2)
			nameAnchor = portraitFrame
		else
			portrait = row:CreateTexture(nil, "ARTWORK")
			portrait:SetSize(22, 22)
			portrait:SetPoint("LEFT", 6, 0)
			nameAnchor = portrait
		end
		TrySetNPCPortrait(portrait, entry.id)
		row.Portrait = portrait
		row.NpcID = entry.id

		local nameFS = row:CreateFontString(nil, "OVERLAY")
		nameFS:SetFontObject(K.UIFont)
		nameFS:SetTextColor(1, 1, 1, 1)
		nameFS:SetPoint("LEFT", nameAnchor, "RIGHT", 8, 0)
		row.NameFS = nameFS

		local tag = (not removable) and (spec.defaultTag or "  [Default]") or ""
		local function setName(nm)
			nameFS:SetText(string.format("%s (ID: %s)%s", nm or "Unknown", tostring(entry.id), tag))
		end
		row._setName = setName
		setName(GetNPCNameByID(entry.id, setName))

		if removable then
			local removeBtn = self:CreateButton(row, "", 22, 22, function() end)
			removeBtn:SetPoint("RIGHT", -8, 0)
			local icon = removeBtn:CreateTexture(nil, "ARTWORK")
			icon:SetAllPoints()
			local ok = pcall(function()
				icon:SetAtlas("common-icon-redx", true)
			end)
			if not ok then
				icon:SetTexture(C["Media"].Textures.White8x8Texture)
				icon:SetVertexColor(0.8, 0.2, 0.2, 1)
			end
			removeBtn:SetScript("OnClick", function()
				store:Remove(entry.id, currentCategory)
				refresh()
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			end)
		end
		return row
	end

	-- Row builder: spell icon + id + name (aura filter)
	local function buildSpellRow(entry, index)
		local spellId = entry.id
		local item = CreateFrame("Frame", nil, scrollChild)
		item:SetSize(contentWidth - 40, 27)
		item:SetPoint("TOPLEFT", 0, -(index - 1) * 29)

		local itemBg = item:CreateTexture(nil, "BACKGROUND")
		itemBg:SetAllPoints()
		itemBg:SetTexture(C["Media"].Textures.White8x8Texture)
		if index % 2 == 0 then
			itemBg:SetVertexColor(0.1, 0.1, 0.1, 0.5)
		else
			itemBg:SetVertexColor(0.05, 0.05, 0.05, 0.5)
		end

		local iconContainer = CreateFrame("Frame", nil, item)
		iconContainer:SetSize(20, 20)
		iconContainer:SetPoint("LEFT", 6, 0)
		local iconBorder = iconContainer:CreateTexture(nil, "BACKGROUND")
		iconBorder:SetAllPoints()
		iconBorder:SetTexture(C["Media"].Textures.White8x8Texture)
		iconBorder:SetVertexColor(0.2, 0.2, 0.2, 0.8)
		local icon = iconContainer:CreateTexture(nil, "ARTWORK")
		icon:SetSize(18, 18)
		icon:SetPoint("CENTER", 0, 0)
		local spellTexture = C_Spell.GetSpellTexture(spellId)
		if spellTexture then
			icon:SetTexture(spellTexture)
		else
			icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
		end
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

		local idText = item:CreateFontString(nil, "OVERLAY")
		idText:SetFontObject(K.UIFont)
		idText:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		idText:SetText(tostring(spellId))
		idText:SetPoint("LEFT", iconContainer, "RIGHT", 10, 0)

		local nameText = item:CreateFontString(nil, "OVERLAY")
		nameText:SetFontObject(K.UIFont)
		nameText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		local spellInfo = C_Spell.GetSpellInfo(spellId)
		nameText:SetText(spellInfo and spellInfo.name or "Unknown Spell")
		nameText:SetPoint("LEFT", idText, "RIGHT", 15, 0)

		local removeButton = CreateFrame("Button", nil, item)
		removeButton:SetSize(18, 18)
		removeButton:SetPoint("RIGHT", -8, 0)
		local removeBg = removeButton:CreateTexture(nil, "BACKGROUND")
		removeBg:SetAllPoints()
		removeBg:SetTexture(C["Media"].Textures.White8x8Texture)
		removeBg:SetVertexColor(0.8, 0.2, 0.2, 0.8)
		local removeText = removeButton:CreateFontString(nil, "OVERLAY")
		removeText:SetFontObject(K.UIFont)
		removeText:SetTextColor(1, 1, 1, 1)
		removeText:SetText("×")
		removeText:SetPoint("CENTER")
		removeButton:SetScript("OnClick", function()
			store:Remove(spellId, currentCategory)
			refresh()
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		end)
		removeButton:SetScript("OnEnter", function(btn)
			removeBg:SetVertexColor(1, 0.2, 0.2, 1)
			GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
			GameTooltip:SetText(L["Remove Aura"] or "Remove Aura", 1, 1, 1, 1, true)
			GameTooltip:AddLine(L["Click to remove this aura from the list"] or "Click to remove this aura from the list", 0.7, 0.7, 0.7, true)
			GameTooltip:Show()
		end)
		removeButton:SetScript("OnLeave", function()
			removeBg:SetVertexColor(0.8, 0.2, 0.2, 0.8)
			GameTooltip:Hide()
		end)

		return item
	end

	refresh = function()
		for _, r in ipairs(rows) do
			r:Hide()
			r:SetParent(nil)
		end
		wipe(rows)

		local entries = store:GetEntries(currentCategory)

		-- Search filter (spell rows)
		if searchEdit then
			local query = (searchEdit:GetText() or ""):lower()
			if query ~= "" then
				local filtered = {}
				for _, e in ipairs(entries) do
					local match = tostring(e.id):find(query, 1, true)
					if not match then
						local info = C_Spell.GetSpellInfo(e.id)
						local nm = info and info.name
						match = nm and nm:lower():find(query, 1, true)
					end
					if match then
						filtered[#filtered + 1] = e
					end
				end
				entries = filtered
			end
		end

		if rowKind == "spell" then
			for i, e in ipairs(entries) do
				rows[#rows + 1] = buildSpellRow(e, i)
			end
			scrollChild:SetHeight(math.max(#entries * 29, 250))
		else
			local y = (rowKind == "text") and -2 or -5
			local step = (rowKind == "text") and 26 or 30
			for _, e in ipairs(entries) do
				rows[#rows + 1] = buildIdRow(e, y)
				y = y - step
			end
			scrollChild:SetHeight(math.abs(y) + 10)
		end
	end

	addCurrent = function()
		local id = validate(addEdit:GetText() or "")
		if not id then
			if spec.invalidMessage then
				print(spec.invalidMessage)
			else
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
			end
			return
		end
		store:Add(id, currentCategory)
		addEdit:SetText("")
		refresh()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end

	-- Live NPC portrait/name refresh
	if spec.liveNPC then
		local events = CreateFrame("Frame", nil, parent)
		events:RegisterEvent("PLAYER_TARGET_CHANGED")
		events:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
		events:RegisterEvent("PLAYER_FOCUS_CHANGED")
		events:RegisterEvent("NAME_PLATE_UNIT_ADDED")
		events:SetScript("OnEvent", function(_, _, unit)
			if unit and UnitExists(unit) then
				local guid = UnitGUID(unit)
				local id = guid and K.GetNPCID(guid)
				if id then
					local n = UnitName(unit)
					if n and n ~= "" then
						K.NPCNameCache = K.NPCNameCache or {}
						K.NPCNameCache[id] = n
					end
				end
			end
			for _, row in ipairs(rows) do
				if row.Portrait and row.NpcID then
					TrySetNPCPortrait(row.Portrait, row.NpcID)
				end
				if row.NameFS and row.NpcID and row._setName then
					row._setName(GetNPCNameByID(row.NpcID, row._setName))
				end
			end
		end)
	end

	refresh()

	-- Footer instructions + panel height
	if spec.footerText then
		yOffset = yOffset - (spec.footerGapBefore or (listHeight + 20))
		local footer = parent:CreateFontString(nil, "OVERLAY")
		footer:SetFontObject(K.UIFont)
		footer:SetTextColor(0.7, 0.7, 0.7, 1)
		footer:SetText(spec.footerText)
		footer:SetPoint("TOPLEFT", 10, yOffset)
		footer:SetWidth(contentWidth - 20)
		footer:SetJustifyH("LEFT")
		yOffset = yOffset - (spec.footerGapAfter or 60)
		parent:SetHeight(math.abs(yOffset) + 20)
	elseif spec.parentHeight then
		parent:SetHeight(spec.parentHeight(listTopY, listHeight))
	else
		parent:SetHeight(math.abs(listTopY) + listHeight + 20)
	end
end

-- ---------------------------------------------------------------------------
-- CONFIGURATION REGISTRATION: BUILT-INS
-- ---------------------------------------------------------------------------

-- NOTE: This function populates the ExtraGUI with standard configurations for core addon features.
function ExtraGUI:RegisterBuiltinConfigs()
	K.ExtraGUIActionBars:Register(self)

	local function CreateSimpleTextEditor(parent, configPath, title, placeholder, description, hookFunction)
		local yOffset = -10
		local contentWidth = GetExtraContentWidth()

		local header = parent:CreateFontString(nil, "OVERLAY")
		header:SetFontObject(K.UIFont)
		header:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		header:SetText(title)
		header:SetPoint("TOPLEFT", 10, yOffset)
		yOffset = yOffset - 25

		local desc = parent:CreateFontString(nil, "OVERLAY")
		desc:SetFontObject(K.UIFont)
		desc:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		desc:SetJustifyH("LEFT")
		desc:SetWidth(contentWidth - 20)
		desc:SetText(description)
		desc:SetPoint("TOPLEFT", 10, yOffset)
		yOffset = yOffset - 45

		local input = self:CreateTextInput(parent, configPath, title, placeholder, description, hookFunction)
		input:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		parent:SetHeight(math.abs(yOffset) + 20)
	end

	-- ---------------------------------------------------------------------------
	-- Configuration Registration: Automation
	-- ---------------------------------------------------------------------------

	self:RegisterExtraConfig("Automation.WhisperInvite", function(parent)
		local function updateInviteKeyword()
			local automationModule = K:GetModule("Automation")
			if automationModule and automationModule.onUpdateInviteKeyword then
				automationModule:onUpdateInviteKeyword()
			end
		end

		CreateSimpleTextEditor(parent, "Automation.WhisperInvite", L["Auto Accept Invite Keyword"], L["WhisperInvite Placeholder"], L["WhisperInvite Desc"], updateInviteKeyword)
	end, L["Auto Accept Invite Keyword"])

	-- ---------------------------------------------------------------------------
	-- Configuration Registration: Inventory
	-- ---------------------------------------------------------------------------

	K.ExtraGUIInventory:Register(self)

	-- ---------------------------------------------------------------------------
	-- Configuration Registration: Miscellaneous (Simple Text Editors)
	-- ---------------------------------------------------------------------------

	self:RegisterExtraConfig("Misc.DBMCount", function(parent)
		CreateSimpleTextEditor(parent, "Misc.DBMCount", L["DBMCount - Add Info"], L["Enter custom info..."], L["Misc.DBMCount Desc"])
	end, L["DBMCount - Add Info"])

	-- ---------------------------------------------------------------------------
	-- Configuration Registration: Miscellaneous (Mute)
	-- ---------------------------------------------------------------------------

	-- NOTE: Allows users to suppress specific game sounds by their SoundKit ID.
	self:RegisterExtraConfig("Misc.MuteSoundIDs", function(parent)
		self:CreateListEditor(parent, {
			title = L["Custom Mute Sound IDs"] or "Custom Mute Sound IDs",
			description = L["MuteSoundIDsDesc"] or "Add SoundKit IDs to mute. KkthnxUI already mutes a built-in set; this list only adds your extra IDs.",
			inputLabel = L["Add Sound ID"] or "Add Sound ID",
			inputTooltip = L["Enter a numeric SoundKit ID to add"] or "Enter a numeric SoundKit ID to add",
			showClear = true,
			rowKind = "text",
			-- Mute accepts any numeric SoundKit id (including 0), matching the legacy behavior.
			validate = function(text)
				return tonumber(text)
			end,
			parentHeight = function(listTopY)
				return math.abs(listTopY) + 230
			end,
			store = ExtraGUI.MakeStringSetStore({
				configPath = "Misc.MuteSoundIDs",
				settingName = "Mute Sound IDs",
				applyFn = function()
					local miscModule = K and K.GetModule and K:GetModule("Miscellaneous")
					if miscModule and miscModule.CreateMuteSounds then
						miscModule:CreateMuteSounds()
					end
				end,
			}),
		})
	end, "Mute Sound IDs")

	-- ---------------------------------------------------------------------------
	-- Configuration Registration: Nameplates
	-- ---------------------------------------------------------------------------

	-- REASON: Enables custom coloring for specific NPCs identified by their internal ID.
	self:RegisterExtraConfig("Nameplate.CustomUnitList", function(parent)
		self:CreateListEditor(parent, {
			title = L["Custom Units by NPC ID"] or "Custom Units by NPC ID",
			description = L["Add NPC IDs to always color as custom. Defaults are shown and cannot be removed here."] or "Add NPC IDs to always color as custom. Defaults are shown and cannot be removed here.",
			inputLabel = L["Add NPC ID"] or "Add NPC ID",
			inputPlaceholder = format(L["e.g. %s"] or "e.g. %s", "174773"),
			inputTooltip = L["Enter an NPC ID to add"] or "Enter an NPC ID to add",
			listHeaderText = L["Current IDs"] or "Current IDs",
			listHeight = 320,
			rowKind = "npc",
			npcPortraitStyle = "framed",
			liveNPC = true,
			invalidMessage = "|cffff0000Invalid NPC ID. Enter a number.|r",
			parentHeight = function(listTopY)
				return math.abs(listTopY) + 20
			end,
			store = ExtraGUI.MakeStringSetStore({
				configPath = "Nameplate.CustomUnitList",
				defaultsTable = C.NameplateCustomUnits,
				applyFn = function()
					local nameplateModule = K:GetModule("Unitframes")
					if nameplateModule and nameplateModule.CreateUnitTable then
						nameplateModule:CreateUnitTable()
					end
				end,
			}),
		})
	end, "Custom Units")

	-- ---------------------------------------------------------------------------
	-- Configuration Registration: Nameplate Power
	-- ---------------------------------------------------------------------------

	-- REASON: Allows specific NPC IDs to display a power bar on their nameplate.
	self:RegisterExtraConfig("Nameplate.PowerUnitList", function(parent)
		self:CreateListEditor(parent, {
			title = L["Show Power for NPC IDs"] or "Show Power for NPC IDs",
			description = L["Add NPC IDs whose power bar should be shown on nameplates. Defaults are shown and cannot be removed here."] or "Add NPC IDs whose power bar should be shown on nameplates. Defaults are shown and cannot be removed here.",
			inputLabel = L["Add NPC ID"] or "Add NPC ID",
			inputPlaceholder = format(L["e.g. %s"] or "e.g. %s", "114247"),
			inputTooltip = L["Enter an NPC ID to add"] or "Enter an NPC ID to add",
			listHeaderText = L["Current IDs"] or "Current IDs",
			listHeight = 320,
			rowKind = "npc",
			npcPortraitStyle = "plain",
			liveNPC = true,
			invalidMessage = "|cffff0000Invalid NPC ID. Enter a number.|r",
			parentHeight = function(listTopY)
				return math.abs(listTopY) + 20
			end,
			store = ExtraGUI.MakeStringSetStore({
				configPath = "Nameplate.PowerUnitList",
				defaultsTable = C.NameplateShowPowerList,
				applyFn = function()
					local nameplateModule = K:GetModule("Unitframes")
					if nameplateModule and nameplateModule.CreatePowerUnitTable then
						nameplateModule:CreatePowerUnitTable()
					end
				end,
			}),
		})
	end, "Power Units")

	-- ---------------------------------------------------------------------------
	-- Configuration Registration: Nameplate Auras
	-- ---------------------------------------------------------------------------

	-- NOTE: High-performance aura management using whitelists, blacklists, and category-based filtering.
	-- REASON: This editor manages the aura *filter* lists, so it hangs off the "Auras Filter Style"
	-- dropdown (Nameplate.AuraFilter), not the simple "Target Nameplate Auras" on/off toggle.
	self:RegisterExtraConfig("Nameplate.AuraFilter", function(parent)
		self:CreateListEditor(parent, {
			categories = {
				{ text = "Whitelist (Show These)", value = "NameplateWhiteList" },
				{ text = "Blacklist (Hide These)", value = "NameplateBlackList" },
				{ text = "Custom Units", value = "NameplateCustomUnits" },
				{ text = "Target NPCs", value = "NameplateTargetNPCs" },
				{ text = "Trash Units", value = "NameplateTrashUnits" },
				{ text = "Major Spells", value = "MajorSpells" },
			},
			search = true,
			addStyle = "container",
			inputLabel = L["Add New Spell ID:"] or "Add New Spell ID:",
			addLabel = L["Add Spell"] or "Add Spell",
			listLabel = L["Current Auras:"] or "Current Auras:",
			listHeight = 300,
			rowKind = "spell",
			invalidMessage = "|cffff0000" .. (L["Invalid Spell ID. Please enter a valid number."] or "Invalid Spell ID. Please enter a valid number.") .. "|r",
			footerText = "• Use /dump spellID to get spell IDs in-game\n• Whitelist: Auras that will always show\n• Blacklist: Auras that will always hide\n• Changes take effect immediately",
			footerGapBefore = 320,
			store = ExtraGUI.MakeAuraDeltaStore(),
		})
	end, "Nameplate Auras")

	-- ---------------------------------------------------------------------------
	-- Configuration Registration: Unit Frame Options
	-- ---------------------------------------------------------------------------

	self:RegisterExtraConfig("Unitframe.ShowPlayerLevel", function(parent)
		local yOffset = -10

		-- Hide at Max Level Switch
		local hideMaxLevelSwitch = self:CreateSwitch(parent, "Unitframe.HideMaxPlayerLevel", L["Hide Player Level At Max Level"], L["Automatically hide the player level text when you reach maximum level (80)"])
		hideMaxLevelSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Set parent height based on content
		parent:SetHeight(math.abs(yOffset) + 20)
	end, "Player Level Options")

	-- REASON: Configuration for raid-style party frames; includes layout and power bar logic.
	self:RegisterExtraConfig("Party.Enable", function(parent)
		local yOffset = -10

		-- Hook function for size updates
		local function UpdateUnitSimplePartySize()
			local unitframeModule = K:GetModule("Unitframes")
			if unitframeModule and unitframeModule.UpdateSimplePartySize then
				unitframeModule:UpdateSimplePartySize()
			end
		end

		-- Enable Simple Party (main toggle)
		local enableSimpleSwitch = self:CreateSwitch(parent, "SimpleParty.Enable", L["Enable Simple Party (Raid-Style)"] or "Enable Simple Party (Raid-Style)", L["Use compact raid-style party frames instead of traditional party frames (requires reload)"] or "Use compact raid-style party frames instead of traditional party frames (requires reload)")
		enableSimpleSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Show Heal Prediction
		local healPredictionSwitch = self:CreateSwitch(parent, "SimpleParty.ShowHealPrediction", L["Show HealPrediction Statusbars"], L["Show incoming heal predictions on party frames"] or "Show incoming heal predictions on party frames")
		healPredictionSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Smooth Bar Transition
		local smoothSwitch = self:CreateSwitch(parent, "SimpleParty.Smooth", L["Smooth Bar Transition"], L["Enable smooth animations for party frame bars"] or "Enable smooth animations for party frame bars")
		smoothSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Target Highlight
		local targetHighlightSwitch = self:CreateSwitch(parent, "SimpleParty.TargetHighlight", L["Show Highlighted Target"], L["Highlight the targeted party member"] or "Highlight the targeted party member")
		targetHighlightSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Horizontal Layout
		local horizonSwitch = self:CreateSwitch(parent, "SimpleParty.HorizonParty", L["Horizontal Party Frames"] or "Horizontal Party Frames", L["Arrange party frames horizontally instead of vertically (requires reload)"] or "Arrange party frames horizontally instead of vertically (requires reload)")
		horizonSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Power Bar Options
		local function UpdatePowerBarVisibility()
			local oUF = K.oUF
			if not oUF then
				return
			end

			-- Force update power bar visibility for all party frames
			for _, object in next, oUF.objects do
				if object.unit and object.unit:match("^party%d") and object.UpdateSimplePartyPower then
					-- Call the stored update function directly
					object:UpdateSimplePartyPower(nil, object.unit)
				end
			end
		end

		local powerBarSwitch = self:CreateSwitch(parent, "SimpleParty.PowerBarShow", L["Enable Power Bars"] or "Enable Power Bars", L["Show power bars on all party frames"] or "Show power bars on all party frames", UpdatePowerBarVisibility)
		powerBarSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local manaBarSwitch = self:CreateSwitch(parent, "SimpleParty.ManabarShow", L["Only Show Mana"], L["Display mana bars on party frames"] or "Display mana bars on party frames", UpdatePowerBarVisibility)
		manaBarSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35
		self:DependsOn(manaBarSwitch, "SimpleParty.PowerBarShow", true)

		yOffset = yOffset - 20 -- Extra spacing before section

		-- Size Section Header
		CreateSectionHeader(parent, L["Sizes"] or "Sizes", EXTRA_PANEL_WIDTH - 40, yOffset)
		yOffset = yOffset - 40

		-- Health Height Slider
		local heightSlider = self:CreateSlider(parent, "SimpleParty.HealthHeight", L["Frame Height"] or "Frame Height", 20, 100, 1, L["Height of simple party member frames (requires reload)"] or "Height of simple party member frames (requires reload)", UpdateUnitSimplePartySize)
		heightSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Health Width Slider
		local widthSlider = self:CreateSlider(parent, "SimpleParty.HealthWidth", L["Frame Width"] or "Frame Width", 20, 100, 1, L["Width of simple party member frames (requires reload)"] or "Width of simple party member frames (requires reload)", UpdateUnitSimplePartySize)
		widthSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Power Bar Height Slider (live update)
		local function UpdatePowerBarHeight()
			local oUF = K.oUF
			if not oUF then
				return
			end

			local newHeight = C["SimpleParty"].PowerBarHeight

			for _, object in next, oUF.objects do
				if object.Power and object.unit and object.unit:match("^party%d") then
					-- Update power bar height
					object.Power:SetHeight(newHeight)

					-- Trigger the update function to reposition health bar correctly
					if object.UpdateSimplePartyPower then
						object:UpdateSimplePartyPower(nil, object.unit)
					end
				end
			end
		end

		local powerHeightSlider = self:CreateSlider(parent, "SimpleParty.PowerBarHeight", L["Power Bar Height"] or "Power Bar Height", 2, 15, 1, L["Height of power bars on simple party frames"] or "Height of power bars on simple party frames", UpdatePowerBarHeight)
		powerHeightSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		yOffset = yOffset - 20 -- Extra spacing before section

		-- Colors Section Header
		CreateSectionHeader(parent, COLORS or "Colors", EXTRA_PANEL_WIDTH - 40, yOffset)
		yOffset = yOffset - 40

		-- Health Color Format Dropdown
		local healthColorOptions = {
			{ text = "Class", value = 1 },
			{ text = "Dark", value = 2 },
			{ text = "Value", value = 3 },
		}
		local colorDropdown = self:CreateDropdown(parent, "SimpleParty.HealthbarColor", L["Health Color Format"] or "Health Color Format", healthColorOptions, L["Choose how health bars are colored on simple party frames"] or "Choose how health bars are colored on simple party frames")
		colorDropdown:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		yOffset = yOffset - 20 -- Extra spacing before section

		-- Buffs Section Header
		CreateSectionHeader(parent, L["Raid Buffs"] or "Raid Buffs", EXTRA_PANEL_WIDTH - 40, yOffset)
		yOffset = yOffset - 40

		-- Raid Buffs Enable
		local raidBuffsEnable = self:CreateSwitch(parent, "SimpleParty.RaidBuffs", L["Enable Raid Buffs"] or "Enable Raid Buffs", L["Show raid buffs on simple party frames"] or "Show raid buffs on simple party frames")
		raidBuffsEnable:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Raid Buffs Style Dropdown
		local raidBuffsOptions = {
			{ text = L["Disabled"] or "Disabled", value = 0 },
			{ text = L["Standard"] or "Standard", value = 1 },
			{ text = L["Aura Track"] or "Aura Track", value = 2 },
		}
		local buffsDropdown = self:CreateDropdown(parent, "SimpleParty.RaidBuffsStyle", L["Raid Buffs Style"] or "Raid Buffs Style", raidBuffsOptions, L["Choose how raid buffs are displayed on simple party frames"] or "Choose how raid buffs are displayed on simple party frames")
		buffsDropdown:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Aura Track specific options
		local auraHeader = CreateSectionHeader(parent, L["Aura Track Options"] or "Aura Track Options", EXTRA_PANEL_WIDTH - 40, yOffset)
		yOffset = yOffset - 40

		local auraIconsSwitch = self:CreateSwitch(parent, "SimpleParty.AuraTrackIcons", L["Show Aura Icons"] or "Show Aura Icons", L["Display icons for tracked auras"] or "Display icons for tracked auras")
		auraIconsSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local auraTexturesSwitch = self:CreateSwitch(parent, "SimpleParty.AuraTrackSpellTextures", L["Use Spell Textures"] or "Use Spell Textures", L["Use spell textures instead of generic icons"] or "Use spell textures instead of generic icons")
		auraTexturesSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local auraThicknessSlider = self:CreateSlider(parent, "SimpleParty.AuraTrackThickness", L["Aura Track Thickness"] or "Aura Track Thickness", 1, 10, 1, L["Line thickness for aura track indicators"] or "Line thickness for aura track indicators")
		auraThicknessSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Only show Aura Track options when style == 2
		self:DependsOn(auraHeader, "SimpleParty.RaidBuffsStyle", 2, function(v)
			return v == 2
		end)
		self:DependsOn(auraIconsSwitch, "SimpleParty.RaidBuffsStyle", 2, function(v)
			return v == 2
		end)
		self:DependsOn(auraTexturesSwitch, "SimpleParty.RaidBuffsStyle", 2, function(v)
			return v == 2
		end)
		self:DependsOn(auraThicknessSlider, "SimpleParty.RaidBuffsStyle", 2, function(v)
			return v == 2
		end)

		-- Debuff Watch options
		local _ = CreateSectionHeader(parent, L["Debuff Watch"] or "Debuff Watch", EXTRA_PANEL_WIDTH - 40, yOffset)
		yOffset = yOffset - 40

		local debuffWatchSwitch = self:CreateSwitch(parent, "SimpleParty.DebuffWatch", L["Enable Debuff Watch"] or "Enable Debuff Watch", L["Show debuff indicators on simple party frames"] or "Show debuff indicators on simple party frames")
		debuffWatchSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local debuffWatchDefaultSwitch = self:CreateSwitch(parent, "SimpleParty.DebuffWatchDefault", L["Use Default Debuff List"] or "Use Default Debuff List", L["Use the default debuff list for tracking"] or "Use the default debuff list for tracking")
		debuffWatchDefaultSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Set parent height based on content
		parent:SetHeight(math.abs(yOffset) + 20)
	end, "Simple Party Frames")

	-- ---------------------------------------------------------------------------
	-- Configuration Registration: Automation
	-- ---------------------------------------------------------------------------

	-- REASON: Manage NPC IDs to ignore during auto-questing; maintains character-specific overrides.
	self:RegisterExtraConfig("Automation.AutoQuestIgnoreNPC", function(parent)
		self:CreateListEditor(parent, {
			title = L["AutoQuest Ignore NPCs Title"] or "Ignored Quest NPCs (Per-Character)",
			description = L["AutoQuest Ignore NPCs Desc"] or "Add NPC IDs to ignore for auto questing. Defaults are built-in; this list is per-character. Hold ALT and click NPC name in quest/gossip to toggle quickly.",
			inputLabel = L["Add NPC ID"] or "Add NPC ID",
			inputPlaceholder = format(L["e.g. %s"] or "e.g. %s", "162804"),
			inputTooltip = L["Enter an NPC ID to add"] or "Enter an NPC ID to add",
			listHeaderText = L["Current IDs"] or "Current IDs",
			listHeight = 300,
			rowKind = "npc",
			npcPortraitStyle = "plain",
			liveNPC = true,
			invalidMessage = "|cffff0000" .. (L["Invalid NPC ID. Enter a number."] or "Invalid NPC ID. Enter a number.") .. "|r",
			store = ExtraGUI.MakeCharFlatStore({
				varKey = "AutoQuestIgnoreNPC",
				stringKeys = true,
				defaultsTable = C.AutoQuestData and C.AutoQuestData.IgnoreQuestNPC,
				applyFn = function()
					local mod = K:GetModule("Automation")
					if mod and mod.UpdateAutoQuestIgnoreList then
						mod:UpdateAutoQuestIgnoreList()
					end
				end,
			}),
		})
	end, "Auto-Quest Ignore NPCs")
end

-- ---------------------------------------------------------------------------
-- WIDGET CREATION: COLOR PICKER
-- ---------------------------------------------------------------------------

-- REASON: Provides a button that opens the system color picker; supports live updates via hooks.
function ExtraGUI:CreateColorPicker(parent, configPath, text, tooltip, hookFunction, isNew)
	local widget = CreateFrame("Frame", nil, parent)
	widget:SetSize(GetExtraContentWidth(), 28)
	widget.ConfigPath = configPath

	-- Background
	CreateColoredBackground(widget, 0.12, 0.12, 0.12, 0.8)

	-- Process NEW tag from text
	local cleanText, hasNewTag = ProcessNewTag(text)
	local showNewTag = isNew or hasNewTag

	-- Label
	local label = widget:CreateFontString(nil, "OVERLAY")
	label:SetFontObject(K.UIFont)
	label:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	label:SetText(cleanText)
	label:SetPoint("LEFT", 8, 0)

	-- Make label clickable for reset functionality
	if configPath then
		local labelButton = CreateFrame("Button", nil, widget)
		labelButton:SetAllPoints(label)
		labelButton:SetScript("OnClick", function(self, button)
			if button == "LeftButton" and IsControlKeyDown() then
				ResetToDefault(configPath, widget, cleanText)
			end
		end)

		-- Add reset-to-default functionality with undo icon
		AddResetToDefaultFunctionality(widget, label, configPath, cleanText)
	end

	-- Add NEW tag if specified
	if showNewTag then
		AddNewTag(widget, label)
	end

	-- Register hook function with main GUI's hook system
	if hookFunction and type(hookFunction) == "function" and configPath then
		if K.NewGUI and K.NewGUI.RegisterHook then
			K.NewGUI:RegisterHook(configPath, hookFunction)
		end
	end

	-- Color Button
	local colorButton = CreateFrame("Button", nil, widget)
	colorButton:SetSize(30, 16)
	colorButton:SetPoint("RIGHT", -8, 0)

	local colorBg = colorButton:CreateTexture(nil, "BACKGROUND")
	colorBg:SetAllPoints()
	colorBg:SetTexture(C["Media"].Textures.White8x8Texture)
	colorBg:SetVertexColor(0.2, 0.2, 0.2, 1)

	-- Color Display
	local colorDisplay = colorButton:CreateTexture(nil, "OVERLAY")
	colorDisplay:SetPoint("TOPLEFT", 2, -2)
	colorDisplay:SetPoint("BOTTOMRIGHT", -2, 2)
	colorDisplay:SetTexture(C["Media"].Textures.White8x8Texture)

	-- Update function
	function widget:UpdateValue()
		local value = GetExtraConfigValue(self.ConfigPath)
		if value and type(value) == "table" and #value >= 3 then
			colorDisplay:SetVertexColor(value[1], value[2], value[3], value[4] or 1)
		else
			colorDisplay:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		end
	end

	-- Click handler
	colorButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end)

	-- Initialize
	widget:UpdateValue()
	return widget
end

-- ---------------------------------------------------------------------------
-- WIDGET CREATION: CHECKBOX GROUP
-- ---------------------------------------------------------------------------

-- REASON: Handles multiple boolean values stored as a table in the config; ideal for multi-selection.
function ExtraGUI:CreateCheckboxGroup(parent, configPath, text, options, tooltip, hookFunction, isNew)
	local widget = CreateFrame("Frame", nil, parent)

	-- Calculate height based on options
	local itemHeight = 25
	local totalHeight = 30 + (#options * itemHeight) + 10
	widget:SetSize(GetExtraContentWidth(), totalHeight)
	widget.ConfigPath = configPath

	-- Background
	CreateColoredBackground(widget, 0.12, 0.12, 0.12, 0.8)

	-- Process NEW tag from text
	local cleanText, hasNewTag = ProcessNewTag(text)
	local showNewTag = isNew or hasNewTag

	-- Label
	local label = widget:CreateFontString(nil, "OVERLAY")
	label:SetFontObject(K.UIFont)
	label:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	label:SetText(cleanText)
	label:SetPoint("TOPLEFT", 8, -8)

	-- Make label clickable for reset functionality
	if configPath then
		local labelButton = CreateFrame("Button", nil, widget)
		labelButton:SetAllPoints(label)
		labelButton:SetScript("OnClick", function(self, button)
			if button == "LeftButton" and IsControlKeyDown() then
				ResetToDefault(configPath, widget, cleanText)
			end
		end)

		-- Add reset-to-default functionality with undo icon
		AddResetToDefaultFunctionality(widget, label, configPath, cleanText)
	end

	-- Add NEW tag if specified
	if showNewTag then
		AddNewTag(widget, label)
	end

	-- Register hook function with main GUI's hook system
	if hookFunction and type(hookFunction) == "function" and configPath then
		if K.NewGUI and K.NewGUI.RegisterHook then
			K.NewGUI:RegisterHook(configPath, hookFunction)
		end
	end

	local checkboxes = {}
	for i, option in ipairs(options) do
		local yOffset = -25 - ((i - 1) * itemHeight)

		-- Checkbox container
		local checkboxContainer = CreateFrame("Frame", nil, widget)
		checkboxContainer:SetSize(GetExtraContentWidth() - 20, itemHeight - 2)
		checkboxContainer:SetPoint("TOPLEFT", 15, yOffset)

		-- Checkbox button
		local checkbox = CreateFrame("Button", nil, checkboxContainer)
		checkbox:SetSize(16, 16)
		checkbox:SetPoint("LEFT", 0, 0)

		local checkboxBg = checkbox:CreateTexture(nil, "BACKGROUND")
		checkboxBg:SetAllPoints()
		checkboxBg:SetTexture(C["Media"].Textures.White8x8Texture)
		checkboxBg:SetVertexColor(0.15, 0.15, 0.15, 1)

		-- Checkmark
		local checkMark = checkbox:CreateFontString(nil, "OVERLAY")
		checkMark:SetFontObject(K.UIFont)
		checkMark:SetTextColor(1, 1, 1, 1)
		checkMark:SetText("✓")
		checkMark:SetPoint("CENTER", 0, 0)
		checkMark:Hide()

		-- Label
		local checkLabel = checkboxContainer:CreateFontString(nil, "OVERLAY")
		checkLabel:SetFontObject(K.UIFont)
		checkLabel:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		checkLabel:SetText(option.text)
		checkLabel:SetPoint("LEFT", checkbox, "RIGHT", 8, 0)

		checkbox.CheckMark = checkMark
		checkbox.Background = checkboxBg
		checkbox.OptionValue = option.value
		checkboxes[i] = checkbox
	end

	-- Update function
	function widget:UpdateValue()
		local value = GetExtraConfigValue(self.ConfigPath)
		if type(value) ~= "table" then
			value = {}
		end

		for _, checkbox in ipairs(checkboxes) do
			local isChecked = false
			for _, v in ipairs(value) do
				if v == checkbox.OptionValue then
					isChecked = true
					break
				end
			end

			if isChecked then
				checkbox.Background:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
				checkbox.CheckMark:Show()
			else
				checkbox.Background:SetVertexColor(0.15, 0.15, 0.15, 1)
				checkbox.CheckMark:Hide()
			end
		end
	end

	-- Click handlers
	for _, checkbox in ipairs(checkboxes) do
		checkbox:SetScript("OnClick", function(self)
			local value = GetExtraConfigValue(configPath)
			if type(value) ~= "table" then
				value = {}
			end

			local newValues = {}
			local isCurrentlyChecked = false

			-- Copy existing values except the one we're toggling
			for _, v in ipairs(value) do
				if v == self.OptionValue then
					isCurrentlyChecked = true
				else
					table.insert(newValues, v)
				end
			end

			-- Add the value if it wasn't checked
			if not isCurrentlyChecked then
				table.insert(newValues, self.OptionValue)
			end

			SetExtraConfigValue(configPath, newValues, cleanText)
			widget:UpdateValue()
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

			-- Call hook function if provided
			if hookFunction and type(hookFunction) == "function" then
				hookFunction(newValues, value, configPath)
			end
		end)
	end

	-- Initialize
	widget:UpdateValue()
	return widget
end

-- ---------------------------------------------------------------------------
-- WIDGET CREATION: TEXT INPUT
-- ---------------------------------------------------------------------------

-- REASON: Multi-functional text input; supports placeholders, ESC to revert, and an explicit apply button.
function ExtraGUI:CreateTextInput(parent, configPath, text, placeholder, tooltip, hookFunction, isNew, customWidth)
	local widget = CreateFrame("Frame", nil, parent)
	widget:SetSize(customWidth or GetExtraContentWidth(), 28)
	widget.ConfigPath = configPath

	-- Background
	CreateColoredBackground(widget, 0.12, 0.12, 0.12, 0.8)

	-- Process NEW tag from text
	local cleanText, hasNewTag = ProcessNewTag(text)
	local showNewTag = isNew or hasNewTag

	-- Label
	local label = widget:CreateFontString(nil, "OVERLAY")
	label:SetFontObject(K.UIFont)
	label:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	label:SetText(cleanText)
	label:SetPoint("LEFT", 8, 0)

	-- Make label clickable for reset functionality
	if configPath then
		local labelButton = CreateFrame("Button", nil, widget)
		labelButton:SetAllPoints(label)
		labelButton:SetScript("OnClick", function(self, button)
			if button == "LeftButton" and IsControlKeyDown() then
				ResetToDefault(configPath, widget, cleanText)
			end
		end)

		-- Add reset-to-default functionality with undo icon
		AddResetToDefaultFunctionality(widget, label, configPath, cleanText)
	end

	-- Add NEW tag if specified
	if showNewTag then
		AddNewTag(widget, label)
	end

	-- Register hook function with main GUI's hook system
	if hookFunction and type(hookFunction) == "function" and configPath then
		if K.NewGUI and K.NewGUI.RegisterHook then
			K.NewGUI:RegisterHook(configPath, hookFunction)
		end
	end

	-- Text Input EditBox
	local editBox = CreateFrame("EditBox", nil, widget)
	editBox:SetSize(140, 20) -- Comment: Taller so text/placeholder doesn't overflow
	editBox:SetPoint("RIGHT", -28, 0) -- Leave space for apply button
	editBox:SetFontObject(K.UIFont)
	editBox:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	editBox:SetAutoFocus(false)
	editBox:SetMultiLine(false)
	editBox:SetMaxLetters(255)
	editBox:SetTextInsets(6, 6, 0, 0) -- Comment: Keep text inside the box

	-- Input background
	local inputBg = editBox:CreateTexture(nil, "BACKGROUND")
	inputBg:SetAllPoints()
	inputBg:SetTexture(C["Media"].Textures.White8x8Texture)
	inputBg:SetVertexColor(0.2, 0.2, 0.2, 1)

	-- Placeholder text (Comment: constrain width so it can't draw outside)
	local placeholderText
	local function UpdatePlaceholder()
		if not placeholderText then
			return
		end

		if editBox:GetText() == "" and not editBox:HasFocus() then
			placeholderText:Show()
		else
			placeholderText:Hide()
		end
	end

	if placeholder then
		placeholderText = editBox:CreateFontString(nil, "OVERLAY")
		placeholderText:SetFontObject(K.UIFont)
		placeholderText:SetTextColor(0.5, 0.5, 0.5, 1)
		placeholderText:SetText(placeholder)

		placeholderText:SetPoint("LEFT", editBox, "LEFT", 6, 0)
		placeholderText:SetPoint("RIGHT", editBox, "RIGHT", -6, 0) -- Comment: hard width constraint
		placeholderText:SetJustifyH("LEFT")
		placeholderText:SetJustifyV("MIDDLE")
		placeholderText:SetWordWrap(false)
		placeholderText:SetMaxLines(1)

		-- Comment: HookScript so we don't clobber save handlers below
		editBox:HookScript("OnTextChanged", UpdatePlaceholder)
		editBox:HookScript("OnEditFocusGained", UpdatePlaceholder)
		editBox:HookScript("OnEditFocusLost", UpdatePlaceholder)

		UpdatePlaceholder()
	end

	-- Update function
	function widget:UpdateValue()
		if not self.ConfigPath then
			editBox:SetText("")
			UpdatePlaceholder()
			return
		end

		local value = GetExtraConfigValue(self.ConfigPath)
		if value ~= nil and value ~= "" then
			editBox:SetText(tostring(value))
		else
			editBox:SetText("")
		end

		UpdatePlaceholder()
	end

	-- Save on enter/focus lost
	editBox:SetScript("OnEnterPressed", function(self)
		local newValue = self:GetText() or ""

		if configPath then
			SetExtraConfigValue(configPath, newValue, cleanText)
		end

		self:ClearFocus()

		-- Call hook function if provided
		if hookFunction and type(hookFunction) == "function" then
			hookFunction(newValue, widget.PreviousValue or "", configPath)
		end
		widget.PreviousValue = newValue

		UpdatePlaceholder()
	end)

	editBox:SetScript("OnEditFocusLost", function(self)
		local newValue = self:GetText() or ""

		if configPath then
			SetExtraConfigValue(configPath, newValue, cleanText)
		end

		if hookFunction and type(hookFunction) == "function" then
			hookFunction(newValue, widget.PreviousValue or "", configPath)
		end
		widget.PreviousValue = newValue

		UpdatePlaceholder()
	end)

	-- ESC to reset to default for ExtraGUI: fallback to current saved value from C
	editBox:SetScript("OnEscapePressed", function(self)
		if widget.ConfigPath then
			local defaultValue
			if K.Defaults then
				defaultValue = K.GetValueByPath(K.Defaults, widget.ConfigPath)
			end

			local revertValue = defaultValue
			if revertValue == nil then
				revertValue = K.GetValueByPath(C, widget.ConfigPath)
			end

			if revertValue ~= nil then
				editBox:SetText(tostring(revertValue))
				SetExtraConfigValue(widget.ConfigPath, revertValue)
			else
				editBox:SetText("")
			end
		end

		self:ClearFocus()
		UpdatePlaceholder()
	end)

	-- Apply checkmark button
	local applyButton = CreateFrame("Button", nil, widget)
	applyButton:SetSize(16, 16)
	applyButton:SetPoint("RIGHT", -8, 0)
	local applyIcon = applyButton:CreateTexture(nil, "ARTWORK")
	applyIcon:SetAllPoints()
	local ok = pcall(function()
		applyIcon:SetAtlas("common-icon-checkmark", true)
	end)
	if not ok then
		applyIcon:SetTexture(C["Media"].Textures.White8x8Texture)
		applyIcon:SetVertexColor(0.3, 0.9, 0.3, 1)
	end
	applyButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Apply"] or "Apply", 1, 1, 1, 1, true)
		GameTooltip:AddLine(L["Click to apply this value"] or "Click to apply this value", 0.7, 0.7, 0.7, true)
		GameTooltip:Show()
	end)
	applyButton:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	applyButton:SetScript("OnClick", function()
		local newValue = editBox:GetText() or ""

		-- Only persist when a configPath is provided
		if configPath then
			SetExtraConfigValue(configPath, newValue, cleanText)
		end

		if hookFunction and type(hookFunction) == "function" then
			hookFunction(newValue, widget.PreviousValue or "", configPath)
		end

		widget.PreviousValue = newValue
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end)

	-- Enhanced tooltip functionality
	if tooltip then
		widget:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(cleanText, 1, 1, 1, 1, true)
			GameTooltip:AddLine(tooltip, 0.7, 0.7, 0.7, true)
			GameTooltip:Show()
		end)

		widget:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)

		-- Also add tooltip to the editBox itself
		editBox:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(cleanText, 1, 1, 1, 1, true)
			GameTooltip:AddLine(tooltip, 0.7, 0.7, 0.7, true)
			GameTooltip:Show()
		end)

		editBox:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	end

	-- Expose the EditBox + thin text accessors so callers stop hunting through
	-- GetChildren() for the EditBox (that pattern silently breaks if layout changes,
	-- and was the cause of the Mute editor reading an empty string).
	widget.editBox = editBox
	function widget:GetText()
		return editBox:GetText()
	end
	function widget:SetText(t)
		editBox:SetText(t or "")
		UpdatePlaceholder()
	end

	-- Initialize
	widget:UpdateValue()
	return widget
end

-- ---------------------------------------------------------------------------
-- WIDGET CREATION: BUTTON
-- ---------------------------------------------------------------------------

-- NOTE: Delegates button creation to the unified K.WidgetFactory for visual consistency across the UI.
function ExtraGUI:CreateButton(parent, text, width, height, onClick)
	-- Use unified widget factory from K.WidgetFactory
	return K.WidgetFactory.CreateButton(parent, text, width, height, onClick)
end

-- ---------------------------------------------------------------------------
-- MODULE EXPORTS
-- ---------------------------------------------------------------------------

K.ExtraGUI = ExtraGUI
_G.KkthnxUI_ExtraGUI = ExtraGUI
