local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("DataText")

local pairs = pairs
local string_format = string.format
local unpack = unpack

local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
local CURRENCY = CURRENCY
local C_CurrencyInfo_GetBackpackCurrencyInfo = C_CurrencyInfo.GetBackpackCurrencyInfo
local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
local C_Timer_NewTicker = C_Timer.NewTicker
local C_WowTokenPublic_GetCurrentMarketPrice = C_WowTokenPublic.GetCurrentMarketPrice
local C_WowTokenPublic_UpdateMarketPrice = C_WowTokenPublic.UpdateMarketPrice
local GameTooltip = GameTooltip
local GetAutoCompleteRealms = GetAutoCompleteRealms
local GetMoney = GetMoney
local GetNumWatchedTokens = GetNumWatchedTokens
local IsControlKeyDown = IsControlKeyDown
local NO = NO
local StaticPopupDialogs = StaticPopupDialogs
local TOTAL = TOTAL
local YES = YES

local slotString = BAGSLOTTEXT .. ": %s%d"
local ticker
local profit = 0
local spent = 0
local oldMoney = 0
local crossRealms = GetAutoCompleteRealms()
local GoldDataText
local RebuildCharList

if not crossRealms or #crossRealms == 0 then
	crossRealms = { [1] = K.Realm }
end

StaticPopupDialogs["RESETGOLD"] = {
	text = "Are you sure to reset the gold count?",
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		for _, realm in pairs(crossRealms) do
			if KkthnxUIDB.Gold[realm] then
				wipe(KkthnxUIDB.Gold[realm])
			end
		end
		KkthnxUIDB.Gold[K.Realm][K.Name] = { GetMoney(), K.Class }
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
	local c1, c2, c3, c4 = unpack(CLASS_ICON_TCOORDS[class])
	c1, c2, c3, c4 = (c1 + 0.03) * 50, (c2 - 0.03) * 50, (c3 + 0.03) * 50, (c4 - 0.03) * 50
	local classStr = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:12:12:0:0:50:50:" .. c1 .. ":" .. c2 .. ":" .. c3 .. ":" .. c4 .. "|t "
	return classStr or ""
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

	if not ticker then
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

	if not KkthnxUIDB.Gold[K.Realm] then
		KkthnxUIDB.Gold[K.Realm] = {}
	end

	if not KkthnxUIDB.Gold[K.Realm][K.Name] then
		KkthnxUIDB.Gold[K.Realm][K.Name] = {}
	end

	KkthnxUIDB.Gold[K.Realm][K.Name][1] = GetMoney()
	KkthnxUIDB.Gold[K.Realm][K.Name][2] = K.Class

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
	for _, realm in pairs(crossRealms) do
		if KkthnxUIDB.Gold[realm] then
			for name, value in pairs(KkthnxUIDB.Gold[realm]) do
				if not (realm == K.Realm and name == K.Name) then
					index = index + 1
					if not menuList[index] then
						menuList[index] = {}
					end
					menuList[index].text = K.RGBToHex(K.ColorClass(value[2])) .. Ambiguate(name .. " - " .. realm, "none")
					menuList[index].notCheckable = true
					menuList[index].arg1 = realm
					menuList[index].arg2 = name
					menuList[index].func = clearCharGold
				end
			end
		end
	end
end

local function OnEnter(self)
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
	for _, realm in pairs(crossRealms) do
		local thisRealmList = KkthnxUIDB.Gold[realm]
		if thisRealmList then
			for k, v in pairs(thisRealmList) do
				local name = Ambiguate(k .. " - " .. realm, "none")
				local gold, class = unpack(v)
				local r, g, b = K.ColorClass(class)
				GameTooltip:AddDoubleLine(getClassIcon(class) .. name, K.FormatMoney(gold), r, g, b, 1, 1, 1)
				totalGold = totalGold + gold
			end
		end
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(TOTAL .. ":", K.FormatMoney(totalGold), 0.63, 0.82, 1, 1, 1, 1)

	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("|TInterface\\ICONS\\WoW_Token01:12:12:0:0:50:50:4:46:4:46|t " .. TOKEN_FILTER_LABEL .. ":", K.FormatMoney(C_WowTokenPublic_GetCurrentMarketPrice() or 0), 0.5, 0.7, 1, 1, 1, 1)

	for i = 1, 6 do -- seems unlimit, but use 10 for now, needs review
		local currencyInfo = C_CurrencyInfo_GetBackpackCurrencyInfo(i)
		if not currencyInfo then
			break
		end
		local name, count, icon, currencyID = currencyInfo.name, currencyInfo.quantity, currencyInfo.iconFileID, currencyInfo.currencyTypesID
		if name and i == 1 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(CURRENCY .. ":", 0.5, 0.7, 1)
		end
		if name and count then
			local total = C_CurrencyInfo_GetCurrencyInfo(currencyID).maxQuantity
			local iconTexture = "|T" .. icon .. ":12:12:0:0:50:50:4:46:4:46|t "
			if total > 0 then
				GameTooltip:AddDoubleLine(iconTexture .. name, BreakUpLargeNumbers(count) .. "/" .. K.ShortValue(total), 1, 1, 1, 1, 1, 1)
			else
				GameTooltip:AddDoubleLine(iconTexture .. name, BreakUpLargeNumbers(count), 1, 1, 1, 1, 1, 1)
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
			EasyMenu(menuList, K.EasyMenu, self, -80, 100, "MENU", 1)
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
	GoldDataText = CreateFrame("Button", "KKUI_GoldDataText", UIParent)
	if C["DataText"].Gold then
		GoldDataText:SetPoint("LEFT", UIParent, "LEFT", 0, -302)
		GoldDataText:SetSize(24, 24)

		GoldDataText.Texture = GoldDataText:CreateTexture(nil, "BACKGROUND")
		GoldDataText.Texture:SetPoint("LEFT", GoldDataText, "LEFT", 3, 0)
		GoldDataText.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\DataText\\bags.blp")
		GoldDataText.Texture:SetSize(24, 24)
		GoldDataText.Texture:SetVertexColor(unpack(C["DataText"].IconColor))

		GoldDataText.Text = GoldDataText:CreateFontString(nil, "ARTWORK")
		GoldDataText.Text:SetFontObject(K.UIFont)
		GoldDataText.Text:SetPoint("LEFT", GoldDataText.Texture, "RIGHT", -2, 0)
	end

	for _, event in pairs(eventList) do
		GoldDataText:RegisterEvent(event)
	end

	GoldDataText:SetScript("OnEvent", OnEvent)
	GoldDataText:SetScript("OnEnter", OnEnter)
	GoldDataText:SetScript("OnLeave", OnLeave)
	if C["DataText"].Gold then
		GoldDataText:SetScript("OnMouseUp", OnMouseUp)

		K.Mover(GoldDataText, "GoldDataText", "GoldDataText", { "LEFT", UIParent, "LEFT", 0, -302 })
	end
end
