local AddOnName, Engine = ...
local Resolution = GetCurrentResolution() > 0 and select(GetCurrentResolution(), GetScreenResolutions()) or nil
local Windowed = Display_DisplayModeDropDown:windowedmode()
local Fullscreen = Display_DisplayModeDropDown:fullscreenmode()

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

-- Lua API
local _G = _G
local select = select
local string_format = string.format
local string_lower = string.lower
local string_match = string.match
local tonumber = tonumber

-- Wow API
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
local GetPhysicalScreenSize = _G.GetPhysicalScreenSize
local GetRealmName = _G.GetRealmName
local GetScreenResolutions = _G.GetScreenResolutions
local GetSpecialization = _G.GetSpecialization
local HideUIPanel = _G.HideUIPanel
local hooksecurefunc = _G.hooksecurefunc
local InCombatLockdown = _G.InCombatLockdown
local IsAddOnLoaded = _G.IsAddOnLoaded
local LibStub = _G.LibStub
local PlaySound = _G.PlaySound
local PlaySoundKitID = _G.PlaySoundKitID
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local UnitClass = _G.UnitClass
local UnitGUID = _G.UnitGUID
local UnitLevel = _G.UnitLevel
local UnitName = _G.UnitName
local UnitRace = _G.UnitRace

local AddOn = LibStub("AceAddon-3.0"):NewAddon(AddOnName, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
AddOn.callbacks = AddOn.callbacks or LibStub("CallbackHandler-1.0")
local About = LibStub:GetLibrary("LibAboutPanel", true)

AddOn.oUF = Engine.oUF or oUF
local oUF = AddOn.oUF

Engine[1] = AddOn
Engine[2] = {}
Engine[3] = {}

_G[AddOnName] = Engine

AddOn.Title = GetAddOnMetadata(AddOnName, "Title")
AddOn.Version = GetAddOnMetadata(AddOnName, "Version")
AddOn.Noop = function() return end
AddOn.Name = UnitName("player")
AddOn.Class = select(2, UnitClass("player"))
AddOn.Race = select(2, UnitRace("player"))
AddOn.Spec = GetSpecialization() or 0
AddOn.Level = UnitLevel("player")
AddOn.Client = GetLocale()
AddOn.Realm = GetRealmName()
AddOn.MediaPath = "Interface\\AddOns\\KkthnxUI\\Media\\"
AddOn.LSM = LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true)
AddOn.OmniCC = select(4, GetAddOnInfo("OmniCC"))
AddOn.Resolution = Resolution or (Windowed and GetCVar("gxWindowedResolution")) or GetCVar("gxFullscreenResolution")
AddOn.ScreenHeight = tonumber(string_match(AddOn.Resolution, "%d+x(%d+)"))
AddOn.ScreenWidth = tonumber(string_match(AddOn.Resolution, "(%d+)x+%d"))
AddOn.PriestColors = {r = 0.86, g = 0.92, b = 0.98, colorStr = "dbebfa"}
AddOn.Color = AddOn.Class == "PRIEST" and AddOn.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[AddOn.Class] or RAID_CLASS_COLORS[AddOn.Class])
AddOn.TexCoords = {0.08, 0.92, 0.08, 0.92}
AddOn.WoWPatch, AddOn.WoWBuild, AddOn.WoWPatchReleaseDate, AddOn.TocVersion = GetBuildInfo() AddOn.WoWBuild = tonumber(AddOn.WoWBuild)
AddOn.PlaySoundKitID = AddOn.WoWBuild == 24500 and PlaySound or PlaySoundKitID
AddOn.Legion715 = AddOn.WoWBuild == 23360
AddOn.Legion735 = AddOn.WoWBuild >= 26124

if (About) then
  AddOn.optionsFrame = About.new(nil, "KkthnxUI")
end

function AddOn:OnInitialize()
  self.GUID = UnitGUID("player")

  -- KkthnxUI GameMenu Button.
  local GameMenuButton = CreateFrame("Button", nil, GameMenuFrame, "GameMenuButtonTemplate")
  GameMenuButton:SetText(string_format("|cff4488ff%s|r", AddOnName))
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
  GameMenuButton:SetPoint("TOPLEFT", GameMenuButtonAddons, "BOTTOMLEFT", 0, - 1)
  hooksecurefunc("GameMenuFrame_UpdateVisibleButtons", self.PositionGameMenuButton)
else
  if GameMenuButton.Middle then
    GameMenuButton.Middle:Hide()
    GameMenuButton.Left:Hide()
    GameMenuButton.Right:Hide()
  end
  ConsolePort:GetData().Atlas.SetFutureButtonStyle(GameMenuButton, nil, nil, true)
  GameMenuButton:SetSize(240, 46)
  GameMenuButton:SetPoint("TOP", GameMenuButtonWhatsNew, "BOTTOMLEFT", 0, - 1)
  GameMenuFrame:SetSize(530, 576)
end
end

function AddOn:PositionGameMenuButton()
GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + GameMenuButtonLogout:GetHeight())
local _, relTo, _, _, offY = GameMenuButtonLogout:GetPoint()
if relTo ~= GameMenuFrame[AddOnName] then
  GameMenuFrame[AddOnName]:ClearAllPoints()
  GameMenuFrame[AddOnName]:SetPoint("TOPLEFT", relTo, "BOTTOMLEFT", 0, - 1)
  GameMenuButtonLogout:ClearAllPoints()
  GameMenuButtonLogout:SetPoint("TOPLEFT", GameMenuFrame[AddOnName], "BOTTOMLEFT", 0, offY)
end
end

AddOn.AddOns = {}
for i = 1, GetNumAddOns() do
local Name = GetAddOnInfo(i)
AddOn.AddOns[string_lower(Name)] = GetAddOnEnableState(AddOn.Name, Name) > 0
end