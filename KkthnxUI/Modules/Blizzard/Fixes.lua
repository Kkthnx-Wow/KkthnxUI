local K, C, L = unpack(select(2, ...))

-- Lua Wow
local _G = _G

-- Wow API
local FCF_StartAlertFlash = FCF_StartAlertFlash
local HideUIPanel = HideUIPanel
local InCombatLockdown = InCombatLockdown
local IsAddOnLoaded = IsAddOnLoaded
local ShowUIPanel = ShowUIPanel

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: LFRBrowseFrame, ScriptErrorsFrame, C_ArtifactUI, ArtifactFrame, addon, ToggleFrame
-- GLOBALS: SpellBookFrame, build, PetJournal_LoadUI, UIParent, WorldMapFrame, event
-- GLOBALS: WorldMapLevelButton, WorldMapFrame_OnHide, WorldMapLevelButton_OnClick, WorldMapFrame

-- </ Fix spellbook taint in combat > --
local SpellBookTaint = CreateFrame("Frame")
SpellBookTaint:RegisterEvent("ADDON_LOADED")
SpellBookTaint:SetScript("OnEvent", function(self, event, addon)
	if addon ~= "KkthnxUI" then return end
	ShowUIPanel(SpellBookFrame)
	HideUIPanel(SpellBookFrame)

	if event == "ADDON_LOADED" then
		self:UnregisterEvent("ADDON_LOADED")
	end
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

-- </ Misclicks for some popups
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