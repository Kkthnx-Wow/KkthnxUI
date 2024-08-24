-- LibChangelog
-- Provides a way to create a simple in-game frame to show a changelog

local MAJOR, MINOR = "LibChangelog-KkthnxUI", 0
local LibChangelog = LibStub:NewLibrary(MAJOR, MINOR)

if not LibChangelog then
	return
end

-- Lua APIs
local error = error

-- WoW APIs and UI functions
local CreateFrame = CreateFrame
local UIParent = UIParent
local GetLocale = GetLocale

-- Local variables for GameFont constants
local GameFontNormalHuge = GameFontNormalHuge
local GameFontNormal = GameFontNormal
local GameFontHighlight = GameFontHighlight
local GameFontDisableHuge = GameFontDisableHuge
local GameFontDisable = GameFontDisable
local GameFontDisableHighlight = GameFontDisableHighlight

-- Localization strings for different languages
local L = {
	["enUS"] = {
		CHANGLOG_VIEWER = " Changelog",
		HIDE_UNTIL_NEXT_UPDATE = "Hide until next update",
	},
	["esES"] = {
		CHANGLOG_VIEWER = " Registro de cambios",
		HIDE_UNTIL_NEXT_UPDATE = "Ocultar hasta la próxima actualización",
	},
	["deDE"] = {
		CHANGLOG_VIEWER = " Änderungsprotokoll",
		HIDE_UNTIL_NEXT_UPDATE = "Verstecken bis zum nächsten Update",
	},
	["frFR"] = {
		CHANGLOG_VIEWER = " Journal des modifications",
		HIDE_UNTIL_NEXT_UPDATE = "Cacher jusqu'à la prochaine mise à jour",
	},
	["itIT"] = {
		CHANGLOG_VIEWER = " Registro delle modifiche",
		HIDE_UNTIL_NEXT_UPDATE = "Nascondi fino al prossimo aggiornamento",
	},
	["koKR"] = {
		CHANGLOG_VIEWER = " 변경 로그",
		HIDE_UNTIL_NEXT_UPDATE = "다음 업데이트까지 숨기기",
	},
	["ptBR"] = {
		CHANGLOG_VIEWER = " Registro de mudanças",
		HIDE_UNTIL_NEXT_UPDATE = "Ocultar até a próxima atualização",
	},
	["ruRU"] = {
		CHANGLOG_VIEWER = " Журнал изменений",
		HIDE_UNTIL_NEXT_UPDATE = "Скрыть до следующего обновления",
	},
	["zhCN"] = {
		CHANGLOG_VIEWER = " 更新日志",
		HIDE_UNTIL_NEXT_UPDATE = "直到下次更新前隐藏",
	},
	["zhTW"] = {
		CHANGLOG_VIEWER = " 更新日誌",
		HIDE_UNTIL_NEXT_UPDATE = "直到下次更新前隱藏",
	},
}

-- Retrieve the appropriate localization based on the player's language
local lang = GetLocale()
local localization = L[lang] or L["enUS"]

local NEW_MESSAGE_FONTS = {
	version = GameFontNormalHuge,
	title = GameFontNormal,
	text = GameFontHighlight,
}

local VIEWED_MESSAGE_FONTS = {
	version = GameFontDisableHuge,
	title = GameFontDisable,
	text = GameFontDisableHighlight,
}

function LibChangelog:Register(addonName, changelogTable, savedVariablesTable, lastReadVersionKey, onlyShowWhenNewVersionKey, texts)
	if not addonName or not changelogTable or not savedVariablesTable or not lastReadVersionKey or not onlyShowWhenNewVersionKey then
		return error("LibChangelog: Missing required parameters (addonName, changelogTable, savedVariablesTable, lastReadVersionKey, onlyShowWhenNewVersionKey)", 2)
	end
	if self[addonName] then
		return error("LibChangelog: Addon '" .. addonName .. "' is already registered", 2)
	end
	self[addonName] = {
		changelogTable = changelogTable,
		savedVariablesTable = savedVariablesTable,
		lastReadVersionKey = lastReadVersionKey,
		onlyShowWhenNewVersionKey = onlyShowWhenNewVersionKey,
		texts = texts or {},
	}
end

function LibChangelog:CreateString(frame, text, font, offset)
	if not frame then
		return error("LibChangelog:CreateString missing required parameter 'frame'", 2)
	end
	offset = offset or -5
	local entry = frame.scrollChild:CreateFontString(nil, "ARTWORK")
	entry:SetFontObject(font or GameFontNormal)
	entry:SetText(text)
	entry:SetJustifyH("LEFT")
	entry:SetWidth(frame.scrollBar:GetWidth())

	if frame.previous then
		entry:SetPoint("TOPLEFT", frame.previous, "BOTTOMLEFT", 0, offset)
	else
		entry:SetPoint("TOPLEFT", frame.scrollChild, "TOPLEFT", -5)
	end

	frame.previous = entry
	return entry
end

function LibChangelog:CreateBulletedListEntry(frame, text, font, offset)
	offset = offset or 0
	local BULLET_WIDTH = 12
	local bullet = self:CreateString(frame, " • ", font, offset)
	if bullet then
		bullet:SetWidth(BULLET_WIDTH)
		bullet:SetJustifyV("TOP")
	end

	local entry = self:CreateString(frame, text, font, offset)
	if entry then
		entry:SetPoint("TOPLEFT", bullet, "TOPRIGHT")
		entry:SetWidth(frame.scrollBar:GetWidth() - BULLET_WIDTH)
	end

	if bullet and entry then
		bullet:SetHeight(entry:GetStringHeight())
		frame.previous = bullet
	end

	return bullet
end

function LibChangelog:ShowChangelog(addonName)
	local fonts = NEW_MESSAGE_FONTS
	local addonData = self[addonName]

	if not addonData then
		return error("LibChangelog: '" .. addonName .. "' was not registered. Please use :Register() first", 2)
	end

	local firstEntry = addonData.changelogTable[1]
	local addonSavedVariablesTable = addonData.savedVariablesTable

	if addonData.lastReadVersionKey and addonSavedVariablesTable[addonData.lastReadVersionKey] and firstEntry.Version <= addonSavedVariablesTable[addonData.lastReadVersionKey] and addonSavedVariablesTable[addonData.onlyShowWhenNewVersionKey] then
		return
	end

	if not addonData.frame then
		local frame = CreateFrame("Frame", "LibChangelogFrame_" .. addonName, UIParent, "ButtonFrameTemplate")
		ButtonFrameTemplate_HidePortrait(frame)
		if frame.SetTitle then
			frame:SetTitle(addonData.texts.title or addonName .. localization.CHANGLOG_VIEWER)
		end

		frame.Inset:SetPoint("TOPLEFT", 4, -25)
		frame:SetSize(500, 500)
		frame:SetPoint("CENTER")
		frame:StripTextures()
		frame:CreateBorder()

		frame.scrollBar = CreateFrame("ScrollFrame", "LibChangelogScrollFrame_" .. addonName, frame.Inset, "UIPanelScrollFrameTemplate")
		frame.scrollBar:SetPoint("TOPLEFT", 10, -6)
		frame.scrollBar:SetPoint("BOTTOMRIGHT", -22, 6)

		frame.scrollChild = CreateFrame("Frame", "LibChangelogScrollChild_" .. addonName)
		frame.scrollChild:SetSize(1, 1)

		frame.scrollBar:SetScrollChild(frame.scrollChild)
		frame.scrollBar.ScrollBar:SkinScrollBar()

		frame.CloseButton:SkinCloseButton()

		-- Create an improved CheckButton
		frame.CheckButton = CreateFrame("CheckButton", "LibChangelogCheckButton_" .. addonName, frame, "UICheckButtonTemplate")
		frame.CheckButton:SetChecked(addonSavedVariablesTable[addonData.onlyShowWhenNewVersionKey])
		frame.CheckButton:SetFrameStrata("HIGH")
		frame.CheckButton:SetSize(26, 26) -- Increase size for better visibility
		frame.CheckButton:SetPoint("LEFT", frame, "BOTTOMLEFT", 4, 16)

		-- Customize the appearance of the CheckButton
		frame.CheckButton:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
		frame.CheckButton:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
		frame.CheckButton:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight", "ADD")
		frame.CheckButton:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
		frame.CheckButton:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")

		-- Add tooltip functionality to explain the checkbox
		frame.CheckButton:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:AddLine(addonData.texts.onlyShowWhenNewVersion or localization.HIDE_UNTIL_NEXT_UPDATE, 1, 1, 1)
			GameTooltip:Show()
		end)
		frame.CheckButton:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)

		-- Add functionality for when the CheckButton is clicked
		frame.CheckButton:SetScript("OnClick", function(self)
			local isChecked = self:GetChecked()
			addonSavedVariablesTable[addonData.onlyShowWhenNewVersionKey] = isChecked
			frame.CheckButton:SetChecked(isChecked)
		end)

		-- Create a label for the CheckButton with better alignment and styling
		frame.CheckButton.Label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		frame.CheckButton.Label:SetPoint("LEFT", frame.CheckButton, "RIGHT", 6, 0)
		frame.CheckButton.Label:SetText(addonData.texts.onlyShowWhenNewVersion or localization.HIDE_UNTIL_NEXT_UPDATE)

		addonData.frame = frame
	end

	for i = 1, #addonData.changelogTable do
		local versionEntry = addonData.changelogTable[i]

		if addonData.lastReadVersionKey and addonSavedVariablesTable[addonData.lastReadVersionKey] and addonSavedVariablesTable[addonData.lastReadVersionKey] >= versionEntry.Version then
			fonts = VIEWED_MESSAGE_FONTS
		end

		self:CreateString(addonData.frame, "## " .. versionEntry.Version, fonts.version, -30)

		if versionEntry.General then
			self:CreateString(addonData.frame, versionEntry.General, fonts.text)
		end

		if versionEntry.Sections then
			for j = 1, #versionEntry.Sections do
				local section = versionEntry.Sections[j]
				self:CreateString(addonData.frame, "### " .. section.Header, fonts.title, -8)
				local entries = section.Entries
				for k = 1, #entries do
					self:CreateBulletedListEntry(addonData.frame, entries[k], fonts.text)
				end
			end
		end
	end

	addonSavedVariablesTable[addonData.lastReadVersionKey] = firstEntry.Version
end
