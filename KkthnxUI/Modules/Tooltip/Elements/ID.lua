local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Tooltip")

local strmatch, format, tonumber, select = string.match, string.format, tonumber, select
local UnitAura, GetItemCount, GetItemInfo, GetUnitName = UnitAura, GetItemCount, GetItemInfo, GetUnitName
local IsPlayerSpell = IsPlayerSpell
local C_CurrencyInfo_GetCurrencyListLink = C_CurrencyInfo.GetCurrencyListLink
local C_MountJournal_GetMountFromSpell = C_MountJournal.GetMountFromSpell
local BAGSLOT, BANK = BAGSLOT, BANK
local LEARNT_STRING = "|cffff0000" .. ALREADY_LEARNED .. "|r"

local types = {
	spell = SPELLS .. "ID:",
	item = ITEMS .. "ID:",
	quest = QUESTS_LABEL .. "ID:",
	talent = TALENT .. "ID:",
	achievement = ACHIEVEMENTS .. "ID:",
	currency = CURRENCY .. "ID:",
	azerite = L["Trait"] .. "ID:",
}

function Module:AddLineForID(id, linkType, noadd)
	if self:IsForbidden() then
		return
	end

	for i = 1, self:NumLines() do
		local line = _G[self:GetName() .. "TextLeft" .. i]
		if not line then
			break
		end
		local text = line:GetText()
		if text and text == linkType then
			return
		end
	end

	if self.__isHoverTip and linkType == types.spell and IsPlayerSpell(id) and C_MountJournal_GetMountFromSpell(id) then
		self:AddLine(LEARNT_STRING)
	end

	if not noadd then
		self:AddLine(" ")
	end

	if linkType == types.item then
		local bagCount = GetItemCount(id)
		local bankCount = GetItemCount(id, true) - bagCount
		local itemStackCount = select(8, GetItemInfo(id))
		if bankCount > 0 then
			self:AddDoubleLine(BAGSLOT .. "/" .. BANK .. ":", K.InfoColor .. bagCount .. "/" .. bankCount)
		elseif bagCount > 0 then
			self:AddDoubleLine(BAGSLOT .. ":", K.InfoColor .. bagCount)
		end
		if itemStackCount and itemStackCount > 1 then
			self:AddDoubleLine(L["Stack Cap"] .. ":", K.InfoColor .. itemStackCount)
		end
	end

	self:AddDoubleLine(linkType, format(K.InfoColor .. "%s|r", id))
	self:Show()
end

function Module:SetHyperLinkID(link)
	if self:IsForbidden() then
		return
	end

	local linkType, id = strmatch(link, "^(%a+):(%d+)")
	if not linkType or not id then
		return
	end

	if linkType == "spell" or linkType == "enchant" or linkType == "trade" then
		Module.AddLineForID(self, id, types.spell)
	elseif linkType == "talent" then
		Module.AddLineForID(self, id, types.talent, true)
	elseif linkType == "quest" then
		Module.AddLineForID(self, id, types.quest)
	elseif linkType == "achievement" then
		Module.AddLineForID(self, id, types.achievement)
	elseif linkType == "item" then
		Module.AddLineForID(self, id, types.item)
	elseif linkType == "currency" then
		Module.AddLineForID(self, id, types.currency)
	end
end

function Module:CreateTooltipID()
	if not C["Tooltip"].ShowIDs then
		return
	end

	-- Update all
	hooksecurefunc(GameTooltip, "SetHyperlink", Module.SetHyperLinkID)
	hooksecurefunc(ItemRefTooltip, "SetHyperlink", Module.SetHyperLinkID)

	-- Spells
	hooksecurefunc(GameTooltip, "SetUnitAura", function(self, ...)
		if self:IsForbidden() then
			return
		end

		local _, _, _, _, _, _, caster, _, _, id = UnitAura(...)
		if id then
			Module.AddLineForID(self, id, types.spell)
		end
		if caster then
			local name = GetUnitName(caster, true)
			local hexColor = K.RGBToHex(K.UnitColor(caster))
			self:AddDoubleLine(L["From"] .. ":", hexColor .. name)
			self:Show()
		end
	end)

	local function UpdateAuraTip(self, unit, auraInstanceID)
		local data = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID)
		if not data then
			return
		end

		local id, caster = data.spellId, data.sourceUnit
		if id then
			Module.AddLineForID(self, id, types.spell)
		end
		if caster then
			local name = GetUnitName(caster, true)
			local hexColor = K.RGBToHex(K.UnitColor(caster))
			self:AddDoubleLine(L["From"] .. ":", hexColor .. name)
			self:Show()
		end
	end
	hooksecurefunc(GameTooltip, "SetUnitBuffByAuraInstanceID", UpdateAuraTip)
	hooksecurefunc(GameTooltip, "SetUnitDebuffByAuraInstanceID", UpdateAuraTip)

	hooksecurefunc("SetItemRef", function(link)
		local id = tonumber(strmatch(link, "spell:(%d+)"))
		if id then
			Module.AddLineForID(ItemRefTooltip, id, types.spell)
		end
	end)

	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, function(self, data)
		if self:IsForbidden() then
			return
		end
		if data.id then
			Module.AddLineForID(self, data.id, types.spell)
		end
	end)

	local function UpdateActionTooltip(self, data)
		if self:IsForbidden() then
			return
		end

		local lineData = data.lines and data.lines[1]
		local tooltipType = lineData and lineData.tooltipType
		if not tooltipType then
			return
		end

		if tooltipType == 0 then --item
			Module.AddLineForID(self, lineData.tooltipID, types.item)
		elseif tooltipType == 1 then --spell
			Module.AddLineForID(self, lineData.tooltipID, types.spell)
		end
	end
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Macro, UpdateActionTooltip)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.PetAction, UpdateActionTooltip)

	-- Items
	local function addItemID(self, data)
		if self:IsForbidden() then
			return
		end
		if data.id then
			Module.AddLineForID(self, data.id, types.item)
		end
	end
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, addItemID)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Toy, addItemID)

	-- Currencies, todo: replace via tooltip processor
	hooksecurefunc(GameTooltip, "SetCurrencyToken", function(self, index)
		local id = tonumber(strmatch(C_CurrencyInfo_GetCurrencyListLink(index), "currency:(%d+)"))
		if id then
			Module.AddLineForID(self, id, types.currency)
		end
	end)
	hooksecurefunc(GameTooltip, "SetCurrencyByID", function(self, id)
		if id then
			Module.AddLineForID(self, id, types.currency)
		end
	end)

	-- Azerite traits
	hooksecurefunc(GameTooltip, "SetAzeritePower", function(self, _, _, id)
		if id then
			Module.AddLineForID(self, id, types.azerite, true)
		end
	end)

	-- Quests
	hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(self)
		if self.questID then
			Module.AddLineForID(GameTooltip, self.questID, types.quest)
		end
	end)
end
