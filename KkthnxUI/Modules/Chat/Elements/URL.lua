--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Detects URLs and IP addresses in chat and converts them into clickable hyperlinks.
-- - Design: Fast-path precheck, secret-safe scan, copy popup on click (Ellesmere pattern).
-- - Events: Hooked into SetItemRef (Midnight; ChatFrame_OnHyperlinkShow was removed in 12.0).
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Chat")

-- PERF: Localize globals and API functions to minimize lookup overhead.
local _G = _G
local ItemRefTooltip = _G.ItemRefTooltip
local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS or 10
local ChatEdit_ChooseBoxForSend = ChatEdit_ChooseBoxForSend
local CreateFrame = _G.CreateFrame
local C_Timer = _G.C_Timer
local GetCursorPosition = _G.GetCursorPosition
local IsControlKeyDown = _G.IsControlKeyDown
local UIParent = _G.UIParent
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
local urlBackdrop
local urlPopup
local hookedFrames = {}
local urlHooksInstalled = false

-- ---------------------------------------------------------------------------
-- URL Processing Logic
-- ---------------------------------------------------------------------------
local function containsURL(text)
	if not text then
		return false
	end
	return string_find(text, "://", 1, true) or string_find(text, "www.", 1, true)
		or string_find(text, "@", 1, true)
		or string_find(text, "%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?", 1)
end

local function convertLink(text, value)
	return "|Hurl:" .. tostring(value) .. "|h" .. K.InfoColor .. text .. "|r|h"
end

local function highlightURL(_, url)
	foundURL = true
	return " " .. convertLink("[" .. url .. "]", url) .. " "
end

local function hideUrlPopup()
	if urlPopup then
		urlPopup:Hide()
	end
	if urlBackdrop then
		urlBackdrop:Hide()
	end
end

local function showUrlPopup(url)
	if not urlPopup then
		urlBackdrop = CreateFrame("Button", nil, UIParent)
		urlBackdrop:SetFrameStrata("DIALOG")
		urlBackdrop:SetFrameLevel(499)
		urlBackdrop:SetAllPoints(UIParent)
		local bdTex = urlBackdrop:CreateTexture(nil, "BACKGROUND")
		bdTex:SetAllPoints()
		bdTex:SetColorTexture(0, 0, 0, 0.35)
		urlBackdrop:RegisterForClicks("AnyUp")
		urlBackdrop:SetScript("OnClick", hideUrlPopup)
		urlBackdrop:Hide()

		urlPopup = CreateFrame("Frame", nil, UIParent)
		urlPopup:SetFrameStrata("DIALOG")
		urlPopup:SetFrameLevel(500)
		urlPopup:SetSize(340, 52)
		urlPopup:EnableMouse(true)
		urlPopup:CreateBorder()

		local hint = urlPopup:CreateFontString(nil, "OVERLAY")
		hint:SetFontObject(K.UIFont)
		hint:SetTextColor(1, 1, 1, 0.55)
		hint:SetPoint("TOP", urlPopup, "TOP", 0, -8)
		hint:SetText(L["Chat.UrlPopup Hint"] or "Ctrl+C to copy, Escape to close")

		local eb = CreateFrame("EditBox", nil, urlPopup)
		eb:SetSize(300, 18)
		eb:SetPoint("TOP", hint, "BOTTOM", 0, -6)
		eb:SetFontObject(K.UIFont)
		eb:SetAutoFocus(false)
		eb:SetJustifyH("CENTER")
		eb:CreateBorder()
		eb:SetScript("OnEscapePressed", function(self)
			self:ClearFocus()
			hideUrlPopup()
		end)
		eb:SetScript("OnKeyDown", function(self, key)
			if key == "C" and IsControlKeyDown() and C_Timer and C_Timer.After then
				C_Timer.After(0.05, hideUrlPopup)
			end
		end)
		eb:SetScript("OnMouseUp", function(self)
			self:HighlightText()
		end)
		urlPopup:SetScript("OnMouseDown", function()
			urlPopup._eb:SetFocus()
			urlPopup._eb:HighlightText()
		end)
		urlPopup._eb = eb
	end

	urlPopup._eb:SetText(url)
	urlPopup:ClearAllPoints()
	local cx, cy = GetCursorPosition()
	local scale = UIParent:GetEffectiveScale()
	urlPopup:SetPoint("BOTTOM", UIParent, "BOTTOMLEFT", cx / scale, cy / scale + 12)
	urlBackdrop:Show()
	urlPopup:Show()
	urlPopup._eb:SetFocus()
	urlPopup._eb:HighlightText()
end

local function copyUrlToEditBox(linkValue)
	local eb = ChatEdit_ChooseBoxForSend()
	if eb then
		eb:Show()
		eb:SetText(linkValue)
		eb:SetFocus()
		eb:HighlightText()
	end
end

function Module:SearchForURL(text, ...)
	if IsSecret(text) then
		return self.am(self, text, ...)
	end

	if not containsURL(text) then
		return self.am(self, text, ...)
	end

	foundURL = false

	if string_find(text, "%pTInterface%p+") or string_find(text, "%pTINTERFACE%p+") then
		foundURL = true
	end

	if not foundURL then
		text = string_gsub(text, "(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:%d%d?%d?%d?%d?)(%s?)", highlightURL)
	end

	if not foundURL then
		text = string_gsub(text, "(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)(%s?)", highlightURL)
	end

	if not foundURL then
		text = string_gsub(text, "(%s?)([%w_-]+%.?[%w_-]+%.[%w_-]+:%d%d%d?%d?%d?)(%s?)", highlightURL)
	end

	if not foundURL then
		text = string_gsub(text, "(%s?)(%a+://[%w_/%.%?%%=~&-'%-]+)(%s?)", highlightURL)
	end

	if not foundURL then
		text = string_gsub(text, "(%s?)(www%.[%w_/%.%?%%=~&-'%-]+)(%s?)", highlightURL)
	end

	if not foundURL then
		text = string_gsub(text, "(%s?)([_%w-%.~-]+@[_%w-]+%.[_%w-%.]+)(%s?)", highlightURL)
	end

	return self.am(self, text, ...)
end

-- ---------------------------------------------------------------------------
-- UI Callbacks
-- ---------------------------------------------------------------------------
function Module.HyperlinkShowHook(link)
	if IsSecret(link) then
		return
	end

	local linkType, linkValue = string_match(link, "(%a+):(.+)")
	if linkType == "url" and linkValue then
		if C["Chat"].UrlPopup ~= false then
			showUrlPopup(linkValue)
		else
			copyUrlToEditBox(linkValue)
		end
	end
end

function Module:DisableCopyURL()
	for chatFrame, original in pairs(hookedFrames) do
		if chatFrame.AddMessage == self.SearchForURL then
			chatFrame.AddMessage = original
		end
		chatFrame.am = nil
		hookedFrames[chatFrame] = nil
	end
end

function Module:CreateCopyURL()
	if C["Chat"].UrlLinks == false then
		self:DisableCopyURL()
		return
	end

	for i = 1, NUM_CHAT_WINDOWS do
		if i ~= 2 then
			local chatFrame = _G["ChatFrame" .. i]
			if chatFrame and chatFrame.AddMessage and not hookedFrames[chatFrame] then
				hookedFrames[chatFrame] = chatFrame.AddMessage
				chatFrame.am = chatFrame.AddMessage
				chatFrame.AddMessage = self.SearchForURL
			end
		end
	end

	if not urlHooksInstalled then
		local originalSetHyperlink = ItemRefTooltip.SetHyperlink
		function ItemRefTooltip:SetHyperlink(link, ...)
			if link and string_sub(link, 1, 3) == "url" then
				return
			end
			return originalSetHyperlink(self, link, ...)
		end

		hooksecurefunc("SetItemRef", self.HyperlinkShowHook)
		urlHooksInstalled = true
	end
end

function Module:ToggleCopyURL()
	self:DisableCopyURL()
	if C["Chat"].UrlLinks ~= false then
		self:CreateCopyURL()
	end
end
