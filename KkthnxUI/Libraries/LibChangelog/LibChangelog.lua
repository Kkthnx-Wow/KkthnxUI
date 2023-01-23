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
	version = GameFontNormalHuge, -- Font used for the version number of new changelog entries
	title = GameFontNormal, -- Font used for the title of new sections in changelog entries
	text = GameFontHighlight, -- Font used for the text of new changelog entries
}

local VIEWED_MESSAGE_FONTS = {
	version = GameFontDisableHuge, -- Font used for the version number of viewed changelog entries
	title = GameFontDisable, -- Font used for the title of viewed sections in changelog entries
	text = GameFontDisable, -- Font used for the text of viewed changelog entries
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

	-- Check if the frame has not been created yet
	if not addonData.frame then
		-- Create the frame using the "ButtonFrameTemplate" template
		local frame = CreateFrame("Frame", nil, UIParent, "ButtonFrameTemplate")
		-- Hide the portrait of the frame
		ButtonFrameTemplate_HidePortrait(frame)
		-- Check if the frame has a "SetTitle" method and set the title
		if frame.SetTitle then
			frame:SetTitle(addonData.texts.title or addonName .. " " .. "CHANGELOG_TITLE")
		end
		-- Set the position of the frame's inset
		frame.Inset:SetPoint("TOPLEFT", 4, -25)
		-- Set the size of the frame
		frame:SetSize(500, 500)
		-- Set the position of the frame
		frame:SetPoint("CENTER")
		-- Remove the textures of the frame
		frame:StripTextures()
		-- Add a border to the frame
		frame:CreateBorder()

		-- Create a scroll bar for the frame's inset
		frame.scrollBar = CreateFrame("ScrollFrame", nil, frame.Inset, "UIPanelScrollFrameTemplate")
		-- Set the position of the scroll bar
		frame.scrollBar:SetPoint("TOPLEFT", 10, -6)
		frame.scrollBar:SetPoint("BOTTOMRIGHT", -22, 6)

		-- Create a child frame for the scroll bar
		frame.scrollChild = CreateFrame("Frame")
		-- Set the size of the child frame
		frame.scrollChild:SetSize(1, 1) -- It doesnt seem to matter how big it is, the only thing that not works is setting the height to really high number, then you can scroll forever

		-- Set the child frame as the scroll child of the scroll bar
		frame.scrollBar:SetScrollChild(frame.scrollChild)
		-- Skin the scroll bar
		UIParentInsetScrollBar:SkinScrollBar()

		-- Skin the close button of the frame
		frame.CloseButton:SkinCloseButton()

		-- Create a check button for the frame
		frame.CheckButton = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
		-- Set the check button's initial state based on the saved variable
		frame.CheckButton:SetChecked(addonSavedVariablesTable[addonData.onlyShowWhenNewVersionKey])
		-- Set the strata of the check button
		frame.CheckButton:SetFrameStrata("HIGH")
		frame.CheckButton:SetSize(14, 14)
		-- Set the script for the OnClick event of the check button
		frame.CheckButton:SetScript("OnClick", function(self)
			-- Get the current state of the check button
			local isChecked = self:GetChecked()
			-- Save the state of the check button in the saved variables table
			addonSavedVariablesTable[addonData.onlyShowWhenNewVersionKey] = isChecked
			-- Update the check state of the check button
			frame.CheckButton:SetChecked(isChecked)
		end)
		-- Set the position of the check button
		frame.CheckButton:SetPoint("LEFT", frame, "BOTTOMLEFT", 10, 13)
		-- Apply a skin to the check button
		frame.CheckButton:SkinCheckBox()

		-- Clear the position of the text of the check button
		frame.CheckButton.text:ClearAllPoints()
		-- Set the position of the text of the check button
		frame.CheckButton.text:SetPoint("LEFT", frame.CheckButton, "RIGHT", 4, 0)
		-- Set the text of the check button
		frame.CheckButton.text:SetText(addonData.texts.onlyShowWhenNewVersion or " Hide until next update")

		-- Save the frame in the addon data table
		addonData.frame = frame
	end

	local firstEntry = addonData.changelogTable[1]
	-- Iterate through each entry in the changelog table
	for i = 1, #addonData.changelogTable do
		local versionEntry = addonData.changelogTable[i]

		-- Check if the current version entry has been read and the last read version is greater or equal to the current version entry
		if addonData.lastReadVersionKey and addonSavedVariablesTable[addonData.lastReadVersionKey] and addonSavedVariablesTable[addonData.lastReadVersionKey] >= versionEntry.Version then
			fonts = VIEWED_MESSAGE_FONTS
		end

		-- Add version string to the frame
		self:CreateString(addonData.frame, "## " .. versionEntry.Version, fonts.version, -30) -- Add a nice spacing between the version header and the previous text

		-- Check if there is a general message for this version entry
		if versionEntry.General then
			self:CreateString(addonData.frame, versionEntry.General, fonts.text)
		end

		-- Check if there are sections for this version entry
		if versionEntry.Sections then
			for i = 1, #versionEntry.Sections do
				local section = versionEntry.Sections[i]
				-- Add the header of the section
				self:CreateString(addonData.frame, "### " .. section.Header, fonts.title, -8)
				local entries = section.Entries
				-- Iterate through each entry for the current section
				for j = 1, #entries do
					self:CreateBulletedListEntry(addonData.frame, entries[j], fonts.text)
				end
			end
		end
	end
	-- Update the last read version to the version of the first entry in the changelog table
	addonSavedVariablesTable[addonData.lastReadVersionKey] = firstEntry.Version
end
