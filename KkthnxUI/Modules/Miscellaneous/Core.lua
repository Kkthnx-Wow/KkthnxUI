local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Miscellaneous")

-- Localizing Lua built-in functions for performance
local select = select
local tonumber = tonumber
local next = next
local type = type
local ipairs = ipairs
local pcall = pcall
local error = error

-- Localizing WoW API functions and variables
local BNToastFrame = BNToastFrame
local C_BattleNet_GetGameAccountInfoByGUID = C_BattleNet.GetGameAccountInfoByGUID
local C_FriendList_IsFriend = C_FriendList.IsFriend
local C_QuestLog_GetSelectedQuest = C_QuestLog.GetSelectedQuest
local C_QuestLog_ShouldShowQuestRewards = C_QuestLog.ShouldShowQuestRewards
local CreateFrame = CreateFrame
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetMerchantItemLink = GetMerchantItemLink
local GetMerchantItemMaxStack = GetMerchantItemMaxStack
local GetQuestLogRewardXP = GetQuestLogRewardXP
local GetRewardXP = GetRewardXP
local InCombatLockdown = InCombatLockdown
local IsAltKeyDown = IsAltKeyDown
local IsGuildMember = IsGuildMember
local PlaySound = PlaySound
local StaticPopupDialogs = StaticPopupDialogs
local StaticPopup_Show = StaticPopup_Show
local UIParent = UIParent
local UnitGUID = UnitGUID
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax
local hooksecurefunc = hooksecurefunc

-- Localizing WoW UI constants
local FRIEND = FRIEND
local GUILD = GUILD
local NO = NO
local YES = YES

local KKUI_MISC_MODULE = {}

function Module:RegisterMisc(name, func)
	if not KKUI_MISC_MODULE[name] then
		KKUI_MISC_MODULE[name] = func
	end
end

function Module:OnEnable()
	-- First loop: Iterating over KKUI_MISC_MODULE
	for name, func in next, KKUI_MISC_MODULE do
		if name and type(func) == "function" then
			func()
		end
	end

	-- Second loop: Iterating over loadMiscModules
	local loadMiscModules = {
		"CreateBlockStrangerInvites",
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
		"CreateTicketStatusFrameMove",
		"CreateTradeTargetInfo",
		"CreateVehicleSeatMover",
		"HandleKkthnxUITitle",
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

	-- TESTING CMD : /run BNToastFrame:AddToast(BN_TOAST_TYPE_ONLINE, 1)
	if not BNToastFrame.mover then
		BNToastFrame.mover = K.Mover(BNToastFrame, "BNToastFrame", "BNToastFrame", { "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 4, 270 }, _G.BNToastFrame:GetSize())
	else
		BNToastFrame.mover:SetSize(_G.BNToastFrame:GetSize())
	end
	hooksecurefunc(BNToastFrame, "SetPoint", Module.PostBNToastMove)

	-- Unregister talent event
	local function unregisterTalentEvent()
		if PlayerTalentFrame then
			PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		else
			hooksecurefunc("TalentFrame_LoadUI", function()
				PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
			end)
		end
	end
	unregisterTalentEvent()

	-- Auto chatBubbles
	local function enableAutoBubbles()
		if C["Misc"].AutoBubbles then
			local function updateBubble()
				local name, instType = GetInstanceInfo()
				if name and instType == "raid" then
					SetCVar("chatBubbles", 1)
				else
					SetCVar("chatBubbles", 0)
				end
			end
			K:RegisterEvent("PLAYER_ENTERING_WORLD", updateBubble)
		end
	end
	enableAutoBubbles()

	-- Instant delete
	local function modifyDeleteDialog()
		local deleteDialog = StaticPopupDialogs["DELETE_GOOD_ITEM"]
		if deleteDialog.OnShow then
			hooksecurefunc(deleteDialog, "OnShow", function(self)
				self.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
			end)
		end
	end
	modifyDeleteDialog()

	-- Fix blizz bug in addon list
	local function fixAddonTooltip()
		local _AddonTooltip_Update = AddonTooltip_Update
		function AddonTooltip_Update(owner)
			if not owner then
				return
			end

			if owner:GetID() < 1 then
				return
			end
			_AddonTooltip_Update(owner)
		end
	end
	fixAddonTooltip()

	local function fixPartyGuidePromote()
		if not PROMOTE_GUIDE then
			PROMOTE_GUIDE = PARTY_PROMOTE_GUIDE
		end
	end
	fixPartyGuidePromote()
end

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

local function KKUI_ClickMinimapButton(_, btn)
	if btn == "LeftButton" then
		-- Prevent options panel from showing if Blizzard options panel is showing
		if SettingsPanel:IsShown() or ChatConfigFrame:IsShown() then
			return
		end

		-- Check if the player is in combat before opening the options panel
		if InCombatLockdown() then
			UIErrorsFrame:AddMessage(K.InfoColor .. ERR_NOT_IN_COMBAT)
			return
		end

		-- Toggle the options panel
		K["GUI"]:Toggle()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
	end
end

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
	overlay:SetTexture(136430) -- "Interface\\Minimap\\MiniMap-TrackingBorder"
	overlay:SetPoint("TOPLEFT")

	local background = mmb:CreateTexture(nil, "BACKGROUND")
	background:SetSize(20, 20)
	background:SetTexture(136467) -- "Interface\\Minimap\\UI-Minimap-Background"
	background:SetPoint("TOPLEFT", 7, -5)

	local icon = mmb:CreateTexture(nil, "ARTWORK")
	icon:SetSize(22, 11)
	icon:SetPoint("CENTER")
	icon:SetTexture(C["Media"].Textures.LogoSmallTexture)
	--icon.__ignored = false -- ignore KkthnxUI recycle bin

	mmb:SetScript("OnEnter", function()
		GameTooltip:ClearLines()
		GameTooltip:Hide()
		GameTooltip:SetOwner(mmb, "ANCHOR_LEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine("KkthnxUI", 1, 1, 1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("LeftButton: Toggle Config", 0.6, 0.8, 1)
		-- GameTooltip:AddLine("RightButton: Toggle MoveUI", 0.6, 0.8, 1)
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

	-- Function to toggle LibDBIcon
	function Module:ToggleMinimapIcon()
		if C["General"].MinimapIcon then
			mmb:Show()
		else
			mmb:Hide()
		end
	end

	Module:ToggleMinimapIcon()
end

local function MainMenu_OnShow(self)
	local buttonToReanchor, buttonHeight

	local isCharacterNewlyBoosted = IsCharacterNewlyBoosted()
	local canViewSplashScreen = C_SplashScreen.CanViewSplashScreen()

	if isCharacterNewlyBoosted or not canViewSplashScreen then
		buttonToReanchor = GameMenuButtonStore
		buttonHeight = Module.GameMenuButton:GetHeight() + 28
	else
		buttonToReanchor = GameMenuButtonWhatsNew
		buttonHeight = Module.GameMenuButton:GetHeight() + 34
	end

	self:SetHeight(self:GetHeight() + buttonHeight)

	_G.GameMenuButtonLogout:SetPoint("TOP", Module.GameMenuButton, "BOTTOM", 0, -14)
	_G.GameMenuButtonStore:SetPoint("TOP", _G.GameMenuButtonHelp, "BOTTOM", 0, -6)

	if _G.GameMenuButtonWhatsNew then
		_G.GameMenuButtonWhatsNew:SetPoint("TOP", _G.GameMenuButtonStore, "BOTTOM", 0, -6)
	end

	_G.GameMenuButtonEditMode:SetPoint("TOP", buttonToReanchor, "BOTTOM", 0, -24)
	_G.GameMenuButtonSettings:SetPoint("TOP", _G.GameMenuButtonEditMode, "BOTTOM", 0, -6)
	_G.GameMenuButtonMacros:SetPoint("TOP", _G.GameMenuButtonSettings, "BOTTOM", 0, -6)
	_G.GameMenuButtonAddons:SetPoint("TOP", _G.GameMenuButtonMacros, "BOTTOM", 0, -6)
	_G.GameMenuButtonQuit:SetPoint("TOP", _G.GameMenuButtonLogout, "BOTTOM", 0, -6)
end

local function Button_OnClick()
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(K.InfoColor .. ERR_NOT_IN_COMBAT)
		return
	end

	K["GUI"]:Toggle()
	HideUIPanel(_G.GameMenuFrame)
	PlaySound(_G.SOUNDKIT.IG_MAINMENU_OPTION)
end

function Module:CreateGUIGameMenuButton()
	local bu = CreateFrame("Button", "KKUI_GameMenuButton", _G.GameMenuFrame, "GameMenuButtonTemplate")
	bu:SetText(K.Title)
	bu:SetPoint("TOP", _G.GameMenuButtonAddons, "BOTTOM", 0, -12)
	bu:SetScript("OnClick", Button_OnClick)
	bu:SkinButton(true)

	Module.GameMenuButton = bu

	_G.GameMenuFrame:HookScript("OnShow", MainMenu_OnShow)
end

function Module:CreateQuestXPPercent()
	local playerCurrentXP, playerMaxXP = UnitXP("player"), UnitXPMax("player")
	local questXP, xpText, xpFrame

	if _G.QuestInfoFrame.questLog then
		local selectedQuest = C_QuestLog_GetSelectedQuest()
		if C_QuestLog_ShouldShowQuestRewards(selectedQuest) then
			questXP = GetQuestLogRewardXP()
			xpText, xpFrame = MapQuestInfoRewardsFrame.XPFrame.Name:GetText(), _G.MapQuestInfoRewardsFrame.XPFrame.Name
		end
	else
		questXP = GetRewardXP()
		xpText, xpFrame = QuestInfoXPFrame.ValueText:GetText(), _G.QuestInfoXPFrame.ValueText
	end

	-- Calculate and display the XP percentage gain
	if questXP and questXP > 0 and xpText then
		local xpPercentageIncrease = (((playerCurrentXP + questXP) / playerMaxXP) - (playerCurrentXP / playerMaxXP)) * 100
		xpFrame:SetFormattedText("%s (|cff4beb2c+%.2f%%|r)", xpText, xpPercentageIncrease)
	end
end

-- Reanchor Vehicle
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

-- Reanchor DurabilityFrame
function Module:CreateDurabilityFrameMove()
	hooksecurefunc(DurabilityFrame, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == MinimapCluster then
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", -40, -50)
		end
	end)
end

-- Reanchor TicketStatusFrame
function Module:CreateTicketStatusFrameMove()
	hooksecurefunc(TicketStatusFrame, "SetPoint", function(self, relF)
		if relF == "TOPRIGHT" then
			self:ClearAllPoints()
			self:SetPoint("TOP", UIParent, "TOP", -400, -20)
		end
	end)
end

-- Hide Bossbanner
function Module:CreateBossBanner()
	if C["Misc"].HideBanner and not C["Misc"].KillingBlow then
		BossBanner:UnregisterAllEvents()
	else
		BossBanner:RegisterEvent("BOSS_KILL")
		BossBanner:RegisterEvent("ENCOUNTER_LOOT_RECEIVED")
	end
end

-- Hide boss emote
function Module:CreateBossEmote()
	if C["Misc"].HideBossEmote then
		RaidBossEmoteFrame:UnregisterAllEvents()
	else
		RaidBossEmoteFrame:RegisterEvent("RAID_BOSS_EMOTE")
		RaidBossEmoteFrame:RegisterEvent("RAID_BOSS_WHISPER")
		RaidBossEmoteFrame:RegisterEvent("CLEAR_BOSS_EMOTES")
	end
end

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

function Module:CreateQuestSizeUpdate()
	QuestTitleFont:SetFont(QuestTitleFont:GetFont(), C["Skins"].QuestFontSize + 3, "")
	QuestFont:SetFont(QuestFont:GetFont(), C["Skins"].QuestFontSize + 1, "")
	QuestFontNormalSmall:SetFont(QuestFontNormalSmall:GetFont(), C["Skins"].QuestFontSize, "")
end

function Module:CreateObjectiveSizeUpdate()
	ObjectiveFont:SetFontObject(K.UIFont)
	ObjectiveFont:SetFont(ObjectiveFont:GetFont(), C["Skins"].ObjectiveFontSize, select(3, ObjectiveFont:GetFont()))
end

-- TradeFrame hook
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

	-- Call the update function once when the frame is shown
	updateColor()

	-- Only hook the update function once, to avoid excessive function calls
	TradeFrame:HookScript("OnShow", updateColor)
end

-- Archaeology counts
do
	local function DisplayArchaeologyCounts(tooltip, anchor)
		tooltip:SetOwner(anchor, "ANCHOR_BOTTOMRIGHT")
		tooltip:ClearLines()
		tooltip:AddLine("|c0000FF00Arch Count:")
		tooltip:AddLine(" ")

		local totalArtifacts = 0
		for raceIndex = 1, GetNumArchaeologyRaces() do
			local numArtifacts = GetNumArtifactsByRace(raceIndex)
			local raceArtifactCount = 0
			for artifactIndex = 1, numArtifacts do
				local completionCount = select(10, GetArtifactInfoByRace(raceIndex, artifactIndex))
				raceArtifactCount = raceArtifactCount + completionCount
			end
			if numArtifacts > 1 then
				local raceName = GetArchaeologyRaceInfo(raceIndex)
				tooltip:AddDoubleLine(raceName .. ":", K.InfoColor .. raceArtifactCount)
				totalArtifacts = totalArtifacts + raceArtifactCount
			end
		end

		tooltip:AddLine(" ")
		tooltip:AddDoubleLine("|c0000ff00" .. TOTAL .. ":", "|cffff0000" .. totalArtifacts)
		tooltip:Show()
	end

	local function CreateArchaeologyCalculateButton()
		local button = CreateFrame("Button", nil, ArchaeologyFrameCompletedPage)
		button:SetPoint("TOPRIGHT", -45, -45)
		button:SetSize(35, 35)
		button.Icon = button:CreateTexture(nil, "ARTWORK")
		button.Icon:SetAllPoints()
		button.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		button.Icon:SetTexture("Interface\\ICONS\\Ability_Iyyokuk_Calculate")
		button:CreateBorder()
		button:StyleButton()

		button:SetScript("OnEnter", function()
			DisplayArchaeologyCounts(GameTooltip, button)
		end)
		button:SetScript("OnLeave", K.HideTooltip)
	end

	local function InitializeArchaeologyUI(event, addon)
		if addon == "Blizzard_ArchaeologyUI" then
			CreateArchaeologyCalculateButton()

			-- Reposition Archaeology Progress Bar
			ArcheologyDigsiteProgressBar.ignoreFramePositionManager = true
			ArcheologyDigsiteProgressBar:SetPoint("TOP", _G.UIParent, "TOP", 0, -400)
			K.CreateMoverFrame(ArcheologyDigsiteProgressBar)

			K:UnregisterEvent(event, InitializeArchaeologyUI)
		end
	end
	K:RegisterEvent("ADDON_LOADED", InitializeArchaeologyUI)

	local updatedProgressBarTitle = ARCHAEOLOGY_DIGSITE_PROGRESS_BAR_TITLE .. " - %s/%s"
	local function UpdateProgressBarTitle(_, numFindsCompleted, totalFinds)
		if ArcheologyDigsiteProgressBar then
			ArcheologyDigsiteProgressBar.BarTitle:SetFormattedText(updatedProgressBarTitle, numFindsCompleted, totalFinds)
		end
	end
	K:RegisterEvent("ARCHAEOLOGY_SURVEY_CAST", UpdateProgressBarTitle)
	K:RegisterEvent("ARCHAEOLOGY_FIND_COMPLETE", UpdateProgressBarTitle)
end

-- ALT+RightClick to buy a stack
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

			local name, _, quality, _, _, _, _, maxStack, _, texture = GetItemInfo(itemLink)
			if maxStack and maxStack > 1 then
				if not cache[itemLink] then
					local r, g, b = GetItemQualityColor(quality or 1)
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

-- Fix Drag Collections taint
do
	local done
	local function fixCollectionTaint(event, addon)
		if event == "ADDON_LOADED" and addon == "Blizzard_Collections" then
			-- Fix undragable issue
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

-- Select target when click on raid units
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

-- Fix blizz guild news hyperlink error
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

do
	local function soundOnResurrect()
		if C["Unitframe"].ResurrectSound then
			PlaySound("72978", "Master")
		end
	end
	K:RegisterEvent("RESURRECT_REQUEST", soundOnResurrect)
end

function Module:CreateBlockStrangerInvites()
	K:RegisterEvent("PARTY_INVITE_REQUEST", function(a, b, c, d, e, f, g, guid)
		if C["Automation"].AutoBlockStrangerInvites and not (C_BattleNet_GetGameAccountInfoByGUID(guid) or C_FriendList_IsFriend(guid) or IsGuildMember(guid)) then
			_G.DeclineGroup()
			_G.StaticPopup_Hide("PARTY_INVITE")
			K.Print("Blocked invite request from a stranger!", a, b, c, d, e, f, g, guid)
		end
	end)
end

-- Make it so we can move this
function Module:PostBNToastMove(_, anchor)
	if anchor ~= BNToastFrame.mover then
		BNToastFrame:ClearAllPoints()
		BNToastFrame:SetPoint(BNToastFrame.mover.anchorPoint or "TOPLEFT", BNToastFrame.mover, BNToastFrame.mover.anchorPoint or "TOPLEFT")
	end
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

function Module:UpdateMaxCameraZoom()
	SetCVar("cameraDistanceMaxZoomFactor", C["Misc"].MaxCameraZoom)
end

function Module:HandleKkthnxUITitle()
	-- Square KkthnxUI logo texture
	local function replaceIconString(self, text)
		if not text then
			text = self:GetText()
		end
		if not text or text == "" then
			return
		end

		if strfind(text, "KkthnxUI") or strfind(text, "BaudErrorFrame") then
			local newText, count = gsub(text, "|T([^:]-):[%d+:]+|t", "|T" .. "Interface\\AddOns\\KkthnxUI\\Media\\Textures\\LogoSmall" .. ":20:20|t")
			if count > 0 then
				self:SetFormattedText("%s", newText)
			end
		end
	end

	hooksecurefunc("AddonList_InitButton", function(entry)
		if not entry.logoHooked then
			replaceIconString(entry.Title)
			hooksecurefunc(entry.Title, "SetText", replaceIconString)

			entry.logoHooked = true
		end
	end)
end
