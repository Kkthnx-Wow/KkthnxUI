local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

-- Utility Functions
--

-- Utility functions for handling nested config paths
local function SetValueByPath(table, path, value)
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

	current[keys[#keys]] = value
end

local function GetValueByPath(table, path)
	local keys = { strsplit(".", path) }
	local current = table

	for i = 1, #keys do
		if not current or type(current) ~= "table" or not current[keys[i]] then
			return nil
		end
		current = current[keys[i]]
	end

	return current
end

-- System Documentation

--[[
Real-Time Update Hooks:
Provide hook functions when creating widgets for real-time updates without UI reloads.

Hook Function Signature:
function hookFunction(newValue, oldValue, configPath)
	-- Your real-time update code here
end

Reload System:
- Settings WITH hooks = no reload needed (real-time updates)
- Settings WITHOUT hooks = reload prompt shown when GUI closes
- Manual override with requiresReload=true parameter

Widget Creation:
GUI:CreateSwitch(section, configPath, text, tooltip, hookFunction, isNew, requiresReload)
GUI:CreateSlider(section, configPath, text, min, max, step, tooltip, hookFunction, isNew, requiresReload)
GUI:CreateDropdown(section, configPath, text, options, tooltip, hookFunction, isNew, requiresReload)
GUI:CreateColorPicker(section, configPath, text, tooltip, hookFunction, isNew, requiresReload)
GUI:CreateTextInput(section, configPath, text, placeholder, tooltip, hookFunction, isNew, requiresReload)
GUI:CreateCheckboxGroup(section, configPath, text, options, tooltip, hookFunction, isNew, requiresReload)

New Tag System:
Use IsNew constant to mark new features:
- Category: GUI:AddCategory("ActionBars" .. IsNew, icon)
- Widget: GUI:CreateSwitch(section, "path", "Feature" .. IsNew, tooltip, hook, true)

Hook Utilities:
- GUI:RegisterHook(configPath, hookFunction)
- GUI:UnregisterHook(configPath, hookFunction)
- GUI:TriggerHooks(configPath, newValue, oldValue)

Reload Management:
- GUI:HasPendingReloads()
- GUI:ClearReloadQueue()
- GUI:ForceReloadPrompt()
- GUI:CheckRequiresReload(configPath)
]]

-- Module Initialization

-- Modern GUI System inspired by NDui, enhanced and redesigned for KkthnxUI
local Module = K:NewModule("NewGUI")

-- API Declarations

-- Lua API
local _G = _G
local floor, max, min = math.floor, math.max, math.min
local format, gsub = string.format, string.gsub
local ipairs, pairs, type = ipairs, pairs, type
local tinsert, tremove = table.insert, table.remove

-- WoW API
local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local UIParent = UIParent
local StaticPopupDialogs = StaticPopupDialogs
local SlashCmdList = SlashCmdList
local ReloadUI = ReloadUI

-- WoW Constants
local YES, NO, OKAY, CANCEL, RESET, SETTINGS = YES, NO, OKAY, CANCEL, RESET, SETTINGS

-- Constants

-- New Tag System (from NDui)
local IsNew = "ISNEW"

-- Panel Dimensions
local PANEL_WIDTH = 880
local PANEL_HEIGHT = 640
local SIDEBAR_WIDTH = 200
local CONTENT_WIDTH = PANEL_WIDTH - SIDEBAR_WIDTH - 40
local SPACING = 8
local WIDGET_HEIGHT = 28
local HEADER_HEIGHT = 40
local CATEGORY_HEIGHT = 32

-- Colors (use KkthnxUI's established color system)
local ACCENT_COLOR = { K.r, K.g, K.b }
local BG_COLOR = C["Media"].Backdrops.ColorBackdrop
local SIDEBAR_COLOR = { 0.05, 0.05, 0.05, 0.95 }
local WIDGET_BG = { 0.12, 0.12, 0.12, 0.8 }
local TEXT_COLOR = { 0.9, 0.9, 0.9, 1 }

-- Helper Functions

-- Function to add NEW tag to widgets/categories
local function AddNewTag(parent, anchor)
	local tag = CreateFrame("Frame", nil, parent, "NewFeatureLabelTemplate")
	tag:SetPoint("LEFT", anchor or parent, -29, 11)
	tag:SetScale(0.85) -- Size down the NEW tag
	tag:Show()
	return tag
end

-- Helper function to check and strip NEW tags from names
local function ProcessNewTag(name)
	local cleanName, hasNewTag = gsub(name, IsNew, "")
	return cleanName, (hasNewTag > 0)
end

-- Reload Tracking System

-- Settings without hooks require reload
local ReloadTracker = {
	PendingReloads = {}, -- Settings that have been changed and require reload
	IsShowing = false, -- Prevent multiple popups
	DebugMode = false, -- Disable debug logging since system is working
}

-- Debug logging function
local function DebugLog(message)
	if ReloadTracker.DebugMode then
		print("|cff669DFFKkthnxUI ReloadDebug:|r " .. message)
	end
end

-- Simple reload logic: only settings without hooks need reloads
local function RequiresReload(configPath, hasHook, forceReload)
	DebugLog("RequiresReload check for: " .. configPath .. " (hasHook: " .. tostring(hasHook) .. ", forceReload: " .. tostring(forceReload) .. ")")

	-- If explicitly forced
	if forceReload then
		DebugLog("Reload required: explicitly forced")
		return true
	end

	-- If no hook function provided, setting can't update in real-time
	if not hasHook then
		DebugLog("Reload required: no hook available")
		return true
	end

	-- Has hook = no reload needed (real-time updates work)
	DebugLog("No reload needed: hook available for real-time updates")
	return false
end

-- Add a setting to reload queue
local function AddToReloadQueue(configPath, settingName)
	DebugLog("Adding to reload queue: " .. configPath .. " (" .. (settingName or configPath) .. ")")

	if not ReloadTracker.PendingReloads[configPath] then
		ReloadTracker.PendingReloads[configPath] = settingName or configPath

		-- Show reload prompt immediately (no delay)
		if not ReloadTracker.IsShowing then
			DebugLog("Showing reload prompt immediately")
			ReloadTracker:ShowReloadPrompt()
		end
	else
		DebugLog("Setting already in reload queue: " .. configPath)
	end
end

-- Show reload prompt with details
function ReloadTracker:ShowReloadPrompt()
	DebugLog("ShowReloadPrompt called")

	if self.IsShowing then
		DebugLog("Reload prompt already showing, skipping")
		return
	end

	if not next(self.PendingReloads) then
		DebugLog("No pending reloads, skipping prompt")
		return
	end

	self.IsShowing = true

	-- Count how many settings need reload
	local count = 0
	for _ in pairs(self.PendingReloads) do
		count = count + 1
	end

	local message
	if count == 1 then
		local _, settingName = next(self.PendingReloads)
		message = format("The setting '%s' requires a UI reload to take effect.\n\nReload now?", settingName)
	else
		message = format("%d settings have been changed that require a UI reload.\n\nReload now?", count)
	end

	DebugLog("Showing reload prompt: " .. message)

	-- Use our existing popup
	StaticPopupDialogs["KKTHNXUI_RELOAD_UI"].text = message
	StaticPopup_Show("KKTHNXUI_RELOAD_UI")
end

-- Clear reload queue
function ReloadTracker:ClearQueue()
	DebugLog("Clearing reload queue")
	self.PendingReloads = {}
	self.IsShowing = false
end

-- Check if we have pending reloads
function ReloadTracker:HasPendingReloads()
	local hasReloads = next(self.PendingReloads) ~= nil
	DebugLog("HasPendingReloads: " .. tostring(hasReloads))
	return hasReloads
end

-- Only show reload prompt on GUI close if there are pending reloads
function ReloadTracker:OnGUIClose()
	DebugLog("OnGUIClose called")
	if self:HasPendingReloads() and not self.IsShowing then
		DebugLog("Showing reload prompt on GUI close")
		-- Show reload prompt when closing GUI if there are pending reloads
		C_Timer.After(0.1, function()
			self:ShowReloadPrompt()
		end)
	else
		DebugLog("No reload prompt needed on GUI close")
	end
end

-- GUI Framework Core

-- GUI Framework (attached to Module instead of global)
Module.GUI = {
	Frame = nil,
	Sidebar = nil,
	Content = nil,
	Categories = {},
	Widgets = {},
	ActiveCategory = nil,
	ScrollFrame = nil,
	IsVisible = false,
	-- REAL-TIME UPDATE HOOKS REGISTRY
	UpdateHooks = {},
	-- RELOAD TRACKER REFERENCE
	ReloadTracker = ReloadTracker,
}

-- Convenience reference
local GUI = Module.GUI

-- Real-Time Update Hook System

local function RegisterUpdateHook(configPath, hookFunction)
	DebugLog("Registering hook for: " .. configPath .. " (function type: " .. type(hookFunction) .. ")")

	if not GUI.UpdateHooks[configPath] then
		GUI.UpdateHooks[configPath] = {}
	end
	tinsert(GUI.UpdateHooks[configPath], hookFunction)
	DebugLog("Hook registered. Total hooks for " .. configPath .. ": " .. #GUI.UpdateHooks[configPath])
end

local function ExecuteUpdateHooks(configPath, newValue, oldValue)
	DebugLog("Executing hooks for: " .. configPath .. " (new: " .. tostring(newValue) .. ", old: " .. tostring(oldValue) .. ")")

	if GUI.UpdateHooks[configPath] then
		DebugLog("Found " .. #GUI.UpdateHooks[configPath] .. " hooks for " .. configPath)
		for i, hookFunc in ipairs(GUI.UpdateHooks[configPath]) do
			if type(hookFunc) == "function" then
				DebugLog("Executing hook " .. i .. " for " .. configPath)
				local success, err = pcall(hookFunc, newValue, oldValue, configPath)
				if not success then
					DebugLog("Hook " .. i .. " failed for " .. configPath .. ": " .. tostring(err))
				else
					DebugLog("Hook " .. i .. " executed successfully for " .. configPath)
				end
			else
				DebugLog("Hook " .. i .. " is not a function for " .. configPath .. " (type: " .. type(hookFunc) .. ")")
			end
		end
	else
		DebugLog("No hooks found for: " .. configPath)
	end
end

-- Configuration Functions

-- Get configuration value by path
local function GetConfigValue(configPath)
	return GetValueByPath(C, configPath)
end

-- Get default value for a config path from K.Defaults
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

-- Forward declaration of SetConfigValue so ResetToDefault can call it
local SetConfigValue

-- Set configuration value with hook execution and reload tracking
function SetConfigValue(configPath, value, requiresReload, settingName)
	DebugLog("SetConfigValue called: " .. configPath .. " = " .. tostring(value) .. " (requiresReload: " .. tostring(requiresReload) .. ")")

	-- Get old value for hook comparison
	local oldValue = GetValueByPath(C, configPath)
	DebugLog("Old value: " .. tostring(oldValue))

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
	else
		-- Database not yet available, settings will only be stored in runtime config
		-- This is normal during initial loading
		DebugLog("Database not available, only storing in runtime config")
	end

	-- Execute real-time update hooks
	if oldValue ~= value then
		DebugLog("Value changed, executing hooks")
		ExecuteUpdateHooks(configPath, value, oldValue)

		-- Check for reload requirement (simple: no hook = needs reload)
		local hasHook = GUI.UpdateHooks[configPath] and #GUI.UpdateHooks[configPath] > 0
		DebugLog("Hook check for " .. configPath .. ": " .. tostring(hasHook) .. " (hooks count: " .. (GUI.UpdateHooks[configPath] and #GUI.UpdateHooks[configPath] or 0) .. ")")

		if RequiresReload(configPath, hasHook, requiresReload) then
			DebugLog("Reload required for: " .. configPath)
			AddToReloadQueue(configPath, settingName or configPath)
		else
			DebugLog("No reload required for: " .. configPath)
		end
	else
		DebugLog("Value unchanged, skipping hook execution and reload check")
	end
end

-- Reset setting to default value with improved feedback
local function ResetToDefault(configPath, widget, settingName)
	local defaultValue = GetDefaultValue(configPath)
	if defaultValue == nil then
		-- No default found, show warning
		print("|cffff6b6bKkthnxUI:|r No default value found for " .. (settingName or configPath))
		return false
	end

	local currentValue = GetConfigValue(configPath)
	if currentValue == defaultValue then
		-- Already at default, provide feedback
		print("|cff669DFFKkthnxUI:|r " .. (settingName or configPath) .. " is already at default value")
		return false
	end

	-- Set to default value
	SetConfigValue(configPath, defaultValue, false, settingName)

	-- Update widget display
	if widget and widget.UpdateValue then
		widget:UpdateValue()
	end

	-- Visual feedback - brief highlight
	if widget then
		local originalBg = widget.KKUI_Background or widget:GetChildren()[1]
		if originalBg and originalBg.SetVertexColor then
			-- Brief green flash to indicate reset
			originalBg:SetVertexColor(0.3, 0.9, 0.3, 0.6)
			C_Timer.After(0.2, function()
				originalBg:SetVertexColor(WIDGET_BG[1], WIDGET_BG[2], WIDGET_BG[3], WIDGET_BG[4])
			end)
		end
	end

	-- Audio feedback
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

	-- Console feedback
	print("|cff669DFFKkthnxUI:|r Reset " .. (settingName or configPath) .. " to default")

	return true
end

-- Helper Widget Functions

-- Create colored background texture
local function CreateColoredBackground(frame, r, g, b, a)
	local bg = frame:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(C["Media"].Textures.White8x8Texture)
	bg:SetVertexColor(r or 0, g or 0, b or 0, a or 0.8)
	return bg
end

-- Create basic button widget
local function CreateButton(parent, text, width, height, onClick)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(width or 120, height or WIDGET_HEIGHT)

	-- Clean button background
	local buttonBg = button:CreateTexture(nil, "BACKGROUND")
	buttonBg:SetAllPoints()
	buttonBg:SetTexture(C["Media"].Textures.White8x8Texture)
	buttonBg:SetVertexColor(0.15, 0.15, 0.15, 1)
	button.KKUI_Background = buttonBg

	-- Subtle border for depth
	local buttonBorder = button:CreateTexture(nil, "BORDER")
	buttonBorder:SetPoint("TOPLEFT", -1, 1)
	buttonBorder:SetPoint("BOTTOMRIGHT", 1, -1)
	buttonBorder:SetTexture(C["Media"].Textures.White8x8Texture)
	buttonBorder:SetVertexColor(0.3, 0.3, 0.3, 0.8)
	button.KKUI_Border = buttonBorder

	-- Hover effects for clean design
	button:SetScript("OnEnter", function(self)
		self.KKUI_Background:SetVertexColor(ACCENT_COLOR[1] * 0.8, ACCENT_COLOR[2] * 0.8, ACCENT_COLOR[3] * 0.8, 1)
		self.KKUI_Border:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		if self.Text then
			self.Text:SetTextColor(1, 1, 1, 1)
		end
	end)

	button:SetScript("OnLeave", function(self)
		self.KKUI_Background:SetVertexColor(0.15, 0.15, 0.15, 1)
		self.KKUI_Border:SetVertexColor(0.3, 0.3, 0.3, 0.8)
		if self.Text then
			self.Text:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		end
	end)

	-- Click effect
	button:SetScript("OnMouseDown", function(self)
		self.KKUI_Background:SetVertexColor(ACCENT_COLOR[1] * 0.6, ACCENT_COLOR[2] * 0.6, ACCENT_COLOR[3] * 0.6, 1)
	end)

	button:SetScript("OnMouseUp", function(self)
		if self:IsMouseOver() then
			self.KKUI_Background:SetVertexColor(ACCENT_COLOR[1] * 0.8, ACCENT_COLOR[2] * 0.8, ACCENT_COLOR[3] * 0.8, 1)
		else
			self.KKUI_Background:SetVertexColor(0.15, 0.15, 0.15, 1)
		end
	end)

	-- Button text
	button.Text = button:CreateFontString(nil, "OVERLAY")
	button.Text:SetFontObject(K.UIFont)
	button.Text:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	button.Text:SetText(text)
	button.Text:SetPoint("CENTER")

	if onClick then
		button:SetScript("OnClick", onClick)
	end

	return button
end

-- Enhanced Features Functions (moved here to be available when needed)
local function CreateEnhancedTooltip(widget, title, description, warning)
	widget:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(title, 1, 1, 1, 1, true)

		if description then
			GameTooltip:AddLine(description, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
		end

		if warning then
			GameTooltip:AddLine(" ", 1, 1, 1)
			GameTooltip:AddLine("|cffff6b6bWarning:|r " .. warning, 1, 1, 1, true)
		end

		-- Add reset to default information
		GameTooltip:AddLine(" ", 1, 1, 1)
		GameTooltip:AddLine("|cff00ff00Tip:|r Hold Ctrl to show reset button, then click to reset to default", 0.7, 0.7, 0.7, true)

		GameTooltip:Show()
	end)

	widget:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

local function CreateSearchBox(parent)
	local searchFrame = CreateFrame("Frame", nil, parent)
	searchFrame:SetSize(SIDEBAR_WIDTH - 20, 30)
	searchFrame:SetPoint("TOP", 0, -10)

	local searchBox = CreateFrame("EditBox", nil, searchFrame)
	searchBox:SetAllPoints()
	searchBox:SetFontObject(K.UIFont)
	searchBox:SetAutoFocus(false)
	searchBox:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	-- Keyboard handling improvements
	searchBox:EnableKeyboard(true)
	if searchBox.SetPropagateKeyboardInput then
		searchBox:SetPropagateKeyboardInput(false)
	end

	-- Subtle background instead of border
	local searchBg = searchFrame:CreateTexture(nil, "BACKGROUND")
	searchBg:SetAllPoints()
	searchBg:SetTexture(C["Media"].Textures.White8x8Texture)
	searchBg:SetVertexColor(0.1, 0.1, 0.1, 0.6)

	local searchIcon = searchFrame:CreateTexture(nil, "ARTWORK")
	searchIcon:SetAtlas("common-search-magnifyingglass")
	searchIcon:SetSize(12, 12)
	searchIcon:SetPoint("LEFT", 6, 0)
	searchIcon:SetVertexColor(0.5, 0.5, 0.5, 1)

	-- Placeholder text
	local placeholderText = searchBox:CreateFontString(nil, "OVERLAY")
	placeholderText:SetFontObject(K.UIFont)
	placeholderText:SetTextColor(0.5, 0.5, 0.5, 1)
	placeholderText:SetText(SEARCH)
	placeholderText:SetPoint("LEFT", searchIcon, "RIGHT", 6, 0)

	searchBox:SetScript("OnTextChanged", function(self)
		local text = self:GetText()
		if text == "" then
			placeholderText:Show()
			searchIcon:Show()
		else
			placeholderText:Hide()
			searchIcon:Hide()
		end
		GUI:FilterCategories(text)
	end)

	-- Helper: show first visible category
	local function ShowFirstVisibleCategory()
		for idx, category in ipairs(GUI.Categories) do
			if category.Button and category.Button:IsShown() then
				GUI:ShowCategory(category)
				-- Scroll to it
				if GUI.CategoryScrollFrame then
					local step = CATEGORY_HEIGHT + 2
					GUI.CategoryScrollFrame:SetVerticalScroll(math.max(0, (idx - 1) * step))
				end
				return
			end
		end
	end

	-- Helper: navigate visible categories by delta (-1 or +1)
	local function NavigateCategory(delta)
		local visible = {}
		for i, cat in ipairs(GUI.Categories) do
			if cat.Button and cat.Button:IsShown() then
				table.insert(visible, { i = i, cat = cat })
			end
		end
		if #visible == 0 then
			return
		end
		local currentIdx = 1
		if GUI.CurrentCategory then
			for pos, item in ipairs(visible) do
				if item.cat == GUI.CurrentCategory then
					currentIdx = pos
					break
				end
			end
		end
		local targetPos = currentIdx + delta
		if targetPos < 1 then
			targetPos = 1
		end
		if targetPos > #visible then
			targetPos = #visible
		end
		local target = visible[targetPos]
		if target then
			GUI:ShowCategory(target.cat)
			if GUI.CategoryScrollFrame then
				local step = CATEGORY_HEIGHT + 2
				GUI.CategoryScrollFrame:SetVerticalScroll(math.max(0, (target.i - 1) * step))
			end
		end
	end

	-- Enter selects first visible; Esc clears search and restores focus
	searchBox:SetScript("OnEnterPressed", function(self)
		ShowFirstVisibleCategory()
		self:ClearFocus()
	end)

	searchBox:SetScript("OnEscapePressed", function(self)
		self:SetText("")
		placeholderText:Show()
		searchIcon:Show()
		GUI:FilterCategories("")
		self:ClearFocus()
	end)

	-- Up/Down arrow navigation through visible categories
	searchBox:SetScript("OnKeyDown", function(self, key)
		if key == "UP" then
			NavigateCategory(-1)
			return
		end
		if key == "DOWN" then
			NavigateCategory(1)
			return
		end
	end)

	searchBox:SetScript("OnEditFocusGained", function()
		placeholderText:Hide()
		searchIcon:Hide()
		-- Add subtle glow effect on focus
		searchBg:SetVertexColor(0.15, 0.15, 0.15, 0.8)
	end)

	searchBox:SetScript("OnEditFocusLost", function(self)
		if self:GetText() == "" then
			placeholderText:Show()
			searchIcon:Show()
		end
		-- Return to normal
		searchBg:SetVertexColor(0.1, 0.1, 0.1, 0.6)
	end)

	return searchBox
end

-- Reset To Default System

-- Global Ctrl key checker for reset buttons (prevents conflicts with widget scripts)
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
-- Disabled by default; enabled while GUI is visible
CtrlChecker:SetScript("OnUpdate", nil)

-- NEW: Helper function to add reset-to-default functionality to widget labels
local function AddResetToDefaultFunctionality(widget, label, configPath, cleanText)
	-- Create reset button with undo icon
	local resetButton = CreateFrame("Button", nil, widget)
	resetButton:SetSize(16, 16)

	-- Check if there's a cogwheel icon and position accordingly
	local baseXOffset = 5 -- Default offset from label

	-- Check if ExtraGUI cogwheel exists for this config path
	local hasExtra = false
	if K.ExtraGUI then
		if K.ExtraGUI.HasExtraConfig and K.ExtraGUI:HasExtraConfig(configPath) then
			hasExtra = true
		else
			-- Also account for buffer inputs that end with "Input" and map to a real config path
			if type(configPath) == "string" then
				local stripped = configPath:gsub("Input$", "")
				if stripped ~= configPath and K.ExtraGUI.HasExtraConfig and K.ExtraGUI:HasExtraConfig(stripped) then
					hasExtra = true
				end
			end
		end
	end
	if hasExtra then
		-- Position further right to avoid overlapping with cogwheel (26px wide + some spacing)
		baseXOffset = 26
	end

	resetButton:SetPoint("LEFT", label, "RIGHT", baseXOffset, 0)
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
		GameTooltip:SetText("Reset to Default", 1, 1, 1, 1, true)
		GameTooltip:AddLine("Click to reset this setting to its default value", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
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

	-- Register with global checker (no conflicts with widget scripts!)
	resetButtons[widget] = resetButton

	return resetButton
end

-- Widget Creation Functions

-- Widget Creation Functions
local function CreateSwitch(parent, configPath, text, tooltip, hookFunction, isNew, requiresReload)
	local widget = CreateFrame("Frame", nil, parent)
	widget:SetSize(CONTENT_WIDTH, WIDGET_HEIGHT)
	widget.ConfigPath = configPath

	-- Background
	CreateColoredBackground(widget, WIDGET_BG[1], WIDGET_BG[2], WIDGET_BG[3], WIDGET_BG[4])

	-- Process NEW tag from text
	local cleanText, hasNewTag = ProcessNewTag(text)
	-- Use isNew parameter or detected NEW tag
	local showNewTag = isNew or hasNewTag

	-- Store NEW tag information for category detection
	widget.IsNew = showNewTag
	widget.HasNewTag = showNewTag

	-- Label
	local label = widget:CreateFontString(nil, "OVERLAY")
	label:SetFontObject(K.UIFont)
	label:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	label:SetText(cleanText) -- Use clean text without NEW tag
	label:SetPoint("LEFT", 8, 0)
	widget.DisplayText = cleanText
	-- Right-click label to copy config path
	label:EnableMouse(true)
	label:SetScript("OnMouseUp", function(_, btn)
		if btn == "RightButton" and configPath then
			StaticPopupDialogs["KKTHNXUI_COPY_PATH"].text = "Config Path:\n" .. configPath
			StaticPopup_Show("KKTHNXUI_COPY_PATH", configPath)
		end
	end)

	-- Add reset-to-default functionality with undo icon
	AddResetToDefaultFunctionality(widget, label, configPath, cleanText)

	-- Add NEW tag if specified
	if showNewTag then
		AddNewTag(widget, label)
	end

	-- Switch Button
	local switchButton = CreateFrame("Button", nil, widget)
	switchButton:SetSize(40, 16)
	switchButton:SetPoint("RIGHT", -8, 0)

	-- Switch Background
	local switchBg = switchButton:CreateTexture(nil, "BACKGROUND")
	switchBg:SetAllPoints()
	switchBg:SetTexture(C["Media"].Textures.White8x8Texture)
	switchBg:SetVertexColor(0.3, 0.3, 0.3, 1)

	-- Switch Thumb
	local thumb = switchButton:CreateTexture(nil, "OVERLAY")
	thumb:SetSize(14, 18)
	thumb:SetTexture(C["Media"].Textures.White8x8Texture)
	thumb:SetVertexColor(1, 1, 1, 1)

	-- Tooltip functionality (now added)
	if tooltip then
		widget:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(cleanText, 1, 1, 1, 1, true)
			GameTooltip:AddLine(tooltip, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
			GameTooltip:Show()
		end)

		widget:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	end

	-- REGISTER HOOK FUNCTION FOR REAL-TIME UPDATES
	DebugLog("CreateSwitch: Checking hook for " .. configPath .. " (hookFunction type: " .. type(hookFunction) .. ")")
	if hookFunction and type(hookFunction) == "function" then
		DebugLog("CreateSwitch: Registering hook for " .. configPath)
		RegisterUpdateHook(configPath, hookFunction)
		widget.HookFunction = hookFunction
	else
		DebugLog("CreateSwitch: No hook provided for " .. configPath)
	end

	-- Hover effect for switch
	switchButton:SetScript("OnEnter", function(self)
		if GetConfigValue(configPath) then
			switchBg:SetVertexColor(ACCENT_COLOR[1] * 1.1, ACCENT_COLOR[2] * 1.1, ACCENT_COLOR[3] * 1.1, 1)
		else
			switchBg:SetVertexColor(0.4, 0.4, 0.4, 1)
		end
	end)

	switchButton:SetScript("OnLeave", function(self)
		local value = GetConfigValue(configPath)
		if value then
			switchBg:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		else
			switchBg:SetVertexColor(0.3, 0.3, 0.3, 1)
		end
	end)

	-- Update function
	function widget:UpdateValue()
		local value = GetConfigValue(self.ConfigPath)
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

	-- Enhanced Click handler with immediate hook execution and reload tracking
	switchButton:SetScript("OnClick", function()
		local currentValue = GetConfigValue(configPath)
		local newValue = not currentValue

		-- SetConfigValue will automatically trigger hooks and handle reload tracking
		SetConfigValue(configPath, newValue, requiresReload, cleanText)
		widget:UpdateValue()

		-- Play feedback sound
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end)

	-- Add cogwheel icon if extra configuration exists
	local extraPath = configPath
	if K.ExtraGUI then
		if type(extraPath) == "string" and not (K.ExtraGUI.HasExtraConfig and K.ExtraGUI:HasExtraConfig(extraPath)) then
			local stripped = extraPath:gsub("Input$", "")
			if stripped ~= extraPath and K.ExtraGUI.HasExtraConfig and K.ExtraGUI:HasExtraConfig(stripped) then
				extraPath = stripped
			end
		end
		if K.ExtraGUI.HasExtraConfig and K.ExtraGUI:HasExtraConfig(extraPath) then
			K.ExtraGUI:CreateCogwheelIcon(widget, extraPath, cleanText)
		end
	end

	-- Initialize
	widget:UpdateValue()

	return widget
end

local function CreateSlider(parent, configPath, text, minVal, maxVal, step, tooltip, hookFunction, isNew, requiresReload)
	local widget = CreateFrame("Frame", nil, parent)
	widget:SetSize(CONTENT_WIDTH, WIDGET_HEIGHT)
	widget.ConfigPath = configPath

	-- Background
	CreateColoredBackground(widget, WIDGET_BG[1], WIDGET_BG[2], WIDGET_BG[3], WIDGET_BG[4])

	-- Process NEW tag from text
	local cleanText, hasNewTag = ProcessNewTag(text)
	-- Use isNew parameter or detected NEW tag
	local showNewTag = isNew or hasNewTag

	-- Store NEW tag information for category detection
	widget.IsNew = showNewTag
	widget.HasNewTag = showNewTag

	-- Label
	local label = widget:CreateFontString(nil, "OVERLAY")
	label:SetFontObject(K.UIFont)
	label:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	label:SetText(cleanText) -- Use clean text without NEW tag
	label:SetPoint("LEFT", 8, 0)

	-- Make label clickable for reset functionality
	local labelButton = CreateFrame("Button", nil, widget)
	labelButton:SetAllPoints(label)
	labelButton:SetScript("OnClick", function(self, button)
		if button == "LeftButton" and IsControlKeyDown() then
			ResetToDefault(configPath, widget, cleanText)
		end
	end)

	-- Add reset-to-default functionality with undo icon
	AddResetToDefaultFunctionality(widget, label, configPath, cleanText)

	-- Add NEW tag if specified
	if showNewTag then
		AddNewTag(widget, label)
	end

	-- REGISTER HOOK FUNCTION FOR REAL-TIME UPDATES
	if hookFunction and type(hookFunction) == "function" then
		RegisterUpdateHook(configPath, hookFunction)
		widget.HookFunction = hookFunction
	end

	-- Value Display
	local valueText = widget:CreateFontString(nil, "OVERLAY")
	valueText:SetFontObject(K.UIFont)
	valueText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	valueText:SetPoint("RIGHT", -8, 0)

	-- Custom Slider Container
	local sliderContainer = CreateFrame("Frame", nil, widget)
	sliderContainer:SetSize(120, 16)
	sliderContainer:SetPoint("RIGHT", -50, 0)

	-- Slider Track Background
	local sliderTrack = sliderContainer:CreateTexture(nil, "BACKGROUND")
	sliderTrack:SetAllPoints()
	sliderTrack:SetTexture(C["Media"].Textures.White8x8Texture)
	sliderTrack:SetVertexColor(0.2, 0.2, 0.2, 1)

	-- Custom Thumb Frame (this fixes the movement issue)
	local thumbFrame = CreateFrame("Frame", nil, sliderContainer)
	thumbFrame:SetSize(12, 16)
	thumbFrame:EnableMouse(true)

	-- Thumb Texture
	local thumbTexture = thumbFrame:CreateTexture(nil, "OVERLAY")
	thumbTexture:SetAllPoints()
	thumbTexture:SetTexture(C["Media"].Textures.White8x8Texture)
	thumbTexture:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)

	-- Thumb Border for better visibility
	local thumbBorder = thumbFrame:CreateTexture(nil, "BORDER")
	thumbBorder:SetPoint("TOPLEFT", -1, 1)
	thumbBorder:SetPoint("BOTTOMRIGHT", 1, -1)
	thumbBorder:SetTexture(C["Media"].Textures.White8x8Texture)
	thumbBorder:SetVertexColor(0.4, 0.4, 0.4, 0.8)

	-- Store current value and state
	local currentValue = minVal
	local committedValue = GetConfigValue(configPath) or minVal
	local isDragging = false
	local isUpdating = false

	-- Function to calculate thumb position from value
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

	-- Function to calculate value from mouse position
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
		return floor(rawValue / step + 0.5) * step
	end

	-- Enhanced Update function
	function widget:UpdateValue()
		if isUpdating then
			return
		end
		isUpdating = true

		local value = GetConfigValue(self.ConfigPath) or minVal

		-- TYPE SAFETY: Handle non-numeric values
		if type(value) == "boolean" then
			-- Convert boolean to appropriate numeric value
			value = value and maxVal or minVal
		elseif type(value) ~= "number" then
			-- For any other type, use the minimum value as default
			value = minVal
		end

		-- Ensure value is within bounds
		value = max(minVal, min(maxVal, value))

		currentValue = value
		committedValue = value
		valueText:SetText(tostring(value))
		UpdateThumbPosition(value)

		isUpdating = false
	end

	-- Enhanced hover effects
	thumbFrame:SetScript("OnEnter", function(self)
		thumbTexture:SetVertexColor(ACCENT_COLOR[1] * 1.2, ACCENT_COLOR[2] * 1.2, ACCENT_COLOR[3] * 1.2, 1)
		thumbBorder:SetVertexColor(ACCENT_COLOR[1] * 0.8, ACCENT_COLOR[2] * 0.8, ACCENT_COLOR[3] * 0.8, 1)
	end)

	thumbFrame:SetScript("OnLeave", function(self)
		if not isDragging then
			thumbTexture:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
			thumbBorder:SetVertexColor(0.4, 0.4, 0.4, 0.8)
		end
	end)

	-- Drag functionality with real-time hook execution and reload tracking
	thumbFrame:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			isDragging = true
			local lastUpdate = 0
			local sinceLastCommit = 0
			-- More efficient OnUpdate: throttled and with early exit conditions
			self:SetScript("OnUpdate", function(self, elapsed)
				if not isDragging then
					self:SetScript("OnUpdate", nil)
					return
				end

				-- Throttle updates to ~30fps instead of full framerate
				lastUpdate = lastUpdate + elapsed
				if lastUpdate < 0.033 then
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

				-- Coalesce config writes while dragging: commit at most ~8 times/sec
				if not isUpdating and currentValue ~= committedValue and sinceLastCommit >= 0.12 then
					SetConfigValue(configPath, currentValue, requiresReload, cleanText)
					committedValue = currentValue
					sinceLastCommit = 0
				end
			end)
		end
	end)

	thumbFrame:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" and isDragging then
			isDragging = false
			self:SetScript("OnUpdate", nil)

			-- Final save and visual update with hook execution and reload tracking
			if currentValue ~= committedValue then
				SetConfigValue(configPath, currentValue, requiresReload, cleanText)
				committedValue = currentValue
			end
			thumbTexture:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
			thumbBorder:SetVertexColor(0.4, 0.4, 0.4, 0.8)

			-- Play feedback sound
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end
	end)

	-- Click on track to jump to position with hook execution and reload tracking
	sliderContainer:EnableMouse(true)
	sliderContainer:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" and not isDragging then
			local x = GetCursorPosition()
			local scale = UIParent:GetEffectiveScale()
			x = x / scale

			local newValue = GetValueFromPosition(x)
			currentValue = newValue
			valueText:SetText(tostring(newValue))
			UpdateThumbPosition(newValue)
			SetConfigValue(configPath, newValue, requiresReload, cleanText)
			committedValue = newValue

			-- Play feedback sound
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end
	end)

	-- Mouse wheel support for fine adjustment with hook execution and reload tracking
	sliderContainer:EnableMouseWheel(true)
	sliderContainer:SetScript("OnMouseWheel", function(self, delta)
		local newValue = currentValue + (step * delta)
		newValue = max(minVal, min(maxVal, newValue))

		if newValue ~= currentValue then
			currentValue = newValue
			valueText:SetText(tostring(newValue))
			UpdateThumbPosition(newValue)
			SetConfigValue(configPath, newValue, requiresReload, cleanText)
			committedValue = newValue

			-- Play feedback sound
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end
	end)

	-- Tooltip support
	if tooltip then
		CreateEnhancedTooltip(widget, cleanText, tooltip .. "\n\nTip: Use mouse wheel for fine adjustment!")
	end

	-- Add cogwheel icon if extra configuration exists
	local extraPath = configPath
	if K.ExtraGUI then
		if type(extraPath) == "string" and not (K.ExtraGUI.HasExtraConfig and K.ExtraGUI:HasExtraConfig(extraPath)) then
			local stripped = extraPath:gsub("Input$", "")
			if stripped ~= extraPath and K.ExtraGUI.HasExtraConfig and K.ExtraGUI:HasExtraConfig(stripped) then
				extraPath = stripped
			end
		end
		if K.ExtraGUI.HasExtraConfig and K.ExtraGUI:HasExtraConfig(extraPath) then
			K.ExtraGUI:CreateCogwheelIcon(widget, extraPath, cleanText)
		end
	end

	-- Initialize
	widget:UpdateValue()

	-- Store references for external access
	widget.Slider = sliderContainer
	widget.Thumb = thumbFrame
	widget.GetValue = function()
		return currentValue
	end
	widget.SetValue = function(value)
		currentValue = max(minVal, min(maxVal, value))
		valueText:SetText(tostring(currentValue))
		UpdateThumbPosition(currentValue)
		SetConfigValue(configPath, currentValue, requiresReload, cleanText)
	end

	return widget
end

local function CreateDropdown(parent, configPath, text, options, tooltip, hookFunction, isNew, requiresReload)
	local widget = CreateFrame("Frame", nil, parent)
	widget:SetSize(CONTENT_WIDTH, WIDGET_HEIGHT)
	widget.ConfigPath = configPath

	-- Background
	CreateColoredBackground(widget, WIDGET_BG[1], WIDGET_BG[2], WIDGET_BG[3], WIDGET_BG[4])

	-- Process NEW tag from text
	local cleanText, hasNewTag = ProcessNewTag(text)
	-- Use isNew parameter or detected NEW tag
	local showNewTag = isNew or hasNewTag

	-- Store NEW tag information for category detection
	widget.IsNew = showNewTag
	widget.HasNewTag = showNewTag

	-- Label
	local label = widget:CreateFontString(nil, "OVERLAY")
	label:SetFontObject(K.UIFont)
	label:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	label:SetText(cleanText) -- Use clean text without NEW tag
	label:SetPoint("LEFT", 8, 0)

	-- Make label clickable for reset functionality
	local labelButton = CreateFrame("Button", nil, widget)
	labelButton:SetAllPoints(label)
	labelButton:SetScript("OnClick", function(self, button)
		if button == "LeftButton" and IsControlKeyDown() then
			ResetToDefault(configPath, widget, cleanText)
		end
	end)

	-- Add reset-to-default functionality with undo icon
	AddResetToDefaultFunctionality(widget, label, configPath, cleanText)

	-- Add NEW tag if specified
	if showNewTag then
		AddNewTag(widget, label)
	end

	-- REGISTER HOOK FUNCTION FOR REAL-TIME UPDATES
	if hookFunction and type(hookFunction) == "function" then
		RegisterUpdateHook(configPath, hookFunction)
		widget.HookFunction = hookFunction
	end

	-- Dropdown Button
	local dropdown = CreateFrame("Button", nil, widget)
	dropdown:SetSize(180, 18)
	dropdown:SetPoint("RIGHT", -8, 0)

	-- Dropdown Background
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

	-- Optional preview swatch (used when options provide a texture/icon)
	local preview = dropdown:CreateTexture(nil, "ARTWORK")
	preview:SetSize(60, 10)
	preview:SetPoint("RIGHT", arrowTex, "LEFT", -6, 0)
	preview:SetTexture(C["Media"].Textures.White8x8Texture)
	preview:SetVertexColor(0.25, 0.25, 0.25, 1)
	preview:Hide()

	-- Adjust text width depending on preview visibility
	local function SetTextRightAnchor()
		if preview:IsShown() then
			dropdownText:ClearAllPoints()
			dropdownText:SetPoint("LEFT", 8, 0)
			dropdownText:SetPoint("RIGHT", preview, "LEFT", -6, 0)
		else
			dropdownText:ClearAllPoints()
			dropdownText:SetPoint("LEFT", 8, 0)
			dropdownText:SetPoint("RIGHT", arrowTex, "LEFT", -6, 0)
		end
	end
	SetTextRightAnchor()

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

	-- Set arrow to down position using atlas
	local function SetArrowDown()
		local success = pcall(function()
			UseArrowTexture("minimal-scrollbar-small-arrow-bottom")
		end)
		if not success then
			UseArrowText("▼")
		end
	end

	local function SetArrowUp()
		local success = pcall(function()
			UseArrowTexture("minimal-scrollbar-small-arrow-top")
		end)
		if not success then
			UseArrowText("▲")
		end
	end

	-- Initialize arrow to down position
	SetArrowDown()

	-- Tooltip functionality (now added)
	if tooltip then
		widget:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(cleanText, 1, 1, 1, 1, true)
			GameTooltip:AddLine(tooltip, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
			GameTooltip:Show()
		end)

		widget:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	end

	-- Menu state management
	local isMenuOpen = false
	local currentMenu = nil
	local menuBlocker = nil

	-- Function to close menu
	local function CloseMenu()
		if currentMenu then
			if currentMenu.closeTimer then
				currentMenu.closeTimer:Cancel()
				currentMenu.closeTimer = nil
			end
			currentMenu:Hide()
			currentMenu = nil
		end
		if menuBlocker then
			menuBlocker:Hide()
			menuBlocker = nil
		end
		isMenuOpen = false
		SetArrowDown()
	end

	-- Function to open menu
	local function OpenMenu()
		if isMenuOpen then
			CloseMenu()
			return
		end

		-- Create dropdown menu on top-level to avoid clipping
		local menu = CreateFrame("Frame", nil, UIParent)
		local itemHeight = 22
		local visibleCount = math.min(#options, 10)
		local menuWidth = 220
		local searchHeight = (#options > 10) and 24 or 0
		local menuHeight = visibleCount * itemHeight + 4 + searchHeight
		menu:SetSize(menuWidth, menuHeight)
		-- Default position below; adjust later if off-screen
		menu:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 0, -2)
		menu:SetFrameStrata("TOOLTIP")
		menu:SetFrameLevel(1000)
		menu:SetClampedToScreen(true)

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

		-- Optional scroll frame when there are too many entries
		local container = menu
		local useScroll = #options > visibleCount
		local scrollChild, scrollFrame
		-- Optional search box for long lists
		local searchBox
		if #options > 10 then
			local searchFrame = CreateFrame("Frame", nil, menu)
			searchFrame:SetSize(menuWidth - 4, searchHeight)
			searchFrame:SetPoint("TOPLEFT", 2, -2)
			local searchBg = searchFrame:CreateTexture(nil, "BACKGROUND")
			searchBg:SetAllPoints()
			searchBg:SetTexture(C["Media"].Textures.White8x8Texture)
			searchBg:SetVertexColor(0.08, 0.08, 0.08, 1)
			searchBox = CreateFrame("EditBox", nil, searchFrame)
			searchBox:SetAllPoints()
			searchBox:SetFontObject(K.UIFont)
			searchBox:SetAutoFocus(true)
			searchBox:SetTextColor(0.9, 0.9, 0.9, 1)
			searchBox:SetJustifyH("LEFT")
			searchBox:SetText("")
			-- Forward navigation keys to the menu handler so arrow/enter work while typing
			searchBox:EnableKeyboard(true)
			if searchBox.SetPropagateKeyboardInput then
				searchBox:SetPropagateKeyboardInput(false)
			end
			searchBox:SetScript("OnKeyDown", function(self, key)
				if menu and menu:GetScript("OnKeyDown") then
					menu:GetScript("OnKeyDown")(menu, key)
				end
			end)
		end
		if useScroll then
			scrollFrame = CreateFrame("ScrollFrame", nil, menu)
			scrollFrame:SetPoint("TOPLEFT", 2, -(2 + searchHeight))
			scrollFrame:SetPoint("BOTTOMRIGHT", -2, 2)
			scrollFrame:EnableMouseWheel(true)
			scrollFrame:SetScript("OnMouseWheel", function(self, delta)
				local current = self:GetVerticalScroll()
				local maxScroll = self:GetVerticalScrollRange()
				local step = itemHeight
				if delta > 0 then
					self:SetVerticalScroll(math.max(0, current - step))
				else
					self:SetVerticalScroll(math.min(maxScroll, current + step))
				end
			end)

			scrollChild = CreateFrame("Frame", nil, scrollFrame)
			scrollChild:SetSize(menuWidth - 4, #options * itemHeight)
			scrollFrame:SetScrollChild(scrollChild)
			container = scrollChild
		else
			container = menu
		end

		-- Keep references for keyboard navigation and filtering
		local optionButtons = {}
		local function RepositionVisibleButtons()
			local y = -2
			local visibleCountLocal = 0
			for _, btn in ipairs(optionButtons) do
				if btn:IsShown() then
					btn:ClearAllPoints()
					btn:SetPoint("TOPLEFT", container, "TOPLEFT", 2, y)
					y = y - itemHeight
					visibleCountLocal = visibleCountLocal + 1
				end
			end
			if scrollChild then
				scrollChild:SetHeight(math.max(visibleCountLocal * itemHeight, visibleCount * itemHeight))
			end
		end

		-- Create option buttons
		for i, option in ipairs(options) do
			local parentForButton = container
			local optionButton = CreateFrame("Button", nil, parentForButton)
			optionButton:SetSize(menuWidth - 4, itemHeight - 2)
			optionButton:SetPoint("TOPLEFT", 2, -(i - 1) * itemHeight - 2)

			-- Option background (for hover effect)
			local optionBg = optionButton:CreateTexture(nil, "BACKGROUND")
			optionBg:SetAllPoints()
			optionBg:SetTexture(C["Media"].Textures.White8x8Texture)
			optionBg:SetVertexColor(0, 0, 0, 0) -- Transparent by default
			optionButton.OptionBg = optionBg

			-- Optional sample texture/icon preview
			local sample
			if option.texture then
				sample = optionButton:CreateTexture(nil, "ARTWORK")
				sample:SetSize(70, 8)
				sample:SetPoint("RIGHT", optionButton, "RIGHT", -6, 0)
				sample:SetTexture(option.texture)
				sample:SetHorizTile(true)
			elseif option.icon then
				sample = optionButton:CreateTexture(nil, "ARTWORK")
				sample:SetSize(14, 14)
				sample:SetPoint("RIGHT", optionButton, "RIGHT", -6, 0)
				sample:SetTexture(option.icon)
			end

			-- Option text
			local optionText = optionButton:CreateFontString(nil, "OVERLAY")
			optionText:SetFontObject(K.UIFont)
			optionText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
			optionText:SetText(option.text)
			optionText:SetPoint("LEFT", 8, 0)
			if sample then
				optionText:SetPoint("RIGHT", sample, "LEFT", -8, 0)
			else
				optionText:SetPoint("RIGHT", optionButton, "RIGHT", -8, 0)
			end

			-- Highlight current selection
			local currentValue = GetConfigValue(configPath)
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

			-- Click handler with reload tracking
			optionButton:SetScript("OnClick", function()
				SetConfigValue(configPath, option.value, requiresReload, cleanText)
				widget:UpdateValue()
				CloseMenu()
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			end)

			-- Store references for filtering/navigation
			optionButton.OptionValue = option.value
			optionButton.OptionText = option.text:lower()
			optionButton.OptionBg = optionBg
			table.insert(optionButtons, optionButton)
		end

		-- Live filtering if search is present
		if searchBox then
			-- Debounced search to avoid relayout thrash on long lists
			searchBox:SetScript("OnTextChanged", function(self)
				local query = self:GetText():lower()
				if menu._searchTimer then
					menu._searchTimer:Cancel()
				end
				menu._searchTimer = C_Timer.NewTimer(0.12, function()
					for _, btn in ipairs(optionButtons) do
						local show = (query == "" or btn.OptionText:find(query, 1, true) ~= nil)
						btn:SetShown(show)
					end
					RepositionVisibleButtons()
				end)
			end)
		end

		-- Keyboard navigation (Up/Down/Enter, Esc to close)
		local function EnsureVisible(idx)
			if not useScroll or not scrollFrame then
				return
			end
			local btn = optionButtons[idx]
			if not btn or not btn:IsShown() then
				return
			end
			local offset = math.abs(select(5, btn:GetPoint(1)) or 0)
			local current = scrollFrame:GetVerticalScroll()
			local topVisible = current
			local bottomVisible = current + visibleCount * itemHeight
			if offset < topVisible then
				scrollFrame:SetVerticalScroll(offset)
			elseif offset + itemHeight > bottomVisible then
				scrollFrame:SetVerticalScroll(offset - visibleCount * itemHeight + itemHeight)
			end
		end

		local function SetHighlight(index)
			for i, btn in ipairs(optionButtons) do
				if btn:IsShown() then
					local bg = btn.OptionBg or (btn.GetRegions and btn:GetRegions())
					if bg and bg.SetVertexColor then
						local isCurrent = (GetConfigValue(configPath) == btn.OptionValue)
						if i == index then
							bg:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 0.25)
							EnsureVisible(i)
						else
							if isCurrent then
								bg:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 0.3)
							else
								bg:SetVertexColor(0, 0, 0, 0)
							end
						end
					end
				end
			end
		end

		local currentIndex = 1
		-- Initialize currentIndex to first visible
		for i, btn in ipairs(optionButtons) do
			if btn:IsShown() then
				currentIndex = i
				break
			end
		end
		SetHighlight(currentIndex)

		menu:EnableKeyboard(true)
		if menu.SetPropagateKeyboardInput then
			menu:SetPropagateKeyboardInput(false)
		end
		menu:SetScript("OnKeyDown", function(self, key)
			if key == "ESCAPE" then
				CloseMenu()
				return
			end
			if key == "UP" then
				local i = currentIndex - 1
				while i >= 1 and not optionButtons[i]:IsShown() do
					i = i - 1
				end
				if i >= 1 then
					currentIndex = i
					SetHighlight(currentIndex)
				end
				return
			end
			if key == "DOWN" then
				local i = currentIndex + 1
				while i <= #optionButtons and not optionButtons[i]:IsShown() do
					i = i + 1
				end
				if i <= #optionButtons then
					currentIndex = i
					SetHighlight(currentIndex)
				end
				return
			end
			if key == "ENTER" or key == "SPACE" then
				local btn = optionButtons[currentIndex]
				if btn and btn:IsShown() and btn:GetScript("OnClick") then
					btn:GetScript("OnClick")(btn)
				end
				return
			end
		end)

		-- Set menu state
		currentMenu = menu
		isMenuOpen = true
		SetArrowUp()

		-- Create an invisible click-catcher to close the menu when clicking outside
		menuBlocker = CreateFrame("Button", nil, UIParent)
		menuBlocker:SetAllPoints(UIParent)
		-- Ensure blocker is below the menu to allow menu interaction
		menuBlocker:SetFrameStrata("TOOLTIP")
		menuBlocker:SetFrameLevel(900)
		menuBlocker:EnableMouse(true)
		menuBlocker:SetScript("OnMouseDown", function()
			CloseMenu()
		end)
		-- Ensure blocker is hidden when menu hides (safety)
		menu:SetScript("OnHide", function()
			if menuBlocker then
				menuBlocker:Hide()
			end
		end)

		-- Reposition menu if it would go off-screen at bottom; open upwards instead
		C_Timer.After(0, function()
			if not menu or not menu:IsShown() then
				return
			end
			local scale = UIParent:GetEffectiveScale()
			local bottom = menu:GetBottom() or 0
			local screenBottom = 0
			if bottom * scale < screenBottom + 10 then
				menu:ClearAllPoints()
				menu:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 0, 2)
			end
		end)
	end

	-- Hover effect for dropdown button
	dropdown:SetScript("OnEnter", function(self)
		dropdownBg:SetVertexColor(0.2, 0.2, 0.2, 1)
		if arrowTex and arrowTex:IsShown() and arrowTex.SetVertexColor then
			arrowTex:SetVertexColor(1, 1, 1, 1)
		elseif arrowText and arrowText:IsShown() and arrowText.SetTextColor then
			arrowText:SetTextColor(1, 1, 1, 1)
		end
	end)

	dropdown:SetScript("OnLeave", function(self)
		dropdownBg:SetVertexColor(0.15, 0.15, 0.15, 1)
		if arrowTex and arrowTex:IsShown() and arrowTex.SetVertexColor then
			arrowTex:SetVertexColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		elseif arrowText and arrowText:IsShown() and arrowText.SetTextColor then
			arrowText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		end
	end)

	-- Click handler for dropdown button
	dropdown:SetScript("OnClick", function()
		OpenMenu()
	end)

	-- Update function
	function widget:UpdateValue()
		local value = GetConfigValue(self.ConfigPath)
		local found = false
		for _, option in ipairs(options) do
			if option.value == value then
				dropdownText:SetText(option.text)
				if option.texture then
					preview:SetTexture(option.texture)
					preview:Show()
				elseif option.icon then
					preview:SetTexture(option.icon)
					preview:Show()
				else
					preview:Hide()
				end
				SetTextRightAnchor()
				found = true
				break
			end
		end
		if not found then
			if options[1] and options[1].text then
				dropdownText:SetText(options[1].text)
			else
				dropdownText:SetText("Select...")
			end
			if options[1] and options[1].texture then
				preview:SetTexture(options[1].texture)
				preview:Show()
			else
				preview:Hide()
			end
			SetTextRightAnchor()
		end
	end

	-- Close menu function for external use
	function widget:CloseMenu()
		CloseMenu()
	end

	-- Add cogwheel icon if extra configuration exists
	local extraPath = configPath
	if K.ExtraGUI then
		if type(extraPath) == "string" and not (K.ExtraGUI.HasExtraConfig and K.ExtraGUI:HasExtraConfig(extraPath)) then
			local stripped = extraPath:gsub("Input$", "")
			if stripped ~= extraPath and K.ExtraGUI.HasExtraConfig and K.ExtraGUI:HasExtraConfig(stripped) then
				extraPath = stripped
			end
		end
		if K.ExtraGUI.HasExtraConfig and K.ExtraGUI:HasExtraConfig(extraPath) then
			K.ExtraGUI:CreateCogwheelIcon(widget, extraPath, cleanText)
		end
	end

	-- Initialize
	widget:UpdateValue()

	return widget
end

local function CreateColorPicker(parent, configPath, text, tooltip, hookFunction, isNew, requiresReload)
	local widget = CreateFrame("Frame", nil, parent)
	widget:SetSize(CONTENT_WIDTH, WIDGET_HEIGHT)
	widget.ConfigPath = configPath

	-- Background
	CreateColoredBackground(widget, WIDGET_BG[1], WIDGET_BG[2], WIDGET_BG[3], WIDGET_BG[4])

	-- Process NEW tag from text
	local cleanText, hasNewTag = ProcessNewTag(text)
	-- Use isNew parameter or detected NEW tag
	local showNewTag = isNew or hasNewTag

	-- Store NEW tag information for category detection
	widget.IsNew = showNewTag
	widget.HasNewTag = showNewTag

	-- Label
	local label = widget:CreateFontString(nil, "OVERLAY")
	label:SetFontObject(K.UIFont)
	label:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	label:SetText(cleanText) -- Use clean text without NEW tag
	label:SetPoint("LEFT", 8, 0)

	-- Make label clickable for reset functionality
	local labelButton = CreateFrame("Button", nil, widget)
	labelButton:SetAllPoints(label)
	labelButton:SetScript("OnClick", function(self, button)
		if button == "LeftButton" and IsControlKeyDown() then
			ResetToDefault(configPath, widget, cleanText)
		end
	end)

	-- Add reset-to-default functionality with undo icon
	AddResetToDefaultFunctionality(widget, label, configPath, cleanText)

	-- Add NEW tag if specified
	if showNewTag then
		AddNewTag(widget, label)
	end

	-- Register hook function for real-time updates
	if hookFunction and type(hookFunction) == "function" then
		RegisterUpdateHook(configPath, hookFunction)
		widget.HookFunction = hookFunction
	end

	-- Color Button
	local colorButton = CreateFrame("Button", nil, widget)
	colorButton:SetSize(30, 16)
	colorButton:SetPoint("RIGHT", -8, 0)
	-- Modern color button with subtle background
	local colorBg = colorButton:CreateTexture(nil, "BACKGROUND")
	colorBg:SetAllPoints()
	colorBg:SetTexture(C["Media"].Textures.White8x8Texture)
	colorBg:SetVertexColor(0.2, 0.2, 0.2, 1)

	-- Color Display
	local colorDisplay = colorButton:CreateTexture(nil, "OVERLAY")
	colorDisplay:SetPoint("TOPLEFT", 2, -2)
	colorDisplay:SetPoint("BOTTOMRIGHT", -2, 2)
	colorDisplay:SetTexture(C["Media"].Textures.White8x8Texture)

	-- Hover effect for color button
	colorButton:SetScript("OnEnter", function(self)
		colorBg:SetVertexColor(0.3, 0.3, 0.3, 1)
	end)

	colorButton:SetScript("OnLeave", function(self)
		colorBg:SetVertexColor(0.2, 0.2, 0.2, 1)
	end)

	-- Update function
	function widget:UpdateValue()
		local value = GetConfigValue(self.ConfigPath)
		if value and type(value) == "table" and #value >= 3 then
			colorDisplay:SetVertexColor(value[1], value[2], value[3], value[4] or 1)
		else
			colorDisplay:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		end
	end

	-- Enhanced Click handler with hook execution
	colorButton:SetScript("OnClick", function()
		local currentValue = GetConfigValue(configPath) or { ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1 }

		-- Ensure we have valid color values
		if not currentValue or type(currentValue) ~= "table" or #currentValue < 3 then
			currentValue = { ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1 }
		end

		-- Open WoW's color picker
		ColorPickerFrame:SetupColorPickerAndShow({
			r = currentValue[1],
			g = currentValue[2],
			b = currentValue[3],
			opacity = currentValue[4] or 1,
			hasOpacity = true,
			opacityFunc = function(opacity)
				currentValue[4] = opacity
				SetConfigValue(configPath, currentValue, requiresReload, cleanText)
				widget:UpdateValue()
			end,
			swatchFunc = function()
				local r, g, b = ColorPickerFrame:GetColorRGB()
				currentValue[1] = r
				currentValue[2] = g
				currentValue[3] = b
				SetConfigValue(configPath, currentValue, requiresReload, cleanText)
				widget:UpdateValue()
			end,
			cancelFunc = function()
				-- Restore original values if cancelled
				SetConfigValue(configPath, currentValue, requiresReload, cleanText)
				widget:UpdateValue()
			end,
		})

		-- Play feedback sound
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end)

	-- Initialize
	widget:UpdateValue()

	return widget
end

-- Enhanced Widget Creation Functions

-- Multi-Select Checkbox Group
local function CreateCheckboxGroup(parent, configPath, text, options, tooltip, hookFunction, isNew, requiresReload)
	local widget = CreateFrame("Frame", nil, parent)

	-- Calculate better spacing for flow
	local cols = math.min(2, #options) -- Max 2 columns for better readability
	local itemHeight = 32 -- Increased height for better spacing
	local rows = math.ceil(#options / cols)
	local totalHeight = 50 + (rows * itemHeight) + 10 -- Header + items + padding

	widget:SetSize(CONTENT_WIDTH, totalHeight)
	widget.ConfigPath = configPath

	-- Background with rounded appearance
	CreateColoredBackground(widget, WIDGET_BG[1], WIDGET_BG[2], WIDGET_BG[3], WIDGET_BG[4])

	-- Process NEW tag from text
	local cleanText, hasNewTag = ProcessNewTag(text)
	-- Use isNew parameter or detected NEW tag
	local showNewTag = isNew or hasNewTag

	-- Store NEW tag information for category detection
	widget.IsNew = showNewTag
	-- Label with better positioning
	local label = widget:CreateFontString(nil, "OVERLAY")
	label:SetFontObject(K.UIFont)
	label:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	label:SetText(cleanText) -- Use clean text without NEW tag
	label:SetPoint("TOPLEFT", 12, -12)

	-- Make label clickable for reset functionality
	local labelButton = CreateFrame("Button", nil, widget)
	labelButton:SetAllPoints(label)
	labelButton:SetScript("OnClick", function(self, button)
		if button == "LeftButton" and IsControlKeyDown() then
			ResetToDefault(configPath, widget, cleanText)
		end
	end)

	-- Add reset-to-default functionality with undo icon
	AddResetToDefaultFunctionality(widget, label, configPath, cleanText)

	-- Add NEW tag if specified
	if showNewTag then
		AddNewTag(widget, label)
	end

	-- REGISTER HOOK FUNCTION FOR REAL-TIME UPDATES
	if hookFunction and type(hookFunction) == "function" then
		RegisterUpdateHook(configPath, hookFunction)
		widget.HookFunction = hookFunction
	end

	local checkboxes = {}
	local itemWidth = (CONTENT_WIDTH - 60) / cols -- Better spacing calculation

	for i, option in ipairs(options) do
		local row = math.floor((i - 1) / cols)
		local col = (i - 1) % cols

		-- Container for each checkbox item (for better flow)
		local checkboxContainer = CreateFrame("Frame", nil, widget)
		checkboxContainer:SetSize(itemWidth, itemHeight - 4)
		checkboxContainer:SetPoint("TOPLEFT", 20 + col * (itemWidth + 10), -45 - row * itemHeight)

		-- Modern Custom Checkbox
		local checkbox = CreateFrame("Button", nil, checkboxContainer)
		checkbox:SetSize(18, 18) -- Slightly larger for better touch
		checkbox:SetPoint("LEFT", 0, 0)

		-- Checkbox background (custom design)
		local checkboxBg = checkbox:CreateTexture(nil, "BACKGROUND")
		checkboxBg:SetAllPoints()
		checkboxBg:SetTexture(C["Media"].Textures.White8x8Texture)
		checkboxBg:SetVertexColor(0.15, 0.15, 0.15, 1)

		-- Checkbox border ring for modern look
		local checkboxBorder = checkbox:CreateTexture(nil, "BORDER")
		checkboxBorder:SetPoint("TOPLEFT", -1, 1)
		checkboxBorder:SetPoint("BOTTOMRIGHT", 1, -1)
		checkboxBorder:SetTexture(C["Media"].Textures.White8x8Texture)
		checkboxBorder:SetVertexColor(0.3, 0.3, 0.3, 0.8)

		-- Custom checkmark (hidden by default)
		local checkMark = checkbox:CreateTexture(nil, "OVERLAY")
		checkMark:SetSize(12, 12)
		checkMark:SetPoint("CENTER", 0, 0)
		checkMark:SetTexture(C["Media"].Textures.White8x8Texture)
		checkMark:SetVertexColor(1, 1, 1, 0) -- Start invisible

		-- Create checkmark pattern using multiple small textures for ✓ shape
		local checkLine1 = checkbox:CreateTexture(nil, "OVERLAY", nil, 1)
		checkLine1:SetSize(6, 2)
		checkLine1:SetPoint("CENTER", -2, -1)
		checkLine1:SetTexture(C["Media"].Textures.White8x8Texture)
		checkLine1:SetVertexColor(1, 1, 1, 0)

		local checkLine2 = checkbox:CreateTexture(nil, "OVERLAY", nil, 1)
		checkLine2:SetSize(8, 2)
		checkLine2:SetPoint("CENTER", 1, 1)
		checkLine2:SetTexture(C["Media"].Textures.White8x8Texture)
		checkLine2:SetVertexColor(1, 1, 1, 0)

		-- Label for the checkbox with better positioning
		local checkLabel = checkboxContainer:CreateFontString(nil, "OVERLAY")
		checkLabel:SetFontObject(K.UIFont)
		checkLabel:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		checkLabel:SetText(option.text)
		checkLabel:SetPoint("LEFT", checkbox, "RIGHT", 10, 0)
		checkLabel:SetPoint("RIGHT", checkboxContainer, "RIGHT", -5, 0)
		checkLabel:SetJustifyH("LEFT")
		checkLabel:SetWordWrap(false)

		-- Store references for animations
		checkbox.Background = checkboxBg
		checkbox.Border = checkboxBorder
		checkbox.CheckMark = checkMark
		checkbox.CheckLine1 = checkLine1
		checkbox.CheckLine2 = checkLine2
		checkbox.Label = checkLabel
		checkbox.Container = checkboxContainer
		checkbox.OptionValue = option.value
		checkbox.IsChecked = false

		-- Smooth hover animations
		checkbox:SetScript("OnEnter", function(self)
			-- Smooth hover effect
			if not self.IsChecked then
				self.Background:SetVertexColor(0.2, 0.2, 0.2, 1)
				self.Border:SetVertexColor(ACCENT_COLOR[1] * 0.7, ACCENT_COLOR[2] * 0.7, ACCENT_COLOR[3] * 0.7, 1)
			else
				-- Enhance checked state on hover
				self.Background:SetVertexColor(ACCENT_COLOR[1] * 1.1, ACCENT_COLOR[2] * 1.1, ACCENT_COLOR[3] * 1.1, 1)
				self.Border:SetVertexColor(ACCENT_COLOR[1] * 1.2, ACCENT_COLOR[2] * 1.2, ACCENT_COLOR[3] * 1.2, 1)
			end

			-- Enhance label on hover
			self.Label:SetTextColor(1, 1, 1, 1)
		end)

		checkbox:SetScript("OnLeave", function(self)
			-- Return to normal state
			if not self.IsChecked then
				self.Background:SetVertexColor(0.15, 0.15, 0.15, 1)
				self.Border:SetVertexColor(0.3, 0.3, 0.3, 0.8)
			else
				self.Background:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
				self.Border:SetVertexColor(ACCENT_COLOR[1] * 1.1, ACCENT_COLOR[2] * 1.1, ACCENT_COLOR[3] * 1.1, 1)
			end

			-- Return label to normal
			self.Label:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		end)

		-- Smooth check animation
		local function AnimateCheck(self, isChecked)
			if isChecked then
				-- Animate to checked state
				self.Background:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
				self.Border:SetVertexColor(ACCENT_COLOR[1] * 1.1, ACCENT_COLOR[2] * 1.1, ACCENT_COLOR[3] * 1.1, 1)

				-- Animate checkmark appearance with staggered effect
				C_Timer.After(0.05, function()
					self.CheckLine1:SetVertexColor(1, 1, 1, 1)
				end)
				C_Timer.After(0.1, function()
					self.CheckLine2:SetVertexColor(1, 1, 1, 1)
				end)
			else
				-- Animate to unchecked state
				self.Background:SetVertexColor(0.15, 0.15, 0.15, 1)
				self.Border:SetVertexColor(0.3, 0.3, 0.3, 0.8)
				self.CheckLine1:SetVertexColor(1, 1, 1, 0)
				self.CheckLine2:SetVertexColor(1, 1, 1, 0)
			end
			self.IsChecked = isChecked
		end

		checkbox.AnimateCheck = AnimateCheck

		checkboxes[i] = checkbox
	end

	-- Enhanced update function with animations
	function widget:UpdateValue()
		local values = GetConfigValue(self.ConfigPath) or {}
		for _, checkbox in ipairs(checkboxes) do
			local isChecked = false
			for _, value in ipairs(values) do
				if value == checkbox.OptionValue then
					isChecked = true
					break
				end
			end
			checkbox:AnimateCheck(isChecked)
		end
	end

	-- ENHANCED click handlers with hook execution
	for _, checkbox in ipairs(checkboxes) do
		checkbox:SetScript("OnClick", function(self)
			local values = GetConfigValue(configPath) or {}
			local newValues = {}

			-- Copy existing values except the one we're toggling
			for _, value in ipairs(values) do
				if value ~= self.OptionValue then
					table.insert(newValues, value)
				end
			end

			-- Add the value if checkbox is now checked
			local willBeChecked = not self.IsChecked
			if willBeChecked then
				table.insert(newValues, self.OptionValue)
			end

			-- Immediate visual feedback with animation
			self:AnimateCheck(willBeChecked)

			-- Save the configuration - SetConfigValue will now trigger hooks
			SetConfigValue(configPath, newValues, requiresReload, cleanText)

			-- Play feedback sound
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end)

		-- Make the entire container clickable for better UX
		checkbox.Container:EnableMouse(true)
		checkbox.Container:SetScript("OnMouseUp", function()
			checkbox:GetScript("OnClick")(checkbox)
		end)

		-- Add hover effect to the entire container
		checkbox.Container:SetScript("OnEnter", function()
			checkbox:GetScript("OnEnter")(checkbox)
		end)

		checkbox.Container:SetScript("OnLeave", function()
			checkbox:GetScript("OnLeave")(checkbox)
		end)
	end

	-- Initialize with smooth animations
	widget:UpdateValue()

	-- Add enhanced tooltip support if provided
	if tooltip then
		CreateEnhancedTooltip(widget, cleanText, tooltip)

		-- Also add tooltips to individual checkbox containers for better UX
		for i, checkbox in ipairs(checkboxes) do
			local option = options[i] -- Get the corresponding option
			CreateEnhancedTooltip(checkbox.Container, option.text, "Click to toggle this option.\n\nCurrent selection affects: " .. cleanText)
		end
	end

	return widget
end

local function CreateTextInput(parent, configPath, text, placeholder, tooltip, hookFunction, isNew, requiresReload)
	local widget = CreateFrame("Frame", nil, parent)
	widget:SetSize(CONTENT_WIDTH, WIDGET_HEIGHT)
	widget.ConfigPath = configPath

	-- Background
	CreateColoredBackground(widget, WIDGET_BG[1], WIDGET_BG[2], WIDGET_BG[3], WIDGET_BG[4])

	-- Process NEW tag from text
	local cleanText, hasNewTag = ProcessNewTag(text)
	-- Use isNew parameter or detected NEW tag
	local showNewTag = isNew or hasNewTag

	-- Store NEW tag information for category detection
	widget.IsNew = showNewTag
	widget.HasNewTag = showNewTag

	-- Label
	local label = widget:CreateFontString(nil, "OVERLAY")
	label:SetFontObject(K.UIFont)
	label:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	label:SetText(cleanText) -- Use clean text without NEW tag
	label:SetPoint("LEFT", 8, 0)

	-- Make label clickable for reset functionality
	local labelButton = CreateFrame("Button", nil, widget)
	labelButton:SetAllPoints(label)
	labelButton:SetScript("OnClick", function(self, button)
		if button == "LeftButton" and IsControlKeyDown() then
			ResetToDefault(configPath, widget, cleanText)
		end
	end)

	-- Add reset-to-default functionality with undo icon
	AddResetToDefaultFunctionality(widget, label, configPath, cleanText)

	-- Add NEW tag if specified
	if showNewTag then
		AddNewTag(widget, label)
	end

	-- Register hook function for real-time updates
	if hookFunction and type(hookFunction) == "function" then
		RegisterUpdateHook(configPath, hookFunction)
		widget.HookFunction = hookFunction
	end

	-- Text Input EditBox
	local editBox = CreateFrame("EditBox", nil, widget)
	editBox:SetSize(150, 16)
	-- Leave room for a checkmark apply button
	editBox:SetPoint("RIGHT", -30, 0)
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
		local value = GetConfigValue(self.ConfigPath) or ""
		editBox:SetText(tostring(value))
	end

	-- Save on enter/focus lost
	editBox:SetScript("OnEnterPressed", function(self)
		local txt = self and self.GetText and self:GetText() or ""
		SetConfigValue(configPath, txt, requiresReload, cleanText)
		self:ClearFocus()
	end)

	editBox:SetScript("OnEditFocusLost", function(self)
		local txt = self and self.GetText and self:GetText() or ""
		SetConfigValue(configPath, txt, requiresReload, cleanText)
	end)

	-- ESC to reset to default value
	editBox:SetScript("OnEscapePressed", function(self)
		ResetToDefault(configPath, widget, cleanText)
		self:ClearFocus()
		widget:UpdateValue()
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
		GameTooltip:SetText("Apply", 1, 1, 1, 1, true)
		GameTooltip:AddLine("Click to apply this value", 0.7, 0.7, 0.7, true)
		GameTooltip:Show()
	end)
	applyButton:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	applyButton:SetScript("OnClick", function()
		local txt = editBox and editBox.GetText and editBox:GetText() or ""
		SetConfigValue(configPath, txt, requiresReload, cleanText)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end)

	-- Enhanced tooltip functionality
	if tooltip then
		CreateEnhancedTooltip(widget, cleanText, tooltip .. "\n\nEnter to apply, Esc to reset to default, or click the checkmark to apply.")
	end

	-- Initialize
	widget:UpdateValue()

	return widget
end

-- Category and Section Management
local function CreateCategory(name, icon)
	local cleanName, hasNewTag = ProcessNewTag(name)
	local category = {
		Name = cleanName,
		Icon = icon,
		Sections = {},
		Widgets = {},
		Frame = nil,
		ScrollChild = nil,
		HasNewTag = hasNewTag,
	}

	tinsert(GUI.Categories, category)
	return category
end

local function CreateSection(category, name)
	local section = {
		Name = name,
		Widgets = {},
	}

	tinsert(category.Sections, section)
	return section
end

-- HOOK MANAGEMENT UTILITIES
function GUI:RegisterHook(configPath, hookFunction)
	RegisterUpdateHook(configPath, hookFunction)
end

function GUI:UnregisterHook(configPath, hookFunction)
	if self.UpdateHooks[configPath] then
		for i, func in ipairs(self.UpdateHooks[configPath]) do
			if func == hookFunction then
				tremove(self.UpdateHooks[configPath], i)
				break
			end
		end
	end
end

function GUI:TriggerHooks(configPath, newValue, oldValue)
	ExecuteUpdateHooks(configPath, newValue, oldValue)
end

-- Sidebar Creation
local function CreateSidebar(parent)
	local sidebar = CreateFrame("Frame", nil, parent)
	sidebar:SetPoint("TOPLEFT", 0, -HEADER_HEIGHT)
	sidebar:SetPoint("BOTTOMLEFT", 0, 0)
	sidebar:SetWidth(SIDEBAR_WIDTH)

	CreateColoredBackground(sidebar, SIDEBAR_COLOR[1], SIDEBAR_COLOR[2], SIDEBAR_COLOR[3], SIDEBAR_COLOR[4])

	-- Create search box at top of sidebar
	local searchBox = CreateSearchBox(sidebar)
	GUI.SearchBox = searchBox -- Store reference for cleanup

	-- Create scrollable area for categories
	local categoryScrollFrame = CreateFrame("ScrollFrame", nil, sidebar)
	categoryScrollFrame:SetPoint("TOPLEFT", 0, -55) -- Below search box
	categoryScrollFrame:SetPoint("BOTTOMRIGHT", -5, 5) -- Leave room for scrollbar
	categoryScrollFrame:EnableMouseWheel(true)

	-- Add mouse wheel scrolling
	categoryScrollFrame:SetScript("OnMouseWheel", function(self, delta)
		local scrollStep = CATEGORY_HEIGHT + 2 -- Height of one category button plus spacing
		local currentScroll = self:GetVerticalScroll()
		local maxScroll = self:GetVerticalScrollRange()

		if delta > 0 then
			-- Scroll up
			self:SetVerticalScroll(max(0, currentScroll - scrollStep))
		else
			-- Scroll down
			self:SetVerticalScroll(min(maxScroll, currentScroll + scrollStep))
		end
	end)

	local categoryScrollChild = CreateFrame("Frame", nil, categoryScrollFrame)
	categoryScrollChild:SetWidth(SIDEBAR_WIDTH - 15) -- Account for scrollbar
	categoryScrollFrame:SetScrollChild(categoryScrollChild)

	-- Keep child width responsive with frame size
	categoryScrollFrame:SetScript("OnSizeChanged", function(self, w)
		if w and categoryScrollChild then
			categoryScrollChild:SetWidth(math.max(1, w - 15))
		end
	end)

	GUI.Sidebar = sidebar
	GUI.CategoryScrollFrame = categoryScrollFrame
	GUI.CategoryScrollChild = categoryScrollChild
	return sidebar
end

-- Content Area Creation
local function CreateContent(parent)
	local content = CreateFrame("Frame", nil, parent)
	content:SetPoint("TOPRIGHT", 0, -HEADER_HEIGHT)
	content:SetPoint("BOTTOMRIGHT", 0, 0)
	content:SetPoint("TOPLEFT", SIDEBAR_WIDTH, -HEADER_HEIGHT)

	CreateColoredBackground(content, BG_COLOR[1], BG_COLOR[2], BG_COLOR[3], BG_COLOR[4])

	-- Create scroll frame for content
	local scrollFrame = CreateFrame("ScrollFrame", nil, content)
	scrollFrame:SetPoint("TOPLEFT", SPACING, -SPACING)
	scrollFrame:SetPoint("BOTTOMRIGHT", -SPACING, SPACING)

	-- Add mouse wheel scrolling
	scrollFrame:EnableMouseWheel(true)
	scrollFrame:SetScript("OnMouseWheel", function(self, delta)
		local scrollStep = 40
		local currentScroll = self:GetVerticalScroll()
		local maxScroll = self:GetVerticalScrollRange()

		if delta > 0 then
			-- Scroll up
			self:SetVerticalScroll(max(0, currentScroll - scrollStep))
		else
			-- Scroll down
			self:SetVerticalScroll(min(maxScroll, currentScroll + scrollStep))
		end
	end)

	local scrollChild = CreateFrame("Frame", nil, scrollFrame)
	-- Initialize width; will also update on size changes for responsiveness
	scrollChild:SetWidth(scrollFrame:GetWidth())
	scrollFrame:SetScrollChild(scrollChild)

	-- Keep child width in sync with frame width
	scrollFrame:SetScript("OnSizeChanged", function(self, w)
		if w and scrollChild then
			scrollChild:SetWidth(math.max(1, w))
		end
	end)

	GUI.Content = content
	GUI.ScrollFrame = scrollFrame
	GUI.ScrollChild = scrollChild

	return content
end

-- Main GUI Creation
local function CreateMainFrame()
	local frame = CreateFrame("Frame", "KkthnxUI_NewGUI", UIParent)
	frame:SetSize(PANEL_WIDTH, PANEL_HEIGHT)
	frame:SetPoint("CENTER")
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:SetFrameStrata("HIGH")
	frame:SetFrameLevel(100)
	frame:Hide()

	-- Modern background with subtle shadow effect
	local mainBg = frame:CreateTexture(nil, "BACKGROUND")
	mainBg:SetAllPoints()
	mainBg:SetTexture(C["Media"].Textures.White8x8Texture)
	mainBg:SetVertexColor(0.08, 0.08, 0.08, 0.95)

	-- Subtle shadow effect
	local shadow = CreateFrame("Frame", nil, frame)
	shadow:SetPoint("TOPLEFT", -8, 8)
	shadow:SetPoint("BOTTOMRIGHT", 8, -8)
	shadow:SetFrameLevel(frame:GetFrameLevel() - 1)
	local shadowTexture = shadow:CreateTexture(nil, "BACKGROUND")
	shadowTexture:SetAllPoints()
	shadowTexture:SetTexture(C["Media"].Textures.White8x8Texture)
	shadowTexture:SetVertexColor(0, 0, 0, 0.4)

	-- Title Bar
	local titleBar = CreateFrame("Frame", nil, frame)
	titleBar:SetPoint("TOPLEFT", 0, 0)
	titleBar:SetPoint("TOPRIGHT", 0, 0)
	titleBar:SetHeight(HEADER_HEIGHT)

	CreateColoredBackground(titleBar, ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3])

	local title = titleBar:CreateFontString(nil, "OVERLAY")
	title:SetFontObject(K.UIFont)
	title:SetTextColor(1, 1, 1, 1)
	title:SetText(format("%s %s - %s", K.Title, K.Version, "Configuration"))
	title:SetPoint("CENTER", 0, -1)

	-- Close Button
	local closeButton = CreateFrame("Button", nil, titleBar)
	closeButton:SetSize(32, 32)
	closeButton:SetPoint("RIGHT", -4, 0)

	local closeBg = closeButton:CreateTexture(nil, "BACKGROUND")
	closeBg:SetAllPoints()
	closeBg:SetTexture(C["Media"].Textures.White8x8Texture)
	closeBg:SetVertexColor(0, 0, 0, 0)

	closeButton.Icon = closeButton:CreateTexture(nil, "ARTWORK")
	closeButton.Icon:SetSize(16, 16)
	closeButton.Icon:SetPoint("CENTER")
	closeButton.Icon:SetAtlas("uitools-icon-close")
	closeButton.Icon:SetVertexColor(1, 1, 1, 0.8)

	closeButton:SetScript("OnClick", function()
		GUI:Hide()
	end)

	closeButton:SetScript("OnEnter", function(self)
		self.Icon:SetVertexColor(1, 1, 1, 1)
		closeBg:SetVertexColor(1, 0.2, 0.2, 0.3)
	end)

	closeButton:SetScript("OnLeave", function(self)
		self.Icon:SetVertexColor(1, 1, 1, 0.8)
		closeBg:SetVertexColor(0, 0, 0, 0)
	end)

	-- Profile Manager Button
	local profileButton = CreateFrame("Button", nil, titleBar)
	profileButton:SetSize(32, 32)
	profileButton:SetPoint("RIGHT", closeButton, "LEFT", -4, 0)

	local profileBg = profileButton:CreateTexture(nil, "BACKGROUND")
	profileBg:SetAllPoints()
	profileBg:SetTexture(C["Media"].Textures.White8x8Texture)
	profileBg:SetVertexColor(0, 0, 0, 0)

	profileButton.Icon = profileButton:CreateTexture(nil, "ARTWORK")
	profileButton.Icon:SetSize(20, 24.5)
	profileButton.Icon:SetPoint("CENTER")
	profileButton.Icon:SetAtlas("UI-HUD-MicroMenu-SpellbookAbilities-Up")
	profileButton.Icon:SetVertexColor(1, 1, 1, 0.8)

	profileButton:SetScript("OnClick", function()
		if K.ProfileGUI then
			K.ProfileGUI:Toggle()
		else
			print("|cff669DFFKkthnxUI:|r ProfileGUI system not available.")
		end
	end)

	profileButton:SetScript("OnEnter", function(self)
		self.Icon:SetVertexColor(1, 1, 1, 1)
		profileBg:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 0.3)

		-- Show tooltip
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
		GameTooltip:SetText("Profile Manager", 1, 1, 1, 1, true)
		GameTooltip:AddLine("Advanced profile management system", 0.7, 0.7, 0.7)
		GameTooltip:AddLine("Click to open profile manager", 0.5, 0.8, 1)
		GameTooltip:Show()
	end)

	profileButton:SetScript("OnLeave", function(self)
		self.Icon:SetVertexColor(1, 1, 1, 0.8)
		profileBg:SetVertexColor(0, 0, 0, 0)
		GameTooltip:Hide()
	end)

	-- Reload UI Button (left of profile button)
	local reloadButton = CreateFrame("Button", nil, titleBar)
	reloadButton:SetSize(32, 32)
	reloadButton:SetPoint("RIGHT", profileButton, "LEFT", -4, 0)

	local reloadBg = reloadButton:CreateTexture(nil, "BACKGROUND")
	reloadBg:SetAllPoints()
	reloadBg:SetTexture(C["Media"].Textures.White8x8Texture)
	reloadBg:SetVertexColor(0, 0, 0, 0)

	reloadButton.Icon = reloadButton:CreateTexture(nil, "ARTWORK")
	reloadButton.Icon:SetSize(18, 18)
	reloadButton.Icon:SetPoint("CENTER")
	reloadButton.Icon:SetAtlas("transmog-icon-revert")
	reloadButton.Icon:SetVertexColor(1, 1, 1, 0.8)

	reloadButton:SetScript("OnClick", function()
		-- Clear pending reloads and reload UI immediately
		if ReloadTracker and ReloadTracker.ClearQueue then
			ReloadTracker:ClearQueue()
		end
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		ReloadUI()
	end)

	reloadButton:SetScript("OnEnter", function(self)
		self.Icon:SetVertexColor(1, 1, 1, 1)
		reloadBg:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 0.3)

		-- Tooltip
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
		GameTooltip:SetText("Reload UI", 1, 1, 1, 1, true)
		GameTooltip:AddLine("Apply changes immediately", 0.7, 0.7, 0.7)
		GameTooltip:Show()
	end)

	reloadButton:SetScript("OnLeave", function(self)
		self.Icon:SetVertexColor(1, 1, 1, 0.8)
		reloadBg:SetVertexColor(0, 0, 0, 0)
		GameTooltip:Hide()
	end)

	-- Create Sidebar
	CreateSidebar(frame)

	-- Create Content Area
	CreateContent(frame)

	GUI.Frame = frame
	return frame
end

-- Content Population
local function PopulateContent(category)
	if not category or not GUI.ScrollChild then
		return
	end

	-- Clear existing content (including FontStrings)
	for _, child in ipairs({ GUI.ScrollChild:GetChildren() }) do
		child:Hide()
		child:SetParent(nil)
	end

	-- Clear any FontStrings that might be directly attached to ScrollChild
	for i = 1, GUI.ScrollChild:GetNumRegions() do
		local region = select(i, GUI.ScrollChild:GetRegions())
		if region and region:GetObjectType() == "FontString" then
			region:SetText("")
			region:Hide()
		end
	end

	local yOffset = -15

	-- Category title (match section header styling for uniformity)
	local categoryTitleFrame = CreateFrame("Frame", nil, GUI.ScrollChild)
	categoryTitleFrame:SetSize(CONTENT_WIDTH - 30, 30)
	categoryTitleFrame:SetPoint("TOPLEFT", 15, yOffset)

	-- Background to match section headers
	local categoryBg = categoryTitleFrame:CreateTexture(nil, "BACKGROUND")
	categoryBg:SetAllPoints()
	categoryBg:SetTexture(C["Media"].Textures.White8x8Texture)
	categoryBg:SetVertexColor(0.05, 0.05, 0.05, 0.8)

	local categoryTitle = categoryTitleFrame:CreateFontString(nil, "OVERLAY")
	categoryTitle:SetFontObject(K.UIFont)
	categoryTitle:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
	categoryTitle:SetText(category.Name)
	categoryTitle:SetPoint("LEFT", categoryTitleFrame, "LEFT", 10, 0)
	yOffset = yOffset - 40

	-- Create sections with proper spacing
	local firstMatchesCategory = (category.Sections[1] and category.Sections[1].Name == category.Name)
	for sectionIndex, section in ipairs(category.Sections) do
		-- Add extra spacing between sections (except first)
		if sectionIndex > 1 then
			yOffset = yOffset - 15
		end

		local createdHeader = false
		if not (sectionIndex == 1 and firstMatchesCategory) then
			-- Section header frame with proper background
			local sectionFrame = CreateFrame("Frame", nil, GUI.ScrollChild)
			sectionFrame:SetSize(CONTENT_WIDTH - 30, 30)
			sectionFrame:SetPoint("TOPLEFT", 15, yOffset)

			-- Section header background
			local sectionBg = sectionFrame:CreateTexture(nil, "BACKGROUND")
			sectionBg:SetAllPoints()
			sectionBg:SetTexture(C["Media"].Textures.White8x8Texture)
			sectionBg:SetVertexColor(0.05, 0.05, 0.05, 0.8)

			-- Section title with proper positioning
			local sectionTitle = sectionFrame:CreateFontString(nil, "OVERLAY")
			sectionTitle:SetFontObject(K.UIFont)
			sectionTitle:SetTextColor(0.9, 0.9, 0.9, 1)

			-- Use clean section title text
			sectionTitle:SetText(section.Name)
			sectionTitle:SetPoint("LEFT", sectionFrame, "LEFT", 10, 0)

			yOffset = yOffset - 40
			createdHeader = true
		else
			-- Skip duplicate header if first section matches category name
			yOffset = yOffset - 10
		end

		-- Section widgets with consistent spacing
		for widgetIndex, widget in ipairs(section.Widgets) do
			widget:SetParent(GUI.ScrollChild)
			widget:ClearAllPoints()
			widget:SetPoint("TOPLEFT", 15, yOffset)

			-- Update widget value to reflect current configuration state
			if widget.UpdateValue then
				widget:UpdateValue()
			end

			widget:Show()

			-- Calculate proper spacing based on widget height
			local widgetHeight = widget:GetHeight()
			if widgetHeight == 0 then
				widgetHeight = WIDGET_HEIGHT
			end

			yOffset = yOffset - (widgetHeight + 8)
		end

		-- Add spacing after last widget in section
		yOffset = yOffset - 10
	end

	-- Set proper scroll child height with padding
	local totalHeight = math.abs(yOffset) + 20
	GUI.ScrollChild:SetHeight(totalHeight)

	-- Reset scroll position to top
	if GUI.ScrollFrame then
		GUI.ScrollFrame:SetVerticalScroll(0)
	end
end

-- Helper function to check if a category contains any widgets with NEW tags
local function CategoryContainsNewWidgets(category)
	for _, section in ipairs(category.Sections) do
		for _, widget in ipairs(section.Widgets) do
			-- Check if widget was created with isNew parameter or has NEW in text
			if widget.IsNew or widget.HasNewTag then
				return true
			end
			-- Also check if the widget's text contains the NEW tag
			if widget.ConfigPath then
				local regions = { widget:GetRegions() }
				for _, region in ipairs(regions) do
					if region and region:GetObjectType() == "FontString" then
						local text = region:GetText()
						if text and text:find("ISNEW") then
							return true
						end
					end
				end
			end
		end
	end
	return false
end

-- Category Button Creation - Enhanced with automatic NEW tag detection
local function CreateCategoryButton(category, index)
	local button = CreateFrame("Button", nil, GUI.CategoryScrollChild or GUI.Sidebar)
	button:SetSize(SIDEBAR_WIDTH - 20, CATEGORY_HEIGHT) -- Slightly smaller to account for scrollbar

	-- Add extra spacing before Credits category to separate it visually
	local extraSpacing = 0
	if category.Name == "Credits" then
		extraSpacing = 20 -- Add 20px extra spacing before Credits
	end

	button:SetPoint("TOP", 0, -(index - 1) * (CATEGORY_HEIGHT + 2) - 10 - extraSpacing) -- Simplified positioning with spacer

	local catBg = CreateColoredBackground(button, 0.08, 0.08, 0.08, 0.8)
	button.KKUI_Background = catBg

	-- Selection indicator
	local selected = button:CreateTexture(nil, "OVERLAY")
	selected:SetSize(3, CATEGORY_HEIGHT - 4)
	selected:SetPoint("LEFT", 2, 0)
	selected:SetTexture(C["Media"].Textures.White8x8Texture)
	selected:Hide()
	button.Selected = selected

	-- Icon
	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetSize(16, 16)
	icon:SetPoint("LEFT", 15, 0)
	icon:SetTexture(category.Icon)
	icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

	-- Text
	local text = button:CreateFontString(nil, "OVERLAY")
	text:SetFontObject(K.UIFont)
	text:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	text:SetText(category.Name)
	text:SetPoint("LEFT", icon, "RIGHT", 8, 0)
	button.Text = text
	button.Icon = icon

	-- Add NEW tag if category has it manually or contains new widgets
	if category.HasNewTag or CategoryContainsNewWidgets(category) then
		AddNewTag(button, text)
	end

	-- Hover effect
	button.Highlight = button:CreateTexture(nil, "HIGHLIGHT")
	button.Highlight:SetAllPoints()
	button.Highlight:SetTexture(C["Media"].Textures.White8x8Texture)
	button.Highlight:SetVertexColor(1, 1, 1, 0.1)

	button:SetScript("OnClick", function()
		GUI:ShowCategory(category)
	end)

	category.Button = button
	return button
end

-- Function to refresh category NEW tags after widgets are loaded
function GUI:RefreshCategoryNewTags()
	for _, category in ipairs(self.Categories) do
		if category.Button then
			-- Remove existing NEW tag frame if it exists
			if category.Button.NewTag then
				category.Button.NewTag:Hide()
				category.Button.NewTag = nil
			end

			-- Check if category should have NEW tag and add it
			if category.HasNewTag or CategoryContainsNewWidgets(category) then
				-- Find the text element in the button
				local text = nil
				for i = 1, category.Button:GetNumRegions() do
					local region = select(i, category.Button:GetRegions())
					if region and region:GetObjectType() == "FontString" then
						text = region
						break
					end
				end

				if text then
					category.Button.NewTag = AddNewTag(category.Button, text)
				end
			end
		end
	end
end

-- Enhanced GUI Functions
function GUI:Initialize()
	DebugLog("GUI:Initialize() called")

	if self.Frame then
		DebugLog("GUI already initialized, returning existing frame")
		return self.Frame
	end

	DebugLog("Initializing GUI system...")

	-- Initialize ExtraGUI system
	if K.ExtraGUI and K.ExtraGUI.Initialize then
		DebugLog("Initializing ExtraGUI system")
		K.ExtraGUI:Initialize()
	end

	CreateMainFrame()

	-- Create category buttons in sidebar
	for i, category in ipairs(self.Categories) do
		CreateCategoryButton(category, i)
	end

	-- Set proper scroll height for category list
	if self.CategoryScrollChild and #self.Categories > 0 then
		local totalHeight = #self.Categories * (CATEGORY_HEIGHT + 2) + 20 -- Extra padding

		-- Add extra space for Credits category spacer
		for _, category in ipairs(self.Categories) do
			if category.Name == "Credits" then
				totalHeight = totalHeight + 20 -- Account for Credits spacer
				break
			end
		end

		self.CategoryScrollChild:SetHeight(totalHeight)
		-- Category scroll height set properly
	end

	-- Create static popups
	DebugLog("Creating static popups")
	self:CreateStaticPopups()

	-- Show "General" category by default if available, else first
	if #self.Categories > 0 then
		local target = nil
		for _, cat in ipairs(self.Categories) do
			if cat.Name == "General" then
				target = cat
				break
			end
		end
		target = target or self.Categories[1]
		DebugLog("Showing default category: " .. (target and target.Name or "nil"))
		self:ShowCategory(target)
	end

	-- Refresh category NEW tags after everything is loaded
	C_Timer.After(0.1, function()
		self:RefreshCategoryNewTags()
	end)

	self.IsInitialized = true
	DebugLog("GUI initialization complete")
	return self.Frame
end

-- Add Enable method for compatibility with Core/Loading.lua
function GUI:Enable()
	if not self.IsInitialized then
		self:Initialize()
	end
	self.Enabled = true
end

function GUI:Show()
	if not self.Frame then
		self:Initialize()
	end
	self.Frame:Show()
	self.IsVisible = true
	-- Enable CtrlChecker updates only while GUI is visible
	if CtrlChecker then
		CtrlChecker:SetScript("OnUpdate", CtrlChecker.CtrlUpdate)
	end
end

function GUI:Hide()
	-- Close ProfileGUI if it's open
	if K.ProfileGUI and K.ProfileGUI.IsVisible then
		K.ProfileGUI:Hide()
	end

	-- Cleanup active timers and handlers to prevent memory leaks
	if self.Frame then
		-- Clean up any active dropdown timers
		for _, category in ipairs(self.Categories) do
			for _, section in ipairs(category.Sections) do
				for _, widget in ipairs(section.Widgets) do
					if widget.CloseMenu then
						widget:CloseMenu()
					end
					-- Clear any OnUpdate handlers that might still be running
					if widget.Thumb then
						widget.Thumb:SetScript("OnUpdate", nil)
					end
				end
			end
		end

		-- Clear search box focus to prevent input capture
		if self.SearchBox then
			self.SearchBox:ClearFocus()
		end

		self.Frame:Hide()
	end
	self.IsVisible = false
	-- Disable CtrlChecker when GUI is hidden
	if CtrlChecker then
		CtrlChecker:SetScript("OnUpdate", nil)
	end

	-- Check for pending reloads when closing GUI
	ReloadTracker:OnGUIClose()
end

function GUI:Toggle()
	if self.IsVisible then
		self:Hide()
	else
		self:Show()
	end
end

function GUI:ShowCategory(category)
	-- Track current category for refresh functionality
	self.CurrentCategory = category

	-- Update button states
	for _, cat in ipairs(self.Categories) do
		if cat.Button then
			if cat == category then
				cat.Button.Selected:Show()
				-- Subtle accent background to indicate selection
				if cat.Button.KKUI_Background then
					cat.Button.KKUI_Background:SetVertexColor(ACCENT_COLOR[1] * 0.2, ACCENT_COLOR[2] * 0.2, ACCENT_COLOR[3] * 0.2, 0.9)
				end
			else
				cat.Button.Selected:Hide()
				if cat.Button.KKUI_Background then
					cat.Button.KKUI_Background:SetVertexColor(0.08, 0.08, 0.08, 0.8)
				end
			end
		end
	end

	-- Populate content
	PopulateContent(category)

	-- Ensure any widgets that should have ExtraGUI cogwheels get them attached
	if self.AttachExtraCogwheels then
		self:AttachExtraCogwheels()
	end

	-- Safety: re-evaluate dependency states for all widgets after population
	if category and category.Widgets then
		for _, widget in ipairs(category.Widgets) do
			if widget and widget.ConfigPath then
				-- Force dependency overlay creation/evaluation if bound
				if K.GUIHelpers and K.GUIHelpers.SetWidgetEnabled then
					-- NOP: actual dependency functions already hooked OnShow; simply ensure shown state
					if widget:IsShown() and widget._disableOverlay and widget._disableOverlay:IsShown() then
						-- keep overlay as-is
					end
				end
			end
		end
	end
end

function GUI:AddCategory(name, icon)
	return CreateCategory(name, icon)
end

function GUI:AddSection(category, name)
	return CreateSection(category, name)
end

function GUI:AddWidget(section, widget)
	if section then
		tinsert(section.Widgets, widget)
	end
	widget.ConfigPath = widget.ConfigPath
end

-- Attach missing ExtraGUI cogwheels for already-created widgets
function GUI:AttachExtraCogwheels()
	if not (K.ExtraGUI and K.ExtraGUI.HasExtraConfig and K.ExtraGUI.CreateCogwheelIcon) then
		return
	end
	for _, category in ipairs(self.Categories) do
		for _, section in ipairs(category.Sections) do
			for _, widget in ipairs(section.Widgets) do
				local cfg = widget and widget.ConfigPath
				if cfg and not widget.Cogwheel then
					local targetPath = cfg
					-- Support buffer inputs that end with "Input" by mapping to the real config path
					if type(targetPath) == "string" and not K.ExtraGUI:HasExtraConfig(targetPath) then
						local stripped = targetPath:gsub("Input$", "")
						if stripped ~= targetPath and K.ExtraGUI:HasExtraConfig(stripped) then
							targetPath = stripped
						end
					end

					if K.ExtraGUI:HasExtraConfig(targetPath) then
						local title = widget.DisplayText
						local cog = K.ExtraGUI:CreateCogwheelIcon(widget, targetPath, title)
						if cog then
							widget.Cogwheel = cog
							-- If a reset button exists, nudge it right so it doesn't overlap the new cogwheel
							if widget.ResetButton and widget.ResetButton:IsShown() == false then
								-- Re-anchor just to be safe; keep the same anchor but add offset
								local point, rel, relPoint, x, y = widget.ResetButton:GetPoint(1)
								if point then
									widget.ResetButton:ClearAllPoints()
									widget.ResetButton:SetPoint(point, rel, relPoint, (x or 0) + 26, y or 0)
								end
							end
						end
					end
				end
			end
		end
	end
end

-- Widget Creation Methods - ENHANCED with Hook Support
function GUI:CreateSwitch(section, configPath, text, tooltip, hookFunction, isNew, requiresReload)
	local widget = CreateSwitch(UIParent, configPath, text, tooltip, hookFunction, isNew, requiresReload)
	widget:Hide()
	self:AddWidget(section, widget)

	-- Add cogwheel icon if this configPath has extra configuration
	if K.ExtraGUI and K.ExtraGUI:HasExtraConfig(configPath) then
		local cogwheel = K.ExtraGUI:CreateCogwheelIcon(widget, configPath, text)
		if cogwheel then
			widget.Cogwheel = cogwheel
		end
	end

	return widget
end

function GUI:CreateSlider(section, configPath, text, minVal, maxVal, step, tooltip, hookFunction, isNew, requiresReload)
	local widget = CreateSlider(UIParent, configPath, text, minVal, maxVal, step, tooltip, hookFunction, isNew, requiresReload)
	widget:Hide()
	self:AddWidget(section, widget)
	return widget
end

function GUI:CreateDropdown(section, configPath, text, options, tooltip, hookFunction, isNew, requiresReload)
	local widget = CreateDropdown(UIParent, configPath, text, options, tooltip, hookFunction, isNew, requiresReload)
	widget:Hide()
	self:AddWidget(section, widget)
	return widget
end

function GUI:CreateTextureDropdown(section, configPath, text, tooltip, hookFunction, isNew, requiresReload)
	-- TEMPORARY FALLBACK: Use regular dropdown with texture options until proper function is available
	local textureOptions = {}

	-- Get basic texture options from Media.lua
	if K.GetAllStatusbarTextures then
		textureOptions = K.GetAllStatusbarTextures()
	else
		-- Fallback texture options if function not available
		textureOptions = {
			{ text = "KkthnxUI", value = "KkthnxUI" },
			{ text = "Flat", value = "Flat" },
			{ text = "Clean", value = "Clean" },
			{ text = "GoldpawUI", value = "GoldpawUI" },
		}
	end

	-- Use regular dropdown widget as fallback
	local widget = CreateDropdown(UIParent, configPath, text, textureOptions, tooltip, hookFunction, isNew, requiresReload)
	widget:Hide()
	self:AddWidget(section, widget)
	return widget
end

function GUI:CreateColorPicker(section, configPath, text, tooltip, hookFunction, isNew, requiresReload)
	local widget = CreateColorPicker(UIParent, configPath, text, tooltip, hookFunction, isNew, requiresReload)
	widget:Hide()
	self:AddWidget(section, widget)
	return widget
end

function GUI:CreateCheckboxGroup(section, configPath, text, options, tooltip, hookFunction, isNew, requiresReload)
	local widget = CreateCheckboxGroup(UIParent, configPath, text, options, tooltip, hookFunction, isNew, requiresReload)
	widget:Hide()
	self:AddWidget(section, widget)
	return widget
end

function GUI:CreateTextInput(section, configPath, text, placeholder, tooltip, hookFunction, isNew, requiresReload)
	local widget = CreateTextInput(UIParent, configPath, text, placeholder, tooltip, hookFunction, isNew, requiresReload)
	widget:Hide()
	self:AddWidget(section, widget)

	-- Add cogwheel icon if this configPath has extra configuration
	if K.ExtraGUI then
		local extraPath = configPath
		-- If this is a buffer input (e.g., ends with "Input"), map to the real config path
		if type(extraPath) == "string" and not K.ExtraGUI:HasExtraConfig(extraPath) then
			local stripped = extraPath:gsub("Input$", "")
			if stripped ~= extraPath and K.ExtraGUI:HasExtraConfig(stripped) then
				extraPath = stripped
			end
		end

		if extraPath and K.ExtraGUI:HasExtraConfig(extraPath) then
			local cogwheel = K.ExtraGUI:CreateCogwheelIcon(widget, extraPath, text)
			if cogwheel then
				widget.Cogwheel = cogwheel
			end
		end
	end
	return widget
end

-- Configuration access methods
function GUI:GetConfigValue(configPath)
	return GetConfigValue(configPath)
end

function GUI:SetConfigValue(configPath, value)
	return SetConfigValue(configPath, value)
end

-- Enhanced functionality methods
function GUI:FilterCategories(searchText)
	if not searchText or searchText == "" then
		for _, category in ipairs(self.Categories) do
			if category.Button then
				category.Button:Show()
				-- Restore normal visuals
				if category.Button.Text then
					category.Button.Text:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
				end
				if category.Button.Icon then
					category.Button.Icon:SetVertexColor(1, 1, 1, 1)
				end
				if category.Button.KKUI_Background and self.ActiveCategory ~= category then
					category.Button.KKUI_Background:SetVertexColor(0.08, 0.08, 0.08, 0.8)
				end
				category.Button:SetAlpha(1)
			end
		end
		return
	end

	searchText = searchText:lower()
	local hasVisibleCategories = false

	for _, category in ipairs(self.Categories) do
		local shouldShow = false

		if category.Name:lower():find(searchText) then
			shouldShow = true
		else
			for _, section in ipairs(category.Sections) do
				if section.Name:lower():find(searchText) then
					shouldShow = true
					break
				end
			end
		end

		if category.Button then
			-- Keep all buttons shown, dim non-matching
			category.Button:Show()
			if shouldShow then
				hasVisibleCategories = true
				category.Button:SetAlpha(1)
				if category.Button.Text then
					category.Button.Text:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
				end
				if category.Button.Icon then
					category.Button.Icon:SetVertexColor(1, 1, 1, 1)
				end
				-- Keep background as selection/non-selection color
			else
				category.Button:SetAlpha(0.45)
				if category.Button.Text then
					category.Button.Text:SetTextColor(0.6, 0.6, 0.6, 1)
				end
				if category.Button.Icon then
					category.Button.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
				end
				-- If not the active category, also slightly dim background
				if category.Button.KKUI_Background and self.ActiveCategory ~= category then
					category.Button.KKUI_Background:SetVertexColor(0.06, 0.06, 0.06, 0.7)
				end
			end
		end
	end

	if self.ActiveCategory and self.ActiveCategory.Button and not self.ActiveCategory.Button:IsShown() then
		for _, category in ipairs(self.Categories) do
			if category.Button and category.Button:IsShown() then
				self:ShowCategory(category)
				break
			end
		end
	end
end

function GUI:RefreshAllWidgets()
	for _, category in ipairs(self.Categories) do
		for _, section in ipairs(category.Sections) do
			for _, widget in ipairs(section.Widgets) do
				if widget.UpdateValue then
					widget:UpdateValue()
				end
				if widget:IsShown() then
					widget:Hide()
					widget:Show()
				end
			end
		end
	end

	if self.CurrentCategory then
		PopulateContent(self.CurrentCategory)
	end
end

-- Create Static Popups for NewGUI System
function GUI:CreateStaticPopups()
	-- Profile switching confirmation
	StaticPopupDialogs["KKTHNXUI_SWITCH_PROFILE"] = {
		text = "Switch to profile: %s?\n\nThis will reload your UI.",
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			ReloadUI()
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}

	-- Profile reset confirmation
	StaticPopupDialogs["KKTHNXUI_RESET_PROFILE"] = {
		text = "Reset current profile to defaults?\n\nThis will reload your UI and cannot be undone.",
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			GUI:ResetProfile()
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}

	-- Settings import dialog
	StaticPopupDialogs["KKTHNXUI_IMPORT_SETTINGS"] = {
		text = "Paste your settings string below:",
		button1 = "Import",
		button2 = CANCEL,
		hasEditBox = true,
		editBoxWidth = 350,
		OnAccept = function(self)
			local text = self.editBox:GetText()
			GUI:ImportSettings(text)
		end,
		OnShow = function(self)
			self.editBox:SetFocus()
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}

	-- Settings export dialog
	StaticPopupDialogs["KKTHNXUI_EXPORT_SETTINGS"] = {
		text = "Copy your settings string below:",
		button1 = OKAY,
		hasEditBox = true,
		editBoxWidth = 350,
		OnShow = function(self)
			self.editBox:SetText(GUI:GenerateExportString())
			self.editBox:HighlightText()
			self.editBox:SetFocus()
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}

	-- UI reload confirmation
	StaticPopupDialogs["KKTHNXUI_NEW_GUI_RELOAD"] = {
		text = "Changes have been made that require a UI reload.\n\nReload now?",
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			ReloadUI()
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}

	-- Automatic UI reload detection (Similar to NDUI)
	StaticPopupDialogs["KKTHNXUI_RELOAD_UI"] = {
		text = "Some settings you changed require a UI reload to take effect.\n\nWould you like to reload the UI now?",
		button1 = "Reload Now",
		button2 = "Later",
		OnAccept = function()
			ReloadTracker:ClearQueue() -- Clear before reload
			ReloadUI()
		end,
		OnCancel = function()
			-- User chose "Later" - clear the showing flag but keep pending reloads
			ReloadTracker.IsShowing = false
		end,
		OnHide = function()
			-- Reset showing flag when popup is hidden
			ReloadTracker.IsShowing = false
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}

	-- Simple copy path helper
	StaticPopupDialogs["KKTHNXUI_COPY_PATH"] = {
		text = "Config Path:\n%s",
		button1 = OKAY,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}
end

-- Placeholder functions for profile management
function GUI:SwitchProfile(profileName)
	print("|cff669DFFKkthnxUI:|r Switching to profile '" .. profileName .. "'...")
	ReloadUI()
end

function GUI:ResetProfile()
	print("|cff669DFFKkthnxUI:|r Resetting profile to defaults...")
	ReloadUI()
end

function GUI:ImportSettings(settingsString)
	print("|cff669DFFKkthnxUI:|r Settings import not yet fully implemented")
end

function GUI:GenerateExportString()
	return "-- Export string generation not yet implemented"
end

-- Module OnEnable Function (required by KkthnxUI)
function Module:OnEnable()
	-- print("|cff669DFFKkthnxUI:|r NewGUI module enabled! Use /kgui to open configuration.")

	-- Note: ProfileGUI initialization is now handled in Loading.lua to ensure proper order
	-- Removed duplicate initialization to prevent conflicts

	-- Setup slash commands
	self:SetupSlashCommands()

	-- Initialize GUI if categories exist
	if #self.GUI.Categories > 0 then
	end
end

-- Add Enable method to Module for Core/Loading.lua compatibility
function Module:Enable()
	if self.GUI and self.GUI.Enable then
		return self.GUI:Enable()
	else
		print("|cffff0000KkthnxUI Error:|r GUI Enable method not available!")
	end
end

function Module:InitializeGUI()
	-- This method will be called to initialize the GUI framework
	-- Load the NewGUIConfig.lua file to populate categories and settings

	-- Initialize the GUI framework only when called explicitly by Loading.lua
	if not self.GUI.IsInitialized then
		self.GUI:Initialize()
	end
end

function Module:SetupSlashCommands()
	-- Enhanced slash commands
	SlashCmdList["KKTHNXUI_NEW_GUI"] = function(cmd)
		local command = cmd:lower()

		if command == "export" then
			self.GUI:ExportSettings()
		elseif command == "import" then
			StaticPopup_Show("KKTHNXUI_IMPORT_SETTINGS")
		elseif command == "refresh" then
			self.GUI:RefreshAllWidgets()
			print("All widget values refreshed!")
		elseif command == "reload" then
			StaticPopup_Show("KKTHNXUI_NEW_GUI_RELOAD")
		elseif command == "reset" then
			StaticPopup_Show("KKTHNXUI_RESET_PROFILE")
		elseif command == "test" then
			self.GUI:TestReloadSystem()
		elseif command == "testchange" then
			self.GUI:TestSettingChange()
		elseif command == "debug" then
			self.GUI:DebugReloadSystem()
		elseif command == "help" then
			print("|cff669DFFKkthnxUI NewGUI Commands:|r")
			print("/kgui - Open configuration panel")
			print("/kgui help - Show this help")
			print("/kgui export - Export settings")
			print("/kgui import - Import settings")
			print("/kgui reload - Reload UI")
			print("/kgui reset - Reset current profile")
			print("/kgui refresh - Refresh all widgets")
			print("/kgui test - Test reload system")
			print("/kgui testchange - Test setting change")
			print("/kgui debug - Debug reload system")
		else
			self.GUI:Toggle()
		end
	end

	SLASH_KKTHNXUI_NEW_GUI1 = "/kgui"
	SLASH_KKTHNXUI_NEW_GUI2 = "/config"
end

-- Export to global for compatibility
K.NewGUI = Module.GUI
_G.KkthnxUI_NewGUI = Module.GUI

-- Export IsNew constant globally for use in config files
K.IsNew = IsNew
_G.IsNew = IsNew
-- Export Module to K for access
K.GUI = Module

-- Shared GUI helpers for reuse in ExtraGUI/ProfileGUI
if not K.GUIHelpers then
	K.GUIHelpers = {}
end

-- Expose commonly used helpers for reuse in ExtraGUI/ProfileGUI
K.GUIHelpers.ProcessNewTag = K.GUIHelpers.ProcessNewTag or ProcessNewTag
K.GUIHelpers.AddNewTag = K.GUIHelpers.AddNewTag or AddNewTag
K.GUIHelpers.CreateColoredBackground = K.GUIHelpers.CreateColoredBackground or CreateColoredBackground
K.GUIHelpers.CreateEnhancedTooltip = K.GUIHelpers.CreateEnhancedTooltip or CreateEnhancedTooltip
K.GUIHelpers.CreateButton = K.GUIHelpers.CreateButton or CreateButton

-- Simple scroll attach helper for consistent mousewheel behavior
function K.GUIHelpers.AttachSimpleScroll(scrollFrame, step)
	if not scrollFrame or type(scrollFrame.SetScript) ~= "function" then
		return
	end
	local scrollStep = step or 30
	scrollFrame:EnableMouseWheel(true)
	scrollFrame:SetScript("OnMouseWheel", function(self, delta)
		local cur = self:GetVerticalScroll() or 0
		local max = self:GetVerticalScrollRange() or 0
		local newVal = cur - (delta * scrollStep)
		if newVal < 0 then
			newVal = 0
		elseif newVal > max then
			newVal = max
		end
		self:SetVerticalScroll(newVal)
	end)
end

-- Lightweight object pool for dropdown option buttons to reduce GC and CPU
if not K.GUIHelpers._optionButtonPool then
	K.GUIHelpers._optionButtonPool = {}
end

local function AcquireOptionButton(parent, width, height)
	local pool = K.GUIHelpers._optionButtonPool
	local btn = table.remove(pool)
	if not btn then
		btn = CreateFrame("Button", nil, parent)
		btn:SetSize(width, height)

		local bg = btn:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints()
		bg:SetTexture(C["Media"].Textures.White8x8Texture)
		bg:SetVertexColor(0, 0, 0, 0)
		btn._bg = bg

		local sample = btn:CreateTexture(nil, "ARTWORK")
		sample:SetPoint("RIGHT", btn, "RIGHT", -6, 0)
		sample:Hide()
		btn._sample = sample

		local txt = btn:CreateFontString(nil, "OVERLAY")
		txt:SetFontObject(K.UIFont)
		txt:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		txt:SetPoint("LEFT", 8, 0)
		txt:SetJustifyH("LEFT")
		btn._text = txt
	else
		btn:SetParent(parent)
		btn:ClearAllPoints()
		btn:SetSize(width, height)
		btn:Show()
	end
	return btn
end

local function ReleaseOptionButtons(buttons)
	local pool = K.GUIHelpers._optionButtonPool
	for _, btn in ipairs(buttons) do
		btn:Hide()
		btn:SetScript("OnEnter", nil)
		btn:SetScript("OnLeave", nil)
		btn:SetScript("OnClick", nil)
		btn._text:SetText("")
		btn._bg:SetVertexColor(0, 0, 0, 0)
		btn._sample:SetTexture(nil)
		btn._sample:Hide()
		table.insert(pool, btn)
	end
end

-- Unified dropdown menu helper (overlay, search, scroll, keyboard, previews)
-- Usage:
-- K.GUIHelpers.OpenDropdownMenu(anchorButton, {
-- 	options = { {text=..., value=..., texture=..., icon=...}, ... },
-- 	getValue = function() return currentValue end,
-- 	onSelect = function(option) end,
-- 	menuWidth = 220,
-- 	visibleCount = 10,
-- 	showSearchOver = 10,
-- })
function K.GUIHelpers.OpenDropdownMenu(anchorButton, args)
	if not anchorButton or not args or not args.options then
		return
	end

	-- Close existing helper menu if open
	if K.GUIHelpers._menu and K.GUIHelpers._menu:IsShown() then
		K.GUIHelpers._menu:Hide()
		K.GUIHelpers._menu = nil
	end
	if K.GUIHelpers._blocker and K.GUIHelpers._blocker:IsShown() then
		K.GUIHelpers._blocker:Hide()
	end

	local options = args.options
	local getValue = args.getValue or function()
		return nil
	end
	local onSelect = args.onSelect or function(_) end
	local menuWidth = args.menuWidth or 220
	local visibleCount = args.visibleCount or 10
	local searchThreshold = args.showSearchOver or 10

	local menu = CreateFrame("Frame", nil, UIParent)
	local itemHeight = 22
	local useSearch = #options > searchThreshold
	local searchHeight = useSearch and 24 or 0
	local menuHeight = math.min(#options, visibleCount) * itemHeight + 4 + searchHeight
	menu:SetSize(menuWidth, menuHeight)
	menu:SetPoint("TOPLEFT", anchorButton, "BOTTOMLEFT", 0, -2)
	menu:SetFrameStrata("TOOLTIP")
	menu:SetFrameLevel(1000)
	menu:SetClampedToScreen(true)

	local menuBg = menu:CreateTexture(nil, "BACKGROUND")
	menuBg:SetAllPoints()
	menuBg:SetTexture(C["Media"].Textures.White8x8Texture)
	menuBg:SetVertexColor(0.1, 0.1, 0.1, 0.95)

	local menuBorder = CreateFrame("Frame", nil, menu)
	menuBorder:SetPoint("TOPLEFT", -1, 1)
	menuBorder:SetPoint("BOTTOMRIGHT", 1, -1)
	menuBorder:SetFrameLevel(menu:GetFrameLevel() - 1)
	local borderTexture = menuBorder:CreateTexture(nil, "BACKGROUND")
	borderTexture:SetAllPoints()
	borderTexture:SetTexture(C["Media"].Textures.White8x8Texture)
	borderTexture:SetVertexColor(0.3, 0.3, 0.3, 0.8)

	local container = menu
	local scrollChild, scrollFrame
	local searchBox
	if useSearch then
		local searchFrame = CreateFrame("Frame", nil, menu)
		searchFrame:SetSize(menuWidth - 4, searchHeight)
		searchFrame:SetPoint("TOPLEFT", 2, -2)
		local searchBg = searchFrame:CreateTexture(nil, "BACKGROUND")
		searchBg:SetAllPoints()
		searchBg:SetTexture(C["Media"].Textures.White8x8Texture)
		searchBg:SetVertexColor(0.08, 0.08, 0.08, 1)
		searchBox = CreateFrame("EditBox", nil, searchFrame)
		searchBox:SetAllPoints()
		searchBox:SetFontObject(K.UIFont)
		searchBox:SetAutoFocus(true)
		searchBox:SetTextColor(0.9, 0.9, 0.9, 1)
		searchBox:SetJustifyH("LEFT")
		searchBox:SetText("")
		searchBox:EnableKeyboard(true)
		if searchBox.SetPropagateKeyboardInput then
			searchBox:SetPropagateKeyboardInput(false)
		end
	end

	if #options > visibleCount then
		scrollFrame = CreateFrame("ScrollFrame", nil, menu)
		scrollFrame:SetPoint("TOPLEFT", 2, -(2 + searchHeight))
		scrollFrame:SetPoint("BOTTOMRIGHT", -2, 2)
		scrollFrame:EnableMouseWheel(true)
		scrollFrame:SetScript("OnMouseWheel", function(self, delta)
			local current = self:GetVerticalScroll()
			local maxScroll = self:GetVerticalScrollRange()
			local step = itemHeight
			if delta > 0 then
				self:SetVerticalScroll(math.max(0, current - step))
			else
				self:SetVerticalScroll(math.min(maxScroll, current + step))
			end
		end)

		scrollChild = CreateFrame("Frame", nil, scrollFrame)
		scrollChild:SetSize(menuWidth - 4, #options * itemHeight)
		scrollFrame:SetScrollChild(scrollChild)
		container = scrollChild
	end

	local optionButtons = {}
	local function RepositionVisibleButtons()
		local y = -2
		local visibleCountLocal = 0
		for _, btn in ipairs(optionButtons) do
			if btn:IsShown() then
				btn:ClearAllPoints()
				btn:SetPoint("TOPLEFT", container, "TOPLEFT", 2, y)
				y = y - itemHeight
				visibleCountLocal = visibleCountLocal + 1
			end
		end
		if scrollChild then
			scrollChild:SetHeight(math.max(visibleCountLocal * itemHeight, visibleCount * itemHeight))
		end
	end

	for i, option in ipairs(options) do
		local optionButton = AcquireOptionButton(container, menuWidth - 4, itemHeight - 2)
		optionButton:SetPoint("TOPLEFT", 2, -(i - 1) * itemHeight - 2)

		local sample = optionButton._sample
		sample:Hide()
		if option.texture then
			sample:SetSize(70, 8)
			sample:SetTexture(option.texture)
			sample:SetHorizTile(true)
			sample:Show()
		elseif option.icon then
			sample:SetSize(14, 14)
			sample:SetTexture(option.icon)
			sample:SetHorizTile(false)
			sample:Show()
		end

		local optionText = optionButton._text
		optionText:SetText(option.text)
		optionText:ClearAllPoints()
		optionText:SetPoint("LEFT", 8, 0)
		if sample:IsShown() then
			optionText:SetPoint("RIGHT", sample, "LEFT", -8, 0)
		else
			optionText:SetPoint("RIGHT", optionButton, "RIGHT", -8, 0)
		end

		local optionBg = optionButton._bg
		local currentValue = getValue()
		if option.value == currentValue then
			optionBg:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 0.3)
		else
			optionBg:SetVertexColor(0, 0, 0, 0)
		end

		optionButton:SetScript("OnEnter", function()
			if option.value ~= getValue() then
				optionBg:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 0.2)
			end
			optionText:SetTextColor(1, 1, 1, 1)
		end)

		optionButton:SetScript("OnLeave", function()
			if option.value == getValue() then
				optionBg:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 0.3)
			else
				optionBg:SetVertexColor(0, 0, 0, 0)
			end
			optionText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		end)

		optionButton:SetScript("OnClick", function()
			onSelect(option)
			if K.GUIHelpers._blocker then
				K.GUIHelpers._blocker:Hide()
			end
			menu:Hide()
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end)

		optionButton.OptionText = option.text:lower()
		table.insert(optionButtons, optionButton)
	end

	if searchBox then
		searchBox:SetScript("OnTextChanged", function(self)
			local query = self:GetText():lower()
			for _, btn in ipairs(optionButtons) do
				local show = (query == "" or btn.OptionText:find(query, 1, true) ~= nil)
				btn:SetShown(show)
			end
			RepositionVisibleButtons()
		end)
		searchBox:SetScript("OnKeyDown", function(self, key)
			if menu and menu:GetScript("OnKeyDown") then
				menu:GetScript("OnKeyDown")(menu, key)
			end
		end)
	end

	local function EnsureVisible(idx)
		if not scrollFrame then
			return
		end
		local btn = optionButtons[idx]
		if not btn or not btn:IsShown() then
			return
		end
		local offset = math.abs(select(5, btn:GetPoint(1)) or 0)
		local current = scrollFrame:GetVerticalScroll()
		local topVisible = current
		local bottomVisible = current + visibleCount * itemHeight
		if offset < topVisible then
			scrollFrame:SetVerticalScroll(offset)
		elseif offset + itemHeight > bottomVisible then
			scrollFrame:SetVerticalScroll(offset - visibleCount * itemHeight + itemHeight)
		end
	end

	local function SetHighlight(index)
		for i, btn in ipairs(optionButtons) do
			if btn:IsShown() then
				if i == index then
					btn:GetRegions():SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 0.25)
					EnsureVisible(i)
				else
					btn:GetRegions():SetVertexColor(0, 0, 0, 0)
				end
			end
		end
	end

	local currentIndex = 1
	for i, btn in ipairs(optionButtons) do
		if btn:IsShown() then
			currentIndex = i
			break
		end
	end
	SetHighlight(currentIndex)

	menu:EnableKeyboard(true)
	if menu.SetPropagateKeyboardInput then
		menu:SetPropagateKeyboardInput(false)
	end
	menu:SetScript("OnKeyDown", function(self, key)
		if key == "ESCAPE" then
			if K.GUIHelpers._blocker then
				K.GUIHelpers._blocker:Hide()
			end
			self:Hide()
			return
		end
		if key == "UP" then
			local i = currentIndex - 1
			while i >= 1 and (not optionButtons[i]:IsShown()) do
				i = i - 1
			end
			if i >= 1 then
				currentIndex = i
				SetHighlight(currentIndex)
			end
			return
		end
		if key == "DOWN" then
			local i = currentIndex + 1
			while i <= #optionButtons and (not optionButtons[i]:IsShown()) do
				i = i + 1
			end
			if i <= #optionButtons then
				currentIndex = i
				SetHighlight(currentIndex)
			end
			return
		end
		if key == "ENTER" or key == "SPACE" then
			local btn = optionButtons[currentIndex]
			if btn and btn:IsShown() and btn:GetScript("OnClick") then
				btn:GetScript("OnClick")(btn)
			end
			return
		end
	end)

	-- Outside click blocker
	local blocker = K.GUIHelpers._blocker or CreateFrame("Button", nil, UIParent)
	blocker:SetAllPoints(UIParent)
	blocker:SetFrameStrata("TOOLTIP")
	blocker:SetFrameLevel(900)
	blocker:EnableMouse(true)
	blocker:SetScript("OnMouseDown", function()
		menu:Hide()
	end)
	blocker:Show()
	K.GUIHelpers._blocker = blocker

	menu:SetScript("OnHide", function()
		if blocker then
			blocker:Hide()
		end
		-- Release pooled option buttons for reuse
		if optionButtons and #optionButtons > 0 then
			ReleaseOptionButtons(optionButtons)
		end
		if menu == K.GUIHelpers._menu then
			K.GUIHelpers._menu = nil
		end
	end)

	-- Reposition upward if needed
	C_Timer.After(0, function()
		if not menu:IsShown() then
			return
		end
		local scale = UIParent:GetEffectiveScale()
		local bottom = menu:GetBottom() or 0
		if bottom * scale < 10 then
			menu:ClearAllPoints()
			menu:SetPoint("BOTTOMLEFT", anchorButton, "TOPLEFT", 0, 2)
		end
	end)

	menu:Show()
	K.GUIHelpers._menu = menu
end

-- Enable/disable a GUI widget with visual dimming and click blocking
function K.GUIHelpers.SetWidgetEnabled(widget, enabled)
	if not widget then
		return
	end

	-- Lazy-create an overlay that blocks interaction when disabled
	if not widget._disableOverlay then
		local overlay = CreateFrame("Frame", nil, widget)
		overlay:SetAllPoints()
		overlay:SetFrameLevel(widget:GetFrameLevel() + 20)
		overlay:EnableMouse(true)
		overlay:Hide()

		-- Soft dim background to reinforce disabled state
		local dim = overlay:CreateTexture(nil, "BACKGROUND")
		dim:SetAllPoints()
		dim:SetTexture(C["Media"].Textures.White8x8Texture)
		dim:SetVertexColor(0, 0, 0, 0.25)

		widget._disableOverlay = overlay
	end

	if enabled then
		widget:SetAlpha(1)
		widget._disableOverlay:Hide()
	else
		widget:SetAlpha(0.5)
		widget._disableOverlay:Show()
	end
end

-- Bind a child widget's enabled state to a parent config path
-- child is enabled only when predicate(newValue) returns true.
-- By default, predicate checks equality with expectedValue (defaults to true).
function K.GUIHelpers.BindDependency(childWidget, parentConfigPath, expectedValue, predicate, friendlyName)
	if not childWidget or not parentConfigPath then
		return
	end

	local expected = expectedValue
	if expected == nil then
		expected = true
	end

	local function evaluate(val)
		if type(predicate) == "function" then
			local ok, res = pcall(predicate, val)
			if ok then
				return not not res
			end
			return false
		end
		return val == expected
	end

	local function update()
		local current = GetValueByPath(C, parentConfigPath)
		K.GUIHelpers.SetWidgetEnabled(childWidget, evaluate(current))
	end

	-- Add explanatory tooltip while disabled
	if not childWidget._dependencyTooltipSetup then
		childWidget._dependencyTooltipSetup = true
		local function showWhyDisabled(self)
			if not self:IsShown() then
				return
			end
			local title = childWidget.DisplayText or "Option Disabled"
			local expectedText
			if type(expected) == "boolean" then
				expectedText = expected and "enabled" or "disabled"
			else
				expectedText = tostring(expected)
			end
			local current = GetValueByPath(C, parentConfigPath)
			if current == nil and K and K.Defaults then
				local def = GetValueByPath(K.Defaults, parentConfigPath)
				if def ~= nil then
					current = def
				end
			end
			local currentText
			if type(current) == "boolean" then
				currentText = current and "enabled" or "disabled"
			else
				currentText = tostring(current or "unset")
			end
			local targetName = friendlyName or parentConfigPath
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(title, 1, 1, 1, 1, true)
			GameTooltip:AddLine("Requires " .. targetName .. " = " .. expectedText, 0.8, 0.8, 0.8, true)
			GameTooltip:AddLine("Current: " .. currentText, 0.6, 0.6, 0.6, true)
			GameTooltip:Show()
		end
		local function hideTooltip()
			GameTooltip:Hide()
		end
		-- Ensure overlay exists so it blocks mouse and holds tooltip
		K.GUIHelpers.SetWidgetEnabled(childWidget, true) -- create overlay if missing
		if childWidget._disableOverlay then
			childWidget._disableOverlay:SetScript("OnEnter", showWhyDisabled)
			childWidget._disableOverlay:SetScript("OnLeave", hideTooltip)
		end
	end

	-- Ensure we re-evaluate whenever the widget is shown (post layout/reload)
	if not childWidget._dependencyOnShowHooked then
		childWidget._dependencyOnShowHooked = true
		childWidget:HookScript("OnShow", function()
			update()
		end)
	end

	-- Initial state
	update()

	-- Listen for parent changes via GUI hook system when available
	if K.GUI and K.GUI.GUI and K.GUI.GUI.RegisterHook then
		K.GUI.GUI:RegisterHook(parentConfigPath, function(newValue)
			K.GUIHelpers.SetWidgetEnabled(childWidget, evaluate(newValue))
		end)
	elseif K.GUI and K.GUI.RegisterHook then
		K.GUI:RegisterHook(parentConfigPath, function(newValue)
			K.GUIHelpers.SetWidgetEnabled(childWidget, evaluate(newValue))
		end)
	end

	return childWidget
end

-- Public method for modules/config to declare dependencies
function GUI:DependsOn(childWidget, parentConfigPath, expectedValue, predicate)
	return K.GUIHelpers.BindDependency(childWidget, parentConfigPath, expectedValue, predicate)
end

-- Credits Widget - Supports class icons and class colors
local function CreateCredits(parent, creditsData, title)
	local widget = CreateFrame("Frame", nil, parent)

	-- Calculate total height based on credits data
	local titleHeight = title and 40 or 0
	local itemHeight = 28
	local totalHeight = titleHeight + (#creditsData * itemHeight) + 30 -- extra padding

	widget:SetSize(CONTENT_WIDTH, totalHeight)

	-- Background
	CreateColoredBackground(widget, WIDGET_BG[1], WIDGET_BG[2], WIDGET_BG[3], WIDGET_BG[4])

	local yOffset = -15

	-- Title if provided
	if title then
		local titleLabel = widget:CreateFontString(nil, "OVERLAY")
		titleLabel:SetFontObject(K.UIFontBold or K.UIFont)
		titleLabel:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		titleLabel:SetText(title)
		titleLabel:SetPoint("TOPLEFT", 15, yOffset)
		yOffset = yOffset - 35
	end

	-- Credits entries
	for i, credit in ipairs(creditsData) do
		local creditFrame = CreateFrame("Frame", nil, widget)
		creditFrame:SetSize(CONTENT_WIDTH - 30, itemHeight - 2)
		creditFrame:SetPoint("TOPLEFT", 15, yOffset)

		-- Entry background with hover effect
		local entryBg = creditFrame:CreateTexture(nil, "BACKGROUND")
		entryBg:SetAllPoints()
		entryBg:SetTexture(C["Media"].Textures.White8x8Texture)
		entryBg:SetVertexColor(0.08, 0.08, 0.08, 0.6)

		-- Hover effect
		creditFrame:EnableMouse(true)
		creditFrame:SetScript("OnEnter", function(self)
			entryBg:SetVertexColor(0.12, 0.12, 0.12, 0.8)
		end)
		creditFrame:SetScript("OnLeave", function(self)
			entryBg:SetVertexColor(0.08, 0.08, 0.08, 0.6)
		end)

		local xOffset = 10

		-- Class icon (if provided) - Fixed proper implementation
		if credit.class and credit.class ~= "" then
			local classIcon = creditFrame:CreateTexture(nil, "ARTWORK")
			classIcon:SetSize(14, 14) -- Smaller size to prevent overlap
			classIcon:SetPoint("LEFT", xOffset, 0)

			-- Use the more reliable class icon texture instead of atlas
			local classFile = credit.class:upper()

			-- Use the standard class icon texture path
			classIcon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
			classIcon:SetSize(14, 14) -- Ensure consistent size

			-- Define class icon coordinates
			local classCoords = {
				["WARRIOR"] = { 0, 0.25, 0, 0.25 },
				["MAGE"] = { 0.25, 0.49609375, 0, 0.25 },
				["ROGUE"] = { 0.49609375, 0.7421875, 0, 0.25 },
				["DRUID"] = { 0.7421875, 0.98828125, 0, 0.25 },
				["HUNTER"] = { 0, 0.25, 0.25, 0.5 },
				["SHAMAN"] = { 0.25, 0.49609375, 0.25, 0.5 },
				["PRIEST"] = { 0.49609375, 0.7421875, 0.25, 0.5 },
				["WARLOCK"] = { 0.7421875, 0.98828125, 0.25, 0.5 },
				["PALADIN"] = { 0, 0.25, 0.5, 0.75 },
				["DEATHKNIGHT"] = { 0.25, 0.49609375, 0.5, 0.75 },
				["MONK"] = { 0.49609375, 0.7421875, 0.5, 0.75 },
				["DEMONHUNTER"] = { 0.7421875, 0.98828125, 0.5, 0.75 },
				["EVOKER"] = { 0, 0.25, 0.75, 1 },
			}

			local coords = classCoords[classFile]
			if coords then
				classIcon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
			else
				-- Use a default icon if class not recognized
				classIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
				classIcon:SetTexCoord(0, 1, 0, 1)
				classIcon:SetSize(14, 14) -- Maintain size for fallback icon
			end

			xOffset = xOffset + 18 -- Adjusted spacing for smaller icons
		end

		-- Name text with color support
		local nameText = creditFrame:CreateFontString(nil, "OVERLAY")
		nameText:SetFontObject(K.UIFont)
		nameText:SetPoint("LEFT", xOffset, 0)

		-- Determine text color and set text
		if credit.color then
			if type(credit.color) == "string" and credit.color:sub(1, 1) == "|" then
				-- Color escape sequence like "|cffff0000"
				nameText:SetText(credit.color .. credit.name .. "|r")
			elseif type(credit.color) == "table" and #credit.color >= 3 then
				-- RGB color table
				nameText:SetText(credit.name)
				nameText:SetTextColor(credit.color[1], credit.color[2], credit.color[3], credit.color[4] or 1)
			elseif type(credit.color) == "string" and RAID_CLASS_COLORS[credit.color:upper()] then
				-- Class color by name
				local classColor = RAID_CLASS_COLORS[credit.color:upper()]
				nameText:SetText(credit.name)
				nameText:SetTextColor(classColor.r, classColor.g, classColor.b, 1)
			else
				-- Default white
				nameText:SetText(credit.name)
				nameText:SetTextColor(1, 1, 1, 1)
			end
		elseif credit.class and RAID_CLASS_COLORS[credit.class:upper()] then
			-- Use class color from class field
			local classColor = RAID_CLASS_COLORS[credit.class:upper()]
			nameText:SetText(credit.name)
			nameText:SetTextColor(classColor.r, classColor.g, classColor.b, 1)
		else
			-- Default white
			nameText:SetText(credit.name)
			nameText:SetTextColor(1, 1, 1, 1)
		end

		-- Check for atlas icon (for special entries like heart) - Position AFTER name text
		if credit.atlas then
			local atlasIcon = creditFrame:CreateTexture(nil, "ARTWORK")
			atlasIcon:SetSize(14, 14)
			atlasIcon:SetPoint("LEFT", nameText, "RIGHT", 5, 0) -- Position to the right of the name text
			atlasIcon:SetAlpha(0.9) -- Set transparency to 90%

			local success = pcall(function()
				atlasIcon:SetAtlas(credit.atlas, true)
				atlasIcon:SetSize(14, 14) -- Ensure size is maintained
			end)

			if not success then
				-- Fallback to a default texture if atlas fails
				atlasIcon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
				atlasIcon:SetTexCoord(0, 1, 0, 1)
			end
		end

		yOffset = yOffset - itemHeight
	end

	return widget
end

function GUI:CreateCredits(section, creditsData, title)
	local widget = CreateCredits(UIParent, creditsData, title)
	widget:Hide()
	self:AddWidget(section, widget)
	return widget
end

-- Helper functions for creating custom widgets in config files
function GUI:CreateButton(parent, text, width, height, onClick)
	return CreateButton(parent, text, width, height, onClick)
end

function GUI:CreateEnhancedTooltip(widget, title, description, warning)
	return CreateEnhancedTooltip(widget, title, description, warning)
end

-- Custom button widget creation
function GUI:CreateButtonWidget(section, configPath, text, buttonText, tooltip, onClick, isNew, requiresReload)
	local widget = CreateFrame("Frame", nil, UIParent)
	widget:SetSize(CONTENT_WIDTH, WIDGET_HEIGHT) -- Use proper constants
	widget.ConfigPath = configPath

	-- Background
	local bg = widget:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(C["Media"].Textures.White8x8Texture)
	bg:SetVertexColor(WIDGET_BG[1], WIDGET_BG[2], WIDGET_BG[3], WIDGET_BG[4])

	-- Process NEW tag from text
	local cleanText, hasNewTag = ProcessNewTag(text)
	-- Use isNew parameter or detected NEW tag
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

	-- Enhanced onClick wrapper that handles reload tracking
	local wrappedOnClick = function()
		if onClick then
			onClick()
		end
		-- If this button action requires reload, add it to queue
		if requiresReload then
			AddToReloadQueue(configPath, cleanText)
		end
	end

	-- Button using the CreateButton helper
	local button = CreateButton(widget, buttonText, 100, 20, wrappedOnClick)
	button:SetPoint("RIGHT", -8, 0)

	-- Enhanced tooltip
	if tooltip then
		CreateEnhancedTooltip(widget, cleanText, tooltip)
	end

	-- Hide initially and add to section
	widget:Hide()
	self:AddWidget(section, widget)
	return widget
end

-- Helper methods for reload management
function GUI:HasPendingReloads()
	return ReloadTracker:HasPendingReloads()
end

function GUI:ClearReloadQueue()
	ReloadTracker:ClearQueue()
end

function GUI:ForceReloadPrompt()
	ReloadTracker:ShowReloadPrompt()
end

-- Check if a config path requires reload (simplified)
function GUI:CheckRequiresReload(configPath)
	local hasHook = self.UpdateHooks[configPath] and #self.UpdateHooks[configPath] > 0
	return RequiresReload(configPath, hasHook, false)
end

-- Debug functions for testing the reload system
function GUI:TestReloadSystem()
	DebugLog("=== RELOAD SYSTEM TEST ===")

	-- Test 1: Add a setting without hook
	DebugLog("Test 1: Adding setting without hook")
	AddToReloadQueue("test.setting.without.hook", "Test Setting Without Hook")

	-- Test 2: Check if we have pending reloads
	DebugLog("Test 2: Checking pending reloads")
	local hasReloads = self:HasPendingReloads()
	DebugLog("Has pending reloads: " .. tostring(hasReloads))

	-- Test 3: Show reload prompt
	DebugLog("Test 3: Showing reload prompt")
	self:ForceReloadPrompt()

	DebugLog("=== RELOAD SYSTEM TEST COMPLETE ===")
end

function GUI:TestSettingChange()
	DebugLog("=== TESTING SETTING CHANGE ===")

	-- Test setting change without hook (should require reload)
	DebugLog("Testing setting change without hook")
	SetConfigValue("test.setting.no.hook", true, false, "Test Setting No Hook")

	-- Test setting change with hook (should not require reload)
	DebugLog("Testing setting change with hook")
	local testHook = function(newValue, oldValue, configPath)
		DebugLog("Test hook executed: " .. configPath .. " = " .. tostring(newValue))
	end

	-- Register the hook first
	RegisterUpdateHook("test.setting.with.hook", testHook)

	-- Then change the setting
	SetConfigValue("test.setting.with.hook", true, false, "Test Setting With Hook")

	DebugLog("=== SETTING CHANGE TEST COMPLETE ===")
end

function GUI:DebugReloadSystem()
	DebugLog("=== RELOAD SYSTEM DEBUG INFO ===")
	DebugLog("Pending reloads count: " .. (next(ReloadTracker.PendingReloads) and "some" or "none"))

	if next(ReloadTracker.PendingReloads) then
		for configPath, settingName in pairs(ReloadTracker.PendingReloads) do
			DebugLog("Pending reload: " .. configPath .. " (" .. settingName .. ")")
		end
	end

	DebugLog("Is showing: " .. tostring(ReloadTracker.IsShowing))

	DebugLog("Registered hooks count: " .. (next(GUI.UpdateHooks) and "some" or "none"))
	if next(GUI.UpdateHooks) then
		for configPath, hooks in pairs(GUI.UpdateHooks) do
			DebugLog("Hooks for " .. configPath .. ": " .. #hooks)
		end
	end

	DebugLog("=== RELOAD SYSTEM DEBUG INFO COMPLETE ===")
end
