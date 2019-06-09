local K = unpack(select(2, ...))

if not K.Name == "Upright" or K.Name == "Kkthnxtv" or K.Name == "Deadarroww" and not K.Realm == "Sethraliss" then -- Only For People Who Will Test These Lame Ass New Features.
	return
end

local _G = _G

local ShortStringThing = _G.CreateFrame("Frame")
ShortStringThing:RegisterEvent("PLAYER_LOGIN")
ShortStringThing:RegisterEvent("MAIL_SHOW")
ShortStringThing:RegisterEvent("MAIL_CLOSED")

local function ShortStringThing_EventHandler(_, event)
	if event == "MAIL_SHOW" then
		_G.COPPER_AMOUNT = "%d Copper"
		_G.SILVER_AMOUNT = "%d Silver"
		_G.GOLD_AMOUNT = "%d Gold"
	else
		_G.COPPER_AMOUNT = "%d|cFF954F28".._G.COPPER_AMOUNT_SYMBOL.."|r"
		_G.SILVER_AMOUNT = "%d|cFFC0C0C0".._G.SILVER_AMOUNT_SYMBOL.."|r"
		_G.GOLD_AMOUNT = "%d|cFFF0D440".._G.GOLD_AMOUNT_SYMBOL.."|r"
	end

	_G.BATTLE_PET_LOOT_RECEIVED = "+ "
	_G.CURRENCY_GAINED = "+ %s +"
	_G.CURRENCY_GAINED_MULTIPLE = "+ %s x%d +"
	_G.CURRENCY_GAINED_MULTIPLE_BONUS = "+ %s x%d (Bonus Objective) +"
	_G.CURRENCY_LOST_FROM_DEATH = "Lost - %s x%d -"
	_G.LOOT_CURRENCY_REFUND = "Refunded - %s x%d -"
	_G.LOOT_DISENCHANT_CREDIT = "%s Disenchanted - %s -"
	_G.LOOT_ITEM = "%s + %s +"
	_G.LOOT_ITEM_BONUS_ROLL = "%s + %s Bonus +"
	_G.LOOT_ITEM_BONUS_ROLL_MULTIPLE = "%s + %sx%d Bonus +"
	_G.LOOT_ITEM_BONUS_ROLL_SELF = "+ %s Bonus +"
	_G.LOOT_ITEM_BONUS_ROLL_SELF_MULTIPLE = "+ %sx%d Bonus +"
	_G.LOOT_ITEM_CREATED_SELF = "+ %s +"
	_G.LOOT_ITEM_CREATED_SELF_MULTIPLE = "+ %sx%d +"
	_G.LOOT_ITEM_MULTIPLE = "%s + %sx%d +"
	_G.LOOT_ITEM_PUSHED = "%s + %s +"
	_G.LOOT_ITEM_PUSHED_MULTIPLE = "%s + %sx%d +"
	_G.LOOT_ITEM_PUSHED_SELF = "+ %s +"
	_G.LOOT_ITEM_PUSHED_SELF = "+ %s +"
	_G.LOOT_ITEM_PUSHED_SELF_MULTIPLE = "+ %sx%d +"
	_G.LOOT_ITEM_PUSHED_SELF_MULTIPLE = "+ %sx%d +"
	_G.LOOT_ITEM_REFUND = "Refunded - %s -"
	_G.LOOT_ITEM_REFUND_MULTIPLE = "Refunded - %sx%d -"
	_G.LOOT_ITEM_SELF = "+ %s +"
	_G.LOOT_ITEM_SELF_MULTIPLE = "+ %sx%d +"
	_G.LOOT_MONEY_SPLIT = "+ %s"
	_G.YOU_LOOT_MONEY = "+ %s"
end

ShortStringThing:SetScript("OnEvent", ShortStringThing_EventHandler)

--------------------------------------------------------------------

local errorMessages = {
	[ERR_ATTACK_MOUNTED]			= true,
	[ERR_MOUNT_ALREADYMOUNTED]		= true,
	[ERR_NOT_WHILE_MOUNTED]			= true,
	[ERR_TAXIPLAYERALREADYMOUNTED]	= true,
	[SPELL_FAILED_NOT_MOUNTED]		= true,
}

local AutoDismount = CreateFrame("Frame")
AutoDismount:RegisterEvent("UI_ERROR_MESSAGE")

local function CheckDismount(self, event, ...)
	if not IsMounted() or not errorMessages[select(2, ...)] then
		return
	end

	Dismount()
	UIErrorsFrame:Clear()
end

AutoDismount:SetScript("OnEvent", CheckDismount)