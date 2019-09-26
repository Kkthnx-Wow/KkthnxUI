local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Miscellaneous", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")

local _G = _G
local math_min = _G.math.min
local math_floor = _G.math.floor

local BNGetGameAccountInfoByGUID = _G.BNGetGameAccountInfoByGUID
local CreateFrame = _G.CreateFrame
local DELETE_ITEM_CONFIRM_STRING = _G.DELETE_ITEM_CONFIRM_STRING
local FRIEND = _G.FRIEND
local GUILD = _G.GUILD
local GetCVar = _G.GetCVar
local GetInstanceInfo = _G.GetInstanceInfo
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
function Module:VehicleSeatMover()
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
    function K.ToggleGrid(arg)
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
    -- K:RegisterChatCommand("showgrid", K.ToggleGrid)
    -- K:RegisterChatCommand("align", K.ToggleGrid)
    -- K:RegisterChatCommand("grid", K.ToggleGrid)
end

-- Get Naked
function Module:NakedIcon()
    -- Add Buttons To Main Dressup Frames
    local DressUpNudeBtn = CreateFrame("Button", "Nude", DressUpFrame, "UIPanelButtonTemplate")
    DressUpNudeBtn:SetPoint("BOTTOMLEFT", 106, 79)
    DressUpNudeBtn:SetSize(80, 22)
    DressUpNudeBtn:SetText("Nude")
    DressUpNudeBtn:ClearAllPoints()
    DressUpNudeBtn:SetPoint("RIGHT", DressUpFrameResetButton, "LEFT", 0, 0)
    DressUpNudeBtn:SetScript("OnClick", function()
        DressUpFrameResetButton:Click() -- Done First In Case Any Slots Refuse To Clear
        for i = 1, 19 do
            DressUpModel:UndressSlot(i) -- Done This Way To Prevent Issues With Undress
        end
    end)

    local DressUpTabBtn = CreateFrame("Button", "Tabard", DressUpFrame, "UIPanelButtonTemplate")
    DressUpTabBtn:SetPoint("BOTTOMLEFT", 26, 79)
    DressUpTabBtn:SetSize(80, 22)
    DressUpTabBtn:SetText("Tabard")
    DressUpTabBtn:ClearAllPoints()
    DressUpTabBtn:SetPoint("RIGHT", DressUpNudeBtn, "LEFT", 0, 0)
    DressUpTabBtn:SetScript("OnClick", function()
        DressUpModel:UndressSlot(19)
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

    local BtnStrata, BtnLevel = SideDressUpModelResetButton:GetFrameStrata(), SideDressUpModelResetButton:GetFrameLevel()

    -- Add Buttons To Auction House Dressup Frame
    local DressUpSideBtn = CreateFrame("Button", "Tabard", SideDressUpFrame, "UIPanelButtonTemplate")
    DressUpSideBtn:SetPoint("BOTTOMLEFT", 14, 20)
    DressUpSideBtn:SetSize(60, 22)
    DressUpSideBtn:SetText("Tabard")
    DressUpSideBtn:SetFrameStrata(BtnStrata)
    DressUpSideBtn:SetFrameLevel(BtnLevel)
    DressUpSideBtn:SetScript("OnClick", function()
        SideDressUpModel:UndressSlot(19)
    end)

    local DressUpSideNudeBtn = CreateFrame("Button", "Nude", SideDressUpFrame, "UIPanelButtonTemplate")
    DressUpSideNudeBtn:SetPoint("BOTTOMRIGHT", -18, 20)
    DressUpSideNudeBtn:SetSize(60, 22)
    DressUpSideNudeBtn:SetText("Nude")
    DressUpSideNudeBtn:SetFrameStrata(BtnStrata)
    DressUpSideNudeBtn:SetFrameLevel(BtnLevel)
    DressUpSideNudeBtn:SetScript("OnClick", function()
        SideDressUpModelResetButton:Click() -- Done First In Case Any Slots Refuse To Clear
        for i = 1, 19 do
            SideDressUpModel:UndressSlot(i) -- Done This Way To Prevent Issues With Undress
        end
    end)

    -- Only Show Side Dressup Buttons If Its A Player (Reset Button Will Show Too)
    hooksecurefunc(SideDressUpModelResetButton, "Show", function()
        DressUpSideBtn:Show()
        DressUpSideNudeBtn:Show()
    end)

    hooksecurefunc(SideDressUpModelResetButton, "Hide", function()
        DressUpSideBtn:Hide()
        DressUpSideNudeBtn:Hide()
    end)

    -- Function To Set Animations
    local function SetupAnimations()
        DressUpModel:SetAnimation(255)
        SideDressUpModel:SetAnimation(255)
    end

    -- Dressing Room
    hooksecurefunc("DressUpFrame_Show", SetupAnimations)
    DressUpFrame.ResetButton:HookScript("OnClick", SetupAnimations)
    -- Auction House Dressing Room
    hooksecurefunc(SideDressUpModel, "SetUnit", SetupAnimations)
    SideDressUpModelResetButton:HookScript("OnClick", SetupAnimations)

    -- Function To Hide Controls
    local function SetupControls()
        CharacterModelFrameControlFrame:Hide()
        DressUpModelControlFrame:Hide()
        SideDressUpModelControlFrame:Hide()
    end

    -- Hide Controls For Character Sheet, Dressing Room And Auction House Dressing Room
    CharacterModelFrameControlFrame:HookScript("OnShow", SetupControls)
    DressUpModelControlFrame:HookScript("OnShow", SetupControls)
    SideDressUpModelControlFrame:HookScript("OnShow", SetupControls)

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
function Module:ExtendInstance()
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
function Module:TradeTargetInfo()
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
    local old_MerchantItemButton_OnModifiedClick = _G.MerchantItemButton_OnModifiedClick
    local cache = {}
    function MerchantItemButton_OnModifiedClick(self, ...)
        if IsAltKeyDown() then
            local id = self:GetID()
            local itemLink = GetMerchantItemLink(id)
            if not itemLink then return end
            local name, _, quality, _, _, _, _, maxStack, _, texture = GetItemInfo(itemLink)
            if maxStack and maxStack > 1 then
                if not cache[itemLink] then
                    StaticPopupDialogs["BUY_STACK"] = {
                        text = "Stack Buying Check",
                        button1 = YES,
                        button2 = NO,
                        OnAccept = function()
                            _G.BuyMerchantItem(id, GetMerchantItemMaxStack(id))
                            cache[itemLink] = true
                        end,
                        hideOnEscape = 1,
                        hasItemFrame = 1,
                    }

                    local r, g, b = GetItemQualityColor(quality or 1)
                    StaticPopup_Show("BUY_STACK", " ", " ", {["texture"] = texture, ["name"] = name, ["color"] = {r, g, b, 1}, ["link"] = itemLink, ["index"] = id, ["count"] = maxStack})
                else
                    _G.BuyMerchantItem(id, GetMerchantItemMaxStack(id))
                end
            end
        end

        old_MerchantItemButton_OnModifiedClick(self, ...)
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

-- Make It Only Split Stacks With Shift-RightClick If The Tradeskillframe Is Open
-- Shift-LeftClick Should Be Reserved For The Search Box
do
    local function hideSplitFrame(_, button)
        if _G.TradeSkillFrame and _G.TradeSkillFrame:IsShown() then
            if button == "LeftButton" then
                _G.StackSplitFrame:Hide()
            end
        end
    end

    hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", hideSplitFrame)
    hooksecurefunc("MerchantItemButton_OnModifiedClick", hideSplitFrame)
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

function Module:OnEnable()
    self:CreateAFKCam()
    self:CreateChatBubble()
    self:CreateDurabilityFrame()
    self:CreateEnchantScroll()
    self:CreateImprovedMail()
    self:CreateImprovedStats()
    self:CreateKillingBlow()
    self:CreateMerchantItemLevel()
    self:CreateNoTalkingHead()
    self:CreatePvPEmote()
    self:CreateQuestNotifier()
    self:CreateQueueTimer()
    self:CreateRaidMarker()
    self:CreateSlotDurability()
    self:CreateSlotItemLevel()
    self:ExtendInstance()
    -- self:NakedIcon()
    self:TradeTargetInfo()
    self:VehicleSeatMover()

    -- Instant delete
    hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_ITEM"], "OnShow", function(self)
        self.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
    end)

    -- Auto chatBubbles
    if C["Skins"].ChatBubbles then
        local function updateBubble()
            local name, instType = GetInstanceInfo()
            if name and instType == "raid" or instType == "party" then
                SetCVar("chatBubbles", 0)
            else
                SetCVar("chatBubbles", 1)
            end
        end

        if InCombatLockdown() or C["Automation"].AutoBubbles ~= true then
            return
        end

        K:RegisterEvent("PLAYER_ENTERING_WORLD", updateBubble)
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
