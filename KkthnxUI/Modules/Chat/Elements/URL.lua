local K = unpack(KkthnxUI)
local Module = K:GetModule("Chat")

local string_find = _G.string.find
local string_gsub = _G.string.gsub
local string_match = _G.string.match
local string_sub = _G.string.sub
local tostring = _G.tostring

local ChatEdit_ClearChat = _G.ChatEdit_ClearChat
local ChatFrame1 = _G.ChatFrame1
local ItemRefTooltip = _G.ItemRefTooltip
local LAST_ACTIVE_CHAT_EDIT_BOX = _G.LAST_ACTIVE_CHAT_EDIT_BOX
local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS
local hooksecurefunc = _G.hooksecurefunc

local foundurl = false
local function convertLink(text, value)
	return "|Hurl:" .. tostring(value) .. "|h" .. K.InfoColor .. text .. "|r|h"
end

local function highlightURL(_, url)
	foundurl = true

	return " " .. convertLink("[" .. url .. "]", url) .. " "
end

function Module:SearchForURL(text, ...)
	foundurl = false

	if string_find(text, "%pTInterface%p+") or string_find(text, "%pTINTERFACE%p+") then
		foundurl = true
	end

	if not foundurl then
		-- 192.168.1.1:1234
		text = string_gsub(text, "(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:%d%d?%d?%d?%d?)(%s?)", highlightURL)
	end

	if not foundurl then
		-- 192.168.1.1
		text = string_gsub(text, "(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)(%s?)", highlightURL)
	end

	if not foundurl then
		-- www.teamspeak.com:3333
		text = string_gsub(text, "(%s?)([%w_-]+%.?[%w_-]+%.[%w_-]+:%d%d%d?%d?%d?)(%s?)", highlightURL)
	end

	if not foundurl then
		-- http://www.google.com
		text = string_gsub(text, "(%s?)(%a+://[%w_/%.%?%%=~&-'%-]+)(%s?)", highlightURL)
	end

	if not foundurl then
		-- www.google.com
		text = string_gsub(text, "(%s?)(www%.[%w_/%.%?%%=~&-'%-]+)(%s?)", highlightURL)
	end

	if not foundurl then
		-- lol@lol.com
		text = string_gsub(text, "(%s?)([_%w-%.~-]+@[_%w-]+%.[_%w-%.]+)(%s?)", highlightURL)
	end

	self.am(self, text, ...)
end

function Module:HyperlinkShowHook(link)
	local type, value = string_match(link, "(%a+):(.+)")
	local hide
	if type == "url" then
		local eb = LAST_ACTIVE_CHAT_EDIT_BOX or _G[self:GetName() .. "EditBox"]
		if eb then
			eb:Show()
			eb:SetText(value)
			eb:SetFocus()
			eb:HighlightText()
		end
	end

	if hide then
		ChatEdit_ClearChat(ChatFrame1.editBox)
	end
end

function Module:CreateCopyURL()
	for i = 1, NUM_CHAT_WINDOWS do
		if i ~= 2 then
			local chatFrame = _G["ChatFrame" .. i]
			chatFrame.am = chatFrame.AddMessage
			chatFrame.AddMessage = self.SearchForURL
		end
	end

	local orig = ItemRefTooltip.SetHyperlink
	function ItemRefTooltip:SetHyperlink(link, ...)
		if link and string_sub(link, 0, 3) == "url" then
			return
		end

		return orig(self, link, ...)
	end

	hooksecurefunc("ChatFrame_OnHyperlinkShow", self.HyperlinkShowHook)
end
