local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Automation")

-- Auto opening of items in bag (kAutoOpen by Kellett)

local _G = _G

local C_Container_GetContainerItemInfo = _G.C_Container.GetContainerItemInfo
local C_Container_GetContainerItemLink = _G.C_Container.GetContainerItemLink
local C_Container_GetContainerNumSlots = _G.C_Container.GetContainerNumSlots
local OPENING = _G.OPENING

local openFrames = {} -- table to store which frames are open

local function BankOpened()
	openFrames.bank = true -- set the bank frame as open
end

local function BankClosed()
	openFrames.bank = false -- set the bank frame as closed
end

local function GuildBankOpened()
	openFrames.guildBank = true -- set the guild bank frame as open
end

local function GuildBankClosed()
	openFrames.guildBank = false -- set the guild bank frame as closed
end

local function MailOpened()
	openFrames.mail = true -- set the mail frame as open
end

local function MailClosed()
	openFrames.mail = false -- set the mail frame as closed
end

local function MerchantOpened()
	openFrames.merchant = true -- set the merchant frame as open
end

local function MerchantClosed()
	openFrames.merchant = false -- set the merchant frame as closed
end

local function BagDelayedUpdate(event)
	-- check if the bank, mail, or merchant frames are open
	if openFrames.bank or openFrames.mail or openFrames.merchant then
		return
	end

	-- variable to store the itemID of the opened item
	local openedItemID

	-- check if the player is in combat lockdown
	if InCombatLockdown() then
		-- register the "PLAYER_REGEN_ENABLED" event to update the bag contents after combat
		K:RegisterEvent("PLAYER_REGEN_ENABLED", BagDelayedUpdate)
	else
		-- loop through all the bags
		for bag = 0, 4 do
			-- loop through all the slots in the bag
			for slot = 0, C_Container_GetContainerNumSlots(bag) do
				-- get the container item information
				local cInfo = C_Container_GetContainerItemInfo(bag, slot)

				-- check if the item has loot, is not locked and has an itemID
				if cInfo and cInfo.hasLoot and not cInfo.isLocked and cInfo.itemID then
					-- check if the item is in the list of items to automatically open
					openedItemID = C.AutoOpenItems[cInfo.itemID]
					if openedItemID then
						-- exit the inner loop
						break
					end
				end
			end
			if openedItemID then
				break
			end
		end
		if openedItemID then
			K.Print(K.SystemColor .. OPENING .. ":|r " .. C_Container_GetContainerItemLink(bag, slot))
			C_Container.UseContainerItem(bag, slot)
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
