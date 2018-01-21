local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Vendor", "AceEvent-3.0")

local strmatch = string.match
local BlizzardMerchantClick = MerchantItemButton_OnModifiedClick

local VendorList = "\n\nVendor List:\n"

Module.VendorFilter = {
	[41808] = true, -- Bonescale Snapper
	[42336] = true, -- Bloodstone Band
	[42337] = true, -- Sun Rock Ring
	[43244] = true, -- Crystal Citrine Necklace
	[43571] = true, -- Sewer Carp
	[43572] = true, -- Magic Eater
	[6289] = true, -- Raw Longjaw Mud Snapper
	[6291] = true, -- Raw Brilliant Smallfish
	[6308] = true, -- Raw Bristle Whisker Catfish
	[6309] = true, -- 17 Pound Catfish
	[6310] = true, -- 19 Pound Catfish
}

function Module:OnEvent()
	if C["Inventory"].AutoSell or C["Inventory"].AutoSellMisc then
		local Cost = 0

		for Bag = 0, 4 do
			for Slot = 1, GetContainerNumSlots(Bag) do
				local Link, ID = GetContainerItemLink(Bag, Slot), GetContainerItemID(Bag, Slot)

				if (Link and ID and type(Link) == "string") then
					if (strmatch(Link, "battlepet:") or strmatch(Link, "keystone:")) then
						-- Do nothing, never sell/destroy pets or keystones
					else
						local Price = 0
						local Mult1, Mult2 = select(11, GetItemInfo(Link)), select(2, GetContainerItemInfo(Bag, Slot))

						if (Mult1 and Mult2) then
							Price = Mult1 * Mult2
						end

						if (C["Inventory"].AutoSell and select(3, GetItemInfo(Link)) == 0 and Price > 0) then
							UseContainerItem(Bag, Slot)
							PickupMerchantItem()
							Cost = Cost + Price
						end

						if C["Inventory"].AutoSellMisc and self.VendorFilter[ID] then
							UseContainerItem(Bag, Slot)
							PickupMerchantItem()
							Cost = Cost + Price
						end
					end
				end
			end
		end

		if (Cost > 0) then
			local Gold, Silver, Copper = math.floor(Cost / 10000) or 0, math.floor((Cost % 10000) / 100) or 0, Cost % 100

			DEFAULT_CHAT_FRAME:AddMessage(L["Inventory"].SoldTrash.." |cffffffff"..Gold..L["Miscellaneous"].Gold_Short.." |cffffffff"..Silver..L["Miscellaneous"].Silver_Short.." |cffffffff"..Copper..L["Miscellaneous"].Copper_Short..".", 255, 255, 0)
		end
	end

	if (not IsShiftKeyDown()) then
		if (CanMerchantRepair() and C["Inventory"].AutoRepair) then
			local Cost, Possible = GetRepairAllCost()

			if (Cost > 0) then
				if (IsInGuild() and C["Inventory"].UseGuildRepairFunds) then
					local CanGuildRepair = (CanGuildBankRepair() and (Cost <= GetGuildBankWithdrawMoney()))

					if CanGuildRepair then
						RepairAllItems(1)

						return
					end
				end

				if Possible then
					RepairAllItems()

					local Copper = Cost % 100
					local Silver = math.floor((Cost % 10000) / 100)
					local Gold = math.floor(Cost / 10000)
					DEFAULT_CHAT_FRAME:AddMessage(L["Inventory"].RepairCost.." |cffffffff"..Gold..L["Miscellaneous"].Gold_Short.." |cffffffff"..Silver..L["Miscellaneous"].Silver_Short.." |cffffffff"..Copper..L["Miscellaneous"].Copper_Short..".", 255, 255, 0)
				else
					DEFAULT_CHAT_FRAME:AddMessage(L["Inventory"].NotEnoughMoney, 255, 0, 0)
				end
			end
		end
	end
end

function Module:UpdateConfigDescription()
	if (not IsAddOnLoaded("KkthnxUI_Config")) then
		return
	end

	local Locale = GetLocale()
	local Group = KkthnxUIConfig[Locale]["Inventory"]["AutoSellMisc"]

	if Group then
		local Desc = Group.Default
		local Items = Desc..VendorList -- 6.0 localize me

		for i = 1, #self.VendorFilter do
			local Name, Link = GetItemInfo(self.VendorFilter[i])

			if (Name and Link) then
				if i == 1 then
					Items = Items..""..Link
				else
					Items = Items..", "..Link
				end
			end
		end
		KkthnxUIConfig[Locale]["Inventory"]["AutoSellMisc"]["Desc"] = Items
	end
end

function Module:AddItem(id)
	tinsert(self.VendorFilter, id)
	self:UpdateConfigDescription()
end

function Module:RemoveItem(id)
	for i = 1, #self.VendorFilter do
		if (self.VendorFilter[i] == id) then
			tremove(self.VendorFilter, i)
			self:UpdateConfigDescription()

			break
		end
	end
end

function Module:MerchantClick(...)
	if (IsAltKeyDown()) then
		local MaxStack = select(8, GetItemInfo(GetMerchantItemLink(self:GetID())))

		if (MaxStack and MaxStack > 1) then
			BuyMerchantItem(self:GetID(), GetMerchantItemMaxStack(self:GetID()))
		end
	end

	BlizzardMerchantClick(self, ...)
end

function Module:OnEnable()
	self:RegisterEvent("MERCHANT_SHOW", "OnEvent")
	MerchantItemButton_OnModifiedClick = self.MerchantClick
end

function Module:OnDisable()
	self:UnregisterEvent("MERCHANT_SHOW")
	MerchantItemButton_OnModifiedClick = BlizzardMerchantClick
end

Module:UpdateConfigDescription()