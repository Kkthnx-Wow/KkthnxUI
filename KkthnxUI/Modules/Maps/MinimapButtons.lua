local K, C = unpack(select(2, ...))
local Module = K:NewModule("MinimapButtons", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")

-- Sourced: ProjectAzilroka (Azilroka)
-- Edited: KkthnxUI (Kkthnx)

local _G = _G
local pairs = pairs
local select = select
local string_find = string.find
local string_len = string.len
local string_lower = string.lower
local string_sub = string.sub
local table_contains = tContains
local table_insert = table.insert
local tostring = tostring

local C_PetBattles_IsInBattle = _G.C_PetBattles.IsInBattle
local CreateFrame = _G.CreateFrame
local InCombatLockdown = _G.InCombatLockdown
local UIParent = _G.UIParent

_G.KKUI_MinimapButtons = Module

Module.Buttons = {}

local ignoreButtons = {
	"GameTimeFrame",
	"HelpOpenWebTicketButton",
	"MiniMapVoiceChatFrame",
	"TimeManagerClockButton",
	"BattlefieldMinimap",
	"ButtonCollectFrame",
	"QueueStatusMinimapButton",
	"GarrisonLandingPageMinimapButton",
	"MiniMapMailFrame",
	"MiniMapTracking",
	"MinimapZoomIn",
	"MinimapZoomOut",
}

local GenericIgnores = {
	"Archy",
	"GatherMatePin",
	"GatherNote",
	"GuildInstance",
	"HandyNotesPin",
	"MiniMap",
	"Spy_MapNoteList_mini",
	"ZGVMarker",
	"poiMinimap",
	"GuildMap3Mini",
	"LibRockConfig-1.0_MinimapButton",
	"NauticusMiniIcon",
	"WestPointer",
	"Cork",
	"DugisArrowMinimapPoint",
}

local PartialIgnores = {
	"Node",
	"Note",
	"Pin",
	"POI"
}

local ButtonFunctions = {
	"SetParent",
	"ClearAllPoints",
	"SetPoint",
	"SetSize",
	"SetScale",
	"SetFrameStrata",
	"SetFrameLevel"
}

function Module:LockButton(Button)
	for _, Function in pairs(ButtonFunctions) do
		Button[Function] = K.Noop
	end
end

function Module:UnlockButton(Button)
	for _, Function in pairs(ButtonFunctions) do
		Button[Function] = nil
	end
end

function Module:SkinMinimapButton(Button)
	if (not Button) or Button.isSkinned then
		return
	end

	local Name = Button:GetName()
	if not Name then
		return
	end

	if table_contains(ignoreButtons, Name) then
		return
	end

	for i = 1, #GenericIgnores do
		if string_sub(Name, 1, string_len(GenericIgnores[i])) == GenericIgnores[i] then
			return
		end
	end

	for i = 1, #PartialIgnores do
		if string_find(Name, PartialIgnores[i]) ~= nil then
			return
		end
	end

	for i = 1, Button:GetNumRegions() do
		local Region = select(i, Button:GetRegions())
		if Region.IsObjectType and Region:IsObjectType("Texture") then
			local Texture = string_lower(tostring(Region:GetTexture()))

			if (string_find(Texture, "interface\\characterframe") or (string_find(Texture, "interface\\minimap") and not string_find(Texture, "interface\\minimap\\tracking\\")) or string_find(Texture, "border") or string_find(Texture, "background") or string_find(Texture, "alphamask") or string_find(Texture, "highlight")) then
				Region:SetTexture()
				Region:SetAlpha(0)
			else
				if Name == "BagSync_MinimapButton" then
					Region:SetTexture("Interface\\AddOns\\BagSync\\media\\icon")
				elseif Name == "DBMMinimapButton" then
					Region:SetTexture("Interface\\Icons\\INV_Helmet_87")
				elseif Name == "OutfitterMinimapButton" then
					if Region:GetTexture() == "Interface\\Addons\\Outfitter\\Textures\\MinimapButton" then
						Region:SetTexture()
					end
				elseif Name == "SmartBuff_MiniMapButton" then
					Region:SetTexture("Interface\\Icons\\Spell_Nature_Purge")
				elseif Name == "VendomaticButtonFrame" then
					Region:SetTexture("Interface\\Icons\\INV_Misc_Rabbit_2")
				end

				Region:ClearAllPoints()
				Region:SetAllPoints()
				Region:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
				Button:HookScript("OnLeave", function()
					Region:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
				end)
				Region:SetDrawLayer("ARTWORK")
				Region.SetPoint = function()
					return
				end
			end
		end
	end

	Button:SetFrameLevel(Minimap:GetFrameLevel() + 5)
	Button:SetSize(C["MinimapButtons"].IconSize, C["MinimapButtons"].IconSize)
	Button:CreateBorder()
	Button:HookScript("OnEnter", function(self)
		self:SetBackdropBorderColor(K.Color.r, K.Color.g, K.Color.b)
		if Module.Bar:IsShown() then
			K.UIFrameFadeIn(Module.Bar, 0.2, Module.Bar:GetAlpha(), 1)
		end
	end)

	Button:HookScript("OnLeave", function(self)
		self:SetBackdropBorderColor()
		self:CreateBorder()
		if Module.Bar:IsShown() and C["MinimapButtons"].BarMouseOver then
			K.UIFrameFadeOut(Module.Bar, 0.2, Module.Bar:GetAlpha(), 0.25)
		end
	end)

	Button.isSkinned = true
	table_insert(self.Buttons, Button)
end

function Module:GrabMinimapButtons()
	if (InCombatLockdown() or C_PetBattles_IsInBattle()) then
		return
	end

	for _, Frame in pairs({Minimap, MinimapBackdrop}) do
		local NumChildren = Frame:GetNumChildren()
		if NumChildren < (Frame.SMBNumChildren or 0) then
			return
		end

		for i = 1, NumChildren do
			local object = select(i, Frame:GetChildren())
			if object then
				local name = object:GetName()
				local width = object:GetWidth()
				if name and width > 15 and width < 40 and (object:IsObjectType("Button") or object:IsObjectType("Frame")) then
					self:SkinMinimapButton(object)
				end
			end
		end
		Frame.SMBNumChildren = NumChildren
	end

	self:Update()
end

function Module:Update()
	if not C["MinimapButtons"].EnableBar then
		return
	end

	local AnchorX, AnchorY = 0, 1
	local ButtonsPerRow = C["MinimapButtons"].ButtonsPerRow or 1
	local Spacing, Mult = C["MinimapButtons"].ButtonSpacing or 6, K.Mult or 1
	local Size = C["MinimapButtons"].IconSize or 18
	local ActualButtons, Maxed = 0

	for _, Button in pairs(Module.Buttons) do
		if Button:IsVisible() then
			AnchorX = AnchorX + 1
			ActualButtons = ActualButtons + 1
			if (AnchorX % (ButtonsPerRow + 1)) == 0 then
				AnchorY = AnchorY + 1
				AnchorX = 1
				Maxed = true
			end

			Module:UnlockButton(Button)

			Button:CreateBorder()
			Button:SetParent(self.Bar)
			Button:ClearAllPoints()
			Button:SetPoint("TOPLEFT", self.Bar, "TOPLEFT", (Spacing + ((Size + Spacing) * (AnchorX - 1))), (- Spacing - ((Size + Spacing) * (AnchorY - 1))))
			Button:SetSize(C["MinimapButtons"].IconSize, C["MinimapButtons"].IconSize)
			Button:SetScript("OnDragStart", nil)
			Button:SetScript("OnDragStop", nil)

			Module:LockButton(Button)

			if Maxed then
				ActualButtons = ButtonsPerRow
			end
		end
	end

	local BarWidth = (Spacing + ((Size * (ActualButtons * Mult)) + ((Spacing * (ActualButtons - 1)) * Mult) + (Spacing * Mult)))
	local BarHeight = (Spacing + ((Size * (AnchorY * Mult)) + ((Spacing * (AnchorY - 1)) * Mult) + (Spacing * Mult)))
	self.Bar:SetSize(BarWidth, BarHeight)

	if ActualButtons == 0 then
		self.Bar:Hide()
	else
		self.Bar:Show()
	end

	if C["MinimapButtons"].BarMouseOver then
		K.UIFrameFadeOut(self.Bar, 0.2, self.Bar:GetAlpha(), 0.25)
	else
		K.UIFrameFadeIn(self.Bar, 0.2, self.Bar:GetAlpha(), 1)
	end
end

function Module:OnEnable()
	Module.Bar = CreateFrame("Frame", "MinimapButtonBar", UIParent)
	Module.Bar:Hide()
	Module.Bar:SetPoint("RIGHT", UIParent, "RIGHT", -94, 226)
	Module.Bar:SetFrameStrata("LOW")
	Module.Bar:SetClampedToScreen(true)
	Module.Bar:SetMovable(true)
	Module.Bar:EnableMouse(true)
	Module.Bar:SetSize(C["MinimapButtons"].IconSize, C["MinimapButtons"].IconSize)

	Module.Bar:CreateBorder()

	Module.Bar:SetScript("OnEnter", function(self)
		K.UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
	end)

	Module.Bar:SetScript("OnLeave", function(self)
		if C["MinimapButtons"].BarMouseOver then
			K.UIFrameFadeOut(self, 0.2, self:GetAlpha(), 0.25)
		end
	end)

	K.Mover(Module.Bar, "MBB", "MinimapButtonBar", {"RIGHT", UIParent, "RIGHT", -94, 226}, C["MinimapButtons"].IconSize + 4, C["MinimapButtons"].IconSize + 4)

	Minimap:SetMaskTexture("Interface\\ChatFrame\\ChatFrameBackground")

	Module:ScheduleRepeatingTimer("GrabMinimapButtons", 6)
end