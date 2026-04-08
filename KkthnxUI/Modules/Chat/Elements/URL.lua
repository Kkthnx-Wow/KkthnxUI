--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Detects URLs and IP addresses in chat and converts them into clickable hyperlinks.
-- - Design: Hooks AddMessage to scan for URL patterns and hooks hyperlink clicks to copy URLs into the editbox.
-- - Events: Hooked into ChatFrame_OnHyperlinkShow
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]
local Module = K:GetModule("Chat")

-- PERF: Localize globals and API functions to minimize lookup overhead.
local _G = _G
local ChatEdit_ClearChat = _G.ChatEdit_ClearChat
local ItemRefTooltip = _G.ItemRefTooltip
local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS or 10
local hooksecurefunc = hooksecurefunc
local string_find = string.find
local string_gsub = string.gsub
local string_match = string.match
local string_sub = string.sub
local tostring = tostring

-- ---------------------------------------------------------------------------
-- State
-- ---------------------------------------------------------------------------
local foundURL = false

-- ---------------------------------------------------------------------------
-- URL Processing Logic
-- ---------------------------------------------------------------------------
local function convertLink(text, value)
	-- REASON: Wraps the detected URL in a custom 'url' hyperlink type for easy identification.
	return "|Hurl:" .. tostring(value) .. "|h" .. K.InfoColor .. text .. "|r|h"
end

local function highlightURL(_, url)
	-- REASON: Callback for string_gsub to format detected URL segments into clickable links.
	foundURL = true
	return " " .. convertLink("[" .. url .. "]", url) .. " "
end

function Module:SearchForURL(text, ...)
	-- REASON: Scans the message text using multiple regex patterns for IP addresses, websites, and emails.
	foundURL = false

	-- REASON: Ignore strings that look like WoW interface texture paths.
	if string_find(text, "%pTInterface%p+") or string_find(text, "%pTINTERFACE%p+") then
		foundURL = true
	end

	if not foundURL then
		-- REASON: Match IP addresses with optional ports (e.g., 192.168.1.1:1234).
		text = string_gsub(text, "(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:%d%d?%d?%d?%d?)(%s?)", highlightURL)
	end

	if not foundURL then
		-- REASON: Match standard IP addresses (e.g., 192.168.1.1).
		text = string_gsub(text, "(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)(%s?)", highlightURL)
	end

	if not foundURL then
		-- REASON: Match common server address patterns (e.g., ts.example.com:9987).
		text = string_gsub(text, "(%s?)([%w_-]+%.?[%w_-]+%.[%w_-]+:%d%d%d?%d?%d?)(%s?)", highlightURL)
	end

	if not foundURL then
		-- REASON: Match full protocol URLs (e.g., http://google.com).
		text = string_gsub(text, "(%s?)(%a+://[%w_/%.%?%%=~&-'%-]+)(%s?)", highlightURL)
	end

	if not foundURL then
		-- REASON: Match www-prefixed URLs (e.g., www.google.com).
		text = string_gsub(text, "(%s?)(www%.[%w_/%.%?%%=~&-'%-]+)(%s?)", highlightURL)
	end

	if not foundURL then
		-- REASON: Match email addresses.
		text = string_gsub(text, "(%s?)([_%w-%.~-]+@[_%w-]+%.[_%w-%.]+)(%s?)", highlightURL)
	end

	-- REASON: Call the original AddMessage (stored as .am) with the potentially modified text.
	return self.addMsg(self, text, ...)
end

-- ---------------------------------------------------------------------------
-- UI Callbacks
-- ---------------------------------------------------------------------------
function Module:SetItemRefHook(link, ...)
	-- REASON: Intercepts custom 'url' hyperlinks and copies the URL into the active chat editbox.
	local linkType, linkValue = string_match(link, "(%a+):(.+)")
	if linkType == "url" then
		local eb = _G.LAST_ACTIVE_CHAT_EDIT_BOX or _G[self:GetName() .. "EditBox"]
		if eb then
			eb:Show()
			eb:SetText(linkValue)
			eb:SetFocus()
			eb:HighlightText()
		end
	end
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------
function Module:CreateCopyURL()
	-- REASON: Entry point for URL detection; redirects AddMessage for all relevant chat frames.
	for i = 1, NUM_CHAT_WINDOWS do
		if i ~= 2 then
			local chatFrame = _G["ChatFrame" .. i]
			chatFrame.addMsg = chatFrame.AddMessage
			chatFrame.AddMessage = self.SearchForURL
		end
	end

	-- REASON: Prevent the default ItemRefTooltip from attempting to process custom 'url' links.
	local orig = ItemRefTooltip.SetHyperlink
	function ItemRefTooltip:SetHyperlink(link, ...)
		if link and strsub(link, 0, 3) == "url" then
			return
		end

		return orig(self, link, ...)
	end

	hooksecurefunc("SetItemRef", self.SetItemRefHook)
end
