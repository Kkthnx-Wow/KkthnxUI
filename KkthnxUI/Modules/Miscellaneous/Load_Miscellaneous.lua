local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Miscellaneous")

local _G = _G
local math_min = _G.math.min
local math_floor = _G.math.floor

local BNGetGameAccountInfoByGUID = _G.BNGetGameAccountInfoByGUID
local CreateFrame = _G.CreateFrame
local FRIEND = _G.FRIEND
local GUILD = _G.GUILD
local GetCVar = _G.GetCVar
local GetItemInfo = _G.GetItemInfo
local GetItemQualityColor = _G.GetItemQualityColor
local GetMerchantItemLink = _G.GetMerchantItemLink
local GetMerchantItemMaxStack = _G.GetMerchantItemMaxStack
local GetNetStats = _G.GetNetStats
local GetNumSavedInstances = _G.GetNumSavedInstances
local GetSavedInstanceInfo = _G.GetSavedInstanceInfo
local GetScreenHeight = _G.GetScreenHeight
local GetScreenWidth = _G.GetScreenWidth
local GetSpellTexture = _G.GetSpellTexture
local InCombatLockdown = _G.InCombatLockdown
local IsAltKeyDown = _G.IsAltKeyDown
local IsCharacterFriend = _G.IsCharacterFriend
local IsGuildMember = _G.IsGuildMember
local NO = _G.NO
local PVPReadyDialog = _G.PVPReadyDialog
local SetCVar = _G.SetCVar
local StaticPopupDialogs = _G.StaticPopupDialogs
local StaticPopup_Show = _G.StaticPopup_Show
local UIParent = _G.UIParent
local UnitGUID = _G.UnitGUID
local YES = _G.YES
local hooksecurefunc = _G.hooksecurefunc
local GetNumAuctionItems = _G.GetNumAuctionItems
local SlashCmdList = _G.SlashCmdList

do
	local AutoSpellQueueTolerance = CreateFrame("Frame", "KkthnxUI_AutoLagTolerance")
	AutoSpellQueueTolerance.cache = GetCVar("SpellQueueWindow")
	AutoSpellQueueTolerance.timer = 0
	local function AutoSpellQueueTolerance_OnUpdate(self, elapsed)
		self.timer = self.timer + elapsed
		if self.timer < 1.0 then
			return
		end

		self.timer = 0

		local latency = math_min(400, select(4, GetNetStats()))

		if latency == 0 then
			return
		end

		if latency == self.cache then
			return
		end

		SetCVar("SpellQueueWindow", latency)
		-- K.Print("SpellQueueWindow has been updated to "..latency) -- DEBUG

		self.cache = latency
	end

	if C["General"].LagTolerance then
		AutoSpellQueueTolerance:SetScript("OnUpdate", AutoSpellQueueTolerance_OnUpdate)
	end
end

-- Repoint Vehicle
function Module:CreateVehicleSeatMover()
	local frame = CreateFrame("Frame", "KkthnxUIVehicleSeatMover", UIParent)
	frame:SetSize(120, 120)
	K.Mover(frame, "VehicleSeat", "VehicleSeat", {"BOTTOM", UIParent, -364, 4})

	hooksecurefunc(_G.VehicleSeatIndicator, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == _G.MinimapCluster then
			self:ClearAllPoints()
			self:SetPoint("CENTER", frame)
			self:SetScale(0.9)
		end
	end)
end

-- Grids
do
	local grid
	local boxSize = 32
	local function Grid_Create()
		grid = CreateFrame("Frame", nil, UIParent)
		grid.boxSize = boxSize
		grid:SetAllPoints(UIParent)

		local size = 2
		local width = GetScreenWidth()
		local ratio = width / GetScreenHeight()
		local height = GetScreenHeight() * ratio

		local wStep = width / boxSize
		local hStep = height / boxSize

		for i = 0, boxSize do
			local tx = grid:CreateTexture(nil, "BACKGROUND")
			if i == boxSize / 2 then
				tx:SetColorTexture(1, 0, 0, .5)
			else
				tx:SetColorTexture(0, 0, 0, .5)
			end
			tx:SetPoint("TOPLEFT", grid, "TOPLEFT", i*wStep - (size/2), 0)
			tx:SetPoint("BOTTOMRIGHT", grid, "BOTTOMLEFT", i*wStep + (size/2), 0)
		end
		height = GetScreenHeight()

		do
			local tx = grid:CreateTexture(nil, "BACKGROUND")
			tx:SetColorTexture(1, 0, 0, .5)
			tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height/2) + (size/2))
			tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height/2 + size/2))
		end

		for i = 1, math_floor((height/2)/hStep) do
			local tx = grid:CreateTexture(nil, "BACKGROUND")
			tx:SetColorTexture(0, 0, 0, .5)

			tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height/2+i*hStep) + (size/2))
			tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height/2+i*hStep + size/2))

			tx = grid:CreateTexture(nil, "BACKGROUND")
			tx:SetColorTexture(0, 0, 0, .5)

			tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height/2-i*hStep) + (size/2))
			tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height/2-i*hStep + size/2))
		end
	end

	local function Grid_Show()
		if not grid then
			Grid_Create()
		elseif grid.boxSize ~= boxSize then
			grid:Hide()
			Grid_Create()
		else
			grid:Show()
		end
	end

	local isAligning = false
	SlashCmdList["KKUI_TOGGLEGRID"] = function(arg)
		if isAligning or arg == "1" then
			if grid then grid:Hide() end
			isAligning = false
		else
			boxSize = (math.ceil((tonumber(arg) or boxSize) / 32) * 32)
			if boxSize > 256 then boxSize = 256 end
			Grid_Show()
			isAligning = true
		end
	end

	SLASH_KKUI_TOGGLEGRID1 = "/showgrid"
	SLASH_KKUI_TOGGLEGRID2 = "/align"
	SLASH_KKUI_TOGGLEGRID3 = "/grid"
end

-- Get Naked
function Module:CreateNakedButtons()
	-- Add Buttons To Main Dressup Frames
	local DressUpNudeBtn = CreateFrame("Button", "Nude", DressUpFrame, "UIPanelButtonTemplate")
	DressUpNudeBtn:SetPoint("BOTTOMLEFT", 106, 79)
	DressUpNudeBtn:SetSize(80, 22)
	DressUpNudeBtn:SetText("Nude")
	DressUpNudeBtn:ClearAllPoints()
	DressUpNudeBtn:SetPoint("RIGHT", DressUpFrameResetButton, "LEFT", 0, 0)
	DressUpNudeBtn:SetScript("OnClick", function()
		SetupPlayerForModelScene(DressUpFrame.ModelScene, {}, false, false)
	end)

	local DressUpTabBtn = CreateFrame("Button", "Tabard", DressUpFrame, "UIPanelButtonTemplate")
	DressUpTabBtn:SetPoint("BOTTOMLEFT", 26, 79)
	DressUpTabBtn:SetSize(80, 22)
	DressUpTabBtn:SetText("Tabard")
	DressUpTabBtn:ClearAllPoints()
	DressUpTabBtn:SetPoint("RIGHT", DressUpNudeBtn, "LEFT", 0, 0)
	DressUpTabBtn:SetScript("OnClick", function()
		-- Store all appearance sources in table
		local appearanceSources = {}
		local playerActor = DressUpFrame.ModelScene:GetPlayerActor()
		for slotID = 1, 19 do
			local appearanceSourceID, illusionSourceID = playerActor:GetSlotTransmogSources(slotID)
			table.insert(appearanceSources, appearanceSourceID)
		end
		-- Strip model
		SetupPlayerForModelScene(DressUpFrame.ModelScene, {}, false, false)
		-- Apply all appearance sources except tabard slot (19)
		for slotID = 1, 18 do
			if appearanceSources[slotID] and appearanceSources[slotID] > 0 then
				playerActor:TryOn(appearanceSources[slotID])
			end
		end
	end)

	-- Only Show Dressup Buttons If Its A Player (Reset Button Will Show Too)
	hooksecurefunc(DressUpFrameResetButton, "Show", function()
		DressUpNudeBtn:Show()
		DressUpTabBtn:Show()
	end)

	hooksecurefunc(DressUpFrameResetButton, "Hide", function()
		DressUpNudeBtn:Hide()
		DressUpTabBtn:Hide()
	end)

	-- Add Buttons To Auction House Dressup Frame
	local DressUpSideBtn = CreateFrame("Button", "Tabard", SideDressUpFrame, "UIPanelButtonTemplate")
	DressUpSideBtn:SetPoint("BOTTOMLEFT", 14, 40)
	DressUpSideBtn:SetSize(60, 22)
	DressUpSideBtn:SetText("Tabard")
	DressUpSideBtn:SetFrameLevel(4)
	DressUpSideBtn:SetFrameStrata("HIGH")
	DressUpSideBtn:SetScript("OnClick", function()
		-- Store all appearance sources in table
		local appearanceSources = {}
		local playerActor = SideDressUpFrame.ModelScene:GetPlayerActor()
		for slotID = 1, 19 do
			local appearanceSourceID, illusionSourceID = playerActor:GetSlotTransmogSources(slotID)
			table.insert(appearanceSources, appearanceSourceID)
		end
		-- Strip model
		SetupPlayerForModelScene(SideDressUpFrame.ModelScene, {}, false, false)
		-- Apply all appearance sources except tabard slot (19)
		for slotID = 1, 18 do
			if appearanceSources[slotID] and appearanceSources[slotID] > 0 then
				playerActor:TryOn(appearanceSources[slotID])
			end
		end
	end)

	local DressUpSideNudeBtn = CreateFrame("Button", "Nude", SideDressUpFrame, "UIPanelButtonTemplate")
	DressUpSideNudeBtn:SetPoint("BOTTOMRIGHT", -18, 40)
	DressUpSideNudeBtn:SetSize(60, 22)
	DressUpSideNudeBtn:SetText("Nude")
	DressUpSideNudeBtn:SetFrameLevel(4)
	DressUpSideNudeBtn:SetFrameStrata("HIGH")
	DressUpSideNudeBtn:SetScript("OnClick", function()
		-- Strip model
		SetupPlayerForModelScene(SideDressUpFrame.ModelScene, {}, false, false)
	end)

	-- Only show side dressup buttons if its a player (reset button will show too)
	hooksecurefunc(SideDressUpFrame.ResetButton, "Show", function()
		DressUpSideBtn:Show()
		DressUpSideNudeBtn:Show()
	end)

	hooksecurefunc(SideDressUpFrame.ResetButton, "Hide", function()
		DressUpSideBtn:Hide()
		DressUpSideNudeBtn:Hide()
	end)

	-- Wardrobe (Used By Transmogrifier Npc)
	local function DoBlizzardCollectionsFunc()
		-- Hide Positioning Controls
		WardrobeTransmogFrameControlFrame:HookScript("OnShow", WardrobeTransmogFrameControlFrame.Hide)
		-- Disable Special Animations
		hooksecurefunc(WardrobeTransmogFrame.Model, "SetUnit", function()
			WardrobeTransmogFrame.Model:SetAnimation(255)
		end)
	end

	if IsAddOnLoaded("Blizzard_Collections") then
		DoBlizzardCollectionsFunc()
	else
		local waitCollectionsFrame = CreateFrame("FRAME")
		waitCollectionsFrame:RegisterEvent("ADDON_LOADED")
		waitCollectionsFrame:SetScript("OnEvent", function(_, _, arg1)
			if arg1 == "Blizzard_Collections" then
				DoBlizzardCollectionsFunc()
				waitCollectionsFrame:UnregisterAllEvents()
			end
		end)
	end

	-- Inspect System
	local function DoInspectSystemFunc()
		-- Hide Positioning Controls
		InspectModelFrameControlFrame:HookScript("OnShow", InspectModelFrameControlFrame.Hide)
	end

	if IsAddOnLoaded("Blizzard_InspectUI") then
		DoInspectSystemFunc()
	else
		local waitInspectFrame = CreateFrame("FRAME")
		waitInspectFrame:RegisterEvent("ADDON_LOADED")
		waitInspectFrame:SetScript("OnEvent", function(_, _, arg1)
			if arg1 == "Blizzard_InspectUI" then
				DoInspectSystemFunc()
				waitInspectFrame:UnregisterAllEvents()
			end
		end)
	end
end

-- Extend Instance
function Module:CreateExtendInstance()
	local bu = CreateFrame("Button", nil, _G.RaidInfoFrame)
	bu:SetPoint("TOPLEFT", 10, -10)
	bu:SetSize(18, 18)
	bu:CreateBorder()

	bu.Icon = bu:CreateTexture(nil, "ARTWORK")
	bu.Icon:SetPoint("TOPLEFT", 1, -1)
	bu.Icon:SetPoint("BOTTOMRIGHT", -1, 1)
	bu.Icon:SetTexCoord(unpack(K.TexCoords))

	local atlas = string.match(GetSpellTexture(80353), "Atlas:(.+)$")
	if atlas then
		bu.Icon:SetAtlas(atlas)
	else
		bu.Icon:SetTexture(GetSpellTexture(80353))
	end
	K.AddTooltip(bu, "ANCHOR_RIGHT", "Extend Instance", "system")

	bu:SetScript("OnMouseUp", function(_, btn)
		for i = 1, GetNumSavedInstances() do
			local _, _, _, _, _, extended, _, isRaid = GetSavedInstanceInfo(i)
			if isRaid then
				if btn == "LeftButton" then
					if not extended then
						_G.SetSavedInstanceExtend(i, true)		-- extend
					end
				else
					if extended then
						_G.SetSavedInstanceExtend(i, false)	-- cancel
					end
				end
			end
		end
		_G.RequestRaidInfo()
		_G.RaidInfoFrame_Update()
	end)
end

-- TradeFrame hook
function Module:CreateTradeTargetInfo()
	local infoText = _G.TradeFrame:CreateFontString(nil, "OVERLAY")
	infoText:SetFont(C["Media"].Font, 14, "")
	infoText:SetShadowOffset(1.25, -1.25)
	infoText:SetWordWrap(false)
	infoText:ClearAllPoints()
	infoText:SetPoint("TOP", _G.TradeFrameRecipientNameText, "BOTTOM", 0, -8)

	local function updateColor()
		local r, g, b = K.UnitColor("NPC")
		_G.TradeFrameRecipientNameText:SetTextColor(r, g, b)

		local guid = UnitGUID("NPC")
		if not guid then return end
		local text = "|cffff0000"..L["Stranger"]
		if BNGetGameAccountInfoByGUID(guid) or IsCharacterFriend(guid) then
			text = "|cffffff00"..FRIEND
		elseif IsGuildMember(guid) then
			text = "|cff00ff00"..GUILD
		end
		infoText:SetText(text)
	end
	hooksecurefunc("TradeFrame_Update", updateColor)
end

-- ALT+RightClick to buy a stack
do
	local cache = {}
	local itemLink, id

	StaticPopupDialogs["BUY_STACK"] = {
		text = "Stack Buying Check",
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			if not itemLink then return end
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
			if not itemLink then return end
			local name, _, quality, _, _, _, _, maxStack, _, texture = GetItemInfo(itemLink)
			if maxStack and maxStack > 1 then
				if not cache[itemLink] then
					local r, g, b = GetItemQualityColor(quality or 1)
					StaticPopup_Show("BUY_STACK", " ", " ", {["texture"] = texture, ["name"] = name, ["color"] = {r, g, b, 1}, ["link"] = itemLink, ["index"] = id, ["count"] = maxStack})
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
			_G.CollectionsJournal:HookScript("OnShow", function()
				if not done then
					if InCombatLockdown() then
						K:RegisterEvent("PLAYER_REGEN_ENABLED", setupMisc)
					else
						K.CreateMoverFrame(_G.CollectionsJournal)
					end
					done = true
				end
			end)
			K:UnregisterEvent(event, setupMisc)
		elseif event == "PLAYER_REGEN_ENABLED" then
			K.CreateMoverFrame(_G.CollectionsJournal)
			K:UnregisterEvent(event, setupMisc)
		end
	end

	K:RegisterEvent("ADDON_LOADED", setupMisc)
end

-- Temporary taint fix
do
	InterfaceOptionsFrameCancel:SetScript("OnClick", function()
		InterfaceOptionsFrameOkay:Click()
	end)

	-- https://www.townlong-yak.com/bugs/Kjq4hm-DisplayModeCommunitiesTaint
	if (UIDROPDOWNMENU_OPEN_PATCH_VERSION or 0) < 1 then
		UIDROPDOWNMENU_OPEN_PATCH_VERSION = 1
		hooksecurefunc("UIDropDownMenu_InitializeHelper", function(frame)
			if UIDROPDOWNMENU_OPEN_PATCH_VERSION ~= 1 then return end

			if UIDROPDOWNMENU_OPEN_MENU and UIDROPDOWNMENU_OPEN_MENU ~= frame and not issecurevariable(UIDROPDOWNMENU_OPEN_MENU, "displayMode") then
				UIDROPDOWNMENU_OPEN_MENU = nil
				local t, f, prefix, i = _G, issecurevariable, " \0", 1
				repeat
					i, t[prefix .. i] = i+1
				until f("UIDROPDOWNMENU_OPEN_MENU")
			end
		end)
	end

	-- https://www.townlong-yak.com/bugs/YhgQma-SetValueRefreshTaint
	if (COMMUNITY_UIDD_REFRESH_PATCH_VERSION or 0) < 1 then
		COMMUNITY_UIDD_REFRESH_PATCH_VERSION = 1
		local function CleanDropdowns()
			if COMMUNITY_UIDD_REFRESH_PATCH_VERSION ~= 1 then
				return
			end
			local f, f2 = FriendsFrame, FriendsTabHeader
			local s = f:IsShown()
			f:Hide()
			f:Show()
			if not f2:IsShown() then
				f2:Show()
				f2:Hide()
			end
			if not s then
				f:Hide()
			end
		end
		hooksecurefunc("Communities_LoadUI", CleanDropdowns)
		hooksecurefunc("SetCVar", function(n)
			if n == "lastSelectedClubId" then
				CleanDropdowns()
			end
		end)
	end

	-- https://www.townlong-yak.com/bugs/Mx7CWN-RefreshOverread
	if (UIDD_REFRESH_OVERREAD_PATCH_VERSION or 0) < 1 then
		UIDD_REFRESH_OVERREAD_PATCH_VERSION = 1
		local function drop(t, k)
			local c = 42
			t[k] = nil
			while not issecurevariable(t, k) do
				if t[c] == nil then
					t[c] = nil
				end
				c = c + 1
			end
		end
		hooksecurefunc("UIDropDownMenu_InitializeHelper", function()
			if UIDD_REFRESH_OVERREAD_PATCH_VERSION ~= 1 then
				return
			end
			for i = 1, UIDROPDOWNMENU_MAXLEVELS do
				local d = _G["DropDownList"..i]
				if d and d.numButtons then
					for j = d.numButtons+1, UIDROPDOWNMENU_MAXBUTTONS do
						local b, _ = _G["DropDownList"..i.."Button"..j]
						_ = issecurevariable(b, "checked") or drop(b, "checked")
						_ = issecurevariable(b, "notCheckable") or drop(b, "notCheckable")
					end
				end
			end
		end)
	end
end

-- Select target when click on raid units
do
	local function fixRaidGroupButton()
		for i = 1, 40 do
			local bu = _G["RaidGroupButton"..i]
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
			if _G.RaidGroupButton1 and _G.RaidGroupButton1:GetAttribute("type") ~= "target" then
				fixRaidGroupButton()
				K:UnregisterEvent(event, setupMisc)
			end
		end
	end

	K:RegisterEvent("ADDON_LOADED", setupMisc)
end

hooksecurefunc("ChatEdit_InsertLink", function(text) -- shift-clicked
	-- change from SearchBox:HasFocus to :IsShown again
	if text and TradeSkillFrame and TradeSkillFrame:IsShown() then
		local spellId = strmatch(text, "enchant:(%d+)")
		local spell = GetSpellInfo(spellId)
		local item = GetItemInfo(strmatch(text, "item:(%d+)") or 0)
		local search = spell or item
		if not search then return end

		-- search needs to be lowercase for .SetRecipeItemNameFilter
		TradeSkillFrame.SearchBox:SetText(search)

		-- jump to the recipe
		if spell then -- can only select recipes on the learned tab
			if PanelTemplates_GetSelectedTab(TradeSkillFrame.RecipeList) == 1 then
				TradeSkillFrame:SelectRecipe(tonumber(spellId))
			end
		elseif item then
			C_Timer.After(.1, function() -- wait a bit or we cant select the recipe yet
				for _, v in pairs(TradeSkillFrame.RecipeList.dataList) do
					if v.name == item then
						--TradeSkillFrame.RecipeList:RefreshDisplay() -- didnt seem to help
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

-- Fix blizz guild news hyperlink error
do
	local function fixGuildNews(event, addon)
		if addon ~= "Blizzard_GuildUI" then return end

		local _GuildNewsButton_OnEnter = GuildNewsButton_OnEnter
		function GuildNewsButton_OnEnter(self)
			if not (self.newsInfo and self.newsInfo.whatText) then return end
			_GuildNewsButton_OnEnter(self)
		end

		K:UnregisterEvent(event, fixGuildNews)
	end

	local function fixCommunitiesNews(event, addon)
		if addon ~= "Blizzard_Communities" then return end

		local _CommunitiesGuildNewsButton_OnEnter = CommunitiesGuildNewsButton_OnEnter
		function CommunitiesGuildNewsButton_OnEnter(self)
			if not (self.newsInfo and self.newsInfo.whatText) then return end
			_CommunitiesGuildNewsButton_OnEnter(self)
		end

		K:UnregisterEvent(event, fixCommunitiesNews)
	end

	K:RegisterEvent("ADDON_LOADED", fixGuildNews)
	K:RegisterEvent("ADDON_LOADED", fixCommunitiesNews)
end

-- Show BID and highlight price
do
	local function setupMisc(event, addon)
		if addon == "Blizzard_AuctionUI" then
			hooksecurefunc("AuctionFrameBrowse_Update", function()
				local numBatchAuctions = GetNumAuctionItems("list")
				local offset = FauxScrollFrame_GetOffset(BrowseScrollFrame)
				local name, buyoutPrice, bidAmount, hasAllInfo
				for i = 1, NUM_BROWSE_TO_DISPLAY do
					local index = offset + i + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page)
					local shouldHide = index > (numBatchAuctions + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page))
					if not shouldHide then
						name, _, _, _, _, _, _, _, _, buyoutPrice, bidAmount, _, _, _, _, _, _, hasAllInfo = GetAuctionItemInfo("list", offset + i)
						if not hasAllInfo then shouldHide = true end
					end
					if not shouldHide then
						local alpha = .5
						local color = "yellow"
						local buttonName = "BrowseButton"..i
						local itemName = _G[buttonName.."Name"]
						local moneyFrame = _G[buttonName.."MoneyFrame"]
						local buyoutMoney = _G[buttonName.."BuyoutFrameMoney"]
						if buyoutPrice >= 5*1e7 then color = "red" end
						if bidAmount > 0 then
							name = name.." |cffffff00"..BID.."|r"
							alpha = 1.0
						end
						itemName:SetText(name)
						moneyFrame:SetAlpha(alpha)
						SetMoneyFrameColor(buyoutMoney:GetName(), color)
					end
				end
			end)

			K:UnregisterEvent(event, setupMisc)
		end
	end

	K:RegisterEvent("ADDON_LOADED", setupMisc)
end

-- Check SHIFT key status
do
	local function onUpdate(self, elapsed)
		if IsShiftKeyDown() then
			self.elapsed = self.elapsed + elapsed
			if self.elapsed > 5 then
				UIErrorsFrame:AddMessage(K.InfoColor.."Your SHIFT key may be stuck.")
				self:Hide()
			end
		end
	end

	local shiftUpdater = CreateFrame("Frame")
	shiftUpdater:SetScript("OnUpdate", onUpdate)
	shiftUpdater:Hide()

	local function ShiftKeyOnEvent(_, key, down)
		if key == "LSHIFT" then
			if down == 1 then
				shiftUpdater.elapsed = 0
				shiftUpdater:Show()
			else
				shiftUpdater:Hide()
			end
		end
	end
	K:RegisterEvent("MODIFIER_STATE_CHANGED", ShiftKeyOnEvent)
end

do
	-- Instant delete
	local function deleteConfirm(_, ...)
		if StaticPopup1EditBox:IsShown() then
			StaticPopup1EditBox:Hide()
			StaticPopup1Button1:Enable()

			local link = select(3, GetCursorInfo())

			Module.link:SetText(link)
			Module.link:Show()
		end
	end

	function addonLoaded(_, loaded_addon)
		if loaded_addon ~= "KkthnxUI" then
			return
		end

		-- create item link container
		Module.link = StaticPopup1:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		Module.link:SetPoint("CENTER", StaticPopup1EditBox)
		Module.link:Hide()

		StaticPopup1:HookScript("OnHide", function(self)
			Module.link:Hide()
		end)
	end

	K:RegisterEvent("ADDON_LOADED", addonLoaded)
	K:RegisterEvent("DELETE_ITEM_CONFIRM", deleteConfirm)
end

function Module:OnEnable()
	self:CreateAFKCam()
	self:CreateDurabilityFrame()
	self:CreateExtendInstance()
	self:CreateImprovedMail()
	self:CreateImprovedStats()
	self:CreateKillingBlow()
	self:CreateMerchantItemLevel()
	self:CreateNakedButtons()
	self:CreateNoTalkingHead()
	self:CreatePulseCooldown()
	self:CreatePvPEmote()
	self:CreateQuestNotifier()
	self:CreateQueueTimer()
	self:CreateRaidMarker()
	self:CreateSlotDurability()
	self:CreateSlotItemLevel()
	self:CreateTradeTargetInfo()
	self:CreateVehicleSeatMover()

	-- Unregister talent event
	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
		hooksecurefunc("TalentFrame_LoadUI", function()
			PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		end)
	end

	do
		StaticPopupDialogs.RESURRECT.hideOnEscape = nil
		StaticPopupDialogs.AREA_SPIRIT_HEAL.hideOnEscape = nil
		StaticPopupDialogs.PARTY_INVITE.hideOnEscape = nil
		StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = nil
		StaticPopupDialogs.ADDON_ACTION_FORBIDDEN.button1 = nil
		StaticPopupDialogs.TOO_MANY_LUA_ERRORS.button1 = nil

		_G.PetBattleQueueReadyFrame.hideOnEscape = nil
	end

	if (PVPReadyDialog) then
		PVPReadyDialog.leaveButton:Hide()
		PVPReadyDialog.enterButton:ClearAllPoints()
		PVPReadyDialog.enterButton:SetPoint("BOTTOM", PVPReadyDialog, "BOTTOM", 0, 25)
	end
end