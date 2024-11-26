local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("DataText")

-- Utility Functions
local pairs = pairs
local string_format = string.format
local unpack = unpack

-- WoW API and Constants
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
local CURRENCY = CURRENCY
local C_CurrencyInfo_GetBackpackCurrencyInfo = C_CurrencyInfo.GetBackpackCurrencyInfo
local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
local C_Timer_NewTicker = C_Timer.NewTicker
local C_WowTokenPublic_GetCurrentMarketPrice = C_WowTokenPublic.GetCurrentMarketPrice
local C_WowTokenPublic_UpdateMarketPrice = C_WowTokenPublic.UpdateMarketPrice
local GameTooltip = GameTooltip
local GetMoney = GetMoney
local IsControlKeyDown = IsControlKeyDown
local NO = NO
local StaticPopupDialogs = StaticPopupDialogs
local TOTAL = TOTAL
local YES = YES

-- Variables
local slotString = BAGSLOTTEXT .. ": %s%d"
local showGoldGap = 100 * 1e4
local ticker
local profit = 0
local spent = 0
local oldMoney = 0
local GoldDataText
local RebuildCharList

-- Player Information
local myName, myRealm = K.Name, K.Realm
myRealm = gsub(myRealm, "%s", "") -- fix for multi-word realm name

StaticPopupDialogs["RESETGOLD"] = {
	text = "Are you sure to reset the gold count?",
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		wipe(KkthnxUIDB.Gold)
		if not KkthnxUIDB.Gold[myRealm] then
			KkthnxUIDB.Gold[myRealm] = {}
		end
		KkthnxUIDB.Gold[myRealm][myName] = { GetMoney(), K.Class, K.Faction }
	end,
	whileDead = 1,
}

local menuList = {
	{
		text = K.RGBToHex(1, 0.8, 0) .. REMOVE_WORLD_MARKERS .. "!!!",
		notCheckable = true,
		func = function()
			StaticPopup_Show("RESETGOLD")
		end,
	},
}

local function getClassIcon(class)
	local coords = CLASS_ICON_TCOORDS[class] or { 0, 0, 0, 0 }
	local c1, c2, c3, c4 = unpack(coords)
	c1, c2, c3, c4 = (c1 + 0.03) * 50, (c2 - 0.03) * 50, (c3 + 0.03) * 50, (c4 - 0.03) * 50
	return "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:12:12:0:0:50:50:" .. c1 .. ":" .. c2 .. ":" .. c3 .. ":" .. c4 .. "|t "
end

local factionIcons = {
	["Horde"] = "UI_HordeIcon",
	["Alliance"] = "UI_AllianceIcon",
	["Unknown"] = "INV_Misc_QuestionMark",
}

local function getFactionIcon(faction)
	local icon = factionIcons[faction] or "INV_Misc_QuestionMark"
	return "|TInterface\\ICONS\\" .. icon .. ":12:12:0:0:50:50:4:46:4:46|t "
end

local function getSlotString()
	local num = CalculateTotalNumberOfFreeBagSlots()
	if num < 10 then
		return string_format(slotString, "|cffff0000", num)
	else
		return string_format(slotString, "|cff00ff00", num)
	end
end

local eventList = {
	"PLAYER_ENTERING_WORLD",
	"PLAYER_MONEY",
	"PLAYER_TRADE_MONEY",
	"SEND_MAIL_COD_CHANGED",
	"SEND_MAIL_MONEY_CHANGED",
	"TRADE_MONEY_CHANGED",
}

local function UpdateMarketPrice()
	return C_WowTokenPublic_UpdateMarketPrice()
end

local function OnEvent(_, event, arg1)
	if not IsLoggedIn() then
		return
	end

	if event == "PLAYER_ENTERING_WORLD" then
		oldMoney = GetMoney()
		GoldDataText:UnregisterEvent(event)

		if KkthnxUIDB.ShowSlots then
			GoldDataText:RegisterEvent("BAG_UPDATE")
		end
	elseif event == "BAG_UPDATE" then
		if arg1 < 0 or arg1 > 4 then
			return
		end
	end

	if not ticker and not K.IsFirestorm then
		C_WowTokenPublic_UpdateMarketPrice()
		ticker = C_Timer_NewTicker(60, UpdateMarketPrice)
	end

	local newMoney = GetMoney()
	local change = newMoney - oldMoney -- Positive if we gain money
	if oldMoney > newMoney then -- Lost Money
		spent = spent - change
	else -- Gained Money
		profit = profit + change
	end

	if C["DataText"].Gold then
		if C["DataText"].HideText then
			GoldDataText.Text:SetText("")
		else
			if KkthnxUIDB.ShowSlots then
				GoldDataText.Text:SetText(getSlotString())
			else
				GoldDataText.Text:SetText(K.FormatMoney(newMoney))
			end
		end
	end

	if not KkthnxUIDB.Gold[myRealm] then
		KkthnxUIDB.Gold[myRealm] = {}
	end

	if not KkthnxUIDB.Gold[myRealm][myName] then
		KkthnxUIDB.Gold[myRealm][myName] = {}
	end

	KkthnxUIDB.Gold[myRealm][myName][1] = GetMoney()
	KkthnxUIDB.Gold[myRealm][myName][2] = K.Class
	KkthnxUIDB.Gold[myRealm][myName][3] = K.Faction

	oldMoney = newMoney
end
K.GoldButton_OnEvent = OnEvent

local function clearCharGold(_, realm, name)
	KkthnxUIDB.Gold[realm][name] = nil
	DropDownList1:Hide()
	RebuildCharList()
end

function RebuildCharList()
	for i = 2, #menuList do
		if menuList[i] then
			wipe(menuList[i])
		end
	end

	local index = 1
	for realm, data in pairs(KkthnxUIDB.Gold) do
		for name, value in pairs(data) do
			if not (realm == myRealm and name == myName) then
				index = index + 1
				if not menuList[index] then
					menuList[index] = {}
				end
				menuList[index].text = K.RGBToHex(K.ColorClass(value[2])) .. Ambiguate(name .. "-" .. realm, "none")
				menuList[index].notCheckable = true
				menuList[index].arg1 = realm
				menuList[index].arg2 = name
				menuList[index].func = clearCharGold
			end
		end
	end
end

local title
local function OnEnter(self)
	if not self then
		return
	end

	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(self))
	GameTooltip:ClearLines()

	GameTooltip:AddLine(K.InfoColor .. CURRENCY)
	GameTooltip:AddLine(" ")

	GameTooltip:AddLine(L["Session"], 0.5, 0.7, 1)
	GameTooltip:AddDoubleLine(L["Earned"], K.FormatMoney(profit), 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(L["Spent"], K.FormatMoney(spent), 1, 1, 1, 1, 1, 1)
	if profit < spent then
		GameTooltip:AddDoubleLine(L["Deficit"], K.FormatMoney(spent - profit), 1, 0, 0, 1, 1, 1)
	elseif profit > spent then
		GameTooltip:AddDoubleLine(L["Profit"], K.FormatMoney(profit - spent), 0, 1, 0, 1, 1, 1)
	end
	GameTooltip:AddLine(" ")

	local totalGold = 0
	GameTooltip:AddLine(CHARACTER_BUTTON .. ":", 0.5, 0.7, 1)
	if KkthnxUIDB.Gold[myRealm] then
		for k, v in pairs(KkthnxUIDB.Gold[myRealm]) do
			local gold, class, faction = unpack(v)
			local name = Ambiguate(k .. "-" .. myRealm, "none")
			if gold > showGoldGap or UnitIsUnit(name, "player") then
				local r, g, b = K.ColorClass(class)
				GameTooltip:AddDoubleLine(getFactionIcon(faction) .. getClassIcon(class) .. name, K.FormatMoney(gold), r, g, b, 1, 1, 1)
				totalGold = totalGold + gold
			end
		end
	end

	local isShiftKeyDown = IsShiftKeyDown()
	for realm, data in pairs(KkthnxUIDB.Gold) do
		if realm ~= myRealm then
			for k, v in pairs(data) do
				local gold, class, faction = unpack(v)
				if gold > showGoldGap then
					if isShiftKeyDown then -- show other realms while holding shift
						local name = Ambiguate(k .. "-" .. realm, "none")
						local r, g, b = K.ColorClass(class)
						GameTooltip:AddDoubleLine(getFactionIcon(faction) .. getClassIcon(class) .. name, K.FormatMoney(gold), r, g, b, 1, 1, 1)
					end
					totalGold = totalGold + gold
				end
			end
		end
	end

	if not isShiftKeyDown then
		GameTooltip:AddLine(L["Hold Shift"], 0.63, 0.82, 1)
	end

	local accountmoney = C_Bank.FetchDepositedMoney(Enum.BankType.Account)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(CHARACTER .. ":", K.FormatMoney(totalGold), 0.63, 0.82, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(ACCOUNT_BANK_PANEL_TITLE .. ":", K.FormatMoney(accountmoney), 0.63, 0.82, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(TOTAL .. ":", K.FormatMoney(totalGold + accountmoney), 0.63, 0.82, 1, 1, 1, 1)

	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("|TInterface\\ICONS\\WoW_Token01:12:12:0:0:50:50:4:46:4:46|t " .. TOKEN_FILTER_LABEL .. ":", K.FormatMoney(C_WowTokenPublic_GetCurrentMarketPrice() or 0), 0.5, 0.7, 1, 1, 1, 1)

	title = false
	local chargeInfo = C_CurrencyInfo_GetCurrencyInfo(2813) -- Tier charges
	if chargeInfo then
		if not title then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(CURRENCY .. ":", 0.63, 0.82, 1)
			title = true
		end
		local iconTexture = "|T" .. chargeInfo.iconFileID .. ":12:12:0:0:50:50:4:46:4:46|t"
		local currencyText = iconTexture .. " " .. chargeInfo.name
		GameTooltip:AddDoubleLine(currencyText, chargeInfo.quantity .. "/" .. chargeInfo.maxQuantity, 1, 1, 1, 1, 1, 1)
	end

	for i = 1, 6 do
		local currencyInfo = C_CurrencyInfo_GetBackpackCurrencyInfo(i)
		if not currencyInfo then
			break
		end

		local name, count, icon, currencyID = currencyInfo.name, currencyInfo.quantity, currencyInfo.iconFileID, currencyInfo.currencyTypesID

		if name and count then
			if not title then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(CURRENCY .. ":", 0.5, 0.7, 1)
				title = true
			end

			local total = C_CurrencyInfo_GetCurrencyInfo(currencyID).maxQuantity
			local iconTexture = "|T" .. icon .. ":12:12:0:0:50:50:4:46:4:46|t "
			local currencyText = iconTexture .. name

			if total > 0 then
				GameTooltip:AddDoubleLine(currencyText, BreakUpLargeNumbers(count) .. "/" .. K.ShortValue(total), 1, 1, 1, 1, 1, 1)
			else
				GameTooltip:AddDoubleLine(currencyText, BreakUpLargeNumbers(count), 1, 1, 1, 1, 1, 1)
			end
		end
	end

	if self == GoldDataText then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(" ", K.RightButton .. "Switch Mode" .. " ", 1, 1, 1, 0.5, 0.7, 1)
		if KkthnxUIDB.ShowSlots then
			GameTooltip:AddDoubleLine(" ", K.LeftButton .. BINDING_NAME_TOGGLEBACKPACK .. " ", 1, 1, 1, 0.5, 0.7, 1)
		else
			GameTooltip:AddDoubleLine(" ", K.LeftButton .. BINDING_NAME_TOGGLECURRENCY .. " ", 1, 1, 1, 0.5, 0.7, 1)
		end
		GameTooltip:AddDoubleLine(" ", L["Ctrl Key"] .. K.RightButton .. "Reset Gold" .. " ", 1, 1, 1, 0.5, 0.7, 1)
	end
	GameTooltip:Show()
end
K.GoldButton_OnEnter = OnEnter

local function OnMouseUp(self, btn)
	if btn == "RightButton" then
		if IsControlKeyDown() then
			if not menuList[1].created then
				RebuildCharList()
				menuList[1].created = true
			end
			K.LibEasyMenu.Create(menuList, K.EasyMenu, self, -80, 100, "MENU", 1)
		else
			KkthnxUIDB["ShowSlots"] = not KkthnxUIDB["ShowSlots"]
			if KkthnxUIDB["ShowSlots"] then
				GoldDataText:RegisterEvent("BAG_UPDATE")
			else
				GoldDataText:UnregisterEvent("BAG_UPDATE")
			end
			OnEvent()
		end
		OnEnter(self) -- Update our tooltip for inventory or currency
	else
		if KkthnxUIDB.ShowSlots then
			ToggleAllBags()
		else
			ToggleCharacter("TokenFrame")
		end
	end
end

local function OnLeave()
	K.HideTooltip()
end
K.GoldButton_OnLeave = OnLeave

function Module:CreateGoldDataText()
	GoldDataText = CreateFrame("Frame", nil, UIParent)
	GoldDataText:SetHitRectInsets(-16, 0, -10, -10)
	if C["DataText"].Gold then
		GoldDataText.Text = K.CreateFontString(GoldDataText, 12)
		GoldDataText.Text:ClearAllPoints()
		GoldDataText.Text:SetPoint("LEFT", UIParent, "LEFT", 24, -302)

		GoldDataText.Texture = GoldDataText:CreateTexture(nil, "ARTWORK")
		GoldDataText.Texture:SetPoint("RIGHT", GoldDataText.Text, "LEFT", 0, 2)
		GoldDataText.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\DataText\\bags.blp")
		GoldDataText.Texture:SetSize(24, 24)
		GoldDataText.Texture:SetVertexColor(unpack(C["DataText"].IconColor))

		GoldDataText:SetAllPoints(GoldDataText.Text)
	end

	for _, event in pairs(eventList) do
		GoldDataText:RegisterEvent(event)
	end

	GoldDataText:SetScript("OnEvent", OnEvent)
	GoldDataText:SetScript("OnEnter", OnEnter)
	GoldDataText:SetScript("OnLeave", OnLeave)

	if C["DataText"].Gold then
		GoldDataText:SetScript("OnMouseUp", OnMouseUp)
	end
end
