debugprofilestart()

--[[The MIT License (MIT)

Copyright (c) 2012 - 2017 Kkthnx (Joshua Russell) kkthnxui@gmail.com

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
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.--]]

local AddOnName, Engine = ...

-- GLOBALS: _G, string, debugprofilestart, hooksecurefunc, select, KkthnxUIData, LibStub, CUSTOM_CLASS_COLORS
-- GLOBALS: tonumber, KkthnxUIDataPerChar, KkthnxUIConfigNotShared, KkthnxUIConfigShared, ConsolePort, GameMenuButtonWhatsNew
-- GLOBALS: KkthnxUIConfigFrame, KkthnxUIConfig

-- luacheck: globals _G string debugprofilestart hooksecurefunc select KkthnxUIData LibStub CUSTOM_CLASS_COLORS
-- luacheck: globals tonumber KkthnxUIDataPerChar KkthnxUIConfigNotShared KkthnxUIConfigShared ConsolePort GameMenuButtonWhatsNew
-- luacheck: globals KkthnxUIConfigFrame KkthnxUIConfig

-- Lua API
local _G = _G
local hooksecurefunc = hooksecurefunc
local select = select
local string_lower = string.lower

-- Wow API
local CreateFrame = _G.CreateFrame
local DecodeResolution = _G.DecodeResolution
local GameMenuButtonAddons = _G.GameMenuButtonAddons
local GameMenuButtonLogout = _G.GameMenuButtonLogout
local GameMenuFrame = _G.GameMenuFrame
local GetAddOnEnableState = _G.GetAddOnEnableState
local GetAddOnInfo = _G.GetAddOnInfo
local GetAddOnMetadata = _G.GetAddOnMetadata
local GetBuildInfo = _G.GetBuildInfo
local GetCurrentResolution = _G.GetCurrentResolution
local GetCVar = _G.GetCVar
local GetLocale = _G.GetLocale
local GetNumAddOns = _G.GetNumAddOns
local GetPhysicalScreenSize = _G.GetPhysicalScreenSize
local GetRealmName = _G.GetRealmName
local GetScreenResolutions = _G.GetScreenResolutions
local GetSpecialization = _G.GetSpecialization
local HideUIPanel = _G.HideUIPanel
local InCombatLockdown = _G.InCombatLockdown
local IsAddOnLoaded = _G.IsAddOnLoaded
local LoadAddOn = _G.LoadAddOn
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local StaticPopup_Show = _G.StaticPopup_Show
local UnitClass = _G.UnitClass
local UnitGUID = _G.UnitGUID
local UnitLevel = _G.UnitLevel
local UnitName = _G.UnitName
local UnitRace = _G.UnitRace

-- Define the saved variables first. This is important
if (not KkthnxUIData) then KkthnxUIData = KkthnxUIData or {} end

local AddOn = LibStub("AceAddon-3.0"):NewAddon(AddOnName, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")

Engine[1] = AddOn
Engine[2] = {}
Engine[3] = {}

_G[AddOnName] = Engine

local Name = UnitName("Player")
local Realm = GetRealmName()

AddOn.Title = GetAddOnMetadata(AddOnName, "Title")
AddOn.Version = GetAddOnMetadata(AddOnName, "Version")
AddOn.Noop = function() return end
AddOn.Name = UnitName("player")
AddOn.GUID = UnitGUID("player")
AddOn.Class = select(2, UnitClass("player"))
AddOn.Spec = GetSpecialization() or 0
AddOn.Race = select(2, UnitRace("player"))
AddOn.Level = UnitLevel("player")
AddOn.Client = GetLocale()
AddOn.Realm = GetRealmName()
AddOn.MediaPath = "Interface\\AddOns\\KkthnxUI\\Media\\"
AddOn.LSM = LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true)
AddOn.OmniCC = select(4, GetAddOnInfo("OmniCC"))
AddOn.Resolution = ({GetScreenResolutions()})[GetCurrentResolution()] or GetCVar("gxWindowedResolution")
AddOn.ScreenWidth, AddOn.ScreenHeight = GetPhysicalScreenSize()
AddOn.PriestColors = {r = 0.86, g = 0.92, b = 0.98, colorStr = "dbebfa"}
AddOn.Color = AddOn.Class == "PRIEST" and AddOn.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[AddOn.Class] or RAID_CLASS_COLORS[AddOn.Class])
AddOn.TexCoords = {0.08, 0.92, 0.08, 0.92}
AddOn.WoWPatch, AddOn.WoWBuild, AddOn.WoWPatchReleaseDate, AddOn.TocVersion = GetBuildInfo()
-- AddOn.WoWBuild = select(2, GetBuildInfo()) AddOn.WoWBuild = tonumber(AddOn.WoWBuild)
AddOn.WoWBuild = tonumber((select(2, GetBuildInfo())))

function AddOn:OnInitialize()

	self.GUID = UnitGUID("player")
	-- Create missing entries in the saved vars if they don"t exist.
	if (not KkthnxUIData[Realm]) then KkthnxUIData[Realm] = KkthnxUIData[Realm] or {} end
	if (not KkthnxUIData[Realm][Name]) then KkthnxUIData[Realm][Name] = KkthnxUIData[Realm][Name] or {} end
	if (not KkthnxUIData[Realm][Name].BarsLocked) then KkthnxUIData[Realm][Name].BarsLocked = false end
	if (not KkthnxUIData[Realm][Name].BottomBars) then KkthnxUIData[Realm][Name].BottomBars = Engine[2]["ActionBar"].BottomBars or 2 end
	if (not KkthnxUIData[Realm][Name].RightBars) then KkthnxUIData[Realm][Name].RightBars = Engine[2]["ActionBar"].RightBars or 1 end
	if (not KkthnxUIData[Realm][Name].SplitBars) then KkthnxUIData[Realm][Name].SplitBars = true end
	if (not KkthnxUIData[Realm][Name].AutoInvite) then KkthnxUIData[Realm][Name].AutoInvite = false end
	if (KkthnxUIDataPerChar) then KkthnxUIData[Realm][Name] = KkthnxUIDataPerChar KkthnxUIDataPerChar = nil end

	-- Blizzard has too many issues with per character saved variables, we now move them (if they exists) to account saved variables.
	if (KkthnxUIConfigNotShared) then KkthnxUIConfigShared[Realm][Name] = KkthnxUIConfigNotShared KkthnxUIConfigNotShared = nil end
	if (not KkthnxUIConfigShared) then KkthnxUIConfigShared = {} end
	if (not KkthnxUIConfigShared.Account) then KkthnxUIConfigShared.Account = {} end
	if (not KkthnxUIConfigShared[Realm]) then KkthnxUIConfigShared[Realm] = {} end
	if (not KkthnxUIConfigShared[Realm][Name]) then KkthnxUIConfigShared[Realm][Name] = {} end
	if (KkthnxUIConfigNotShared) then KkthnxUIConfigShared[Realm][Name] = KkthnxUIConfigNotShared KkthnxUIConfigNotShared = nil end

	local IsInstalled = KkthnxUIData[Realm][Name].InstallComplete
	if (not IsInstalled) then
		self.Install:Launch()
	end

	-- KkthnxUI GameMenu Button.
	local GameMenuButton = CreateFrame("Button", nil, GameMenuFrame, "GameMenuButtonTemplate")
	GameMenuButton:SetText(format("|cff4488ff%s|r", AddOnName))
	GameMenuButton:SetScript("OnClick", function()

		if (InCombatLockdown()) then
			return print("|cff4488ffKkthnxUI Config|r: Can only be toggled out of combat!")
		end

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

	if not IsAddOnLoaded("ConsolePort") then
		GameMenuButton:SetSize(GameMenuButtonLogout:GetWidth(), GameMenuButtonLogout:GetHeight())
		GameMenuButton:SetPoint("TOPLEFT", GameMenuButtonAddons, "BOTTOMLEFT", 0, -1)
		hooksecurefunc("GameMenuFrame_UpdateVisibleButtons", self.PositionGameMenuButton)
	else
		if GameMenuButton.Middle then
			GameMenuButton.Middle:Hide()
			GameMenuButton.Left:Hide()
			GameMenuButton.Right:Hide()
		end
		ConsolePort:GetData().Atlas.SetFutureButtonStyle(GameMenuButton, nil, nil, true)
		GameMenuButton:SetSize(240, 46)
		GameMenuButton:SetPoint("TOP", GameMenuButtonWhatsNew, "BOTTOMLEFT", 0, -1)
		GameMenuFrame:SetSize(530, 576)
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

-- Matching the pre-MoP return arguments of the Blizzard API call
function AddOn.GetAddOnInfo(index)
	local name, title, notes, enabled, loadable, reason, security
	name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(index)

	return name, title, notes, enabled, loadable, reason, security
end

-- Check if an addon exists in the addon listing and loadable on demand
function AddOn.IsAddOnLoadable(target)
	local target = strlower(target)
	for i = 1,GetNumAddOns() do
		local name, title, notes, enabled, loadable, reason, security = AddOn.GetAddOnInfo(i)
		if strlower(name) == target then
			if loadable then
				return true
			end
		end
	end
end

-- Check if an addon is enabled	in the addon listing
function AddOn.IsAddOnEnabled(target)
	local target = strlower(target)
	for i = 1, GetNumAddOns() do
		local name, title, notes, enabled, loadable, reason, security = AddOn.GetAddOnInfo(i)
		if strlower(name) == target then
			if enabled then
				return true
			end
		end
	end
end