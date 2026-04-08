--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Tracks and displays player gold across characters and session profit/loss.
-- - Design: Persistent database for multi-char tracking, session-based delta calculations, and bag slot hybrid mode.
-- - Events: PLAYER_ENTERING_WORLD, PLAYER_MONEY, PLAYER_TRADE_MONEY, BAG_UPDATE, etc.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("DataText")

-- PERF: Localize globals and API functions to reduce lookup overhead.
local _G = _G
local Ambiguate = _G.Ambiguate
local BreakUpLargeNumbers = _G.BreakUpLargeNumbers
local C_Bank_FetchDepositedMoney = _G.C_Bank.FetchDepositedMoney
local C_CurrencyInfo_GetBackpackCurrencyInfo = _G.C_CurrencyInfo.GetBackpackCurrencyInfo
local C_CurrencyInfo_GetCurrencyInfo = _G.C_CurrencyInfo.GetCurrencyInfo
local C_Timer_NewTicker = _G.C_Timer.NewTicker
local C_WowTokenPublic_GetCurrentMarketPrice = _G.C_WowTokenPublic.GetCurrentMarketPrice
local C_WowTokenPublic_UpdateMarketPrice = _G.C_WowTokenPublic.UpdateMarketPrice
local CalculateTotalNumberOfFreeBagSlots = _G.CalculateTotalNumberOfFreeBagSlots
local CreateFrame = _G.CreateFrame
local Enum = _G.Enum
local GameTooltip = _G.GameTooltip
local GetMoney = _G.GetMoney
local IsControlKeyDown = _G.IsControlKeyDown
local IsLoggedIn = _G.IsLoggedIn
local IsShiftKeyDown = _G.IsShiftKeyDown
local StaticPopup_Show = _G.StaticPopup_Show
local ToggleAllBags = _G.ToggleAllBags
local ToggleCharacter = _G.ToggleCharacter
local UIParent = _G.UIParent
local ipairs = ipairs
local math_max = math.max
local pairs = pairs
local print = print
local string_format = string.format
local string_gsub = string.gsub
local table_sort = table.sort
local table_unpack = unpack
local table_wipe = table.wipe
local tostring = tostring
local type = type

-- ---------------------------------------------------------------------------
-- State & Constants
-- ---------------------------------------------------------------------------
local SLOT_STRING = _G.BAGSLOTTEXT .. ": %s%d"
local SHOW_GOLD_GAP = 100 * 10000 -- 100 Gold threshold for character listing.
local goldDataText
local marketTicker
local profit = 0
local spent = 0
local oldMoney = 0
local rebuildCharList

local myName, myRealm = K.Name, K.Realm
myRealm = string_gsub(myRealm, "%s", "")

_G.StaticPopupDialogs["RESETGOLD"] = {
	text = "Are you sure to reset the gold count?",
	button1 = _G.YES,
	button2 = _G.NO,
	OnAccept = function()
		table_wipe(_G.KkthnxUIDB.Gold)
		_G.KkthnxUIDB.Gold[myRealm] = _G.KkthnxUIDB.Gold[myRealm] or {}
		_G.KkthnxUIDB.Gold[myRealm][myName] = { GetMoney(), K.Class, K.Faction }
	end,
	whileDead = 1,
}

local menuList = {
	{
		text = K.RGBToHex(1, 0.8, 0) .. _G.REMOVE_WORLD_MARKERS .. "!!!",
		notCheckable = true,
		func = function()
			StaticPopup_Show("RESETGOLD")
		end,
	},
}

-- ---------------------------------------------------------------------------
-- Utility Functions
-- ---------------------------------------------------------------------------
local function getClassIcon(class)
	-- REASON: Generates an inline class icon texture string for the character gold list.
	local coords = _G.CLASS_ICON_TCOORDS[class]
	if not coords then
		return ""
	end

	local c1, c2, c3, c4 = table_unpack(coords)
	c1, c2, c3, c4 = (c1 + 0.03) * 50, (c2 - 0.03) * 50, (c3 + 0.03) * 50, (c4 - 0.03) * 50
	return "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:12:12:0:0:50:50:" .. c1 .. ":" .. c2 .. ":" .. c3 .. ":" .. c4 .. "|t "
end

local factionIcons = {
	["Horde"] = "UI_HordeIcon",
	["Alliance"] = "UI_AllianceIcon",
	["Unknown"] = "INV_Misc_QuestionMark",
}

local function getFactionIcon(faction)
	-- REASON: Generates an inline faction icon texture string.
	local icon = factionIcons[faction] or "INV_Misc_QuestionMark"
	return "|TInterface\\ICONS\\" .. icon .. ":12:12:0:0:50:50:4:46:4:46|t "
end

local function getSlotString()
	-- REASON: Formats the bag slot count with color coding based on available space.
	local num = CalculateTotalNumberOfFreeBagSlots()
	local color = (num < 10) and "|cffff0000" or "|cff00ff00"
	return string_format(SLOT_STRING, color, num)
end

local function updateMarketPrice()
	return C_WowTokenPublic_UpdateMarketPrice()
end

local function ensureGoldDB()
	-- REASON: Ensures the persistent database structure exists before writing character data.
	_G.KkthnxUIDB.Gold = _G.KkthnxUIDB.Gold or {}
	_G.KkthnxUIDB.Gold[myRealm] = _G.KkthnxUIDB.Gold[myRealm] or {}
	_G.KkthnxUIDB.Gold[myRealm][myName] = _G.KkthnxUIDB.Gold[myRealm][myName] or {}
end

local function updateDisplay(newMoney)
	-- REASON: Updates the on-screen DataText string to either show total gold or available bag slots.
	if not (C["DataText"].Gold and goldDataText and goldDataText.Text) then
		return
	end

	if C["DataText"].HideText then
		goldDataText.Text:SetText("")
	elseif _G.KkthnxUIDB.ShowSlots then
		goldDataText.Text:SetText(getSlotString())
	else
		goldDataText.Text:SetText(K.FormatMoney(newMoney))
	end

	-- REASON: Synchronize the mover width to match the dynamic text width for consistent interaction area.
	local textW = goldDataText.Text:GetStringWidth() or 0
	local iconW = (goldDataText.Texture and goldDataText.Texture:GetWidth()) or 0
	local totalW = textW + iconW
	local textH = goldDataText.Text:GetLineHeight() or 12
	local iconH = (goldDataText.Texture and goldDataText.Texture:GetHeight()) or 12
	local totalH = math_max(textH, iconH)

	goldDataText:SetSize(math_max(totalW, 56), totalH)
	if goldDataText.mover then
		goldDataText.mover:SetSize(math_max(totalW, 56), totalH)
	end
end

-- ---------------------------------------------------------------------------
-- Event Handling Logic
-- ---------------------------------------------------------------------------
local function onEvent(_, event, arg1)
	if not IsLoggedIn() then
		return
	end

	if event == "PLAYER_ENTERING_WORLD" then
		oldMoney = GetMoney()
		if goldDataText then
			goldDataText:UnregisterEvent(event)
			if _G.KkthnxUIDB.ShowSlots then
				goldDataText:RegisterEvent("BAG_UPDATE")
			end
		end
	elseif event == "BAG_UPDATE" then
		-- REASON: Only process primary bag updates to avoid redundant processing on sub-bag changes.
		if arg1 < 0 or arg1 > 4 then
			return
		end
	end

	-- REASON: Periodically refresh WoW Token market prices for the tooltip display.
	if not marketTicker then
		C_WowTokenPublic_UpdateMarketPrice()
		marketTicker = C_Timer_NewTicker(60, updateMarketPrice)
	end

	local newMoney = GetMoney()
	if oldMoney == 0 then
		oldMoney = newMoney
	end

	if event then
		local delta = newMoney - oldMoney
		if delta < 0 then
			spent = spent - delta
		else
			profit = profit + delta
		end
	end

	updateDisplay(newMoney)

	ensureGoldDB()
	_G.KkthnxUIDB.Gold[myRealm][myName][1] = newMoney
	_G.KkthnxUIDB.Gold[myRealm][myName][2] = K.Class
	_G.KkthnxUIDB.Gold[myRealm][myName][3] = K.Faction

	oldMoney = newMoney
end
K.GoldButton_OnEvent = onEvent

local function clearCharGold(_, realm, name)
	-- REASON: Context menu action to remove a specific character's data from the gold tracking database.
	if _G.KkthnxUIDB.Gold and _G.KkthnxUIDB.Gold[realm] then
		_G.KkthnxUIDB.Gold[realm][name] = nil
	end
	if _G.DropDownList1 then
		_G.DropDownList1:Hide()
	end
	rebuildCharList()
end

function rebuildCharList()
	-- REASON: Rebuilds the character menu list used for manual database pruning.
	for i = #menuList, 2, -1 do
		menuList[i] = nil
	end

	if not _G.KkthnxUIDB.Gold then
		return
	end

	local index = 1
	for realm, realmData in pairs(_G.KkthnxUIDB.Gold) do
		for name, charData in pairs(realmData) do
			if not (realm == myRealm and name == myName) then
				index = index + 1
				menuList[index] = menuList[index] or {}
				local entry = menuList[index]
				entry.text = K.RGBToHex(K.ColorClass(charData[2])) .. Ambiguate(name .. "-" .. realm, "none")
				entry.notCheckable = true
				entry.arg1 = realm
				entry.arg2 = name
				entry.func = clearCharGold
			end
		end
	end
end

-- ---------------------------------------------------------------------------
-- Tooltip Logic
-- ---------------------------------------------------------------------------
local function onEnter(self)
	-- REASON: Generates a comprehensive financial overview tooltip, including cross-realm/account summaries and currencies.
	if not self then
		return
	end

	GameTooltip:SetOwner(goldDataText, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(self == goldDataText and goldDataText or self))
	GameTooltip:ClearLines()

	GameTooltip:AddLine(K.InfoColor .. _G.CURRENCY)
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
	GameTooltip:AddLine(_G.CHARACTER_BUTTON .. ":", 0.5, 0.7, 1)

	if _G.KkthnxUIDB.Gold and _G.KkthnxUIDB.Gold[myRealm] then
		for name, charData in pairs(_G.KkthnxUIDB.Gold[myRealm]) do
			local gold, class, faction = charData[1], charData[2], charData[3]
			local shownName = Ambiguate(name .. "-" .. myRealm, "none")

			if gold > SHOW_GOLD_GAP or name == myName then
				local r, g, b = K.ColorClass(class)
				GameTooltip:AddDoubleLine(getFactionIcon(faction) .. getClassIcon(class) .. shownName, K.FormatMoney(gold), r, g, b, 1, 1, 1)
			end
			totalGold = totalGold + gold
		end
	end

	local isShift = IsShiftKeyDown()
	if _G.KkthnxUIDB.Gold then
		for realm, realmData in pairs(_G.KkthnxUIDB.Gold) do
			if realm ~= myRealm then
				for name, charData in pairs(realmData) do
					local gold, class, faction = charData[1], charData[2], charData[3]
					if gold > SHOW_GOLD_GAP then
						if isShift then
							local shownName = Ambiguate(name .. "-" .. realm, "none")
							local r, g, b = K.ColorClass(class)
							GameTooltip:AddDoubleLine(getFactionIcon(faction) .. getClassIcon(class) .. shownName, K.FormatMoney(gold), r, g, b, 1, 1, 1)
						end
						totalGold = totalGold + gold
					end
				end
			end
		end
	end

	if not isShift then
		GameTooltip:AddLine(L["Hold Shift"], 0.63, 0.82, 1)
	end

	local accountBankMoney = C_Bank_FetchDepositedMoney(Enum.BankType.Account) or 0
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(_G.CHARACTER .. ":", K.FormatMoney(totalGold), 0.63, 0.82, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(_G.ACCOUNT_BANK_PANEL_TITLE .. ":", K.FormatMoney(accountBankMoney), 0.63, 0.82, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(_G.TOTAL .. ":", K.FormatMoney(totalGold + accountBankMoney), 0.63, 0.82, 1, 1, 1, 1)

	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("|TInterface\\ICONS\\WoW_Token01:12:12:0:0:50:50:4:46:4:46|t " .. _G.TOKEN_FILTER_LABEL .. ":", K.FormatMoney(C_WowTokenPublic_GetCurrentMarketPrice() or 0), 0.5, 0.7, 1, 1, 1, 1)

	local hasHeader = false
	local tierChargeInfo = C_CurrencyInfo_GetCurrencyInfo(3269) -- Tier charges
	if tierChargeInfo then
		if not hasHeader then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(_G.CURRENCY .. ":", 0.63, 0.82, 1)
			hasHeader = true
		end
		local iconTexture = "|T" .. tierChargeInfo.iconFileID .. ":12:12:0:0:50:50:4:46:4:46|t"
		GameTooltip:AddDoubleLine(iconTexture .. " " .. tierChargeInfo.name, tierChargeInfo.quantity .. "/" .. (tierChargeInfo.maxQuantity or 0), 1, 1, 1, 1, 1, 1)
	end

	for i = 1, 6 do
		local backpackCurrency = C_CurrencyInfo_GetBackpackCurrencyInfo(i)
		if not backpackCurrency then
			break
		end

		local name, count, icon, currencyID = backpackCurrency.name, backpackCurrency.quantity, backpackCurrency.iconFileID, backpackCurrency.currencyID or backpackCurrency.currencyTypesID
		if name and count and currencyID then
			if not hasHeader then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(_G.CURRENCY .. ":", 0.5, 0.7, 1)
				hasHeader = true
			end

			local currencyInfo = C_CurrencyInfo_GetCurrencyInfo(currencyID)
			local totalCap = (currencyInfo and currencyInfo.maxQuantity) or 0
			local iconTextureString = "|T" .. icon .. ":12:12:0:0:50:50:4:46:4:46|t "
			if totalCap > 0 then
				GameTooltip:AddDoubleLine(iconTextureString .. name, BreakUpLargeNumbers(count) .. "/" .. K.ShortValue(totalCap), 1, 1, 1, 1, 1, 1)
			else
				GameTooltip:AddDoubleLine(iconTextureString .. name, BreakUpLargeNumbers(count), 1, 1, 1, 1, 1, 1)
			end
		end
	end

	if self == goldDataText then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(" ", K.RightButton .. "Switch Mode" .. " ", 1, 1, 1, 0.5, 0.7, 1)
		local bindingName = _G.KkthnxUIDB.ShowSlots and _G.BINDING_NAME_TOGGLEBACKPACK or _G.BINDING_NAME_TOGGLECURRENCY
		GameTooltip:AddDoubleLine(" ", K.LeftButton .. bindingName .. " ", 1, 1, 1, 0.5, 0.7, 1)
		GameTooltip:AddDoubleLine(" ", L["Ctrl Key"] .. K.RightButton .. "Reset Gold" .. " ", 1, 1, 1, 0.5, 0.7, 1)
	end

	GameTooltip:Show()
end
K.GoldButton_OnEnter = onEnter

local function onMouseUp(self, btn)
	-- REASON: Handles interaction: Right-click for mode toggle (Gold/Slots), Ctrl+Right-click for reset menu.
	if btn == "RightButton" then
		if IsControlKeyDown() then
			if not menuList[1].isCreated then
				rebuildCharList()
				menuList[1].isCreated = true
			end
			_G.K.LibEasyMenu.Create(menuList, _G.K.EasyMenu, self, -80, 100, "MENU", 1)
		else
			_G.KkthnxUIDB.ShowSlots = not _G.KkthnxUIDB.ShowSlots
			if _G.KkthnxUIDB.ShowSlots then
				goldDataText:RegisterEvent("BAG_UPDATE")
			else
				goldDataText:UnregisterEvent("BAG_UPDATE")
			end
			onEvent()
		end
		onEnter(self)
	else
		-- REASON: Left-click toggles either bags or the currency pane based on current mode.
		if _G.KkthnxUIDB.ShowSlots then
			ToggleAllBags()
		else
			ToggleCharacter("TokenFrame")
		end
	end
end

local function onLeave()
	K.HideTooltip()
end
K.GoldButton_OnLeave = onLeave

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------
function Module:CreateGoldDataText()
	-- REASON: Entry point for the financial DataText element; sets up frame, textures, and event listeners.
	goldDataText = CreateFrame("Frame", nil, UIParent)
	goldDataText:SetHitRectInsets(-16, 0, -10, -10)

	if C["DataText"].Gold then
		goldDataText.Text = K.CreateFontString(goldDataText, 12)
		goldDataText.Text:ClearAllPoints()
		goldDataText.Text:SetPoint("LEFT", goldDataText, "LEFT", 24, 0)

		goldDataText.Texture = goldDataText:CreateTexture(nil, "ARTWORK")
		goldDataText.Texture:SetPoint("LEFT", goldDataText, "LEFT", 0, 2)
		goldDataText.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\DataText\\BagsIcon")
		goldDataText.Texture:SetSize(24, 24)
		goldDataText.Texture:SetVertexColor(table_unpack(C["DataText"].IconColor))
	end

	local eventList = {
		"PLAYER_ENTERING_WORLD",
		"PLAYER_MONEY",
		"PLAYER_TRADE_MONEY",
		"SEND_MAIL_COD_CHANGED",
		"SEND_MAIL_MONEY_CHANGED",
		"TRADE_MONEY_CHANGED",
	}

	for _, eventName in ipairs(eventList) do
		goldDataText:RegisterEvent(eventName)
	end

	goldDataText:SetScript("OnEvent", onEvent)
	goldDataText:SetScript("OnEnter", onEnter)
	goldDataText:SetScript("OnLeave", onLeave)

	if C["DataText"].Gold then
		goldDataText:SetScript("OnMouseUp", onMouseUp)
		-- REASON: Registers the frame with the mover system for user-controlled layout.
		goldDataText.mover = K.Mover(goldDataText, "GoldDT", "GoldDT", { "LEFT", UIParent, "LEFT", 0, -300 }, 56, 12)

		local currentWidth = (goldDataText.Text:GetStringWidth() or 0) + ((goldDataText.Texture and goldDataText.Texture:GetWidth()) or 0)
		goldDataText.mover:SetWidth(math_max(currentWidth, 56))
	end
end
