--[[
	Tracking.lua - Debuff Tracking UI for KkthnxUI
	
	This module provides an interface for managing custom PvE and PvP debuff tracking.
	Players can add/remove spell IDs to track on raid frames.
	
	Features:
	- Add custom PvE debuffs
	- Add custom PvP debuffs
	- Browse tracked debuffs
	- Remove tracked debuffs
	- Combat lockdown safe
	- Taint-free implementation
]]

-- Localized globals
local _G = _G
local pairs = pairs
local tonumber = tonumber
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local StaticPopup_Show = StaticPopup_Show
local SetClampedTextureRotation = SetClampedTextureRotation

-- KkthnxUI namespace
local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Unitframes")

-- Module constants
local ARROW_UP_TEXTURE = "Interface\\Buttons\\Arrow-Up-Down"
local ARROW_DOWN_TEXTURE = "Interface\\Buttons\\Arrow-Down-Down"
local QUESTION_MARK_ICON = [[Interface\Icons\Inv_misc_questionmark]]

-- Localized Blizzard globals
local ACCEPT = _G.ACCEPT
local CANCEL = _G.CANCEL

-- Color constants
local COLOR_GREEN = "|CFF00FF00"
local COLOR_BLUE = "|CFF567AFF"
local COLOR_RED = "|CFFFF5252"
local COLOR_YELLOW = "|CFFFFFF00"
local COLOR_ORANGE = "|cffff8800"
local COLOR_END = "|r"

--[[-----------------------------------------------------------------------------
	Spell Info Compatibility Layer
	
	Provides compatibility between retail and classic GetSpellInfo APIs.
	Caches results to avoid repeated API calls.
-------------------------------------------------------------------------------]]
do
	local GetSpellInfo = _G.GetSpellInfo
	local C_Spell_GetSpellInfo = _G.C_Spell and _G.C_Spell.GetSpellInfo
	local spellCache = {}

	--- Get spell information with caching
	-- @param spell Spell ID or name
	-- @return name, rank, iconID, castTime, minRange, maxRange, spellID, originalIconID
	Module.GetSpellInfo = function(spell)
		if not spell then
			return
		end

		-- Check cache first
		if spellCache[spell] then
			return unpack(spellCache[spell])
		end

		local name, rank, iconID, castTime, minRange, maxRange, spellID, originalIconID

		if C_Spell_GetSpellInfo then
			-- Modern retail API (preferred)
			local info = C_Spell_GetSpellInfo(spell)
			if info then
				name, rank, iconID, castTime, minRange, maxRange, spellID, originalIconID =
					info.name,
					info.rank,
					info.iconID,
					info.castTime,
					info.minRange,
					info.maxRange,
					info.spellID,
					info.originalIconID
			end
		elseif GetSpellInfo then
			-- Classic / fallback API
			name, rank, iconID, castTime, minRange, maxRange, spellID, originalIconID = GetSpellInfo(spell)
		end

		-- Cache the result
		if name then
			spellCache[spell] = { name, rank, iconID, castTime, minRange, maxRange, spellID, originalIconID }
		end

		return name, rank, iconID, castTime, minRange, maxRange, spellID, originalIconID
	end
end

--[[-----------------------------------------------------------------------------
	Static Popup Dialogs
	
	Dialog boxes for adding new PvE/PvP debuffs to track.
-------------------------------------------------------------------------------]]

--- Create static popup dialog for tracking
-- @param category "PvE" or "PvP"
-- @return dialog configuration table
local function CreateTrackingDialog(category)
	local categoryUpper = category:upper()
	local categoryColor = category == "PvE" and COLOR_BLUE or COLOR_RED

	return {
		text = L["Which spell id would you like to add?"],
		button1 = ACCEPT,
		button2 = CANCEL,
		OnAccept = function(self)
			local spellID = tonumber(self.editBox:GetText())
			if not spellID then
				return
			end

			local db = KkthnxUIDB.Variables[K.Realm][K.Name].Tracking[category]
			local name, _, icon = Module.GetSpellInfo(spellID)

			local trackingTitle = COLOR_GREEN .. L["DEBUFF TRACKING"] .. " " .. COLOR_END
			local categoryTitle = categoryColor .. "[" .. L[categoryUpper] .. "] " .. COLOR_END

			if not name then
				K.Print(trackingTitle .. categoryTitle .. L["Sorry, this spell id doesn't exist"])
				return
			end

			if db[spellID] then
				K.Print(trackingTitle .. categoryTitle .. string.format(L["Sorry, %s is already tracked"], COLOR_YELLOW .. name .. COLOR_END))
				return
			end

			-- Add to database
			db[spellID] = {
				enable = true,
				priority = 1,
				stackThreshold = 0,
			}

			K.Print(trackingTitle .. categoryTitle .. string.format(L["You have added %s"], COLOR_YELLOW .. name .. COLOR_END))

			-- Update UI if frame exists
			local trackingFrame = _G.KKUI_Tracking
			if trackingFrame and trackingFrame[category] then
				trackingFrame[category].Text:SetText(name)
				trackingFrame[category].Icon.Texture:SetTexture(icon)
				trackingFrame[category].SpellID = spellID
			end

			-- Update raid frames
			Module:UpdateRaidDebuffIndicator()
		end,
		hasEditBox = true,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}
end

StaticPopupDialogs["KKUI_TRACKING_ADD_PVE"] = CreateTrackingDialog("PvE")
StaticPopupDialogs["KKUI_TRACKING_ADD_PVP"] = CreateTrackingDialog("PvP")

--[[-----------------------------------------------------------------------------
	Tracking UI Frame
	
	Main frame for debuff tracking interface.
-------------------------------------------------------------------------------]]
local Tracking = {}
Tracking.__index = Tracking

--- Get spell from tracking database by button ID
-- @param button UI button reference
-- @param category "PvE" or "PvP"
-- @return spellID, name, iconPath
function Tracking:GetSpell(button, category)
	local count = 0
	local id = button.ID
	local db = KkthnxUIDB.Variables[K.Realm][K.Name].Tracking[category]

	for spellID in pairs(db) do
		count = count + 1
		if count == id then
			local name, _, iconPath = Module.GetSpellInfo(spellID)
			return spellID, name, iconPath
		end
	end
end

--- Remove spell from tracking
-- Handler for clicking on spell name button
function Tracking:RemoveSpell()
	if InCombatLockdown() then
		K.Print(L["Sorry, our raid module is currently disabled"]) -- Using existing string, ideally add "Cannot modify during combat"
		return
	end

	local category = self.Cat
	local spellID = self.SpellID
	local db = KkthnxUIDB.Variables[K.Realm][K.Name].Tracking[category]

	if spellID and db[spellID] then
		db[spellID] = nil
		Module:UpdateRaidDebuffIndicator()

		-- Reset and show next spell
		self.ID = 0
		self.Next:Click()
	end
end

--- Update displayed spell in UI
-- Handler for navigation arrows
function Tracking:UpdateSpellDisplay()
	local button = self:GetParent()
	local category = button.Cat
	local id = button.ID
	local icon = button.Icon.Texture
	local text = button.Text
	local currentID = id

	-- Adjust ID based on direction
	if self.Decrease then
		id = id - 1
	else
		button.ID = button.ID + 1
	end

	local spellID, name, iconPath = Tracking:GetSpell(button, category)

	if name and iconPath then
		text:SetText(name)
		icon:SetTexture(iconPath)
		button.SpellID = spellID
	else
		-- No spell found, revert ID
		button.ID = currentID
	end

	-- Show empty state
	if id == 0 then
		icon:SetTexture(QUESTION_MARK_ICON)
		text:SetText(COLOR_ORANGE .. L["This list is currently empty!"] .. COLOR_END)
	end
end

--- Toggle frame visibility
function Tracking:Toggle()
	if self:IsShown() then
		self:Hide()
	else
		self:Show()
	end
end

--- Create navigation button (arrow)
-- @param parent Parent frame
-- @param texture Arrow texture path
-- @param point Anchor point
-- @param relativeFrame Relative frame
-- @param relativePoint Relative anchor point
-- @param offsetX X offset
-- @param offsetY Y offset
-- @param rotation Texture rotation in degrees
-- @param isDecrease Whether this decreases the ID
-- @return button frame
local function CreateNavigationButton(parent, texture, point, relativeFrame, relativePoint, offsetX, offsetY, rotation, isDecrease)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(26, 26)
	button:SetPoint(point, relativeFrame, relativePoint, offsetX, offsetY)
	button:SkinButton()
	button:SetScript("OnClick", Tracking.UpdateSpellDisplay)

	local btnTexture = button:CreateTexture(nil, "OVERLAY")
	btnTexture:SetSize(16, 16)
	btnTexture:SetPoint("CENTER", isDecrease and -3 or 3, 0)
	btnTexture:SetTexture(texture)

	if rotation then
		SetClampedTextureRotation(btnTexture, rotation)
	end

	button.Texture = btnTexture
	button.Decrease = isDecrease

	return button
end

--- Create category section (PvE or PvP)
-- @param trackingFrame Main tracking frame
-- @param category "PvE" or "PvP"
-- @param titleText Title text
-- @param buttonText Add button text
-- @param titlePoint Anchor point for title
-- @param titleRelative Relative frame for title
-- @param titleOffsetY Y offset for title
-- @param popupName Static popup name
-- @return category frame
local function CreateCategorySection(trackingFrame, category, titleText, buttonText, titlePoint, titleRelative, titleOffsetY, popupName)
	-- Title
	local title = trackingFrame:CreateFontString(nil, "OVERLAY")
	title:SetFontObject(K.UIFont)
	title:SetFont(select(1, title:GetFont()), 16, select(3, title:GetFont()))
	title:SetPoint(titlePoint, titleRelative, titlePoint, 0, titleOffsetY)
	title:SetText(titleText)

	-- Main button (displays spell)
	local button = CreateFrame("Button", nil, trackingFrame)
	button:SetSize(300, 26)
	button:SetPoint("TOP", title, "BOTTOM", 18, -10)
	button:SkinButton()
	button:SetScript("OnClick", Tracking.RemoveSpell)
	button.ID = 0
	button.Cat = category

	-- Spell name text
	button.Text = button:CreateFontString(nil, "OVERLAY")
	button.Text:SetFontObject(K.UIFont)
	button.Text:SetFont(select(1, button.Text:GetFont()), 14, select(3, button.Text:GetFont()))
	button.Text:SetPoint("LEFT", 10, 0)

	-- Icon frame
	button.Icon = CreateFrame("Frame", nil, button)
	button.Icon:SetSize(26, 26)
	button.Icon:SetPoint("RIGHT", button, "LEFT", -6, 0)
	button.Icon:CreateBorder()

	button.Icon.Texture = button.Icon:CreateTexture(nil, "OVERLAY")
	button.Icon.Texture:SetAllPoints()
	button.Icon.Texture:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	button.Icon.Texture:SetTexture(QUESTION_MARK_ICON)

	-- Navigation buttons
	button.Previous = CreateNavigationButton(button, ARROW_UP_TEXTURE, "RIGHT", button, "LEFT", -38, 0, 270, true)
	button.Next = CreateNavigationButton(button, ARROW_DOWN_TEXTURE, "LEFT", button, "RIGHT", 6, 0, 270, false)

	-- Add button
	button.Add = CreateFrame("Button", nil, trackingFrame)
	button.Add:SetSize(trackingFrame:GetWidth() / 2 - 3, 26)
	button.Add:SetPoint(category == "PvE" and "TOPLEFT" or "TOPRIGHT", trackingFrame, category == "PvE" and "BOTTOMLEFT" or "BOTTOMRIGHT", 0, -6)
	button.Add:SkinButton()
	button.Add:SetScript("OnClick", function()
		StaticPopup_Show(popupName)
	end)

	button.Add.Text = button.Add:CreateFontString(nil, "OVERLAY")
	button.Add.Text:SetFontObject(K.UIFont)
	button.Add.Text:SetPoint("CENTER")
	button.Add.Text:SetText(buttonText)

	return button
end

--- Setup tracking UI frame
-- @param self Tracking frame
function Tracking:Setup()
	self:SetSize(460, 280)
	self:SetPoint("CENTER", UIParent, "CENTER", 0, 64)
	self:CreateBorder()

	-- Title
	K.CreateFontString(self, 24, K.Title, "", false, "TOP", 0, -12)
	K.CreateFontString(self, 14, L["Debuff Tracking"], "", true, "TOP", 0, -40)

	-- Decorative gradient lines
	local leftLine = CreateFrame("Frame", nil, self)
	leftLine:SetPoint("TOP", self, -100, -70)
	K.CreateGF(leftLine, 200, 1, "Horizontal", 0.7, 0.7, 0.7, 0, 0.7)
	leftLine:SetFrameStrata("HIGH")

	local rightLine = CreateFrame("Frame", nil, self)
	rightLine:SetPoint("TOP", self, 100, -70)
	K.CreateGF(rightLine, 200, 1, "Horizontal", 0.7, 0.7, 0.7, 0.7, 0)
	rightLine:SetFrameStrata("HIGH")

	-- PvE Section
	self.TitlePVE = self:CreateFontString(nil, "OVERLAY")
	self.TitlePVE:SetFontObject(K.UIFont)
	self.TitlePVE:SetFont(select(1, self.TitlePVE:GetFont()), 16, select(3, self.TitlePVE:GetFont()))
	self.TitlePVE:SetPoint("TOP", self, "TOP", 0, -86)

	self.PvE = CreateCategorySection(self, "PvE", L["PvE Debuffs to track"], L["Add a pve debuff to track"], "TOP", self, -86, "KKUI_TRACKING_ADD_PVE")

	-- PvP Section
	self.TitlePVP = self:CreateFontString(nil, "OVERLAY")
	self.TitlePVP:SetFontObject(K.UIFont)
	self.TitlePVP:SetFont(select(1, self.TitlePVP:GetFont()), 16, select(3, self.TitlePVP:GetFont()))
	self.TitlePVP:SetPoint("TOP", self.TitlePVE, "TOP", 0, -86)

	self.PvP = CreateCategorySection(self, "PvP", L["PvP Debuffs to track"], L["Add a pvp debuff to track"], "TOP", self.TitlePVE, -86, "KKUI_TRACKING_ADD_PVP")

	-- Close button
	self.Close = CreateFrame("Button", nil, self)
	self.Close:SetSize(32, 32)
	self.Close:SetPoint("TOPRIGHT", self, "TOPRIGHT", 2, 2)
	self.Close:SkinCloseButton()
	self.Close:SetScript("OnClick", function(closeBtn)
		closeBtn:GetParent():Hide()
	end)

	-- Footer instructions
	self.Footer = self:CreateFontString(nil, "OVERLAY")
	self.Footer:SetFontObject(K.UIFont)
	self.Footer:SetPoint("BOTTOM", 0, 18)
	self.Footer:SetText(L["To remove a debuff from the list, select with arrow and click on name"])

	-- Initialize display
	self.PvE.Next:Click()
	self.PvP.Next:Click()
	self:Hide()
end

--[[-----------------------------------------------------------------------------
	Module Integration
-------------------------------------------------------------------------------]]

--- Create tracking UI
-- Called by the unitframes module during initialization
function Module:CreateTracking()
	if _G.KKUI_Tracking then
		-- Already created
		return
	end

	local trackingFrame = CreateFrame("Frame", "KKUI_Tracking", UIParent)

	-- Apply methods
	for k, v in pairs(Tracking) do
		trackingFrame[k] = v
	end

	trackingFrame:Setup()
end

--[[-----------------------------------------------------------------------------
	Slash Command
-------------------------------------------------------------------------------]]

--- Slash command handler for /debufftrack
SlashCmdList["KKUI_TRACKING"] = function()
	if not C["Unitframe"].Enable or not C["Raid"].Enable then
		K.Print(L["Sorry, our raid module is currently disabled"])
		return
	end

	if InCombatLockdown() then
		K.Print(L["Sorry, our raid module is currently disabled"]) -- Ideally add "Cannot open during combat"
		return
	end

	local trackingFrame = _G.KKUI_Tracking
	if trackingFrame then
		trackingFrame:Toggle()
	end
end

_G.SLASH_KKUI_TRACKING1 = "/debufftrack"
