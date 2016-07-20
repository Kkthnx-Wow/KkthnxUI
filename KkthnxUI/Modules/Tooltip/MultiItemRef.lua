local K, C, L, _ = select(2, ...):unpack()
if C.Tooltip.Enable ~= true then return end

local _G = _G
local ipairs = ipairs
local insert = table.insert
local UIParent = UIParent
local CreateFrame = CreateFrame

local tips = {[1] = _G["ItemRefTooltip"]}
local types = {item = true, enchant = true, spell = true, quest = true, unit = true, talent = true, achievement = true, glyph = true, instancelock = true, currency = true}

local CreateTip = function(link)
	for k, v in ipairs(tips) do
		for i, tip in ipairs(tips) do
			if tip:IsShown() and tip.link == link then
				tip.link = nil
				HideUIPanel(tip)
				return
			end
		end
		if not v:IsShown() then
			v.link = link
			return v
		end
	end

	local num = #tips + 1
	local tip = CreateFrame("GameTooltip", "ItemRefTooltip"..num, UIParent, "GameTooltipTemplate")
	tip:SetBackdrop(K.Backdrop)
	tip:SetPoint("BOTTOM", 0, 80)
	tip:SetSize(128, 64)
	tip:EnableMouse(true)
	tip:SetMovable(true)
	tip:SetClampedToScreen(true)
	tip:RegisterForDrag("LeftButton")
	tip:SetScript("OnDragStart", function(self) self:StartMoving() end)
	tip:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	tip:HookScript("OnShow", function(self)
		self:SetBackdropColor(unpack(C.Media.Backdrop_Color))
		self:SetBackdropBorderColor(unpack(C.Media.Border_Color))
	end)

	local close = CreateFrame("Button", "CloseButton", tip, "UIPanelCloseButton")
	close:SetSize(26, 26)
	close:SetPoint("BOTTOMRIGHT", tip, "TOPRIGHT", 0, -26)
	close:SetScript("OnClick", function(self) HideUIPanel(tip) end)

	insert(UISpecialFrames, tip:GetName())

	tip.link = link
	tips[num] = tip

	return tip
end

local ShowTip = function(tip, link)
	ShowUIPanel(tip)
	if not tip:IsShown() then
		tip:SetOwner(UIParent, "ANCHOR_PRESERVE")
	end
	tip:SetHyperlink(link)
end

local _SetItemRef = SetItemRef
function SetItemRef(...)
	local link, text, button = ...
	local handled = strsplit(":", link)
	if not IsModifiedClick() and handled and types[handled] then
		local tip = CreateTip(link)
		if tip then
			ShowTip(tip, link)
		end
	else
		return _SetItemRef(...)
	end
end