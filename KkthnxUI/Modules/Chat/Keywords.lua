--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Chat/Keywords.lua
	Purpose:
		Highlight your name and any keywords you set wherever they show up in chat,
		and play a short sound when one is mentioned so a call-out does not scroll
		past unseen. Built on a message filter, so it only recolours the text and
		never touches the secure or secret parts of the chat.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local Module = K:GetModule("Chat")
if not Module then
	return
end

local ipairs = ipairs
local gsub = string.gsub
local format = string.format
local lower = string.lower
local upper = string.upper
local max = math.max
local GetTime = GetTime
local PlaySound = PlaySound
local UnitName = UnitName

local IsSecret = K.IsSecret

-- The chat events worth watching. System and combat text are left alone.
local EVENTS = {
	"CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_EMOTE", "CHAT_MSG_TEXT_EMOTE",
	"CHAT_MSG_GUILD", "CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_WHISPER", "CHAT_MSG_BN_WHISPER",
}

local keywords = {}
local lastSound = 0
local mentions = 0
local badge

-- Build a case-insensitive Lua pattern from a plain word, e.g. Foo -> [Ff][Oo][Oo],
-- with magic characters escaped so odd keywords do not break the match.
local function CaseInsensitive(word)
	return (gsub(word, "(%a)", function(letter)
		return "[" .. upper(letter) .. lower(letter) .. "]"
	end))
end

-- Rebuild the watch list from your name plus the configured extras.
function Module:RefreshKeywords()
	wipe(keywords)
	local name = UnitName("player")
	if name then
		keywords[#keywords + 1] = CaseInsensitive(name)
	end
	local list = C.Chat.KeywordList
	if type(list) == "string" and list ~= "" then
		for word in list:gmatch("[^,]+") do
			-- Trim the spaces around each entry but keep spaces inside a phrase, so
			-- "loot council" stays one keyword rather than collapsing to one word.
			word = word:gsub("^%s+", ""):gsub("%s+$", "")
			if word ~= "" then
				keywords[#keywords + 1] = CaseInsensitive(word)
			end
		end
	end
end

-- Reset the unread mention tally and hide the badge. Called when you look at the
-- chat, so the count always reflects mentions you have not seen yet.
local function ClearMentions()
	mentions = 0
	if badge then
		badge:Hide()
	end
end

-- Bump the tally and refresh the badge. The badge only exists while the count
-- feature is on, so a nil badge just means the count is tracked silently.
local function BumpMentions()
	mentions = mentions + 1
	if badge then
		local c = C.Chat.KeywordColor
		badge.text:SetText(mentions > 99 and "99+" or mentions)
		badge.text:SetTextColor(c[1] or 1, c[2] or 1, c[3] or 1)
		badge:SetWidth(max(20, badge.text:GetStringWidth() + 10))
		badge:Show()
	end
end

local function Filter(_, _, message, ...)
	if not C.Chat.KeywordHighlight or IsSecret(message) or type(message) ~= "string" then
		return false, message, ...
	end

	local c = C.Chat.KeywordColor
	local hex = format("|cff%02x%02x%02x", (c[1] or 1) * 255, (c[2] or 1) * 255, (c[3] or 1) * 255)
	local hit = false
	for _, pattern in ipairs(keywords) do
		-- Frontier patterns keep the match to a whole word, so a keyword inside a
		-- longer word is left alone.
		local replaced = gsub(message, "%f[%w](" .. pattern .. ")%f[%W]", hex .. "%1|r")
		if replaced ~= message then
			hit = true
			message = replaced
		end
	end

	if hit then
		-- A short sound on a mention, throttled so a burst is one chime.
		if C.Chat.KeywordSound then
			local now = GetTime()
			if now - lastSound > 3 then
				lastSound = now
				PlaySound(SOUNDKIT and SOUNDKIT.TELL_MESSAGE or 3081, "Master")
			end
		end
		-- Count it as unread until you look at the chat.
		if C.Chat.KeywordCount then
			BumpMentions()
		end
	end

	return false, message, ...
end

-- A small badge in the bottom-right corner of the chat that counts keyword
-- mentions you have not read yet. It clears the moment you mouse over the chat
-- or click the badge, so a lingering number always means something new.
local function CreateBadge()
	local anchor = _G.ChatFrame1
	if not anchor or badge then
		return
	end

	badge = CreateFrame("Button", "KKUI_KeywordBadge", anchor)
	badge:SetSize(20, 16)
	badge:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -2, 2)
	badge:SetFrameStrata("HIGH")
	K.CreateGradientBackground(badge, 0.9)
	K.CreateBorder(badge)
	badge:Hide()

	local text = badge:CreateFontString(nil, "OVERLAY")
	K.SetFont(text, 11, K.FontOutlineStyle())
	text:SetPoint("CENTER")
	badge.text = text

	badge:SetScript("OnClick", ClearMentions)
	badge:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetText(L["Keyword Mentions"] or "Keyword Mentions", 1, 1, 1)
		GameTooltip:AddLine(L["Unread mentions of your keywords. Click to clear."] or "Unread mentions of your keywords. Click to clear.", 1, 0.82, 0, true)
		GameTooltip:Show()
	end)
	badge:SetScript("OnLeave", GameTooltip_Hide)

	-- Looking at the chat counts as reading the mentions.
	anchor:HookScript("OnEnter", ClearMentions)
end

function Module:SetupKeywords()
	self:RefreshKeywords()
	for _, event in ipairs(EVENTS) do
		ChatFrame_AddMessageEventFilter(event, Filter)
	end
	if C.Chat.KeywordCount then
		CreateBadge()
	end
end
