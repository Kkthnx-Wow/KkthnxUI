local K, C = unpack(select(2, ...))
local Module = K:NewModule("TooltipIcons")

if not Module then
	return
end

local _G = _G
local gsub = gsub
local string_match = string.match

local GetItemIcon = _G.GetItemIcon
local GetSpellTexture = _G.GetSpellTexture

local newString = "0:0:64:64:5:59:5:59"

function Module:SetupTooltipIcon(icon)
	local title = icon and _G[self:GetName().."TextLeft1"]
	if title then
		title:SetFormattedText("|T%s:20:20:"..newString..":%d|t %s", icon, 20, title:GetText())
	end

	for i = 2, self:NumLines() do
		local line = _G[self:GetName().."TextLeft"..i]
		if not line then break end
		local text = line:GetText() or ""
		if string_match(text, "|T.-:[%d+:]+|t") then
			line:SetText(gsub(text, "|T(.-):[%d+:]+|t", "|T%1:20:20:"..newString.."|t"))
		end
	end
end

function Module:HookTooltipCleared()
	self.tipModified = false
end

function Module:HookTooltipSetItem()
	if not self.tipModified then
		local _, link = self:GetItem()
		if link then
			Module.SetupTooltipIcon(self, GetItemIcon(link))
		end

		self.tipModified = true
	end
end

function Module:HookTooltipSetSpell()
	if not self.tipModified then
		local _, id = self:GetSpell()
		if id then
			Module.SetupTooltipIcon(self, GetSpellTexture(id))
		end

		self.tipModified = true
	end
end

function Module:HookTooltipMethod()
	self:HookScript("OnTooltipSetItem", Module.HookTooltipSetItem)
	self:HookScript("OnTooltipSetSpell", Module.HookTooltipSetSpell)
	self:HookScript("OnTooltipCleared", Module.HookTooltipCleared)
end

function Module:ReskinRewardIcon()
	if self and self.Icon then
		self.Icon:SetTexCoord(unpack(K.TexCoords))
		self.IconBorder:SetAlpha(0)
	end
end

function Module:ReskinTooltipIcons()
	Module.HookTooltipMethod(GameTooltip)
	Module.HookTooltipMethod(ItemRefTooltip)

	-- Tooltip Rewards Icon
	_G.BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT = "|T%1$s:16:16:"..newString.."|t |cffffffff%2$s|r %3$s"
	_G.BONUS_OBJECTIVE_REWARD_FORMAT = "|T%1$s:16:16:"..newString.."|t %2$s"

	hooksecurefunc("EmbeddedItemTooltip_SetItemByQuestReward", Module.ReskinRewardIcon)
	hooksecurefunc("EmbeddedItemTooltip_SetItemByID", Module.ReskinRewardIcon)
	hooksecurefunc("EmbeddedItemTooltip_SetCurrencyByID", Module.ReskinRewardIcon)
end

function Module:OnEnable()
	if C["Tooltip"].Icons ~= true then
		return
	end

	self:ReskinTooltipIcons()
end