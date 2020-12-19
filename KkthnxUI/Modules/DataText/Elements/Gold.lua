local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Infobar")

local _G = _G
local pairs = _G.pairs
local table_wipe = _G.table.wipe
local unpack = _G.unpack

local CLASS_ICON_TCOORDS = _G.CLASS_ICON_TCOORDS
local CURRENCY = _G.CURRENCY
local C_CurrencyInfo_GetBackpackCurrencyInfo = _G.C_CurrencyInfo.GetBackpackCurrencyInfo
local C_CurrencyInfo_GetCurrencyInfo = _G.C_CurrencyInfo.GetCurrencyInfo
local C_Timer_NewTicker = _G.C_Timer.NewTicker
local C_WowTokenPublic_GetCurrentMarketPrice = _G.C_WowTokenPublic.GetCurrentMarketPrice
local C_WowTokenPublic_UpdateMarketPrice = _G.C_WowTokenPublic.UpdateMarketPrice
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT
local GameTooltip = _G.GameTooltip
local GetAutoCompleteRealms = _G.GetAutoCompleteRealms
local GetMoney = _G.GetMoney
local GetNumWatchedTokens = _G.GetNumWatchedTokens
local InCombatLockdown = _G.InCombatLockdown
local IsControlKeyDown = _G.IsControlKeyDown
local NO = _G.NO
local StaticPopupDialogs = _G.StaticPopupDialogs
local TOTAL = _G.TOTAL
local YES = _G.YES

local ticker
local profit = 0
local spent = 0
local oldMoney = 0
local crossRealms = GetAutoCompleteRealms()

if not crossRealms or #crossRealms == 0 then
	crossRealms = {[1] = K.Realm}
end

StaticPopupDialogs["RESETGOLD"] = {
	text = "Are you sure to reset the gold count?",
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		for _, realm in pairs(crossRealms) do
			if KkthnxUIGold.totalGold[realm] then
				table_wipe(KkthnxUIGold.totalGold[realm])
			end
		end
		KkthnxUIGold.totalGold[K.Realm][K.Name] = {GetMoney(), K.Class}
	end,
	whileDead = 1,
}

local function getClassIcon(class)
	local c1, c2, c3, c4 = unpack(CLASS_ICON_TCOORDS[class])
	c1, c2, c3, c4 = (c1 + 0.03) * 50, (c2 - 0.03) * 50, (c3 + 0.03) * 50, (c4 - 0.03) * 50
	local classStr = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:12:12:0:0:50:50:"..c1..":"..c2..":"..c3..":"..c4.."|t "
	return classStr or ""
end

local function OnEvent(_, event)
	if not IsLoggedIn() then
		return
	end

	if event == "PLAYER_ENTERING_WORLD" then
		oldMoney = GetMoney()
		Module.GoldDataTextFrame:UnregisterEvent(event)
	end

	if not ticker then
		C_WowTokenPublic_UpdateMarketPrice()
		ticker = C_Timer_NewTicker(60, C_WowTokenPublic_UpdateMarketPrice)
	end

	local newMoney = GetMoney()
	local change = newMoney - oldMoney -- Positive if we gain money
	if oldMoney > newMoney then -- Lost Money
		spent = spent - change
	else -- Gained Moeny
		profit = profit + change
	end

	local coppername = "|cffeda55fC|r"
	local silvername = "|cffc7c7cfS|r."
	local goldname = "|cffffd700G|r."
	if C["DataText"].Gold then
		if C["DataText"].HideText then
			Module.GoldDataTextFrame.Text:SetText("")
		else
			Module.GoldDataTextFrame.Text:SetText(goldname..silvername..coppername)
		end
	end

	KkthnxUIGold = KkthnxUIGold or {}
	KkthnxUIGold.totalGold = KkthnxUIGold.totalGold or {}

	if not KkthnxUIGold.totalGold[K.Realm] then
		KkthnxUIGold.totalGold[K.Realm] = {}
	end

	if not KkthnxUIGold.totalGold[K.Realm][K.Name] then
		KkthnxUIGold.totalGold[K.Realm][K.Name] = {}
	end

	KkthnxUIGold.ServerID = KkthnxUIGold.ServerID or {}
	KkthnxUIGold.ServerID[K.ServerID] = KkthnxUIGold.ServerID[K.ServerID] or {}
	KkthnxUIGold.ServerID[K.ServerID][K.Realm] = true

	KkthnxUIGold.totalGold[K.Realm][K.Name][1] = GetMoney()
	KkthnxUIGold.totalGold[K.Realm][K.Name][2] = K.Class

	oldMoney = newMoney
end

local function OnEnter()
	GameTooltip:SetOwner(Module.GoldDataTextFrame, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(Module.GoldDataTextFrame))
	GameTooltip:ClearLines()

	GameTooltip:AddLine(K.InfoColor..CURRENCY)
	GameTooltip:AddLine(" ")

	GameTooltip:AddLine(L["Session"], 0.6, 0.8, 1)
	GameTooltip:AddDoubleLine(L["Earned"], K.FormatMoney(profit), 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(L["Spent"], K.FormatMoney(spent), 1, 1, 1, 1, 1, 1)
	if profit < spent then
		GameTooltip:AddDoubleLine(L["Deficit"], K.FormatMoney(spent - profit), 1, 0, 0, 1, 1, 1)
	elseif profit > spent then
		GameTooltip:AddDoubleLine(L["Profit"], K.FormatMoney(profit - spent), 0, 1, 0, 1, 1, 1)
	end
	GameTooltip:AddLine(" ")

	local totalGold = 0
	GameTooltip:AddLine(L["RealmCharacter"], 0.6, 0.8, 1)
	for realm in pairs(KkthnxUIGold.ServerID[K.ServerID]) do
		local thisRealmList = KkthnxUIGold.totalGold[realm]
		if thisRealmList then
			for k, v in pairs(thisRealmList) do
				local name = Ambiguate(k.."-"..realm, "none")
				local gold, class = unpack(v)
				local r, g, b = K.ColorClass(class)
				GameTooltip:AddDoubleLine(getClassIcon(class)..name, K.FormatMoney(gold), r, g, b, 1, 1, 1)
				totalGold = totalGold + gold
			end
		end
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(TOTAL..":", K.FormatMoney(totalGold), 0.63, 0.82, 1, 1, 1, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("|TInterface\\ICONS\\WoW_Token01:12:12:0:0:50:50:4:46:4:46|t ".."Token:", K.FormatMoney(C_WowTokenPublic_GetCurrentMarketPrice() or 0), 0.6, 0.8, 1, 1, 1, 1)

	for i = 1, GetNumWatchedTokens() do
		local currencyInfo = C_CurrencyInfo_GetBackpackCurrencyInfo(i)
		if not currencyInfo then
			break
		end

		local name, count, icon, currencyID = currencyInfo.name, currencyInfo.quantity, currencyInfo.iconFileID, currencyInfo.currencyTypesID
		if name and i == 1 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(CURRENCY..":", 0.6, 0.8, 1)
		end

		if name and count then
			local total = C_CurrencyInfo_GetCurrencyInfo(currencyID).maxQuantity
			local iconTexture = " |T"..icon..":12:12:0:0:50:50:4:46:4:46|t"
			if total > 0 then
				GameTooltip:AddDoubleLine(name, count.."/"..total..iconTexture, 1, 1, 1, 1, 1, 1)
			else
				GameTooltip:AddDoubleLine(name, count..iconTexture, 1, 1, 1, 1, 1, 1)
			end
		end
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(" ", K.LeftButton.."Currency Panel".." ", 1, 1, 1, 0.6, 0.8, 1)
	GameTooltip:AddDoubleLine(" ", L["Ctrl Key"]..K.RightButton.."Reset Gold".." ", 1, 1, 1, 0.6, 0.8, 1)
	GameTooltip:Show()
end

local function OnMouseUp(_, btn)
	if IsControlKeyDown() and btn == "RightButton" then
		StaticPopup_Show("RESETGOLD")
	elseif btn == "MiddleButton" then
		OnEnter()
	else
		if InCombatLockdown() then
			UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_IN_COMBAT)
			return
		end
		ToggleCharacter("TokenFrame")
	end
end

local function OnLeave()
	K.HideTooltip()
end

function Module:CreateGoldDataText()
	Module.GoldDataTextFrame = CreateFrame("Button", nil, UIParent)
	
	if C["DataText"].Gold then
		Module.GoldDataTextFrame:SetPoint("LEFT", UIParent, "LEFT", 4, -302)
		Module.GoldDataTextFrame:SetSize(32, 32)

		Module.GoldDataTextFrame.Texture = Module.GoldDataTextFrame:CreateTexture(nil, "BACKGROUND")
		Module.GoldDataTextFrame.Texture:SetPoint("LEFT", Module.GoldDataTextFrame, "LEFT", 0, 0)
		Module.GoldDataTextFrame.Texture:SetTexture([[Interface\HELPFRAME\ReportLagIcon-Loot]])
		Module.GoldDataTextFrame.Texture:SetSize(32, 32)

		Module.GoldDataTextFrame.Text = Module.GoldDataTextFrame:CreateFontString(nil, "ARTWORK")
		Module.GoldDataTextFrame.Text:SetFontObject(K.GetFont(C["UIFonts"].DataTextFonts))
		Module.GoldDataTextFrame.Text:SetPoint("CENTER", Module.GoldDataTextFrame.Texture, "CENTER", 0, -6)
	end

	Module.GoldDataTextFrame:RegisterEvent("PLAYER_MONEY", OnEvent)
	Module.GoldDataTextFrame:RegisterEvent("SEND_MAIL_MONEY_CHANGED", OnEvent)
	Module.GoldDataTextFrame:RegisterEvent("SEND_MAIL_COD_CHANGED", OnEvent)
	Module.GoldDataTextFrame:RegisterEvent("PLAYER_TRADE_MONEY", OnEvent)
	Module.GoldDataTextFrame:RegisterEvent("TRADE_MONEY_CHANGED", OnEvent)
	Module.GoldDataTextFrame:RegisterEvent("PLAYER_ENTERING_WORLD", OnEvent)

	Module.GoldDataTextFrame:SetScript("OnEvent", OnEvent)
	if C["DataText"].Gold then
		Module.GoldDataTextFrame:SetScript("OnMouseUp", OnMouseUp)
		Module.GoldDataTextFrame:SetScript("OnEnter", OnEnter)
		Module.GoldDataTextFrame:SetScript("OnLeave", OnLeave)
		
		K.Mover(Module.GoldDataTextFrame, "GoldDataText", "GoldDataText", {"LEFT", UIParent, "LEFT", 4, -302})
	end
end