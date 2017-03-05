local K, C, L = unpack(select(2, ...))
if C.Tooltip.Enable ~= true or C.Tooltip.ItemIcon ~= true then return end

local _G = _G
local pairs = pairs
local select = select

local BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT = _G.BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT
local GetItem = _G.GetItem
local GetItemIcon = _G.GetItemIcon
local GetName = _G.GetName
local GetSpellInfo = _G.GetSpellInfo

local function SetTooltipIcon(self, icon)
	local title = icon and _G[self:GetName().."TextLeft1"]
	if title then
		title:SetFormattedText("|T%s:20:20:0:0:64:64:5:59:5:59:%d|t %s", icon, 20, title:GetText())
	end
end

local function newTooltipHooker(method, func)
	return function(tooltip)
		local modified = false

		tooltip:HookScript("OnTooltipCleared", function(self, ...)
			modified = false
		end)

		tooltip:HookScript(method, function(self, ...)
			if not modified then
				modified = true
				func(self, ...)
			end
		end)
	end
end

local hookItem = newTooltipHooker("OnTooltipSetItem", function(self, ...)
	local _, link = self:GetItem()
	if link then
		SetTooltipIcon(self, GetItemIcon(link))
	end
end)

local hookSpell = newTooltipHooker("OnTooltipSetSpell", function(self, ...)
	local _, _, id = self:GetSpell()
	if id then
		SetTooltipIcon(self, select(3, GetSpellInfo(id)))
	end
end)

for _, tooltip in pairs{GameTooltip, ItemRefTooltip, ItemRefShoppingTooltip1, ItemRefShoppingTooltip2, ShoppingTooltip1, ShoppingTooltip2} do
	hookItem(tooltip)
	hookSpell(tooltip)
end

-- WorldQuest Tooltip
hooksecurefunc("EmbeddedItemTooltip_SetItemByQuestReward", function(self)
	if self.Icon then
		self.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		self.IconBorder:Hide()
	end
end)
BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT = "|T%1$s:16:16:0:0:64:64:5:59:5:59|t |cffffffff%2$d|r %3$s"