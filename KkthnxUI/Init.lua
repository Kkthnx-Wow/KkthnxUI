local AddOnName, Engine = ...

--[[
The MIT License (MIT)

Copyright (c) 2012 - 2019 Kkthnx (Joshua Russell) kkthnxui@gmail.com

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished
to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
	INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
	PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
	ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	]]

--[[
This should be at the top of every file inside of the KkthnxUI AddOn:
local K, C, L = unpack(select(2, ...))

This is how another addon imports the KkthnxUI engine:
local K, C, L = unpack(KkthnxUI)
]]

-- ISSUE Review the engine and clean it up. Performance!

local _G = _G
local math_max = math.max
local math_min = math.min
local string_format = string.format
local string_lower = string.lower
local string_match = string.match
local tonumber = tonumber

local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS
local CreateFrame = _G.CreateFrame
local GetAddOnEnableState = _G.GetAddOnEnableState
local GetAddOnInfo = _G.GetAddOnInfo
local GetAddOnMetadata = _G.GetAddOnMetadata
local GetBuildInfo = _G.GetBuildInfo
local GetCVar = _G.GetCVar
local GetCurrentResolution = _G.GetCurrentResolution
local GetLocale = _G.GetLocale
local GetNumAddOns = _G.GetNumAddOns
local GetRealmName = _G.GetRealmName
local GetScreenResolutions = _G.GetScreenResolutions
local GetSpecialization = _G.GetSpecialization
local HideUIPanel = _G.HideUIPanel
local IsAddOnLoaded = _G.IsAddOnLoaded
local LibStub = _G.LibStub
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local UnitClass = _G.UnitClass
local UnitFactionGroup = _G.UnitFactionGroup
local UnitGUID = _G.UnitGUID
local UnitLevel = _G.UnitLevel
local UnitName = _G.UnitName
local UnitRace = _G.UnitRace
local hooksecurefunc = _G.hooksecurefunc
local issecurevariable = _G.issecurevariable

local AddOn = LibStub("AceAddon-3.0"):NewAddon(AddOnName, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
local About = LibStub:GetLibrary("LibAboutPanel", true)

Engine[1] = AddOn
Engine[2] = {}
Engine[3] = {}
Engine[4] = {}

_G[AddOnName] = Engine

AddOn.Title = GetAddOnMetadata(AddOnName, "Title")
AddOn.Version = GetAddOnMetadata(AddOnName, "Version")
AddOn.Credits = GetAddOnMetadata(AddOnName, "X-Credits")

AddOn.Noop = function()
	return
end

AddOn.Name = UnitName("player")
AddOn.LocalizedClass, AddOn.Class, AddOn.ClassID = UnitClass("player")
AddOn.LocalizedRace, AddOn.Race = UnitRace("player")
AddOn.Faction, AddOn.LocalizedFaction = UnitFactionGroup("player")
AddOn.Spec = GetSpecialization() or 0
AddOn.Level = UnitLevel("player")
AddOn.Client = GetLocale()
AddOn.Realm = GetRealmName()
AddOn.oUF = Engine.oUF
AddOn.Media = "Interface\\AddOns\\KkthnxUI\\Media\\"
AddOn.LSM = LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true)
AddOn.Resolution = ({GetScreenResolutions()})[GetCurrentResolution()] or GetCVar("gxWindowedResolution")
AddOn.ScreenHeight = tonumber(string_match(AddOn.Resolution, "%d+x(%d+)"))
AddOn.ScreenWidth = tonumber(string_match(AddOn.Resolution, "(%d+)x+%d"))
AddOn.UIScale = math_min(2, math_max(0.01, 768 / string_match(AddOn.Resolution, "%d+x(%d+)")))
AddOn.PriestColors = {r = 0.86, g = 0.92, b = 0.98, colorStr = "dbebfa"}
AddOn.Color = AddOn.Class == "PRIEST" and AddOn.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[AddOn.Class] or RAID_CLASS_COLORS[AddOn.Class])
AddOn.MyClassColor = string_format("|cff%02x%02x%02x", AddOn.Color.r * 255, AddOn.Color.g * 255, AddOn.Color.b * 255)
AddOn.TexCoords = {0.08, 0.92, 0.08, 0.92}
AddOn.Welcome = "|cff4488ffKkthnxUI "..AddOn.Version.." "..AddOn.Client.."|r - /helpui"
AddOn.ScanTooltip = CreateFrame("GameTooltip", "KkthnxUI_ScanTooltip", _G.UIParent, "GameTooltipTemplate")
AddOn.WowPatch, AddOn.WowBuild, AddOn.WowRelease, AddOn.TocVersion = GetBuildInfo()
AddOn.WowBuild = tonumber(AddOn.WowBuild)
AddOn.IsPTR = GetBuildInfo and AddOn.WowBuild >= 29634
AddOn.InfoColor = "|cff4488ff"
AddOn.CodeDebug = false -- Don't touch this, unless you know what you are doing?

AddOn.ClassList = {}
for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	AddOn.ClassList[v] = k
end
AddOn.ClassColors = {}
local colors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
for class in pairs(colors) do
	AddOn.ClassColors[class] = {}
	AddOn.ClassColors[class].r = colors[class].r
	AddOn.ClassColors[class].g = colors[class].g
	AddOn.ClassColors[class].b = colors[class].b
	AddOn.ClassColors[class].colorStr = colors[class].colorStr
end
AddOn.r, AddOn.g, AddOn.b = AddOn.ClassColors[AddOn.Class].r, AddOn.ClassColors[AddOn.Class].g, AddOn.ClassColors[AddOn.Class].b

if (About) then
	AddOn.optionsFrame = About.new(nil, AddOnName)
end

function AddOn:OnInitialize()
	self.GUID = UnitGUID("player")
	self.CreateStaticPopups()

	-- KkthnxUI GameMenu Button.
	local GameMenuButton = CreateFrame("Button", nil, GameMenuFrame, "GameMenuButtonTemplate")
	GameMenuButton:SetText(string_format("|cff4488ff%s|r", AddOnName))
	GameMenuButton:SetScript("OnClick", function()
		if (not KkthnxUIConfigFrame) then
			KkthnxUIConfig:CreateConfigWindow()
		end

		if KkthnxUIConfigFrame:IsVisible() then
			KkthnxUIConfigFrame:Hide()
		else
			KkthnxUIConfigFrame:Show()
		end

		HideUIPanel(GameMenuFrame)
	end)
	GameMenuFrame[AddOnName] = GameMenuButton

	if not IsAddOnLoaded("ConsolePortUI_Menu") then
		GameMenuButton:SetSize(GameMenuButtonLogout:GetWidth(), GameMenuButtonLogout:GetHeight())
		GameMenuButton:SetPoint("TOPLEFT", GameMenuButtonAddons, "BOTTOMLEFT", 0, -1)
		hooksecurefunc("GameMenuFrame_UpdateVisibleButtons", self.PositionGameMenuButton)
	end
end

function AddOn:PositionGameMenuButton()
	GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + GameMenuButtonLogout:GetHeight())
	local _, relTo, _, _, offY = GameMenuButtonLogout:GetPoint()
	if relTo ~= GameMenuFrame[AddOnName] then
		GameMenuFrame[AddOnName]:ClearAllPoints()
		GameMenuFrame[AddOnName]:SetPoint("TOPLEFT", relTo, "BOTTOMLEFT", 0, -1)
		GameMenuButtonLogout:ClearAllPoints()
		GameMenuButtonLogout:SetPoint("TOPLEFT", GameMenuFrame[AddOnName], "BOTTOMLEFT", 0, offY)
	end
end

function AddOn.ScanTooltipTextures(clean, grabTextures)
	local essenceTextureID, textures, essences = 2975691
	for i = 1, 10 do
		local tex = _G["KkthnxUI_ScanTooltipTexture"..i]
		local texture = tex and tex:GetTexture()
		if texture then
			if grabTextures then
				if not textures then textures = {} end
				if texture == essenceTextureID then
					if not essences then essences = {} end

					local selected = (textures[i-1] ~= essenceTextureID and textures[i-1]) or nil
					essences[i] = {selected, tex:GetAtlas(), texture}

					if selected then
						textures[i-1] = nil
					end
				else
					textures[i] = texture
				end
			end
			if clean then
				tex:SetTexture()
			end
		end
	end

	return textures, essences
end

AddOn.AddOns = {}
AddOn.AddOnVersion = {}
for i = 1, GetNumAddOns() do
	local Name = GetAddOnInfo(i)
	AddOn.AddOns[string_lower(Name)] = GetAddOnEnableState(AddOn.Name, Name) == 2
	AddOn.AddOnVersion[string_lower(Name)] = GetAddOnMetadata(Name, "Version")
end

do
	InterfaceOptionsFrameCancel:SetScript("OnClick", function()
		InterfaceOptionsFrameOkay:Click()
	end)

	-- https://www.townlong-yak.com/bugs/Kjq4hm-DisplayModeCommunitiesTaint
	if (UIDROPDOWNMENU_OPEN_PATCH_VERSION or 0) < 1 then
		UIDROPDOWNMENU_OPEN_PATCH_VERSION = 1
		hooksecurefunc("UIDropDownMenu_InitializeHelper", function(frame)
			if UIDROPDOWNMENU_OPEN_PATCH_VERSION ~= 1 then
				return
			end

			if UIDROPDOWNMENU_OPEN_MENU and UIDROPDOWNMENU_OPEN_MENU ~= frame and not issecurevariable(UIDROPDOWNMENU_OPEN_MENU, "displayMode") then
				UIDROPDOWNMENU_OPEN_MENU = nil
				local t, f, prefix, i = _G, issecurevariable, " \0", 1
				repeat
					i, t[prefix .. i] = i+1
				until f("UIDROPDOWNMENU_OPEN_MENU")
			end
		end)
	end

	-- https://www.townlong-yak.com/bugs/YhgQma-SetValueRefreshTaint
	if (COMMUNITY_UIDD_REFRESH_PATCH_VERSION or 0) < 1 then
		COMMUNITY_UIDD_REFRESH_PATCH_VERSION = 1
		local function CleanDropdowns()
			if COMMUNITY_UIDD_REFRESH_PATCH_VERSION ~= 1 then
				return
			end
			local f, f2 = FriendsFrame, FriendsTabHeader
			local s = f:IsShown()
			f:Hide()
			f:Show()
			if not f2:IsShown() then
				f2:Show()
				f2:Hide()
			end
			if not s then
				f:Hide()
			end
		end
		hooksecurefunc("Communities_LoadUI", CleanDropdowns)
		hooksecurefunc("SetCVar", function(n)
			if n == "lastSelectedClubId" then
				CleanDropdowns()
			end
		end)
	end
end