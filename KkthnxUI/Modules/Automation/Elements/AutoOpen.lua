local K, C = unpack(select(2, ...))
local Module = K:GetModule("Automation")

-- Auto opening of items in bag (kAutoOpen by Kellett)

local _G = _G

local GetContainerNumSlots = _G.GetContainerNumSlots
local GetContainerItemInfo = _G.GetContainerItemInfo
local OPENING = _G.OPENING
local GetContainerItemLink = _G.GetContainerItemLink

local atBank, atMail, atMerchant

local function BankOpened()
	atBank = true
end

local function BankClosed()
	atBank = false
end

local function GuildBankOpened()
	atBank = true
end

local function GuildBankClosed()
	atBank = false
end

local function MailOpened()
	atMail = true
end

local function MailClosed()
	atMail = false
end

local function MerchantOpened()
	atMerchant = true
end

local function MerchantClosed()
	atMerchant = false
end

local function BagDelayedUpdate()
	if atBank or atMail or atMerchant then
		return
	end

	for bag = 0, 4 do
		for slot = 0, GetContainerNumSlots(bag) do
			local _, _, locked, _, _, lootable, _, _, _, id = GetContainerItemInfo(bag, slot)
			if lootable and not locked and id and C.AutoOpenItems[id] then
				K.Print(K.SystemColor..OPENING..":|r "..GetContainerItemLink(bag, slot))
				UseContainerItem(bag, slot)
				return
			end
		end
	end
end

function Module:CreateAutoOpenItems()
	if C["Automation"].AutoOpenItems then
		K:RegisterEvent("BANKFRAME_OPENED", BankOpened)
		K:RegisterEvent("BANKFRAME_CLOSED", BankClosed)
		K:RegisterEvent("GUILDBANKFRAME_OPENED", GuildBankOpened)
		K:RegisterEvent("GUILDBANKFRAME_CLOSED", GuildBankClosed)
		K:RegisterEvent("MAIL_SHOW", MailOpened)
		K:RegisterEvent("MAIL_CLOSED", MailClosed)
		K:RegisterEvent("MERCHANT_SHOW", MerchantOpened)
		K:RegisterEvent("MERCHANT_CLOSED", MerchantClosed)
		K:RegisterEvent("BAG_UPDATE_DELAYED", BagDelayedUpdate)
	else
		K:UnregisterEvent("BANKFRAME_OPENED", BankOpened)
		K:UnregisterEvent("BANKFRAME_CLOSED", BankClosed)
		K:UnregisterEvent("GUILDBANKFRAME_OPENED", GuildBankOpened)
		K:UnregisterEvent("GUILDBANKFRAME_CLOSED", GuildBankClosed)
		K:UnregisterEvent("MAIL_SHOW", MailOpened)
		K:UnregisterEvent("MAIL_CLOSED", MailClosed)
		K:UnregisterEvent("MERCHANT_SHOW", MerchantOpened)
		K:UnregisterEvent("MERCHANT_CLOSED", MerchantClosed)
		K:UnregisterEvent("BAG_UPDATE_DELAYED", BagDelayedUpdate)
	end
end