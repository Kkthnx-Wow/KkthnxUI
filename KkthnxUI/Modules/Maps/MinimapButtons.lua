local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("MinimapButtons", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")

-- Sourced: ProjectAzilroka (Azilroka)

local _G = _G

_G.MinimapButtons = Module

local InCombatLockdown, C_PetBattles = _G.InCombatLockdown, _G.C_PetBattles
local Minimap = Minimap
local strsub, strlen, strfind, ceil = strsub, strlen, strfind, ceil
local tinsert, pairs, unpack, select = tinsert, pairs, unpack, select

Module.Buttons = {}

local ignoreButtons = {
	"GameTimeFrame",
	"HelpOpenWebTicketButton",
	"MiniMapVoiceChatFrame",
	"TimeManagerClockButton",
	"BattlefieldMinimap",
	"ButtonCollectFrame",
	"GameTimeFrame",
	"QueueStatusMinimapButton",
	"GarrisonLandingPageMinimapButton",
	"MiniMapMailFrame",
	"MiniMapTracking",
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
}

local PartialIgnores = {
	"Node",
	"Note",
	"Pin",
	"POI"
}

local AcceptedFrames = {
	"BagSync_MinimapButton",
	"VendomaticButtonFrame",
}

local AddButtonsToBar = {
	"SmartBuff_MiniMapButton",
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
	if (not Button) then return end
	if Button.isSkinned then return end

	local Name = Button:GetName()
	if not Name then return end

	if Button:IsObjectType("Button") then
		for i = 1, #ignoreButtons do
			if Name == ignoreButtons[i] then return end
		end

		for i = 1, #GenericIgnores do
			if strsub(Name, 1, strlen(GenericIgnores[i])) == GenericIgnores[i] then return end
		end

		for i = 1, #PartialIgnores do
			if strfind(Name, PartialIgnores[i]) ~= nil then return end
		end
	end

	for i = 1, Button:GetNumRegions() do
		local Region = select(i, Button:GetRegions())
		if Region:GetObjectType() == "Texture" then
			local Texture = Region:GetTexture()

			if Texture and (strfind(Texture, "Border") or strfind(Texture, "Background") or strfind(Texture, "AlphaMask") or strfind(Texture, "Highlight")) then
				Region:SetAlpha(0)
			else
				if Name == "BagSync_MinimapButton" then
					Region:SetTexture("Interface\\AddOns\\BagSync\\media\\icon")
				elseif Name == "DBMMinimapButton" then
					Region:SetTexture("Interface\\Icons\\INV_Helmet_87")
				elseif Name == "OutfitterMinimapButton" then
					if Region:GetTexture() == "Interface\\Addons\\Outfitter\\Textures\\MinimapButton" then
						Region:SetTexture(nil)
					end
				elseif Name == "SmartBuff_MiniMapButton" then
					Region:SetTexture("Interface\\Icons\\Spell_Nature_Purge")
				elseif Name == "VendomaticButtonFrame" then
					Region:SetTexture("Interface\\Icons\\INV_Misc_Rabbit_2")
				end
				Region:ClearAllPoints()
				Region:SetAllPoints()
				Region:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
				Button:HookScript("OnLeave", function() Region:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4]) end)
				Region:SetDrawLayer("ARTWORK")
				Region.SetPoint = function() return end
			end
		end
	end

	Button:SetFrameLevel(Minimap:GetFrameLevel() + 5)
	Button:SetSize(C["MinimapButtons"].IconSize, C["MinimapButtons"].IconSize)
	Button:SetTemplate("Transparent", true)
	Button:HookScript("OnEnter", function(self)
		self:SetBackdropBorderColor(K.Color.r, K.Color.g, K.Color.b)
		if Module.Bar:IsShown() then
			UIFrameFadeIn(Module.Bar, 0.2, Module.Bar:GetAlpha(), 1)
		end
	end)
	Button:HookScript("OnLeave", function(self)
		self:SetTemplate("Transparent", true)
		if Module.Bar:IsShown() and C["MinimapButtons"].BarMouseOver then
			UIFrameFadeOut(Module.Bar, 0.2, Module.Bar:GetAlpha(), 0)
		end
	end)

	Button.isSkinned = true
	tinsert(self.Buttons, Button)
end

function Module:GrabMinimapButtons()
	if (InCombatLockdown() or C_PetBattles.IsInBattle()) then return end

	for _, Frame in pairs({Minimap, MinimapBackdrop}) do
		for i = 1, Frame:GetNumChildren() do
			local object = select(i, Frame:GetChildren())
			if object then
				if object:IsObjectType("Button") and object:GetName() then
					self:SkinMinimapButton(object)
				end
			end
		end
	end

	self:Update()
end

function Module:Update()
	if not C["MinimapButtons"].EnableBar then return end

	local AnchorX, AnchorY, MaxX = 0, 1, C["MinimapButtons"].ButtonsPerRow
	local ButtonsPerRow = C["MinimapButtons"].ButtonsPerRow
	local NumColumns = ceil(#Module.Buttons / ButtonsPerRow)
	local Spacing, Mult = C["MinimapButtons"].ButtonSpacing, 1
	local Size = C["MinimapButtons"].IconSize
	local ActualButtons, Maxed = 0

	if NumColumns == 1 and ButtonsPerRow > #Module.Buttons then
		ButtonsPerRow = #Module.Buttons
	end

	for _, Button in pairs(Module.Buttons) do
		if Button:IsVisible() then
			AnchorX = AnchorX + 1
			ActualButtons = ActualButtons + 1
			if AnchorX > MaxX then
				AnchorY = AnchorY + 1
				AnchorX = 1
				Maxed = true
			end

			Module:UnlockButton(Button)

			Button:SetTemplate("Transparent", true)
			Button:SetParent(self.Bar)
			Button:ClearAllPoints()
			Button:SetPoint("TOPLEFT", self.Bar, "TOPLEFT", (Spacing + ((Size + Spacing) * (AnchorX - 1))), (- Spacing - ((Size + Spacing) * (AnchorY - 1))))
			Button:SetSize(C["MinimapButtons"].IconSize, C["MinimapButtons"].IconSize)
			Button:SetScale(1)
			Button:SetFrameStrata("LOW")
			Button:SetFrameLevel(self.Bar:GetFrameLevel() + 1)
			Button:SetScript("OnDragStart", nil)
			Button:SetScript("OnDragStop", nil)

			Module:LockButton(Button)

			if Maxed then ActualButtons = ButtonsPerRow end
		end
	end

	local BarWidth = (Spacing + ((Size * (ActualButtons * Mult)) + ((Spacing * (ActualButtons - 1)) * Mult) + (Spacing * Mult)))
	local BarHeight = (Spacing + ((Size * (AnchorY * Mult)) + ((Spacing * (AnchorY - 1)) * Mult) + (Spacing * Mult)))
	self.Bar:SetSize(BarWidth, BarHeight)

	self.Bar:Show()

	if C["MinimapButtons"].BarMouseOver then
		UIFrameFadeOut(self.Bar, 0.2, self.Bar:GetAlpha(), 0)
	else
		UIFrameFadeIn(self.Bar, 0.2, self.Bar:GetAlpha(), 1)
	end
end

function Module:OnInitialize()
	self.Bar = CreateFrame("Frame", "MinimapButtonBar", UIParent)
	self.Bar:Hide()
	self.Bar:SetPoint("RIGHT", UIParent, "RIGHT", -126, 184)
	self.Bar:SetFrameStrata("LOW")
	self.Bar:SetClampedToScreen(true)
	self.Bar:SetMovable(true)
	self.Bar:EnableMouse(true)
	self.Bar:SetSize(C["MinimapButtons"].IconSize, C["MinimapButtons"].IconSize)
	self.Bar:SetTemplate("Transparent", true)

	self.Bar:SetScript("OnEnter", function(self)
		UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
	end)
	self.Bar:SetScript("OnLeave", function(self)
		if C["MinimapButtons"].BarMouseOver then
			UIFrameFadeOut(self, 0.2, self:GetAlpha(), 0)
		end
	end)

	K["Movers"]:RegisterFrame(self.Bar)

	self:ScheduleRepeatingTimer("GrabMinimapButtons", 5)
end