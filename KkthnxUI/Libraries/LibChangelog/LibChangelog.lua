--- LibChangelog
-- Provides an way to create a simple ingame frame to show a changelog

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
	-- Check if required parameters are not nil
	if not addonName or not changelogTable or not savedVariablesTable or not lastReadVersionKey or not onlyShowWhenNewVersionKey then
		return error("LibChangelog: Missing required parameters", 2)
	end
	-- Check if addon is already registered
	if self[addonName] then
		return error("LibChangelog: '" .. addonName .. "' already registered", 2)
	end
	-- Register the addon
	self[addonName] = {
		changelogTable = changelogTable,
		savedVariablesTable = savedVariablesTable,
		lastReadVersionKey = lastReadVersionKey,
		onlyShowWhenNewVersionKey = onlyShowWhenNewVersionKey,
		texts = texts or {},
	}
end

function LibChangelog:CreateString(frame, text, font, offset)
	-- Check if frame parameter is not nil
	if not frame then
		return error("LibChangelog:CreateString missing required parameter 'frame'", 2)
	end
	-- set default offset value if not provided
	offset = offset or -5
	-- create fontstring
	local entry = frame.scrollChild:CreateFontString(nil, "ARTWORK")

	-- set the font for the fontstring
	entry:SetFontObject(font or "GameFontNormal")
	-- set the text for the fontstring
	entry:SetText(text)
	-- set the justification of the text to left
	entry:SetJustifyH("LEFT")
	-- set the width of the fontstring
	entry:SetWidth(frame.scrollBar:GetWidth())

	-- check if there is a previous frame, if yes set the position accordingly
	if frame.previous then
		entry:SetPoint("TOPLEFT", frame.previous, "BOTTOMLEFT", 0, offset)
	else
		entry:SetPoint("TOPLEFT", frame.scrollChild, "TOPLEFT", -5)
	end

	-- save the current frame as previous
	frame.previous = entry

	-- return the fontstring
	return entry
end

-- Create a new bulleted list entry
function LibChangelog:CreateBulletedListEntry(frame, text, font, offset)
	--default value for offset
	offset = offset or 0
	-- constant variable for bullet width
	local BULLET_WIDTH = 12
	-- create the bullet point
	local bullet = self:CreateString(frame, " • ", font, offset)
	bullet:SetWidth(BULLET_WIDTH)
	bullet:SetJustifyV("TOP")

	-- create the text
	local entry = self:CreateString(frame, text, font, offset)
	-- position the text next to the bullet
	entry:SetPoint("TOPLEFT", bullet, "TOPRIGHT")
	-- set the width of the text
	entry:SetWidth(frame.scrollBar:GetWidth() - BULLET_WIDTH)

	-- set the height of the bullet to match the text
	bullet:SetHeight(entry:GetStringHeight())

	-- update the previous frame
	frame.previous = bullet
	--return the bullet point
	return bullet
end

function LibChangelog:ShowChangelog(addonName)
	local fonts = NEW_MESSAGE_FONTS
	local addonData = self[addonName]

	if not addonData then
		return error("LibChangelog: '" .. addonName .. "' was not registered. Please use :Register() first", 2)
	end

	local firstEntry = addonData.changelogTable[1] -- firstEntry contains the newest Version
	local addonSavedVariablesTable = addonData.savedVariablesTable

	if
		addonData.lastReadVersionKey -- check if last read version exists in saved variables table
		and addonSavedVariablesTable[addonData.lastReadVersionKey]
		and firstEntry.Version <= addonSavedVariablesTable[addonData.lastReadVersionKey]
		and addonSavedVariablesTable[addonData.onlyShowWhenNewVersionKey]
	then -- check if only show when new version flag is set
		return -- don't show changelog if all conditions are met
	end

	if not addonData.frame then
		local frame = CreateFrame("Frame", nil, UIParent, "ButtonFrameTemplate")
		ButtonFrameTemplate_HidePortrait(frame)
		if frame.SetTitle then
			frame:SetTitle(addonData.texts.title or addonName .. " " .. "CHANGELOG_TITLE")
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
		frame.scrollChild:SetSize(1, 1) -- It doesnt seem to matter how big it is, the only thing that not works is setting the height to really high number, then you can scroll forever

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

		-- Add version string
		self:CreateString(addonData.frame, "## " .. versionEntry.Version, fonts.version, -30) -- Add a nice spacing between the version header and the previous text

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
