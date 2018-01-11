--[[local K, C = unpack(select(2, ...))

local _G = _G
local pairs = pairs
local join = string.join

local CURRENCY = CURRENCY
local GetBackpackCurrencyInfo = _G.GetBackpackCurrencyInfo
local GetMoney = _G.GetMoney
local IsLoggedIn = _G.IsLoggedIn
local IsShiftKeyDown = _G.IsShiftKeyDown
local MAX_WATCHED_TOKENS = MAX_WATCHED_TOKENS

local DataTextGold = CreateFrame("Frame")

DataTextGold.Text = UIParent:CreateFontString(nil, "OVERLAY")
DataTextGold.Text:SetFont(C["Media"].Font, 13, "OUTLINE")
DataTextGold.Text:SetShadowOffset(0, 0)
DataTextGold.Text:SetPoint("CENTER", UIParent, "CENTER", 0, 2)
DataTextGold:SetAllPoints(DataTextGold.Text)

local Profit = 0
local Spent = 0
local resetCountersFormatter = join("", "|cffaaaaaa", "Reset Counters: Hold Shift + Left Click", "|r")
local resetInfoFormatter = join("", "|cffaaaaaa", "Reset Data: Hold Shift + Right Click", "|r")

local function OnEvent(self)
	if not IsLoggedIn() then return end
	local NewMoney = GetMoney()
	KkthnxUIData = KkthnxUIData or {}
	KkthnxUIData["Gold"] = KkthnxUIData["Gold"] or {}
	KkthnxUIData["Gold"][K.Realm] = KkthnxUIData["Gold"][K.Realm] or {}
	KkthnxUIData["Gold"][K.Realm][K.Name] = KkthnxUIData["Gold"][K.Realm][K.Name] or NewMoney

	local OldMoney = KkthnxUIData["Gold"][K.Realm][K.Name] or NewMoney

	local Change = NewMoney - OldMoney -- Positive if we gain money
	if OldMoney > NewMoney then -- Lost Money
		Spent = Spent - Change
	else -- Gained Moeny
		Profit = Profit + Change
	end

	DataTextGold.Text:SetText(K.FormatMoney(NewMoney))

	KkthnxUIData["Gold"][K.Realm][K.Name] = NewMoney
end

local function Click(self, btn)
	if GameTooltip:IsForbidden() then return end

	if IsShiftKeyDown() then
		if btn == "LeftButton" then
			Profit = 0
			Spent = 0
			GameTooltip:Hide()
		elseif btn == "RightButton" then
			KkthnxUIData.gold = nil
			OnEvent(self)
			GameTooltip:Hide()
		end
	else
		ToggleAllBags()
	end
end

local function OnLeave()
	if GameTooltip:IsForbidden() then return end

	GameTooltip:Hide()
end

local function OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(self))
	GameTooltip:ClearLines()

	GameTooltip:AddLine("Session:")
	GameTooltip:AddDoubleLine("Earned:", K.FormatMoney(Profit), 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine("Spent:", K.FormatMoney(Spent), 1, 1, 1, 1, 1, 1)
	if Profit < Spent then
		GameTooltip:AddDoubleLine("Deficit:", K.FormatMoney(Profit - Spent), 1, 0, 0, 1, 1, 1)
	elseif (Profit - Spent) > 0 then
		GameTooltip:AddDoubleLine("Profit:", K.FormatMoney(Profit - Spent), 0, 1, 0, 1, 1, 1)
	end
	GameTooltip:AddLine(" ")

	local totalGold = 0
	GameTooltip:AddLine("Character: ")

	for k, _ in pairs(KkthnxUIData["Gold"][K.Realm]) do
		if KkthnxUIData["Gold"][K.Realm][k] then
			GameTooltip:AddDoubleLine(k, K.FormatMoney(KkthnxUIData["Gold"][K.Realm][k]), 1, 1, 1, 1, 1, 1)
			totalGold = totalGold + KkthnxUIData["Gold"][K.Realm][k]
		end
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("Server: ")
	GameTooltip:AddDoubleLine("Total: ", K.FormatMoney(totalGold), 1, 1, 1, 1, 1, 1)

	for i = 1, MAX_WATCHED_TOKENS do
		local name, count = GetBackpackCurrencyInfo(i)
		if name and i == 1 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(CURRENCY)
		end
		if name and count then GameTooltip:AddDoubleLine(name, count, 1, 1, 1) end
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(resetCountersFormatter)
	GameTooltip:AddLine(resetInfoFormatter)

	GameTooltip:Show()
end

-- Events
DataTextGold:RegisterEvent("PLAYER_ENTERING_WORLD")
DataTextGold:RegisterEvent("PLAYER_MONEY")
DataTextGold:RegisterEvent("SEND_MAIL_MONEY_CHANGED")
DataTextGold:RegisterEvent("SEND_MAIL_COD_CHANGED")
DataTextGold:RegisterEvent("PLAYER_TRADE_MONEY")
DataTextGold:RegisterEvent("TRADE_MONEY_CHANGED")
DataTextGold:RegisterEvent("MERCHANT_SHOW")
-- Scripts
DataTextGold:SetScript("OnEvent", OnEvent)
DataTextGold:SetScript("OnMouseDown", Click)
DataTextGold:SetScript("OnEnter", OnEnter)
DataTextGold:SetScript("OnLeave", OnLeave)--]]