--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Detects URLs and IP addresses in chat and converts them into clickable hyperlinks.
-- - Design: Hooks AddMessage to scan for URL patterns and hooks hyperlink clicks to copy URLs into the editbox.
-- - Events: Hooked into SetItemRef (Midnight; ChatFrame_OnHyperlinkShow was removed in 12.0).
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]
local Module = K:GetModule("Chat")

-- PERF: Localize globals and API functions to minimize lookup overhead.
local _G = _G
local ItemRefTooltip = _G.ItemRefTooltip
local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS or 10
local ChatEdit_ChooseBoxForSend = ChatEdit_ChooseBoxForSend
local hooksecurefunc = hooksecurefunc
local IsSecret = K.IsSecret
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
	return self.am(self, text, ...)
end

-- ---------------------------------------------------------------------------
-- UI Callbacks
-- ---------------------------------------------------------------------------
-- MIDNIGHT (12.0): ChatFrame_OnHyperlinkShow was removed; hyperlink clicks now route
-- through SetItemRef(link, text, button). Defined with a dot (no implicit self) so the
-- hooksecurefunc post-hook receives SetItemRef's raw arguments.
function Module.HyperlinkShowHook(link)
	-- SECRET (12.0): chat links can be secret values inside instances; never parse them then.
	if IsSecret(link) then
		return
	end

	-- REASON: Intercepts custom 'url' hyperlinks and copies the URL into the active chat editbox.
	local linkType, linkValue = string_match(link, "(%a+):(.+)")
	if linkType == "url" then
		local eb = ChatEdit_ChooseBoxForSend()
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
			if chatFrame and chatFrame.AddMessage then
				chatFrame.am = chatFrame.AddMessage
				chatFrame.AddMessage = self.SearchForURL
			end
		end
	end

	-- REASON: Prevent the default ItemRefTooltip from attempting to process custom 'url' links.
	local originalSetHyperlink = ItemRefTooltip.SetHyperlink
	function ItemRefTooltip:SetHyperlink(link, ...)
		if link and string_sub(link, 1, 3) == "url" then
			return
		end
		return originalSetHyperlink(self, link, ...)
	end

	hooksecurefunc("SetItemRef", self.HyperlinkShowHook)
end
