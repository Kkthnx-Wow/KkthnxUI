local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Miscellaneous")

local select = select
local string_match = string.match
local tonumber = tonumber

local BNToastFrame = BNToastFrame
local C_BattleNet_GetGameAccountInfoByGUID = C_BattleNet.GetGameAccountInfoByGUID
local C_FriendList_IsFriend = C_FriendList.IsFriend
local C_QuestLog_GetSelectedQuest = C_QuestLog.GetSelectedQuest
local C_QuestLog_ShouldShowQuestRewards = C_QuestLog.ShouldShowQuestRewards
local CreateFrame = CreateFrame
local FRIEND = FRIEND
local GUILD = GUILD
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetMerchantItemLink = GetMerchantItemLink
local GetMerchantItemMaxStack = GetMerchantItemMaxStack
local GetQuestLogRewardXP = GetQuestLogRewardXP
local GetRewardXP = GetRewardXP
local InCombatLockdown = InCombatLockdown
local IsAltKeyDown = IsAltKeyDown
local IsGuildMember = IsGuildMember
local NO = NO
local PlaySound = PlaySound
local StaticPopupDialogs = StaticPopupDialogs
local StaticPopup_Show = StaticPopup_Show
local UIParent = UIParent
local UnitGUID = UnitGUID
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax
local YES = YES
local hooksecurefunc = hooksecurefunc

local KKUI_MISC_MODULE = {}

function Module:RegisterMisc(name, func)
	if not KKUI_MISC_MODULE[name] then
		KKUI_MISC_MODULE[name] = func
	end
end

function Module:OnEnable()
	for name, func in next, KKUI_MISC_MODULE do
		if name and type(func) == "function" then
			func()
		end
	end

	self:CreateBlockStrangerInvites()
	self:CreateBossBanner()
	self:CreateBossEmote()
	self:CreateDurabilityFrameMove()
	self:CreateErrorFrameToggle()
	self:CreateGUIGameMenuButton()
	self:CreateJerryWay()
	self:CreateMinimapButtonToggle()
	self:CreateObjectiveSizeUpdate()
	self:CreateQuestSizeUpdate()
	self:CreateTicketStatusFrameMove()
	self:CreateTradeTargetInfo()
	self:CreateVehicleSeatMover()
	self:DisableHelpTip()
	self:DisableTutorials()
	self:MoveMawBuffsFrame()
	self:UpdateMaxCameraZoom()

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
	bu:SetPoint("TOP", _G.GameMenuButtonAddons, "BOTTOM", 0, -6)
	bu:SetScript("OnClick", Button_OnClick)
	bu:SkinButton(true)

	Module.GameMenuButton = bu

	_G.GameMenuFrame:HookScript("OnShow", MainMenu_OnShow)
end

function Module:CreateQuestXPPercent()
	local unitXP, unitXPMax = UnitXP("player"), UnitXPMax("player")
	local xp, text, frame
	if _G.QuestInfoFrame.questLog then
		local selectedQuest = C_QuestLog_GetSelectedQuest()
		if C_QuestLog_ShouldShowQuestRewards(selectedQuest) then
			xp = GetQuestLogRewardXP()
			text, frame = MapQuestInfoRewardsFrame.XPFrame.Name:GetText(), _G.MapQuestInfoRewardsFrame.XPFrame.Name
		end
	else
		xp = GetRewardXP()
		text, frame = QuestInfoXPFrame.ValueText:GetText(), _G.QuestInfoXPFrame.ValueText
	end
	if xp and xp > 0 and text then
		local xpDiff = (((unitXP + xp) / unitXPMax) - (unitXP / unitXPMax)) * 100
		frame:SetFormattedText("%s (|cff4beb2c+%.2f%%|r)", text, xpDiff)
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
	local function CalculateArches(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine("|c0000FF00" .. "Arch Count" .. ":")
		GameTooltip:AddLine(" ")

		local total = 0
		for i = 1, GetNumArchaeologyRaces() do
			local numArtifacts = GetNumArtifactsByRace(i)
			local count = 0
			for j = 1, numArtifacts do
				local completionCount = select(10, GetArtifactInfoByRace(i, j))
				count = count + completionCount
			end
			local name = GetArchaeologyRaceInfo(i)
			if numArtifacts > 1 then
				GameTooltip:AddDoubleLine(name .. ":", K.InfoColor .. count)
				total = total + count
			end
		end

		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine("|c0000ff00" .. TOTAL .. ":", "|cffff0000" .. total)
		GameTooltip:Show()
	end

	local function AddCalculateIcon()
		local bu = CreateFrame("Button", nil, ArchaeologyFrameCompletedPage)
		bu:SetPoint("TOPRIGHT", -45, -45)
		bu:SetSize(35, 35)
		bu.Icon = bu:CreateTexture(nil, "ARTWORK")
		bu.Icon:SetAllPoints()
		bu.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		bu.Icon:SetTexture("Interface\\ICONS\\Ability_Iyyokuk_Calculate")
		bu:CreateBorder()
		bu:StyleButton()

		bu:SetScript("OnEnter", CalculateArches)
		bu:SetScript("OnLeave", K.HideTooltip)
	end

	local function MakeMoverArchaeology(event, addon)
		if addon == "Blizzard_ArchaeologyUI" then
			AddCalculateIcon()
			-- Repoint Bar
			ArcheologyDigsiteProgressBar.ignoreFramePositionManager = true
			ArcheologyDigsiteProgressBar:SetPoint("TOP", _G.UIParent, "TOP", 0, -400)
			K.CreateMoverFrame(ArcheologyDigsiteProgressBar)

			K:UnregisterEvent(event, MakeMoverArchaeology)
		end
	end
	K:RegisterEvent("ADDON_LOADED", MakeMoverArchaeology)

	local newTitleString = ARCHAEOLOGY_DIGSITE_PROGRESS_BAR_TITLE .. " - %s/%s"
	local function updateArcTitle(_, ...)
		local numFindsCompleted, totalFinds = ...
		if ArcheologyDigsiteProgressBar then
			ArcheologyDigsiteProgressBar.BarTitle:SetFormattedText(newTitleString, numFindsCompleted, totalFinds)
		end
	end
	K:RegisterEvent("ARCHAEOLOGY_SURVEY_CAST", updateArcTitle)
	K:RegisterEvent("ARCHAEOLOGY_FIND_COMPLETE", updateArcTitle)
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

-- Reanchor MawBuffsBelowMinimapFrame
function Module:MoveMawBuffsFrame()
	local frame = CreateFrame("Frame", "KKUI_MawBuffsMover", UIParent)
	frame:SetSize(235, 28)
	local mover = K.Mover(frame, MAW_POWER_DESCRIPTION, "MawBuffs", { "TOPRIGHT", UIParent, -80, -225 })
	frame:SetPoint("TOPLEFT", mover, 4, 12)

	hooksecurefunc(MawBuffsBelowMinimapFrame, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == MinimapCluster then
			self:ClearAllPoints()
			self:SetPoint("TOPRIGHT", frame)
		end
	end)
end

function Module:CreateJerryWay()
	if K.CheckAddOnState("TomTom") then
		return
	end

	local pointString = K.InfoColor .. "|Hworldmap:%d+:%d+:%d+|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a%s (%s, %s)]|h|r"

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

	SlashCmdList["KKUI_JERRY_WAY"] = function(msg)
		if not msg or msg == nil or msg == "" or msg == " " then
			K.Print(K.SystemColor .. "WARNING:|r Use a proper format for coords. Example: '/way 51.7, 65.2'")
			return
		end

		msg = gsub(msg, "(%d)[%.,] (%d)", "%1 %2")
		local x, y, z = string_match(msg, "(%S+)%s(%S+)(.*)")
		if x and y then
			local mapID = C_Map.GetBestMapForUnit("player")
			if mapID then
				local mapInfo = C_Map.GetMapInfo(mapID)
				local mapName = mapInfo and mapInfo.name
				if mapName then
					x = GetCorrectCoord(x)
					y = GetCorrectCoord(y)
					if x and y then
						K.Print(format(pointString, mapID, x * 100, y * 100, mapName, x, y, z or ""))
					end
				end
			end
		end
	end
	SLASH_KKUI_JERRY_WAY1 = "/way"
end

function Module:UpdateMaxCameraZoom()
	SetCVar("cameraDistanceMaxZoomFactor", C["Misc"].MaxCameraZoom)
end

local function AcknowledgeTips()
	for frame in _G.HelpTip.framePool:EnumerateActive() do
		frame:Acknowledge()
	end
end

function Module:DisableHelpTip() -- auto complete helptips
	if not C["General"].NoTutorialButtons then
		return
	end

	hooksecurefunc(_G.HelpTip, "Show", AcknowledgeTips)
	C_Timer.After(2, AcknowledgeTips)
end

-- Blizzard_NewPlayerExperience: ActionBars heavily conflicts with this
local function ShutdownNPE()
	local NPE = NewPlayerExperience
	if NPE and NPE:GetIsActive() then
		NPE:Shutdown()
	end

	return NPE
end

-- Blizzard_TutorialManager: sort of similar to NPE
local tutorialFrames = {
	"TutorialWalk_Frame",
	"TutorialSingleKey_Frame",
	"TutorialMainFrame_Frame",
	"TutorialKeyboardMouseFrame_Frame",
}

local function ShutdownTM()
	local TM = TutorialManager
	if TM and TM:GetIsActive() then
		TM:Shutdown()

		-- these aren't hidden by the shutdown
		for _, name in next, tutorialFrames do
			_G[name]:Kill()
		end
	end

	return TM
end

-- Blizzard_Tutorials: implemented kinda weird, imo tbh
local gameTutorials = {
	-- Blizzard_Tutorials_Professions
	"Class_ProfessionInventoryWatcher",
	"Class_ProfessionGearCheckingService",
	"Class_EquipProfessionGear",
	"Class_FirstProfessionWatcher",
	"Class_FirstProfessionTutorial",

	-- Blizzard_Tutorials_Dracthyr
	"Class_DracthyrEssenceWatcher",

	-- Blizzard_Tutorials_Classes
	"Class_StarterTalentWatcher",
	"Class_TalentPoints",
	"Class_ChangeSpec",
}

local GT_Shutdown = false
local function ShutdownGT()
	local GT = GameTutorials
	if GT and not GT_Shutdown then
		GT_Shutdown = true

		-- shut some down, they are running but not used
		for _, name in next, gameTutorials do
			_G[name]:Complete()
		end
	end

	return GT
end

-- this is the event handler for tutorials, maybe other stuff later?
-- it seems shutdown is not unregistering events for stuff so..
local function ShutdownTD() -- Blizzard_TutorialDispatcher
	local TD = Dispatcher
	if TD then
		wipe(TD.Events)
		wipe(TD.Scripts)
	end

	return TD
end

local function ShutdownTutorials(event)
	local NPE, GT, TM, TD = ShutdownNPE(), ShutdownGT(), ShutdownTM(), ShutdownTD()
	if NPE and GT and TM and TD then -- they exist unregister this
		K:UnregisterEvent(event)
	end
end

-- disable new player experience stuff
function Module:DisableTutorials()
	local NPE, GT, TM, TD = ShutdownNPE(), ShutdownGT(), ShutdownTM(), ShutdownTD()
	if not NPE or not GT or not TM or not TD then -- wait for them to exist
		K:RegisterEvent("ADDON_LOADED", ShutdownTutorials)
	end
end
