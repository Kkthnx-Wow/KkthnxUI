--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Chat/Hyperlink.lua
	Purpose:
		Show a tooltip when the mouse rests on a chat hyperlink (item, spell,
		achievement, quest) without having to click it. Kept safe with pcall so an
		unsupported link type never errors.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

local Module = K:GetModule("Chat")

local _G = _G
local pcall = pcall

local NUM_FRAMES = NUM_CHAT_WINDOWS or 10

local function OnHyperlinkEnter(frame, link)
	local kind = link:match("^(%a+):")
	-- Only object links have a useful tooltip, plain URLs and player links do not.
	if not kind or kind == "kkurl" or kind == "player" or kind == "channel" or kind == "BNplayer" then
		return
	end
	GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
	local ok = pcall(GameTooltip.SetHyperlink, GameTooltip, link)
	if ok then
		GameTooltip:Show()
	else
		GameTooltip:Hide()
	end
end

local function OnHyperlinkLeave()
	GameTooltip:Hide()
end

function Module:EnableHyperlinkTooltips()
	for i = 1, NUM_FRAMES do
		local frame = _G["ChatFrame" .. i]
		if frame and not frame.__kkuiHyperlink then
			frame.__kkuiHyperlink = true
			frame:HookScript("OnHyperlinkEnter", OnHyperlinkEnter)
			frame:HookScript("OnHyperlinkLeave", OnHyperlinkLeave)
		end
	end
end
