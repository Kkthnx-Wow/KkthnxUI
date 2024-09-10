local K = KkthnxUI[1]
local C = KkthnxUI[2]
local L = KkthnxUI[3]
local Module = K:NewModule("Miscellaneous")

-- Localizing Lua built-in functions
local select = select
local tonumber = tonumber
local next = next
local type = type
local ipairs = ipairs
local pcall = pcall
local error = error

-- Localizing WoW API functions
local CreateFrame = CreateFrame
local PlaySound = PlaySound
local StaticPopup_Show = StaticPopup_Show
local hooksecurefunc = hooksecurefunc
local UIParent = UIParent
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax
local UnitGUID = UnitGUID
local GetMerchantItemLink = GetMerchantItemLink
local GetMerchantItemMaxStack = GetMerchantItemMaxStack
local GetRewardXP = GetRewardXP
local GetQuestLogRewardXP = GetQuestLogRewardXP
local IsAltKeyDown = IsAltKeyDown
local InCombatLockdown = InCombatLockdown
local C_BattleNet_GetGameAccountInfoByGUID = C_BattleNet.GetGameAccountInfoByGUID
local C_FriendList_IsFriend = C_FriendList.IsFriend
local C_QuestLog_GetSelectedQuest = C_QuestLog.GetSelectedQuest
local C_QuestLog_ShouldShowQuestRewards = C_QuestLog.ShouldShowQuestRewards
local C_Item_GetItemInfo = C_Item.GetItemInfo
local C_Item_GetItemQualityColor = C_Item.GetItemQualityColor
local StaticPopupDialogs = StaticPopupDialogs
local IsGuildMember = IsGuildMember

-- Localizing WoW UI constants
local FRIEND = FRIEND
local GUILD = GUILD
local NO = NO
local YES = YES

-- Miscellaneous Module Registry
local KKUI_MISC_MODULE = {}

-- Register Miscellaneous Modules
function Module:RegisterMisc(name, func)
	if not KKUI_MISC_MODULE[name] then
		KKUI_MISC_MODULE[name] = func
	end
end

-- Unregister Talent Event
local function unregisterTalentEvent()
	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
		hooksecurefunc("TalentFrame_LoadUI", function()
			PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		end)
	end
end

-- Enable Auto Chat Bubbles
local function enableAutoBubbles()
	if C["Misc"].AutoBubbles then
		local function updateBubble()
			local name, instType = GetInstanceInfo()
			SetCVar("chatBubbles", (name and instType == "raid") and 1 or 0)
		end
		K:RegisterEvent("PLAYER_ENTERING_WORLD", updateBubble)
	end
end

-- Modify Delete Dialog
local function modifyDeleteDialog()
	local confirmationText = DELETE_GOOD_ITEM:gsub("[\r\n]", "@")
	local _, confirmationType = strsplit("@", confirmationText, 2)

	local function setHyperlinkHandlers(dialog)
		dialog.OnHyperlinkEnter = StaticPopupDialogs["DELETE_GOOD_ITEM"].OnHyperlinkEnter
		dialog.OnHyperlinkLeave = StaticPopupDialogs["DELETE_GOOD_ITEM"].OnHyperlinkLeave
	end

	setHyperlinkHandlers(StaticPopupDialogs["DELETE_ITEM"])
	setHyperlinkHandlers(StaticPopupDialogs["DELETE_QUEST_ITEM"])
	setHyperlinkHandlers(StaticPopupDialogs["DELETE_GOOD_QUEST_ITEM"])

	local deleteConfirmationFrame = CreateFrame("FRAME")
	deleteConfirmationFrame:RegisterEvent("DELETE_ITEM_CONFIRM")
	deleteConfirmationFrame:SetScript("OnEvent", function()
		local staticPopup = StaticPopup1
		local editBox = StaticPopup1EditBox
		local button = StaticPopup1Button1
		local popupText = StaticPopup1Text

		if editBox:IsShown() then
			staticPopup:SetHeight(staticPopup:GetHeight() - 14)
			editBox:Hide()
			button:Enable()
			local link = select(3, GetCursorInfo())

			if link then
				local linkType, linkOptions, name = LinkUtil.ExtractLink(link)
				if linkType == "battlepet" then
					local _, level, breedQuality = strsplit(":", linkOptions)
					local qualityColor = BAG_ITEM_QUALITY_COLORS[tonumber(breedQuality)]
					link = qualityColor:WrapTextInColorCode(name .. " |n" .. "Level" .. " " .. level .. "Battle Pet")
				end
				popupText:SetText(popupText:GetText():gsub(confirmationType, "") .. "|n|n" .. link)
			end
		else
			staticPopup:SetHeight(staticPopup:GetHeight() + 40)
			editBox:Hide()
			button:Enable()
			local link = select(3, GetCursorInfo())

			if link then
				local linkType, linkOptions, name = LinkUtil.ExtractLink(link)
				if linkType == "battlepet" then
					local _, level, breedQuality = strsplit(":", linkOptions)
					local qualityColor = BAG_ITEM_QUALITY_COLORS[tonumber(breedQuality)]
					link = qualityColor:WrapTextInColorCode(name .. " |n" .. "Level" .. " " .. level .. "Battle Pet")
				end
				popupText:SetText(popupText:GetText():gsub(confirmationType, "") .. "|n|n" .. link)
			end
		end
	end)
end

-- Fix Addon Tooltip
local function fixAddonTooltip()
	local _AddonTooltip_Update = AddonTooltip_Update
	function AddonTooltip_Update(owner)
		if owner and owner:GetID() >= 1 then
			_AddonTooltip_Update(owner)
		end
	end
end

-- Fix Party Guide Promote
local function fixPartyGuidePromote()
	if not PROMOTE_GUIDE then
		PROMOTE_GUIDE = PARTY_PROMOTE_GUIDE
	end
end

-- Enable Module and Initialize Miscellaneous Modules
function Module:OnEnable()
	for name, func in next, KKUI_MISC_MODULE do
		if name and type(func) == "function" then
			func()
		end
	end

	local loadMiscModules = {
		"CreateBossBanner",
		"CreateBossEmote",
		"CreateCustomWaypoint",
		"CreateDeathCounter",
		"CreateDurabilityFrameMove",
		"CreateErrorFrameToggle",
		"CreateGUIGameMenuButton",
		"CreateMinimapButtonToggle",
		"CreateObjectiveSizeUpdate",
		"CreateQuestSizeUpdate",
		"CreateQuickMenuButton",
		"CreateTicketStatusFrameMove",
		"CreateTradeTargetInfo",
		"CreateVehicleSeatMover",
		"UpdateMaxCameraZoom",
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

	unregisterTalentEvent()
	enableAutoBubbles()
	modifyDeleteDialog()
	fixAddonTooltip()
	fixPartyGuidePromote()
end

-- BNToast Frame Mover Setup
function Module:PostBNToastMove(_, anchor)
	if anchor ~= BNToastFrame.mover then
		BNToastFrame:ClearAllPoints()
		BNToastFrame:SetPoint(BNToastFrame.mover.anchorPoint or "TOPLEFT", BNToastFrame.mover, BNToastFrame.mover.anchorPoint or "TOPLEFT")
	end
end

-- Update Drag Cursor for Minimap
local function KKUI_UpdateDragCursor(self)
	local mx, my = Minimap:GetCenter()
	local px, py = GetCursorPosition()
	local scale = Minimap:GetEffectiveScale()
	px, py = px / scale, py / scale

	local angle = atan2(py - my, px - mx)
	local x, y, q = cos(angle), sin(angle), 1
	if x < 0 then
		q = q + 1
	end
	if y > 0 then
		q = q + 2
	end

	local w = (Minimap:GetWidth() / 2) + 5
	local h = (Minimap:GetHeight() / 2) + 5
	local diagRadiusW = sqrt(2 * w ^ 2) - 10
	local diagRadiusH = sqrt(2 * h ^ 2) - 10
	x = max(-w, min(x * diagRadiusW, w))
	y = max(-h, min(y * diagRadiusH, h))

	self:ClearAllPoints()
	self:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

-- Click Minimap Button Functionality
local function KKUI_ClickMinimapButton(_, btn)
	if btn == "LeftButton" then
		if SettingsPanel:IsShown() or ChatConfigFrame:IsShown() then
			return
		end
		if InCombatLockdown() then
			UIErrorsFrame:AddMessage(K.InfoColor .. ERR_NOT_IN_COMBAT)
			return
		end
		K["GUI"]:Toggle()
		PlaySound(SOUNDKIT_IG_MAINMENU_OPTION)
	end
end

-- Create Minimap Button
function Module:CreateMinimapButtonToggle()
	local mmb = CreateFrame("Button", "KKUI_MinimapButton", Minimap)
	mmb:SetPoint("BOTTOMLEFT", -15, 20)
	mmb:SetSize(32, 32)
	mmb:SetMovable(true)
	mmb:SetUserPlaced(true)
	mmb:RegisterForDrag("LeftButton")
	mmb:SetHighlightTexture(C["Media"].Textures.LogoSmallTexture)
	mmb:GetHighlightTexture():SetSize(18, 9)
	mmb:GetHighlightTexture():ClearAllPoints()
	mmb:GetHighlightTexture():SetPoint("CENTER")

	local overlay = mmb:CreateTexture(nil, "OVERLAY")
	overlay:SetSize(53, 53)
	overlay:SetTexture(136430)
	overlay:SetPoint("TOPLEFT")

	local background = mmb:CreateTexture(nil, "BACKGROUND")
	background:SetSize(20, 20)
	background:SetTexture(136467)
	background:SetPoint("TOPLEFT", 7, -5)

	local icon = mmb:CreateTexture(nil, "ARTWORK")
	icon:SetSize(22, 11)
	icon:SetPoint("CENTER")
	icon:SetTexture(C["Media"].Textures.LogoSmallTexture)

	mmb:SetScript("OnEnter", function()
		GameTooltip:SetOwner(mmb, "ANCHOR_LEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine("KkthnxUI", 1, 1, 1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("LeftButton: Toggle Config", 0.6, 0.8, 1)
		GameTooltip:Show()
	end)

	mmb:SetScript("OnLeave", GameTooltip_Hide)
	mmb:RegisterForClicks("AnyUp")
	mmb:SetScript("OnClick", KKUI_ClickMinimapButton)
	mmb:SetScript("OnDragStart", function(self)
		self:SetScript("OnUpdate", KKUI_UpdateDragCursor)
	end)
	mmb:SetScript("OnDragStop", function(self)
		self:SetScript("OnUpdate", nil)
	end)

	function Module:ToggleMinimapIcon()
		if C["General"].MinimapIcon then
			mmb:Show()
		else
			mmb:Hide()
		end
	end

	Module:ToggleMinimapIcon()
end

-- Game Menu Setup
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
	K["GUI"]:Toggle()
	HideUIPanel(GameMenuFrame)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
	if not InCombatLockdown() then
		HideUIPanel(GameMenuFrame)
	end
end

function Module:CreateGUIGameMenuButton()
	if GameMenuFrame.KkthnxUI then
		return
	end
	local button = CreateFrame("Button", "KKUI_GameMenuButton", GameMenuFrame, "MainMenuFrameButtonTemplate")
	button:SetScript("OnClick", function()
		Module:ClickGameMenu()
	end)

	button:SkinButton()
	GameMenuFrame.KkthnxUI = button
	GameMenuFrame.MenuButtons = {}
	hooksecurefunc(GameMenuFrame, "Layout", function()
		Module:PositionGameMenuButton()
	end)
end

-- Create Quest XP Percent Display
function Module:CreateQuestXPPercent()
	local playerCurrentXP = UnitXP("player")
	local playerMaxXP = UnitXPMax("player")
	local questXP
	local xpText
	local xpFrame

	if _G.QuestInfoFrame.questLog then
		local selectedQuest = C_QuestLog_GetSelectedQuest()
		if C_QuestLog_ShouldShowQuestRewards(selectedQuest) then
			questXP = GetQuestLogRewardXP()
			xpText = MapQuestInfoRewardsFrame.XPFrame.Name:GetText()
			xpFrame = _G.MapQuestInfoRewardsFrame.XPFrame.Name
		end
	else
		questXP = GetRewardXP()
		xpText = QuestInfoXPFrame.ValueText:GetText()
		xpFrame = _G.QuestInfoXPFrame.ValueText
	end

	if questXP and questXP > 0 and xpText then
		local xpPercentageIncrease = (((playerCurrentXP + questXP) / playerMaxXP) - (playerCurrentXP / playerMaxXP)) * 100
		xpFrame:SetFormattedText("%s (|cff4beb2c+%.2f%%|r)", xpText, xpPercentageIncrease)
	end
end

-- Reanchor Vehicle Seat Indicator
function Module:CreateVehicleSeatMover()
	local frame = CreateFrame("Frame", "KKUI_VehicleSeatMover", UIParent)
	frame:SetSize(125, 125)
	K.Mover(frame, "VehicleSeat", "VehicleSeat", { "BOTTOMRIGHT", UIParent, -400, 30 })

	hooksecurefunc(VehicleSeatIndicator, "SetPoint", function(self, _, parent)
		if parent ~= frame then
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", frame)
		end
	end)
end

-- Reanchor Durability Frame
function Module:CreateDurabilityFrameMove()
	hooksecurefunc(DurabilityFrame, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == MinimapCluster then
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", -40, -50)
		end
	end)
end

-- Reanchor Ticket Status Frame
function Module:CreateTicketStatusFrameMove()
	hooksecurefunc(TicketStatusFrame, "SetPoint", function(self, relF)
		if relF == "TOPRIGHT" then
			self:ClearAllPoints()
			self:SetPoint("TOP", UIParent, "TOP", -400, -20)
		end
	end)
end

-- Hide Boss Banner
function Module:CreateBossBanner()
	if C["Misc"].HideBanner and not C["Misc"].KillingBlow then
		BossBanner:UnregisterAllEvents()
	else
		BossBanner:RegisterEvent("BOSS_KILL")
		BossBanner:RegisterEvent("ENCOUNTER_LOOT_RECEIVED")
	end
end

-- Hide Boss Emote
function Module:CreateBossEmote()
	if C["Misc"].HideBossEmote then
		RaidBossEmoteFrame:UnregisterAllEvents()
	else
		RaidBossEmoteFrame:RegisterEvent("RAID_BOSS_EMOTE")
		RaidBossEmoteFrame:RegisterEvent("RAID_BOSS_WHISPER")
		RaidBossEmoteFrame:RegisterEvent("CLEAR_BOSS_EMOTES")
	end
end

-- Error Frame Toggle Setup
local function SetupErrorFrameToggle(event)
	if event == "PLAYER_REGEN_DISABLED" then
		_G.UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
		K:RegisterEvent("PLAYER_REGEN_ENABLED", SetupErrorFrameToggle)
	else
		_G.UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
		K:UnregisterEvent(event, SetupErrorFrameToggle)
	end
end

function Module:CreateErrorFrameToggle()
	if C["General"].NoErrorFrame then
		K:RegisterEvent("PLAYER_REGEN_DISABLED", SetupErrorFrameToggle)
	else
		K:UnregisterEvent("PLAYER_REGEN_DISABLED", SetupErrorFrameToggle)
	end
end

-- Create Quest Size Update
function Module:CreateQuestSizeUpdate()
	QuestTitleFont:SetFont(QuestTitleFont:GetFont(), C["Skins"].QuestFontSize + 3, "")
	QuestFont:SetFont(QuestFont:GetFont(), C["Skins"].QuestFontSize + 1, "")
	QuestFontNormalSmall:SetFont(QuestFontNormalSmall:GetFont(), C["Skins"].QuestFontSize, "")
end

-- Create Objective Size Update
function Module:CreateObjectiveSizeUpdate()
	ObjectiveFont:SetFontObject(K.UIFont)
	ObjectiveFont:SetFont(ObjectiveFont:GetFont(), C["Skins"].ObjectiveFontSize, select(3, ObjectiveFont:GetFont()))
end

-- TradeFrame Hook
function Module:CreateTradeTargetInfo()
	local infoText = K.CreateFontString(TradeFrame, 16, "", "")
	infoText:SetPoint("TOP", TradeFrameRecipientNameText, "BOTTOM", 0, -8)

	local function updateColor()
		local r, g, b = K.UnitColor("NPC")
		TradeFrameRecipientNameText:SetTextColor(r, g, b)
		local guid = UnitGUID("NPC")
		if not guid then
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
	TradeFrame:HookScript("OnShow", updateColor)
end

-- ALT + Right Click to Buy a Stack
do
	local cache = {}
	local itemLink, id

	StaticPopupDialogs["BUY_STACK"] = {
		text = L["Stack Buying Check"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			if not itemLink then
				return
			end
			BuyMerchantItem(id, GetMerchantItemMaxStack(id))
			cache[itemLink] = true
			itemLink = nil
		end,
		hideOnEscape = 1,
		hasItemFrame = 1,
	}

	local _MerchantItemButton_OnModifiedClick = MerchantItemButton_OnModifiedClick
	function MerchantItemButton_OnModifiedClick(self, ...)
		if IsAltKeyDown() then
			id = self:GetID()
			itemLink = GetMerchantItemLink(id)
			if not itemLink then
				return
			end

			local name, _, quality, _, _, _, _, maxStack, _, texture = C_Item_GetItemInfo(itemLink)
			if maxStack and maxStack > 1 then
				if not cache[itemLink] then
					local r, g, b = C_Item_GetItemQualityColor(quality or 1)
					StaticPopup_Show("BUY_STACK", " ", " ", {
						["texture"] = texture,
						["name"] = name,
						["color"] = { r, g, b, 1 },
						["link"] = itemLink,
						["index"] = id,
						["count"] = maxStack,
					})
				else
					BuyMerchantItem(id, GetMerchantItemMaxStack(id))
				end
			end
		end
		_MerchantItemButton_OnModifiedClick(self, ...)
	end
end

-- Fix Collection Taint
do
	local done
	local function fixCollectionTaint(event, addon)
		if event == "ADDON_LOADED" and addon == "Blizzard_Collections" then
			local checkBox = WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox
			checkBox.Label:ClearAllPoints()
			checkBox.Label:SetPoint("LEFT", checkBox, "RIGHT", 2, 1)
			checkBox.Label:SetWidth(152)

			CollectionsJournal:HookScript("OnShow", function()
				if not done then
					if InCombatLockdown() then
						K:RegisterEvent("PLAYER_REGEN_ENABLED", fixCollectionTaint)
					else
						K.CreateMoverFrame(CollectionsJournal)
					end
					done = true
				end
			end)
			K:UnregisterEvent(event, fixCollectionTaint)
		elseif event == "PLAYER_REGEN_ENABLED" then
			K.CreateMoverFrame(CollectionsJournal)
			K:UnregisterEvent(event, fixCollectionTaint)
		end
	end
	K:RegisterEvent("ADDON_LOADED", fixCollectionTaint)
end

-- Fix Raid Group Button Targeting
do
	local function fixRaidGroupButton()
		for i = 1, 40 do
			local bu = _G["RaidGroupButton" .. i]
			if bu and bu.unit and not bu.clickFixed then
				bu:SetAttribute("type", "target")
				bu:SetAttribute("unit", bu.unit)
				bu.clickFixed = true
			end
		end
	end

	local function setupfixRaidGroup(event, addon)
		if event == "ADDON_LOADED" and addon == "Blizzard_RaidUI" then
			if not InCombatLockdown() then
				fixRaidGroupButton()
			else
				K:RegisterEvent("PLAYER_REGEN_ENABLED", setupfixRaidGroup)
			end
			K:UnregisterEvent(event, setupfixRaidGroup)
		elseif event == "PLAYER_REGEN_ENABLED" then
			if RaidGroupButton1 and RaidGroupButton1:GetAttribute("type") ~= "target" then
				fixRaidGroupButton()
				K:UnregisterEvent(event, setupfixRaidGroup)
			end
		end
	end
	K:RegisterEvent("ADDON_LOADED", setupfixRaidGroup)
end

-- Fix Guild News Hyperlink Error
do
	local function fixGuildNews(event, addon)
		if addon ~= "Blizzard_GuildUI" then
			return
		end
		local _GuildNewsButton_OnEnter = GuildNewsButton_OnEnter
		function GuildNewsButton_OnEnter(self)
			if not (self.newsInfo and self.newsInfo.whatText) then
				return
			end
			_GuildNewsButton_OnEnter(self)
		end
		K:UnregisterEvent(event, fixGuildNews)
	end
	K:RegisterEvent("ADDON_LOADED", fixGuildNews)
end

-- Resurrect Sound on Request
do
	local function soundOnResurrect()
		if C["Unitframe"].ResurrectSound then
			PlaySound("72978", "Master")
		end
	end
	K:RegisterEvent("RESURRECT_REQUEST", soundOnResurrect)
end

function Module:CreateCustomWaypoint()
	if hash_SlashCmdList["/WAY"] or hash_SlashCmdList["/GO"] then
		return
	end

	local pointString = K.InfoColor .. "|Hworldmap:%d+:%d+:%d+|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a%s (%s, %s)%s]|h|r"

	local function GetCorrectCoord(x)
		x = tonumber(x)
		if x then
			if x > 100 then
				return 100
			elseif x < 0 then
				return 0
			end
			return x
		end
	end

	SlashCmdList["KKUI_CUSTOM_WAYPOINT"] = function(msg)
		msg = gsub(msg, "(%d)[%.,] (%d)", "%1 %2")
		local x, y, z = strmatch(msg, "(%S+)%s(%S+)(.*)")
		if x and y then
			local mapID = C_Map.GetBestMapForUnit("player")
			if mapID then
				local mapInfo = C_Map.GetMapInfo(mapID)
				local mapName = mapInfo and mapInfo.name
				if mapName then
					x = GetCorrectCoord(x)
					y = GetCorrectCoord(y)
					if x and y then
						print(format(pointString, mapID, x * 100, y * 100, mapName, x, y, z or ""))
						C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(mapID, x / 100, y / 100))
						C_SuperTrack.SetSuperTrackedUserWaypoint(true)
					else
						print("Invalid waypoint format. Please enter the x and y coordinates in the format 'x y'.")
					end
				end
			end
		else
			print("Invalid waypoint format. Please enter the x and y coordinates in the format 'x y'.")
		end
	end
	SLASH_KKUI_CUSTOM_WAYPOINT1 = "/way"
	SLASH_KKUI_CUSTOM_WAYPOINT2 = "/go"
end

-- Update Max Camera Zoom
function Module:UpdateMaxCameraZoom()
	SetCVar("cameraDistanceMaxZoomFactor", C["Misc"].MaxCameraZoom)
end

-- Enhance Popup Menu with Additional Buttons
function Module:CustomMenu_AddFriend(rootDescription, data, name)
	rootDescription:CreateButton(K.InfoColor .. ADD_CHARACTER_FRIEND, function()
		C_FriendList.AddFriend(name or data.name)
	end)
end

local guildInviteString = gsub(CHAT_GUILD_INVITE_SEND, HEADER_COLON, "")
function Module:CustomMenu_GuildInvite(rootDescription, data, name)
	rootDescription:CreateButton(K.InfoColor .. guildInviteString, function()
		C_GuildInfo.Invite(name or data.name)
	end)
end

function Module:CustomMenu_CopyName(rootDescription, data, name)
	rootDescription:CreateButton(K.InfoColor .. COPY_NAME, function()
		local editBox = ChatEdit_ChooseBoxForSend()
		local hasText = (editBox:GetText() ~= "")
		ChatEdit_ActivateChat(editBox)
		editBox:Insert(name or data.name)
		if not hasText then
			editBox:HighlightText()
		end
	end)
end

function Module:CustomMenu_Whisper(rootDescription, data)
	rootDescription:CreateButton(K.InfoColor .. WHISPER, function()
		ChatFrame_SendTell(data.name)
	end)
end

-- Quick Menu Button Setup
function Module:CreateQuickMenuButton()
	Menu.ModifyMenu("MENU_UNIT_SELF", function(_, rootDescription, data)
		Module:CustomMenu_CopyName(rootDescription, data)
		Module:CustomMenu_Whisper(rootDescription, data)
	end)

	Menu.ModifyMenu("MENU_UNIT_TARGET", function(_, rootDescription, data)
		Module:CustomMenu_CopyName(rootDescription, data)
	end)

	Menu.ModifyMenu("MENU_UNIT_PLAYER", function(_, rootDescription, data)
		Module:CustomMenu_GuildInvite(rootDescription, data)
	end)

	Menu.ModifyMenu("MENU_UNIT_FRIEND", function(_, rootDescription, data)
		Module:CustomMenu_AddFriend(rootDescription, data)
		Module:CustomMenu_GuildInvite(rootDescription, data)
	end)

	Menu.ModifyMenu("MENU_UNIT_BN_FRIEND", function(_, rootDescription, data)
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

	Menu.ModifyMenu("MENU_UNIT_PARTY", function(_, rootDescription, data)
		Module:CustomMenu_GuildInvite(rootDescription, data)
	end)

	Menu.ModifyMenu("MENU_UNIT_RAID", function(_, rootDescription, data)
		Module:CustomMenu_AddFriend(rootDescription, data)
		Module:CustomMenu_GuildInvite(rootDescription, data)
		Module:CustomMenu_CopyName(rootDescription, data)
		Module:CustomMenu_Whisper(rootDescription, data)
	end)

	Menu.ModifyMenu("MENU_UNIT_RAID_PLAYER", function(_, rootDescription, data)
		Module:CustomMenu_GuildInvite(rootDescription, data)
	end)
end
