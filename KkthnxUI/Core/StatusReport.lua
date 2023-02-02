local K, C = unpack(KkthnxUI)

local CreateFrame = CreateFrame
local GetAddOnInfo = GetAddOnInfo
local GetCVarBool = GetCVarBool
local GetNumAddOns = GetNumAddOns
local GetRealZoneText = GetRealZoneText
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local UNKNOWN = UNKNOWN

local function AreOtherAddOnsEnabled()
	local addons

	for i = 1, GetNumAddOns() do
		local name = GetAddOnInfo(i)
		if name ~= "KkthnxUI" and name ~= "KkthnxUI_Dev" and name ~= "!BaudErrorFrame" and K.CheckAddOnState(name) then
			addons = true
		end
	end

	return addons
end

local function GetDisplayMode()
	return GetCVarBool("gxMaximize") and "Fullscreen" or "Windowed"
end

local function GetBestScale()
	local scale = math.max(0.4, math.min(1.15, 768 / K.ScreenHeight))
	return K.Round(scale, 2)
end

local EnglishClassName = {
	DEATHKNIGHT = K.GetClassIconAndColor("DEATHKNIGHT", "|CFFC41F3B") .. "Death Knight",
	DEMONHUNTER = K.GetClassIconAndColor("DEMONHUNTER", "|CFFA330C9") .. "Demon Hunter",
	DRUID = K.GetClassIconAndColor("DRUID", "|CFFFF7D0A") .. "Druid",
	EVOKER = K.GetClassIconAndColor("EVOKER", "|CFF33937F") .. "Evoker",
	HUNTER = K.GetClassIconAndColor("HUNTER", "|CFFA9D271") .. "Hunter",
	MAGE = K.GetClassIconAndColor("MAGE", "|CFF40C7EB") .. "Mage",
	MONK = K.GetClassIconAndColor("MONK", "|CFF00FF96") .. "Monk",
	PALADIN = K.GetClassIconAndColor("PALADIN", "|CFFF58CBA") .. "Paladin",
	PRIEST = K.GetClassIconAndColor("PRIEST", "|CFFFFFFFF") .. "Priest",
	ROGUE = K.GetClassIconAndColor("ROGUE", "|CFFFFF569") .. "Rogue",
	SHAMAN = K.GetClassIconAndColor("SHAMAN", "|CFF0070DE") .. "Shaman",
	WARLOCK = K.GetClassIconAndColor("WARLOCK", "|CFF8787ED") .. "Warlock",
	WARRIOR = K.GetClassIconAndColor("WARRIOR", "|CFFC79C6E") .. "Warrior",
}

local EnglishSpecName = {
	[250] = "Blood",
	[251] = "Frost",
	[252] = "Unholy",
	[102] = "Balance",
	[103] = "Feral",
	[104] = "Guardian",
	[105] = "Restoration",
	[253] = "Beast Mastery",
	[254] = "Marksmanship",
	[255] = "Survival",
	[62] = "Arcane",
	[63] = "Fire",
	[64] = "Frost",
	[268] = "Brewmaster",
	[270] = "Mistweaver",
	[269] = "Windwalker",
	[65] = "Holy",
	[66] = "Protection",
	[70] = "Retribution",
	[256] = "Discipline",
	[257] = "Holy",
	[258] = "Shadow",
	[259] = "Assasination",
	[260] = "Combat",
	[261] = "Sublety",
	[262] = "Elemental",
	[263] = "Enhancement",
	[264] = "Restoration",
	[265] = "Affliction",
	[266] = "Demonoligy",
	[267] = "Destruction",
	[71] = "Arms",
	[72] = "Fury",
	[73] = "Protection",
	[577] = "Havoc",
	[581] = "Vengeance",
}

local function GetSpecName()
	return EnglishSpecName[GetSpecializationInfo(GetSpecialization())]
end

local function CreateStatusContent(num, width, parent, anchorTo, content)
	if not content then
		content = CreateFrame("Frame", nil, parent)
	end
	content:SetSize(width, (num * 20) + ((num - 1) * 6)) --20 height and 6 spacing
	content:SetPoint("TOP", anchorTo, "BOTTOM")

	for i = 1, num do
		if not content["Line" .. i] then
			local line = CreateFrame("Frame", nil, content)
			line:SetSize(width, 20)

			local text = line:CreateFontString(nil, "ARTWORK")
			text:SetAllPoints()
			text:SetJustifyH("LEFT")
			text:SetJustifyV("MIDDLE")
			text:SetFontObject(K.UIFont)
			text:SetFont(select(1, text:GetFont()), 14, select(3, text:GetFont()))
			line.Text = text

			if i == 1 then
				line:SetPoint("TOP", content, "TOP")
			else
				line:SetPoint("TOP", content["Line" .. (i - 1)], "BOTTOM", 0, -5)
			end

			content["Line" .. i] = line
		end
	end

	return content
end

local function CloseClicked()
	if K.StatusFrame:IsShown() then
		K.StatusFrame:Hide()
	end
end

local function CreateStatusSection(width, height, headerWidth, headerHeight, parent, anchor1, anchorTo, anchor2, yOffset)
	local parentWidth, parentHeight = parent:GetSize()

	if width > parentWidth then
		parent:SetWidth(width + 25)
	end

	if height then
		parent:SetHeight(parentHeight + height)
	end

	local section = CreateFrame("Frame", nil, parent)
	section:SetSize(width, height or 0)
	section:SetPoint(anchor1, anchorTo, anchor2, 0, yOffset)

	local header = CreateFrame("Frame", nil, section)
	header:SetSize(headerWidth or width, headerHeight)
	header:SetPoint("TOP", section)
	section.Header = header

	local text = section.Header:CreateFontString(nil, "ARTWORK")
	text:SetPoint("TOP")
	text:SetPoint("BOTTOM")
	text:SetJustifyH("CENTER")
	text:SetJustifyV("MIDDLE")
	text:SetFontObject(K.UIFont)
	text:SetFont(select(1, text:GetFont()), 18, select(3, text:GetFont()))
	section.Header.Text = text

	local leftDivider = section.Header:CreateTexture(nil, "ARTWORK")
	leftDivider:SetHeight(8)
	leftDivider:SetPoint("LEFT", section.Header, "LEFT", 5, 0)
	leftDivider:SetPoint("RIGHT", section.Header.Text, "LEFT", -5, 0)
	leftDivider:SetTexture([[Interface\Tooltips\UI-Tooltip-Border]])
	leftDivider:SetTexCoord(0.81, 0.94, 0.5, 1)
	section.Header.LeftDivider = leftDivider

	local rightDivider = section.Header:CreateTexture(nil, "ARTWORK")
	rightDivider:SetHeight(8)
	rightDivider:SetPoint("RIGHT", section.Header, "RIGHT", -5, 0)
	rightDivider:SetPoint("LEFT", section.Header.Text, "RIGHT", 5, 0)
	rightDivider:SetTexture([[Interface\Tooltips\UI-Tooltip-Border]])
	rightDivider:SetTexCoord(0.81, 0.94, 0.5, 1)
	section.Header.RightDivider = rightDivider

	return section
end

local function CreateStatusFrame()
	-- Main frame
	local StatusFrame = CreateFrame("Frame", "KKUI_StatusReport", UIParent)
	StatusFrame:SetPoint("CENTER", UIParent, "CENTER")
	StatusFrame:SetFrameStrata("HIGH")
	StatusFrame:CreateBorder()
	StatusFrame:SetMovable(true)
	StatusFrame:SetSize(0, 35)
	StatusFrame:Hide()
	K.CreateMoverFrame(StatusFrame)

	-- Close button and script to retoggle the options.
	local CloseButton = CreateFrame("Button", nil, StatusFrame)
	CloseButton:SetSize(32, 32)
	CloseButton:SetPoint("TOPRIGHT", StatusFrame, 0, 0)
	CloseButton:HookScript("OnClick", CloseClicked)

	CloseButton.Texture = CloseButton:CreateTexture(nil, "OVERLAY")
	CloseButton.Texture:SetPoint("CENTER", CloseButton, 0, 0)
	CloseButton.Texture:SetSize(20, 20)
	CloseButton.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\CloseButton_32")

	local LogoCenter = StatusFrame:CreateTexture(nil, "OVERLAY")
	LogoCenter:SetSize(512 / 1.4, 256 / 1.4)
	LogoCenter:SetBlendMode("ADD")
	LogoCenter:SetAlpha(0.07)
	LogoCenter:SetTexture(C["Media"].Textures.LogoTexture)
	LogoCenter:SetPoint("CENTER", StatusFrame, "CENTER", 0, 0)

	-- Sections
	StatusFrame.Section1 = CreateStatusSection(300, 125, nil, 30, StatusFrame, "TOP", StatusFrame, "TOP", -30)
	StatusFrame.Section2 = CreateStatusSection(300, 130, nil, 30, StatusFrame, "TOP", StatusFrame.Section1, "BOTTOM", 0)
	StatusFrame.Section3 = CreateStatusSection(300, 185, nil, 30, StatusFrame, "TOP", StatusFrame.Section2, "BOTTOM", 0)

	-- Section content
	StatusFrame.Section1.Content = CreateStatusContent(4, 260, StatusFrame.Section1, StatusFrame.Section1.Header)
	StatusFrame.Section2.Content = CreateStatusContent(5, 260, StatusFrame.Section2, StatusFrame.Section2.Header)
	StatusFrame.Section3.Content = CreateStatusContent(6, 260, StatusFrame.Section3, StatusFrame.Section3.Header)

	local factionColor
	local factionIcon
	if K.Faction == "Alliance" then
		factionColor = "|CFF004A94"
		factionIcon = "|TInterface\\AddOns\\KkthnxUI\\Media\\Minimap\\Alliance:20:20:2|t"
	elseif K.Faction == "Horde" then
		factionColor = "|CFF8C1616"
		factionIcon = "|TInterface\\AddOns\\KkthnxUI\\Media\\Minimap\\Horde:20:20:2|t"
	else
		factionColor = K.SystemColor
		factionIcon = "|TInterface\\COMMON\\friendship-FistHuman:20:20:2|t"
	end

	-- Content lines
	StatusFrame.Section1.Content.Line3.Text:SetFormattedText("Recommended Scale: " .. K.SystemColor .. "%s|r", GetBestScale())
	StatusFrame.Section1.Content.Line4.Text:SetFormattedText("UI Scale Is: " .. K.SystemColor .. "%s|r", C["General"].UIScale)
	StatusFrame.Section2.Content.Line1.Text:SetFormattedText("Version of WoW: " .. K.SystemColor .. "%s (build %s)|r", K.WowPatch, K.WowBuild)
	StatusFrame.Section2.Content.Line2.Text:SetFormattedText("Client Language: " .. K.SystemColor .. "%s|r", K.Client)
	StatusFrame.Section3.Content.Line1.Text:SetFormattedText("Faction:" .. factionIcon .. factionColor .. "%s|r", K.Faction)
	StatusFrame.Section3.Content.Line2.Text:SetFormattedText("Race: " .. K.SystemColor .. " %s|r", K.Race)
	StatusFrame.Section3.Content.Line3.Text:SetFormattedText("Class: " .. K.SystemColor .. "%s|r", EnglishClassName[K.Class])

	return StatusFrame
end

local function UpdateStatusFrame()
	local StatusFrame = K.StatusFrame

	-- Section headers
	local valueColor = "|cff669DFF"
	StatusFrame.Section1.Header.Text:SetFormattedText("%sAddOn Info|r", valueColor)
	StatusFrame.Section2.Header.Text:SetFormattedText("%sWoW Info|r", valueColor)
	StatusFrame.Section3.Header.Text:SetFormattedText("%sCharacter Info|r", valueColor)

	StatusFrame.Section1.Content.Line3.Text:SetFormattedText("Recommended Scale: " .. K.SystemColor .. "%s|r", GetBestScale())
	StatusFrame.Section1.Content.Line4.Text:SetFormattedText("UI Scale Is: " .. K.SystemColor .. "%s|r", C["General"].UIScale)

	StatusFrame.Section1.Content.Line1.Text:SetFormattedText("Version of KkthnxUI: %s%s", valueColor, K.Version)
	StatusFrame.Section1.Content.Line2.Text:SetFormattedText("Other AddOns Enabled: |cff%s|r", (AreOtherAddOnsEnabled() and "ff3333Yes") or "33ff33No")

	local Section2 = StatusFrame.Section2
	Section2.Content.Line3.Text:SetFormattedText("Display Mode: " .. K.SystemColor .. "%s|r", GetDisplayMode())
	Section2.Content.Line4.Text:SetFormattedText("Resolution: " .. K.SystemColor .. "%s|r", K.Resolution)

	local Section3 = StatusFrame.Section3
	Section3.Content.Line4.Text:SetFormattedText("Level: " .. K.SystemColor .. "%s|r", K.Level)
	Section3.Content.Line5.Text:SetFormattedText("Zone: " .. K.SystemColor .. "%s|r", GetRealZoneText() or UNKNOWN)
	Section3.Content.Line6.Text:SetFormattedText("Specialization: " .. K.SystemColor .. "%s|r", GetSpecName() or UNKNOWN)
end

function K:ShowStatusReport()
	if not K.StatusFrame then
		K.StatusFrame = CreateStatusFrame()
	end

	if not K.StatusFrame:IsShown() then
		UpdateStatusFrame()
		K.StatusFrame:Show()
	else
		K.StatusFrame:Hide()
	end
end

SlashCmdList.STATUSREPORT = function()
	K:ShowStatusReport()
end

SLASH_STATUSREPORT1 = "/kkstatus"
SLASH_STATUSREPORT2 = "/kstatus"
