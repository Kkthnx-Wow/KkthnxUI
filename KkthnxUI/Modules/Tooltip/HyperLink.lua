local K, C, L = unpack(select(2, ...))

local _G = _G

local ChatHyperLink = CreateFrame("Frame")

local linktypes = {
	["item"] = true,
	["spell"] = true,
	["unit"] = true,
	["quest"] = true,
	["enchant"] = true,
	["achievement"] = true,
	["instancelock"] = true,
	["talent"] = true,
	["glyph"] = true,
	["currency"] = true,
}

local HyperlinkEntered
local function OnHyperlinkEnter(frame, link, ...)
	if InCombatLockdown() then return end
	local linktype = link:match("^([^:]+)")
	if linktype and linktypes[linktype] then
		ShowUIPanel(GameTooltip)
		GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
		GameTooltip:SetHyperlink(link)
		HyperlinkEntered = frame
		GameTooltip:Show()
	end
end

local function OnHyperlinkLeave(frame, link, ...)
	if HyperlinkEntered then
		HideUIPanel(GameTooltip)
		HyperlinkEntered = nil
	end
end

for _, frameName in pairs(CHAT_FRAMES) do
	local frame = _G[frameName]
	frame:SetScript("OnHyperlinkEnter", OnHyperlinkEnter)
	frame:SetScript("OnHyperlinkLeave", OnHyperlinkLeave)
end


local function EnableHyperlink()
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName]
		frame:SetScript("OnHyperlinkEnter", OnHyperlinkEnter)
		frame:SetScript("OnHyperlinkLeave", OnHyperlinkLeave)
	end
end

local function DisableHyperlink()
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName]
		frame:SetScript("OnHyperlinkEnter", nil)
		frame:SetScript("OnHyperlinkLeave", nil)
	end
end

if C.Tooltip.HyperLink and C.Chat.Enable or C.Tooltip.Enable or not K.CheckAddOn("tekKompare") then
	EnableHyperlink()
else
	DisableHyperlink()
end