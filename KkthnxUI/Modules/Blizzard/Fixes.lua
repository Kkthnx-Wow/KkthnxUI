local K, C, L = unpack(select(2, ...))

-- Lua Wow
local _G = _G

-- Wow API
local FCF_StartAlertFlash = _G.FCF_StartAlertFlash
local HideUIPanel = _G.HideUIPanel
local InCombatLockdown = _G.InCombatLockdown
local IsAddOnLoaded = _G.IsAddOnLoaded
local ShowUIPanel = _G.ShowUIPanel

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: LFRBrowseFrame, ScriptErrorsFrame, C_ArtifactUI, ArtifactFrame, addon, ToggleFrame
-- GLOBALS: SpellBookFrame, build, PetJournal_LoadUI, UIParent, WorldMapFrame, event
-- GLOBALS: WorldMapLevelButton, WorldMapFrame_OnHide, WorldMapLevelButton_OnClick, WorldMapFrame

-- Retrive the current game client version
local BUILD = tonumber((select(2, GetBuildInfo())))

-- Shortcuts to identify client versions
local LEGION_23478 	= BUILD >= 23478 -- 7.2.0.23478 (PTR)
local LEGION_23436 	= BUILD >= 23436 -- 7.2.0.23436 (PTR)
local LEGION_720 	= BUILD >= 23436 -- 7.2.0 (PTR)
local LEGION_710 	= BUILD >= 22900 -- 7.1.0 "Return to Karazhan"
local LEGION 	= BUILD >= 22410 -- 7.0.3 "Legion"

-- </ Fix spellbook taint in combat > --
local SpellBookTaint = CreateFrame("Frame")
SpellBookTaint:RegisterEvent("ADDON_LOADED")
SpellBookTaint:SetScript("OnEvent", function(self, event, addon)
	if addon ~= "KkthnxUI" then
		return
	end

	ToggleFrame(SpellBookFrame)

	self:UnregisterEvent("ADDON_LOADED")
end)

-- </ Fix RemoveTalent() taint > --
FCF_StartAlertFlash = K.Noop

-- </ Fix SearchLFGLeave() taint > --
local LFRBrowseTaint = CreateFrame("Frame")
LFRBrowseTaint:SetScript("OnUpdate", function(self, elapsed)
	if LFRBrowseFrame.timeToClear then
		LFRBrowseFrame.timeToClear = nil
	end
end)

-- </ Misclicks for some popups > --
StaticPopupDialogs.RESURRECT.hideOnEscape = nil
StaticPopupDialogs.AREA_SPIRIT_HEAL.hideOnEscape = nil
StaticPopupDialogs.PARTY_INVITE.hideOnEscape = nil
StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = nil
StaticPopupDialogs.ADDON_ACTION_FORBIDDEN.button1 = nil
StaticPopupDialogs.TOO_MANY_LUA_ERRORS.button1 = nil
PetBattleQueueReadyFrame.hideOnEscape = nil
if PVPReadyDialog then
	PVPReadyDialog.leaveButton:Hide()
	PVPReadyDialog.enterButton:ClearAllPoints()
	PVPReadyDialog.enterButton:SetPoint("BOTTOM", PVPReadyDialog, "BOTTOM", 0, 25)
	PVPReadyDialog.label:SetPoint("TOP", 0, -22)
end

ReadyCheckFrame:HookScript("OnShow", function(self)
	-- </ bug fix, don't show it if player is initiator > --
	if self.initiator and UnitIsUnit("player", self.initiator) then
		self:Hide()
	end
end)

-- </ Prevent Blizzard world map taint errors > --
-- function WorldMapFrame.UIElementsFrame.ActionButton.GetDisplayLocation(self, useAlternateLocation)
-- 	if InCombatLockdown() then return end
-- 	return WorldMapActionButtonMixin.GetDisplayLocation(self, useAlternateLocation)
-- end
--
-- function WorldMapFrame.UIElementsFrame.ActionButton.Refresh(self)
-- 	if InCombatLockdown() then return end
-- 	WorldMapActionButtonMixin.Refresh(self)
-- end

-- WorldMapFrame Dropdown bug
if LEGION and (not LEGION_23436) then

	-- Legion legendaries are unique-equipped up to two at the same time,
	-- but the UseEquipmentSet API is stupid, it will fail should you try
	-- to swap to a different legendary without unequipping a previous
	-- one first (fails with the "Too many legendaries equipped" error).

	-- This fix was supplied by p3lim@WowInterface.
	-- http://www.wowinterface.com/forums/showthread.php?t=54889

	-- WoW API
	local EquipmentManager_EquipItemByLocation = _G.EquipmentManager_EquipItemByLocation
	local EquipmentManager_RunAction = _G.EquipmentManager_RunAction
	local EquipmentSetContainsLockedItems = _G.EquipmentSetContainsLockedItems
	local GetEquipmentSetLocations = _G.GetEquipmentSetLocations
	local GetInventoryItemLink = _G.GetInventoryItemLink
	local GetInventoryItemQuality = _G.GetInventoryItemQuality
	local UnitCastingInfo = _G.UnitCastingInfo
	local UIErrorsFrame = _G.UIErrorsFrame

	local equipSet = function(name)
		if EquipmentSetContainsLockedItems(name) or UnitCastingInfo("player") then
			UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1, 0.1, 0.1, 1)
			return
		end

		-- BUG: legion legendaries will halt the set equipping if the user is swapping
		-- different slotted legendaries beyond the 1/2 equipped limit
		local locations = GetEquipmentSetLocations(name)
		for inventoryID = 1, 17 do
			local itemLink = GetInventoryItemLink("player", inventoryID)
			if(itemLink) then
				local rarity = GetInventoryItemQuality("player", inventoryID)
				if(rarity == 5) then
					-- legendary item found, manually replace it with the item from the new set
					local action = EquipmentManager_EquipItemByLocation(locations[inventoryID], inventoryID)
					if action then
						EquipmentManager_RunAction(action)
						locations[inventoryID] = nil
					end
				end
			end
		end

		-- Equip remaining items through _RunAction to avoid blocking from UseEquipmentSet
		for inventoryID, location in next, locations do
			local action = EquipmentManager_EquipItemByLocation(location, inventoryID)
			if action then
				EquipmentManager_RunAction(action)
			end
		end
	end

	_G.EquipmentManager_EquipSet = equipSet
end

-- WorldMapFrame Zoom bugs & various taints
if LEGION then
	-- The first problem is that WorldMapScrollFrame_ResetZoom doesn't work properly in combat.
	-- The second problem is that changing it taints the WorldMap and probably the POI system and Objectives Tracker too.
	-- The "solution" is to remove events and script handlers that call it while engaged in combat.

	-- WoW frames & functions
	local WorldMapFrame = WorldMapFrame
	local WorldMapFrame_OnHide = WorldMapFrame_OnHide
	local WorldMapLevelButton_OnClick = WorldMapLevelButton_OnClick

	local frame = CreateFrame("Frame", nil, UIParent)
	frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	frame:RegisterEvent("PLAYER_REGEN_DISABLED")
	frame:SetScript("OnEvent", function(self)
		if event == "PLAYER_REGEN_DISABLED" then
			WorldMapFrame:UnregisterEvent("WORLD_MAP_UPDATE")
			WorldMapFrame:SetScript("OnHide", nil)
			WorldMapLevelButton:SetScript("OnClick", nil)
		elseif event == "PLAYER_REGEN_ENABLED" then
			WorldMapFrame:RegisterEvent("WORLD_MAP_UPDATE")
			WorldMapFrame:SetScript("OnHide", WorldMapFrame_OnHide)
			WorldMapLevelButton:SetScript("OnClick", WorldMapLevelButton_OnClick)
		end
	end)
end

-- Equipment Manager Legendary swap bug
if LEGION_710 and (not LEGION_23478) then
	-- In 7.1 if you open the world map and open any dropdown in the UI
	-- (from the world map frame or any other frame) the dropdown will suddenly close itself.
	-- This little fix was supplied by Ellypse@WowInterface.
	-- http://www.wowinterface.com/forums/showthread.php?t=54979

	local DropDownList1 = _G.DropDownList1
	local oldUpdate = _G.WorldMapLevelDropDown_Update
	local newUpdate = function()
		if not DropDownList1:IsVisible() then
			oldUpdate()
		end
	end

	_G.WorldMapLevelDropDown_Update = newUpdate
end

-- Pointless Taint Reports at the 7.2 PTR
if LEGION_720 then

	-- Currently at the PTR we're getting taint reports when logging in,
	-- with pretty much any random addon enabled.
	--0
	-- I have yet to find the source, and nothing appears to be blocked
	-- in combat or prohibited in any way. I'm leaning to this being a Blizz bug.
	--
	-- Might be some value made global by accident, or something else they'll fix.
	-- Might also be something intentional but yet undocumented.
	--
	-- For now I'll simply go with the dirty hack of hiding this message,
	-- and instead revisit this issue every future PTR build until I can solve it.
	_G.INTERFACE_ACTION_BLOCKED = ""
end

-- </ blizzard's baghandling just doesn't cut it > --
-- </ we wish for all backpack/bag hotkeys and buttons to toggle all bags, always > --
local function OpenAllBags()
	if not UIParent:IsShown() or IsOptionFrameOpen() then
		return
	end
	if not BankFrame:IsShown() then
		if IsBagOpen(0) then
			CloseAllBags()
		else
			for i = 0, NUM_BAG_FRAMES, 1 do
				OpenBag(i)
			end
		end
	else
		local bagsOpen = 0
		local totalBags = 0

		-- check for open bank bags
		for i = NUM_BAG_FRAMES + 1, NUM_CONTAINER_FRAMES, 1 do
			if GetContainerNumSlots(i) > 0 then
				totalBags = totalBags + 1
			end
			if IsBagOpen(i) then
				CloseBag(i)
				bagsOpen = bagsOpen + 1
			end
		end
		if bagsOpen < totalBags or totalBags == 0 then
			for i = 0, NUM_CONTAINER_FRAMES, 1 do
				OpenBag(i)
			end
		else
			CloseAllBags()
		end
	end
end

-- </ replace blizzard's bag opening functions > --
local otherBagsLoaded
for _,bags in ipairs({"ArkInventory", "Bagnon", "OneBag3", "BagForce", "Tbag", "Tbag-Shefki"}) do
	if K.CheckAddOn(bags) then
		otherBagsLoaded = true
		break
	end
end
if not otherBagsLoaded then
	_G.OpenBackpack = OpenAllBags
	_G.OpenAllBags = OpenAllBags
	_G.ToggleBackpack = OpenAllBags
	_G.ToggleBag = OpenAllBags
else
	OpenAllBags = nil
end