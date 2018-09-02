local AddOnName, Engine = ...

--[[
The MIT License (MIT)

Copyright (c) 2012 - 2018 Kkthnx (Joshua Russell) kkthnxui@gmail.com

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

local _G = _G
local select = select
local string_format = string.format
local string_match = string.match
local tonumber = tonumber

local CreateFrame = _G.CreateFrame
local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS
local GetAddOnEnableState = _G.GetAddOnEnableState
local GetAddOnInfo = _G.GetAddOnInfo
local GetAddOnMetadata = _G.GetAddOnMetadata
local GetBuildInfo = _G.GetBuildInfo
local GetCurrentResolution = _G.GetCurrentResolution
local GetCVar = _G.GetCVar
local GetLocale = _G.GetLocale
local GetNumAddOns = _G.GetNumAddOns
local GetRealmName = _G.GetRealmName
local GetScreenResolutions = _G.GetScreenResolutions
local GetSpecialization = _G.GetSpecialization
local HideUIPanel = _G.HideUIPanel
local hooksecurefunc = _G.hooksecurefunc
local IsAddOnLoaded = _G.IsAddOnLoaded
local issecurevariable = _G.issecurevariable
local LibStub = _G.LibStub
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local UIDROPDOWNMENU_MAXBUTTONS = _G.UIDROPDOWNMENU_MAXBUTTONS
local UIDROPDOWNMENU_MAXLEVELS = _G.UIDROPDOWNMENU_MAXLEVELS
local UnitClass = _G.UnitClass
local UnitGUID = _G.UnitGUID
local UnitLevel = _G.UnitLevel
local UnitName = _G.UnitName
local UnitRace = _G.UnitRace

local AddOn = LibStub("AceAddon-3.0"):NewAddon(AddOnName, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
local About = LibStub:GetLibrary("LibAboutPanel", true)

AddOn.oUF = Engine.oUF or oUF
local oUF = AddOn.oUF

Engine[1] = AddOn
Engine[2] = {}
Engine[3] = {}
Engine[4] = {}

_G[AddOnName] = Engine

AddOn.Title = GetAddOnMetadata(AddOnName, "Title")
AddOn.Version = GetAddOnMetadata(AddOnName, "Version")
AddOn.Noop = function()
	return
end
AddOn.Name = UnitName("player")
AddOn.Class = select(2, UnitClass("player"))
AddOn.Race = select(2, UnitRace("player"))
AddOn.Spec = GetSpecialization() or 0
AddOn.Level = UnitLevel("player")
AddOn.Client = GetLocale()
AddOn.Realm = GetRealmName()
AddOn.Media = "Interface\\AddOns\\KkthnxUI\\Media\\"
AddOn.LSM = LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true)
AddOn.Resolution = ({GetScreenResolutions()})[GetCurrentResolution()] or GetCVar("gxWindowedResolution")
AddOn.ScreenHeight = tonumber(string_match(AddOn.Resolution, "%d+x(%d+)"))
AddOn.ScreenWidth = tonumber(string_match(AddOn.Resolution, "(%d+)x+%d"))
AddOn.PriestColors = {r = 0.86, g = 0.92, b = 0.98, colorStr = "dbebfa"}
AddOn.Color = AddOn.Class == "PRIEST" and AddOn.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[AddOn.Class] or RAID_CLASS_COLORS[AddOn.Class])
AddOn.TexCoords = {0.08, 0.92, 0.08, 0.92}
AddOn.Welcome = "|cff4488ffKkthnxUI "..AddOn.Version.." "..AddOn.Client.."|r - /helpui"
AddOn.WowPatch, AddOn.WowBuild, AddOn.WowRelease, AddOn.TocVersion = GetBuildInfo()
AddOn.WowBuild = tonumber(AddOn.WowBuild)

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

AddOn.AddOns = {}
AddOn.AddOnVersion = {}
for i = 1, GetNumAddOns() do
	local Name = GetAddOnInfo(i)
	AddOn.AddOns[strlower(Name)] = GetAddOnEnableState(AddOn.Name, Name) == 2 or false
	AddOn.AddOnVersion[strlower(Name)] = GetAddOnMetadata(Name, "Version")
end

--HonorFrameLoadTaint workaround
--credit: https://www.townlong-yak.com/bugs/afKy4k-HonorFrameLoadTaint
if (UIDROPDOWNMENU_VALUE_PATCH_VERSION or 0) < 2 then
	UIDROPDOWNMENU_VALUE_PATCH_VERSION = 2
	hooksecurefunc("UIDropDownMenu_InitializeHelper", function()
		if UIDROPDOWNMENU_VALUE_PATCH_VERSION ~= 2 then
			return
		end
		for i = 1, UIDROPDOWNMENU_MAXLEVELS do
			for j = 1, UIDROPDOWNMENU_MAXBUTTONS do
				local b = _G["DropDownList" .. i .. "Button" .. j]
				if not (issecurevariable(b, "value") or b:IsShown()) then
					b.value = nil
					repeat
						j, b["fx" .. j] = j+1
					until issecurevariable(b, "value")
				end
			end
		end
	end)
end

--DisplayModeCommunitiesTaint workaround
--credit https://www.townlong-yak.com/bugs/Kjq4hm-DisplayModeCommunitiesTaint
if (UIDROPDOWNMENU_OPEN_PATCH_VERSION or 0) < 1 then
	UIDROPDOWNMENU_OPEN_PATCH_VERSION = 1
	hooksecurefunc("UIDropDownMenu_InitializeHelper", function(frame)
		if UIDROPDOWNMENU_OPEN_PATCH_VERSION ~= 1 then
			return
		end
		if UIDROPDOWNMENU_OPEN_MENU and UIDROPDOWNMENU_OPEN_MENU ~= frame
		and not issecurevariable(UIDROPDOWNMENU_OPEN_MENU, "displayMode") then
			UIDROPDOWNMENU_OPEN_MENU = nil
			local t, f, prefix, i = _G, issecurevariable, " \0", 1
			repeat
				i, t[prefix .. i] = i + 1
			until f("UIDROPDOWNMENU_OPEN_MENU")
		end
	end)
end