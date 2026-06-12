local K, C = KkthnxUI[1], KkthnxUI[2]

-- System Documentation

--[[
Advanced ProfileGUI System for KkthnxUI

Inspired by NDui's ProfileGUI system, this provides comprehensive
profile management including:
- Profile list management with visual interface
- Create, copy, delete, reset profiles
- Data validation and error handling
- Import/export with improved security
- Profile sharing and backup
- Automatic profile switching options
- Modern UI design
]]

-- API Declarations

-- Lua API
local _G = _G
local ipairs, pairs = ipairs, pairs
local type = type
local select = select
local tinsert = table.insert
local time = time
local date = date
local UnitClass = UnitClass
local UnitRace = UnitRace
local UnitSex = UnitSex
local UnitFactionGroup = UnitFactionGroup

-- WoW API
local CreateFrame = CreateFrame
local UIParent = UIParent
local ReloadUI = ReloadUI
local PlaySound = PlaySound
local SOUNDKIT = SOUNDKIT

-- Utility Functions

-- String utility functions
local function trim(str)
	if not str then
		return ""
	end
	return str:match("^%s*(.-)%s*$") or ""
end

-- UI Constants

-- Panel Dimensions: shared metrics come from K.GUILayout (WidgetFactory.lua).
-- NOTE: the profile manager is intentionally narrower than the main config, so
-- PANEL_WIDTH stays a local 560 and does NOT read layout.PanelWidth.
local layout = K.GUILayout
local PANEL_WIDTH = 560
local PANEL_HEIGHT = layout.PanelHeight
local LIST_WIDTH = 200
local LIST_HEIGHT = 420
local BUTTON_HEIGHT = layout.RowHeight
local SPACING = layout.Spacing
local HEADER_HEIGHT = layout.HeaderHeight

-- Colors: pull from the shared K.GUITheme (WidgetFactory.lua) so the profile
-- manager matches the main config exactly. PERF: alias to file-scope locals.
-- NOTE: matches main GUI -> dimmed accent (AccentDim), not the full Accent.
local theme = K.GUITheme
local ACCENT_COLOR = theme.AccentDim
local TEXT_COLOR = theme.Text
local SUCCESS_COLOR = theme.Success
local ERROR_COLOR = theme.Error
local WARNING_COLOR = theme.Warning
local BG_COLOR = C["Media"].Backdrops.ColorBackdrop
local SIDEBAR_COLOR = theme.Sidebar
local WIDGET_BG = theme.WidgetBg
local BUTTON_HOVER = theme.ButtonHover
local SELECTED_BG = theme.Selected
-- Detail-panel text tiers + faction tints (no more raw grays/colors inline).
local HEADER_COLOR = theme.Header
local MUTED_COLOR = theme.Muted
local HINT_COLOR = theme.Hint
local FACTION_ALLIANCE = theme.FactionAlliance
local FACTION_HORDE = theme.FactionHorde

-- ProfileGUI Module Core

-- ProfileGUI Main Object
local ProfileGUI = {
	Frame = nil,
	IsVisible = false,
	CurrentProfile = nil,
	ProfileList = {},
	SelectedProfile = nil,
	LastUpdate = 0,
}

-- Helper Functions

-- Create colored background texture (matching main GUI exactly)
-- Use unified widget factory from K.WidgetFactory
local CreateColoredBackground = K.WidgetFactory.CreateBackdrop
local CreateButton = K.WidgetFactory.CreateButton
local ProfileDialogs = K.ProfileDialogs

-- Profile service bridge
local ProfileService = K.ProfileService

-- REASON: Keep the ProfileGUI public method names stable for every existing UI
-- call site, but move DB/storage/import/export responsibilities into
-- ProfileService.lua. The GUI layer should arrange frames, not own persistence.
function ProfileGUI:GetCurrentProfileKey()
	return ProfileService:GetCurrentProfileKey()
end

function ProfileGUI:GetAllProfiles()
	return ProfileService:GetAllProfiles()
end

function ProfileGUI:ValidateProfileName(name)
	return ProfileService:ValidateProfileName(name)
end

function ProfileGUI:ValidateProfileData(data)
	return ProfileService:ValidateProfileData(data)
end

function ProfileGUI:ExportProfile(profileKey)
	return ProfileService:ExportProfile(profileKey)
end

function ProfileGUI:ImportProfile(profileString, applyToCurrent)
	return ProfileService:ImportProfile(profileString, applyToCurrent)
end

function ProfileGUI:CreateProfile(profileName, sourceProfile)
	local success, message = ProfileService:CreateProfile(profileName, sourceProfile)
	if success then
		self:StoreCharacterMetadata(K.Name, K.Realm)
	end
	return success, message
end

function ProfileGUI:RenameProfile(profileKey, newName)
	local success, message, newProfileKey = ProfileService:RenameProfile(profileKey, newName)
	if success and self.SelectedProfile == profileKey then
		self.SelectedProfile = newProfileKey
	end
	return success, message
end

function ProfileGUI:DeleteProfile(profileKey)
	return ProfileService:DeleteProfile(profileKey)
end

function ProfileGUI:SwitchProfile(profileKey)
	return ProfileService:SwitchProfile(profileKey)
end

function ProfileGUI:ResetProfile(profileKey)
	return ProfileService:ResetProfile(profileKey)
end

-- UI Creation

function ProfileGUI:CreateScrollFrame(parent, width, height)
	local scrollFrame = CreateFrame("ScrollFrame", nil, parent)
	scrollFrame:SetSize(width, height)

	-- Simple background
	CreateColoredBackground(scrollFrame, 0.08, 0.08, 0.08, 0.9)

	-- Scroll child
	local scrollChild = CreateFrame("Frame", nil, scrollFrame)
	scrollChild:SetWidth(width - 20)
	scrollChild:SetHeight(1)
	scrollFrame:SetScrollChild(scrollChild)

	-- Keep child width in sync with frame width for responsive layouts
	scrollFrame:SetScript("OnSizeChanged", function(self, w)
		if self.Child and w then
			self.Child:SetWidth(math.max(1, w - 20))
		end
	end)

	-- Enable mouse wheel scrolling
	scrollFrame:EnableMouseWheel(true)
	scrollFrame:SetScript("OnMouseWheel", function(self, delta)
		local current = self:GetVerticalScroll()
		local maxScroll = self:GetVerticalScrollRange()
		local step = 30

		if delta > 0 then
			self:SetVerticalScroll(math.max(0, current - step))
		else
			self:SetVerticalScroll(math.min(maxScroll, current + step))
		end
	end)

	scrollFrame.Child = scrollChild
	return scrollFrame
end

-- Profile List
function ProfileGUI:RefreshProfileList()
	if not self.ProfileScrollFrame or not self.ProfileScrollFrame.Child then
		return
	end

	-- Refresh current character metadata to ensure it's up to date
	self:StoreCharacterMetadata(K.Name, K.Realm)

	-- Ensure button pool
	self.ProfileButtons = self.ProfileButtons or {}
	-- Hide existing buttons; we'll reuse them
	for _, btn in ipairs(self.ProfileButtons) do
		if btn.Hide then
			btn:Hide()
		end
	end

	local profiles = self:GetAllProfiles()
	local sortedProfiles = {}

	-- Sort profiles by display name
	for _, profile in pairs(profiles) do
		tinsert(sortedProfiles, profile)
	end

	table.sort(sortedProfiles, function(a, b)
		-- Current profile should appear first
		if a.isCurrent ~= b.isCurrent then
			return a.isCurrent
		end
		return a.displayName < b.displayName
	end)

	local yOffset = -8
	local buttonHeight = 32

	for index, profile in ipairs(sortedProfiles) do
		local button = self.ProfileButtons[index]
		if not button then
			button = self:CreateProfileListButton(profile)
			self.ProfileButtons[index] = button
			button:SetParent(self.ProfileScrollFrame.Child)
		else
			-- Reuse existing button; update its data and visuals
			button.Profile = profile
			if button.Text then
				button.Text:SetText(profile.name)
			end
			if button.Portrait then
				self:SetupPortrait(button.Portrait, profile.name, profile.realm)
			end
			self:UpdateProfileButtonState(button, profile)
			button:Show()
		end
		button:SetPoint("TOPLEFT", 8, yOffset)
		button:SetPoint("TOPRIGHT", -8, yOffset)
		button:SetHeight(buttonHeight)

		yOffset = yOffset - buttonHeight - 4
	end
	-- Hide any extra buttons beyond current list
	for i = #sortedProfiles + 1, #self.ProfileButtons do
		local btn = self.ProfileButtons[i]
		if btn and btn.Hide then
			btn:Hide()
		end
	end

	-- Update scroll frame content height
	local contentHeight = math.abs(yOffset) + 20
	local frameHeight = self.ProfileScrollFrame:GetHeight() or LIST_HEIGHT
	self.ProfileScrollFrame.Child:SetHeight(math.max(contentHeight, frameHeight))

	-- Auto-select current profile if no selection
	if not self.SelectedProfile and profiles then
		local currentKey = self:GetCurrentProfileKey()
		if profiles[currentKey] then
			self.SelectedProfile = currentKey
		end
	end
end

function ProfileGUI:CreateProfileListButton(profile)
	local button = CreateFrame("Button", nil, self.ProfileScrollFrame.Child)
	button:SetHeight(32)

	-- Simple button background
	local buttonBg = CreateColoredBackground(button, 0.08, 0.08, 0.08, 0.9)
	button.KKUI_Background = buttonBg

	-- Profile selection indicator
	local selected = button:CreateTexture(nil, "OVERLAY")
	selected:SetSize(3, 24)
	selected:SetPoint("LEFT", 2, 0)
	selected:SetTexture(C["Media"].Textures.White8x8Texture)
	selected:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
	selected:Hide()
	button.Selected = selected

	-- Portrait with simple styling
	local portraitFrame = CreateFrame("Frame", nil, button)
	portraitFrame:SetSize(24, 24)
	portraitFrame:SetPoint("LEFT", 12, 0)

	-- Portrait background
	local _ = CreateColoredBackground(portraitFrame, 0.12, 0.12, 0.12, 1)

	-- Portrait border
	local portraitBorder = portraitFrame:CreateTexture(nil, "BORDER")
	portraitBorder:SetPoint("TOPLEFT", -1, 1)
	portraitBorder:SetPoint("BOTTOMRIGHT", 1, -1)
	portraitBorder:SetTexture(C["Media"].Textures.White8x8Texture)
	portraitBorder:SetVertexColor(0.3, 0.3, 0.3, 0.8)

	-- Portrait texture
	local portrait = portraitFrame:CreateTexture(nil, "ARTWORK")
	portrait:SetPoint("TOPLEFT", 2, -2)
	portrait:SetPoint("BOTTOMRIGHT", -2, 2)

	self:SetupPortrait(portrait, profile.name, profile.realm)

	button.Portrait = portrait
	button.PortraitFrame = portraitFrame
	button.PortraitBorder = portraitBorder

	-- Profile name text
	local nameText = button:CreateFontString(nil, "OVERLAY")
	nameText:SetFontObject(K.UIFont)
	nameText:SetPoint("LEFT", portraitFrame, "RIGHT", 8, 0)
	nameText:SetPoint("RIGHT", button, "RIGHT", -8, 0)
	nameText:SetJustifyH("LEFT")
	nameText:SetText(profile.name)
	nameText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	button.Text = nameText

	-- Simplified tooltip - only essential info
	button:SetScript("OnEnter", function(self)
		if not profile.isCurrent then
			buttonBg:SetVertexColor(BUTTON_HOVER[1], BUTTON_HOVER[2], BUTTON_HOVER[3], 0.6)
		end
		nameText:SetTextColor(1, 1, 1, 1)

		-- Clean, minimal tooltip
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(profile.displayName, 1, 1, 1, 1, true)

		if profile.isCurrent then
			GameTooltip:AddLine("Currently Active Profile", SUCCESS_COLOR[1], SUCCESS_COLOR[2], SUCCESS_COLOR[3])
		else
			GameTooltip:AddLine("Click to select this profile", 0.5, 0.8, 1)
		end

		GameTooltip:Show()
	end)

	button:SetScript("OnLeave", function(buttonSelf)
		local isSelected = (self.SelectedProfile == profile.key)
		local isCurrent = profile.isCurrent

		if isCurrent then
			buttonBg:SetVertexColor(ACCENT_COLOR[1] * 0.2, ACCENT_COLOR[2] * 0.2, ACCENT_COLOR[3] * 0.2, 0.9)
			nameText:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		elseif isSelected then
			buttonBg:SetVertexColor(SELECTED_BG[1], SELECTED_BG[2], SELECTED_BG[3], SELECTED_BG[4])
			nameText:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		else
			buttonBg:SetVertexColor(0.08, 0.08, 0.08, 0.9)
			nameText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		end

		GameTooltip:Hide()
	end)

	-- Click handler
	button:SetScript("OnClick", function(self, mouseButton)
		if mouseButton == "LeftButton" then
			ProfileGUI:SelectProfile(profile.key)
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end
	end)

	button:RegisterForClicks("LeftButtonUp")
	button.Profile = profile

	-- Set initial state
	self:UpdateProfileButtonState(button, profile)

	return button
end

function ProfileGUI:ShowRenameProfileDialog()
	if not self.SelectedProfile then
		self:ShowStatusMessage("No profile selected to rename", "error")
		return
	end

	local profiles = self:GetAllProfiles()
	local profile = profiles[self.SelectedProfile]

	if profile.isCurrent then
		self:ShowStatusMessage("Cannot rename the currently active profile", "error")
		return
	end

	local _ = self:CreateInputDialog("Rename Profile", "Enter a new name for the profile '" .. profile.name .. "':", profile.name, function(newName)
		if not newName or newName == "" then
			self:ShowStatusMessage("Profile name cannot be empty", "error")
			return
		end

		if newName == profile.name then
			self:ShowStatusMessage("New name must be different from current name", "error")
			return
		end

		local success, error = self:RenameProfile(self.SelectedProfile, newName)
		if success then
			self:ShowStatusMessage("Profile renamed successfully", "success")
			self:RefreshProfileList()
			self:UpdateInfoPanel()
		else
			self:ShowStatusMessage(error, "error")
		end
	end)
end

-- Helper function to update profile button state
function ProfileGUI:UpdateProfileButtonState(button, profile)
	local isSelected = (self.SelectedProfile == profile.key)
	local isCurrent = profile.isCurrent

	-- Update background
	if isCurrent then
		button.KKUI_Background:SetVertexColor(ACCENT_COLOR[1] * 0.2, ACCENT_COLOR[2] * 0.2, ACCENT_COLOR[3] * 0.2, 0.9)
		button.Text:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
	elseif isSelected then
		button.KKUI_Background:SetVertexColor(SELECTED_BG[1], SELECTED_BG[2], SELECTED_BG[3], SELECTED_BG[4])
		button.Text:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
	else
		button.KKUI_Background:SetVertexColor(0.08, 0.08, 0.08, 0.9)
		button.Text:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	end

	-- Update selection indicator
	if isSelected or isCurrent then
		button.Selected:Show()
		if isCurrent then
			button.Selected:SetSize(4, 24)
			button.Selected:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		else
			button.Selected:SetSize(2, 24)
			button.Selected:SetVertexColor(ACCENT_COLOR[1] * 0.8, ACCENT_COLOR[2] * 0.8, ACCENT_COLOR[3] * 0.8, 0.8)
		end
	else
		button.Selected:Hide()
	end
end

function ProfileGUI:SelectProfile(profileKey)
	self.SelectedProfile = profileKey

	-- Refresh current character metadata when selecting profiles
	self:StoreCharacterMetadata(K.Name, K.Realm)

	-- Update visual feedback for all profile buttons
	if self.ProfileScrollFrame and self.ProfileScrollFrame.Child then
		for _, button in ipairs({ self.ProfileScrollFrame.Child:GetChildren() }) do
			if button.Profile then
				self:UpdateProfileButtonState(button, button.Profile)
			end
		end
	end

	-- Update info panel and button states
	self:UpdateInfoPanel()
	self:UpdateButtonStates()
end

function ProfileGUI:UpdateButtonStates()
	local hasSelection = (self.SelectedProfile ~= nil)
	local profiles = self:GetAllProfiles()
	local selectedProfile = hasSelection and profiles[self.SelectedProfile] or nil
	local isCurrentProfile = selectedProfile and selectedProfile.isCurrent or false

	-- Helper function to set button state
	local function SetButtonState(button, enabled)
		if button then
			button:SetAlpha(enabled and 1 or 0.4)
			button:EnableMouse(enabled)
		end
	end

	-- Switch To button - disabled if no selection or if selected profile is current
	SetButtonState(self.SwitchButton, hasSelection and not isCurrentProfile)

	-- Export button - enabled if has selection
	SetButtonState(self.ExportButton, hasSelection)

	-- Delete button - disabled if no selection or if selected profile is current
	SetButtonState(self.DeleteButton, hasSelection and not isCurrentProfile)

	-- Copy button - enabled if has selection
	SetButtonState(self.CopyButton, hasSelection)

	-- Rename button - disabled if no selection or if selected profile is current
	SetButtonState(self.RenameButton, hasSelection and not isCurrentProfile)

	-- Reset button - enabled if has selection
	SetButtonState(self.ResetButton, hasSelection)
end

-- Enhanced info panel with comprehensive profile details
function ProfileGUI:UpdateInfoPanel()
	if not self.InfoPanel then
		return
	end

	-- Store references to existing UI elements to avoid recreating them
	if not self.InfoElements then
		self.InfoElements = {}
	end

	-- Hide all existing elements first
	for _, element in pairs(self.InfoElements) do
		if element and element.Hide then
			element:Hide()
		end
	end

	if not self.SelectedProfile then
		-- Show "Select a profile" message
		if not self.InfoElements.NoSelectionText then
			self.InfoElements.NoSelectionText = self.InfoPanel:CreateFontString(nil, "OVERLAY")
			self.InfoElements.NoSelectionText:SetFontObject(K.UIFont)
			self.InfoElements.NoSelectionText:SetTextColor(0.6, 0.6, 0.6, 1)
			self.InfoElements.NoSelectionText:SetPoint("CENTER", 0, 0)
		end

		self.InfoElements.NoSelectionText:SetText("Select a profile to view details")
		self.InfoElements.NoSelectionText:Show()
		return
	end

	-- Hide the "no selection" text
	if self.InfoElements.NoSelectionText then
		self.InfoElements.NoSelectionText:Hide()
	end

	local profiles = self:GetAllProfiles()
	local profile = profiles[self.SelectedProfile]

	if not profile then
		return
	end

	local yOffset = -12
	local maxWidth = 290 -- Prevent text overflow
	-- REASON: sub-rows used to fake indentation by jamming "  " into the string.
	-- Use a real x-offset so everything lines up on a grid instead of eyeballed spaces.
	local indentX = 26

	-- Profile name header
	if not self.InfoElements.NameLabel then
		self.InfoElements.NameLabel = self.InfoPanel:CreateFontString(nil, "OVERLAY")
		self.InfoElements.NameLabel:SetFontObject(K.UIFont)
		self.InfoElements.NameLabel:SetPoint("TOPLEFT", 15, 0)
		self.InfoElements.NameLabel:SetWidth(maxWidth)
		self.InfoElements.NameLabel:SetJustifyH("LEFT")
	end
	self.InfoElements.NameLabel:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
	self.InfoElements.NameLabel:SetText("Profile: " .. profile.name)
	self.InfoElements.NameLabel:SetPoint("TOPLEFT", 15, yOffset)
	self.InfoElements.NameLabel:Show()
	yOffset = yOffset - 20

	-- Status with visual indicator
	if not self.InfoElements.StatusLabel then
		self.InfoElements.StatusLabel = self.InfoPanel:CreateFontString(nil, "OVERLAY")
		self.InfoElements.StatusLabel:SetFontObject(K.UIFont)
		self.InfoElements.StatusLabel:SetPoint("TOPLEFT", 15, 0)
		self.InfoElements.StatusLabel:SetWidth(maxWidth)
		self.InfoElements.StatusLabel:SetJustifyH("LEFT")
	end
	if profile.isCurrent then
		self.InfoElements.StatusLabel:SetTextColor(SUCCESS_COLOR[1], SUCCESS_COLOR[2], SUCCESS_COLOR[3], 1)
		self.InfoElements.StatusLabel:SetText("Currently Active")
	else
		self.InfoElements.StatusLabel:SetTextColor(MUTED_COLOR[1], MUTED_COLOR[2], MUTED_COLOR[3], 1)
		self.InfoElements.StatusLabel:SetText("Available")
	end
	self.InfoElements.StatusLabel:SetPoint("TOPLEFT", 15, yOffset)
	self.InfoElements.StatusLabel:Show()
	yOffset = yOffset - 22

	-- Character info section
	if not self.InfoElements.CharacterHeader then
		self.InfoElements.CharacterHeader = self.InfoPanel:CreateFontString(nil, "OVERLAY")
		self.InfoElements.CharacterHeader:SetFontObject(K.UIFont)
		self.InfoElements.CharacterHeader:SetPoint("TOPLEFT", 15, 0)
		self.InfoElements.CharacterHeader:SetWidth(maxWidth)
		self.InfoElements.CharacterHeader:SetJustifyH("LEFT")
	end
	self.InfoElements.CharacterHeader:SetTextColor(HEADER_COLOR[1], HEADER_COLOR[2], HEADER_COLOR[3], 1)
	self.InfoElements.CharacterHeader:SetText("Character Information:")
	self.InfoElements.CharacterHeader:SetPoint("TOPLEFT", 15, yOffset)
	self.InfoElements.CharacterHeader:Show()
	yOffset = yOffset - 16

	-- Character name and realm
	if not self.InfoElements.CharacterLabel then
		self.InfoElements.CharacterLabel = self.InfoPanel:CreateFontString(nil, "OVERLAY")
		self.InfoElements.CharacterLabel:SetFontObject(K.UIFont)
		self.InfoElements.CharacterLabel:SetPoint("TOPLEFT", 15, 0)
		self.InfoElements.CharacterLabel:SetWidth(maxWidth)
		self.InfoElements.CharacterLabel:SetJustifyH("LEFT")
	end
	self.InfoElements.CharacterLabel:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	self.InfoElements.CharacterLabel:SetText("Name: " .. profile.name .. " @ " .. profile.realm)
	self.InfoElements.CharacterLabel:SetPoint("TOPLEFT", indentX, yOffset)
	self.InfoElements.CharacterLabel:Show()
	yOffset = yOffset - 14

	-- Character class with color
	local characterClass = self:GetClassFromGoldInfo(profile.name, profile.realm)
	if characterClass and characterClass ~= "NONE" then
		-- Class label (normal color)
		if not self.InfoElements.ClassLabel then
			self.InfoElements.ClassLabel = self.InfoPanel:CreateFontString(nil, "OVERLAY")
			self.InfoElements.ClassLabel:SetFontObject(K.UIFont)
			self.InfoElements.ClassLabel:SetPoint("TOPLEFT", 15, 0)
			self.InfoElements.ClassLabel:SetJustifyH("LEFT")
		end
		self.InfoElements.ClassLabel:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		self.InfoElements.ClassLabel:SetText("Class: ")
		self.InfoElements.ClassLabel:SetPoint("TOPLEFT", indentX, yOffset)
		self.InfoElements.ClassLabel:Show()

		-- Class value (class color)
		if not self.InfoElements.ClassValue then
			self.InfoElements.ClassValue = self.InfoPanel:CreateFontString(nil, "OVERLAY")
			self.InfoElements.ClassValue:SetFontObject(K.UIFont)
			self.InfoElements.ClassValue:SetJustifyH("LEFT")
		end
		local classColor = K.ClassColors and K.ClassColors[characterClass]
		if classColor then
			self.InfoElements.ClassValue:SetTextColor(classColor.r, classColor.g, classColor.b, 1)
		else
			self.InfoElements.ClassValue:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		end
		self.InfoElements.ClassValue:SetText(characterClass)
		self.InfoElements.ClassValue:SetPoint("LEFT", self.InfoElements.ClassLabel, "RIGHT", 0, 0)
		self.InfoElements.ClassValue:Show()

		yOffset = yOffset - 14
	elseif self.InfoElements.ClassLabel then
		self.InfoElements.ClassLabel:Hide()
		if self.InfoElements.ClassValue then
			self.InfoElements.ClassValue:Hide()
		end
	end

	-- Character race
	local race = self:GetRaceFromPortraitData(profile.name, profile.realm)
	if race then
		if not self.InfoElements.RaceLabel then
			self.InfoElements.RaceLabel = self.InfoPanel:CreateFontString(nil, "OVERLAY")
			self.InfoElements.RaceLabel:SetFontObject(K.UIFont)
			self.InfoElements.RaceLabel:SetPoint("TOPLEFT", 15, 0)
			self.InfoElements.RaceLabel:SetWidth(maxWidth)
			self.InfoElements.RaceLabel:SetJustifyH("LEFT")
		end
		self.InfoElements.RaceLabel:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		self.InfoElements.RaceLabel:SetText("Race: " .. race)
		self.InfoElements.RaceLabel:SetPoint("TOPLEFT", indentX, yOffset)
		self.InfoElements.RaceLabel:Show()
		yOffset = yOffset - 14
	elseif self.InfoElements.RaceLabel then
		self.InfoElements.RaceLabel:Hide()
	end

	-- Character faction
	local faction = self:GetFactionFromGoldInfo(profile.name, profile.realm)
	if faction and faction ~= "Unknown" then
		-- Faction label (normal color)
		if not self.InfoElements.FactionLabel then
			self.InfoElements.FactionLabel = self.InfoPanel:CreateFontString(nil, "OVERLAY")
			self.InfoElements.FactionLabel:SetFontObject(K.UIFont)
			self.InfoElements.FactionLabel:SetPoint("TOPLEFT", 15, 0)
			self.InfoElements.FactionLabel:SetJustifyH("LEFT")
		end
		self.InfoElements.FactionLabel:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		self.InfoElements.FactionLabel:SetText("Faction: ")
		self.InfoElements.FactionLabel:SetPoint("TOPLEFT", indentX, yOffset)
		self.InfoElements.FactionLabel:Show()

		-- Faction value (faction color)
		if not self.InfoElements.FactionValue then
			self.InfoElements.FactionValue = self.InfoPanel:CreateFontString(nil, "OVERLAY")
			self.InfoElements.FactionValue:SetFontObject(K.UIFont)
			self.InfoElements.FactionValue:SetJustifyH("LEFT")
		end
		-- Color faction appropriately (tints centralized in K.GUITheme)
		if faction == "Alliance" then
			self.InfoElements.FactionValue:SetTextColor(FACTION_ALLIANCE[1], FACTION_ALLIANCE[2], FACTION_ALLIANCE[3], 1)
		elseif faction == "Horde" then
			self.InfoElements.FactionValue:SetTextColor(FACTION_HORDE[1], FACTION_HORDE[2], FACTION_HORDE[3], 1)
		else
			self.InfoElements.FactionValue:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		end
		self.InfoElements.FactionValue:SetText(faction)
		self.InfoElements.FactionValue:SetPoint("LEFT", self.InfoElements.FactionLabel, "RIGHT", 0, 0)
		self.InfoElements.FactionValue:Show()

		yOffset = yOffset - 14
	elseif self.InfoElements.FactionLabel then
		self.InfoElements.FactionLabel:Hide()
		if self.InfoElements.FactionValue then
			self.InfoElements.FactionValue:Hide()
		end
	end

	-- Profile metadata section
	if not self.InfoElements.MetadataHeader then
		self.InfoElements.MetadataHeader = self.InfoPanel:CreateFontString(nil, "OVERLAY")
		self.InfoElements.MetadataHeader:SetFontObject(K.UIFont)
		self.InfoElements.MetadataHeader:SetPoint("TOPLEFT", 15, 0)
		self.InfoElements.MetadataHeader:SetWidth(maxWidth)
		self.InfoElements.MetadataHeader:SetJustifyH("LEFT")
	end
	self.InfoElements.MetadataHeader:SetTextColor(HEADER_COLOR[1], HEADER_COLOR[2], HEADER_COLOR[3], 1)
	self.InfoElements.MetadataHeader:SetText("Profile Details:")
	self.InfoElements.MetadataHeader:SetPoint("TOPLEFT", 15, yOffset - 4)
	self.InfoElements.MetadataHeader:Show()
	yOffset = yOffset - 20

	-- Last modified date
	if profile.lastModified and profile.lastModified > 946684800 then
		if not self.InfoElements.ModifiedLabel then
			self.InfoElements.ModifiedLabel = self.InfoPanel:CreateFontString(nil, "OVERLAY")
			self.InfoElements.ModifiedLabel:SetFontObject(K.UIFont)
			self.InfoElements.ModifiedLabel:SetPoint("TOPLEFT", 15, 0)
			self.InfoElements.ModifiedLabel:SetWidth(maxWidth)
			self.InfoElements.ModifiedLabel:SetJustifyH("LEFT")
		end
		self.InfoElements.ModifiedLabel:SetTextColor(MUTED_COLOR[1], MUTED_COLOR[2], MUTED_COLOR[3], 1)
		self.InfoElements.ModifiedLabel:SetText("Modified: " .. date("%Y-%m-%d %H:%M", profile.lastModified))
		self.InfoElements.ModifiedLabel:SetPoint("TOPLEFT", indentX, yOffset)
		self.InfoElements.ModifiedLabel:Show()
		yOffset = yOffset - 14
	end

	-- Customized-settings count: ties directly to the delta-storage model and
	-- fills the dead space below with something actually useful. GetProfileDataSize
	-- returns (changed, total); we surface "changed" -- i.e. how far this profile
	-- strays from defaults. A fresh/default profile reads "0 (defaults)".
	if not self.InfoElements.CustomizedLabel then
		self.InfoElements.CustomizedLabel = self.InfoPanel:CreateFontString(nil, "OVERLAY")
		self.InfoElements.CustomizedLabel:SetFontObject(K.UIFont)
		self.InfoElements.CustomizedLabel:SetWidth(maxWidth)
		self.InfoElements.CustomizedLabel:SetJustifyH("LEFT")
	end
	local changedCount = self:GetProfileDataSize(profile.data)
	self.InfoElements.CustomizedLabel:SetTextColor(MUTED_COLOR[1], MUTED_COLOR[2], MUTED_COLOR[3], 1)
	if changedCount and changedCount > 0 then
		self.InfoElements.CustomizedLabel:SetText("Customized: " .. changedCount .. " setting" .. (changedCount == 1 and "" or "s"))
	else
		self.InfoElements.CustomizedLabel:SetText("Customized: none (defaults)")
	end
	self.InfoElements.CustomizedLabel:SetPoint("TOPLEFT", indentX, yOffset)
	self.InfoElements.CustomizedLabel:Show()
	yOffset = yOffset - 14

	-- Last switched (only when we have the metadata; non-active profiles mostly).
	local lastSwitched = profile.data and profile.data.LastSwitched
	if lastSwitched and type(lastSwitched) == "number" and lastSwitched > 946684800 then
		if not self.InfoElements.SwitchedLabel then
			self.InfoElements.SwitchedLabel = self.InfoPanel:CreateFontString(nil, "OVERLAY")
			self.InfoElements.SwitchedLabel:SetFontObject(K.UIFont)
			self.InfoElements.SwitchedLabel:SetWidth(maxWidth)
			self.InfoElements.SwitchedLabel:SetJustifyH("LEFT")
		end
		self.InfoElements.SwitchedLabel:SetTextColor(MUTED_COLOR[1], MUTED_COLOR[2], MUTED_COLOR[3], 1)
		self.InfoElements.SwitchedLabel:SetText("Last switched: " .. date("%Y-%m-%d %H:%M", lastSwitched))
		self.InfoElements.SwitchedLabel:SetPoint("TOPLEFT", indentX, yOffset)
		self.InfoElements.SwitchedLabel:Show()
		yOffset = yOffset - 14
	elseif self.InfoElements.SwitchedLabel then
		self.InfoElements.SwitchedLabel:Hide()
	end

	-- Action hint
	if not self.InfoElements.HintLabel then
		self.InfoElements.HintLabel = self.InfoPanel:CreateFontString(nil, "OVERLAY")
		self.InfoElements.HintLabel:SetFontObject(K.UIFont)
		self.InfoElements.HintLabel:SetPoint("TOPLEFT", 15, 0)
		self.InfoElements.HintLabel:SetWidth(maxWidth)
		self.InfoElements.HintLabel:SetJustifyH("LEFT")
	end
	-- REASON: only meaningful when the profile is NOT active. For the active one the
	-- green "Currently Active" header already says it -- don't repeat the same fact.
	if profile.isCurrent then
		self.InfoElements.HintLabel:Hide()
	else
		self.InfoElements.HintLabel:SetTextColor(HINT_COLOR[1], HINT_COLOR[2], HINT_COLOR[3], 1)
		self.InfoElements.HintLabel:SetText("Use 'Switch To' to activate this profile")
		self.InfoElements.HintLabel:SetPoint("TOPLEFT", 15, yOffset - 4)
		self.InfoElements.HintLabel:Show()
		yOffset = yOffset - 18 -- account for the hint so the box grows to contain it
	end

	-- REASON: the content height is genuinely variable -- class/race/faction may be
	-- missing, the hint only shows when inactive, last-switched only when present.
	-- A fixed 178px box either clipped text out the bottom (the bug) or left a dead
	-- gap. Size the box to the real content instead. yOffset is the running top
	-- cursor (negative as it descends); flip it and add bottom padding for height.
	-- The control panel is anchored to this box's bottom, so it reflows cleanly.
	self.InfoPanel:SetHeight(math.max(120, -yOffset + 12))
end

-- Main UI Creation with Simplified Design
function ProfileGUI:CreateMainFrame()
	if self.Frame then
		return self.Frame
	end

	-- Main frame (matching main GUI exactly)
	local frame = CreateFrame("Frame", "KkthnxUI_ProfileGUI", UIParent)
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
	titleBar:EnableMouse(true)
	titleBar:RegisterForDrag("LeftButton")
	titleBar:SetScript("OnDragStart", function()
		frame:StartMoving()
	end)
	titleBar:SetScript("OnDragStop", function()
		frame:StopMovingOrSizing()
	end)

	CreateColoredBackground(titleBar, ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3])

	-- Title text
	local title = titleBar:CreateFontString(nil, "OVERLAY")
	title:SetFontObject(K.UIFont)
	title:SetTextColor(1, 1, 1, 1)
	title:SetText("Profile Manager")
	title:SetPoint("LEFT", 15, 0)

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

	-- Content area
	local content = CreateFrame("Frame", nil, frame)
	content:SetPoint("TOPLEFT", 0, -HEADER_HEIGHT)
	content:SetPoint("BOTTOMRIGHT", 0, 0)

	CreateColoredBackground(content, BG_COLOR[1], BG_COLOR[2], BG_COLOR[3], BG_COLOR[4])

	-- Left panel (Profile List)
	local leftPanel = CreateFrame("Frame", nil, content)
	leftPanel:SetPoint("TOPLEFT", SPACING, -SPACING)
	leftPanel:SetPoint("BOTTOMLEFT", SPACING, SPACING)
	leftPanel:SetWidth(LIST_WIDTH)

	CreateColoredBackground(leftPanel, SIDEBAR_COLOR[1], SIDEBAR_COLOR[2], SIDEBAR_COLOR[3], SIDEBAR_COLOR[4])

	-- Profile list title
	local listTitle = leftPanel:CreateFontString(nil, "OVERLAY")
	listTitle:SetFontObject(K.UIFont)
	listTitle:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
	listTitle:SetText("Available Profiles")
	listTitle:SetPoint("TOPLEFT", 12, -12)

	-- Profile scroll frame
	local profileScrollFrame = self:CreateScrollFrame(leftPanel, LIST_WIDTH - 20, LIST_HEIGHT - 46)
	profileScrollFrame:ClearAllPoints()
	profileScrollFrame:SetPoint("TOPLEFT", 10, -35)
	profileScrollFrame:SetPoint("BOTTOMRIGHT", -10, 10)
	self.ProfileScrollFrame = profileScrollFrame

	-- Right panel (Info and Controls)
	local rightPanel = CreateFrame("Frame", nil, content)
	rightPanel:SetPoint("TOPLEFT", leftPanel, "TOPRIGHT", SPACING, 0)
	rightPanel:SetPoint("BOTTOMRIGHT", -SPACING, SPACING)

	CreateColoredBackground(rightPanel, SIDEBAR_COLOR[1], SIDEBAR_COLOR[2], SIDEBAR_COLOR[3], SIDEBAR_COLOR[4])

	-- Info panel
	local infoPanel = CreateFrame("Frame", nil, rightPanel)
	infoPanel:SetPoint("TOPLEFT", 15, -15)
	infoPanel:SetPoint("TOPRIGHT", -15, -15)
	infoPanel:SetHeight(178) -- Fixed height for info panel

	CreateColoredBackground(infoPanel, WIDGET_BG[1], WIDGET_BG[2], WIDGET_BG[3], WIDGET_BG[4])
	self.InfoPanel = infoPanel

	-- Control panel
	local controlPanel = CreateFrame("Frame", nil, rightPanel)
	controlPanel:SetPoint("TOPLEFT", infoPanel, "BOTTOMLEFT", 0, -SPACING - 10)
	controlPanel:SetPoint("BOTTOMRIGHT", -15, 15)

	CreateColoredBackground(controlPanel, WIDGET_BG[1], WIDGET_BG[2], WIDGET_BG[3], WIDGET_BG[4])

	-- Create control buttons
	self:CreateControlButtons(controlPanel)

	-- Status text
	local statusText = controlPanel:CreateFontString(nil, "OVERLAY")
	statusText:SetFontObject(K.UIFont)
	statusText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	statusText:SetText("")
	statusText:SetPoint("BOTTOMLEFT", controlPanel, "BOTTOMLEFT", 15, 15)
	statusText:SetPoint("BOTTOMRIGHT", controlPanel, "BOTTOMRIGHT", -15, 15)
	statusText:SetJustifyH("LEFT")
	self.StatusText = statusText

	self.Frame = frame
	return frame
end

function ProfileGUI:CreateControlButtons(parent)
	local buttonWidth = 100
	local yOffset = -15

	-- Section header
	local operationsTitle = parent:CreateFontString(nil, "OVERLAY")
	operationsTitle:SetFontObject(K.UIFont)
	operationsTitle:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
	operationsTitle:SetText("Profile Operations")
	operationsTitle:SetPoint("TOPLEFT", 15, yOffset)
	yOffset = yOffset - 30

	-- Switch profile button
	local switchButton = CreateButton(parent, "Switch To", buttonWidth, BUTTON_HEIGHT, function()
		self:SwitchToSelectedProfile()
	end)
	switchButton:SetPoint("TOPLEFT", 15, yOffset)
	self.SwitchButton = switchButton

	-- Reset profile button
	local resetButton = CreateButton(parent, "Reset", buttonWidth, BUTTON_HEIGHT, function()
		self:ShowResetConfirmation()
	end)
	resetButton:SetPoint("TOPLEFT", switchButton, "TOPRIGHT", SPACING, 0)
	self.ResetButton = resetButton

	yOffset = yOffset - (BUTTON_HEIGHT + SPACING)

	-- Create new profile button
	local createButton = CreateButton(parent, "Create New", buttonWidth, BUTTON_HEIGHT, function()
		self:ShowCreateProfileDialog()
	end)
	createButton:SetPoint("TOPLEFT", 15, yOffset)
	self.CreateProfileButton = createButton

	-- Copy profile button
	local copyButton = CreateButton(parent, "Copy", buttonWidth, BUTTON_HEIGHT, function()
		self:ShowCopyProfileDialog()
	end)
	copyButton:SetPoint("TOPLEFT", createButton, "TOPRIGHT", SPACING, 0)
	self.CopyButton = copyButton

	yOffset = yOffset - (BUTTON_HEIGHT + SPACING)

	-- Rename profile button
	local renameButton = CreateButton(parent, "Rename", buttonWidth, BUTTON_HEIGHT, function()
		self:ShowRenameProfileDialog()
	end)
	renameButton:SetPoint("TOPLEFT", 15, yOffset)
	self.RenameButton = renameButton

	-- Delete profile button
	local deleteButton = CreateButton(parent, "Delete", buttonWidth, BUTTON_HEIGHT, function()
		self:ShowDeleteConfirmation()
	end)
	deleteButton:SetPoint("TOPLEFT", renameButton, "TOPRIGHT", SPACING, 0)
	self.DeleteButton = deleteButton

	yOffset = yOffset - (BUTTON_HEIGHT + SPACING * 2)

	-- Import section header
	local importTitle = parent:CreateFontString(nil, "OVERLAY")
	importTitle:SetFontObject(K.UIFont)
	importTitle:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
	importTitle:SetText("Import or Export Profile")
	importTitle:SetPoint("TOPLEFT", 15, yOffset)
	yOffset = yOffset - 25

	-- Import button
	local importButton = CreateButton(parent, "Import", buttonWidth, BUTTON_HEIGHT, function()
		self:ShowImportDialog()
	end)
	importButton:SetPoint("TOPLEFT", 15, yOffset)
	self.ImportButton = importButton

	-- Export profile button
	local exportButton = CreateButton(parent, "Export", buttonWidth, BUTTON_HEIGHT, function()
		self:ShowExportDialog()
	end)
	exportButton:SetPoint("TOPLEFT", importButton, "TOPRIGHT", SPACING, 0)
	self.ExportButton = exportButton
end

-- Status Message Functions
function ProfileGUI:ShowStatusMessage(message, messageType)
	if not self.StatusText then
		return
	end

	local color = TEXT_COLOR
	if messageType == "success" then
		color = SUCCESS_COLOR
	elseif messageType == "error" then
		color = ERROR_COLOR
	elseif messageType == "warning" then
		color = WARNING_COLOR
	end

	self.StatusText:SetTextColor(color[1], color[2], color[3], 1)
	self.StatusText:SetText(message)

	-- Auto-clear message after 5 seconds
	C_Timer.After(5, function()
		if self.StatusText then
			self.StatusText:SetText("")
		end
	end)
end

-- Main control functions
function ProfileGUI:SwitchToSelectedProfile()
	if not self.SelectedProfile then
		self:ShowStatusMessage("No profile selected", "error")
		return
	end

	self:SwitchToProfile(self.SelectedProfile)
end

-- Export Dialog - Enhanced with better styling
function ProfileGUI:ShowExportDialog()
	if not self.SelectedProfile then
		self:ShowStatusMessage("No profile selected", "error")
		return
	end
	-- Export string for current selection
	local exportString, error = self:ExportProfile(self.SelectedProfile)
	if not exportString then
		self:ShowStatusMessage(error, "error")
		return
	end

	-- Reuse singleton dialog if already created.
	-- REASON: new frames start visible, so the first export worked by accident.
	-- After closing, the existing singleton is hidden and MUST be shown explicitly;
	-- rebuilding children on the hidden frame made the second click look dead.
	if self.ExportDialog then
		if self.ExportDialog._exportBox then
			self.ExportDialog._exportBox:SetText(exportString)
			self.ExportDialog._exportBox:SetCursorPosition(0)
			self.ExportDialog._exportBox:HighlightText()
		end
		if self.ExportDialog._profileInfo then
			local profiles = self:GetAllProfiles()
			local profile = profiles[self.SelectedProfile]
			if profile then
				self.ExportDialog._profileInfo:SetText("Profile: " .. profile.name .. " (" .. profile.realm .. ")")
			end
		end
		self.ExportDialog:SetParent(UIParent)
		self.ExportDialog:Show()
		self.ExportDialog:Raise()
		C_Timer.After(0.1, function()
			if self.ExportDialog and self.ExportDialog:IsShown() and self.ExportDialog._exportBox then
				self.ExportDialog._exportBox:SetFocus()
				self.ExportDialog._exportBox:HighlightText()
			end
		end)
		return self.ExportDialog
	end

	local dialog = self.ExportDialog or CreateFrame("Frame", nil, UIParent)
	dialog.__KKUI_ProfileGUI = true
	dialog:SetSize(500, 400)
	dialog:SetPoint("CENTER")
	dialog:SetFrameStrata("TOOLTIP")
	dialog:SetFrameLevel(120)
	dialog:EnableMouse(true)
	dialog:SetMovable(true)
	dialog:RegisterForDrag("LeftButton")
	dialog:SetScript("OnDragStart", dialog.StartMoving)
	dialog:SetScript("OnDragStop", dialog.StopMovingOrSizing)

	-- Background and shadow
	local mainBg = dialog:CreateTexture(nil, "BACKGROUND")
	mainBg:SetAllPoints()
	mainBg:SetTexture(C["Media"].Textures.White8x8Texture)
	mainBg:SetVertexColor(0.08, 0.08, 0.08, 0.95)

	local shadow = CreateFrame("Frame", nil, dialog)
	shadow:SetPoint("TOPLEFT", -8, 8)
	shadow:SetPoint("BOTTOMRIGHT", 8, -8)
	shadow:SetFrameLevel(dialog:GetFrameLevel() - 1)
	local shadowTexture = shadow:CreateTexture(nil, "BACKGROUND")
	shadowTexture:SetAllPoints()
	shadowTexture:SetTexture(C["Media"].Textures.White8x8Texture)
	shadowTexture:SetVertexColor(0, 0, 0, 0.4)

	-- Title Bar
	local titleBar = CreateFrame("Frame", nil, dialog)
	titleBar:SetPoint("TOPLEFT", 0, 0)
	titleBar:SetPoint("TOPRIGHT", 0, 0)
	titleBar:SetHeight(HEADER_HEIGHT)
	titleBar:EnableMouse(true)
	titleBar:RegisterForDrag("LeftButton")
	titleBar:SetScript("OnDragStart", function()
		dialog:StartMoving()
	end)
	titleBar:SetScript("OnDragStop", function()
		dialog:StopMovingOrSizing()
	end)

	CreateColoredBackground(titleBar, ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3])

	-- Title text
	local titleText = titleBar:CreateFontString(nil, "OVERLAY")
	titleText:SetFontObject(K.UIFont)
	titleText:SetTextColor(1, 1, 1, 1)
	titleText:SetText("Export Profile")
	titleText:SetPoint("LEFT", 15, 0)

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
		dialog:Hide()
	end)
	dialog:EnableKeyboard(true)
	if dialog.SetPropagateKeyboardInput then
		dialog:SetPropagateKeyboardInput(false)
	end
	dialog:SetScript("OnKeyDown", function(self, key)
		if key == "ESCAPE" then
			self:Hide()
		end
	end)

	closeButton:SetScript("OnEnter", function(self)
		self.Icon:SetVertexColor(1, 1, 1, 1)
		closeBg:SetVertexColor(1, 0.2, 0.2, 0.3)
	end)

	closeButton:SetScript("OnLeave", function(self)
		self.Icon:SetVertexColor(1, 1, 1, 0.8)
		closeBg:SetVertexColor(0, 0, 0, 0)
	end)

	-- Content area
	local content = CreateFrame("Frame", nil, dialog)
	content:SetPoint("TOPLEFT", 0, -HEADER_HEIGHT)
	content:SetPoint("BOTTOMRIGHT", 0, 0)

	CreateColoredBackground(content, BG_COLOR[1], BG_COLOR[2], BG_COLOR[3], BG_COLOR[4])

	-- Profile info
	local profiles = self:GetAllProfiles()
	local profile = profiles[self.SelectedProfile]
	local infoText = "Profile: " .. profile.name .. " (" .. profile.realm .. ")"

	local profileInfo = content:CreateFontString(nil, "OVERLAY")
	profileInfo:SetFontObject(K.UIFont)
	profileInfo:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
	profileInfo:SetText(infoText)
	profileInfo:SetPoint("TOP", content, "TOP", 0, -15)

	-- Instructions
	local instructText = content:CreateFontString(nil, "OVERLAY")
	instructText:SetFontObject(K.UIFont)
	instructText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	instructText:SetText("Copy the code below to share your profile:")
	instructText:SetPoint("TOP", profileInfo, "BOTTOM", 0, -10)

	-- Scrollable text area
	local scrollFrame = CreateFrame("ScrollFrame", nil, content)
	scrollFrame:SetSize(460, 220)
	scrollFrame:SetPoint("TOP", instructText, "BOTTOM", 0, -15)

	CreateColoredBackground(scrollFrame, WIDGET_BG[1], WIDGET_BG[2], WIDGET_BG[3], WIDGET_BG[4])

	-- Simple border
	local scrollBorder = CreateFrame("Frame", nil, scrollFrame)
	scrollBorder:SetPoint("TOPLEFT", -1, 1)
	scrollBorder:SetPoint("BOTTOMRIGHT", 1, -1)
	scrollBorder:SetFrameLevel(scrollFrame:GetFrameLevel() - 1)
	local borderTexture = scrollBorder:CreateTexture(nil, "BACKGROUND")
	borderTexture:SetAllPoints()
	borderTexture:SetTexture(C["Media"].Textures.White8x8Texture)
	borderTexture:SetVertexColor(0.3, 0.3, 0.3, 0.8)

	local scrollChild = CreateFrame("Frame", nil, scrollFrame)
	scrollChild:SetSize(440, 220)
	scrollFrame:SetScrollChild(scrollChild)

	-- Export code editbox
	local exportBox = dialog._exportBox or CreateFrame("EditBox", nil, scrollChild)
	exportBox:SetSize(440, 220)
	exportBox:SetPoint("TOPLEFT", 10, -10)
	exportBox:SetFontObject(K.UIFont)
	exportBox:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	exportBox:SetAutoFocus(false)
	exportBox:SetMultiLine(true)
	exportBox:SetMaxLetters(0)
	exportBox:SetTextInsets(10, 10, 10, 10)
	exportBox:EnableMouse(true)
	exportBox:SetText(exportString)
	exportBox:SetCursorPosition(0)

	-- Auto-select on focus
	exportBox:SetScript("OnEditFocusGained", function(self)
		self:HighlightText()
	end)

	-- Status message
	local statusText = content:CreateFontString(nil, "OVERLAY")
	statusText:SetFontObject(K.UIFont)
	statusText:SetTextColor(SUCCESS_COLOR[1], SUCCESS_COLOR[2], SUCCESS_COLOR[3], 1)
	statusText:SetText("Profile exported successfully - click in the text area to select all")
	statusText:SetPoint("TOP", scrollFrame, "BOTTOM", 0, -10)
	statusText:SetWidth(460)
	statusText:SetJustifyH("CENTER")

	-- Buttons
	local selectAllButton = CreateButton(content, "Select All", 100, BUTTON_HEIGHT, function()
		exportBox:SetFocus()
		exportBox:HighlightText()
	end)
	selectAllButton:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 20, 15)

	local cancelButton = CreateButton(content, "Close", 100, BUTTON_HEIGHT, function()
		dialog:Hide()
	end)
	cancelButton:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -20, 15)

	-- Auto-focus the export box
	C_Timer.After(0.1, function()
		exportBox:SetFocus()
		exportBox:HighlightText()
	end)

	dialog._profileInfo = profileInfo
	dialog._exportBox = exportBox
	self.ExportDialog = dialog
	dialog:Show()
	return dialog
end

-- Import Dialog - Enhanced with better styling
function ProfileGUI:ShowImportDialog()
	-- Reuse singleton dialog if available
	if self.ImportDialog then
		self.ImportDialog:SetParent(UIParent)
		self.ImportDialog:Show()
		self.ImportDialog:Raise()
		C_Timer.After(0.1, function()
			if self.ImportDialog and self.ImportDialog:IsShown() and self.ImportDialog._importBox then
				self.ImportDialog._importBox:SetFocus()
			end
		end)
		return self.ImportDialog
	end
	local dialog = self.ImportDialog or CreateFrame("Frame", nil, UIParent)
	dialog.__KKUI_ProfileGUI = true
	dialog:SetSize(500, 400)
	dialog:SetPoint("CENTER")
	dialog:SetFrameStrata("TOOLTIP")
	dialog:SetFrameLevel(120)
	dialog:EnableMouse(true)
	dialog:SetMovable(true)
	dialog:RegisterForDrag("LeftButton")
	dialog:SetScript("OnDragStart", dialog.StartMoving)
	dialog:SetScript("OnDragStop", dialog.StopMovingOrSizing)

	-- Background and shadow
	local mainBg = dialog:CreateTexture(nil, "BACKGROUND")
	mainBg:SetAllPoints()
	mainBg:SetTexture(C["Media"].Textures.White8x8Texture)
	mainBg:SetVertexColor(0.08, 0.08, 0.08, 0.95)

	local shadow = CreateFrame("Frame", nil, dialog)
	shadow:SetPoint("TOPLEFT", -8, 8)
	shadow:SetPoint("BOTTOMRIGHT", 8, -8)
	shadow:SetFrameLevel(dialog:GetFrameLevel() - 1)
	local shadowTexture = shadow:CreateTexture(nil, "BACKGROUND")
	shadowTexture:SetAllPoints()
	shadowTexture:SetTexture(C["Media"].Textures.White8x8Texture)
	shadowTexture:SetVertexColor(0, 0, 0, 0.4)

	-- Title Bar
	local titleBar = CreateFrame("Frame", nil, dialog)
	titleBar:SetPoint("TOPLEFT", 0, 0)
	titleBar:SetPoint("TOPRIGHT", 0, 0)
	titleBar:SetHeight(HEADER_HEIGHT)
	titleBar:EnableMouse(true)
	titleBar:RegisterForDrag("LeftButton")
	titleBar:SetScript("OnDragStart", function()
		dialog:StartMoving()
	end)
	titleBar:SetScript("OnDragStop", function()
		dialog:StopMovingOrSizing()
	end)

	CreateColoredBackground(titleBar, ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3])

	-- Title text
	local titleText = titleBar:CreateFontString(nil, "OVERLAY")
	titleText:SetFontObject(K.UIFont)
	titleText:SetTextColor(1, 1, 1, 1)
	titleText:SetText("Import Profile")
	titleText:SetPoint("LEFT", 15, 0)

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
		dialog:Hide()
	end)
	dialog:EnableKeyboard(true)
	if dialog.SetPropagateKeyboardInput then
		dialog:SetPropagateKeyboardInput(false)
	end
	dialog:SetScript("OnKeyDown", function(self, key)
		if key == "ESCAPE" then
			self:Hide()
		end
	end)

	closeButton:SetScript("OnEnter", function(self)
		self.Icon:SetVertexColor(1, 1, 1, 1)
		closeBg:SetVertexColor(1, 0.2, 0.2, 0.3)
	end)

	closeButton:SetScript("OnLeave", function(self)
		self.Icon:SetVertexColor(1, 1, 1, 0.8)
		closeBg:SetVertexColor(0, 0, 0, 0)
	end)

	-- Content area
	local content = CreateFrame("Frame", nil, dialog)
	content:SetPoint("TOPLEFT", 0, -HEADER_HEIGHT)
	content:SetPoint("BOTTOMRIGHT", 0, 0)

	CreateColoredBackground(content, BG_COLOR[1], BG_COLOR[2], BG_COLOR[3], BG_COLOR[4])

	-- Instructions
	local instructText = content:CreateFontString(nil, "OVERLAY")
	instructText:SetFontObject(K.UIFont)
	instructText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	instructText:SetText("Paste your profile code below:")
	instructText:SetPoint("TOP", content, "TOP", 0, -15)

	-- Current character info
	local charInfo = content:CreateFontString(nil, "OVERLAY")
	charInfo:SetFontObject(K.UIFont)
	charInfo:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
	charInfo:SetText("Will apply to: " .. K.Name .. " @ " .. K.Realm)
	charInfo:SetPoint("TOP", instructText, "BOTTOM", 0, -5)

	-- Scrollable text area
	local scrollFrame = CreateFrame("ScrollFrame", nil, content)
	scrollFrame:SetSize(460, 180)
	scrollFrame:SetPoint("TOP", charInfo, "BOTTOM", 0, -10)

	CreateColoredBackground(scrollFrame, WIDGET_BG[1], WIDGET_BG[2], WIDGET_BG[3], WIDGET_BG[4])

	-- Simple border
	local scrollBorder = CreateFrame("Frame", nil, scrollFrame)
	scrollBorder:SetPoint("TOPLEFT", -1, 1)
	scrollBorder:SetPoint("BOTTOMRIGHT", 1, -1)
	scrollBorder:SetFrameLevel(scrollFrame:GetFrameLevel() - 1)
	local borderTexture = scrollBorder:CreateTexture(nil, "BACKGROUND")
	borderTexture:SetAllPoints()
	borderTexture:SetTexture(C["Media"].Textures.White8x8Texture)
	borderTexture:SetVertexColor(0.3, 0.3, 0.3, 0.8)

	local scrollChild = CreateFrame("Frame", nil, scrollFrame)
	scrollChild:SetSize(440, 180)
	scrollFrame:SetScrollChild(scrollChild)

	-- Import code editbox
	local importBox = dialog._importBox or CreateFrame("EditBox", nil, scrollChild)
	importBox:SetSize(440, 180)
	importBox:SetPoint("TOPLEFT", 10, -10)
	importBox:SetFontObject(K.UIFont)
	importBox:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	importBox:SetAutoFocus(false)
	importBox:SetMultiLine(true)
	importBox:SetMaxLetters(0)
	importBox:SetTextInsets(10, 10, 10, 10)
	importBox:EnableMouse(true)
	importBox:SetCursorPosition(0)

	-- Placeholder
	local placeholder = "Paste your KkthnxUI profile code here..."
	local isPlaceholder = true

	importBox:SetText(placeholder)
	importBox:SetTextColor(0.6, 0.6, 0.6, 1)

	importBox:SetScript("OnEditFocusGained", function(self)
		if isPlaceholder then
			self:SetText("")
			self:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
			isPlaceholder = false
		end
	end)

	importBox:SetScript("OnEditFocusLost", function(self)
		local text = self:GetText()
		if text == "" or trim(text) == "" then
			self:SetText(placeholder)
			self:SetTextColor(0.6, 0.6, 0.6, 1)
			isPlaceholder = true
		end
	end)

	-- Status message
	local statusText = content:CreateFontString(nil, "OVERLAY")
	statusText:SetFontObject(K.UIFont)
	statusText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	statusText:SetText("Ready to import...")
	statusText:SetPoint("TOP", scrollFrame, "BOTTOM", 0, -10)
	statusText:SetWidth(460)
	statusText:SetJustifyH("CENTER")

	-- Import mode selection
	local applyToCurrent = true

	local modeLabel = content:CreateFontString(nil, "OVERLAY")
	modeLabel:SetFontObject(K.UIFont)
	modeLabel:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	modeLabel:SetText("Import Mode:")
	modeLabel:SetPoint("BOTTOMLEFT", statusText, "BOTTOMLEFT", 5, -30)

	-- Apply to current button
	local applyButton, createButton
	applyButton = CreateButton(content, "Apply to Current", 140, 24, function()
		applyToCurrent = true
		applyButton.Text:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		createButton.Text:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		charInfo:SetText("Will apply to: " .. K.Name .. " @ " .. K.Realm)
	end)
	applyButton:SetPoint("LEFT", modeLabel, "RIGHT", 10, 0)
	applyButton.Text:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)

	-- Create new profile button
	createButton = CreateButton(content, "Create New Profile", 140, 24, function()
		applyToCurrent = false
		createButton.Text:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		applyButton.Text:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		charInfo:SetText("Will create new profile entry")
	end)
	createButton:SetPoint("LEFT", applyButton, "RIGHT", 10, 0)

	-- Validation function
	local function ValidateImportCode()
		local code = importBox:GetText()
		if isPlaceholder or not code or code == "" or trim(code) == "" then
			statusText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
			statusText:SetText("Please paste a profile code")
			return false
		end

		-- Trim the code
		code = trim(code)

		-- Check format
		local isValidFormat = code:find("KkthnxUI:Profile:", 1, true)

		if not isValidFormat then
			statusText:SetTextColor(ERROR_COLOR[1], ERROR_COLOR[2], ERROR_COLOR[3], 1)
			statusText:SetText("Invalid format - code must start with 'KkthnxUI:Profile:'")
			return false
		end

		statusText:SetTextColor(SUCCESS_COLOR[1], SUCCESS_COLOR[2], SUCCESS_COLOR[3], 1)
		statusText:SetText("Valid profile code detected")
		return true
	end

	-- Buttons
	local validateButton = CreateButton(content, "Validate", 80, BUTTON_HEIGHT, ValidateImportCode)
	validateButton:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 20, 15)

	local importButton = CreateButton(content, "Import", 80, BUTTON_HEIGHT, function()
		if not ValidateImportCode() then
			return
		end

		local success, error = self:ImportProfile(importBox:GetText(), applyToCurrent)
		if success then
			self:ShowStatusMessage(error, "success")
			self:RefreshProfileList()
			self:UpdateInfoPanel()
			self:UpdateButtonStates()
			dialog:Hide()

			-- Ask if user wants to reload UI
			if applyToCurrent then
				self:ShowReloadUIDialog("Profile applied successfully. Would you like to reload the UI to ensure all changes take effect?")
			end
		else
			statusText:SetTextColor(ERROR_COLOR[1], ERROR_COLOR[2], ERROR_COLOR[3], 1)
			statusText:SetText(error)
		end
	end)
	importButton:SetPoint("BOTTOM", content, "BOTTOM", 0, 15)

	local cancelButton = CreateButton(content, "Cancel", 80, BUTTON_HEIGHT, function()
		dialog:Hide()
	end)
	cancelButton:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -20, 15)

	-- Auto-validation on text change
	local validateTimer = nil
	importBox:SetScript("OnTextChanged", function(self)
		if validateTimer then
			validateTimer:Cancel()
		end

		if not isPlaceholder then
			validateTimer = C_Timer.NewTimer(1.0, ValidateImportCode)
		end
	end)

	-- Focus the import box
	C_Timer.After(0.1, function()
		importBox:SetFocus()
	end)

	dialog._importBox = importBox
	self.ImportDialog = dialog
	dialog:Show()
	return dialog
end

-- Simple dialog helper for basic text display
function ProfileGUI:CreateSimpleDialog(title, message, content)
	return ProfileDialogs:CreateSimpleDialog(title, message, content)
end

-- Show/Hide functions
function ProfileGUI:Show()
	-- Close ExtraGUI if it's open
	if K.ExtraGUI and K.ExtraGUI.Hide then
		K.ExtraGUI:Hide()
	end

	if not self.Frame then
		self:CreateMainFrame()
	end

	-- Refresh current character metadata when opening ProfileGUI
	self:StoreCharacterMetadata(K.Name, K.Realm)

	-- Try to find the main GUI and anchor to it
	local mainConfig = nil

	-- Try multiple ways to find the main GUI frame
	if _G.KkthnxUI_NewGUI and _G.KkthnxUI_NewGUI.Frame and _G.KkthnxUI_NewGUI.Frame:IsShown() then
		mainConfig = _G.KkthnxUI_NewGUI.Frame
	elseif K.NewGUI and K.NewGUI.Frame and K.NewGUI.Frame:IsShown() then
		mainConfig = K.NewGUI.Frame
	end

	self.Frame:ClearAllPoints()
	if mainConfig then
		-- Anchor to the right of the main GUI
		self.Frame:SetPoint("TOPLEFT", mainConfig, "TOPRIGHT", 18, 0)
		self.Frame:SetHeight(mainConfig:GetHeight())
	else
		-- Center on screen if main GUI is not available
		self.Frame:SetPoint("CENTER", UIParent, "CENTER")
		self.Frame:SetHeight(PANEL_HEIGHT)
	end

	self.Frame:Show()
	self.IsVisible = true

	-- Start periodic check to auto-close if main GUI is closed
	self:StartMainGUICheck()

	-- Refresh data
	self:RefreshProfileList()
	self:UpdateInfoPanel()
	self:UpdateButtonStates()

	-- Refresh all portraits to ensure they're up to date
	self:RefreshAllPortraits()
end

-- Periodic check to close ProfileGUI if main GUI is closed
function ProfileGUI:StartMainGUICheck()
	if self.MainGUICheckTimer then
		self.MainGUICheckTimer:Cancel()
	end

	self.MainGUICheckTimer = C_Timer.NewTicker(1, function()
		if self.IsVisible and not self:IsMainGUIVisible() then
			self:Hide()
		end
	end)
end

function ProfileGUI:StopMainGUICheck()
	if self.MainGUICheckTimer then
		self.MainGUICheckTimer:Cancel()
		self.MainGUICheckTimer = nil
	end
end

function ProfileGUI:Hide()
	-- Stop the main GUI check timer
	self:StopMainGUICheck()

	if self.Frame then
		self.Frame:Hide()
	end
	self.IsVisible = false

	-- Clear any pending status messages
	if self.StatusMessageTimer then
		self.StatusMessageTimer:Cancel()
		self.StatusMessageTimer = nil
	end

	-- Clean up any open dialogs
	for i = 1, UIParent:GetNumChildren() do
		local child = select(i, UIParent:GetChildren())
		if child and child.__KKUI_ProfileGUI and child.Hide and child:IsShown() then
			pcall(function()
				child:Hide()
			end)
		end
	end
end

function ProfileGUI:Toggle()
	if self.IsVisible then
		self:Hide()
	else
		self:Show()
	end
end

-- Check if main GUI is visible for auto-closing
function ProfileGUI:IsMainGUIVisible()
	-- Try multiple ways to detect main GUI visibility
	if _G.KkthnxUI_NewGUI and _G.KkthnxUI_NewGUI.Frame then
		return _G.KkthnxUI_NewGUI.Frame:IsShown()
	elseif K.NewGUI and K.NewGUI.Frame then
		return K.NewGUI.Frame:IsShown()
	elseif K.GUI and K.GUI.Frame then
		return K.GUI.Frame:IsShown()
	end
	return false
end

-- Dialog creation functions
function ProfileGUI:ShowCreateProfileDialog()
	local _ = self:CreateInputDialog("Create New Profile", "Enter a name for the new profile:", "", function(profileName)
		if not profileName or profileName == "" then
			self:ShowStatusMessage("Profile name cannot be empty", "error")
			return
		end

		local success, error = self:CreateProfile(profileName)
		if success then
			self:ShowStatusMessage("Profile created successfully", "success")
			self:RefreshProfileList()
		else
			self:ShowStatusMessage(error, "error")
		end
	end)
end

function ProfileGUI:ShowCopyProfileDialog()
	if not self.SelectedProfile then
		self:ShowStatusMessage("No profile selected to copy", "error")
		return
	end

	local profiles = self:GetAllProfiles()
	local sourceProfile = profiles[self.SelectedProfile]

	local _ = self:CreateInputDialog("Copy Profile", "Enter a name for the copied profile:", sourceProfile.name .. " Copy", function(profileName)
		if not profileName or profileName == "" then
			self:ShowStatusMessage("Profile name cannot be empty", "error")
			return
		end

		local success, error = self:CreateProfile(profileName, self.SelectedProfile)
		if success then
			self:ShowStatusMessage("Profile copied successfully", "success")
			self:RefreshProfileList()
		else
			self:ShowStatusMessage(error, "error")
		end
	end)
end

function ProfileGUI:ShowDeleteConfirmation()
	if not self.SelectedProfile then
		self:ShowStatusMessage("No profile selected to delete", "error")
		return
	end

	local profiles = self:GetAllProfiles()
	local profile = profiles[self.SelectedProfile]

	if profile.isCurrent then
		self:ShowStatusMessage("Cannot delete the currently active profile", "error")
		return
	end

	local _ = self:CreateConfirmDialog("Delete Profile", "Are you sure you want to delete the profile '" .. profile.name .. "'?\n\nThis action cannot be undone.", function()
		local success, error = self:DeleteProfile(self.SelectedProfile)
		if success then
			self:ShowStatusMessage("Profile deleted successfully", "success")
			self.SelectedProfile = nil
			self:RefreshProfileList()
			self:UpdateInfoPanel()
			self:UpdateButtonStates()
		else
			self:ShowStatusMessage(error, "error")
		end
	end)
end

function ProfileGUI:ShowResetConfirmation()
	local profiles = self:GetAllProfiles()
	local profile = self.SelectedProfile and profiles[self.SelectedProfile]
	local profileName = profile and profile.name or "current profile"

	local _ = self:CreateConfirmDialog("Reset Profile", "Are you sure you want to reset '" .. profileName .. "' to default settings?\n\nThis action cannot be undone.", function()
		local success, error = self:ResetProfile(self.SelectedProfile)
		if success then
			self:ShowStatusMessage("Profile reset successfully", "success")
			self:RefreshProfileList()
		else
			self:ShowStatusMessage(error, "error")
		end
	end)
end

-- Character metadata and utility functions
function ProfileGUI:GetClassFromGoldInfo(name, realm)
	return ProfileService:GetClassFromGoldInfo(name, realm) or "NONE"
end

-- Store character metadata for better portraits
function ProfileGUI:StoreCharacterMetadata(name, realm)
	-- Only store for current character to avoid API limitations.
	if realm == K.Realm and name == K.Name and self:ShouldRefreshCharacterData(name, realm) then
		ProfileService:StoreCharacterMetadata(name, realm)
		ProfileService:UpdateCurrentProfileTimestamp()
	end
end

-- Get race info from portrait storage
function ProfileGUI:GetRaceFromPortraitData(name, realm)
	return ProfileService:GetRaceFromPortraitData(name, realm)
end

-- Get gender info from portrait storage
function ProfileGUI:GetGenderFromPortraitData(name, realm)
	return ProfileService:GetGenderFromPortraitData(name, realm)
end

-- Helper function to convert race name to atlas format
function ProfileGUI:GetRaceAtlasName(race, gender)
	return K.ProfilePortraits:GetRaceAtlasName(race, gender)
end

-- Portrait setup function
function ProfileGUI:SetupPortrait(portrait, name, realm)
	return K.ProfilePortraits:SetupPortrait(portrait, name, realm)
end

-- Helper function to get character faction from gold data
function ProfileGUI:GetFactionFromGoldInfo(name, realm)
	return ProfileService:GetFactionFromGoldInfo(name, realm)
end

function ProfileGUI:GetProfileDataSize(profileData)
	return ProfileService:GetProfileDataSize(profileData)
end

-- Returns (enabledCount, disabledCount) by scanning booleans in the profile (ignoring metadata)
function ProfileGUI:GetBooleanStats(profileData)
	return ProfileService:GetBooleanStats(profileData)
end

-- Dialog Helper Functions
function ProfileGUI:CreateInputDialog(title, message, defaultText, onConfirm)
	return ProfileDialogs:CreateInputDialog(title, message, defaultText, onConfirm)
end

function ProfileGUI:CreateConfirmDialog(title, message, onConfirm, onCancel)
	return ProfileDialogs:CreateConfirmDialog(title, message, onConfirm, onCancel)
end

-- Initialize ProfileGUI
K.ProfileGUI = ProfileGUI

-- Enhanced safety check for database integrity
function ProfileGUI:EnsureDatabaseIntegrity()
	ProfileService:EnsureProfileStorage(K.Realm, K.Name)
	return true
end

-- Enhanced Profile Switching Functionality
function ProfileGUI:SwitchToProfile(profileKey)
	if not profileKey then
		self:ShowStatusMessage("No profile selected", "error")
		return false
	end

	local profiles = self:GetAllProfiles()
	local targetProfile = profiles[profileKey]

	if not targetProfile then
		self:ShowStatusMessage("Profile not found", "error")
		return false
	end

	if targetProfile.isCurrent then
		self:ShowStatusMessage("Profile is already active", "warning")
		return false
	end

	-- Simple profile switch - copy data to current character
	local success, error = self:SwitchProfile(profileKey)
	if success then
		self:ShowStatusMessage("Switched to profile: " .. targetProfile.name, "success")
		self:RefreshProfileList()
		self:UpdateInfoPanel()
		self:UpdateButtonStates()

		-- Ask if user wants to reload UI
		self:ShowReloadUIDialog("Profile switched successfully. Would you like to reload the UI to ensure all changes take effect?")
		return true
	else
		self:ShowStatusMessage(error or "Failed to switch profile", "error")
		return false
	end
end

function ProfileGUI:ShowReloadUIDialog(message)
	local dialog = self:CreateConfirmDialog("Reload UI", message, function()
		ReloadUI()
	end, function()
		-- User chose not to reload, that's fine
	end)
	return dialog
end

-- Module initialization and exposure
function ProfileGUI:Initialize()
	-- Set up initial state
	self.IsInitialized = true
	self.SelectedProfile = nil

	-- Try to auto-select current profile
	local currentKey = self:GetCurrentProfileKey()
	local profiles = self:GetAllProfiles()
	if profiles[currentKey] then
		self.SelectedProfile = currentKey
	end
end

-- Enable function for integration with Loading.lua
function ProfileGUI:Enable()
	-- Guard against double-enabling
	if self._enabled then
		return true
	end

	-- Ensure database integrity first
	if not self:EnsureDatabaseIntegrity() then
		print("|cffff0000KkthnxUI Error:|r ProfileGUI failed to initialize - database not available!")
		return false
	end

	-- Migrate existing profiles to have LastModified timestamps
	self:MigrateProfileTimestamps()

	-- Store current character metadata for portraits
	self:StoreCharacterMetadata(K.Name, K.Realm)

	-- Ensure current profile has LastModified timestamp
	self:UpdateCurrentProfileTimestamp()

	-- Check for required libraries with better error messages
	if not K.LibSerialize then
		print("|cffff0000KkthnxUI Warning:|r LibSerialize not available - profile import/export disabled!")
	end
	if not K.LibDeflate then
		print("|cffff0000KkthnxUI Warning:|r LibDeflate not available - profile import/export disabled!")
	end

	-- Initialize the ProfileGUI
	self:Initialize()

	-- Expose the timestamp update function globally so other parts of KkthnxUI can call it
	K.UpdateProfileTimestamp = function()
		if ProfileGUI and ProfileGUI.UpdateCurrentProfileTimestamp then
			ProfileGUI:UpdateCurrentProfileTimestamp()
		end
	end

	-- Slash commands are registered centrally in Core/Commands.lua to reduce taint

	self._enabled = true
	return true
end

-- Expose ProfileGUI globally for Loading.lua access
K.ProfileGUI = ProfileGUI

-- Helper function to refresh all portraits in the profile list
function ProfileGUI:RefreshAllPortraits()
	if not self.ProfileScrollFrame or not self.ProfileScrollFrame.Child then
		return
	end

	-- Refresh current character metadata first
	self:StoreCharacterMetadata(K.Name, K.Realm)

	-- Update all portrait textures in the current list
	for _, button in ipairs({ self.ProfileScrollFrame.Child:GetChildren() }) do
		if button.Portrait and button.Profile then
			self:SetupPortrait(button.Portrait, button.Profile.name, button.Profile.realm)
		end
	end
end

-- Helper function to check if character metadata needs refreshing
function ProfileGUI:ShouldRefreshCharacterData(name, realm)
	if not KkthnxUIDB.ProfilePortraits or not KkthnxUIDB.ProfilePortraits[realm] or not KkthnxUIDB.ProfilePortraits[realm][name] then
		return true -- No data exists
	end

	local data = KkthnxUIDB.ProfilePortraits[realm][name]
	local currentTime = time()

	-- Refresh if data is older than 1 hour
	if not data.lastUpdated or (currentTime - data.lastUpdated) > 3600 then
		return true
	end

	-- Refresh if essential data is missing
	if not data.class or not data.race or not data.gender or not data.faction then
		return true
	end

	-- For current character, also check if data has changed
	if realm == K.Realm and name == K.Name then
		local currentClass = K.Class or UnitClass("player")
		local currentRace = K.Race or UnitRace("player")
		local currentGender = K.Sex or UnitSex("player")
		local currentFaction = K.Faction or UnitFactionGroup("player")

		if currentClass and currentRace and currentGender and currentFaction then
			if data.class ~= currentClass or data.race ~= currentRace or data.gender ~= currentGender or data.faction ~= currentFaction then
				return true
			end
		end
	end

	return false
end

-- Helper function to update current profile's LastModified timestamp
function ProfileGUI:UpdateCurrentProfileTimestamp()
	-- Ensure database integrity
	if not self:EnsureDatabaseIntegrity() then
		return
	end

	-- Update the current character's LastModified timestamp
	local settingsByRealm = ProfileService:EnsureProfileStorage(K.Realm, K.Name)

	-- Use time() for proper Unix timestamp
	local currentTime = time()
	settingsByRealm[K.Name].LastModified = currentTime
end

-- Helper function to migrate existing profiles to have LastModified timestamps
function ProfileGUI:MigrateProfileTimestamps()
	if not KkthnxUIDB or not KkthnxUIDB.Settings then
		return
	end

	local currentTime = time()
	local migrated = 0

	for realm, realmData in pairs(KkthnxUIDB.Settings) do
		if type(realmData) == "table" then
			for name, profileData in pairs(realmData) do
				if type(profileData) == "table" and not profileData.LastModified then
					profileData.LastModified = currentTime
					migrated = migrated + 1
				end
			end
		end
	end
end
