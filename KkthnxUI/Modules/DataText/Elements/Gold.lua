local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Infobar")

local _G = _G
local pairs = _G.pairs
local string_format = _G.string.format
local table_wipe = _G.table.wipe
local unpack = _G.unpack

local CLASS_ICON_TCOORDS = _G.CLASS_ICON_TCOORDS
local CURRENCY = _G.CURRENCY
local C_CurrencyInfo_GetBackpackCurrencyInfo = _G.C_CurrencyInfo.GetBackpackCurrencyInfo
local C_CurrencyInfo_GetCurrencyInfo = _G.C_CurrencyInfo.GetCurrencyInfo
local C_Timer_NewTicker = _G.C_Timer.NewTicker
local C_WowTokenPublic_GetCurrentMarketPrice = _G.C_WowTokenPublic.GetCurrentMarketPrice
local C_WowTokenPublic_UpdateMarketPrice = _G.C_WowTokenPublic.UpdateMarketPrice
local GameTooltip = _G.GameTooltip
local GetAutoCompleteRealms = _G.GetAutoCompleteRealms
local GetMoney = _G.GetMoney
local GetNumWatchedTokens = _G.GetNumWatchedTokens
local IsControlKeyDown = _G.IsControlKeyDown
local NO = _G.NO
local StaticPopupDialogs = _G.StaticPopupDialogs
local TOTAL = _G.TOTAL
local YES = _G.YES

local slotString = "Bags" .. ": %s%d"
local ticker
local profit = 0
local spent = 0
local oldMoney = 0
local crossRealms = GetAutoCompleteRealms()
local GoldDataText

if not crossRealms or #crossRealms == 0 then
	crossRealms = { [1] = K.Realm }
end

StaticPopupDialogs["RESETGOLD"] = {
	text = "Are you sure to reset the gold count?",
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		for _, realm in pairs(crossRealms) do
			if KkthnxUIDB.Gold.totalGold[realm] then
				wipe(KkthnxUIDB.Gold.totalGold[realm])
			end
		end
		KkthnxUIDB.Gold.totalGold[K.Realm][K.Name] = { GetMoney(), K.Class }
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
	"BN_FRIEND_ACCOUNT_ONLINE",
	"BN_FRIEND_ACCOUNT_OFFLINE",
	"BN_FRIEND_INFO_CHANGED",
	"FRIENDLIST_UPDATE",
	"PLAYER_ENTERING_WORLD",
	"CHAT_MSG_SYSTEM",
}

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
		ticker = C_Timer_NewTicker(60, C_WowTokenPublic_UpdateMarketPrice)
	end

	local newMoney = GetMoney()
	local change = newMoney - oldMoney -- Positive if we gain money
	if oldMoney > newMoney then -- Lost Money
		spent = spent - change
	else -- Gained Moeny
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

	KkthnxUIDB.Gold = KkthnxUIDB.Gold or {}
	KkthnxUIDB.Gold.totalGold = KkthnxUIDB.Gold.totalGold or {}

	if not KkthnxUIDB.Gold.totalGold[K.Realm] then
		KkthnxUIDB.Gold.totalGold[K.Realm] = {}
	end

	if not KkthnxUIDB.Gold.totalGold[K.Realm][K.Name] then
		KkthnxUIDB.Gold.totalGold[K.Realm][K.Name] = {}
	end

	KkthnxUIDB.Gold.ServerID = KkthnxUIDB.Gold.ServerID or {}
	KkthnxUIDB.Gold.ServerID[K.ServerID] = KkthnxUIDB.Gold.ServerID[K.ServerID] or {}
	KkthnxUIDB.Gold.ServerID[K.ServerID][K.Realm] = true

	KkthnxUIDB.Gold.totalGold[K.Realm][K.Name][1] = GetMoney()
	KkthnxUIDB.Gold.totalGold[K.Realm][K.Name][2] = K.Class

	oldMoney = newMoney
end
K.GoldButton_OnEvent = OnEvent

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
	GameTooltip:AddLine(L["RealmCharacter"], 0.5, 0.7, 1)
	for realm in pairs(KkthnxUIDB.Gold.ServerID[K.ServerID]) do
		local thisRealmList = KkthnxUIDB.Gold.totalGold[realm]
		if thisRealmList then
			for k, v in pairs(thisRealmList) do
				local name = Ambiguate(k .. "-" .. realm, "none")
				local gold, class = unpack(v)
				local r, g, b = K.ColorClass(class)
				GameTooltip:AddDoubleLine(getClassIcon(class) .. name, K.FormatMoney(gold), r, g, b, 1, 1, 1)
				totalGold = totalGold + gold
			end
		end
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(TOTAL .. ":", K.FormatMoney(totalGold), 0.63, 0.82, 1, 1, 1, 1)
	if not K.IsFirestorm or not K.IsWoWFreakz then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine("|TInterface\\ICONS\\WoW_Token01:12:12:0:0:50:50:4:46:4:46|t " .. "Token:", K.FormatMoney(C_WowTokenPublic_GetCurrentMarketPrice() or 0), 0.5, 0.7, 1, 1, 1, 1)
	end

	for i = 1, GetNumWatchedTokens() do
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
			local iconTexture = " |T" .. icon .. ":12:12:0:0:50:50:4:46:4:46|t"
			if total > 0 then
				GameTooltip:AddDoubleLine(name, count .. "/" .. total .. iconTexture, 1, 1, 1, 1, 1, 1)
			else
				GameTooltip:AddDoubleLine(name, count .. iconTexture, 1, 1, 1, 1, 1, 1)
			end
		end
	end

	if self == GoldDataText then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(" ", K.RightButton .. "Switch Mode" .. " ", 1, 1, 1, 0.5, 0.7, 1)
		GameTooltip:AddDoubleLine(" ", K.LeftButton .. "Currency Panel" .. " ", 1, 1, 1, 0.5, 0.7, 1)
		GameTooltip:AddDoubleLine(" ", L["Ctrl Key"] .. K.RightButton .. "Reset Gold" .. " ", 1, 1, 1, 0.5, 0.7, 1)
	end
	GameTooltip:Show()
end
K.GoldButton_OnEnter = OnEnter

local RebuildCharList

local function clearCharGold(_, realm, name)
	KkthnxUIDB.Gold.totalGold[realm][name] = nil
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
		if KkthnxUIDB.Gold.totalGold[realm] then
			for name, value in pairs(KkthnxUIDB.Gold.totalGold[realm]) do
				if not (realm == K.Realm and name == K.Name) then
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
end

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
	elseif btn == "MiddleButton" then
		OnEnter(self)
	else
		ToggleCharacter("TokenFrame")
	end
end

local function OnLeave()
	K.HideTooltip()
end
K.GoldButton_OnLeave = OnLeave

function Module:CreateGoldDataText()
	GoldDataText = GoldDataText or CreateFrame("Button", "KKUI_GoldDataText", UIParent)
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
