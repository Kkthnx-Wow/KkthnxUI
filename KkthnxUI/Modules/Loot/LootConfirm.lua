local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("LootConfirm", "AceEvent-3.0")

local _G = _G

local GetLocale = _G.GetLocale
local GetItemInfo = _G.GetItemInfo
local GetLootRollItemLink = _G.GetLootRollItemLink
local IsAddOnLoaded = _G.IsAddOnLoaded
local UIParent = _G.UIParent
local RollOnLoot = _G.RollOnLoot
local StaticPopup_OnClick = _G.StaticPopup_OnClick
local GetLootRollItemInfo = _G.GetLootRollItemInfo

Module.NeedLoot = {
	[124124] = true,
	[33865 ] = true,
	[43102 ] = true,
	[52078 ] = true,
	[140222] = true,
}

function Module:AutoConfirm(event, id)
	if C["Loot"].AutoDisenchant ~= true then
		return
	end

	for i = 1, _G.STATICPOPUP_NUMDIALOGS do
		local frame = _G["StaticPopup"..i]
		if (frame.which == "CONFIRM_LOOT_ROLL" or frame.which == "LOOT_BIND") and frame:IsVisible() then
			StaticPopup_OnClick(frame, 1)
		end
	end
end

function Module:START_LOOT_ROLL(event, id)
	if C["Loot"].AutoGreed ~= true or K.Level <= C["Loot"].AutoGreedLevel then
		return
	end

	local _, name, _, quality, BoP, canNeed, _, canDisenchant = GetLootRollItemInfo(id)
	if id and quality == 2 and not BoP then
		for i in pairs(Module.NeedLoot) do
			local itemName = GetItemInfo(Module.NeedLoot[i])
			if name == itemName and canNeed then
				RollOnLoot(id, 1)
				return
			end
		end
		local link = GetLootRollItemLink(id)
		local _, _, _, ilevel = GetItemInfo(link)
		if canDisenchant and ilevel > 482 then
			RollOnLoot(id, 3)
		else
			RollOnLoot(id, 2)
		end
	end
end

function Module:UpdateConfigDescription()
	if (not IsAddOnLoaded("KkthnxUI_Config")) then
		return
	end

	local Locale = GetLocale()
	local Group = KkthnxUIConfig[Locale]["Loot"]["AutoGreed"]

	if Group then
		local Desc = Group.Default
		local Items = Desc.."|n|nAuto Greed List:|n"

		for itemID in pairs(self.NeedLoot) do
			local Name, Link = GetItemInfo(itemID)
			if (Name and Link) then
				if itemID == 1 then
					Items = Items..""..Link
				else
					Items = Items.."\n"..Link
				end
			end
		end
		KkthnxUIConfig[Locale]["Loot"]["AutoGreed"]["Desc"] = Items
	end
end

function Module:AddItem(itemID)
	self.NeedLoot[itemID] = true
	self:UpdateConfigDescription()
end

function Module:RemoveItem(itemID)
	self.NeedLoot[itemID] = nil
	self:UpdateConfigDescription()
end

function Module:OnEnable()
	if C["Loot"].AutoDisenchant == true then
		UIParent:UnregisterEvent("LOOT_BIND_CONFIRM")
		UIParent:UnregisterEvent("CONFIRM_DISENCHANT_ROLL")
		UIParent:UnregisterEvent("CONFIRM_LOOT_ROLL")

		self:RegisterEvent("CONFIRM_DISENCHANT_ROLL", "AutoConfirm")
		self:RegisterEvent("CONFIRM_LOOT_ROLL", "AutoConfirm")
		self:RegisterEvent("LOOT_BIND_CONFIRM", "AutoConfirm")
	end

	if C["Loot"].AutoGreed == true or K.Level >= C["Loot"].AutoGreedLevel then
		self:RegisterEvent("START_LOOT_ROLL")
	end
end
Module:UpdateConfigDescription()