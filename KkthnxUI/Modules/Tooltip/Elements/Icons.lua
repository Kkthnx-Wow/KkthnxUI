--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Adds icons to tooltips for items, spells, etc.
-- - Design: Hooks tooltip data processor to prepend icons to the first line.
-- - Events: N/A
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Tooltip")

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local gsub = _G.gsub
local next = _G.next
local select = _G.select
local strfind = _G.strfind
local hooksecurefunc = _G.hooksecurefunc

local C_Item = _G.C_Item
local C_MountJournal = _G.C_MountJournal
local C_Spell = _G.C_Spell
local CreateFrame = _G.CreateFrame
local Enum = _G.Enum
local GameTooltip = _G.GameTooltip
local ItemRefTooltip = _G.ItemRefTooltip
local EmbeddedItemTooltip = _G.EmbeddedItemTooltip
local TooltipDataProcessor = _G.TooltipDataProcessor

local GetItemIcon = C_Item.GetItemIconByID
local GetSpellTexture = C_Spell.GetSpellTexture
local C_MountJournal_GetMountInfoByID = C_MountJournal.GetMountInfoByID

local newString = "0:0:64:64:5:59:5:59"

-- REASON: Prepends an icon to the first line of the tooltip and scales others.
function Module:SetupTooltipIcon(icon)
	local title = icon and _G[self:GetName() .. "TextLeft1"]
	local titleText = title and title:GetText()

	if titleText and not strfind(titleText, ":20:20:") then
		title:SetFormattedText("|T%s:20:20:" .. newString .. ":%d|t %s", icon, 20, titleText)
	end

	for i = 2, self:NumLines() do
		local line = _G[self:GetName() .. "TextLeft" .. i]
		if not line then
			break
		end

		local text = line:GetText()
		if text and text ~= " " then
			local newText, count = gsub(text, "|T([^:]-):[%d+:]+|t", "|T%1:14:14:" .. newString .. "|t")
			if count > 0 then
				line:SetText(newText)
			end
		end
	end
end

function Module:HookTooltipCleared()
	self.tipModified = false
end

function Module:HookTooltipMethod()
	self:HookScript("OnTooltipCleared", Module.HookTooltipCleared)
end

-- REASON: Applies KkthnxUI border styling to tooltip reward icons.
function Module:ReskinRewardIcon()
	self.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	self.Count:ClearAllPoints()
	self.Count:SetPoint("BOTTOMRIGHT", self.Icon, "BOTTOMRIGHT", 1, 1)

	self.bg = CreateFrame("Frame", nil, self)
	self.bg:SetAllPoints(self.Icon)
	self.bg:SetFrameLevel(2)
	self.bg:CreateBorder()

	local iconBorder = self.IconBorder
	iconBorder:SetAlpha(0)

	local greyRGB = K.QualityColors[0].r
	hooksecurefunc(self.IconBorder, "SetVertexColor", function(_, r, g, b)
		if not r or r == greyRGB or (r > 0.99 and g > 0.99 and b > 0.99) then
			r, g, b = 1, 1, 1
		end
		self.bg.KKUI_Border:SetVertexColor(r, g, b)
	end)

	hooksecurefunc(self.IconBorder, "Hide", function()
		K.SetBorderColor(self.bg.KKUI_Border)
	end)
end

local GetTooltipTextureByType = {
	[Enum.TooltipDataType.Item] = function(id)
		return GetItemIcon(id)
	end,
	[Enum.TooltipDataType.Toy] = function(id)
		return GetItemIcon(id)
	end,
	[Enum.TooltipDataType.Spell] = function(id)
		return GetSpellTexture(id)
	end,
	[Enum.TooltipDataType.Mount] = function(id)
		return select(3, C_MountJournal_GetMountInfoByID(id))
	end,
}

function Module:CreateTooltipIcons()
	if not C["Tooltip"].Icons then
		return
	end

	-- Add Icons
	Module.HookTooltipMethod(GameTooltip)
	Module.HookTooltipMethod(ItemRefTooltip)

	for tooltipType, getTex in next, GetTooltipTextureByType do
		TooltipDataProcessor.AddTooltipPostCall(tooltipType, function(self)
			if self == GameTooltip or self == ItemRefTooltip then
				local data = self:GetTooltipData()
				local id = data and data.id
				if id then
					Module.SetupTooltipIcon(self, getTex(id))
				end
			end
		end)
	end

	-- Cut Icons
	hooksecurefunc(GameTooltip, "SetUnitAura", function(self)
		Module.SetupTooltipIcon(self)
	end)

	hooksecurefunc(GameTooltip, "SetAzeriteEssence", function(self)
		Module.SetupTooltipIcon(self)
	end)
	hooksecurefunc(GameTooltip, "SetAzeriteEssenceSlot", function(self)
		Module.SetupTooltipIcon(self)
	end)

	-- Tooltip rewards icon
	Module.ReskinRewardIcon(GameTooltip.ItemTooltip)
	Module.ReskinRewardIcon(EmbeddedItemTooltip.ItemTooltip)
end
