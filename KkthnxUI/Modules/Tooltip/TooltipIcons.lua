local _, C = unpack(select(2, ...))
if C["Tooltip"].Enable ~= true or C["Tooltip"].Icons ~= true then
	return
end

-- Adds an Icon to the Tooltip (Spell, Item)
-- (Tipachu by Tuller)

local _G = _G
local select = select
local string_match = string.match
local type = type

local GetAchievementInfo = _G.GetAchievementInfo
local GetItemIcon = _G.GetItemIcon
local GetSpellInfo = _G.GetSpellInfo

local function AddIcon(self, icon)
	if icon then
		local title = _G[self:GetName() .. "TextLeft1"]
		if title and not title:GetText():find("|T" .. icon) then
			title:SetFormattedText("|T%s:20:20:0:0:64:64:5:59:5:59:%d|t %s", icon, 20, title:GetText())
		end
	end
end

-- Icon for Items
local function hookItem(tip)
	tip:HookScript("OnTooltipSetItem", function(self)
		local link = self:GetItem()
		local icon = link and GetItemIcon(link)
		AddIcon(self, icon)
	end)
end
hookItem(_G["GameTooltip"])
hookItem(_G["ItemRefTooltip"])
hookItem(_G["ShoppingTooltip1"])
hookItem(_G["ShoppingTooltip2"])

-- Icon for Spells
local function hookSpell(tip)
	tip:HookScript("OnTooltipSetSpell", function(self)
		local id = self:GetSpell()
		if id then
			AddIcon(self, select(3, GetSpellInfo(id)))
		end
	end)
end
hookSpell(_G["GameTooltip"])
hookSpell(_G["ItemRefTooltip"])

-- Icon for Achievements (only GameTooltip)
hooksecurefunc(GameTooltip, "SetHyperlink", function(self, link)
	if type(link) ~= "string" then return end
	local linkType, id = string_match(link, "^([^:]+):(%d+)")
	if linkType == "achievement" then
		local icon = GetAchievementInfo(id)
		AddIcon(self, icon)
	end
end)