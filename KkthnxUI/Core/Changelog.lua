--[[-----------------------------------------------------------------------------
Addon: KkthnxUI
Author: Josh "Kkthnx" Russell
Notes:
- Purpose: Automated changelog display and version tracking.
- Combat: Safe; logic runs on login or manual trigger via slash command.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

-- ---------------------------------------------------------------------------
-- Locals & Global Caching
-- ---------------------------------------------------------------------------

-- PERF: Cache frequent APIs and globals to minimize table lookups.
local CreateFrame = CreateFrame
local UIParent = UIParent
local pairs, ipairs, type = pairs, ipairs, type
local table_concat = table.concat
local string_format, string_rep = string.format, string.rep
local GameTooltip, GameTooltip_Hide = GameTooltip, GameTooltip_Hide

-- ---------------------------------------------------------------------------
-- Internal State & Mapping
-- ---------------------------------------------------------------------------

-- NOTE: Singleton frame reference to avoid multiple instances.
local changelogFrame

-- REASON: Define a consistent color and icon theme for changelog categories.
local sectionColors = {
	["General"] = "|cff5C8BCF",
	["Performance"] = "|cff6FCF5C",
	["Bug Fixes"] = "|cffCF5C5C",
	["New Features"] = "|cffCFCF5C",
	["Improvements"] = "|cff5CCFCF",
	["API"] = "|cffCF9B5C",
}

-- Atlas texture icons for sections (using WoW atlas textures)
local sectionIcons = {
	["General"] = "|TInterface\\Icons\\INV_Misc_Book_09:14:14:0:0|t",
	["Performance"] = "|TInterface\\Icons\\Spell_ChargePositive:14:14:0:0|t",
	["Bug Fixes"] = "|TInterface\\Icons\\INV_Misc_Wrench_01:14:14:0:0|t",
	["New Features"] = "|TInterface\\Icons\\Ability_Seal:14:14:0:0|t",
	["Improvements"] = "|TInterface\\Icons\\Trade_Engineering:14:14:0:0|t",
	["API"] = "|TInterface\\Icons\\INV_Misc_Gear_01:14:14:0:0|t",
}

-- ---------------------------------------------------------------------------
-- Utility Helpers
-- ---------------------------------------------------------------------------

-- REASON: Categorizes changes for summary line generation.
local function CountChangesByCategory(changes)
	local counts = {}
	local total = 0

	for section, items in pairs(changes) do
		if type(section) == "string" and type(items) == "table" then
			counts[section] = #items
			total = total + #items
		end
	end

	return counts, total
end

-- REASON: Generates a concise summary line for the version header (e.g., "(2 Bug Fixes, 1 New Features)").
local function BuildSummary(counts, useGrey)
	local parts = {}
	local greyColor = "|cff999999"

	-- Order of sections for display
	local sectionOrder = { "Bug Fixes", "New Features", "Performance", "Improvements", "General", "API" }

	for _, section in ipairs(sectionOrder) do
		local count = counts[section]
		if count and count > 0 then
			local color = useGrey and greyColor or (sectionColors[section] or "|cffFFFFFF")
			parts[#parts + 1] = color .. count .. " " .. section .. "|r"
		end
	end

	if #parts > 0 then
		local summaryColor = useGrey and greyColor or K.GreyColor
		return summaryColor .. "(" .. table_concat(parts, summaryColor .. ", " .. "|r") .. summaryColor .. ")|r"
	end

	return ""
end

-- REASON: Processes raw changelog data into a formatted string for the UI.
-- NOTE: Uses escape sequences for colors and embedded textures for icons.
local function BuildChangelogText(highlightLatestOnly)
	local data = K.ChangelogData
	if not data or #data == 0 then
		return "No changelog available."
	end

	local lines = {}
	local greyColor = "|cff999999"
	local separatorColor = "|cff444444"

	-- NOTE: Limit to 15 most recent versions to avoid FontString character/memory limits.
	local maxVersions = math.min(#data, 15)

	for i = 1, maxVersions do
		local entry = data[i]
		if entry and entry.version and entry.changes then
			local isLatest = (i == 1)
			local useGrey = highlightLatestOnly and not isLatest

			-- REASON: Use InfoColor (usually blue/cyan) for versions to make them stand out.
			local versionColor = useGrey and greyColor or K.InfoColor
			lines[#lines + 1] = versionColor .. "Version " .. entry.version .. "|r"

			if entry.date then
				local dateColor = useGrey and greyColor or K.GreyColor
				lines[#lines + 1] = dateColor .. entry.date .. "|r"
			end

			if entry.description then
				local descColor = useGrey and greyColor or K.SystemColor
				lines[#lines + 1] = descColor .. entry.description .. "|r"
			end

			-- REASON: Summary line provides a quick "at a glance" view of changes.
			local counts, total = CountChangesByCategory(entry.changes)
			if total > 0 then
				local summary = BuildSummary(counts, useGrey)
				if summary ~= "" then
					lines[#lines + 1] = summary
				end
			end

			lines[#lines + 1] = " "

			-- REASON: Handle both new sectioned format and legacy array format for backwards compatibility.
			local hasSection = false
			for k in pairs(entry.changes) do
				if type(k) == "string" then
					hasSection = true
					break
				end
			end

			if hasSection then
				for section, items in pairs(entry.changes) do
					local color = useGrey and greyColor or (sectionColors[section] or "|cffFFFFFF")
					local icon = sectionIcons[section] or "•"
					lines[#lines + 1] = color .. icon .. " " .. section .. ":|r"

					for j = 1, #items do
						-- REASON: Alternate shades slightly for better readability in long lists.
						local bulletColor = useGrey and greyColor or K.SystemColor
						local textColor
						if useGrey then
							textColor = greyColor
						else
							textColor = (j % 2 == 1) and "|cffEEEEEE" or "|cffCCCCCC"
						end
						lines[#lines + 1] = "  " .. bulletColor .. "• |r" .. textColor .. items[j] .. "|r"
					end
					lines[#lines + 1] = " "
				end
			else
				for j = 1, #entry.changes do
					local bulletColor = useGrey and greyColor or K.SystemColor
					local textColor
					if useGrey then
						textColor = greyColor
					else
						textColor = (j % 2 == 1) and "|cffEEEEEE" or "|cffCCCCCC"
					end
					lines[#lines + 1] = bulletColor .. "• |r" .. textColor .. entry.changes[j] .. "|r"
				end
				lines[#lines + 1] = " "
			end

			if i < maxVersions then
				lines[#lines + 1] = separatorColor .. string_rep("-", 80) .. "|r"
				lines[#lines + 1] = " "
			end
		end
	end

	if #data > maxVersions then
		lines[#lines + 1] = " "
		lines[#lines + 1] = K.GreyColor .. "... " .. (#data - maxVersions) .. " older versions not shown (character limit)|r"
	end

	return table_concat(lines, "\n")
end

-- ---------------------------------------------------------------------------
-- UI Component: Changelog Frame
-- ---------------------------------------------------------------------------

-- REASON: Singleton pattern to ensure only one instance of the changelog window exists.
local function CreateChangelogFrame()
	if changelogFrame then
		return changelogFrame
	end

	local frame = CreateFrame("Frame", "KKUIChangelogFrame", UIParent)
	frame:SetSize(650, 600)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:CreateBorder()
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:Hide()

	-- Title
	local title = frame:CreateFontString(nil, "OVERLAY")
	title:SetFontObject("GameFontHighlightLarge")
	title:SetPoint("TOP", frame, "TOP", 0, -10)
	title:SetText(K.InfoColor .. "KkthnxUI Changelog|r")

	-- REASON: Visual branding for the changelog.
	if K.AttachPerksTheme then
		frame.PerksOverlay = K.AttachPerksTheme(frame, { variant = "tp", point = "TOP", relPoint = "TOP", x = 0, y = 62, strata = "TOOLTIP", level = 999 })
	end

	-- Logo
	local logo = frame:CreateTexture(nil, "OVERLAY")
	logo:SetSize(512, 256)
	logo:SetBlendMode("ADD")
	logo:SetAlpha(0.07)
	logo:SetTexture(C["Media"].Textures.LogoTexture)
	logo:SetPoint("CENTER", frame, "CENTER", 0, 0)

	-- Scroll frame
	local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
	scrollFrame:SetSize(604, 480)
	scrollFrame:SetPoint("TOP", title, "BOTTOM", 0, -10)
	scrollFrame.ScrollBar:ClearAllPoints()
	scrollFrame.ScrollBar:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", 16, -16)
	scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 16, 16)

	local scrollChild = CreateFrame("Frame")
	scrollChild:SetSize(600, 1)
	scrollFrame:SetScrollChild(scrollChild)
	scrollFrame.ScrollBar:SkinScrollBar()

	-- Changelog text
	local changelogText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	changelogText:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 10, -10)
	changelogText:SetWidth(580)
	changelogText:SetJustifyH("LEFT")
	changelogText:SetJustifyV("TOP")

	frame.changelogText = changelogText
	frame.scrollChild = scrollChild

	-- REASON: Dynamically updates the content and adjusts the scroll child height.
	local function RefreshChangelog()
		local highlightLatest = KkthnxUIDB.ChangelogHighlightLatest or false
		changelogText:SetText(BuildChangelogText(highlightLatest))
		local textHeight = changelogText:GetStringHeight() + 20
		scrollChild:SetHeight(textHeight)
	end

	RefreshChangelog()

	-- Close button
	local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
	closeButton:SkinCloseButton()

	-- REASON: Persistent storage of "don't show" preference in KkthnxUIDB.
	local checkbox = CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
	checkbox:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 6, 6)
	checkbox:SetSize(16, 16)
	checkbox:SkinCheckBox()

	local checkboxLabel = checkbox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	checkboxLabel:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
	checkboxLabel:SetText("Don't show until next update")

	checkbox:SetScript("OnClick", function(self)
		local currentVersion = K.Version or "0.0.0"
		if self:GetChecked() then
			KkthnxUIDB.ChangelogVersion = currentVersion
		else
			KkthnxUIDB.ChangelogVersion = nil
		end
	end)

	frame.checkbox = checkbox

	-- REASON: Allows users to focus on what changed in the current version.
	local highlightCheckbox = CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
	highlightCheckbox:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 6, 28)
	highlightCheckbox:SetSize(16, 16)
	highlightCheckbox:SkinCheckBox()

	local highlightLabel = highlightCheckbox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	highlightLabel:SetPoint("LEFT", highlightCheckbox, "RIGHT", 5, 0)
	highlightLabel:SetText("Focus on latest version")

	highlightCheckbox:SetScript("OnClick", function(self)
		KkthnxUIDB.ChangelogHighlightLatest = self:GetChecked()
		RefreshChangelog()
	end)

	-- Set initial state
	highlightCheckbox:SetChecked(KkthnxUIDB.ChangelogHighlightLatest or false)

	frame.highlightCheckbox = highlightCheckbox

	-- ---------------------------------------------------------------------------
	-- External Links (Buttons)
	-- ---------------------------------------------------------------------------

	-- Discord button with tooltip
	local discordButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	discordButton:SetSize(75, 22)
	discordButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -6, 6)
	discordButton:SetText("|cff7289daDiscord|r")
	discordButton:SkinButton()
	discordButton:SetScript("OnClick", function()
		StaticPopup_Show("KKUI_POPUP_LINK", nil, nil, "https://discord.gg/Rc9wcK9cAB")
	end)
	discordButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:AddLine("Join KkthnxUI Discord", 1, 1, 1)
		GameTooltip:AddLine("Get support, share feedback, and chat with the community!", 0.7, 0.7, 0.7, true)
		GameTooltip:Show()
	end)
	discordButton:SetScript("OnLeave", GameTooltip_Hide)

	-- GitHub button with tooltip
	local githubButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	githubButton:SetSize(75, 22)
	githubButton:SetPoint("RIGHT", discordButton, "LEFT", -6, 0)
	githubButton:SetText("|cfffafbfcGitHub|r")
	githubButton:SkinButton()
	githubButton:SetScript("OnClick", function()
		StaticPopup_Show("KKUI_POPUP_LINK", nil, nil, "https://github.com/Kkthnx-Wow/KkthnxUI")
	end)
	githubButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:AddLine("KkthnxUI GitHub Repository", 1, 1, 1)
		GameTooltip:AddLine("Report issues, contribute code, and view the source!", 0.7, 0.7, 0.7, true)
		GameTooltip:Show()
	end)
	githubButton:SetScript("OnLeave", GameTooltip_Hide)

	-- Issues button with tooltip
	local issuesButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	issuesButton:SetSize(75, 22)
	issuesButton:SetPoint("RIGHT", githubButton, "LEFT", -6, 0)
	issuesButton:SetText("Issues")
	issuesButton:SkinButton()
	issuesButton:SetScript("OnClick", function()
		StaticPopup_Show("KKUI_POPUP_LINK", nil, nil, "https://github.com/Kkthnx-Wow/KkthnxUI/issues")
	end)
	issuesButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:AddLine("Report a Bug or Request a Feature", 1, 1, 1)
		GameTooltip:AddLine("Help us improve KkthnxUI by reporting issues!", 0.7, 0.7, 0.7, true)
		GameTooltip:Show()
	end)
	issuesButton:SetScript("OnLeave", GameTooltip_Hide)

	changelogFrame = frame
	return frame
end

-- ---------------------------------------------------------------------------
-- Global API: Changelog Control
-- ---------------------------------------------------------------------------

-- REASON: Main entry point for showing the changelog; handles version checking.
function K:ShowChangelog(force)
	if not KkthnxUIDB then
		KkthnxUIDB = {}
	end

	local currentVersion = K.Version or "0.0.0"
	local lastSeenVersion = KkthnxUIDB.ChangelogVersion

	-- Show if forced, or if version changed and user hasn't suppressed
	if force or (currentVersion ~= lastSeenVersion) then
		local frame = CreateChangelogFrame()
		frame:Show()

		-- Update checkbox state
		if frame.checkbox then
			frame.checkbox:SetChecked(currentVersion == lastSeenVersion)
		end
	end
end

-- ---------------------------------------------------------------------------
-- Slash Commands
-- ---------------------------------------------------------------------------

SlashCmdList["KKUI_CHANGELOG"] = function()
	K:ShowChangelog(true)
end
SLASH_KKUI_CHANGELOG1 = "/changelog"
SLASH_KKUI_CHANGELOG2 = "/kkchangelog"

-- ---------------------------------------------------------------------------
-- Event Handling
-- ---------------------------------------------------------------------------

-- NOTE: Automated check on login; respects user's "don't show" preference.
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_LOGIN" then
		K:ShowChangelog(false)
	end
end)
