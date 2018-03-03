local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("BagFilter", "AceEvent-3.0")

-- Sourced: Tukui (Tukz)
-- Modified: KkthnxUI (Kkthnx)

local _G = _G
local select = select
local table_insert = table.insert
local table_remove = table.remove
local unpack = unpack

local CreateFrame = _G.CreateFrame
local GetContainerItemInfo = _G.GetContainerItemInfo
local GetContainerNumSlots = _G.GetContainerNumSlots
local GetItemInfo = _G.GetItemInfo
local GetLocale = _G.GetLocale
local IsAddOnLoaded = _G.IsAddOnLoaded
local GetContainerItemID = _G.GetContainerItemID

Module.Trash = {
    -- TBC - Dungeon/Raid items
    [32897] = true, -- Mark of the Illidari
    [32902] = true, -- Bottled Nethergon Energy
    [32905] = true, -- Bottled Nethergon Vapor
}

local Link

function Module:GetTrash(event)
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local itemID = GetContainerItemID(bag, slot)
            if itemID and self.Trash[itemID] then
                PickupContainerItem(bag, slot)
                DeleteCursorItem()
            end
        end
    end
end

function Module:UpdateConfigDescription()
    if (not IsAddOnLoaded("KkthnxUI_Config")) then
        return
    end

    local Locale = GetLocale()
    local Group = KkthnxUIConfig[Locale]["Inventory"]["BagFilter"]

    if Group then
        local Desc = Group.Default
        local Items = Desc..L["Inventory"].TrashList

        for itemID in pairs(self.Trash) do
            local Name, Link = GetItemInfo(itemID)
            if (Name and Link) then
                if itemID == 1 then
                    Items = Items..""..Link
                else
                    Items = Items.."\n"..Link
                end
            end
        end
        KkthnxUIConfig[Locale]["Inventory"]["BagFilter"]["Desc"] = Items
    end
end

function Module:AddItem(itemID)
    self.Trash[itemID] = true
    self:UpdateConfigDescription()
end

function Module:RemoveItem(itemID)
    self.Trash[itemID] = nil
    self:UpdateConfigDescription()
end

function Module:OnEnable()
    if K.CheckAddOnState("Felsong_Companion") or C["Inventory"].BagFilter ~= true then
        return
    end
    self:RegisterEvent("CHAT_MSG_LOOT", "GetTrash")
end

function Module:OnDisable()
    self:UnregisterEvent("CHAT_MSG_LOOT")
end
Module:UpdateConfigDescription()

K["BagFilter"] = Module