local K, C = unpack(select(2, ...))
local Module = K:GetModule("Infobar")

local _G = _G
local pairs = _G.pairs
local table_wipe = _G.table.wipe
local unpack = _G.unpack

local CLASS_ICON_TCOORDS = _G.CLASS_ICON_TCOORDS
local CURRENCY = _G.CURRENCY
local C_Timer_NewTicker = _G.C_Timer.NewTicker
local C_WowTokenPublic_GetCurrentMarketPrice = _G.C_WowTokenPublic.GetCurrentMarketPrice
local C_WowTokenPublic_UpdateMarketPrice = _G.C_WowTokenPublic.UpdateMarketPrice
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT
local GameTooltip = _G.GameTooltip
local GetBackpackCurrencyInfo = _G.GetBackpackCurrencyInfo
local GetCurrencyInfo = _G.GetCurrencyInfo
local GetMoney = _G.GetMoney
local GetNumWatchedTokens = _G.GetNumWatchedTokens
local InCombatLockdown = _G.InCombatLockdown
local IsControlKeyDown = _G.IsControlKeyDown
local IsLoggedIn = _G.IsLoggedIn
local NO = _G.NO
local StaticPopupDialogs = _G.StaticPopupDialogs
local TOTAL = _G.TOTAL
local YES = _G.YES

local profit, spent, oldMoney, ticker = 0, 0, 0

StaticPopupDialogs["RESETGOLD"] = {
	text = "Are you sure to reset the gold count?",
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		table_wipe(KkthnxUIGold.totalGold[K.Realm])
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

	KkthnxUIGold = KkthnxUIGold or {}
	KkthnxUIGold.totalGold = KkthnxUIGold.totalGold or {}
	KkthnxUIGold.totalGold[K.Realm] = KkthnxUIGold.totalGold[K.Realm] or {}
	KkthnxUIGold.totalGold[K.Realm][K.Name] = {GetMoney(), K.Class}

	oldMoney = newMoney
end

local function OnEnter()
	GameTooltip:SetOwner(Module.GoldDataTextFrame, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(Module.GoldDataTextFrame))
	GameTooltip:ClearLines()

	GameTooltip:AddLine(K.InfoColor..CURRENCY)
	GameTooltip:AddLine(" ")

	GameTooltip:AddLine("Session:", .6, .8, 1)
	GameTooltip:AddDoubleLine("Earned", K.FormatMoney(profit), 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine("Spent", K.FormatMoney(spent), 1, 1, 1, 1, 1, 1)
	if profit < spent then
		GameTooltip:AddDoubleLine("Deficit", K.FormatMoney(spent-profit), 1, 0, 0, 1, 1, 1)
	elseif profit > spent then
		GameTooltip:AddDoubleLine("Profit", K.FormatMoney(profit-spent), 0, 1, 0, 1, 1, 1)
	end
	GameTooltip:AddLine(" ")

	local totalGold = 0
	GameTooltip:AddLine("Characters:", 0.6, 0.8, 1)
	local thisRealmList = KkthnxUIGold.totalGold[K.Realm]
	for k, v in pairs(thisRealmList) do
		local gold, class = unpack(v)
		local r, g, b = K.ColorClass(class)
		GameTooltip:AddDoubleLine(getClassIcon(class)..k, K.FormatMoney(gold), r, g, b, 1, 1, 1)
		totalGold = totalGold + gold
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(TOTAL..":", K.FormatMoney(totalGold), 0.63, 0.82, 1, 1, 1, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("|TInterface\\ICONS\\WoW_Token01:12:12:0:0:50:50:4:46:4:46|t ".."Token:", K.FormatMoney(C_WowTokenPublic_GetCurrentMarketPrice() or 0), .6,.8,1, 1, 1, 1)

	for i = 1, GetNumWatchedTokens() do
		local name, count, icon, currencyID = GetBackpackCurrencyInfo(i)
		if name and i == 1 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(CURRENCY..":", 0.6, 0.8, 1)
		end
		if name and count then
			local _, _, _, _, _, total = GetCurrencyInfo(currencyID)
			local iconTexture = " |T"..icon..":12:12:0:0:50:50:4:46:4:46|t"
			if total > 0 then
				GameTooltip:AddDoubleLine(name, count.."/"..total..iconTexture, 1, 1, 1, 1, 1, 1)
			else
				GameTooltip:AddDoubleLine(name, count..iconTexture, 1, 1, 1, 1, 1, 1)
			end
		end
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(" ", " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:230:307|t ".."Currency Panel".." ", 1, 1, 1, 0.6, 0.8, 1)
	GameTooltip:AddDoubleLine(" ", "CTRL +".." |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:411|t ".."Reset Gold".." ", 1, 1, 1, 0.6, 0.8, 1)
	GameTooltip:Show()
end

local function OnMouseUp(_, button)
	if IsControlKeyDown() and button == "RightButton" then
		StaticPopup_Show("RESETGOLD")
	elseif button == "MiddleButton" then
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

function Module:CreateCurrencyDataText()
	if not C["DataText"].Currency then
		return
	end

	if not C["ActionBar"].MicroBar then
		return
	end

	if not CharacterMicroButton or not CharacterMicroButton:IsShown() then
		return
	end

	Module.GoldDataTextFrame = CreateFrame("Button", nil, UIParent)
	Module.GoldDataTextFrame:SetSize(_G.CharacterMicroButton:GetWidth(), _G.CharacterMicroButton:GetHeight())
	Module.GoldDataTextFrame:SetFrameLevel(_G.CharacterMicroButton:GetFrameLevel() + 2)
	Module.GoldDataTextFrame:SetAllPoints(_G.CharacterMicroButton)

	Module.GoldDataTextFrame.Texture = Module.GoldDataTextFrame:CreateTexture(nil, "BACKGROUND")
	Module.GoldDataTextFrame.Texture:SetTexture("Interface\\BUTTONS\\UI-GroupLoot-Coin-Up")
	Module.GoldDataTextFrame.Texture:SetPoint("CENTER", Module.GoldDataTextFrame, "CENTER", 1, -8)
	Module.GoldDataTextFrame.Texture:SetSize(14, 14)

	Module.GoldDataTextFrame:RegisterEvent("PLAYER_MONEY", OnEvent)
	Module.GoldDataTextFrame:RegisterEvent("SEND_MAIL_MONEY_CHANGED", OnEvent)
	Module.GoldDataTextFrame:RegisterEvent("SEND_MAIL_COD_CHANGED", OnEvent)
	Module.GoldDataTextFrame:RegisterEvent("PLAYER_TRADE_MONEY", OnEvent)
	Module.GoldDataTextFrame:RegisterEvent("TRADE_MONEY_CHANGED", OnEvent)
	Module.GoldDataTextFrame:RegisterEvent("PLAYER_ENTERING_WORLD", OnEvent)

	Module.GoldDataTextFrame:SetScript("OnEvent", OnEvent)
	Module.GoldDataTextFrame:SetScript("OnMouseUp", OnMouseUp)
	Module.GoldDataTextFrame:SetScript("OnEnter", OnEnter)
	Module.GoldDataTextFrame:SetScript("OnLeave", OnLeave)
end