local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("BagFilter", "AceEvent-3.0", "AceHook-3.0")
if C["Bags"].BagFilter ~= true then return end

local _G = _G
local select = select
local tinsert = table.insert
local tremove = table.remove
local unpack = unpack

local CreateFrame = CreateFrame
local DeleteCursorItem = DeleteCursorItem
local GetContainerItemInfo = _G.GetContainerItemInfo
local GetContainerNumSlots = _G.GetContainerNumSlots
local GetItemInfo = _G.GetItemInfo
local GetLocale = _G.GetLocale
local IsAddOnLoaded = _G.IsAddOnLoaded
local PickupContainerItem = PickupContainerItem

local Link
local TrashList = "\n\nTrash List:\n" -- 6.0 localize me

Module.Trash = {
	32902, -- Bottled Nethergon Energy
	32905, -- Bottled Nethergon Vapor
	32897, -- Mark of the Illidari
}

function Module:GetTrash(event)
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			Link = select(7, GetContainerItemInfo(bag, slot))

			for i = 1, #self.Trash do
				if (Link and (GetItemInfo(Link) == GetItemInfo(self.Trash[i]))) then
					PickupContainerItem(bag, slot)
					DeleteCursorItem()
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
	local Group = KkthnxUIConfig[Locale]["Bags"]["BagFilter"]

	if Group then
		local Desc = Group.Default
		local Items = Desc .. TrashList -- 6.0 localize me

		for i = 1, #self.Trash do
			local Name, Link = GetItemInfo(self.Trash[i])

			if (Name and Link) then
				if i == 1 then
					Items = Items .. "" .. Link
				else
					Items = Items .. ", " .. Link
				end
			end
		end

		KkthnxUIConfig[Locale]["Bags"]["BagFilter"]["Desc"] = Items
	end
end

function Module:AddItem(id)
	tinsert(self.Trash, id)

	self:UpdateConfigDescription()
end

function Module:RemoveItem(id)
	for i = 1, #self.Trash do
		if (self.Trash[i] == id) then
			tremove(self.Trash, i)
			self:UpdateConfigDescription()

			break
		end
	end
end

function Module:OnEnable()
	self:RegisterEvent("CHAT_MSG_LOOT", "GetTrash")
end

function Module:OnDisable()
	self:UnregisterEvent("CHAT_MSG_LOOT")
end

Module:UpdateConfigDescription()

K["BagFilter"] = Module