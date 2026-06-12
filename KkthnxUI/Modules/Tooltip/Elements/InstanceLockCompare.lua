--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Displays your instance lock status in a secondary tooltip for comparison.
-- - Design: Hooks SetHyperlink to show an adjacent GameTooltip.
-- - Events: None
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Tooltip")

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local string_match = _G.string.match
local string_gsub = _G.string.gsub
local select = _G.select
local hooksecurefunc = _G.hooksecurefunc

local CreateFrame = _G.CreateFrame
local GameTooltip = _G.GameTooltip
local GetNumSavedInstances = _G.GetNumSavedInstances
local GetSavedInstanceChatLink = _G.GetSavedInstanceChatLink
local GetSavedInstanceInfo = _G.GetSavedInstanceInfo
local GetScreenWidth = _G.GetScreenWidth
local ItemRefTooltip = _G.ItemRefTooltip
local UnitGUID = _G.UnitGUID

local myTip

-- REASON: Compares instance locks and displays a secondary tooltip with the player's lock state.
local function ILockCompare(frame, link)
	if not frame or not link then
		return
	end

	local linkType = string_match(link, "^(instancelock):")
	if linkType == "instancelock" then
		local mylink, templink
		local myguid = UnitGUID("player")
		local guid = string_match(link, "instancelock:([^:]+)")

		if guid ~= myguid then
			local instanceguid = string_match(link, "instancelock:[^:]+:(%d+):")
			local numsaved = GetNumSavedInstances()
			if numsaved > 0 then
				for i = 1, numsaved do
					local locked, extended = select(5, GetSavedInstanceInfo(i))
					if extended or locked then
						templink = GetSavedInstanceChatLink(i)
						local myinstanceguid = string_match(templink, "instancelock:[^:]+:(%d+):")
						if myinstanceguid == instanceguid then
							mylink = string_match(templink, "(instancelock:[^:]+:%d+:%d+:%d+)")
							break
						end
					end
				end
				-- REASON: GC Optimization: Define the sub function inline is fine since it's only executed occasionally when linking locks,
				-- but we can avoid closure creation by pulling it out or using static string replacements.
				-- However, string_gsub with a function isn't called rapidly.
				if not mylink then
					mylink = string_gsub(link, "(instancelock:)([^:]+)(:%d+:%d+:)(%d+)", function(a, _, b)
						return a .. myguid .. b .. "0"
					end)
				end
			else
				mylink = string_gsub(link, "(instancelock:)([^:]+)(:%d+:%d+:)(%d+)", function(a, _, b)
					return a .. myguid .. b .. "0"
				end)
			end
		end

		if mylink then
			if not myTip:IsVisible() and frame:IsVisible() then
				myTip:SetParent(frame)
				myTip:SetOwner(frame, "ANCHOR_NONE")

				local leftPos = frame:GetLeft() or 0
				local rightPos = frame:GetRight() or 0
				local rightDist = GetScreenWidth() - rightPos
				local side = (rightDist < leftPos) and "left" or "right"

				myTip:ClearAllPoints()
				if side == "left" then
					myTip:SetPoint("TOPRIGHT", frame, "TOPLEFT", -3, -10)
				else
					myTip:SetPoint("TOPLEFT", frame, "TOPRIGHT", 3, -10)
				end

				myTip:SetHyperlink(mylink)
				myTip:Show()
			end
		end
	end
end

-- REASON: Handler to reposition the secondary tooltip when the main ItemRefTooltip is dragged.
local function OnItemRefDragStop(self)
	if myTip:IsVisible() and (myTip:GetParent():GetName() == self:GetName()) then
		local leftPos = self:GetLeft() or 0
		local rightPos = self:GetRight() or 0
		local rightDist = GetScreenWidth() - rightPos
		local side = (rightDist < leftPos) and "left" or "right"

		myTip:ClearAllPoints()
		if side == "left" then
			myTip:SetPoint("TOPRIGHT", self, "TOPLEFT", -3, -10)
		else
			myTip:SetPoint("TOPLEFT", self, "TOPRIGHT", 3, -10)
		end
	end
end

-- REASON: Initializes the Instance Lock Compare tooltip hooking.
function Module:CreateInstanceLockCompare()
	if not C["Tooltip"].InstanceLock then
		return
	end

	myTip = CreateFrame("GameTooltip", "KKUI_InstanceLockTooltip", nil, "GameTooltipTemplate")
	-- Reskin using Core tooltip styling if available
	if Module.ReskinTooltip then
		myTip:HookScript("OnShow", Module.ReskinTooltip)
	end

	hooksecurefunc(GameTooltip, "SetHyperlink", ILockCompare)
	hooksecurefunc(ItemRefTooltip, "SetHyperlink", ILockCompare)

	ItemRefTooltip:HookScript("OnDragStop", OnItemRefDragStop)
end
