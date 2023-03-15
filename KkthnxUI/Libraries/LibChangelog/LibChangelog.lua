--- LibChangelog
-- Provides a way to create a simple in-game frame to show a changelog

local MAJOR, MINOR = "LibChangelog-KkthnxUI", 0
local LibChangelog = LibStub:NewLibrary(MAJOR, MINOR)

if not LibChangelog then
	return
end

-- Lua APIs
local error = error

local NEW_MESSAGE_FONTS = {
	version = GameFontNormalHuge,
	title = GameFontNormal,
	text = GameFontHighlight,
}

local VIEWED_MESSAGE_FONTS = {
	version = GameFontDisableHuge,
	title = GameFontDisable,
	text = GameFontDisable,
}

function LibChangelog:Register(addonName, changelogTable, savedVariablesTable, lastReadVersionKey, onlyShowWhenNewVersionKey, texts)
	if not addonName or not changelogTable or not savedVariablesTable or not lastReadVersionKey or not onlyShowWhenNewVersionKey then
		return error("LibChangelog: Missing required parameters", 2)
	end
	if self[addonName] then
		return error("LibChangelog: '" .. addonName .. "' already registered", 2)
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
	entry:SetFontObject(font or "GameFontNormal")
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
	bullet:SetWidth(BULLET_WIDTH)
	bullet:SetJustifyV("TOP")

	local entry = self:CreateString(frame, text, font, offset)
	entry:SetPoint("TOPLEFT", bullet, "TOPRIGHT")
	entry:SetWidth(frame.scrollBar:GetWidth() - BULLET_WIDTH)

	bullet:SetHeight(entry:GetStringHeight())
	frame.previous = bullet
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
		local frame = CreateFrame("Frame", nil, UIParent, "ButtonFrameTemplate")
		ButtonFrameTemplate_HidePortrait(frame)
		if frame.SetTitle then
			frame:SetTitle(addonData.texts.title or addonName .. " " .. "Changelog Viewer")
		end
		frame.Inset:SetPoint("TOPLEFT", 4, -25)
		frame:SetSize(500, 500)
		frame:SetPoint("CENTER")
		frame:StripTextures()
		frame:CreateBorder()

		frame.scrollBar = CreateFrame("ScrollFrame", nil, frame.Inset, "UIPanelScrollFrameTemplate")
		frame.scrollBar:SetPoint("TOPLEFT", 10, -6)
		frame.scrollBar:SetPoint("BOTTOMRIGHT", -22, 6)

		frame.scrollChild = CreateFrame("Frame")
		frame.scrollChild:SetSize(1, 1)

		frame.scrollBar:SetScrollChild(frame.scrollChild)
		UIParentInsetScrollBar:SkinScrollBar()

		frame.CloseButton:SkinCloseButton()

		frame.CheckButton = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
		frame.CheckButton:SetChecked(addonSavedVariablesTable[addonData.onlyShowWhenNewVersionKey])
		frame.CheckButton:SetFrameStrata("HIGH")
		frame.CheckButton:SetSize(14, 14)
		frame.CheckButton:SetScript("OnClick", function(self)
			local isChecked = self:GetChecked()
			addonSavedVariablesTable[addonData.onlyShowWhenNewVersionKey] = isChecked
			frame.CheckButton:SetChecked(isChecked)
		end)
		frame.CheckButton:SetPoint("LEFT", frame, "BOTTOMLEFT", 10, 13)
		frame.CheckButton:SkinCheckBox()

		frame.CheckButton.text:ClearAllPoints()
		frame.CheckButton.text:SetPoint("LEFT", frame.CheckButton, "RIGHT", 4, 0)
		frame.CheckButton.text:SetText(addonData.texts.onlyShowWhenNewVersion or " Hide until next update")

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
			for i = 1, #versionEntry.Sections do
				local section = versionEntry.Sections[i]
				self:CreateString(addonData.frame, "### " .. section.Header, fonts.title, -8)
				local entries = section.Entries
				for j = 1, #entries do
					self:CreateBulletedListEntry(addonData.frame, entries[j], fonts.text)
				end
			end
		end
	end

	addonSavedVariablesTable[addonData.lastReadVersionKey] = firstEntry.Version
end
