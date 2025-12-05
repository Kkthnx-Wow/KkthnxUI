local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

-- System Documentation

--[[
ExtraGUI System for KkthnxUI

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

-- API Declarations

-- Lua API
local _G = _G
local floor, max, min = math.floor, math.max, math.min
local format = string.format
local ipairs, pairs, type = ipairs, pairs, type

-- WoW API
local CreateFrame = CreateFrame
local UIParent = UIParent

-- Utility Functions

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

-- Configuration Functions

-- Get default value for a config path
local function GetDefaultValue(configPath)
	-- First check if K.Defaults exists and has the path
	if K.Defaults then
		local defaultValue = GetValueByPath(K.Defaults, configPath)
		if defaultValue ~= nil then
			return defaultValue
		end
	end

	-- Fallback: If K.Defaults doesn't exist or doesn't have the path,
	-- try to get from the original C table structure (may be current values though)
	return GetValueByPath(C, configPath)
end

-- Get extra configuration value by path
local function GetExtraConfigValue(configPath)
	return GetValueByPath(C, configPath)
end

-- Set extra configuration value with hook integration and reload tracking
local function SetExtraConfigValue(configPath, value, settingName)
	-- Use main GUI's SetConfigValue if available - it handles hooks AND reload tracking
	if K.NewGUI and K.NewGUI.SetConfigValue then
		-- Main GUI's SetConfigValue handles everything: saving, hooks, and reload tracking
		K.NewGUI:SetConfigValue(configPath, value, false, settingName)
		return true
	end

	-- Fallback if main GUI not available (shouldn't happen in normal operation)
	-- Get old value for hook comparison
	local oldValue = GetValueByPath(C, configPath)

	-- Set in runtime config
	SetValueByPath(C, configPath, value)

	-- Save to database (with safety check)
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
		if K.NewGUI and K.NewGUI.TriggerHooks and type(K.NewGUI.TriggerHooks) == "function" then
			K.NewGUI:TriggerHooks(configPath, value, oldValue)
		end
	end

	return true
end

-- Reset to Default Functionality

-- Reset a setting to its default value
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

-- Global Ctrl key checker for reset buttons
local CtrlChecker = CreateFrame("Frame")
local resetButtons = {}

local function CtrlUpdate()
	for widget, resetButton in pairs(resetButtons) do
		if widget:IsMouseOver() then
			if IsControlKeyDown() then
				if not resetButton:IsShown() then
					resetButton:Show()
				end
			else
				if resetButton:IsShown() then
					resetButton:Hide()
					GameTooltip:Hide()
				end
			end
		else
			if resetButton:IsShown() then
				resetButton:Hide()
				GameTooltip:Hide()
			end
		end
	end
end

CtrlChecker.CtrlUpdate = CtrlUpdate
-- Disabled by default; enabled while ExtraGUI is visible
CtrlChecker:SetScript("OnUpdate", nil)

-- Throttled OnUpdate to reduce per-frame work
local function CtrlChecker_OnUpdate(self, elapsed)
	self._accum = (self._accum or 0) + (elapsed or 0)
	if self._accum < 0.12 then
		return
	end
	self._accum = 0
	CtrlChecker:CtrlUpdate()
end

-- Helper function to add reset-to-default functionality to widget labels
local function AddResetToDefaultFunctionality(widget, label, configPath, cleanText)
	-- Create reset button with undo icon
	local resetButton = CreateFrame("Button", nil, widget)
	resetButton:SetSize(16, 16)

	-- Position next to label (no cogwheel in ExtraGUI widgets)
	resetButton:SetPoint("LEFT", label, "RIGHT", 5, 0)
	resetButton:Hide() -- Initially hidden

	-- Undo icon
	local undoIcon = resetButton:CreateTexture(nil, "ARTWORK")
	undoIcon:SetAllPoints()
	undoIcon:SetAlpha(0.7)

	-- Try to set the atlas, with fallback
	local success = pcall(function()
		undoIcon:SetAtlas("common-icon-undo", true)
		undoIcon:SetSize(16, 16)
	end)

	if not success then
		-- Fallback to a texture if atlas fails
		undoIcon:SetTexture("Interface\\Buttons\\UI-RefreshButton")
		undoIcon:SetTexCoord(0, 1, 0, 1)
	end

	-- Hover effects for the reset button
	resetButton:SetScript("OnEnter", function(self)
		undoIcon:SetAlpha(1)
		-- Show tooltip
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Reset to Default"] or "Reset to Default", 1, 1, 1, 1, true)
		GameTooltip:AddLine(L["Click to reset this setting to its default value"] or "Click to reset this setting to its default value", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
		GameTooltip:Show()
	end)

	resetButton:SetScript("OnLeave", function(self)
		undoIcon:SetAlpha(0.7)
		GameTooltip:Hide()
	end)

	-- Click handler for reset
	resetButton:SetScript("OnClick", function(self, button)
		if button == "LeftButton" then
			ResetToDefault(configPath, widget, cleanText)
		end
	end)

	-- Store reference for showing/hiding
	widget.ResetButton = resetButton

	-- Register with global checker
	resetButtons[widget] = resetButton

	return resetButton
end

-- Constants

-- Panel Dimensions (based on main GUI)
local PANEL_WIDTH = 880
local PANEL_HEIGHT = 640
local EXTRA_PANEL_WIDTH = PANEL_WIDTH / 2 -- Half the width of main GUI
local SPACING = 8
local HEADER_HEIGHT = 40

-- Colors (use KkthnxUI's established color system)
local ACCENT_COLOR = { K.r, K.g, K.b }
local TEXT_COLOR = { 0.9, 0.9, 0.9, 1 }
local BG_COLOR = C["Media"].Backdrops.ColorBackdrop

-- Helper Functions

-- Create colored background texture
local function CreateColoredBackground(frame, r, g, b, a)
	if K and K.GUIHelpers and K.GUIHelpers.CreateColoredBackground then
		return K.GUIHelpers.CreateColoredBackground(frame, r, g, b, a)
	end
	local bg = frame:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(C["Media"].Textures.White8x8Texture)
	bg:SetVertexColor(r or 0, g or 0, b or 0, a or 0.8)
	return bg
end

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

-- ExtraGUI Module Core

-- ExtraGUI Module
local ExtraGUI = {
	ExtraConfigs = {},
	CurrentConfig = nil,
	IsVisible = false,
	IsInitialized = false,
}

-- Configuration Registration

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

-- Frame Creation

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
	title:SetText(L["Extra Configuration"] or "Extra Configuration")
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

	-- Reload UI Button (left of close button)
	local reloadButton = CreateFrame("Button", nil, titleBar)
	reloadButton:SetSize(24, 24)
	reloadButton:SetPoint("RIGHT", closeButton, "LEFT", -4, 0)

	local reloadBg = reloadButton:CreateTexture(nil, "BACKGROUND")
	reloadBg:SetAllPoints()
	reloadBg:SetTexture(C["Media"].Textures.White8x8Texture)
	reloadBg:SetVertexColor(0, 0, 0, 0)

	reloadButton.Icon = reloadButton:CreateTexture(nil, "ARTWORK")
	reloadButton.Icon:SetSize(14, 14)
	reloadButton.Icon:SetPoint("CENTER")
	reloadButton.Icon:SetAtlas("transmog-icon-revert")
	reloadButton.Icon:SetVertexColor(1, 1, 1, 0.8)

	reloadButton:SetScript("OnClick", function()
		-- Clear pending reloads and reload UI immediately
		if K.NewGUI and K.NewGUI.ClearReloadQueue then
			K.NewGUI:ClearReloadQueue()
		end
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		ReloadUI()
	end)

	reloadButton:SetScript("OnEnter", function(self)
		self.Icon:SetVertexColor(1, 1, 1, 1)
		reloadBg:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 0.3)

		-- Tooltip
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
		GameTooltip:SetText(L["Reload UI"] or "Reload UI", 1, 1, 1, 1, true)
		GameTooltip:AddLine(L["Apply changes immediately"] or "Apply changes immediately", 0.7, 0.7, 0.7)
		GameTooltip:Show()
	end)

	reloadButton:SetScript("OnLeave", function(self)
		self.Icon:SetVertexColor(1, 1, 1, 0.8)
		reloadBg:SetVertexColor(0, 0, 0, 0)
		GameTooltip:Hide()
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

	-- Mouse wheel scrolling
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

-- Panel Positioning

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

-- Show/Hide Functionality

-- Show extra configuration for a specific config path
function ExtraGUI:ShowExtraConfig(configPath, optionTitle)
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
	for key, container in pairs(self.ConfigContainers) do
		if container and container.Hide then
			container:Hide()
		end
	end

	-- Update title bar only (remove duplicate titles)
	local displayTitle = optionTitle or config.title
	self.Title:SetText(format(L["Extra: %s"] or "Extra: %s", displayTitle))

	-- Start content layout with proper spacing
	local yOffset = -20

	-- Add category title in content area (like main GUI)
	local categoryTitleFrame = CreateFrame("Frame", nil, self.ScrollChild)
	categoryTitleFrame:SetSize(EXTRA_PANEL_WIDTH - 40, 30) -- Match main GUI height
	categoryTitleFrame:SetPoint("TOPLEFT", 15, yOffset)

	-- Background to match main GUI category headers
	local categoryBg = categoryTitleFrame:CreateTexture(nil, "BACKGROUND")
	categoryBg:SetAllPoints()
	categoryBg:SetTexture(C["Media"].Textures.White8x8Texture)
	categoryBg:SetVertexColor(0.09, 0.09, 0.09, 0.8)

	local categoryTitle = categoryTitleFrame:CreateFontString(nil, "OVERLAY")
	categoryTitle:SetFontObject(K.UIFont)
	categoryTitle:SetTextColor(0.9, 0.9, 0.9, 1) -- Match main GUI style
	categoryTitle:SetText(displayTitle)
	categoryTitle:SetPoint("CENTER", categoryTitleFrame, "CENTER", 0, 0) -- Centered like main GUI

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

	-- Enable CtrlChecker updates while ExtraGUI is visible
	if CtrlChecker then
		CtrlChecker:SetScript("OnUpdate", CtrlChecker_OnUpdate)
	end
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

	-- Disable CtrlChecker when ExtraGUI is hidden
	if CtrlChecker then
		CtrlChecker:SetScript("OnUpdate", nil)
	end
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

-- Cogwheel Icon Creation

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
		GameTooltip:SetText(L["Extra Configuration"] or "Extra Configuration", 1, 1, 1, 1, true)
		local tipMsg = format(L["Click to open additional options for %s"] or "Click to open additional options for %s", (optionTitle or configPath))
		GameTooltip:AddLine(tipMsg, 0.7, 0.7, 0.7, true)
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

-- Module Initialization

-- Initialize ExtraGUI
function ExtraGUI:Enable()
	if self.IsInitialized or self._enabled then
		return true
	end

	-- Register some example extra configurations
	self:RegisterExampleConfigs()

	self.IsInitialized = true
	self._enabled = true
	return true
end

-- Widget Helper Functions

-- Helper function to get extra panel content width
local function GetExtraContentWidth()
	return EXTRA_PANEL_WIDTH - 40 -- Account for margins
end

-- Helper function to process NEW tags (same as main GUI)
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

-- Helper function to add NEW tags (same as main GUI)
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

-- Helper function to create colored backgrounds (same as main GUI)
local function CreateColoredBackground(frame, r, g, b, a)
	local bg = frame:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(C["Media"].Textures.White8x8Texture)
	bg:SetVertexColor(r or 0, g or 0, b or 0, a or 0.8)
	return bg
end

-- Widget Creation Functions
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

-- Declare dependency for an ExtraGUI widget on a parent config path
-- Mirrors GUI:DependsOn, reusing shared helpers
function ExtraGUI:DependsOn(childWidget, parentConfigPath, expectedValue, predicate)
	if K and K.GUIHelpers and K.GUIHelpers.BindDependency then
		return K.GUIHelpers.BindDependency(childWidget, parentConfigPath, expectedValue, predicate)
	end
	return childWidget
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
						SetExtraConfigValue(configPath, newValue, cleanText)

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

	-- Mouse wheel support for fine adjustment
	sliderContainer:EnableMouseWheel(true)
	sliderContainer:SetScript("OnMouseWheel", function(self, delta)
		local newValue = currentValue + (step * delta)
		newValue = max(minVal, min(maxVal, newValue))

		if newValue ~= currentValue then
			currentValue = newValue
			valueText:SetText(tostring(newValue))
			UpdateThumbPosition(newValue)
			SetExtraConfigValue(configPath, newValue, cleanText)

			-- Call hook function if provided
			if hookFunction and type(hookFunction) == "function" then
				hookFunction(newValue, currentValue, configPath)
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

	-- (Removed earlier simple Nameplate Auras registration to avoid duplicate key)

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

		-- Filter Legacy Items Switch
		local legacySwitch = self:CreateSwitch(parent, "Inventory.FilterLegacy", "Filter Legacy Items", "Filter legacy items", UpdateBagStatus)
		legacySwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Filter Primordial Stones Switch
		local stoneSwitch = self:CreateSwitch(parent, "Inventory.FilterStone", "Filter Primordial Stones", "Filter primordial stones", UpdateBagStatus)
		stoneSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Filter Keystone Items Switch
		local keystoneSwitch = self:CreateSwitch(parent, "Inventory.FilterKeystone", "Filter Keystone Items", "Filter Mythic Keystone items", UpdateBagStatus)
		keystoneSwitch:SetPoint("TOPLEFT", 0, yOffset)
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
			SetExtraConfigValue("Inventory.FilterLegacy", false)
			SetExtraConfigValue("Inventory.FilterStone", true)
			SetExtraConfigValue("Inventory.FilterKeystone", true)

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
			legacySwitch:UpdateValue()
			stoneSwitch:UpdateValue()
			keystoneSwitch:UpdateValue()
			gatherEmptySwitch:UpdateValue()
		end)
		resetButton:SetPoint("TOPLEFT", 10, yOffset)
		yOffset = yOffset - 35

		-- Set parent height based on content
		parent:SetHeight(math.abs(yOffset) + 20)
	end, "Inventory Filters")

	-- Provide a small cache for NPC names learned from nearby units
	K.NPCNameCache = K.NPCNameCache or {}

	-- Use K.GetNPCName (NDui-style) for async NPC name resolution
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

		if K.NPCNameCache and K.NPCNameCache[npcID] then
			return K.NPCNameCache[npcID]
		end

		return "Unknown"
	end

	-- Nameplate Custom Units (IDs) Manager
	self:RegisterExtraConfig("Nameplate.CustomUnitList", function(parent)
		local yOffset = -10
		local contentWidth = GetExtraContentWidth()

		-- Header
		local header = parent:CreateFontString(nil, "OVERLAY")
		header:SetFontObject(K.UIFont)
		header:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		header:SetText(L["Custom Units by NPC ID"] or "Custom Units by NPC ID")
		header:SetPoint("TOPLEFT", 10, yOffset)
		yOffset = yOffset - 25

		-- Description
		local desc = parent:CreateFontString(nil, "OVERLAY")
		desc:SetFontObject(K.UIFont)
		desc:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		desc:SetJustifyH("LEFT")
		desc:SetText(L["Add NPC IDs to always color as custom. Defaults are shown and cannot be removed here."] or "Add NPC IDs to always color as custom. Defaults are shown and cannot be removed here.")
		desc:SetPoint("TOPLEFT", 10, yOffset)
		yOffset = yOffset - 25

		-- Add ID input
		local addInput = self:CreateTextInput(parent, nil, (L["Add NPC ID"] or "Add NPC ID"), format(L["e.g. %s"] or "e.g. %s", "174773"), (L["Enter an NPC ID to add"] or "Enter an NPC ID to add"))
		addInput:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Add button (shared helper for consistent styling)
		local addButton
		if K and K.GUIHelpers and K.GUIHelpers.CreateButton then
			addButton = K.GUIHelpers.CreateButton(parent, (L["Add"] or "Add"), 90, 24)
			addButton:SetPoint("TOPLEFT", 0, yOffset)
		else
			addButton = CreateFrame("Button", nil, parent)
			addButton:SetSize(90, 24)
			addButton:SetPoint("TOPLEFT", 0, yOffset)
			local addBg = addButton:CreateTexture(nil, "BACKGROUND")
			addBg:SetAllPoints()
			addBg:SetTexture(C["Media"].Textures.White8x8Texture)
			addBg:SetVertexColor(0.2, 0.6, 0.2, 0.8)
			local addLabel = addButton:CreateFontString(nil, "OVERLAY")
			addLabel:SetFontObject(K.UIFont)
			addLabel:SetTextColor(1, 1, 1, 1)
			addLabel:SetText(L["Add"] or "Add")
			addLabel:SetPoint("CENTER")
		end
		yOffset = yOffset - 35

		-- List header
		CreateSectionHeader(parent, L["Current IDs"] or "Current IDs", contentWidth, yOffset)
		yOffset = yOffset - 40

		-- List container
		local listFrame = CreateFrame("Frame", nil, parent)
		listFrame:SetPoint("TOPLEFT", 10, yOffset)
		listFrame:SetSize(contentWidth - 20, 320)
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

		local rows = {}

		local function parseConfigString()
			local current = tostring(C["Nameplate"].CustomUnitList or "")
			local numeric = {}
			local nonNumeric = {}
			for w in string.gmatch(current, "%S+") do
				local id = tonumber(w)
				if id then
					numeric[id] = true
				else
					table.insert(nonNumeric, w)
				end
			end
			return numeric, nonNumeric
		end

		local function saveNumericSet(numericSet, nonNumericList)
			local ids = {}
			for id in pairs(numericSet) do
				table.insert(ids, id)
			end
			table.sort(ids)
			local parts = {}
			for _, t in ipairs(nonNumericList) do
				table.insert(parts, tostring(t))
			end
			for _, id in ipairs(ids) do
				table.insert(parts, tostring(id))
			end
			local newStr = table.concat(parts, " ")
			-- Persist via config system so it saves to DB
			SetExtraConfigValue("Nameplate.CustomUnitList", newStr)
			local nameplateModule = K:GetModule("Unitframes")
			if nameplateModule and nameplateModule.CreateUnitTable then
				nameplateModule:CreateUnitTable()
			end
		end

		local function getCombinedIds()
			local combined = {}
			-- defaults
			for id in pairs(C.NameplateCustomUnits or {}) do
				combined[id] = "default"
			end
			-- user numeric
			local numeric = select(1, parseConfigString())
			for id in pairs(numeric) do
				combined[id] = combined[id] or "user"
			end
			local list = {}
			for id, src in pairs(combined) do
				table.insert(list, { id = id, source = src })
			end
			table.sort(list, function(a, b)
				return a.id < b.id
			end)
			return list
		end

		local function trySetPortrait(texture, npcID)
			-- Default to question mark if we can't resolve a portrait
			texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
			texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			local function checkUnit(u)
				if UnitExists(u) then
					local guid = UnitGUID(u)
					local id = guid and K.GetNPCID(guid)
					if id and id == npcID then
						SetPortraitTexture(texture, u)
						texture:SetTexCoord(0, 1, 0, 1)
						return true
					end
				end
			end
			-- Common direct tokens
			local directUnits = { "target", "mouseover", "focus" }
			for _, u in ipairs(directUnits) do
				if checkUnit(u) then
					return
				end
			end
			-- Visible nameplates
			for i = 1, 40 do
				if checkUnit("nameplate" .. i) then
					return
				end
			end
			-- Boss units
			for i = 1, 8 do
				if checkUnit("boss" .. i) then
					return
				end
			end
		end

		local function refreshRows()
			for _, r in ipairs(rows) do
				r:Hide()
			end
			wipe(rows)

			local list = getCombinedIds()
			local y = -5
			for _, entry in ipairs(list) do
				local row = CreateFrame("Frame", nil, scrollChild)
				row:SetSize(contentWidth - 40, 28)
				row:SetPoint("TOPLEFT", 10, y)

				local bg = row:CreateTexture(nil, "BACKGROUND")
				bg:SetAllPoints()
				bg:SetTexture(C["Media"].Textures.White8x8Texture)
				bg:SetVertexColor(0.08, 0.08, 0.08, 0.7)

				local portraitFrame = CreateFrame("Frame", nil, row)
				portraitFrame:SetSize(24, 24)
				portraitFrame:SetPoint("LEFT", 6, 0)
				-- Match ProfileGUI portrait styling: background + subtle border + inset texture
				CreateColoredBackground(portraitFrame, 0.12, 0.12, 0.12, 1)
				local portraitBorder = portraitFrame:CreateTexture(nil, "BORDER")
				portraitBorder:SetPoint("TOPLEFT", -1, 1)
				portraitBorder:SetPoint("BOTTOMRIGHT", 1, -1)
				portraitBorder:SetTexture(C["Media"].Textures.White8x8Texture)
				portraitBorder:SetVertexColor(0.3, 0.3, 0.3, 0.8)

				local portrait = portraitFrame:CreateTexture(nil, "ARTWORK")
				portrait:SetPoint("TOPLEFT", 2, -2)
				portrait:SetPoint("BOTTOMRIGHT", -2, 2)
				trySetPortrait(portrait, entry.id)
				row.Portrait = portrait
				row.NpcID = entry.id
				row.Portrait = portrait
				row.NpcID = entry.id

				local nameFS = row:CreateFontString(nil, "OVERLAY")
				nameFS:SetFontObject(K.UIFont)
				nameFS:SetTextColor(1, 1, 1, 1)
				row.NameFS = nameFS
				local function setNameText(nm)
					if row.NameFS then
						row.NameFS:SetText(string.format("%s (ID: %d)%s", nm or "Unknown", entry.id, entry.source == "default" and "  [Default]" or ""))
					end
				end
				local creatureName = GetNPCNameByID(entry.id, setNameText)
				setNameText(creatureName)
				nameFS:SetPoint("LEFT", portraitFrame, "RIGHT", 8, 0)

				if entry.source ~= "default" then
					local removeBtn
					if K and K.GUIHelpers and K.GUIHelpers.CreateButton then
						removeBtn = K.GUIHelpers.CreateButton(row, "", 22, 22)
						removeBtn:SetPoint("RIGHT", -8, 0)
					else
						removeBtn = CreateFrame("Button", nil, row)
						removeBtn:SetSize(22, 22)
						removeBtn:SetPoint("RIGHT", -8, 0)
					end
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
						local numeric, nonNumeric = parseConfigString()
						numeric[entry.id] = nil
						saveNumericSet(numeric, nonNumeric)
						refreshRows()
						PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
					end)
				end

				table.insert(rows, row)
				y = y - 30
			end

			scrollChild:SetHeight(math.abs(y) + 10)
		end

		-- Add button handler
		addButton:SetScript("OnClick", function()
			local inputText = ""
			if addInput and addInput.GetChildren then
				for _, child in ipairs({ addInput:GetChildren() }) do
					if child and child.GetObjectType and child:GetObjectType() == "EditBox" then
						local eb = child
						if eb and eb.GetText then
							inputText = eb:GetText() or ""
						end
						break
					end
				end
			end
			local id = tonumber(inputText)
			if id and id > 0 then
				local numeric, nonNumeric = parseConfigString()
				numeric[id] = true
				saveNumericSet(numeric, nonNumeric)
				refreshRows()
				-- clear input
				if addInput and addInput:GetChildren() then
					for _, child in ipairs({ addInput:GetChildren() }) do
						if child:GetObjectType() == "EditBox" then
							child:SetText("")
							break
						end
					end
				end
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			else
				print("|cffff0000Invalid NPC ID. Enter a number.|r")
			end
		end)

		-- Update portraits and learn names when units are visible
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
						K.NPCNameCache[id] = n
					end
				end
			end
			for _, row in ipairs(rows) do
				if row.Portrait and row.NpcID then
					trySetPortrait(row.Portrait, row.NpcID)
				end
				if row.NameFS then
					local function setText(nm)
						row.NameFS:SetText(string.format("%s (ID: %d)%s", nm or "Unknown", row.NpcID, (C.NameplateCustomUnits and C.NameplateCustomUnits[row.NpcID]) and "  [Default]" or ""))
					end
					local nm = GetNPCNameByID(row.NpcID, setText)
					setText(nm)
				end
			end
		end)

		refreshRows()
		parent:SetHeight(math.abs(yOffset) + 20)
	end, "Custom Units")

	-- Nameplate Power Units (IDs) Manager
	self:RegisterExtraConfig("Nameplate.PowerUnitList", function(parent)
		local yOffset = -10
		local contentWidth = GetExtraContentWidth()

		local header = parent:CreateFontString(nil, "OVERLAY")
		header:SetFontObject(K.UIFont)
		header:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		header:SetText(L["Show Power for NPC IDs"] or "Show Power for NPC IDs")
		header:SetPoint("TOPLEFT", 10, yOffset)
		yOffset = yOffset - 25

		local desc = parent:CreateFontString(nil, "OVERLAY")
		desc:SetFontObject(K.UIFont)
		desc:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		desc:SetJustifyH("LEFT")
		desc:SetText(L["Add NPC IDs whose power bar should be shown on nameplates. Defaults are shown and cannot be removed here."] or "Add NPC IDs whose power bar should be shown on nameplates. Defaults are shown and cannot be removed here.")
		desc:SetPoint("TOPLEFT", 10, yOffset)
		yOffset = yOffset - 25

		local addInput = self:CreateTextInput(parent, nil, (L["Add NPC ID"] or "Add NPC ID"), format(L["e.g. %s"] or "e.g. %s", "114247"), (L["Enter an NPC ID to add"] or "Enter an NPC ID to add"))
		addInput:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local addButton = CreateFrame("Button", nil, parent)
		addButton:SetSize(90, 24)
		addButton:SetPoint("TOPLEFT", 0, yOffset)
		local addBg = addButton:CreateTexture(nil, "BACKGROUND")
		addBg:SetAllPoints()
		addBg:SetTexture(C["Media"].Textures.White8x8Texture)
		addBg:SetVertexColor(0.2, 0.6, 0.2, 0.8)
		local addLabel = addButton:CreateFontString(nil, "OVERLAY")
		addLabel:SetFontObject(K.UIFont)
		addLabel:SetTextColor(1, 1, 1, 1)
		addLabel:SetText(L["Add"] or "Add")
		addLabel:SetPoint("CENTER")
		yOffset = yOffset - 35

		CreateSectionHeader(parent, L["Current IDs"] or "Current IDs", contentWidth, yOffset)
		yOffset = yOffset - 40

		local listFrame = CreateFrame("Frame", nil, parent)
		listFrame:SetPoint("TOPLEFT", 10, yOffset)
		listFrame:SetSize(contentWidth - 20, 320)
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

		local rows = {}

		local function parseConfigString()
			local current = tostring(C["Nameplate"].PowerUnitList or "")
			local numeric = {}
			local nonNumeric = {}
			for w in string.gmatch(current, "%S+") do
				local id = tonumber(w)
				if id then
					numeric[id] = true
				else
					table.insert(nonNumeric, w)
				end
			end
			return numeric, nonNumeric
		end

		local function saveNumericSet(numericSet, nonNumericList)
			local ids = {}
			for id in pairs(numericSet) do
				table.insert(ids, id)
			end
			table.sort(ids)
			local parts = {}
			for _, t in ipairs(nonNumericList) do
				table.insert(parts, tostring(t))
			end
			for _, id in ipairs(ids) do
				table.insert(parts, tostring(id))
			end
			local newStr = table.concat(parts, " ")
			-- Persist via config system so it saves to DB
			SetExtraConfigValue("Nameplate.PowerUnitList", newStr)
			local nameplateModule = K:GetModule("Unitframes")
			if nameplateModule and nameplateModule.CreatePowerUnitTable then
				nameplateModule:CreatePowerUnitTable()
			end
		end

		local function getCombinedIds()
			local combined = {}
			for id in pairs(C.NameplateShowPowerList or {}) do
				combined[id] = "default"
			end
			local numeric = select(1, parseConfigString())
			for id in pairs(numeric) do
				combined[id] = combined[id] or "user"
			end
			local list = {}
			for id, src in pairs(combined) do
				table.insert(list, { id = id, source = src })
			end
			table.sort(list, function(a, b)
				return a.id < b.id
			end)
			return list
		end

		local function trySetPortrait(texture, npcID)
			-- Default to question mark icon (cropped) until a unit match is found
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
			-- Common direct tokens
			local directUnits = { "target", "mouseover", "focus" }
			for _, u in ipairs(directUnits) do
				if checkUnit(u) then
					return
				end
			end
			-- Visible nameplates
			for i = 1, 40 do
				if checkUnit("nameplate" .. i) then
					return
				end
			end
			-- Boss units
			for i = 1, 8 do
				if checkUnit("boss" .. i) then
					return
				end
			end
		end

		local function refreshRows()
			for _, r in ipairs(rows) do
				r:Hide()
			end
			wipe(rows)

			local list = getCombinedIds()
			local y = -5
			for _, entry in ipairs(list) do
				local row = CreateFrame("Frame", nil, scrollChild)
				row:SetSize(contentWidth - 40, 28)
				row:SetPoint("TOPLEFT", 10, y)

				local bg = row:CreateTexture(nil, "BACKGROUND")
				bg:SetAllPoints()
				bg:SetTexture(C["Media"].Textures.White8x8Texture)
				bg:SetVertexColor(0.08, 0.08, 0.08, 0.7)

				local portrait = row:CreateTexture(nil, "ARTWORK")
				portrait:SetSize(22, 22)
				portrait:SetPoint("LEFT", 6, 0)
				trySetPortrait(portrait, entry.id)

				local nameFS = row:CreateFontString(nil, "OVERLAY")
				nameFS:SetFontObject(K.UIFont)
				nameFS:SetTextColor(1, 1, 1, 1)
				row.NameFS = nameFS
				local function setNameText(nm)
					if row.NameFS then
						row.NameFS:SetText(string.format("%s (ID: %d)%s", nm or "Unknown", entry.id, entry.source == "default" and "  [Default]" or ""))
					end
				end
				local creatureName = GetNPCNameByID(entry.id, setNameText)
				setNameText(creatureName)
				nameFS:SetPoint("LEFT", portrait, "RIGHT", 8, 0)

				if entry.source ~= "default" then
					local removeBtn
					if K and K.GUIHelpers and K.GUIHelpers.CreateButton then
						removeBtn = K.GUIHelpers.CreateButton(row, "", 22, 22)
						removeBtn:SetPoint("RIGHT", -8, 0)
					else
						removeBtn = CreateFrame("Button", nil, row)
						removeBtn:SetSize(22, 22)
						removeBtn:SetPoint("RIGHT", -8, 0)
					end
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
						local numeric, nonNumeric = parseConfigString()
						numeric[entry.id] = nil
						saveNumericSet(numeric, nonNumeric)
						refreshRows()
						PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
					end)
				end

				table.insert(rows, row)
				y = y - 30
			end

			scrollChild:SetHeight(math.abs(y) + 10)
		end

		addButton:SetScript("OnClick", function()
			local inputText = ""
			if addInput and addInput:GetChildren() then
				for _, child in ipairs({ addInput:GetChildren() }) do
					if child:GetObjectType() == "EditBox" then
						inputText = child:GetText()
						break
					end
				end
			end
			local id = tonumber(inputText)
			if id and id > 0 then
				local numeric, nonNumeric = parseConfigString()
				numeric[id] = true
				saveNumericSet(numeric, nonNumeric)
				refreshRows()
				if addInput and addInput:GetChildren() then
					for _, child in ipairs({ addInput:GetChildren() }) do
						if child:GetObjectType() == "EditBox" then
							child:SetText("")
							break
						end
					end
				end
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			else
				print("|cffff0000Invalid NPC ID. Enter a number.|r")
			end
		end)

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
						K.NPCNameCache[id] = n
					end
				end
			end
			for _, row in ipairs(rows) do
				if row.Portrait and row.NpcID then
					trySetPortrait(row.Portrait, row.NpcID)
				end
				if row.NameFS then
					local function setText(nm)
						row.NameFS:SetText(string.format("%s (ID: %d)%s", nm or "Unknown", row.NpcID, (C.NameplateShowPowerList and C.NameplateShowPowerList[row.NpcID]) and "  [Default]" or ""))
					end
					local nm = GetNPCNameByID(row.NpcID, setText)
					setText(nm)
				end
			end
		end)

		refreshRows()
		parent:SetHeight(math.abs(yOffset) + 20)
	end, "Power Units")

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

		-- Category Selection Header (match header styling)
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

		-- Category Dropdown
		categoryDropdown = self:CreateDropdown(parent, nil, (L["Select Category"] or "Select Category"), categories, (L["Choose which aura list to manage"] or "Choose which aura list to manage"), function(newValue, oldValue, configPath)
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
		searchLabel:SetText(L["Search Auras:"] or "Search Auras:")
		searchLabel:SetPoint("TOPLEFT", 10, yOffset)
		yOffset = yOffset - 20

		searchInput = self:CreateTextInput(parent, nil, "", (L["Enter Spell ID"] or "Enter Spell ID"), (L["Filter displayed auras"] or "Filter displayed auras"))
		searchInput:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Add New Spell Section
		local addLabel = parent:CreateFontString(nil, "OVERLAY")
		addLabel:SetFontObject(K.UIFont)
		addLabel:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		addLabel:SetText(L["Add New Spell ID:"] or "Add New Spell ID:")
		addLabel:SetPoint("TOPLEFT", 10, yOffset)
		yOffset = yOffset - 20

		-- Create container for input and button
		local addContainer = CreateFrame("Frame", nil, parent)
		addContainer:SetSize(contentWidth, 28)
		addContainer:SetPoint("TOPLEFT", 0, yOffset)

		-- Create smaller text input to make room for button
		addSpellInput = self:CreateTextInput(addContainer, nil, "", (L["Enter Spell ID"] or "Enter Spell ID"), (L["Add a new spell to the current category"] or "Add a new spell to the current category"), nil, false, contentWidth - 110)
		addSpellInput:SetPoint("TOPLEFT", 0, 0)

		-- Create the add button positioned to the right of the input
		local addButton = self:CreateButton(addContainer, (L["Add Spell"] or "Add Spell"), 100, 28, function() end)
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
				print("|cffff0000" .. (L["Invalid Spell ID. Please enter a valid number."] or "Invalid Spell ID. Please enter a valid number.") .. "|r")
			end
		end

		-- Update the add button
		addButton:SetScript("OnClick", addButtonHandler)

		-- Aura List Header
		local listLabel = parent:CreateFontString(nil, "OVERLAY")
		listLabel:SetFontObject(K.UIFont)
		listLabel:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		listLabel:SetText(L["Current Auras:"] or "Current Auras:")
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
		if K and K.GUIHelpers and K.GUIHelpers.AttachSimpleScroll then
			K.GUIHelpers.AttachSimpleScroll(scrollFrame, 30)
		end

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
				GameTooltip:SetText(L["Remove Aura"] or "Remove Aura", 1, 1, 1, 1, true)
				GameTooltip:AddLine(L["Click to remove this aura from the list"] or "Click to remove this aura from the list", 0.7, 0.7, 0.7, true)
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

	-- Player Level Extra Config
	self:RegisterExtraConfig("Unitframe.ShowPlayerLevel", function(parent)
		local yOffset = -10

		-- Hide at Max Level Switch
		local hideMaxLevelSwitch = self:CreateSwitch(parent, "Unitframe.HideMaxPlayerLevel", L["Hide Player Level At Max Level"], L["Automatically hide the player level text when you reach maximum level (80)"])
		hideMaxLevelSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		-- Set parent height based on content
		parent:SetHeight(math.abs(yOffset) + 20)
	end, "Player Level Options")

	-- Simple Party Frames Extra Config (accessed via Party.Enable cogwheel)
	self:RegisterExtraConfig("Party.Enable", function(parent)
		local yOffset = -10
		local contentWidth = GetExtraContentWidth()

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

		local powerBarSwitch = self:CreateSwitch(parent, "SimpleParty.PowerBarShow", L["Show All Power Bars"] or "Show All Power Bars", L["Show power bars on all party frames"] or "Show power bars on all party frames", UpdatePowerBarVisibility)
		powerBarSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local manaBarSwitch = self:CreateSwitch(parent, "SimpleParty.ManabarShow", L["Show Manabars"], L["Display mana bars on party frames"] or "Display mana bars on party frames", UpdatePowerBarVisibility)
		manaBarSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

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
		local debuffHeader = CreateSectionHeader(parent, L["Debuff Watch"] or "Debuff Watch", EXTRA_PANEL_WIDTH - 40, yOffset)
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

	-- Auto-Quest Ignore NPCs Manager
	self:RegisterExtraConfig("Automation.AutoQuestIgnoreNPC", function(parent)
		local yOffset = -10
		local contentWidth = GetExtraContentWidth()

		local header = parent:CreateFontString(nil, "OVERLAY")
		header:SetFontObject(K.UIFont)
		header:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		header:SetText("Ignored Quest NPCs (Per-Character)")
		header:SetPoint("TOPLEFT", 10, yOffset)
		yOffset = yOffset - 25

		local desc = parent:CreateFontString(nil, "OVERLAY")
		desc:SetFontObject(K.UIFont)
		desc:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		desc:SetJustifyH("LEFT")
		desc:SetText("Add NPC IDs to ignore for auto questing. Defaults are built-in; this list is per-character. Hold ALT and click NPC name in quest/gossip to toggle quickly.")
		desc:SetPoint("TOPLEFT", 10, yOffset)
		yOffset = yOffset - 25

		local addInput = self:CreateTextInput(parent, nil, "Add NPC ID", "e.g. 162804", "Enter an NPC ID to add")
		addInput:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local addButton = self:CreateButton(parent, "Add", 90, 24, function() end)
		addButton:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		CreateSectionHeader(parent, "Current IDs", contentWidth, yOffset)
		yOffset = yOffset - 40

		local listFrame = CreateFrame("Frame", nil, parent)
		listFrame:SetPoint("TOPLEFT", 10, yOffset)
		listFrame:SetSize(contentWidth - 20, 300)
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

		local function getStore()
			KkthnxUIDB.Variables[K.Realm] = KkthnxUIDB.Variables[K.Realm] or {}
			KkthnxUIDB.Variables[K.Realm][K.Name] = KkthnxUIDB.Variables[K.Realm][K.Name] or {}
			KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuestIgnoreNPC = KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuestIgnoreNPC or {}
			return KkthnxUIDB.Variables[K.Realm][K.Name].AutoQuestIgnoreNPC
		end

		local function trySetPortrait(texture, npcID)
			-- Fallback to question mark icon (cropped)
			texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
			texture:SetVertexColor(1, 1, 1, 1)
			texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			local function checkUnit(u)
				if UnitExists(u) then
					local guid = UnitGUID(u)
					local id = guid and K.GetNPCID(guid)
					if id and id == npcID then
						SetPortraitTexture(texture, u)
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

		local rows = {}
		local function refresh()
			for _, r in ipairs(rows) do
				r:Hide()
			end
			wipe(rows)
			local store = getStore()
			local defaults = (C and C["AutoQuestData"] and C["AutoQuestData"].IgnoreQuestNPC) or {}
			local combined = {}
			for id in pairs(defaults) do
				combined[tonumber(id) or id] = "default"
			end
			for id, v in pairs(store) do
				if v then
					local nid = tonumber(id) or id
					combined[nid] = combined[nid] or "user"
				end
			end
			local list = {}
			for id, src in pairs(combined) do
				table.insert(list, { id = tonumber(id) or id, source = src })
			end
			table.sort(list, function(a, b)
				return (tonumber(a.id) or 0) < (tonumber(b.id) or 0)
			end)
			local y = -5
			for _, entry in ipairs(list) do
				local row = CreateFrame("Frame", nil, scrollChild)
				row:SetSize(contentWidth - 40, 28)
				row:SetPoint("TOPLEFT", 10, y)
				local bg = row:CreateTexture(nil, "BACKGROUND")
				bg:SetAllPoints()
				bg:SetTexture(C["Media"].Textures.White8x8Texture)
				bg:SetVertexColor(0.08, 0.08, 0.08, 0.7)

				local portrait = row:CreateTexture(nil, "ARTWORK")
				portrait:SetSize(22, 22)
				portrait:SetPoint("LEFT", 6, 0)
				trySetPortrait(portrait, entry.id)
				row.Portrait = portrait
				row.NpcID = entry.id

				local nameFS = row:CreateFontString(nil, "OVERLAY")
				nameFS:SetFontObject(K.UIFont)
				nameFS:SetTextColor(1, 1, 1, 1)
				local tag = entry.source == "default" and "  [Default]" or ""
				local function setNameText(nm)
					nameFS:SetText(string.format("%s (ID: %s)%s", nm or "Unknown", tostring(entry.id), tag))
				end
				local creatureName = GetNPCNameByID and GetNPCNameByID(entry.id, setNameText) or nil
				setNameText(creatureName)
				nameFS:SetPoint("LEFT", portrait, "RIGHT", 8, 0)
				row.NameFS = nameFS

				if entry.source ~= "default" then
					local removeBtn
					if K and K.GUIHelpers and K.GUIHelpers.CreateButton then
						removeBtn = K.GUIHelpers.CreateButton(row, "", 22, 22)
						removeBtn:SetPoint("RIGHT", -8, 0)
					else
						removeBtn = CreateFrame("Button", nil, row)
						removeBtn:SetSize(22, 22)
						removeBtn:SetPoint("RIGHT", -8, 0)
					end
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
						store[tostring(entry.id)] = nil
						if K:GetModule("Automation") and K:GetModule("Automation").UpdateAutoQuestIgnoreList then
							K:GetModule("Automation"):UpdateAutoQuestIgnoreList()
						end
						refresh()
						PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
					end)
				end

				table.insert(rows, row)
				y = y - 30
			end
			scrollChild:SetHeight(math.abs(y) + 10)
		end

		addButton:SetScript("OnClick", function()
			local inputText = ""
			if addInput and addInput:GetChildren() then
				for _, child in ipairs({ addInput:GetChildren() }) do
					if child:GetObjectType() == "EditBox" then
						inputText = child:GetText()
						break
					end
				end
			end
			local id = tonumber(inputText)
			if id and id > 0 then
				local store = getStore()
				store[tostring(id)] = true
				if K:GetModule("Automation") and K:GetModule("Automation").UpdateAutoQuestIgnoreList then
					K:GetModule("Automation"):UpdateAutoQuestIgnoreList()
				end
				refresh()
				if addInput and addInput.GetChildren then
					for _, child in ipairs({ addInput:GetChildren() }) do
						if child and child.GetObjectType and child:GetObjectType() == "EditBox" then
							local eb = child
							if eb and eb.SetText then
								eb:SetText("")
							end
							break
						end
					end
				end
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			else
				print("|cffff0000Invalid NPC ID. Enter a number.|r")
			end
		end)

		-- Update portraits and learn names when units are visible
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
					trySetPortrait(row.Portrait, row.NpcID)
				end
				if row.NpcID and row.NameFS then
					local function setText(nm)
						local tag = (C and C.AutoQuestData and C.AutoQuestData.IgnoreQuestNPC and C.AutoQuestData.IgnoreQuestNPC[row.NpcID]) and "  [Default]" or ""
						row.NameFS:SetText(string.format("%s (ID: %d)%s", nm or "Unknown", row.NpcID, tag))
					end
					local nm = GetNPCNameByID and GetNPCNameByID(row.NpcID, setText)
					setText(nm)
				end
			end
		end)

		refresh()
		parent:SetHeight(360)
	end, "Auto-Quest Ignore NPCs")
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
	editBox:SetSize(120, 16) -- Smaller for extra panel
	editBox:SetPoint("RIGHT", -28, 0) -- Leave space for apply button
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
		-- Only persist and trigger hooks when a configPath is provided
		if configPath then
			SetExtraConfigValue(configPath, newValue, cleanText)
		end
		self:ClearFocus()

		-- Call hook function if provided
		if hookFunction and type(hookFunction) == "function" then
			hookFunction(newValue, widget.PreviousValue or "", configPath)
		end
		widget.PreviousValue = newValue
	end)

	editBox:SetScript("OnEditFocusLost", function(self)
		local newValue = self:GetText()
		-- Only persist and trigger hooks when a configPath is provided
		if configPath then
			SetExtraConfigValue(configPath, newValue, cleanText)
		end

		-- Call hook function if provided
		if hookFunction and type(hookFunction) == "function" then
			hookFunction(newValue, widget.PreviousValue or "", configPath)
		end
		widget.PreviousValue = newValue
	end)

	-- ESC to reset to default for ExtraGUI: fallback to current saved value from C
	editBox:SetScript("OnEscapePressed", function(self)
		-- Prefer default if available; fallback to current stored value in C
		if widget.ConfigPath then
			local defaultValue
			if K.Defaults then
				defaultValue = GetValueByPath(K.Defaults, widget.ConfigPath)
			end
			local revertValue = defaultValue
			if revertValue == nil then
				revertValue = GetValueByPath(C, widget.ConfigPath)
			end
			if revertValue ~= nil then
				editBox:SetText(tostring(revertValue))
				SetExtraConfigValue(widget.ConfigPath, revertValue)
			end
		end
		self:ClearFocus()
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
		-- Only persist when a configPath is provided
		if configPath then
			SetExtraConfigValue(configPath, editBox:GetText(), cleanText)
		end
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

-- Module Exports

-- Export to global for use
K.ExtraGUI = ExtraGUI
_G.KkthnxUI_ExtraGUI = ExtraGUI
