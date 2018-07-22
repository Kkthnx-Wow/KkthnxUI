local K, C = unpack(select(2, ...))
if C["Minimap"].Enable ~= true then
	return
end

local _G = _G
local table_insert = table.insert

local ACHIEVEMENT_BUTTON = _G.ACHIEVEMENT_BUTTON
local ACHIEVEMENTS_GUILD_TAB = _G.ACHIEVEMENTS_GUILD_TAB
local BLIZZARD_STORE = _G.BLIZZARD_STORE
local CHARACTER_BUTTON = _G.CHARACTER_BUTTON
local COLLECTIONS = _G.COLLECTIONS
local CreateFrame = _G.CreateFrame
local GARRISON_TYPE_8_0_LANDING_PAGE_TITLE = _G.GARRISON_TYPE_8_0_LANDING_PAGE_TITLE
local HELP_BUTTON = _G.HELP_BUTTON
local HideUIPanel = _G.HideUIPanel
local IsShiftKeyDown = _G.IsShiftKeyDown
local MAINMENU_BUTTON = _G.MAINMENU_BUTTON
local ShowUIPanel = _G.ShowUIPanel
local SOCIAL_BUTTON = _G.SOCIAL_BUTTON
local SPELLBOOK_ABILITIES_BUTTON = _G.SPELLBOOK_ABILITIES_BUTTON
local UIParent = _G.UIParent

local UIMiniMapTrackingMenu = CreateFrame("Frame", "UIMiniMapTrackingMenu", UIParent, "UIDropDownMenuTemplate")
UIMiniMapTrackingMenu:SetID(1)
UIMiniMapTrackingMenu:SetClampedToScreen(true)
UIMiniMapTrackingMenu:Hide()
UIDropDownMenu_Initialize(UIMiniMapTrackingMenu, MiniMapTrackingDropDown_Initialize, "MENU")
UIMiniMapTrackingMenu.noResize = true

local menuFrame = CreateFrame("Frame", "MinimapRightClickMenu", UIParent)
local menuList = {
	{text = CHARACTER_BUTTON,
	func = function() ToggleCharacter("PaperDollFrame") end},
	{text = SPELLBOOK_ABILITIES_BUTTON,
	func = function() if not SpellBookFrame:IsShown() then ShowUIPanel(SpellBookFrame) else HideUIPanel(SpellBookFrame) end end},
	{text = TALENTS_BUTTON,
		func = function()
			if not PlayerTalentFrame then
				TalentFrame_LoadUI()
			end

			if not PlayerTalentFrame:IsShown() then
				ShowUIPanel(PlayerTalentFrame)
			else
				HideUIPanel(PlayerTalentFrame)
			end
	end},
	{text = COLLECTIONS,
		func = function()
			ToggleCollectionsJournal()
	end},
	{text = TIMEMANAGER_TITLE,
	func = function() ToggleFrame(TimeManagerFrame) end},
	{text = ACHIEVEMENT_BUTTON,
	func = ToggleAchievementFrame},
	{text = SOCIAL_BUTTON,
	func = ToggleFriendsFrame},
	{text = "Calendar",
	func = function() GameTimeFrame:Click() end},
	{text = GARRISON_TYPE_8_0_LANDING_PAGE_TITLE,
	func = function() GarrisonLandingPageMinimapButton_OnClick() end},
	{text = ACHIEVEMENTS_GUILD_TAB,
	func = ToggleGuildFrame},
	{text = LFG_TITLE,
	func = ToggleLFDParentFrame},
	{text = ENCOUNTER_JOURNAL,
	func = function() if not IsAddOnLoaded('Blizzard_EncounterJournal') then EncounterJournal_LoadUI(); end ToggleFrame(EncounterJournal) end},
	{text = MAINMENU_BUTTON,
		func = function()
			if (not GameMenuFrame:IsShown()) then
				if (VideoOptionsFrame:IsShown()) then
					VideoOptionsFrameCancel:Click()
				elseif (AudioOptionsFrame:IsShown()) then
					AudioOptionsFrameCancel:Click()
				elseif (InterfaceOptionsFrame:IsShown()) then
					InterfaceOptionsFrameCancel:Click()
				end
				CloseMenus()
				CloseAllWindows()
				PlaySound(850) --IG_MAINMENU_OPEN
				ShowUIPanel(GameMenuFrame)
			else
				PlaySound(854) --IG_MAINMENU_QUIT
				HideUIPanel(GameMenuFrame)
				MainMenuMicroButton_SetNormal()
			end
	end}
}

table_insert(menuList, {text = BLIZZARD_STORE, func = function() StoreMicroButton:Click() end})
table_insert(menuList, 	{text = HELP_BUTTON, func = ToggleHelpFrame})

Minimap:SetScript("OnMouseUp", function(self, button)
	local position = self:GetPoint()

	if (button == "MiddleButton") or (button == "RightButton" and IsShiftKeyDown()) then
		if (position:match("LEFT")) then
			EasyMenu(menuList, menuFrame, "cursor")
		else
			EasyMenu(menuList, menuFrame, "cursor", -160, 0)
		end
	elseif (button == "RightButton") then
		ToggleDropDownMenu(1, nil, UIMiniMapTrackingMenu, "cursor")
	else
		Minimap_OnClick(self)
	end
end)