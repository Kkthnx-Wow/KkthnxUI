local K, C = unpack(select(2, ...))
local Module = K:NewModule("SlotItemLevel", "AceEvent-3.0", "AceHook-3.0")

-- Sourced: DiabolicUI (Goldpaw)

-- Lua API
local _G = _G
local pairs = pairs
local string_find = string.find
local string_gsub = string.gsub
local string_match = string.match
local tonumber = tonumber

-- WoW API
local GetAchievementInfo = _G.GetAchievementInfo
-- local GetDetailedItemLevelInfo = _G.GetDetailedItemLevelInfo
local GetInventoryItemLink = _G.GetInventoryItemLink
local GetItemInfo = _G.GetItemInfo

local CRUCIBLE = select(4, GetAchievementInfo(12072))

-- Tooltip used for scanning
local scannerTip = CreateFrame("GameTooltip", "PaperDollScannerTooltip", WorldFrame, "GameTooltipTemplate")
local scannerName = scannerTip:GetName()

-- Tooltip and scanning by Phanx @ http://www.wowinterface.com/forums/showthread.php?p=271406
local S_ITEM_LEVEL = "^" .. string_gsub(_G.ITEM_LEVEL, "%%d", "(%%d+)")

function Module:InitializePaperDoll()
	local buttonCache = {}
	local borderCache = {} -- Cache of custom old client borders

	-- The ItemsFrame was added in Cata when the character frame was upgraded to the big one
	local paperDoll = _G.PaperDollItemsFrame or _G.PaperDollFrame

	for i = 1, select("#", paperDoll:GetChildren()) do
		local child = select(i, paperDoll:GetChildren())
		local childName = child:GetName()

		if (child:GetObjectType() == "Button") and (childName and childName:find("Slot")) then
			local itemLevel = child:CreateFontString()
			itemLevel:SetDrawLayer("OVERLAY")
			itemLevel:SetPoint("TOPLEFT", 2, -2)
			itemLevel:SetFontObject(KkthnxUIFontOutline or _G.NumberFontNormal)

			buttonCache[child] = itemLevel

			local iconBorder = child.IconBorder
			if (not iconBorder) then
				local iconBorder = child:CreateTexture()
				iconBorder:SetDrawLayer("ARTWORK")
				iconBorder:SetTexture([[Interface\Buttons\UI-Quickslot2]])
				iconBorder:SetAllPoints(child)
				iconBorder:Hide()

				local iconBorderDoubler = child:CreateTexture()
				iconBorderDoubler:SetDrawLayer("OVERLAY")
				iconBorderDoubler:SetAllPoints(iconBorder)
				iconBorderDoubler:SetTexture(iconBorder:GetTexture())
				iconBorderDoubler:SetBlendMode("ADD")
				iconBorderDoubler:Hide()

				hooksecurefunc(
					iconBorder,
					"SetVertexColor",
					function(_, ...)
						iconBorderDoubler:SetVertexColor(...)
					end
				)
				hooksecurefunc(
					iconBorder,
					"Show",
					function()
						iconBorderDoubler:Show()
					end
				)
				hooksecurefunc(
					iconBorder,
					"Hide",
					function()
						iconBorderDoubler:Hide()
					end
				)

				borderCache[child] = iconBorder
			end
		end
	end

	self.buttonCache = buttonCache
	self.borderCache = borderCache
end

function Module:GetInventorySlotItemData(slotID)
	local itemLink = GetInventoryItemLink("player", slotID)
	if itemLink then
		local _, _, itemRarity, ilvl = GetItemInfo(itemLink)
		if itemRarity then
			local scannerLevel
			scannerTip.owner = self
			scannerTip:SetOwner(UIParent, "ANCHOR_NONE")
			scannerTip:SetInventoryItem("player", slotID)

			local line = _G[scannerName .. "TextLeft2"]
			if line then
				local msg = line:GetText()
				if msg and string_find(msg, S_ITEM_LEVEL) then
					local iLevel = string_match(msg, S_ITEM_LEVEL)
					if iLevel and (tonumber(iLevel) > 0) then
						return itemLink, itemRarity, iLevel
					end
				else
					-- Check line 3, some artifacts have the ilevel there.
					-- *an example is demon hunter artifacts, which have their names on 2 lines
					line = _G[scannerName .. "TextLeft3"]
					if line then
						local msg = line:GetText()
						if msg and string_find(msg, S_ITEM_LEVEL) then
							local iLevel = string_match(msg, S_ITEM_LEVEL)
							if iLevel and (tonumber(iLevel) > 0) then
								return itemLink, itemRarity, iLevel
							end
						end
					end
				end
			end

		-- We're probably still in patch 7.1.5 or not in Legion at all if we made it to this point, so normal checks will suffice
		-- local effectiveLevel, previewLevel, origLevel = GetDetailedItemLevelInfo and GetDetailedItemLevelInfo(itemLink)
		-- ilvl = effectiveLevel or ilvl
		end
		return itemLink, itemRarity, ilvl
	end
end

function Module:UpdateEquippeditemLevels(event, ...)
	if (event == "UNIT_INVENTORY_CHANGED") then
		local unit = ...
		if (unit ~= "player") then
			return
		end
	end

	for itemButton, itemLevel in pairs(self.buttonCache) do
		local normalTexture = _G[itemButton:GetName() .. "NormalTexture"] or itemButton:GetNormalTexture()
		local itemLink, itemRarity, ilvl = self:GetInventorySlotItemData(itemButton:GetID())
		if itemLink then
			if itemRarity then
				local r, g, b = GetItemQualityColor(itemRarity)
				itemLevel:SetTextColor(r, g, b)
				itemLevel:SetText(ilvl or "")

				local iconBorder = itemButton.IconBorder
				if iconBorder then
					iconBorder:SetTexture([[Interface\Common\WhiteIconFrame]])
					if itemRarity then
						if (itemRarity >= (LE_ITEM_QUALITY_COMMON + 1)) and GetItemQualityColor(itemRarity) then
							iconBorder:Show()
							iconBorder:SetVertexColor(GetItemQualityColor(itemRarity))
						else
							iconBorder:Show()
							iconBorder:SetVertexColor(
								C["Media"].BorderColor[1],
								C["Media"].BorderColor[2],
								C["Media"].BorderColor[3],
								C["Media"].BorderColor[4]
							)
						end
					else
						iconBorder:Hide()
					end
				else
					iconBorder = self.borderCache[itemButton]
					if iconBorder then
						if itemRarity then
							if (itemRarity >= (LE_ITEM_QUALITY_COMMON + 1)) and (GetItemQualityColor(itemRarity)) then
								iconBorder:Show()
								iconBorder:SetVertexColor(GetItemQualityColor(itemRarity))
							else
								iconBorder:Show()
								iconBorder:SetVertexColor(
									C["Media"].BorderColor[1],
									C["Media"].BorderColor[2],
									C["Media"].BorderColor[3],
									C["Media"].BorderColor[4]
								)
							end
						else
							iconBorder:Hide()
							iconBorder:Show()
							iconBorder:SetVertexColor(
								C["Media"].BorderColor[1],
								C["Media"].BorderColor[2],
								C["Media"].BorderColor[3],
								C["Media"].BorderColor[4]
							)
						end
					end
				end
			else
				itemLevel:SetTextColor(1, 1, 0)
			end
			if ilvl then
				itemLevel:SetText(ilvl)
			else
				itemLevel:SetText("")
			end
		else
			local iconBorder = itemButton.IconBorder
			if iconBorder then
				iconBorder:Hide()
			else
				iconBorder = self.borderCache[itemButton]
				if iconBorder then
					iconBorder:Show()
					iconBorder:SetVertexColor(
						C["Media"].BorderColor[1],
						C["Media"].BorderColor[2],
						C["Media"].BorderColor[3],
						C["Media"].BorderColor[4]
					)
				end
			end
			itemLevel:SetText("")
		end
	end
end

function Module:CrucibleAchievementListener(event, id)
	if (id == 12072) then
		CRUCIBLE = true
		self:UnregisterEvent("ACHIEVEMENT_EARNED", "CrucibleAchievementListener")
		self:UpdateEquippeditemLevels()
	end
end

function Module:OnInitialize()
	if C["Misc"].ItemLevel ~= true then
		return
	end

	self:InitializePaperDoll()

	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateEquippeditemLevels")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "UpdateEquippeditemLevels")
	self:RegisterEvent("ITEM_UPGRADE_MASTER_UPDATE", "UpdateEquippeditemLevels")
	self:RegisterEvent("ITEM_UPGRADE_MASTER_SET_ITEM", "UpdateEquippeditemLevels")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED", "UpdateEquippeditemLevels")

	-- Adding in compatibility with the 7.3.0 upgraded artifact relic itemlevels
	if (not CRUCIBLE) then
		self:RegisterEvent("ACHIEVEMENT_EARNED", "CrucibleAchievementListener")
	end
end
