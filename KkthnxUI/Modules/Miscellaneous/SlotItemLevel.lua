local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("ItemLevelCharacter", "AceEvent-3.0", "AceHook-3.0")

-- Sourced: DiabolicUI (Goldpaw)

-- Lua API
local _G = _G
local pairs = pairs
local unpack = unpack

-- WoW API
local GetInventoryItemLink = _G.GetInventoryItemLink
local GetInventorySlotInfo = _G.GetInventorySlotInfo
local GetItemInfo = _G.GetItemInfo

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
				iconBorder:SetAllPoints(normalTexture or child)
				iconBorder:Hide()

				local iconBorderDoubler = child:CreateTexture()
				iconBorderDoubler:SetDrawLayer("OVERLAY")
				iconBorderDoubler:SetAllPoints(iconBorder)
				iconBorderDoubler:SetTexture(iconBorder:GetTexture())
				iconBorderDoubler:SetBlendMode("ADD")
				iconBorderDoubler:Hide()

				hooksecurefunc(iconBorder, "SetVertexColor", function(_, ...) iconBorderDoubler:SetVertexColor(...) end)
				hooksecurefunc(iconBorder, "Show", function() iconBorderDoubler:Show() end)
				hooksecurefunc(iconBorder, "Hide", function() iconBorderDoubler:Hide() end)

				borderCache[child] = iconBorder
			end
		end
	end

	self.buttonCache = buttonCache
	self.borderCache = borderCache
end

function Module:UpdateEquippeditemLevels(event, ...)
	if (event == "UNIT_INVENTORY_CHANGED") then
		local unit = ...
		if (unit ~= "player") then
			return
		end
	end

	for itemButton, itemLevel in pairs(self.buttonCache) do
		local normalTexture = _G[itemButton:GetName().."NormalTexture"] or itemButton:GetNormalTexture()
		if normalTexture then
			--normalTexture:SetVertexColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3], C["Media"].BorderColor[4])
		end

		local slotID = itemButton:GetID()
		local itemLink = GetInventoryItemLink("player", slotID)
		if itemLink then
			local _, _, itemRarity, ilvl = GetItemInfo(itemLink)
			if itemRarity then
				local effectiveLevel, previewLevel, origLevel = GetDetailedItemLevelInfo and GetDetailedItemLevelInfo(itemLink)
				ilvl = effectiveLevel or ilvl

				-- Legion Artifact offhanders report just the base itemLevel, without relic enhancements,
				-- so we're borrowing the itemLevel from the main hand weapon when this happens.
				-- *The constants used are defined in FrameXML/Constants.lua
				if (itemButton:GetID() == _G.INVSLOT_OFFHAND) and (itemRarity == 6) then
					local mainHandLink = GetInventoryItemLink("player", _G.INVSLOT_MAINHAND)
					local _, _, mainHandRarity, mainHandLevel = GetItemInfo(mainHandLink)
					local effectiveLevel, previewLevel, origLevel = GetDetailedItemLevelInfo and GetDetailedItemLevelInfo(mainHandLink)

					mainHandLevel = effectiveLevel or mainHandLevel

					if (mainHandLevel and (mainHandLevel > ilvl)) and (mainHandRarity and (mainHandRarity == 6)) then
						ilvl = mainHandLevel
					end
				end

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
							iconBorder:SetVertexColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3], C["Media"].BorderColor[4])
						end
					else
						iconBorder:Hide()
					end
				else
					iconBorder = self.borderCache[itemButton]
					if iconBorder then
						if itemRarity then
							if (itemRarity >= (LE_ITEM_QUALITY_COMMON + 1)) and GetItemQualityColor(itemRarity) then
								iconBorder:Show()
								iconBorder:SetVertexColor(GetItemQualityColor(itemRarity))
							else
								iconBorder:Show()
								iconBorder:SetVertexColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3], C["Media"].BorderColor[4])
							end
						else
							iconBorder:Hide()
							iconBorder:Show()
							iconBorder:SetVertexColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3], C["Media"].BorderColor[4])
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
					iconBorder:SetVertexColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3], C["Media"].BorderColor[4])
				end
			end
			itemLevel:SetText("")
		end
	end

end

function Module:OnEnable()
	if C["Misc"].ItemLevel ~= true then return end
	self:InitializePaperDoll()

	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateEquippeditemLevels")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "UpdateEquippeditemLevels")
	self:RegisterEvent("ITEM_UPGRADE_MASTER_UPDATE", "UpdateEquippeditemLevels")
	self:RegisterEvent("ITEM_UPGRADE_MASTER_SET_ITEM", "UpdateEquippeditemLevels")
end

function Module:OnDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:UnregisterEvent("ITEM_UPGRADE_MASTER_UPDATE")
	self:UnregisterEvent("ITEM_UPGRADE_MASTER_SET_ITEM")
end