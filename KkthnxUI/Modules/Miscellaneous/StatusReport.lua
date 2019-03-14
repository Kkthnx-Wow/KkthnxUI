local K, C = unpack(select(2, ...))

-- Sourced: ElvUI (Elvz, Blazeflack)

local _G = _G
local math_max = math.max

local CreateFrame = _G.CreateFrame
local GetAddOnInfo = _G.GetAddOnInfo
local GetCurrentResolution = _G.GetCurrentResolution
local GetCVar = _G.GetCVar
local GetLocale = _G.GetLocale
local GetNumAddOns = _G.GetNumAddOns
local GetRealZoneText = _G.GetRealZoneText
local GetScreenResolutions = _G.GetScreenResolutions
local GetSpecialization = _G.GetSpecialization
local GetSpecializationInfo = _G.GetSpecializationInfo
local UnitLevel = _G.UnitLevel
local GetAddOnEnableState = _G.GetAddOnEnableState

local function IsAddOnEnabled(addon)
	return GetAddOnEnableState(K.Name, addon) == 2
end

local function AreOtherAddOnsEnabled()
	local name
	for i = 1, GetNumAddOns() do
		name = GetAddOnInfo(i)
		if ((name ~= "KkthnxUI" and name ~= "KkthnxUI_Config") and IsAddOnEnabled(name)) then -- Loaded or load on demand
			return "Yes"
		end
	end
	return "No"
end

local function GetUiScale()
	local uiScale = GetCVar("uiScale")
	local minUiScale = "0.6"

	return math_max(uiScale, minUiScale)
end

local function GetDisplayMode()
	local window, maximize = GetCVar("gxWindow"), GetCVar("gxMaximize")
	local displayMode

	if window == "1" then
		if maximize == "1" then
			displayMode = "Windowed (Fullscreen)"
		else
			displayMode = "Windowed"
		end
	else
		displayMode = "Fullscreen"
	end

	return displayMode
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
	["WARRIOR"] = "Warrior"
}

local EnglishSpecName = {
	[102] = "Balance",
	[103] = "Feral",
	[104] = "Guardian",
	[105] = "Restoration",
	[250] = "Blood",
	[251] = "Frost",
	[252] = "Unholy",
	[253] = "Beast Mastery",
	[254] = "Marksmanship",
	[255] = "Survival",
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
	[268] = "Brewmaster",
	[269] = "Windwalker",
	[270] = "Mistweaver",
	[577] = "Havoc",
	[581] = "Vengeance",
	[62] = "Arcane",
	[63] = "Fire",
	[64] = "Frost",
	[65] = "Holy",
	[66] = "Protection",
	[70] = "Retribution",
	[71] = "Arms",
	[72] = "Fury",
	[73] = "Protection"
}

local function GetSpecName()
	return EnglishSpecName[GetSpecializationInfo(GetSpecialization())]
end

local function GetResolution()
	return (({GetScreenResolutions()})[GetCurrentResolution()] or GetCVar("gxWindowedResolution"))
end

local function PixelBestSize()
	return max(0.4, min(1.15, 768 / K.ScreenHeight))
end

local function PixelClip(num)
	local str = num and tostring(num)
	if str and strlen(str) > 4 then
		return tonumber(strsub(str, 0, 4))
	end
	return num
end

function K.CreateStatusFrame()
	local function CreateSection(width, height, parent, anchor1, anchorTo, anchor2, yOffset)
		local section = CreateFrame("Frame", nil, parent)
		section:SetSize(width, height)
		section:SetPoint(anchor1, anchorTo, anchor2, 0, yOffset)

		section.Header = CreateFrame("Frame", nil, section)
		section.Header:SetSize(300, 30)
		section.Header:SetPoint("TOP", section)

		section.Header.Text = section.Header:CreateFontString(nil, "ARTWORK", "SystemFont_Outline")
		section.Header.Text:SetPoint("TOP")
		section.Header.Text:SetPoint("BOTTOM")
		section.Header.Text:SetJustifyH("CENTER")
		section.Header.Text:SetJustifyV("MIDDLE")
		local font, height, flags = section.Header.Text:GetFont()
		section.Header.Text:SetFont(font, height * 1.3, flags)

		section.Header.LeftDivider = section.Header:CreateTexture(nil, "ARTWORK")
		section.Header.LeftDivider:SetHeight(8)
		section.Header.LeftDivider:SetPoint("LEFT", section.Header, "LEFT", 5, 0)
		section.Header.LeftDivider:SetPoint("RIGHT", section.Header.Text, "LEFT", -5, 0)
		section.Header.LeftDivider:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
		section.Header.LeftDivider:SetTexCoord(0.81, 0.94, 0.5, 1)

		section.Header.RightDivider = section.Header:CreateTexture(nil, "ARTWORK")
		section.Header.RightDivider:SetHeight(8)
		section.Header.RightDivider:SetPoint("RIGHT", section.Header, "RIGHT", -5, 0)
		section.Header.RightDivider:SetPoint("LEFT", section.Header.Text, "RIGHT", 5, 0)
		section.Header.RightDivider:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
		section.Header.RightDivider:SetTexCoord(0.81, 0.94, 0.5, 1)

		return section
	end

	local function CreateContentLines(num, parent, anchorTo)
		local content = CreateFrame("Frame", nil, parent)
		content:SetSize(260, (num * 20) + ((num - 1) * 5)) -- 20 height and 5 spacing
		content:SetPoint("TOP", anchorTo, "BOTTOM", 0, -5)

		for i = 1, num do
			local line = CreateFrame("Frame", nil, content)
			line:SetSize(260, 20)
			line.Text = line:CreateFontString(nil, "ARTWORK", "SystemFont_Outline")
			line.Text:SetAllPoints()
			line.Text:SetJustifyH("LEFT")
			line.Text:SetJustifyV("MIDDLE")
			content["Line" .. i] = line

			if i == 1 then
				content["Line" .. i]:SetPoint("TOP", content, "TOP")
			else
				content["Line" .. i]:SetPoint("TOP", content["Line" .. (i - 1)], "BOTTOM", 0, -5)
			end
		end

		return content
	end

	--Main frame
	local StatusFrame = CreateFrame("Frame", "KkthnxUIStatusReport", UIParent)
	StatusFrame:SetSize(320, 555)
	StatusFrame:SetPoint("CENTER", UIParent, "CENTER")
	StatusFrame:SetFrameStrata("HIGH")
	StatusFrame:CreateBorder()
	StatusFrame:SetShown(false)
	StatusFrame:SetMovable(true)

	-- Close Button
	StatusFrame.CloseButton = CreateFrame("Button", nil, StatusFrame, "UIPanelCloseButton")
	StatusFrame.CloseButton:SetPoint("TOPRIGHT", 0, 1)
	StatusFrame.CloseButton:SkinCloseButton()
	StatusFrame.CloseButton:RegisterForClicks("AnyUp")
	StatusFrame.CloseButton:SetScript("OnClick", function(self)
		self:GetParent():Hide()
	end)

	-- Title logo (drag to move frame)
	StatusFrame.TitleLogoFrame = CreateFrame("Frame", nil, StatusFrame, "TitleDragAreaTemplate")
	StatusFrame.TitleLogoFrame:SetSize(128, 64)
	StatusFrame.TitleLogoFrame:SetPoint("CENTER", StatusFrame, "TOP", 0, 0)
	StatusFrame.TitleLogoFrame.Texture = StatusFrame.TitleLogoFrame:CreateTexture(nil, "ARTWORK")
	StatusFrame.TitleLogoFrame.Texture:SetTexture(C["Media"].Logo)
	StatusFrame.TitleLogoFrame.Texture:SetAllPoints()

	StatusFrame.TitleLogoFrame.Shade = StatusFrame.TitleLogoFrame:CreateTexture(nil, "BACKGROUND")
	StatusFrame.TitleLogoFrame.Shade:SetTexture(C["Media"].Shader)
	StatusFrame.TitleLogoFrame.Shade:SetPoint("TOPLEFT", StatusFrame.TitleLogoFrame.Texture, "TOPLEFT", -6, 6)
	StatusFrame.TitleLogoFrame.Shade:SetPoint("BOTTOMRIGHT", StatusFrame.TitleLogoFrame.Texture, "BOTTOMRIGHT", 6, -6)
	StatusFrame.TitleLogoFrame.Shade:SetVertexColor(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4] )

	--Sections
	StatusFrame.Section1 = CreateSection(300, 125, StatusFrame, "TOP", StatusFrame, "TOP", -30)
	StatusFrame.Section2 = CreateSection(300, 150, StatusFrame, "TOP", StatusFrame.Section1, "BOTTOM", 0)
	StatusFrame.Section3 = CreateSection(300, 185, StatusFrame, "TOP", StatusFrame.Section2, "BOTTOM", 0)
	StatusFrame.Section4 = CreateSection(300, 60, StatusFrame, "TOP", StatusFrame.Section3, "BOTTOM", 0)

	--Section headers
	StatusFrame.Section1.Header.Text:SetText("|cff4488ffAddOn Info|r")
	StatusFrame.Section2.Header.Text:SetText("|cff4488ffWoW Info|r")
	StatusFrame.Section3.Header.Text:SetText("|cff4488ffCharacter Info|r")
	StatusFrame.Section4.Header.Text:SetText("|cff4488ffReport To|r")

	--Section content
	StatusFrame.Section1.Content = CreateContentLines(4, StatusFrame.Section1, StatusFrame.Section1.Header)
	StatusFrame.Section2.Content = CreateContentLines(5, StatusFrame.Section2, StatusFrame.Section2.Header)
	StatusFrame.Section3.Content = CreateContentLines(6, StatusFrame.Section3, StatusFrame.Section3.Header)
	StatusFrame.Section4.Content = CreateFrame("Frame", nil, StatusFrame.Section4)
	StatusFrame.Section4.Content:SetSize(240, 25)
	StatusFrame.Section4.Content:SetPoint("TOP", StatusFrame.Section4.Header, "BOTTOM", 0, 0)

	--Content lines
	StatusFrame.Section1.Content.Line1.Text:SetFormattedText("Version of KkthnxUI: |cff4beb2c%s|r", K.Version)
	StatusFrame.Section1.Content.Line2.Text:SetFormattedText("Other AddOns Enabled: |cff4beb2c%s|r", AreOtherAddOnsEnabled() )
	StatusFrame.Section1.Content.Line3.Text:SetFormattedText("Scale: |cff4beb2c%s|r", (C["General"]["Scaling"].Value))
	StatusFrame.Section1.Content.Line3.Text:SetFormattedText("Recommended Scale: |cff4beb2c%s|r", PixelClip(PixelBestSize()))
	StatusFrame.Section1.Content.Line4.Text:SetFormattedText("UI Scale Is: |cff4beb2c%s|r", GetUiScale())

	StatusFrame.Section2.Content.Line1.Text:SetFormattedText("Version of WoW: |cff4beb2c%s (build %s)|r", K.WowPatch, K.WowBuild)
	StatusFrame.Section2.Content.Line2.Text:SetFormattedText("Client Language: |cff4beb2c%s|r", GetLocale())
	StatusFrame.Section2.Content.Line3.Text:SetFormattedText("Display Mode: |cff4beb2c%s|r", GetDisplayMode())
	StatusFrame.Section2.Content.Line4.Text:SetFormattedText("Resolution: |cff4beb2c%s|r", GetResolution())
	StatusFrame.Section2.Content.Line5.Text:SetFormattedText("Using Mac Client: |cff4beb2c%s|r", (IsMacClient() == true and "Yes" or "No") )
	StatusFrame.Section3.Content.Line1.Text:SetFormattedText("Faction: |cff4beb2c%s|r", select(2, UnitFactionGroup("player")) )
	StatusFrame.Section3.Content.Line2.Text:SetFormattedText("Race: |cff4beb2c%s|r", K.Race)
	StatusFrame.Section3.Content.Line3.Text:SetFormattedText("Class: |cff4beb2c%s|r", EnglishClassName[K.Class])
	StatusFrame.Section3.Content.Line4.Text:SetFormattedText("Specialization: |cff4beb2c%s|r", GetSpecName())
	StatusFrame.Section3.Content.Line5.Text:SetFormattedText("Level: |cff4beb2c%s|r", UnitLevel("player"))
	StatusFrame.Section3.Content.Line6.Text:SetFormattedText("Zone: |cff4beb2c%s|r", GetRealZoneText())

	--Export buttons
	StatusFrame.Section4.Content.Button1 = CreateFrame("Button", nil, StatusFrame.Section4.Content, "UIPanelButtonTemplate")
	StatusFrame.Section4.Content.Button1:SetSize(100, 23)
	StatusFrame.Section4.Content.Button1:SetPoint("LEFT", StatusFrame.Section4.Content, "LEFT")
	StatusFrame.Section4.Content.Button1:SetText("|cff7289DADiscord")
	StatusFrame.Section4.Content.Button1:SkinButton()
	StatusFrame.Section4.Content.Button1:SetScript("OnClick", function()
		K.StaticPopup_Show("DISCORD_EDITBOX", nil, nil, "https://discord.gg/YUmxqQm")
	end)

	StatusFrame.Section4.Content.Button2 = CreateFrame("Button", nil, StatusFrame.Section4.Content, "UIPanelButtonTemplate")
	StatusFrame.Section4.Content.Button2:SetSize(100, 23)
	StatusFrame.Section4.Content.Button2:SetPoint("RIGHT", StatusFrame.Section4.Content, "RIGHT")
	StatusFrame.Section4.Content.Button2:SetText("|cff6e5494Github")
	StatusFrame.Section4.Content.Button2:SkinButton()
	StatusFrame.Section4.Content.Button2:SetScript("OnClick", function()
		K.StaticPopup_Show("GITHUB_EDITBOX", nil, nil, "https://github.com/Kkthnx/KkthnxUI/issues")
	end)

	K.StatusFrame = StatusFrame
end

local function UpdateDynamicValues()
	K.StatusFrame.Section2.Content.Line3.Text:SetFormattedText("Display Mode: |cff4beb2c%s|r", GetDisplayMode())
	K.StatusFrame.Section2.Content.Line4.Text:SetFormattedText("Resolution: |cff4beb2c%s|r", GetResolution())
	K.StatusFrame.Section3.Content.Line4.Text:SetFormattedText("Specialization: |cff4beb2c%s|r", GetSpecName())
	K.StatusFrame.Section3.Content.Line5.Text:SetFormattedText("Level: |cff4beb2c%s|r", UnitLevel("player"))
	K.StatusFrame.Section3.Content.Line6.Text:SetFormattedText("Zone: |cff4beb2c%s|r", GetRealZoneText())
end

function K.ShowStatusReport()
	if not K.StatusFrame then
		K.CreateStatusFrame()
	end

	if not K.StatusFrame:IsShown() then
		UpdateDynamicValues()
		K.StatusFrame:Raise() -- Set framelevel above everything else
		K.StatusFrame:SetShown(true)
	else
		K.StatusFrame:SetShown(false)
	end
end

K:RegisterChatCommand("kstatus", "ShowStatusReport")