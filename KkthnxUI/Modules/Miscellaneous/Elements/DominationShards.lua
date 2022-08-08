local K, _, L = unpack(KkthnxUI)
local Module = K:GetModule("Miscellaneous")
local TT = K:GetModule("Tooltip")

local _G = _G
local math_floor = _G.math.floor
local table_wipe = _G.table.wipe
local pairs = _G.pairs
local mod = _G.mod

local InCombatLockdown = _G.InCombatLockdown
local PickupContainerItem = _G.PickupContainerItem
local ClickSocketButton = _G.ClickSocketButton
local ClearCursor = _G.ClearCursor
local GetContainerNumSlots = _G.GetContainerNumSlots
local GetContainerItemID = _G.GetContainerItemID
local GetContainerItemLink = _G.GetContainerItemLink
local GetItemIcon = _G.GetItemIcon
local GetItemCount = _G.GetItemCount
local GetSocketTypes = _G.GetSocketTypes
local GetExistingSocketInfo = _G.GetExistingSocketInfo

local EXTRACTOR_ID = 187532
local foundShards = {}

function Module:DomiShard_Equip()
	if not self.itemLink then
		return
	end

	PickupContainerItem(self.bagID, self.slotID)
	ClickSocketButton(1)
	ClearCursor()
end

function Module:DomiShard_ShowTooltip()
	if not self.itemLink then
		return
	end

	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
	GameTooltip:SetHyperlink(self.itemLink)
	GameTooltip:Show()
end

function Module:DomiShards_Refresh()
	table_wipe(foundShards)

	for bagID = 0, 4 do
		for slotID = 1, GetContainerNumSlots(bagID) do
			local itemID = GetContainerItemID(bagID, slotID)
			local rank = itemID and TT.DomiRankData[itemID]
			if rank then
				local index = TT.DomiIndexData[itemID]
				if not index then
					break
				end

				local button = Module.DomiShardsFrame.icons[index]
				button.bagID = bagID
				button.slotID = slotID
				button.itemLink = GetContainerItemLink(bagID, slotID)
				button.count:SetText(rank)
				button.Icon:SetDesaturated(false)

				foundShards[index] = true
			end
		end
	end

	for index, button in pairs(Module.DomiShardsFrame.icons) do
		if not foundShards[index] then
			button.itemLink = nil
			button.count:SetText("")
			button.Icon:SetDesaturated(true)
		end
	end
end

function Module:DomiShards_ListFrame()
	if Module.DomiShardsFrame then
		return
	end

	local iconSize = 28
	local frameSize = iconSize * 3

	local frame = CreateFrame("Frame", "KKUI_DomiShards", ItemSocketingFrame)
	frame:SetSize(frameSize, frameSize)
	frame:SetPoint("BOTTOMLEFT", 32, 3)
	frame.icons = {}
	Module.DomiShardsFrame = frame

	for index, value in pairs(TT.DomiDataByGroup) do
		for itemID in pairs(value) do
			local button = CreateFrame("Button", nil, frame)
			button:SetSize(iconSize, iconSize)
			button:SetPoint("TOPLEFT", mod(index - 1, 3) * iconSize, -math_floor((index - 1) / 3) * iconSize)

			button.Icon = button:CreateTexture(nil, "ARTWORK")
			button.Icon:SetTexture(GetItemIcon(itemID))
			button.Icon:SetAllPoints()
			button.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

			button:CreateBorder()

			button:SetScript("OnClick", Module.DomiShard_Equip)
			button:SetScript("OnEnter", Module.DomiShard_ShowTooltip)
			button:SetScript("OnLeave", K.HideTooltip)
			button.count = K.CreateFontString(button, 14, "", "", "system", "BOTTOMRIGHT", -3, 3)

			frame.icons[index] = button
			break
		end
	end

	Module:DomiShards_Refresh()
	K:RegisterEvent("BAG_UPDATE", Module.DomiShards_Refresh)
end

function Module:DomiShards_ExtractButton()
	if Module.DomiExtButton then
		return
	end

	if GetItemCount(EXTRACTOR_ID) == 0 then
		return
	end
	ItemSocketingSocketButton:SetWidth(80)
	if InCombatLockdown() then
		return
	end

	local button = CreateFrame("Button", "KKUI_ExtractorButton", ItemSocketingFrame, "UIPanelButtonTemplate, SecureActionButtonTemplate")
	button:SetSize(80, 22)
	button:SetText(L["Drop"])
	button:SetPoint("RIGHT", ItemSocketingSocketButton, "LEFT", -3, 0)
	button:SetAttribute("type", "macro")
	button:SetAttribute("macrotext", "/use item:" .. EXTRACTOR_ID .. "\n/click ItemSocketingSocket1")

	Module.DomiExtButton = button
end

function Module:CreateDominationShards()
	hooksecurefunc("ItemSocketingFrame_LoadUI", function()
		if not ItemSocketingFrame then
			return
		end

		Module:DomiShards_ListFrame()
		Module:DomiShards_ExtractButton()

		if Module.DomiShardsFrame then
			Module.DomiShardsFrame:SetShown(GetSocketTypes(1) == "Domination" and not GetExistingSocketInfo(1))
		end

		if Module.DomiExtButton then
			Module.DomiExtButton:SetAlpha(GetSocketTypes(1) == "Domination" and GetExistingSocketInfo(1) and 1 or 0)
		end
	end)
end

Module:RegisterMisc("DomiShards", Module.CreateDominationShards)
