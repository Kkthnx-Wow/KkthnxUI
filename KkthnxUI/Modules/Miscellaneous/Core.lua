--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Main hub for miscellaneous features and utilities in KkthnxUI.
-- - Design: Registers sub-modules and handles global miscellaneous settings like camera, delete dialogs, and more.
-- - Events: PLAYER_ENTERING_WORLD, READY_CHECK, etc.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Miscellaneous")

-- PERF: Localize global functions and environment for faster lookups.
local error = _G.error
local ipairs = _G.ipairs
local math_atan2 = _G.math.atan2
local math_cos = _G.math.cos
local math_floor = _G.math.floor
local math_max = _G.math.max
local math_min = _G.math.min
local math_sin = _G.math.sin
local math_sqrt = _G.math.sqrt
local next = _G.next
local pcall = _G.pcall
local string_format = _G.string.format
local string_gsub = _G.string.gsub
local string_match = _G.string.match
local table_insert = _G.table.insert
local table_remove = _G.table.remove
local tonumber = _G.tonumber
local tostring = _G.tostring
local type = _G.type

local _G = _G
local BNToastFrame = _G.BNToastFrame
local C_BattleNet_GetGameAccountInfoByGUID = _G.C_BattleNet.GetGameAccountInfoByGUID
local C_FriendList_AddFriend = _G.C_FriendList.AddFriend
local C_FriendList_IsFriend = _G.C_FriendList.IsFriend
local C_GuildInfo = _G.C_GuildInfo
local C_Item_GetItemInfo = _G.C_Item.GetItemInfo
local C_Item_GetItemQualityColor = _G.C_Item.GetItemQualityColor
local C_Map_GetBestMapForUnit = _G.C_Map.GetBestMapForUnit
local C_Map_GetMapInfo = _G.C_Map.GetMapInfo
local C_Map_SetUserWaypoint = _G.C_Map.SetUserWaypoint
local C_QuestLog_GetSelectedQuest = _G.C_QuestLog.GetSelectedQuest
local C_QuestLog_ShouldShowQuestRewards = _G.C_QuestLog.ShouldShowQuestRewards
local C_StorePublic = _G.C_StorePublic
local C_SuperTrack_SetSuperTrackedUserWaypoint = _G.C_SuperTrack.SetSuperTrackedUserWaypoint
local ChatEdit_ActivateChat = _G.ChatEdit_ActivateChat
local ChatEdit_ChooseBoxForSend = _G.ChatEdit_ChooseBoxForSend
local CreateFrame = _G.CreateFrame
local DurabilityFrame = _G.DurabilityFrame
local GameMenuFrame = _G.GameMenuFrame
local GameTooltip = _G.GameTooltip
local GameTooltip_Hide = _G.GameTooltip_Hide
local GetCursorPosition = _G.GetCursorPosition
local GetGuildInfo = _G.GetGuildInfo
local GetInstanceInfo = _G.GetInstanceInfo
local GetMerchantItemLink = _G.GetMerchantItemLink
local GetMerchantItemMaxStack = _G.GetMerchantItemMaxStack
local GetQuestLogRewardXP = _G.GetQuestLogRewardXP
local GetRewardXP = _G.GetRewardXP
local HideUIPanel = _G.HideUIPanel
local InCombatLockdown = _G.InCombatLockdown
local IsAltKeyDown = _G.IsAltKeyDown
local IsGuildMember = _G.IsGuildMember
local Minimap = _G.Minimap
local MinimapCluster = _G.MinimapCluster
local PlaySound = _G.PlaySound
local QuestInfoXPFrame = _G.QuestInfoXPFrame
local SettingsPanel = _G.SettingsPanel
local StaticPopupDialogs = _G.StaticPopupDialogs
local StaticPopup_Show = _G.StaticPopup_Show
local TicketStatusFrame = _G.TicketStatusFrame
local UIErrorsFrame = _G.UIErrorsFrame
local UIParent = _G.UIParent
local UiMapPoint_CreateFromCoordinates = _G.UiMapPoint.CreateFromCoordinates
local UnitGUID = _G.UnitGUID
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax
local VehicleSeatIndicator = _G.VehicleSeatIndicator
local hooksecurefunc = _G.hooksecurefunc

local FRIEND = _G.FRIEND
local GUILD = _G.GUILD
local NO = _G.NO
local YES = _G.YES
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT
local SOUNDKIT = _G.SOUNDKIT
local COPY_NAME = _G.COPY_NAME
local WHISPER = _G.WHISPER
local ADD_CHARACTER_FRIEND = _G.ADD_CHARACTER_FRIEND
local HEADER_COLON = _G.HEADER_COLON

-- Miscellaneous Module Registry
local KKUI_MISC_MODULE = {}

-- Register Miscellaneous Modules
function Module:RegisterMisc(name, func)
	if not KKUI_MISC_MODULE[name] then
		KKUI_MISC_MODULE[name] = func
	end
end

-- Enable Auto Chat Bubbles
local function enableAutoBubbles()
	if C["Misc"].AutoBubbles then
		local function updateBubble()
			local _, instType = GetInstanceInfo()
			_G.SetCVar("chatBubbles", instType == "raid" and 1 or 0)
		end
		K:RegisterEvent("PLAYER_ENTERING_WORLD", updateBubble)
	end
end

-- REASON: Provides audio feedback for ready checks even if the master channel is otherwise muted.
K:RegisterEvent("READY_CHECK", function()
	PlaySound(SOUNDKIT.READY_CHECK, "Master")
end)

-- Modify Delete Dialog
local function modifyDeleteDialog()
	local deleteItem = K.CopyTable(StaticPopupDialogs.DELETE_ITEM)
	deleteItem.timeout = 5 -- also add a timeout
	StaticPopupDialogs.DELETE_GOOD_ITEM = deleteItem

	local deleteQuestItem = K.CopyTable(StaticPopupDialogs.DELETE_QUEST_ITEM)
	deleteQuestItem.timeout = 5 -- also add a timeout
	StaticPopupDialogs.DELETE_GOOD_QUEST_ITEM = deleteQuestItem
end

-- Enable Module and Initialize Miscellaneous Modules
function Module:OnEnable()
	for name, func in next, KKUI_MISC_MODULE do
		if name and type(func) == "function" then
			func()
		end
	end

	local loadMiscModules = {
		"CreateAlreadyKnown",
		"CreateBossBanner",
		"CreateBossEmote",
		"CreateCustomWaypoint",
		"CreateDurabilityFrameMove",
		"CreateErrorFrameToggle",
		"CreateGUIGameMenuButton",
		"CreateMinimapButtonToggle",
		"CreateMoveBlizzardFrames",
		"CreateQuickMenuList",
		"CreateTicketStatusFrameMove",
		"CreateTradeTargetInfo",
		"CreateVehicleSeatMover",
		"UpdateMaxCameraZoom",
		"UpdateYClassColors",
	}

	for _, funcName in ipairs(loadMiscModules) do
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			if not success then
				error("Error in " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end

	hooksecurefunc("QuestInfo_Display", Module.CreateQuestXPPercent)

	if not BNToastFrame.mover then
		BNToastFrame.mover = K.Mover(BNToastFrame, "BNToastFrame", "BNToastFrame", { "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 4, 270 }, BNToastFrame:GetSize())
	else
		BNToastFrame.mover:SetSize(BNToastFrame:GetSize())
	end
	hooksecurefunc(BNToastFrame, "SetPoint", Module.PostBNToastMove)

	enableAutoBubbles()
	modifyDeleteDialog()

	if self.UpdateGuildInviteString then
		self:UpdateGuildInviteString()
	end
end

-- BNToast Frame Mover Setup
function Module:PostBNToastMove(_, anchor)
	if anchor ~= BNToastFrame.mover then
		BNToastFrame:ClearAllPoints()
		local anchorPoint = BNToastFrame.mover.anchorPoint or "TOPLEFT"
		BNToastFrame:SetPoint(anchorPoint, BNToastFrame.mover, anchorPoint)
	end
end

-- REASON: Calculates the position for the minimap button on a circular path around the minimap.
local function updateDragCursor(self)
	local centerX, centerY = Minimap:GetCenter()
	local cursorX, cursorY = GetCursorPosition()
	local scale = Minimap:GetEffectiveScale()
	cursorX, cursorY = cursorX / scale, cursorY / scale

	local angle = math_atan2(cursorY - centerY, cursorX - centerX)
	local x, y = math_cos(angle), math_sin(angle)

	local width = (Minimap:GetWidth() / 2) + 5
	local height = (Minimap:GetHeight() / 2) + 5
	local diagRadiusW = math_sqrt(2 * width ^ 2) - 10
	local diagRadiusH = math_sqrt(2 * height ^ 2) - 10
	x = math_max(-width, math_min(x * diagRadiusW, width))
	y = math_max(-height, math_min(y * diagRadiusH, height))

	self:ClearAllPoints()
	self:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

-- Click Minimap Button Functionality
local function minimapButtonOnClick(_, btn)
	if btn == "LeftButton" then
		if SettingsPanel:IsShown() or _G.ChatConfigFrame:IsShown() then
			return
		end
		if InCombatLockdown() then
			UIErrorsFrame:AddMessage(K.InfoColor .. ERR_NOT_IN_COMBAT)
			return
		end
		K.NewGUI:Toggle()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION, "SFX")
	end
end

-- Create Minimap Button
function Module:CreateMinimapButtonToggle()
	local minimapButton = CreateFrame("Button", "KKUI_MinimapButton", Minimap)
	minimapButton:SetPoint("BOTTOMLEFT", -15, 20)
	minimapButton:SetSize(32, 32)
	minimapButton:SetMovable(true)
	minimapButton:SetUserPlaced(true)
	minimapButton:RegisterForDrag("LeftButton")
	minimapButton:SetHighlightTexture(C["Media"].Textures.LogoSmallTexture)
	minimapButton:GetHighlightTexture():SetSize(18, 9)
	minimapButton:GetHighlightTexture():ClearAllPoints()
	minimapButton:GetHighlightTexture():SetPoint("CENTER")

	local overlay = minimapButton:CreateTexture(nil, "OVERLAY")
	overlay:SetSize(53, 53)
	overlay:SetTexture(136430) -- REASON: Blizzard's standard minimap button overlay border.
	overlay:SetPoint("TOPLEFT")

	local background = minimapButton:CreateTexture(nil, "BACKGROUND")
	background:SetSize(20, 20)
	background:SetTexture(136467) -- REASON: Blizzard's standard minimap button background.
	background:SetPoint("TOPLEFT", 7, -5)

	local icon = minimapButton:CreateTexture(nil, "ARTWORK")
	icon:SetSize(22, 11)
	icon:SetPoint("CENTER")
	icon:SetTexture(C["Media"].Textures.LogoSmallTexture)

	minimapButton:SetScript("OnEnter", function()
		GameTooltip:SetOwner(minimapButton, "ANCHOR_LEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine("KkthnxUI", 1, 1, 1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("LeftButton: Toggle Config", 0.6, 0.8, 1)
		GameTooltip:Show()
	end)

	minimapButton:SetScript("OnLeave", GameTooltip_Hide)
	minimapButton:RegisterForClicks("AnyUp")
	minimapButton:SetScript("OnClick", minimapButtonOnClick)
	minimapButton:SetScript("OnDragStart", function(self)
		self:SetScript("OnUpdate", updateDragCursor)
	end)
	minimapButton:SetScript("OnDragStop", function(self)
		self:SetScript("OnUpdate", nil)
	end)

	function Module:ToggleMinimapIcon()
		if C["General"].MinimapIcon then
			minimapButton:Show()
		else
			minimapButton:Hide()
		end
	end

	Module:ToggleMinimapIcon()
end

-- REASON: Injected into the Blizzard Game Menu to provide quick access to KkthnxUI configuration.
local gameMenuLastButtons = {
	[_G.GAMEMENU_OPTIONS] = 1,
	[_G.BLIZZARD_STORE] = 2,
}

function Module:PositionGameMenuButton()
	local anchorIndex = (C_StorePublic.IsEnabled and C_StorePublic.IsEnabled() and 2) or 1
	for button in GameMenuFrame.buttonPool:EnumerateActive() do
		local text = button:GetText()
		GameMenuFrame.MenuButtons[text] = button
		local lastIndex = gameMenuLastButtons[text]
		if lastIndex == anchorIndex and GameMenuFrame.KkthnxUI then
			GameMenuFrame.KkthnxUI:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -10)
		elseif not lastIndex then
			local point, anchor, point2, x, y = button:GetPoint()
			button:SetPoint(point, anchor, point2, x, y - 36)
		end
	end
	GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + 36)
	if GameMenuFrame.KkthnxUI then
		GameMenuFrame.KkthnxUI:SetFormattedText(K.Title)
	end
end

function Module:ClickGameMenu()
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(K.InfoColor .. ERR_NOT_IN_COMBAT)
		return
	end
	K.NewGUI:Toggle()
	HideUIPanel(GameMenuFrame)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
end

function Module:CreateGUIGameMenuButton()
	if GameMenuFrame.KkthnxUI then
		return
	end

	local gameMenuButton = CreateFrame("Button", "KKUI_GameMenuButton", GameMenuFrame, "MainMenuFrameButtonTemplate")
	gameMenuButton:SetScript("OnClick", function()
		Module:ClickGameMenu()
	end)

	gameMenuButton:SkinButton()
	GameMenuFrame.KkthnxUI = gameMenuButton
	GameMenuFrame.MenuButtons = {}
	hooksecurefunc(GameMenuFrame, "Layout", function()
		Module:PositionGameMenuButton()
	end)
end

-- Create Quest XP Percent Display
function Module:CreateQuestXPPercent()
	local playerCurrentXP = UnitXP("player")
	local playerMaxXP = UnitXPMax("player")
	if not playerMaxXP or playerMaxXP == 0 then
		return
	end

	local questXP
	local xpText
	local xpFrame

	if _G.QuestInfoFrame.questLog then
		local selectedQuest = C_QuestLog_GetSelectedQuest()
		if C_QuestLog_ShouldShowQuestRewards(selectedQuest) then
			questXP = GetQuestLogRewardXP()
			xpText = _G.MapQuestInfoRewardsFrame.XPFrame.Name:GetText()
			xpFrame = _G.MapQuestInfoRewardsFrame.XPFrame.Name
		end
	else
		questXP = GetRewardXP()
		xpText = QuestInfoXPFrame.ValueText:GetText()
		xpFrame = QuestInfoXPFrame.ValueText
	end

	if questXP and questXP > 0 and xpText then
		local xpPercentageIncrease = (((playerCurrentXP + questXP) / playerMaxXP) - (playerCurrentXP / playerMaxXP)) * 100
		xpFrame:SetFormattedText("%s (|cff4beb2c+%.2f%%|r)", xpText, xpPercentageIncrease)
	end
end

-- REASON: Moves the vehicle seat indicator away from its default position to fit the KkthnxUI layout.
function Module:CreateVehicleSeatMover()
	local seatMover = CreateFrame("Frame", "KKUI_VehicleSeatMover", UIParent)
	seatMover:SetSize(125, 125)
	K.Mover(seatMover, "VehicleSeat", "VehicleSeat", { "BOTTOMRIGHT", UIParent, -400, 30 })

	hooksecurefunc(VehicleSeatIndicator, "SetPoint", function(self, _, parent)
		if parent ~= seatMover then
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", seatMover)
		end
	end)
end

-- REASON: Moves the durability frame to a more sensible location below the minimap.
function Module:CreateDurabilityFrameMove()
	hooksecurefunc(DurabilityFrame, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == MinimapCluster then
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", -40, -50)
		end
	end)
end

-- REASON: Reanchors the GM ticket status frame to avoid overlapping with other UI elements.
function Module:CreateTicketStatusFrameMove()
	hooksecurefunc(TicketStatusFrame, "SetPoint", function(self, relF)
		if relF == "TOPRIGHT" then
			self:ClearAllPoints()
			self:SetPoint("TOP", UIParent, "TOP", -400, -20)
		end
	end)
end

-- REASON: Toggles the boss kill/loot banner based on user configuration.
function Module:CreateBossBanner()
	if C["Misc"].HideBanner and not C["Misc"].KillingBlow then
		_G.BossBanner:UnregisterAllEvents()
	else
		_G.BossBanner:RegisterEvent("BOSS_KILL")
		_G.BossBanner:RegisterEvent("ENCOUNTER_LOOT_RECEIVED")
	end
end

-- REASON: Toggles the raid boss emote frame to reduce screen clutter during encounters.
function Module:CreateBossEmote()
	if C["Misc"].HideBossEmote then
		_G.RaidBossEmoteFrame:UnregisterAllEvents()
	else
		_G.RaidBossEmoteFrame:RegisterEvent("RAID_BOSS_EMOTE")
		_G.RaidBossEmoteFrame:RegisterEvent("RAID_BOSS_WHISPER")
		_G.RaidBossEmoteFrame:RegisterEvent("CLEAR_BOSS_EMOTES")
	end
end

-- REASON: Automatically hides UI error messages during combat to reduce distractions.
local function setupErrorFrameToggle(event)
	if event == "PLAYER_REGEN_DISABLED" then
		_G.UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
		K:RegisterEvent("PLAYER_REGEN_ENABLED", setupErrorFrameToggle)
	else
		_G.UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
		K:UnregisterEvent(event, setupErrorFrameToggle)
	end
end

function Module:CreateErrorFrameToggle()
	if C["General"].NoErrorFrame then
		K:RegisterEvent("PLAYER_REGEN_DISABLED", setupErrorFrameToggle)
	else
		K:UnregisterEvent("PLAYER_REGEN_DISABLED", setupErrorFrameToggle)
	end
end

-- REASON: Enhances the trade frame by showing if the target is a friend, guildy, or stranger.
function Module:CreateTradeTargetInfo()
	local infoText = K.CreateFontString(_G.TradeFrame, 16, "", "")
	infoText:SetPoint("TOP", _G.TradeFrameRecipientNameText, "BOTTOM", 0, -8)

	local function updateColor()
		local r, g, b = K.UnitColor("NPC")
		_G.TradeFrameRecipientNameText:SetTextColor(r or 1, g or 1, b or 1)

		local guid = UnitGUID("NPC")
		if not guid then
			infoText:SetText("|cffff0000" .. L["Stranger"])
			return
		end

		local text = "|cffff0000" .. L["Stranger"]
		if C_BattleNet_GetGameAccountInfoByGUID(guid) or C_FriendList_IsFriend(guid) then
			text = "|cffffff00" .. FRIEND
		elseif IsGuildMember(guid) then
			text = "|cff00ff00" .. GUILD
		end
		infoText:SetText(text)
	end

	updateColor()
	_G.TradeFrame:HookScript("OnShow", updateColor)
end

-- REASON: Adds Alt+RightClick functionality to buy a full stack from a merchant instantly.
do
	local sessionCache = {}
	local pendingItemLink, pendingItemID

	StaticPopupDialogs["BUY_STACK"] = {
		text = L["Stack Buying Check"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			if not pendingItemLink then
				return
			end
			_G.BuyMerchantItem(pendingItemID, GetMerchantItemMaxStack(pendingItemID))
			sessionCache[pendingItemLink] = true
			pendingItemLink = nil
		end,
		hideOnEscape = 1,
		hasItemFrame = 1,
	}

	local originalMerchantItemButton_OnModifiedClick = _G.MerchantItemButton_OnModifiedClick
	_G.MerchantItemButton_OnModifiedClick = function(self, ...)
		if IsAltKeyDown() then
			pendingItemID = self:GetID()
			pendingItemLink = GetMerchantItemLink(pendingItemID)
			if not pendingItemLink then
				return
			end

			local name, _, quality, _, _, _, _, maxStack, _, texture = C_Item_GetItemInfo(pendingItemLink)
			if maxStack and maxStack > 1 then
				if not sessionCache[pendingItemLink] then
					local r, g, b = C_Item_GetItemQualityColor(quality or 1)
					StaticPopup_Show("BUY_STACK", " ", " ", {
						["texture"] = texture,
						["name"] = name,
						["color"] = { r, g, b, 1 },
						["link"] = pendingItemLink,
						["index"] = pendingItemID,
						["count"] = maxStack,
					})
				else
					_G.BuyMerchantItem(pendingItemID, GetMerchantItemMaxStack(pendingItemID))
				end
			end
		end
		originalMerchantItemButton_OnModifiedClick(self, ...)
	end
end

-- REASON: Plays a distinct sound when receiving a resurrection request.
do
	local function soundOnResurrect()
		if C["Unitframe"].ResurrectSound then
			PlaySound("72978", "Master")
		end
	end
	K:RegisterEvent("RESURRECT_REQUEST", soundOnResurrect)
end

-- Buttons to enhance popup menu
-- REASON: Appends a "Add Friend" button to specific unit context menus.
function Module:CustomMenu_AddFriend(rootDescription, data, name)
	rootDescription:CreateButton(K.InfoColor .. ADD_CHARACTER_FRIEND, function()
		local fullName = data.server and data.name .. "-" .. data.server or data.name
		C_FriendList_AddFriend(name or fullName)
	end)
end

-- REASON: Dynamically builds the guild invite string based on the player's current guild.
local guildInviteString
function Module:UpdateGuildInviteString()
	local base = _G.COMMUNITIES_INVITE_MANAGER_LABEL or "Invite to %s"
	local guildName = GetGuildInfo("player")
	if guildName and guildName ~= "" then
		guildInviteString = string_format(base, guildName)
	else
		guildInviteString = string_gsub("Invite To Guild", HEADER_COLON, "")
	end
end

-- REASON: Appends a "Guild Invite" button to specific unit context menus.
function Module:CustomMenu_GuildInvite(rootDescription, data, name)
	rootDescription:CreateButton(K.InfoColor .. guildInviteString, function()
		local fullName = data.server and data.name .. "-" .. data.server or data.name
		_G.C_GuildInfo.Invite(name or fullName)
	end)
end

-- REASON: Appends a "Copy Name" button to specific unit context menus for easy name extraction.
function Module:CustomMenu_CopyName(rootDescription, data, name)
	rootDescription:CreateButton(K.InfoColor .. COPY_NAME, function()
		local editBox = _G.ChatEdit_ChooseBoxForSend()
		local hasText = editBox:GetText() ~= ""
		ChatEdit_ActivateChat(editBox)
		editBox:Insert(name or data.name)
		if not hasText then
			editBox:HighlightText()
		end
	end)
end

-- REASON: Appends a "Whisper" button to specific unit context menus.
function Module:CustomMenu_Whisper(rootDescription, data)
	rootDescription:CreateButton(K.InfoColor .. WHISPER, function()
		_G.ChatFrame_SendTell(data.name)
	end)
end

-- REASON: Modifies the new WoW 10.0+ Menu System to inject custom KkthnxUI context menu options.
function Module:CreateQuickMenuList()
	if not C["Misc"].QuickMenuList then
		return
	end

	local menu = _G.Menu
	menu.ModifyMenu("MENU_UNIT_SELF", function(_, rootDescription, data)
		Module:CustomMenu_CopyName(rootDescription, data)
		Module:CustomMenu_Whisper(rootDescription, data)
	end)

	menu.ModifyMenu("MENU_UNIT_TARGET", function(_, rootDescription, data)
		Module:CustomMenu_CopyName(rootDescription, data)
	end)

	menu.ModifyMenu("MENU_UNIT_PLAYER", function(_, rootDescription, data)
		Module:CustomMenu_GuildInvite(rootDescription, data)
	end)

	menu.ModifyMenu("MENU_UNIT_FRIEND", function(_, rootDescription, data)
		Module:CustomMenu_AddFriend(rootDescription, data)
		Module:CustomMenu_GuildInvite(rootDescription, data)
	end)

	menu.ModifyMenu("MENU_UNIT_BN_FRIEND", function(_, rootDescription, data)
		local fullName
		local gameAccountInfo = data.accountInfo and data.accountInfo.gameAccountInfo
		if gameAccountInfo then
			local characterName = gameAccountInfo.characterName
			local realmName = gameAccountInfo.realmName
			if characterName and realmName then
				fullName = characterName .. "-" .. realmName
			end
		end
		Module:CustomMenu_AddFriend(rootDescription, data, fullName)
		Module:CustomMenu_GuildInvite(rootDescription, data, fullName)
		Module:CustomMenu_CopyName(rootDescription, data, fullName)
	end)

	menu.ModifyMenu("MENU_UNIT_PARTY", function(_, rootDescription, data)
		Module:CustomMenu_GuildInvite(rootDescription, data)
	end)

	menu.ModifyMenu("MENU_UNIT_RAID", function(_, rootDescription, data)
		Module:CustomMenu_AddFriend(rootDescription, data)
		Module:CustomMenu_GuildInvite(rootDescription, data)
		Module:CustomMenu_CopyName(rootDescription, data)
		Module:CustomMenu_Whisper(rootDescription, data)
	end)

	menu.ModifyMenu("MENU_UNIT_RAID_PLAYER", function(_, rootDescription, data)
		Module:CustomMenu_GuildInvite(rootDescription, data)
	end)
end

-- REASON: Implements a custom waypoint system compatible with Blizzard's 9.0+ mapping API.
function Module:CreateCustomWaypoint()
	if _G.hash_SlashCmdList["/WAY"] or _G.hash_SlashCmdList["/GO"] then
		return
	end

	if C_AddOns.IsAddOnLoaded("TomTom") then
		return
	end

	local debugMode = false
	local pointString = K.InfoColor .. "|Hworldmap:%d:%d:%d|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a%s (%.1f, %.1f)%s]|h|r"
	local recentWaypoints = {}

	local function debugPrint(...)
		if debugMode then
			_G.print("|cFF00FF00[DEBUG]:|r", ...)
		end
	end

	local function getCorrectCoord(coord)
		debugPrint("Validating coordinate:", coord)
		-- Remove any accidental trailing dots that could break tonumber
		coord = coord and coord:gsub("%.+$", "")
		local num = tonumber(coord)
		if not num then
			return
		end
		return math_max(0, math_min(num, 100))
	end


	local function canWaypointOnMap(mapID)
		if not mapID then
			return false
		end
		local canSet = true
		if _G.C_Map and _G.C_Map.CanSetUserWaypointOnMap then
			canSet = _G.C_Map.CanSetUserWaypointOnMap(mapID)
		end
		return not not canSet
	end

	local function formatClickableWaypoint(mapID, x, y, mapName, desc)
		local descriptionPart = desc and (" " .. desc) or ""
		local hx = math_floor(x * 100 + 0.5)
		local hy = math_floor(y * 100 + 0.5)
		local formatted = string_format(pointString, mapID, hx, hy, mapName, x, y, descriptionPart)
		debugPrint("Formatted clickable waypoint message:", formatted)
		return formatted
	end

	local function setWaypoint(mapID, x, y, desc)
		if not mapID or not x or not y then
			return
		end

		local info = C_Map_GetMapInfo(mapID)
		local mapName = (info and info.name) or "Unknown"
		debugPrint("Setting waypoint - MapID:", mapID, "X:", x, "Y:", y, "Description:", desc or "No description")

		local message = formatClickableWaypoint(mapID, x, y, mapName, desc)
		_G.print(message)

		if canWaypointOnMap(mapID) then
			C_Map_SetUserWaypoint(UiMapPoint_CreateFromCoordinates(mapID, x / 100, y / 100))
			C_SuperTrack_SetSuperTrackedUserWaypoint(true)
		end

		table_insert(recentWaypoints, { mapID = mapID, x = x, y = y, desc = desc, name = mapName })
		if #recentWaypoints > 20 then
			table_remove(recentWaypoints, 1)
		end

		if C["WorldMap"].AutoOpenWaypoint then
			if _G.C_Map.OpenWorldMap then
				_G.C_Map.OpenWorldMap(mapID)
			elseif WorldMapFrame then
				if WorldMapFrame.SetMapID then
					WorldMapFrame:SetMapID(mapID)
				end
				WorldMapFrame:Show()
			end
		end
	end

	local function parseInput(msg)
		debugPrint("Parsing input:", msg)
		msg = (msg or ""):gsub("^%s+", ""):gsub("%s+$", "")
		if msg == "" or msg:lower() == "here" then
			local mapID = C_Map_GetBestMapForUnit("player")
			if not mapID then
				_G.print("Unable to determine the current map.")
				return
			end
			local pos = _G.C_Map.GetPlayerMapPosition(mapID, "player")
			if not pos then
				_G.print("Unable to determine player position on the current map.")
				return
			end
			local px, py = pos:GetXY()
			return mapID, px * 100, py * 100, nil
		end

		-- Convert commas followed by spaces to just spaces (e.g. "51.29, 44.31" -> "51.29 44.31")
		msg = msg:gsub(",%s+", " ")
		-- Convert remaining commas to dots (for EU coordinate format)
		msg = msg:gsub(",", "."):gsub(";", " "):gsub("%s+", " ")

		local mapName, nsx, nsy, ndesc = string_match(msg, '^"([^"]+)"%s+([%d%.]+)%s+([%d%.]+)%s*(.*)$')
		if not mapName then
			mapName, nsx, nsy, ndesc = string_match(msg, "^([^#%d][^%d]*)%s+([%d%.]+)%s+([%d%.]+)%s*(.*)$")
			if mapName then
				mapName = mapName:gsub("%s+$", "")
			end
		end

		if mapName and nsx and nsy then
			local function findRoot(id)
				local info = C_Map_GetMapInfo(id)
				while info and info.parentMapID and info.parentMapID ~= 0 do
					local parent = C_Map_GetMapInfo(info.parentMapID)
					if not parent then
						break
					end
					info = parent
				end
				return info and info.mapID
			end

			local function findByName(rootID, name)
				if not rootID then
					return
				end
				local children = _G.C_Map.GetMapChildrenInfo(rootID, nil, true)
				if children then
					local lname = name:lower()
					for i = 1, #children do
						local mi = children[i]
						if mi.name and mi.name:lower() == lname then
							return mi.mapID
						end
					end
				end
			end

			local current = C_Map_GetBestMapForUnit("player")
			local root = current and findRoot(current)
			local found = root and findByName(root, mapName)
			if found then
				local xx = getCorrectCoord(nsx)
				local yy = getCorrectCoord(nsy)
				if xx and yy then
					return found, xx, yy, (ndesc ~= "" and ndesc or nil)
				end
			end
		end

		local mapID, sx, sy, desc = string_match(msg, "^#(%d+)%s+([%d%.]+)%s+([%d%.]+)%s*(.*)$")
		if not mapID then
			sx, sy, desc = string_match(msg, "^([%d%.]+)%s+([%d%.]+)%s*(.*)$")
			if sx and sy then
				mapID = C_Map_GetBestMapForUnit("player")
				if not mapID then
					_G.print("Unable to determine the current map.")
					return
				end
			end
		end

		if not mapID or not sx or not sy then
			if mapName then
				_G.print(string_format("Map '%s' not found.", mapName))
			else
				_G.print("Invalid input. Usage: /way [#<mapID>] <x> <y> [description]")
			end
			return
		end

		local x = getCorrectCoord(sx)
		local y = getCorrectCoord(sy)
		mapID = tonumber(mapID)

		if not (x and y and mapID) then
			_G.print("Coordinates must be between 0 and 100, and mapID must be valid.")
			return
		end

		debugPrint("Parsed values - MapID:", mapID, "X:", x, "Y:", y, "Description:", desc or "No description")
		return mapID, x, y, (desc ~= "" and desc or nil)
	end

	local function handleSlashCommand(msg, command)
		debugPrint("Handling /" .. command .. " command with input:", msg)
		local lowerInput = (msg or ""):lower():gsub("^%s+", "")

		if lowerInput == "clear" then
			if _G.C_Map.ClearUserWaypoint then
				_G.C_Map.ClearUserWaypoint()
			end
			C_SuperTrack_SetSuperTrackedUserWaypoint(false)
			_G.print("Waypoints cleared.")
			return
		elseif lowerInput == "list" then
			if #recentWaypoints == 0 then
				_G.print("No recent waypoints.")
			else
				_G.print("Recent waypoints:")
				for i, wp in ipairs(recentWaypoints) do
					local message = formatClickableWaypoint(wp.mapID, wp.x, wp.y, wp.name, wp.desc)
					_G.print(string_format(" [%d] %s", i, message))
				end
			end
			return
		else
			local removeIndex = lowerInput:match("^remove%s+(%d+)$")
			if removeIndex then
				removeIndex = tonumber(removeIndex)
				if removeIndex >= 1 and removeIndex <= #recentWaypoints then
					local wp = recentWaypoints[removeIndex]
					local message = formatClickableWaypoint(wp.mapID, wp.x, wp.y, wp.name, wp.desc)
					table_remove(recentWaypoints, removeIndex)
					_G.print("Removed waypoint #" .. removeIndex .. ": " .. message)
					return
				end
				_G.print("Invalid index.")
				return
			end
		end

		local mapID, x, y, desc = parseInput(msg)
		if mapID then
			setWaypoint(mapID, x, y, desc)
		else
			debugPrint("Parsing failed for input:", msg)
		end
	end

	_G.SlashCmdList["KKUI_WAY"] = function(msg)
		handleSlashCommand(msg, "way")
	end
	_G.SLASH_KKUI_WAY1 = "/way"

	_G.SlashCmdList["KKUI_GO"] = function(msg)
		handleSlashCommand(msg, "go")
	end
	_G.SLASH_KKUI_GO1 = "/go"
end

-- Update Max Camera Zoom
function Module:UpdateMaxCameraZoom()
	local value = tonumber(C["Misc"].MaxCameraZoom) or 2.6
	value = math_min(math_max(value, 1), 2.6)
	_G.SetCVar("cameraDistanceMaxZoomFactor", value)
end
