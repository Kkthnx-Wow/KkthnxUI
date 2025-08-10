local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

-- ============================================================================
-- EXTRAGUI SYSTEM DOCUMENTATION
-- ============================================================================

--[[
NDui-Style ExtraGUI System for KkthnxUI

This system provides a side panel that appears to the right of the main GUI
when users click cogwheel icons next to certain options. Features:
- Side panel positioned to the right of main GUI
- Same height as main GUI, half the width
- No overlapping - proper positioning
- Gradient line separators like NDui
- Cogwheel icons in main GUI for options with extra configs

Usage:
K.ExtraGUI:RegisterExtraConfig("Actionbar.MicroMenu", function(parent)
	-- Create extra configuration widgets here
end)
]]

-- ============================================================================
-- API DECLARATIONS
-- ============================================================================

-- Lua API
local _G = _G
local floor, max, min = math.floor, math.max, math.min
local format = string.format
local ipairs, pairs, type = ipairs, pairs, type

-- WoW API
local CreateFrame = CreateFrame
local UIParent = UIParent

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Helper function to get table keys
local function tKeys(t)
	local keys = {}
	for k, _ in pairs(t) do
		table.insert(keys, k)
	end
	return keys
end

-- Utility functions for handling nested config paths
local function SetValueByPath(table, path, value)
	if not path then
		return false
	end

	local keys = { strsplit(".", path) }
	local current = table

	for i = 1, #keys - 1 do
		if not current[keys[i]] then
			current[keys[i]] = {}
		elseif type(current[keys[i]]) ~= "table" then
			-- Handle case where we encounter a primitive value that needs to become a table
			current[keys[i]] = {}
		end
		current = current[keys[i]]
	end

	local finalKey = keys[#keys]
	current[finalKey] = value
	return true
end

local function GetValueByPath(table, path)
	if not path then
		return nil
	end

	local keys = { strsplit(".", path) }
	local current = table

	for i = 1, #keys do
		if not current or type(current) ~= "table" or current[keys[i]] == nil then
			return nil
		end
		current = current[keys[i]]
	end

	return current
end

-- ============================================================================
-- CONFIGURATION FUNCTIONS
-- ============================================================================

-- Get extra configuration value by path
local function GetExtraConfigValue(configPath)
	return GetValueByPath(C, configPath)
end

-- Set extra configuration value with hook integration
local function SetExtraConfigValue(configPath, value)
	-- Get old value for hook comparison
	local oldValue = GetValueByPath(C, configPath)

	-- Set in runtime config
	SetValueByPath(C, configPath, value)

	-- Save to database (with safety check) - exactly like main GUI
	if KkthnxUIDB then
		if not KkthnxUIDB.Settings then
			KkthnxUIDB.Settings = {}
		end
		if not KkthnxUIDB.Settings[K.Realm] then
			KkthnxUIDB.Settings[K.Realm] = {}
		end
		if not KkthnxUIDB.Settings[K.Realm][K.Name] then
			KkthnxUIDB.Settings[K.Realm][K.Name] = {}
		end

		SetValueByPath(KkthnxUIDB.Settings[K.Realm][K.Name], configPath, value)
	end

	-- Execute real-time update hooks (if available from main GUI)
	if oldValue ~= value then
		-- Try to use main GUI's hook system if available
		if K.GUI and K.GUI.GUI and K.GUI.GUI.TriggerHooks and type(K.GUI.GUI.TriggerHooks) == "function" then
			K.GUI.GUI:TriggerHooks(configPath, value, oldValue)
		end
	end

	return true
end

-- ============================================================================
-- CONSTANTS
-- ============================================================================

-- Panel Dimensions (based on main GUI)
local PANEL_WIDTH = 880
local PANEL_HEIGHT = 640
local EXTRA_PANEL_WIDTH = PANEL_WIDTH / 2 -- Half the width of main GUI
local SPACING = 8
local HEADER_HEIGHT = 40

-- Colors (use KkthnxUI's established color system)
local ACCENT_COLOR = { 0.36, 0.55, 0.81 }
local TEXT_COLOR = { 0.9, 0.9, 0.9, 1 }
local BG_COLOR = C["Media"].Backdrops.ColorBackdrop

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Create colored background texture
local function CreateColoredBackground(frame, r, g, b, a)
	local bg = frame:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(C["Media"].Textures.White8x8Texture)
	bg:SetVertexColor(r or 0, g or 0, b or 0, a or 0.8)
	return bg
end

-- Create NDui-style gradient separator lines
local function CreateGradientSeparator(parent, yOffset)
	local separator = CreateFrame("Frame", nil, parent)
	separator:SetHeight(1)
	separator:SetPoint("TOPLEFT", 15, yOffset)
	separator:SetPoint("TOPRIGHT", -15, yOffset)

	-- Create simple colored line (gradient methods are deprecated in newer WoW)
	local line = separator:CreateTexture(nil, "ARTWORK")
	line:SetAllPoints()
	line:SetTexture(C["Media"].Textures.White8x8Texture)
	-- Use solid accent color since SetGradientAlpha is no longer available
	line:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 0.6)

	return separator
end

-- ============================================================================
-- EXTRAGUI MODULE CORE
-- ============================================================================

-- ExtraGUI Module
local ExtraGUI = {
	ExtraConfigs = {},
	CurrentConfig = nil,
	IsVisible = false,
	IsInitialized = false,
}

-- ============================================================================
-- CONFIGURATION REGISTRATION
-- ============================================================================

-- Register extra configuration for a specific option path
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

-- ============================================================================
-- FRAME CREATION
-- ============================================================================

-- Create the ExtraGUI side panel
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

	-- Position to the right of main GUI
	-- We'll set this dynamically when showing based on main GUI position

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

	local title = titleBar:CreateFontString(nil, "OVERLAY")
	title:SetFontObject(K.UIFont)
	title:SetTextColor(1, 1, 1, 1)
	title:SetText("Extra Configuration")
	title:SetPoint("LEFT", 15, 0)

	-- Close Button using atlas icon
	local closeButton = CreateFrame("Button", nil, titleBar)
	closeButton:SetSize(24, 24)
	closeButton:SetPoint("RIGHT", -8, 0)

	-- Close button background
	local closeBg = closeButton:CreateTexture(nil, "BACKGROUND")
	closeBg:SetAllPoints()
	closeBg:SetTexture(C["Media"].Textures.White8x8Texture)
	closeBg:SetVertexColor(0, 0, 0, 0) -- Transparent by default

	-- Use atlas icon for close button
	closeButton.Icon = closeButton:CreateTexture(nil, "ARTWORK")
	closeButton.Icon:SetSize(12, 12)
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

	-- Content Area
	local content = CreateFrame("Frame", nil, frame)
	content:SetPoint("TOPLEFT", 0, -HEADER_HEIGHT)
	content:SetPoint("BOTTOMRIGHT", 0, 0)

	CreateColoredBackground(content, BG_COLOR[1], BG_COLOR[2], BG_COLOR[3], BG_COLOR[4])

	-- Scroll Frame for content
	local scrollFrame = CreateFrame("ScrollFrame", nil, content)
	scrollFrame:SetPoint("TOPLEFT", SPACING, -SPACING)
	scrollFrame:SetPoint("BOTTOMRIGHT", -SPACING, SPACING)

	-- Enable mouse wheel scrolling
	scrollFrame:EnableMouseWheel(true)
	scrollFrame:SetScript("OnMouseWheel", function(self, delta)
		local scrollStep = 40
		local currentScroll = self:GetVerticalScroll()
		local maxScroll = self:GetVerticalScrollRange()

		if delta > 0 then
			self:SetVerticalScroll(max(0, currentScroll - scrollStep))
		else
			self:SetVerticalScroll(min(maxScroll, currentScroll + scrollStep))
		end
	end)

	local scrollChild = CreateFrame("Frame", nil, scrollFrame)
	scrollChild:SetWidth(scrollFrame:GetWidth() - 10)
	scrollChild:SetHeight(1)
	scrollFrame:SetScrollChild(scrollChild)

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

-- ============================================================================
-- PANEL POSITIONING
-- ============================================================================

-- Position the extra panel relative to the main GUI
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

-- ============================================================================
-- SHOW/HIDE FUNCTIONALITY
-- ============================================================================

-- Show extra configuration for a specific config path
function ExtraGUI:ShowExtraConfig(configPath, optionTitle)
	local config = self.ExtraConfigs[configPath]
	if not config then
		return
	end

	if not self.Frame then
		self:CreateFrame()
	end

	-- Hook main GUI close event if not already hooked
	if not self.MainGUIHooked then
		self:HookMainGUIClose()
	end

	-- Clear existing content
	for _, child in ipairs({ self.ScrollChild:GetChildren() }) do
		child:Hide()
		child:SetParent(nil)
	end

	-- Update title bar only (remove duplicate titles)
	local displayTitle = optionTitle or config.title
	self.Title:SetText("Extra: " .. displayTitle)

	-- Start content layout with proper spacing
	local yOffset = -20

	-- Add category title in content area (like main GUI)
	local categoryTitleFrame = CreateFrame("Frame", nil, self.ScrollChild)
	categoryTitleFrame:SetSize(EXTRA_PANEL_WIDTH - 40, 25) -- Match main GUI height
	categoryTitleFrame:SetPoint("TOPLEFT", 15, yOffset)

	local categoryTitle = categoryTitleFrame:CreateFontString(nil, "OVERLAY")
	categoryTitle:SetFontObject(K.UIFont)
	categoryTitle:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1) -- Match main GUI accent color
	categoryTitle:SetText(displayTitle)
	categoryTitle:SetPoint("TOPLEFT", 0, 0) -- Match main GUI positioning

	-- Update yOffset after category title
	yOffset = yOffset - 45

	-- Create the extra configuration content directly without redundant titles
	if config.createContent then
		local contentContainer = CreateFrame("Frame", nil, self.ScrollChild)
		contentContainer:SetPoint("TOPLEFT", 15, yOffset)
		contentContainer:SetSize(EXTRA_PANEL_WIDTH - 40, 1) -- Proper width with margins

		-- Add subtle content background like main GUI
		local contentBg = contentContainer:CreateTexture(nil, "BACKGROUND")
		contentBg:SetAllPoints()
		contentBg:SetTexture(C["Media"].Textures.White8x8Texture)
		contentBg:SetVertexColor(0.05, 0.05, 0.05, 0.4)

		config.createContent(contentContainer)

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

-- Hook main GUI close event to auto-close ExtraGUI
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
	if mainGUI:GetScript("OnHide") then
		-- Store the original OnHide handler
		local originalOnHide = mainGUI:GetScript("OnHide")
		mainGUI:SetScript("OnHide", function(...)
			-- Call original handler first
			originalOnHide(...)
			-- Then close ExtraGUI
			self:Hide()
		end)
	else
		-- No existing OnHide handler, create one
		mainGUI:SetScript("OnHide", function()
			self:Hide()
		end)
	end

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

-- Show/Toggle the extra panel
function ExtraGUI:Show()
	if self.IsVisible then
		self:Hide()
	else
		-- Can't show without a specific config
	end
end

function ExtraGUI:Toggle()
	if self.IsVisible then
		self:Hide()
	else
		self:Show()
	end
end

-- ============================================================================
-- COGWHEEL ICON CREATION
-- ============================================================================

-- Helper function to create cogwheel icon for main GUI widgets
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

	-- Enhanced hover effects
	cogwheel:SetScript("OnEnter", function(self)
		icon:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)

		-- Add subtle scaling effect
		icon:SetSize(30, 30) -- Increased hover size from 24x24 to 26x26

		-- Show tooltip
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Extra Configuration", 1, 1, 1, 1, true)
		GameTooltip:AddLine("Click to open additional options for " .. (optionTitle or configPath), 0.7, 0.7, 0.7, true)
		GameTooltip:Show()
	end)

	cogwheel:SetScript("OnLeave", function(self)
		icon:SetVertexColor(0.8, 0.8, 0.8, 0.9)

		-- Return to normal size
		icon:SetSize(22, 22) -- Return to new normal size of 22x22

		GameTooltip:Hide()
	end)

	-- Click handler with toggle functionality
	cogwheel:SetScript("OnClick", function()
		-- Visual feedback
		icon:SetVertexColor(1, 1, 1, 1)
		C_Timer.After(0.1, function()
			icon:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		end)

		-- Check if ExtraGUI is already open with the same config
		if ExtraGUI.IsVisible and ExtraGUI.CurrentConfig and ExtraGUI.CurrentConfig.configPath == configPath then
			-- Same config is open, close it (toggle off)
			ExtraGUI:Hide()
		else
			-- Different config or not open, show it (toggle on or switch)
			ExtraGUI:ShowExtraConfig(configPath, optionTitle)
		end

		-- Play sound feedback
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end)

	return cogwheel
end

-- ============================================================================
-- MODULE INITIALIZATION
-- ============================================================================

-- Initialize ExtraGUI
function ExtraGUI:Enable()
	if self.IsInitialized then
		return
	end

	-- Register some example extra configurations
	self:RegisterExampleConfigs()

	self.IsInitialized = true
end

-- ============================================================================
-- WIDGET HELPER FUNCTIONS
-- ============================================================================

-- Helper function to get extra panel content width
local function GetExtraContentWidth()
	return EXTRA_PANEL_WIDTH - 40 -- Account for margins
end

-- Helper function to process NEW tags (same as main GUI)
local function ProcessNewTag(name)
	local cleanName, hasNewTag = string.gsub(name, "ISNEW", "")
	return cleanName, (hasNewTag > 0)
end

-- Helper function to add NEW tags (same as main GUI)
local function AddNewTag(parent, anchor)
	local tag = CreateFrame("Frame", nil, parent, "NewFeatureLabelTemplate")
	tag:SetPoint("LEFT", anchor or parent, -29, 11)
	tag:SetScale(0.85) -- Size down the NEW tag
	tag:Show()
	return tag
end

-- Helper function to create colored backgrounds (same as main GUI)
local function CreateColoredBackground(frame, r, g, b, a)
	local bg = frame:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(C["Media"].Textures.White8x8Texture)
	bg:SetVertexColor(r or 0, g or 0, b or 0, a or 0.8)
	return bg
end

-- ============================================================================
-- WIDGET CREATION FUNCTIONS
-- ============================================================================
-- These match the main GUI widget functions but are sized for the extra panel

-- Switch Widget for ExtraGUI
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

	-- Tooltip functionality (now added)
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
		else
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
		else
		end

		local newValue = not currentValue

		SetExtraConfigValue(configPath, newValue)
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

-- Slider Widget for ExtraGUI
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

	-- Update function
	function widget:UpdateValue()
		local value = GetExtraConfigValue(self.ConfigPath)
		if type(value) ~= "number" then
			value = minVal
		end

		value = math.max(minVal, math.min(maxVal, value))
		currentValue = value
		valueText:SetText(tostring(value))
		UpdateThumbPosition(value)
	end

	-- Mouse handling
	thumbFrame:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			isDragging = true
			self:SetScript("OnUpdate", function(self)
				if isDragging then
					local x = GetCursorPosition()
					local scale = UIParent:GetEffectiveScale()
					x = x / scale
					local newValue = GetValueFromPosition(x)
					if newValue ~= currentValue then
						currentValue = newValue
						valueText:SetText(tostring(newValue))
						UpdateThumbPosition(newValue)
						SetExtraConfigValue(configPath, newValue)

						-- Call hook function if provided
						if hookFunction and type(hookFunction) == "function" then
							hookFunction(newValue, currentValue, configPath)
						end
					end
				end
			end)
		end
	end)

	thumbFrame:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" and isDragging then
			isDragging = false
			self:SetScript("OnUpdate", nil)
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end
	end)

	-- Initialize
	widget:UpdateValue()
	return widget
end

-- Dropdown Widget for ExtraGUI
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

	-- Add NEW tag if specified
	if showNewTag then
		AddNewTag(widget, label)
	end

	-- Dropdown Button
	local dropdown = CreateFrame("Button", nil, widget)
	dropdown:SetSize(120, 18) -- Smaller for extra panel
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
	dropdownText:SetPoint("RIGHT", -20, 0)
	dropdownText:SetJustifyH("LEFT")

	-- Arrow Icon (try atlas first, fallback to text)
	local arrow = dropdown:CreateTexture(nil, "OVERLAY")
	local function SetArrowDown()
		local success = pcall(function()
			arrow:SetAtlas("minimal-scrollbar-small-arrow-bottom", true)
			arrow:SetSize(18, 12)
			arrow:SetPoint("RIGHT", -6, 0)
		end)
		if not success then
			-- Fallback to text if atlas fails
			arrow = dropdown:CreateFontString(nil, "OVERLAY")
			arrow:SetFontObject(K.UIFont)
			arrow:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
			arrow:SetText("▼")
			arrow:SetPoint("RIGHT", -6, 0)
		end
	end

	local function SetArrowUp()
		local success = pcall(function()
			arrow:SetAtlas("minimal-scrollbar-small-arrow-top", true)
			arrow:SetSize(18, 12)
		end)
		if not success then
			-- Fallback to text if atlas fails
			arrow = dropdown:CreateFontString(nil, "OVERLAY")
			arrow:SetFontObject(K.UIFont)
			arrow:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
			arrow:SetText("▲")
			arrow:SetPoint("RIGHT", -6, 0)
		end
	end

	-- Initialize arrow to down position
	SetArrowDown()

	-- Tooltip functionality (now added)
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
	end

	-- Menu state management
	local isMenuOpen = false
	local currentMenu = nil

	-- Function to close menu
	local function CloseMenu()
		if currentMenu then
			currentMenu:Hide()
			currentMenu = nil
			isMenuOpen = false
			SetArrowDown()
		end
	end

	-- Function to open menu
	local function OpenMenu()
		if isMenuOpen then
			CloseMenu()
			return
		end

		-- Create dropdown menu
		local menu = CreateFrame("Frame", nil, dropdown)
		menu:SetSize(120, #options * 22 + 4) -- Match dropdown width
		menu:SetPoint("TOP", dropdown, "BOTTOM", 0, -2)
		menu:SetFrameStrata("TOOLTIP")
		menu:SetFrameLevel(dropdown:GetFrameLevel() + 50)

		-- Menu background
		local menuBg = menu:CreateTexture(nil, "BACKGROUND")
		menuBg:SetAllPoints()
		menuBg:SetTexture(C["Media"].Textures.White8x8Texture)
		menuBg:SetVertexColor(0.1, 0.1, 0.1, 0.95)

		-- Menu border
		local menuBorder = CreateFrame("Frame", nil, menu)
		menuBorder:SetPoint("TOPLEFT", -1, 1)
		menuBorder:SetPoint("BOTTOMRIGHT", 1, -1)
		menuBorder:SetFrameLevel(menu:GetFrameLevel() - 1)
		local borderTexture = menuBorder:CreateTexture(nil, "BACKGROUND")
		borderTexture:SetAllPoints()
		borderTexture:SetTexture(C["Media"].Textures.White8x8Texture)
		borderTexture:SetVertexColor(0.3, 0.3, 0.3, 0.8)

		-- Create option buttons
		for i, option in ipairs(options) do
			local optionButton = CreateFrame("Button", nil, menu)
			optionButton:SetSize(118, 20) -- Slightly smaller to fit
			optionButton:SetPoint("TOP", 0, -(i - 1) * 22 - 2)

			-- Option background (for hover effect)
			local optionBg = optionButton:CreateTexture(nil, "BACKGROUND")
			optionBg:SetAllPoints()
			optionBg:SetTexture(C["Media"].Textures.White8x8Texture)
			optionBg:SetVertexColor(0, 0, 0, 0) -- Transparent by default

			-- Option text
			local optionText = optionButton:CreateFontString(nil, "OVERLAY")
			optionText:SetFontObject(K.UIFont)
			optionText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
			optionText:SetText(option.text)
			optionText:SetPoint("LEFT", 8, 0)

			-- Highlight current selection
			local currentValue = GetExtraConfigValue(configPath)
			if option.value == currentValue then
				optionBg:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 0.3)
			end

			-- Hover effects
			optionButton:SetScript("OnEnter", function(self)
				if option.value ~= currentValue then
					optionBg:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 0.2)
				end
				optionText:SetTextColor(1, 1, 1, 1)
			end)

			optionButton:SetScript("OnLeave", function(self)
				if option.value == currentValue then
					optionBg:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 0.3)
				else
					optionBg:SetVertexColor(0, 0, 0, 0)
				end
				optionText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
			end)

			-- Click handler
			optionButton:SetScript("OnClick", function()
				if configPath then
					SetExtraConfigValue(configPath, option.value)
					widget:UpdateValue()
				else
					-- For dropdowns without config paths, just update display
					dropdownText:SetText(option.text)
				end

				CloseMenu()
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

				-- Call hook function if provided
				if hookFunction and type(hookFunction) == "function" then
					hookFunction(option.value, currentValue, configPath)
				end
			end)
		end

		-- Set menu state
		currentMenu = menu
		isMenuOpen = true
		SetArrowUp()

		-- Mouse detection to auto-close menu
		local function IsMouseOverDropdownArea()
			if MouseIsOver(dropdown) or MouseIsOver(menu) then
				return true
			end

			-- Check if mouse is in the gap between dropdown and menu
			local cursorX, cursorY = GetCursorPosition()
			local scale = UIParent:GetEffectiveScale()
			cursorX, cursorY = cursorX / scale, cursorY / scale

			local dropdownLeft = dropdown:GetLeft()
			local dropdownRight = dropdown:GetRight()
			local dropdownBottom = dropdown:GetBottom()
			local menuTop = menu:GetTop()

			if dropdownLeft and dropdownRight and dropdownBottom and menuTop then
				-- Check if cursor is in the vertical gap between dropdown and menu
				if cursorX >= dropdownLeft and cursorX <= dropdownRight and cursorY <= dropdownBottom and cursorY >= menuTop then
					return true
				end
			end

			return false
		end

		-- Close menu when mouse is completely outside the dropdown area
		menu:SetScript("OnUpdate", function(self, elapsed)
			if not IsMouseOverDropdownArea() then
				CloseMenu()
				self:SetScript("OnUpdate", nil)
			end
		end)
	end

	-- Hover effect for dropdown button
	dropdown:SetScript("OnEnter", function(self)
		dropdownBg:SetVertexColor(0.2, 0.2, 0.2, 1)
		if arrow.SetVertexColor then
			arrow:SetVertexColor(1, 1, 1, 1) -- For texture arrows
		elseif arrow.SetTextColor then
			arrow:SetTextColor(1, 1, 1, 1) -- For fallback text arrows
		end
	end)

	dropdown:SetScript("OnLeave", function(self)
		dropdownBg:SetVertexColor(0.15, 0.15, 0.15, 1)
		if arrow.SetVertexColor then
			arrow:SetVertexColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4]) -- For texture arrows
		elseif arrow.SetTextColor then
			arrow:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4]) -- For fallback text arrows
		end
	end)

	-- Click handler for dropdown button
	dropdown:SetScript("OnClick", function()
		OpenMenu()
	end)

	-- Update function
	function widget:UpdateValue()
		if not self.ConfigPath then
			-- If no config path, just show the first option
			if options[1] then
				dropdownText:SetText(options[1].text)
			end
			return
		end

		local value = GetExtraConfigValue(self.ConfigPath)

		for _, option in ipairs(options) do
			if option.value == value then
				dropdownText:SetText(option.text)
				return
			end
		end
		dropdownText:SetText(options[1] and options[1].text or "Select...")
	end

	-- Close menu function for external use
	function widget:CloseMenu()
		CloseMenu()
	end

	-- Expose properties for external access
	widget.dropdownText = dropdownText
	widget.dropdown = dropdown

	-- Initialize
	widget:UpdateValue()

	return widget
end

local function UpdateActionBar1Scale()
	K:GetModule("ActionBar"):UpdateActionSize("Bar1")
end

local function UpdateActionBar2Scale()
	K:GetModule("ActionBar"):UpdateActionSize("Bar2")
end

local function UpdateActionBar3Scale()
	K:GetModule("ActionBar"):UpdateActionSize("Bar3")
end

local function UpdateActionBar4Scale()
	K:GetModule("ActionBar"):UpdateActionSize("Bar4")
end

local function UpdateActionBar5Scale()
	K:GetModule("ActionBar"):UpdateActionSize("Bar5")
end

local function UpdateActionBar6Scale()
	K:GetModule("ActionBar"):UpdateActionSize("Bar6")
end

local function UpdateActionBar7Scale()
	K:GetModule("ActionBar"):UpdateActionSize("Bar7")
end

local function UpdateActionBar8Scale()
	K:GetModule("ActionBar"):UpdateActionSize("Bar8")
end

local function UpdateABFaderState()
	local ActionBarModule = K:GetModule("ActionBar")
	if not ActionBarModule.fadeParent then
		return
	end
	ActionBarModule:UpdateFaderState()
	ActionBarModule.fadeParent:SetAlpha(C["ActionBar"].BarFadeAlpha)
end

-- Hook Functions for Inventory
local function UpdateBagStatus()
	local inventoryModule = K:GetModule("Bags")
	if inventoryModule and inventoryModule.UpdateAllBags then
		K:GetModule("Bags"):UpdateAllBags()
	end
end

-- Register extra configurations
function ExtraGUI:RegisterExampleConfigs()
	self:RegisterExtraConfig("ActionBar.Bar1", function(parent)
		local yOffset = -10

		local bar1SizeSlider = self:CreateSlider(parent, "ActionBar.Bar1Size", L["Button Size"], 20, 80, 1, L["Bar1Size Desc"], UpdateActionBar1Scale)
		bar1SizeSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar1PerRowSlider = self:CreateSlider(parent, "ActionBar.Bar1PerRow", L["Button PerRow"], 1, 12, 1, L["Bar1PerRow Desc"], UpdateActionBar1Scale)
		bar1PerRowSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar1NumSlider = self:CreateSlider(parent, "ActionBar.Bar1Num", L["Button Num"], 1, 12, 1, L["Bar1Num Desc"], UpdateActionBar1Scale)
		bar1NumSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar1FontSlider = self:CreateSlider(parent, "ActionBar.Bar1Font", L["Button FontSize"], 8, 20, 1, L["Bar1Font Desc"], UpdateActionBar1Scale)
		bar1FontSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar1FadeSwitch = self:CreateSwitch(parent, "ActionBar.Bar1Fade", L["Enable Fade for Bar 1"], L["Allows Bar 1 to fade based on the specified conditions"], UpdateABFaderState)
		bar1FadeSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Set parent height based on content
		parent:SetHeight(math.abs(yOffset) + 20)
	end, "Bar 1")

	self:RegisterExtraConfig("ActionBar.Bar2", function(parent)
		local yOffset = -10

		local bar2SizeSlider = self:CreateSlider(parent, "ActionBar.Bar2Size", L["Button Size"], 20, 80, 1, L["Bar2Size Desc"], UpdateActionBar2Scale)
		bar2SizeSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar2PerRowSlider = self:CreateSlider(parent, "ActionBar.Bar2PerRow", L["Button PerRow"], 1, 12, 1, L["Bar2PerRow Desc"], UpdateActionBar2Scale)
		bar2PerRowSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar2NumSlider = self:CreateSlider(parent, "ActionBar.Bar2Num", L["Button Num"], 1, 12, 1, L["Bar2Num Desc"], UpdateActionBar2Scale)
		bar2NumSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar2FontSlider = self:CreateSlider(parent, "ActionBar.Bar2Font", L["Button FontSize"], 8, 20, 1, L["Bar2Font Desc"], UpdateActionBar2Scale)
		bar2FontSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar2FadeSwitch = self:CreateSwitch(parent, "ActionBar.Bar2Fade", L["Enable Fade for Bar 2"], L["Allows Bar 2 to fade based on the specified conditions"], UpdateABFaderState)
		bar2FadeSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Set parent height based on content
		parent:SetHeight(math.abs(yOffset) + 20)
	end, "Bar 2")

	self:RegisterExtraConfig("ActionBar.Bar3", function(parent)
		local yOffset = -10

		local bar3SizeSlider = self:CreateSlider(parent, "ActionBar.Bar3Size", L["Button Size"], 20, 80, 1, L["Bar3Size Desc"], UpdateActionBar3Scale)
		bar3SizeSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar3PerRowSlider = self:CreateSlider(parent, "ActionBar.Bar3PerRow", L["Button PerRow"], 1, 12, 1, L["Bar3PerRow Desc"], UpdateActionBar3Scale)
		bar3PerRowSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar3NumSlider = self:CreateSlider(parent, "ActionBar.Bar3Num", L["Button Num"], 1, 12, 1, L["Bar3Num Desc"], UpdateActionBar3Scale)
		bar3NumSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar3FontSlider = self:CreateSlider(parent, "ActionBar.Bar3Font", L["Button FontSize"], 8, 20, 1, L["Bar3Font Desc"], UpdateActionBar3Scale)
		bar3FontSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar3FadeSwitch = self:CreateSwitch(parent, "ActionBar.Bar3Fade", L["Enable Fade for Bar 3"], L["Allows Bar 3 to fade based on the specified conditions"], UpdateABFaderState)
		bar3FadeSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		parent:SetHeight(math.abs(yOffset) + 20)
	end, "Bar 3")

	self:RegisterExtraConfig("ActionBar.Bar4", function(parent)
		local yOffset = -10

		local bar4SizeSlider = self:CreateSlider(parent, "ActionBar.Bar4Size", L["Button Size"], 20, 80, 1, L["Bar4Size Desc"], UpdateActionBar4Scale)
		bar4SizeSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar4PerRowSlider = self:CreateSlider(parent, "ActionBar.Bar4PerRow", L["Button PerRow"], 1, 12, 1, L["Bar4PerRow Desc"], UpdateActionBar4Scale)
		bar4PerRowSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar4NumSlider = self:CreateSlider(parent, "ActionBar.Bar4Num", L["Button Num"], 1, 12, 1, L["Bar4Num Desc"], UpdateActionBar4Scale)
		bar4NumSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar4FontSlider = self:CreateSlider(parent, "ActionBar.Bar4Font", L["Button FontSize"], 8, 20, 1, L["Bar4Font Desc"], UpdateActionBar4Scale)
		bar4FontSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar4FadeSwitch = self:CreateSwitch(parent, "ActionBar.Bar4Fade", L["Enable Fade for Bar 4"], L["Allows Bar 4 to fade based on the specified conditions"], UpdateABFaderState)
		bar4FadeSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Set parent height based on content
		parent:SetHeight(math.abs(yOffset) + 20)
	end, "Bar 4")

	self:RegisterExtraConfig("ActionBar.Bar5", function(parent)
		local yOffset = -10

		local bar5SizeSlider = self:CreateSlider(parent, "ActionBar.Bar5Size", L["Button Size"], 20, 80, 1, L["Bar5Size Desc"], UpdateActionBar5Scale)
		bar5SizeSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar5PerRowSlider = self:CreateSlider(parent, "ActionBar.Bar5PerRow", L["Button PerRow"], 1, 12, 1, L["Bar5PerRow Desc"], UpdateActionBar5Scale)
		bar5PerRowSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar5NumSlider = self:CreateSlider(parent, "ActionBar.Bar5Num", L["Button Num"], 1, 12, 1, L["Bar5Num Desc"], UpdateActionBar5Scale)
		bar5NumSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar5FontSlider = self:CreateSlider(parent, "ActionBar.Bar5Font", L["Button FontSize"], 8, 20, 1, L["Bar5Font Desc"], UpdateActionBar5Scale)
		bar5FontSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar5FadeSwitch = self:CreateSwitch(parent, "ActionBar.Bar5Fade", L["Enable Fade for Bar 5"], L["Allows Bar 5 to fade based on the specified conditions"], UpdateABFaderState)
		bar5FadeSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Set parent height based on content
		parent:SetHeight(math.abs(yOffset) + 20)
	end, "Bar 5")

	self:RegisterExtraConfig("ActionBar.Bar6", function(parent)
		local yOffset = -10

		local bar6SizeSlider = self:CreateSlider(parent, "ActionBar.Bar6Size", L["Button Size"], 20, 80, 1, L["Bar6Size Desc"], UpdateActionBar6Scale)
		bar6SizeSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar6PerRowSlider = self:CreateSlider(parent, "ActionBar.Bar6PerRow", L["Button PerRow"], 1, 12, 1, L["Bar6PerRow Desc"], UpdateActionBar6Scale)
		bar6PerRowSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar6NumSlider = self:CreateSlider(parent, "ActionBar.Bar6Num", L["Button Num"], 1, 12, 1, L["Bar6Num Desc"], UpdateActionBar6Scale)
		bar6NumSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar6FontSlider = self:CreateSlider(parent, "ActionBar.Bar6Font", L["Button FontSize"], 8, 20, 1, L["Bar6Font Desc"], UpdateActionBar6Scale)
		bar6FontSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar6FadeSwitch = self:CreateSwitch(parent, "ActionBar.Bar6Fade", L["Enable Fade for Bar 6"], L["Allows Bar 6 to fade based on the specified conditions"], UpdateABFaderState)
		bar6FadeSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Set parent height based on content
		parent:SetHeight(math.abs(yOffset) + 20)
	end, "Bar 6")

	self:RegisterExtraConfig("ActionBar.Bar7", function(parent)
		local yOffset = -10

		local bar7SizeSlider = self:CreateSlider(parent, "ActionBar.Bar7Size", L["Button Size"], 20, 80, 1, L["Bar7Size Desc"], UpdateActionBar7Scale)
		bar7SizeSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar7PerRowSlider = self:CreateSlider(parent, "ActionBar.Bar7PerRow", L["Button PerRow"], 1, 12, 1, L["Bar7PerRow Desc"], UpdateActionBar7Scale)
		bar7PerRowSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar7NumSlider = self:CreateSlider(parent, "ActionBar.Bar7Num", L["Button Num"], 1, 12, 1, L["Bar7Num Desc"], UpdateActionBar7Scale)
		bar7NumSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar7FontSlider = self:CreateSlider(parent, "ActionBar.Bar7Font", L["Button FontSize"], 8, 20, 1, L["Bar7Font Desc"], UpdateActionBar7Scale)
		bar7FontSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar7FadeSwitch = self:CreateSwitch(parent, "ActionBar.Bar7Fade", L["Enable Fade for Bar 7"], L["Allows Bar 7 to fade based on the specified conditions"], UpdateABFaderState)
		bar7FadeSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Set parent height based on content
		parent:SetHeight(math.abs(yOffset) + 20)
	end, "Bar 7")

	self:RegisterExtraConfig("ActionBar.Bar8", function(parent)
		local yOffset = -10

		local bar8SizeSlider = self:CreateSlider(parent, "ActionBar.Bar8Size", L["Button Size"], 20, 80, 1, L["Bar8Size Desc"], UpdateActionBar8Scale)
		bar8SizeSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar8PerRowSlider = self:CreateSlider(parent, "ActionBar.Bar8PerRow", L["Button PerRow"], 1, 12, 1, L["Bar8PerRow Desc"], UpdateActionBar8Scale)
		bar8PerRowSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar8NumSlider = self:CreateSlider(parent, "ActionBar.Bar8Num", L["Button Num"], 1, 12, 1, L["Bar8Num Desc"], UpdateActionBar8Scale)
		bar8NumSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar8FontSlider = self:CreateSlider(parent, "ActionBar.Bar8Font", L["Button FontSize"], 8, 20, 1, L["Bar8Font Desc"], UpdateActionBar8Scale)
		bar8FontSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local bar8FadeSwitch = self:CreateSwitch(parent, "ActionBar.Bar8Fade", L["Enable Fade for Bar 8"], L["Allows Bar 8 to fade based on the specified conditions"], UpdateABFaderState)
		bar8FadeSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Set parent height based on content
		parent:SetHeight(math.abs(yOffset) + 20)
	end, "Bar 8")

	-- Example: Nameplate Auras extra config using widget system
	self:RegisterExtraConfig("Nameplate.PlateAuras", function(parent)
		local yOffset = -10

		-- Player Auras Section
		local playerAurasGroup = self:CreateCheckboxGroup(parent, "Nameplate.PlayerAuras", "Player Auras", {
			{ text = "Show Player Buffs", value = "buffs" },
			{ text = "Show Player Debuffs", value = "debuffs" },
			{ text = "Show Player DoTs", value = "dots" },
		}, "Configure which player auras to show")
		playerAurasGroup:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - playerAurasGroup:GetHeight() - 10

		-- Enemy Auras Section
		local enemyAurasGroup = self:CreateCheckboxGroup(parent, "Nameplate.EnemyAuras", "Enemy Auras", {
			{ text = "Show Enemy Buffs", value = "buffs" },
			{ text = "Show Enemy Debuffs", value = "debuffs" },
			{ text = "Hide Raid Debuffs", value = "hideraid" },
		}, "Configure which enemy auras to show")
		enemyAurasGroup:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - enemyAurasGroup:GetHeight() - 10

		-- Aura Size Slider
		local auraSizeSlider = self:CreateSlider(parent, "Nameplate.AuraSize", "Aura Size", 16, 32, 1, "Size of aura icons")
		auraSizeSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Max Auras Slider
		local maxAurasSlider = self:CreateSlider(parent, "Nameplate.MaxAuras", "Max Auras", 4, 12, 1, "Maximum number of auras to display")
		maxAurasSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Set parent height based on content
		parent:SetHeight(math.abs(yOffset) + 20)
	end, "Nameplate Auras")

	-- Example: Chat Extra Config using widget system
	self:RegisterExtraConfig("Chat.General", function(parent)
		local yOffset = -10

		-- Chat Font Size Slider
		local fontSizeSlider = self:CreateSlider(parent, "Chat.FontSize", "Font Size", 8, 18, 1, "Size of chat text")
		fontSizeSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Chat Fade Time Slider
		local fadeTimeSlider = self:CreateSlider(parent, "Chat.FadeTime", "Fade Time", 5, 120, 5, "Time in seconds before chat messages fade")
		fadeTimeSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Short Channel Names Switch
		local shortNamesSwitch = self:CreateSwitch(parent, "Chat.ShortChannelNames", "Short Channel Names", "Use abbreviated channel names")
		shortNamesSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Link Hover Switch
		local linkHoverSwitch = self:CreateSwitch(parent, "Chat.LinkHover", "Link Hover Tooltips", "Show tooltips when hovering over links")
		linkHoverSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Chat Background Color Picker
		local bgColorPicker = self:CreateColorPicker(parent, "Chat.BackgroundColor", "Background Color", "Chat frame background color")
		bgColorPicker:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Chat Copy Button
		local copyButton = self:CreateButton(parent, "Copy Chat", 100, 25, function() end)
		copyButton:SetPoint("TOPLEFT", 10, yOffset)
		yOffset = yOffset - 35

		-- Set parent height based on content
		parent:SetHeight(math.abs(yOffset) + 20)
	end, "Chat Settings")

	-- Updated Inventory Filters Extra Config - Only filters and gather empty slots
	self:RegisterExtraConfig("Inventory.ItemFilter", function(parent)
		local yOffset = -10

		-- Filter Warband BOE Switch
		local warbandSwitch = self:CreateSwitch(parent, "Inventory.FilterAOE", "Filter Warband BOE", "Filter Warband bind-on-equip items", UpdateBagStatus)
		warbandSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Filter Anima Items Switch
		local animaSwitch = self:CreateSwitch(parent, "Inventory.FilterAnima", "Filter Anima Items", "Filter anima items into separate category", UpdateBagStatus)
		animaSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Filter Azerite Items Switch
		local azeriteSwitch = self:CreateSwitch(parent, "Inventory.FilterAzerite", "Filter Azerite Items", "Filter azerite items into separate category", UpdateBagStatus)
		azeriteSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Filter Collection Items Switch
		local collectionSwitch = self:CreateSwitch(parent, "Inventory.FilterCollection", "Filter Collection Items", "Filter collection items (pets, mounts, toys)", UpdateBagStatus)
		collectionSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Filter Consumables Switch
		local consumableSwitch = self:CreateSwitch(parent, "Inventory.FilterConsumable", "Filter Consumables", "Filter consumable items (food, potions, etc.)", UpdateBagStatus)
		consumableSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Filter Equipment Switch
		local equipmentSwitch = self:CreateSwitch(parent, "Inventory.FilterEquipment", "Filter Equipment", "Filter equipment items", UpdateBagStatus)
		equipmentSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Filter Trade Goods Switch
		local goodsSwitch = self:CreateSwitch(parent, "Inventory.FilterGoods", "Filter Trade Goods", "Filter trade goods and crafting materials", UpdateBagStatus)
		goodsSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Filter Junk Items Switch
		local junkSwitch = self:CreateSwitch(parent, "Inventory.FilterJunk", "Filter Junk Items", "Filter junk items for easy selling", UpdateBagStatus)
		junkSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Filter Quest Items Switch
		local questSwitch = self:CreateSwitch(parent, "Inventory.FilterQuest", "Filter Quest Items", "Filter quest items into separate category", UpdateBagStatus)
		questSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Filter Custom Items Switch
		local customSwitch = self:CreateSwitch(parent, "Inventory.FilterCustom", "Filter Custom Items", "Filter custom defined items", UpdateBagStatus)
		customSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Filter Legendary Items Switch
		local legendarySwitch = self:CreateSwitch(parent, "Inventory.FilterLegendary", "Filter Legendary Items", "Filter legendary items", UpdateBagStatus)
		legendarySwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Filter Lower Item Level Switch
		local lowerSwitch = self:CreateSwitch(parent, "Inventory.FilterLower", "Filter Lower Item Level", "Filter items with lower item level", UpdateBagStatus)
		lowerSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Filter Primordial Stones Switch
		local stoneSwitch = self:CreateSwitch(parent, "Inventory.FilterStone", "Filter Primordial Stones", "Filter primordial stones", UpdateBagStatus)
		stoneSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Gather Empty Slots Switch (this stays in extra config)
		local gatherEmptySwitch = self:CreateSwitch(parent, "Inventory.GatherEmpty", "Gather Empty Slots", "Gather empty slots into one button", UpdateBagStatus)
		gatherEmptySwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Reset Filters Button
		local resetButton = self:CreateButton(parent, "Reset Filters", 120, 25, function()
			-- Reset filter switches to default values
			SetExtraConfigValue("Inventory.FilterAOE", true)
			SetExtraConfigValue("Inventory.FilterAnima", true)
			SetExtraConfigValue("Inventory.FilterAzerite", false)
			SetExtraConfigValue("Inventory.FilterCollection", true)
			SetExtraConfigValue("Inventory.FilterConsumable", true)
			SetExtraConfigValue("Inventory.FilterEquipment", true)
			SetExtraConfigValue("Inventory.FilterGoods", false)
			SetExtraConfigValue("Inventory.FilterJunk", true)
			SetExtraConfigValue("Inventory.FilterQuest", true)
			SetExtraConfigValue("Inventory.FilterCustom", true)
			SetExtraConfigValue("Inventory.FilterLegendary", true)
			SetExtraConfigValue("Inventory.FilterLower", true)
			SetExtraConfigValue("Inventory.FilterStone", true)

			-- Update all widgets
			warbandSwitch:UpdateValue()
			animaSwitch:UpdateValue()
			azeriteSwitch:UpdateValue()
			collectionSwitch:UpdateValue()
			consumableSwitch:UpdateValue()
			equipmentSwitch:UpdateValue()
			goodsSwitch:UpdateValue()
			junkSwitch:UpdateValue()
			questSwitch:UpdateValue()
			customSwitch:UpdateValue()
			legendarySwitch:UpdateValue()
			lowerSwitch:UpdateValue()
			stoneSwitch:UpdateValue()
			gatherEmptySwitch:UpdateValue()
		end)
		resetButton:SetPoint("TOPLEFT", 10, yOffset)
		yOffset = yOffset - 35

		-- Set parent height based on content
		parent:SetHeight(math.abs(yOffset) + 20)
	end, "Inventory Filters")

	-- Nameplate Aura Management System
	self:RegisterExtraConfig("Nameplate.PlateAuras", function(parent)
		local yOffset = -10
		local contentWidth = GetExtraContentWidth()

		-- Create category selection dropdown
		local categories = {
			{ text = "Whitelist (Show These)", value = "NameplateWhiteList" },
			{ text = "Blacklist (Hide These)", value = "NameplateBlackList" },
			{ text = "Custom Units", value = "NameplateCustomUnits" },
			{ text = "Target NPCs", value = "NameplateTargetNPCs" },
			{ text = "Trash Units", value = "NameplateTrashUnits" },
			{ text = "Major Spells", value = "MajorSpells" },
		}

		local currentCategory = "NameplateWhiteList"
		local categoryDropdown, auraListFrame, addSpellInput, searchInput
		local auraItems = {}
		local scrollChild

		-- Declare RefreshAuraList function first so it's in scope
		local RefreshAuraList
		local CreateAuraItem

		-- Category Selection Header
		local categoryLabel = parent:CreateFontString(nil, "OVERLAY")
		categoryLabel:SetFontObject(K.UIFont)
		categoryLabel:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		categoryLabel:SetText("Aura Category:")
		categoryLabel:SetPoint("TOPLEFT", 10, yOffset)
		yOffset = yOffset - 25

		-- Category Dropdown
		categoryDropdown = self:CreateDropdown(parent, nil, "Select Category", categories, "Choose which aura list to manage", function(newValue, oldValue, configPath)
			-- Handle category change
			currentCategory = newValue
			if RefreshAuraList then
				RefreshAuraList()
			end
		end)
		categoryDropdown:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 45

		-- Search Input
		local searchLabel = parent:CreateFontString(nil, "OVERLAY")
		searchLabel:SetFontObject(K.UIFont)
		searchLabel:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		searchLabel:SetText("Search Auras:")
		searchLabel:SetPoint("TOPLEFT", 10, yOffset)
		yOffset = yOffset - 20

		searchInput = self:CreateTextInput(parent, nil, "", "Search by Spell ID or Name", "Filter displayed auras")
		searchInput:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Add New Spell Section
		local addLabel = parent:CreateFontString(nil, "OVERLAY")
		addLabel:SetFontObject(K.UIFont)
		addLabel:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		addLabel:SetText("Add New Spell ID:")
		addLabel:SetPoint("TOPLEFT", 10, yOffset)
		yOffset = yOffset - 20

		-- Create container for input and button
		local addContainer = CreateFrame("Frame", nil, parent)
		addContainer:SetSize(contentWidth, 28)
		addContainer:SetPoint("TOPLEFT", 0, yOffset)

		-- Create smaller text input to make room for button
		addSpellInput = self:CreateTextInput(addContainer, nil, "", "Enter Spell ID", "Add a new spell to the current category", nil, false, contentWidth - 110)
		addSpellInput:SetPoint("TOPLEFT", 0, 0)

		-- Create the add button positioned to the right of the input
		local addButton = self:CreateButton(addContainer, "Add Spell", 100, 28, function() end)
		addButton:SetPoint("LEFT", addSpellInput, "RIGHT", 10, 0)

		yOffset = yOffset - 35

		-- Add button click handler
		local addButtonHandler = function()
			local spellIdText = ""
			-- Access the editBox from the CreateTextInput widget
			if addSpellInput and addSpellInput:GetChildren() then
				for _, child in ipairs({ addSpellInput:GetChildren() }) do
					if child:GetObjectType() == "EditBox" then
						spellIdText = child:GetText()
						break
					end
				end
			end

			local spellId = tonumber(spellIdText)

			if spellId and spellId > 0 then
				-- Add to the current category
				if not C[currentCategory] then
					C[currentCategory] = {}
				end

				C[currentCategory][spellId] = true

				-- Clear the input - access editBox again
				if addSpellInput and addSpellInput:GetChildren() then
					for _, child in ipairs({ addSpellInput:GetChildren() }) do
						if child:GetObjectType() == "EditBox" then
							child:SetText("")
							break
						end
					end
				end

				-- Refresh the aura list
				RefreshAuraList()

				-- Play success sound
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			else
				print("|cffff0000Invalid Spell ID. Please enter a valid number.|r")
			end
		end

		-- Update the add button
		addButton:SetScript("OnClick", addButtonHandler)

		-- Aura List Header
		local listLabel = parent:CreateFontString(nil, "OVERLAY")
		listLabel:SetFontObject(K.UIFont)
		listLabel:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		listLabel:SetText("Current Auras:")
		listLabel:SetPoint("TOPLEFT", 10, yOffset)
		yOffset = yOffset - 25

		-- Aura List Container
		auraListFrame = CreateFrame("Frame", nil, parent)
		auraListFrame:SetPoint("TOPLEFT", 10, yOffset)
		auraListFrame:SetSize(contentWidth - 20, 300)

		-- Background for aura list
		local listBg = auraListFrame:CreateTexture(nil, "BACKGROUND")
		listBg:SetAllPoints()
		listBg:SetTexture(C["Media"].Textures.White8x8Texture)
		listBg:SetVertexColor(0.05, 0.05, 0.05, 0.8)

		-- Scroll Frame for aura list
		local scrollFrame = CreateFrame("ScrollFrame", nil, auraListFrame)
		scrollFrame:SetPoint("TOPLEFT", 5, -5)
		scrollFrame:SetPoint("BOTTOMRIGHT", -5, 5)
		scrollFrame:EnableMouseWheel(true)

		scrollChild = CreateFrame("Frame", nil, scrollFrame)
		scrollChild:SetWidth(contentWidth - 30) -- Use known width directly like main GUI
		scrollChild:SetHeight(1)
		scrollFrame:SetScrollChild(scrollChild)

		-- Mouse wheel scrolling
		scrollFrame:SetScript("OnMouseWheel", function(self, delta)
			local scrollStep = 30
			local currentScroll = self:GetVerticalScroll()
			local maxScroll = self:GetVerticalScrollRange()

			if delta > 0 then
				self:SetVerticalScroll(max(0, currentScroll - scrollStep))
			else
				self:SetVerticalScroll(min(maxScroll, currentScroll + scrollStep))
			end
		end)

		-- Function to refresh the aura list
		RefreshAuraList = function()
			-- Clear existing items
			for _, item in ipairs(auraItems) do
				item:Hide()
				item:SetParent(nil)
			end
			wipe(auraItems)

			if not C[currentCategory] then
				scrollChild:SetHeight(1)
				return
			end

			-- Get search text
			local searchText = ""
			if searchInput and searchInput:GetChildren() then
				for _, child in ipairs({ searchInput:GetChildren() }) do
					if child:GetObjectType() == "EditBox" then
						searchText = child:GetText():lower()
						break
					end
				end
			end

			-- Build filtered list
			local filteredSpells = {}
			for spellId, _ in pairs(C[currentCategory]) do
				local shouldShow = true

				if searchText ~= "" then
					local spellInfo = C_Spell.GetSpellInfo(spellId)
					local spellName = spellInfo and spellInfo.name or nil
					local spellIdStr = tostring(spellId)

					shouldShow = spellIdStr:find(searchText, 1, true) or (spellName and spellName:lower():find(searchText, 1, true))
				end

				if shouldShow then
					table.insert(filteredSpells, spellId)
				end
			end

			-- Sort by spell ID
			table.sort(filteredSpells)

			-- Create items
			for i, spellId in ipairs(filteredSpells) do
				local item = CreateAuraItem(spellId, i)
				table.insert(auraItems, item)
			end

			-- Update scroll child height
			scrollChild:SetHeight(max(#filteredSpells * 29, 250)) -- Updated to match new spacing
		end

		-- Function to create an aura item row
		CreateAuraItem = function(spellId, index)
			local item = CreateFrame("Frame", nil, scrollChild)
			item:SetSize(contentWidth - 40, 27) -- Slightly taller for better icon fit
			item:SetPoint("TOPLEFT", 0, -(index - 1) * 29) -- Increased spacing

			-- Background
			local itemBg = item:CreateTexture(nil, "BACKGROUND")
			itemBg:SetAllPoints()
			itemBg:SetTexture(C["Media"].Textures.White8x8Texture)
			if index % 2 == 0 then
				itemBg:SetVertexColor(0.1, 0.1, 0.1, 0.5)
			else
				itemBg:SetVertexColor(0.05, 0.05, 0.05, 0.5)
			end

			-- Spell Icon Container (for better border control)
			local iconContainer = CreateFrame("Frame", nil, item)
			iconContainer:SetSize(20, 20) -- Smaller square container (was 24x24)
			iconContainer:SetPoint("LEFT", 6, 0) -- Slightly less padding since icon is smaller

			-- Icon border/background
			local iconBorder = iconContainer:CreateTexture(nil, "BACKGROUND")
			iconBorder:SetAllPoints()
			iconBorder:SetTexture(C["Media"].Textures.White8x8Texture)
			iconBorder:SetVertexColor(0.2, 0.2, 0.2, 0.8)

			-- Spell Icon
			local icon = iconContainer:CreateTexture(nil, "ARTWORK")
			icon:SetSize(18, 18) -- Smaller square icon (was 22x22)
			icon:SetPoint("CENTER", 0, 0) -- Perfectly centered

			local spellTexture = C_Spell.GetSpellTexture(spellId)
			if spellTexture then
				icon:SetTexture(spellTexture)
				icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Crop borders for cleaner look
			else
				icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
				icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Apply same cropping to fallback
			end

			-- Spell ID Text
			local idText = item:CreateFontString(nil, "OVERLAY")
			idText:SetFontObject(K.UIFont)
			idText:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
			idText:SetText(tostring(spellId))
			idText:SetPoint("LEFT", iconContainer, "RIGHT", 10, 0) -- Adjusted spacing for smaller icon

			-- Spell Name Text
			local nameText = item:CreateFontString(nil, "OVERLAY")
			nameText:SetFontObject(K.UIFont)
			nameText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
			local spellInfo = C_Spell.GetSpellInfo(spellId)
			local spellName = spellInfo and spellInfo.name or "Unknown Spell"
			nameText:SetText(spellName)
			nameText:SetPoint("LEFT", idText, "RIGHT", 15, 0)

			-- Remove Button
			local removeButton = CreateFrame("Button", nil, item)
			removeButton:SetSize(18, 18) -- Square button
			removeButton:SetPoint("RIGHT", -8, 0) -- More padding from right edge

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
				-- Remove from the category
				if C[currentCategory] then
					C[currentCategory][spellId] = nil
				end

				-- Refresh the list
				RefreshAuraList()

				-- Play sound
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
			end)

			removeButton:SetScript("OnEnter", function(self)
				removeBg:SetVertexColor(1, 0.2, 0.2, 1)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText("Remove Aura", 1, 1, 1, 1, true)
				GameTooltip:AddLine("Click to remove this aura from the list", 0.7, 0.7, 0.7, true)
				GameTooltip:Show()
			end)

			removeButton:SetScript("OnLeave", function(self)
				removeBg:SetVertexColor(0.8, 0.2, 0.2, 0.8)
				GameTooltip:Hide()
			end)

			return item
		end

		-- Category dropdown change handler
		local function OnCategoryChanged(newValue)
			currentCategory = newValue
			RefreshAuraList()
		end

		-- Search input change handler
		if searchInput and searchInput:GetChildren() then
			for _, child in ipairs({ searchInput:GetChildren() }) do
				if child:GetObjectType() == "EditBox" then
					child:SetScript("OnTextChanged", function()
						if RefreshAuraList then
							RefreshAuraList()
						end
					end)
					break
				end
			end
		end

		-- Initialize with first category
		categoryDropdown.dropdownText:SetText(categories[1].text)
		currentCategory = categories[1].value
		-- Call RefreshAuraList after it's been defined
		if RefreshAuraList then
			RefreshAuraList()
		end

		-- Update yOffset for parent height
		yOffset = yOffset - 320

		-- Instructions
		local instructionText = parent:CreateFontString(nil, "OVERLAY")
		instructionText:SetFontObject(K.UIFont)
		instructionText:SetTextColor(0.7, 0.7, 0.7, 1)
		instructionText:SetText("• Use /dump spellID to get spell IDs in-game\n• Whitelist: Auras that will always show\n• Blacklist: Auras that will always hide\n• Changes take effect immediately")
		instructionText:SetPoint("TOPLEFT", 10, yOffset)
		instructionText:SetWidth(contentWidth - 20)
		instructionText:SetJustifyH("LEFT")
		yOffset = yOffset - 60

		-- Set parent height based on content
		parent:SetHeight(math.abs(yOffset) + 20)
	end, "Nameplate Auras")
end

-- Color Picker Widget for ExtraGUI
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

	-- Add NEW tag if specified
	if showNewTag then
		AddNewTag(widget, label)
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

-- Checkbox Group Widget for ExtraGUI
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

	-- Add NEW tag if specified
	if showNewTag then
		AddNewTag(widget, label)
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

			SetExtraConfigValue(configPath, newValues)
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

-- Text Input Widget for ExtraGUI
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

	-- Add NEW tag if specified
	if showNewTag then
		AddNewTag(widget, label)
	end

	-- Text Input EditBox
	local editBox = CreateFrame("EditBox", nil, widget)
	editBox:SetSize(120, 16) -- Smaller for extra panel
	editBox:SetPoint("RIGHT", -8, 0)
	editBox:SetFontObject(K.UIFont)
	editBox:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	editBox:SetAutoFocus(false)

	-- Input background
	local inputBg = editBox:CreateTexture(nil, "BACKGROUND")
	inputBg:SetAllPoints()
	inputBg:SetTexture(C["Media"].Textures.White8x8Texture)
	inputBg:SetVertexColor(0.2, 0.2, 0.2, 1)

	-- Placeholder text
	if placeholder then
		local placeholderText = editBox:CreateFontString(nil, "OVERLAY")
		placeholderText:SetFontObject(K.UIFont)
		placeholderText:SetTextColor(0.5, 0.5, 0.5, 1)
		placeholderText:SetText(placeholder)
		placeholderText:SetPoint("LEFT", editBox, "LEFT", 4, 0)

		editBox:SetScript("OnTextChanged", function(self)
			local text = self:GetText()
			if text == "" then
				placeholderText:Show()
			else
				placeholderText:Hide()
			end
		end)

		editBox:SetScript("OnEditFocusGained", function()
			placeholderText:Hide()
		end)

		editBox:SetScript("OnEditFocusLost", function(self)
			if self:GetText() == "" then
				placeholderText:Show()
			end
		end)
	end

	-- Update function
	function widget:UpdateValue()
		if not self.ConfigPath then
			-- For widgets without config paths, keep empty
			editBox:SetText("")
			return
		end

		local value = GetExtraConfigValue(self.ConfigPath)
		if value ~= nil and value ~= "" then
			editBox:SetText(tostring(value))
		else
			editBox:SetText("") -- Set to empty string instead of showing "nil"
		end
	end

	-- Save on enter/focus lost
	editBox:SetScript("OnEnterPressed", function(self)
		local newValue = self:GetText()
		SetExtraConfigValue(configPath, newValue)
		self:ClearFocus()

		-- Call hook function if provided
		if hookFunction and type(hookFunction) == "function" then
			hookFunction(newValue, widget.PreviousValue or "", configPath)
		end
		widget.PreviousValue = newValue
	end)

	editBox:SetScript("OnEditFocusLost", function(self)
		local newValue = self:GetText()
		SetExtraConfigValue(configPath, newValue)

		-- Call hook function if provided
		if hookFunction and type(hookFunction) == "function" then
			hookFunction(newValue, widget.PreviousValue or "", configPath)
		end
		widget.PreviousValue = newValue
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

	-- Initialize
	widget:UpdateValue()
	return widget
end

-- Button Widget for ExtraGUI
function ExtraGUI:CreateButton(parent, text, width, height, onClick)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(width or 100, height or 25)

	-- Button background
	local buttonBg = button:CreateTexture(nil, "BACKGROUND")
	buttonBg:SetAllPoints()
	buttonBg:SetTexture(C["Media"].Textures.White8x8Texture)
	buttonBg:SetVertexColor(0.15, 0.15, 0.15, 1)

	-- Button text
	local buttonText = button:CreateFontString(nil, "OVERLAY")
	buttonText:SetFontObject(K.UIFont)
	buttonText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	buttonText:SetText(text)
	buttonText:SetPoint("CENTER")

	-- Hover effects
	button:SetScript("OnEnter", function(self)
		buttonBg:SetVertexColor(ACCENT_COLOR[1] * 0.8, ACCENT_COLOR[2] * 0.8, ACCENT_COLOR[3] * 0.8, 1)
		buttonText:SetTextColor(1, 1, 1, 1)
	end)

	button:SetScript("OnLeave", function(self)
		buttonBg:SetVertexColor(0.15, 0.15, 0.15, 1)
		buttonText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	end)

	if onClick then
		button:SetScript("OnClick", onClick)
	end

	return button
end

-- ============================================================================
-- MODULE EXPORTS
-- ============================================================================

-- Export to global for access
K.ExtraGUI = ExtraGUI
_G.KkthnxUI_ExtraGUI = ExtraGUI

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

-- Initialize immediately when the file loads
ExtraGUI:Enable()
