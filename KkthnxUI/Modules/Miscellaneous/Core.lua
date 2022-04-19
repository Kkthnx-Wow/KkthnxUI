local K, C, L = unpack(KkthnxUI)
local Module = K:NewModule("Miscellaneous")

local _G = _G
local select = _G.select
local string_match = _G.string.match
local tonumber = _G.tonumber

local C_BattleNet_GetGameAccountInfoByGUID = _G.C_BattleNet.GetGameAccountInfoByGUID
local C_FriendList_IsFriend = _G.C_FriendList.IsFriend
local C_QuestLog_GetSelectedQuest = _G.C_QuestLog.GetSelectedQuest
local C_QuestLog_ShouldShowQuestRewards = _G.C_QuestLog.ShouldShowQuestRewards
local C_Timer_After = _G.C_Timer.After
local CreateFrame = _G.CreateFrame
local FRIEND = _G.FRIEND
local GUILD = _G.GUILD
local GetItemInfo = _G.GetItemInfo
local GetItemQualityColor = _G.GetItemQualityColor
local GetMerchantItemLink = _G.GetMerchantItemLink
local GetMerchantItemMaxStack = _G.GetMerchantItemMaxStack
local GetQuestLogRewardXP = _G.GetQuestLogRewardXP
local GetRewardXP = _G.GetRewardXP
local GetSpellInfo = _G.GetSpellInfo
local InCombatLockdown = _G.InCombatLockdown
local IsAltKeyDown = _G.IsAltKeyDown
local IsGuildMember = _G.IsGuildMember
local NO = _G.NO
local PlaySound = _G.PlaySound
local StaticPopupDialogs = _G.StaticPopupDialogs
local StaticPopup_Show = _G.StaticPopup_Show
local UIParent = _G.UIParent
local UnitGUID = _G.UnitGUID
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax
local YES = _G.YES
local hooksecurefunc = _G.hooksecurefunc

local KKUI_MISC_LIST = {}

function Module:RegisterMisc(name, func)
	if not KKUI_MISC_LIST[name] then
		KKUI_MISC_LIST[name] = func
	end
end

function Module:OnEnable()
	for name, func in next, KKUI_MISC_LIST do
		if name and type(func) == "function" then
			func()
		end
	end

	self:CreateBlockStrangerInvites()
	self:CreateBossBanner()
	self:CreateBossEmote()
	self:CreateDisableHelpTip()
	self:CreateDisableNewPlayerExperience()
	self:CreateDomiExtractor()
	self:CreateDurabilityFrameMove()
	self:CreateErrorFrameToggle()
	self:CreateErrorsFrame()
	self:CreateGUIGameMenuButton()
	self:CreateJerryWay()
	self:CreateKillTutorials()
	self:CreateMawWidgetFrame()
	self:CreateQuestSizeUpdate()
	self:CreateTicketStatusFrameMove()
	self:CreateTradeTargetInfo()
	self:CreateVehicleSeatMover()
	self:MoveMawBuffsFrame()

	hooksecurefunc("QuestInfo_Display", Module.CreateQuestXPPercent)

	-- TESTING CMD : /run BNToastFrame:AddToast(BN_TOAST_TYPE_ONLINE, 1)
	if not BNToastFrame.mover then
		BNToastFrame.mover = K.Mover(BNToastFrame, "BNToastFrame", "BNToastFrame", { "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 4, 218 })
	else
		BNToastFrame.mover:SetSize(BNToastFrame:GetSize())
	end
	hooksecurefunc(BNToastFrame, "SetPoint", Module.PostBNToastMove)

	-- Unregister talent event
	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
		hooksecurefunc("TalentFrame_LoadUI", function()
			PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		end)
	end

	-- Auto chatBubbles
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

	-- Instant delete
	local deleteDialog = StaticPopupDialogs["DELETE_GOOD_ITEM"]
	if deleteDialog.OnShow then
		hooksecurefunc(deleteDialog, "OnShow", function(self)
			self.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
		end)
	end

	-- Fix blizz bug in addon list
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

	-- MicroButton Talent Alert
	local TalentMicroButtonAlert = _G.TalentMicroButtonAlert
	if TalentMicroButtonAlert then -- why do we need to check this?
		if C["General"].NoTutorialButtons then
			TalentMicroButtonAlert:Kill() -- Kill it, because then the blizz default will show
		end
	end
end

do
	-- Minimap button click function
	local function KKUI_MinimapButton_OnClick()
		-- Prevent options panel from showing if Blizzard options panel is showing
		if InterfaceOptionsFrame:IsShown() or VideoOptionsFrame:IsShown() or ChatConfigFrame:IsShown() then
			return
		end

		-- No modifier key toggles the options panel
		if InCombatLockdown() then
			UIErrorsFrame:AddMessage(K.InfoColor .. ERR_NOT_IN_COMBAT)
			return
		end

		K["GUI"]:Toggle()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
	end

	-- Create minimap button using LibDBIcon
	local KKUI_MinimapButton = K.DataBroker:NewDataObject("KkthnxUI", {
		type = "data source",
		text = "KkthnxUI",
		icon = "Interface\\ICONS\\Ability_Monk_CounteractMagic",
		OnClick = function()
			KKUI_MinimapButton_OnClick()
		end,

		OnTooltipShow = function(self)
			self:AddLine("KkthnxUI")
		end,
	})

	K.DBIcon:Register("KkthnxUI", KKUI_MinimapButton, KkthnxUIDB)

	-- Function to toggle LibDBIcon
	function Module:ToggleMinimapIcon()
		if C["General"].MinimapIcon then
			KkthnxUIDB.MinimapButton = true
			K.DBIcon:Show("KkthnxUI")
		else
			KkthnxUIDB.MinimapButton = false
			K.DBIcon:Hide("KkthnxUI")
		end
	end
end

local maxMawValue = 1000
local MawRankColor = {
	[0] = { 0.5, 0.7, 1 },
	[1] = { 0, 0.7, 0.3 },
	[2] = { 0, 1, 0 },
	[3] = { 1, 0.8, 0 },
	[4] = { 1, 0.5, 0 },
	[5] = { 1, 0, 0 },
}

function Module:CreateGUIGameMenuButton()
	local KKUI_GUIButton = CreateFrame("Button", "KKUI_GameMenuButton", GameMenuFrame, "GameMenuButtonTemplate, BackdropTemplate")
	KKUI_GUIButton:SetText(K.InfoColor .. "KkthnxUI|r")
	KKUI_GUIButton:SetPoint("TOP", GameMenuButtonAddons, "BOTTOM", 0, -21)
	KKUI_GUIButton:SkinButton()

	GameMenuFrame:HookScript("OnShow", function(self)
		_G.GameMenuButtonLogout:ClearAllPoints()
		_G.GameMenuButtonLogout:SetPoint("TOP", KKUI_GUIButton, "BOTTOM", 0, -21)

		_G.GameMenuButtonStore:ClearAllPoints()
		_G.GameMenuButtonStore:SetPoint("TOP", _G.GameMenuButtonHelp, "BOTTOM", 0, -6)

		_G.GameMenuButtonWhatsNew:ClearAllPoints()
		_G.GameMenuButtonWhatsNew:SetPoint("TOP", _G.GameMenuButtonStore, "BOTTOM", 0, -6)

		_G.GameMenuButtonUIOptions:ClearAllPoints()
		_G.GameMenuButtonUIOptions:SetPoint("TOP", _G.GameMenuButtonOptions, "BOTTOM", 0, -6)

		_G.GameMenuButtonKeybindings:ClearAllPoints()
		_G.GameMenuButtonKeybindings:SetPoint("TOP", _G.GameMenuButtonUIOptions, "BOTTOM", 0, -6)

		_G.GameMenuButtonMacros:ClearAllPoints()
		_G.GameMenuButtonMacros:SetPoint("TOP", _G.GameMenuButtonKeybindings, "BOTTOM", 0, -6)

		_G.GameMenuButtonAddons:ClearAllPoints()
		_G.GameMenuButtonAddons:SetPoint("TOP", _G.GameMenuButtonMacros, "BOTTOM", 0, -6)

		_G.GameMenuButtonQuit:ClearAllPoints()
		_G.GameMenuButtonQuit:SetPoint("TOP", _G.GameMenuButtonLogout, "BOTTOM", 0, -6)

		self:SetHeight(self:GetHeight() + KKUI_GUIButton:GetHeight() + 63) -- 6 x 7 + 21?
	end)

	KKUI_GUIButton:SetScript("OnClick", function()
		if InCombatLockdown() then
			UIErrorsFrame:AddMessage(K.InfoColor .. ERR_NOT_IN_COMBAT)
			return
		end

		K["GUI"]:Toggle()
		HideUIPanel(GameMenuFrame)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
	end)
end

function Module:CreateQuestXPPercent()
	local unitXP, unitXPMax = UnitXP("player"), UnitXPMax("player")
	if _G.QuestInfoFrame.questLog then
		local selectedQuest = C_QuestLog_GetSelectedQuest()
		if C_QuestLog_ShouldShowQuestRewards(selectedQuest) then
			local xp = GetQuestLogRewardXP()
			if xp and xp > 0 then
				local text = _G.MapQuestInfoRewardsFrame.XPFrame.Name:GetText()
				if text then
					_G.MapQuestInfoRewardsFrame.XPFrame.Name:SetFormattedText("%s (|cff4beb2c+%.2f%%|r)", text, (((unitXP + xp) / unitXPMax) - (unitXP / unitXPMax)) * 100)
				end
			end
		end
	else
		local xp = GetRewardXP()
		if xp and xp > 0 then
			local text = _G.QuestInfoXPFrame.ValueText:GetText()
			if text then
				_G.QuestInfoXPFrame.ValueText:SetFormattedText("%s (|cff4beb2c+%.2f%%|r)", text, (((unitXP + xp) / unitXPMax) - (unitXP / unitXPMax)) * 100)
			end
		end
	end
end

-- Reanchor Vehicle
function Module:CreateVehicleSeatMover()
	local frame = CreateFrame("Frame", "KKUI_VehicleSeatMover", UIParent)
	frame:SetSize(125, 125)
	K.Mover(frame, "VehicleSeat", "VehicleSeat", { "BOTTOM", UIParent, -364, 4 })

	hooksecurefunc(VehicleSeatIndicator, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == MinimapCluster then
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
	QuestTitleFont:SetFont(QuestFont:GetFont(), C["UIFonts"].QuestFontSize + 3, nil)
	QuestFont:SetFont(QuestFont:GetFont(), C["UIFonts"].QuestFontSize + 1, nil)
	QuestFontNormalSmall:SetFont(QuestFontNormalSmall:GetFont(), C["UIFonts"].QuestFontSize, nil)
end

function Module:CreateErrorsFrame()
	local Font = K.GetFont(C["UIFonts"].GeneralFonts)
	local Path, _, Flag = _G[Font]:GetFont()

	UIErrorsFrame:SetFont(Path, 15, Flag)
	UIErrorsFrame:ClearAllPoints()
	UIErrorsFrame:SetPoint("TOP", 0, -200)

	K.Mover(UIErrorsFrame, "UIErrorsFrame", "UIErrorsFrame", { "TOP", 0, -200 })
end

-- TradeFrame hook
function Module:CreateTradeTargetInfo()
	local infoText = K.CreateFontString(TradeFrame, 16, "", "")
	infoText:ClearAllPoints()
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
	hooksecurefunc("TradeFrame_Update", updateColor)
end

-- Maw widget frame
local function GetMawBarValue()
	local widgetInfo = C_UIWidgetManager.GetDiscreteProgressStepsVisualizationInfo(2885)
	if widgetInfo and widgetInfo.shownState == 1 then
		local value = widgetInfo.progressVal
		return floor(value / maxMawValue), value % maxMawValue
	end
end

function Module:UpdateMawBarLayout()
	local bar = Module.mawbar
	local rank, value = GetMawBarValue()
	if rank then
		bar:SetStatusBarColor(unpack(MawRankColor[rank]))
		if rank == 5 then
			bar.text:SetText("Lv" .. rank)
			bar:SetValue(maxMawValue)
		else
			bar.text:SetText("Lv" .. rank .. " - " .. value .. "/" .. maxMawValue)
			bar:SetValue(value)
		end
		bar:Show()
		UIWidgetTopCenterContainerFrame:Hide()
	else
		bar:Hide()
		UIWidgetTopCenterContainerFrame:Show()
	end
end

function Module:CreateMawWidgetFrame()
	if not C["Misc"].MawThreatBar then
		return
	end

	if Module.mawbar then
		return
	end

	local bar = CreateFrame("StatusBar", nil, UIParent)
	bar:SetPoint("TOP", 0, -50)
	bar:SetSize(200, 16)
	bar:SetMinMaxValues(0, maxMawValue)
	bar.text = K.CreateFontString(bar, 12)
	bar:SetStatusBarTexture(C["Media"].Statusbars.KkthnxUIStatusbar)
	bar:CreateBorder()
	K:SmoothBar(bar)

	bar.spark = bar:CreateTexture(nil, "OVERLAY")
	bar.spark:SetTexture(C["Media"].Textures.Spark16Texture)
	bar.spark:SetHeight(14)
	bar.spark:SetBlendMode("ADD")
	bar.spark:SetPoint("CENTER", bar:GetStatusBarTexture(), "RIGHT", 0, 0)

	Module.mawbar = bar

	K.Mover(bar, "MawThreatBar", "MawThreatBar", { "TOP", UIParent, 0, -50 })

	bar:SetScript("OnEnter", function(self)
		local rank = GetMawBarValue()
		local widgetInfo = rank and C_UIWidgetManager.GetTextureWithAnimationVisualizationInfo(2873 + rank)
		if widgetInfo and widgetInfo.shownState == 1 then
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -10)
			local header, nonHeader = SplitTextIntoHeaderAndNonHeader(widgetInfo.tooltip)
			if header then
				GameTooltip:AddLine(header, nil, nil, nil, 1)
			end

			if nonHeader then
				GameTooltip:AddLine(nonHeader, nil, nil, nil, 1)
			end
			GameTooltip:Show()
		end
	end)
	bar:SetScript("OnLeave", K.HideTooltip)

	Module:UpdateMawBarLayout()
	K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.UpdateMawBarLayout)
	K:RegisterEvent("UPDATE_UI_WIDGET", Module.UpdateMawBarLayout)
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
		bu.Icon:SetTexCoord(unpack(K.TexCoords))
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
	local function setupMisc(event, addon)
		if event == "ADDON_LOADED" and addon == "Blizzard_Collections" then
			CollectionsJournal:HookScript("OnShow", function()
				if not done then
					if InCombatLockdown() then
						K:RegisterEvent("PLAYER_REGEN_ENABLED", setupMisc)
					else
						K.CreateMoverFrame(CollectionsJournal)
					end
					done = true
				end
			end)
			K:UnregisterEvent(event, setupMisc)
		elseif event == "PLAYER_REGEN_ENABLED" then
			K.CreateMoverFrame(CollectionsJournal)
			K:UnregisterEvent(event, setupMisc)
		end
	end

	-- K:RegisterEvent("ADDON_LOADED", setupMisc)
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

	local function setupMisc(event, addon)
		if event == "ADDON_LOADED" and addon == "Blizzard_RaidUI" then
			if not InCombatLockdown() then
				fixRaidGroupButton()
			else
				K:RegisterEvent("PLAYER_REGEN_ENABLED", setupMisc)
			end
			K:UnregisterEvent(event, setupMisc)
		elseif event == "PLAYER_REGEN_ENABLED" then
			if RaidGroupButton1 and RaidGroupButton1:GetAttribute("type") ~= "target" then
				fixRaidGroupButton()
				K:UnregisterEvent(event, setupMisc)
			end
		end
	end

	K:RegisterEvent("ADDON_LOADED", setupMisc)
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

	local function fixCommunitiesNews(event, addon)
		if addon ~= "Blizzard_Communities" then
			return
		end

		local _CommunitiesGuildNewsButton_OnEnter = CommunitiesGuildNewsButton_OnEnter
		function CommunitiesGuildNewsButton_OnEnter(self)
			if not (self.newsInfo and self.newsInfo.whatText) then
				return
			end
			_CommunitiesGuildNewsButton_OnEnter(self)
		end

		K:UnregisterEvent(event, fixCommunitiesNews)
	end

	K:RegisterEvent("ADDON_LOADED", fixGuildNews)
	K:RegisterEvent("ADDON_LOADED", fixCommunitiesNews)
end

hooksecurefunc("ChatEdit_InsertLink", function(text) -- shift-clicked
	-- change from SearchBox:HasFocus to :IsShown again
	if text and TradeSkillFrame and TradeSkillFrame:IsShown() then
		local spellId = string_match(text, "enchant:(%d+)")
		local spell = GetSpellInfo(spellId)
		local item = GetItemInfo(string_match(text, "item:(%d+)") or 0)
		local search = spell or item
		if not search then
			return
		end

		-- search needs to be lowercase for .SetRecipeItemNameFilter
		TradeSkillFrame.SearchBox:SetText(search)

		-- jump to the recipe
		if spell then -- can only select recipes on the learned tab
			if PanelTemplates_GetSelectedTab(TradeSkillFrame.RecipeList) == 1 then
				TradeSkillFrame:SelectRecipe(tonumber(spellId))
			end
		elseif item then
			C_Timer_After(0.1, function() -- wait a bit or we cant select the recipe yet
				for _, v in pairs(TradeSkillFrame.RecipeList.dataList) do
					if v.name == item then
						-- TradeSkillFrame.RecipeList:RefreshDisplay() -- didnt seem to help
						TradeSkillFrame:SelectRecipe(v.recipeID)
						return
					end
				end
			end)
		end
	end
end)

-- make it only split stacks with shift-rightclick if the TradeSkillFrame is open
-- shift-leftclick should be reserved for the search box
local function hideSplitFrame(_, button)
	if TradeSkillFrame and TradeSkillFrame:IsShown() then
		if button == "LeftButton" then
			StackSplitFrame:Hide()
		end
	end
end
hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", hideSplitFrame)
hooksecurefunc("MerchantItemButton_OnModifiedClick", hideSplitFrame)

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

function Module:CreateKillTutorials()
	if not C["General"].NoTutorialButtons then
		return
	end

	_G.HelpPlate:Kill()
	_G.HelpPlateTooltip:Kill()
	_G.SpellBookFrameTutorialButton:Kill()
	_G.WorldMapFrame.BorderFrame.Tutorial:Kill()
end

local function AcknowledgeTips()
	for frame in _G.HelpTip.framePool:EnumerateActive() do
		frame:Acknowledge()
	end
end

function Module:CreateDisableHelpTip() -- auto complete helptips
	if not C["General"].NoTutorialButtons then
		return
	end

	hooksecurefunc(_G.HelpTip, "Show", AcknowledgeTips)
	C_Timer_After(1, AcknowledgeTips)
end

local function ShutdownNewPlayerExperience(event)
	local NPE = _G.NewPlayerExperience
	if NPE then
		if NPE:GetIsActive() then
			NPE:Shutdown()
		end

		if event then
			K:UnregisterEvent(event, ShutdownNewPlayerExperience)
		end
	end
end

function Module:CreateDisableNewPlayerExperience() -- Disable new player experience
	if _G.NewPlayerExperience then
		ShutdownNewPlayerExperience()
	else
		K:RegisterEvent("ADDON_LOADED", ShutdownNewPlayerExperience)
	end
end

-- Make it so we can move this
function Module:PostBNToastMove(_, anchor)
	if anchor ~= _G.BNToastFrame.mover then
		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", _G.BNToastFrame.mover, "TOPLEFT")
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

function Module:CreateDomiExtractor()
	local EXTRACTOR_ID = 187532
	local Module_Tooltip = K:GetModule("Tooltip")

	local function TryOnShard(self)
		if not self.itemLink then
			return
		end

		PickupContainerItem(self.bagID, self.slotID)
		ClickSocketButton(1)
		ClearCursor()
	end

	local function ShowShardTooltip(self)
		if not self.itemLink then
			return
		end

		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
		GameTooltip:SetHyperlink(self.itemLink)
		GameTooltip:Show()
	end

	local foundShards = {}
	local function RefreshShardsList()
		wipe(foundShards)

		for bagID = 0, 4 do
			for slotID = 1, GetContainerNumSlots(bagID) do
				local _, _, _, _, _, _, itemLink, _, _, itemID = GetContainerItemInfo(bagID, slotID)
				local rank = itemID and Module_Tooltip.DomiRankData[itemID]
				if rank then
					local index = Module_Tooltip.DomiIndexData[itemID]
					if not index then
						break
					end

					local button = Module.DomiShardsFrame.icons[index]
					button.bagID = bagID
					button.slotID = slotID
					button.itemLink = itemLink
					button.count:SetText(rank)
					button.Icon:SetDesaturated(false)

					foundShards[index] = true
				end
			end
		end

		for index, button in pairs(Module.DomiShardsFrame.icons) do
			if not foundShards[index] then
				button.itemLink = nil
				button.count:SetText("")
				button.Icon:SetDesaturated(true)
			end
		end
	end

	local function CreateDomiShards()
		local frame = CreateFrame("Frame", "KKUI_DomiShards", ItemSocketingFrame)
		frame:SetSize(96, 96)
		frame:SetPoint("RIGHT", -36, 36)
		frame.icons = {}

		Module.DomiShardsFrame = frame

		for index, value in pairs(Module_Tooltip.DomiDataByGroup) do
			for itemID in pairs(value) do
				local button = CreateFrame("Button", nil, frame)
				button:SetSize(26, 26)
				button:SetPoint("TOPLEFT", 3 + mod(index - 1, 3) * 32, -3 - floor((index - 1) / 3) * 32)

				button.Icon = button:CreateTexture(nil, "ARTWORK")
				button.Icon:SetTexture(GetItemIcon(itemID))
				button.Icon:SetAllPoints()
				button.Icon:SetTexCoord(unpack(K.TexCoords))

				button:CreateBorder()

				button:SetScript("OnClick", TryOnShard)
				button:SetScript("OnLeave", K.HideTooltip)
				button:SetScript("OnEnter", ShowShardTooltip)

				button.count = K.CreateFontString(button, 12, "", "OUTLINE", "system", "BOTTOMRIGHT", 0, -0)

				frame.icons[index] = button
				break
			end
		end

		RefreshShardsList()
		K:RegisterEvent("BAG_UPDATE", RefreshShardsList)
	end

	local function CreateExtractButton()
		if not ItemSocketingFrame then
			return
		end

		if Module.DomiExtButton then
			return
		end

		if GetItemCount(EXTRACTOR_ID) == 0 then
			return
		end

		ItemSocketingSocketButton:SetWidth(80)

		if InCombatLockdown() then
			return
		end

		local button = CreateFrame("Button", "KKUI_ExtractorButton", ItemSocketingFrame, "UIPanelButtonTemplate, SecureActionButtonTemplate")
		button:SetSize(80, 22)
		button:SetText(REMOVE)
		button:SetPoint("RIGHT", ItemSocketingSocketButton, "LEFT", -2, 0)
		button:SetAttribute("type", "macro")
		button:SetAttribute("macrotext", "/use item:" .. EXTRACTOR_ID .. "\n/click ItemSocketingSocket1")

		CreateDomiShards()

		Module.DomiExtButton = button
	end

	hooksecurefunc("ItemSocketingFrame_LoadUI", function()
		CreateExtractButton()

		if Module.DomiExtButton then
			Module.DomiExtButton:SetAlpha(GetSocketTypes(1) == "Domination" and GetExistingSocketInfo(1) and 1 or 0)
		end

		if Module.DomiShardsFrame then
			Module.DomiShardsFrame:SetShown(GetSocketTypes(1) == "Domination" and not GetExistingSocketInfo(1))
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

do -- Firestorm has a bug where UI_ERROR_MESSAGES that should trigger a dismount DO NOT trigger a dismount so it is basically acting like Classic Wow.
	local dismountStrings = {
		[SPELL_FAILED_NOT_MOUNTED] = true,
	}

	local function FixFSAutoDismount(_, _, msg)
		if K.Realm ~= "Oribos" then
			return
		end

		if dismountStrings[msg] then -- There could be other ones FS has issues with but we will only apply the ones we run into.
			if IsMounted() then
				Dismount()
				UIErrorsFrame:Clear()
			end
		end
	end
	K:RegisterEvent("UI_ERROR_MESSAGE", FixFSAutoDismount)
end
