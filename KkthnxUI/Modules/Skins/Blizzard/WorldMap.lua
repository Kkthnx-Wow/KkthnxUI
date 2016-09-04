local K, C, L, _ = select(2, ...):unpack()
if (select(4, GetAddOnInfo("WorldQuestTracker"))) or (select(4, GetAddOnInfo("WorldQuestsList"))) then return end

--local WorldMap = K:NewModule('WorldMap', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0')
local WorldMap = LibStub("AceAddon-3.0"):NewAddon("WorldMap", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")

K.WorldMap = WorldMap

local smallerWorldMap = true

--Cache global variables
--Lua functions
local find = string.find
--WoW API / Variables
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local SetUIPanelAttribute = SetUIPanelAttribute
local IsInInstance = IsInInstance
local GetPlayerMapPosition = GetPlayerMapPosition
local GetCursorPosition = GetCursorPosition
local PLAYER = PLAYER
local MOUSE_LABEL = MOUSE_LABEL
local WORLDMAP_FULLMAP_SIZE = WORLDMAP_FULLMAP_SIZE
local WORLDMAP_WINDOWED_SIZE = WORLDMAP_WINDOWED_SIZE

function WorldMap:SetLargeWorldMap()
	if InCombatLockdown() then return end

	WorldMapFrame:SetParent(K.UIParent)
	WorldMapFrame:EnableKeyboard(false)
	WorldMapFrame:SetScale(1)
	WorldMapFrame:EnableMouse(true)

	if WorldMapFrame:GetAttribute("UIPanelLayout-area") ~= "center" then
		SetUIPanelAttribute(WorldMapFrame, "area", "center");
	end

	if WorldMapFrame:GetAttribute("UIPanelLayout-allowOtherPanels") ~= true then
		SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true)
	end

	WorldMapFrameSizeUpButton:Hide()
	WorldMapFrameSizeDownButton:Show()

	WorldMapFrame:ClearAllPoints()
	WorldMapFrame:SetPoint(unpack(C.Position.WorldMap))
	WorldMapFrame:SetSize(1002, 668)
end

function WorldMap:SetSmallWorldMap()
	if InCombatLockdown() then return; end

	WorldMapFrameSizeUpButton:Show()
	WorldMapFrameSizeDownButton:Hide()
end

function WorldMap:PLAYER_REGEN_ENABLED()
	WorldMapFrameSizeDownButton:Enable()
	WorldMapFrameSizeUpButton:Enable()
end

function WorldMap:PLAYER_REGEN_DISABLED()
	WorldMapFrameSizeDownButton:Disable()
	WorldMapFrameSizeUpButton:Disable()
end

function WorldMap:ResetDropDownListPosition(frame)
	--DropDownList1:ClearAllPoints()
	--DropDownList1:Point("TOPRIGHT", frame, "BOTTOMRIGHT", -17, -4)
end

function WorldMap:Initialize()
	-- setfenv(WorldMapFrame_OnShow, setmetatable({ UpdateMicroButtons = function() end }, { __index = _G })) --blizzard taint fix

	if(smallerWorldMap) then
		BlackoutWorld:SetTexture(nil)
		self:SecureHook("WorldMap_ToggleSizeDown", "SetSmallWorldMap")
		self:SecureHook("WorldMap_ToggleSizeUp", "SetLargeWorldMap")
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		self:RegisterEvent("PLAYER_REGEN_DISABLED")

		if WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE then
			self:SetLargeWorldMap()
		elseif WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE then
			self:SetSmallWorldMap()
		end
	end

	--Set alpha used when moving
	--WORLD_MAP_MIN_ALPHA = C.Map.mapAlphaWhenMoving
	--SetCVar("mapAnimMinAlpha", C.Map.mapAlphaWhenMoving)
	--Enable/Disable map fading when moving
	--SetCVar("mapFade", (C.Map.fadeMapWhenMoving == true and 1 or 0))
end

WorldMap:Initialize()
