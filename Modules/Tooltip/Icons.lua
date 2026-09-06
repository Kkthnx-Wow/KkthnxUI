--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Tooltip/Icons.lua
	Purpose:
		Put the item, toy, spell, or mount icon next to the tooltip title, and crop
		the default border off any inline icons in the body so they sit cleanly.

		Every line read is guarded against Midnight secrets first, then a cheap |T
		pre-filter skips lines with no texture escape before the gsub runs.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("Tooltip")

local _G = _G
local gsub = string.gsub
local strfind = string.find
local select = select
local next = next
local IsSecret = K.IsSecret

local C_Item = C_Item
local C_Spell = C_Spell
local C_MountJournal = C_MountJournal

-- |T texcoord tail: full 64x64 texture cropped 5..59 on both axes to shave the
-- default icon border. Reused for every inline icon so they all crop the same.
local CROP = "0:0:64:64:5:59:5:59"

-- Prepend the icon to the title line and crop any inline body icons.
function Module:AddTooltipIcon(icon)
	if not C.Tooltip.ShowIcons then
		return
	end

	local title = icon and _G[self:GetName() .. "TextLeft1"]
	local titleText = title and title:GetText()
	if titleText and not IsSecret(titleText) and not strfind(titleText, ":20:20:") then
		title:SetFormattedText("|T%s:20:20:" .. CROP .. "|t %s", icon, titleText)
	end

	for i = 2, self:NumLines() do
		local line = _G[self:GetName() .. "TextLeft" .. i]
		if not line then
			break
		end
		local text = line:GetText()
		if text and not IsSecret(text) and text ~= " " and strfind(text, "|T", 1, true) then
			local newText, count = gsub(text, "|T([^:]-):[%d+:]+|t", "|T%1:14:14:" .. CROP .. "|t")
			if count > 0 then
				line:SetText(newText)
			end
		end
	end
end

local TextureByType = {
	[Enum.TooltipDataType.Item] = function(id)
		return C_Item.GetItemIconByID(id)
	end,
	[Enum.TooltipDataType.Toy] = function(id)
		return C_Item.GetItemIconByID(id)
	end,
	[Enum.TooltipDataType.Spell] = function(id)
		return C_Spell.GetSpellTexture(id)
	end,
	[Enum.TooltipDataType.Mount] = function(id)
		if C_MountJournal and C_MountJournal.GetMountInfoByID then
			return select(3, C_MountJournal.GetMountInfoByID(id))
		end
	end,
}

function Module:SetupIcons()
	if not C.Tooltip.ShowIcons then
		return
	end
	if not (TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType) then
		return
	end

	local watched = {
		[_G.GameTooltip] = true,
		[_G.ItemRefTooltip] = true,
		[_G.ShoppingTooltip1] = true,
		[_G.ShoppingTooltip2] = true,
	}

	for tooltipType, getTex in next, TextureByType do
		TooltipDataProcessor.AddTooltipPostCall(tooltipType, function(tt)
			if watched[tt] and not tt:IsForbidden() then
				local data = tt:GetTooltipData()
				local id = data and data.id
				if id and not IsSecret(id) then
					Module.AddTooltipIcon(tt, getTex(id))
				end
			end
		end)
	end

	-- Aura tooltips carry no data.id, so crop their inline icons without a title.
	if _G.GameTooltip.SetUnitAura then
		hooksecurefunc(_G.GameTooltip, "SetUnitAura", function(tt)
			if not tt:IsForbidden() then
				Module.AddTooltipIcon(tt)
			end
		end)
	end
end
