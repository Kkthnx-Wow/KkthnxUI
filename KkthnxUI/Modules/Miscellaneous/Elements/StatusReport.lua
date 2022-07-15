local K, C = unpack(KkthnxUI)

-- Sourced: ElvUI (Elvz, Blazeflack)

local _G = _G
local math_max = math.max

local CreateFrame = _G.CreateFrame
local GetAddOnInfo = _G.GetAddOnInfo
local GetCVar = _G.GetCVar
local GetLocale = _G.GetLocale
local GetNumAddOns = _G.GetNumAddOns
local GetRealZoneText = _G.GetRealZoneText
local GetSpecialization = _G.GetSpecialization
local GetSpecializationInfo = _G.GetSpecializationInfo

local function AreOtherAddOnsEnabled()
	for i = 1, GetNumAddOns() do
		local name = GetAddOnInfo(i)
		if name ~= "KkthnxUI" and K.CheckAddOnState(name) then -- Loaded or load on demand
			return "Yes"
		end
	end
	return "No"
end

local function GetDisplayMode()
	local window, maximize = GetCVar("gxWindow") == "1", GetCVar("gxMaximize") == "1"
	return (window and maximize and "Windowed (Fullscreen)") or (window and "Windowed") or "Fullscreen"
end

local EnglishClassName = {
	["DEATHKNIGHT"] = "Death Knight",
	["DEMONHUNTER"] = "Demon Hunter",
	["DRUID"] = "Druid",
	["HUNTER"] = "Hunter",
	["MAGE"] = "Mage",
	["MONK"] = "Monk",
	["PALADIN"] = "Paladin",
	["PRIEST"] = "Priest",
	["ROGUE"] = "Rogue",
	["SHAMAN"] = "Shaman",
	["WARLOCK"] = "Warlock",
	["WARRIOR"] = "Warrior",
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

local function CreateContentLines(num, parent, anchorTo)
	local content = CreateFrame("Frame", nil, parent)
	content:SetSize(260, (num * 20) + ((num - 1) * 5)) -- 20 height and 5 spacing
	content:SetPoint("TOP", anchorTo, "BOTTOM", 0, -5)

	for i = 1, num do
		local line = CreateFrame("Frame", nil, content)
		line:SetSize(260, 20)

		local text = K.CreateFontString(line, 13, nil, "")
		text:SetAllPoints()
		text:SetJustifyH("LEFT")
		text:SetJustifyV("MIDDLE")
		line.Text = text

		local numLine = line
		if i == 1 then
			numLine:SetPoint("TOP", content, "TOP")
		else
			numLine:SetPoint("TOP", content["Line" .. (i - 1)], "BOTTOM", 0, -5)
		end

		content["Line" .. i] = numLine
	end

	return content
end

local function CloseClicked()
	if K.StatusReportToggled then
		K.StatusReportToggled = nil
	end
end

function K:CreateStatusFrame()
	local function CreateSection(width, height, parent, anchor1, anchorTo, anchor2, yOffset)
		local section = CreateFrame("Frame", nil, parent)
		section:SetSize(width, height)
		section:SetPoint(anchor1, anchorTo, anchor2, 0, yOffset)

		local header = CreateFrame("Frame", nil, section)
		header:SetSize(306, 24)
		header:SetPoint("TOP", section)
		header:CreateBorder()
		section.Header = header

		local text = K.CreateFontString(section.Header, 13 * 1.3, nil, "")
		text:SetPoint("TOP")
		text:SetPoint("BOTTOM")
		text:SetJustifyH("CENTER")
		text:SetJustifyV("MIDDLE")
		section.Header.Text = text

		return section
	end

	--Main frame
	local StatusFrame = CreateFrame("Frame", "KKUI_StatusReport", UIParent)
	StatusFrame:SetSize(320, 500)
	StatusFrame:SetPoint("CENTER", UIParent, "CENTER")
	StatusFrame:SetFrameStrata("HIGH")
	StatusFrame:CreateBorder()
	StatusFrame:SetMovable(true)
	StatusFrame:Hide()

	--Close button and script to retoggle the options.
	StatusFrame.CloseButton = CreateFrame("Button", nil, StatusFrame, "UIPanelCloseButton")
	StatusFrame.CloseButton:SetPoint("TOPRIGHT", 0, 1)
	StatusFrame.CloseButton:SkinCloseButton()
	StatusFrame.CloseButton:HookScript("OnClick", CloseClicked)

	--Title logo (drag to move frame)
	local titleLogoFrame = CreateFrame("Frame", nil, StatusFrame, "TitleDragAreaTemplate")
	titleLogoFrame:SetPoint("CENTER", StatusFrame, "CENTER")
	titleLogoFrame:SetSize(512, 256)
	StatusFrame.TitleLogoFrame = titleLogoFrame

	K.CreateFontString(StatusFrame, 30, K.Title, "", true, "TOPLEFT", 10, 28)
	K.CreateFontString(StatusFrame, 16, "Status Report", "", true, "TOPLEFT", 140, 17)

	local titleTexture = StatusFrame.TitleLogoFrame:CreateTexture(nil, "ARTWORK")
	titleTexture:SetPoint("CENTER", titleLogoFrame, "CENTER")
	titleTexture:SetTexture(C["Media"].Textures.LogoTexture)
	titleTexture:SetSize(512, 256)
	titleTexture:SetBlendMode("ADD")
	titleTexture:SetAlpha(0.06)
	titleLogoFrame.Texture = titleTexture

	--Sections
	StatusFrame.Section1 = CreateSection(306, 126, StatusFrame, "TOP", StatusFrame, "TOP", -32)
	StatusFrame.Section2 = CreateSection(306, 150, StatusFrame, "TOP", StatusFrame.Section1, "BOTTOM", -2)
	StatusFrame.Section3 = CreateSection(306, 186, StatusFrame, "TOP", StatusFrame.Section2, "BOTTOM", -2)
	-- StatusFrame.Section4 = CreateSection(306, 60, StatusFrame, "TOP", StatusFrame.Section3, "BOTTOM", 0)

	--Section headers
	StatusFrame.Section1.Header.Text:SetText(K.SystemColor .. "AddOn Info|r")
	StatusFrame.Section2.Header.Text:SetText(K.SystemColor .. "WoW Info|r")
	StatusFrame.Section3.Header.Text:SetText(K.SystemColor .. "Character Info|r")
	--StatusFrame.Section4.Header.Text:SetText("|cff1784d1Export To|r")

	--Section content
	StatusFrame.Section1.Content = CreateContentLines(4, StatusFrame.Section1, StatusFrame.Section1.Header)
	StatusFrame.Section2.Content = CreateContentLines(5, StatusFrame.Section2, StatusFrame.Section2.Header)
	StatusFrame.Section3.Content = CreateContentLines(6, StatusFrame.Section3, StatusFrame.Section3.Header)
	-- StatusFrame.Section4.Content = CreateFrame("Frame", nil, StatusFrame.Section4)
	-- StatusFrame.Section4.Content:SetSize(240, 25)
	-- StatusFrame.Section4.Content:SetPoint("TOP", StatusFrame.Section4.Header, "BOTTOM", 0, 0)

	--Content lines
	StatusFrame.Section1.Content.Line1.Text:SetFormattedText("Version of KkthnxUI: |cff4beb2c%s|r", K.Version)
	StatusFrame.Section1.Content.Line2.Text:SetFormattedText("Other AddOns Enabled: |cff4beb2c%s|r", AreOtherAddOnsEnabled())
	StatusFrame.Section1.Content.Line3.Text:SetFormattedText("Recommended Scale: |cff4beb2c%s|r", math_max(0.4, math.min(1.15, 768 / K.ScreenHeight)))
	StatusFrame.Section1.Content.Line4.Text:SetFormattedText("UI Scale Is: |cff4beb2c%s|r", C["General"].UIScale)
	StatusFrame.Section2.Content.Line1.Text:SetFormattedText("Version of WoW: |cff4beb2c%s (build %s)|r", K.WowPatch, K.WowBuild)
	StatusFrame.Section2.Content.Line2.Text:SetFormattedText("Client Language: |cff4beb2c%s|r", GetLocale())
	StatusFrame.Section2.Content.Line3.Text:SetFormattedText("Display Mode: |cff4beb2c%s|r", GetDisplayMode())
	StatusFrame.Section2.Content.Line4.Text:SetFormattedText("Resolution: |cff4beb2c%s|r", K.Resolution)
	StatusFrame.Section2.Content.Line5.Text:SetFormattedText("Using Mac Client: |cff4beb2c%s|r", (IsMacClient() == true and "Yes" or "No"))
	StatusFrame.Section3.Content.Line1.Text:SetFormattedText("Faction: |cff4beb2c%s|r", K.Faction)
	StatusFrame.Section3.Content.Line2.Text:SetFormattedText("Race: |cff4beb2c%s|r", K.Race)
	StatusFrame.Section3.Content.Line3.Text:SetFormattedText("Class: |cff4beb2c%s|r", EnglishClassName[K.Class])
	StatusFrame.Section3.Content.Line4.Text:SetFormattedText("Specialization: |cff4beb2c%s|r", GetSpecName())
	StatusFrame.Section3.Content.Line5.Text:SetFormattedText("Level: |cff4beb2c%s|r", K.Level)
	StatusFrame.Section3.Content.Line6.Text:SetFormattedText("Zone: |cff4beb2c%s|r", GetRealZoneText())

	--Export buttons
	-- StatusFrame.Section4.Content.Button1 = CreateFrame("Button", nil, StatusFrame.Section4.Content, "UIPanelButtonTemplate")
	-- StatusFrame.Section4.Content.Button1:SetSize(100, 25)
	-- StatusFrame.Section4.Content.Button1:SetPoint("LEFT", StatusFrame.Section4.Content, "LEFT")
	-- StatusFrame.Section4.Content.Button1:SetText("Not")
	-- StatusFrame.Section4.Content.Button1:SetButtonState("DISABLED")
	-- StatusFrame.Section4.Content.Button2 = CreateFrame("Button", nil, StatusFrame.Section4.Content, "UIPanelButtonTemplate")
	-- StatusFrame.Section4.Content.Button2:SetSize(100, 25)
	-- StatusFrame.Section4.Content.Button2:SetPoint("RIGHT", StatusFrame.Section4.Content, "RIGHT")
	-- StatusFrame.Section4.Content.Button2:SetText("Implemented")
	-- StatusFrame.Section4.Content.Button2:SetButtonState("DISABLED")
	-- StatusFrame.Section4.Content.Button1:SkinButton()
	-- StatusFrame.Section4.Content.Button2:SkinButton()

	return StatusFrame
end

local function UpdateDynamicValues()
	local StatusFrame = K.StatusFrame

	local Section2 = StatusFrame.Section2
	Section2.Content.Line3.Text:SetFormattedText("Display Mode: |cff4beb2c%s|r", GetDisplayMode())
	Section2.Content.Line4.Text:SetFormattedText("Resolution: |cff4beb2c%s|r", K.Resolution)

	local Section3 = StatusFrame.Section3
	Section3.Content.Line4.Text:SetFormattedText("Specialization: |cff4beb2c%s|r", GetSpecName())
	Section3.Content.Line5.Text:SetFormattedText("Level: |cff4beb2c%s|r", K.Level)
	Section3.Content.Line6.Text:SetFormattedText("Zone: |cff4beb2c%s|r", GetRealZoneText())
end

_G.SlashCmdList["KKUI_STATUSREPORT"] = function()
	if not K.StatusFrame then
		K.StatusFrame = K:CreateStatusFrame()
	end

	if not K.StatusFrame:IsShown() then
		UpdateDynamicValues()
		K.StatusFrame:Raise() -- Set framelevel above everything else
		K.StatusFrame:Show()
	else
		K.StatusFrame:Hide()
	end
end
_G.SLASH_KKUI_STATUSREPORT1 = "/kkstatus"
