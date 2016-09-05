local K, C, L, _ = select(2, ...):unpack()
if C.Tooltip.Enable ~= true or C.Tooltip.ItemIcon ~= true then return end

local _G = _G
local select = select

local GetName, GetItem = GetName, GetItem
local GetItemIcon = GetItemIcon
local GetSpellInfo = GetSpellInfo

-- ADDS ITEM ICONS TO TOOLTIPS(TIPACHU BY TULLER)
local function AddIcon(self, icon)

	if icon then
		local title = _G[self:GetName() .. "TextLeft1"]
		if title and not title:GetText():find("|T" .. icon) then
			title:SetFormattedText("|T%s:20:20:0:0:64:64:5:59:5:59:%d|t %s", icon, 20, title:GetText())
		end
	end
end

-- ICON FOR ITEMS
local function hookItem(tip)
	tip:HookScript("OnTooltipSetItem", function(self, ...)

		local name, link = self:GetItem()
		local icon = link and GetItemIcon(link)
		AddIcon(self, icon)
	end)
end
hookItem(_G["GameTooltip"])
hookItem(_G["ItemRefTooltip"])
hookItem(_G["ShoppingTooltip1"])
hookItem(_G["ShoppingTooltip2"])

-- ICON FOR SPELLS
local function hookSpell(tip)
	tip:HookScript("OnTooltipSetSpell", function(self, ...)

		local _, _, id = self:GetSpell()
		if id then
			AddIcon(self, select(3, GetSpellInfo(id)))
		end
	end)
end
hookSpell(_G["GameTooltip"])
hookSpell(_G["ItemRefTooltip"])

-- ICON FOR ACHIEVEMENTS (ONLY GAMETOOLTIP)
hooksecurefunc(GameTooltip, "SetHyperlink", function(self, link)

	if type(link) ~= "string" then return end
	local linkType, id = strmatch(link, "^([^:]+):(%d+)")
	if linkType == "achievement" then
		local id, name, _, accountCompleted, month, day, year, _, _, icon, _, isGuild, characterCompleted, whoCompleted = GetAchievementInfo(id)
		AddIcon(self, icon)
	end
end)