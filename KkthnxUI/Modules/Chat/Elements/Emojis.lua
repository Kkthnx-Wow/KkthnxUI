--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Notes:
-- - Purpose: Replace emoticon text / :shortcodes: with Media emoji textures in chat.
-- - Design: ChatFrame message filters; optional speech-bubble poll; optional : autocomplete.
-- - Copy.lua restores original text from |Helvmoji:%<base64>|h links — do not change scheme.
-- - Texture map lives in Config/Elements/FilterLists/Emojis.lua (C.SetEmojiTexture).
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Chat")

local format = string.format
local gsub = string.gsub
local strfind = string.find
local strlower = string.lower
local strmatch = string.match
local strsub = string.sub
local strlen = string.len
local tconcat = table.concat
local wipe = wipe
local ipairs = ipairs
local pairs = pairs
local unpack = unpack
local CreateFrame = CreateFrame
local GetCVarBool = GetCVarBool
local ChatFrame_AddMessageEventFilter = ChatFrame_AddMessageEventFilter
local ChatFrame_RemoveMessageEventFilter = ChatFrame_RemoveMessageEventFilter
local C_ChatBubbles_GetAllChatBubbles = C_ChatBubbles and C_ChatBubbles.GetAllChatBubbles

local EMOJI_PX = 14
local BUBBLE_EMOJI_PX = 12
local AC_EMOJI_PX = 14
local AC_EMOJI_YOFFSET = 1
local AC_ROW_HEIGHT = 20
local AC_TOKEN_COLOR = "|cffd0d0d0"
local BUBBLE_MAX_TEXT_WIDTH = 268
local HELVMOJI_PAD = "|cFFffffff|r|h"

local AC_PRIORITY = (Enum and Enum.AutoCompletePriority and Enum.AutoCompletePriority.Other) or LE_AUTOCOMPLETE_PRIORITY_OTHER

local CHAT_EVENTS = {
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BN_WHISPER_INFORM",
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_COMMUNITIES_CHANNEL",
	"CHAT_MSG_EMOTE",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_SAY",
	"CHAT_MSG_TEXT_EMOTE",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_YELL",
}

local entries = {}
local emoticonHintChars = {}
local listReady = false
local autocompleteCatalog = {}
local autocompleteReady = false
local hookedEditBoxes = {}
local matchScratch = {}
local segmentParts = {}
local filtersInstalled = false

local bubbleWorker
local bubblePollElapsed = 0

-- ---
-- Helpers
-- ---

local function GetEditBoxCursor(editBox)
	return editBox:GetCursorPosition()
end

local function TextureMarkup(path, size, yOffset)
	if yOffset then
		return format("|T%s:%d:%d:0:%d|t", path, size, size, yOffset)
	end
	return format("|T%s:%d:%d|t", path, size, size)
end

-- C.SetEmojiTexture keys are already Lua-escaped patterns (":%-%)", etc.).
local function UnescapePattern(pat)
	return (gsub(pat, "%%([%^%$%(%)%%%.%[%]%*%+%-%?])", "%1"))
end

local function HelvmojiLink(matched)
	local encoded = K.LibBase64 and K.LibBase64:Encode(matched)
	if not encoded then
		return ""
	end
	-- |Helvmoji:… is |H + elvmoji:… — Copy.lua strips these before texture paths.
	return "|Helvmoji:%" .. encoded .. "|h" .. HELVMOJI_PAD
end

local function GetIncompleteShortcode(beginning)
	if not beginning or beginning == "" then
		return nil
	end
	local code = strmatch(beginning, "^(:[^:][^:]*)$") or strmatch(beginning, "[%s%p](:[^:][^:]*)$")
	if code then
		return code
	end
	if strmatch(beginning, "^:$") or strmatch(beginning, "[%s%p]:$") then
		return ":"
	end
end

local function RegisterHintChars(literal)
	for j = 1, #literal do
		emoticonHintChars[strsub(literal, j, j)] = true
	end
end

local function SegmentMightHaveEmoticon(segment)
	for i = 1, #segment do
		if emoticonHintChars[strsub(segment, i, i)] then
			return true
		end
	end
	return false
end

local function BuildReplacementList()
	if listReady then
		return
	end
	listReady = true
	wipe(emoticonHintChars)
	wipe(entries)

	local n = 0
	local map = C.SetEmojiTexture
	if not map then
		return
	end

	for pattern, path in pairs(map) do
		if pattern and path then
			local literal = UnescapePattern(pattern)
			n = n + 1
			entries[n] = {
				literal = literal,
				pattern = pattern,
				chatTexture = TextureMarkup(path, EMOJI_PX),
				bubbleTexture = TextureMarkup(path, BUBBLE_EMOJI_PX),
			}
			RegisterHintChars(literal)
		end
	end

	table.sort(entries, function(a, b)
		return #a.literal > #b.literal
	end)
end

-- ---
-- Autocomplete (:name: shortcodes from the texture map)
-- ---

local function FormatAutocompleteLabel(path, token)
	return TextureMarkup(path, AC_EMOJI_PX, AC_EMOJI_YOFFSET) .. "  " .. AC_TOKEN_COLOR .. token .. "|r"
end

local acLayoutHooked = false

local function InstallAutocompleteLayoutHook()
	if acLayoutHooked then
		return
	end
	acLayoutHooked = true

	hooksecurefunc("AutoComplete_UpdateResults", function(box, results)
		if not C["Chat"].Emojis or not C["Chat"].EmojiAutocomplete then
			return
		end
		local isEmoji = results and results[1] and results[1].insertToken
		if not isEmoji then
			return
		end
		local rowH = AC_ROW_HEIGHT
		local maxButtons = AUTOCOMPLETE_MAX_BUTTONS or 5
		local numShown = 0

		for i = 1, maxButtons do
			local button = _G["AutoCompleteButton" .. i]
			if button then
				button:SetHeight(rowH)
				local fs = button:GetFontString()
				if fs then
					fs:ClearAllPoints()
					fs:SetPoint("LEFT", button, "LEFT", 10, 0)
				end
				if button:IsShown() then
					numShown = numShown + 1
				end
			end
		end

		if numShown > 0 and box and box:IsShown() then
			box:SetHeight(numShown * rowH + 35)
		end
	end)
end

local function BuildAutocompleteCatalog()
	if autocompleteReady then
		return
	end
	autocompleteReady = true
	wipe(autocompleteCatalog)

	local map = C.SetEmojiTexture
	if not map then
		return
	end

	local seen = {}
	for pattern, path in pairs(map) do
		local literal = UnescapePattern(pattern)
		if literal and path and strmatch(literal, "^:[^:]+:$") and not seen[literal] then
			seen[literal] = true
			autocompleteCatalog[#autocompleteCatalog + 1] = {
				token = literal,
				label = FormatAutocompleteLabel(path, literal),
			}
		end
	end

	table.sort(autocompleteCatalog, function(a, b)
		return a.token < b.token
	end)
end

local function GetEmojiAutoCompleteMatches(text, maxResults, cursorPosition)
	wipe(matchScratch)
	if not text or text == "" then
		return matchScratch
	end

	maxResults = maxResults or (AUTOCOMPLETE_MAX_BUTTONS or 5)
	local beginning = strsub(text, 1, cursorPosition or strlen(text))
	local shortCode = GetIncompleteShortcode(beginning)
	if not shortCode then
		return matchScratch
	end

	local q = strlower(shortCode)
	local n = 0
	for i = 1, #autocompleteCatalog do
		local entry = autocompleteCatalog[i]
		if strfind(strlower(entry.token), q, 1, true) == 1 then
			n = n + 1
			matchScratch[n] = {
				name = entry.label,
				priority = AC_PRIORITY,
				insertToken = entry.token,
			}
			if n >= maxResults then
				break
			end
		end
	end
	return matchScratch
end

local ClearEmojiAutocomplete, ActivateEmojiAutocomplete, CompleteEmojiToken

ClearEmojiAutocomplete = function(editBox)
	if not editBox or not editBox.__kkEmojiACActive then
		return
	end
	AutoCompleteEditBox_SetCustomAutoCompleteFunction(editBox, editBox.__kkSavedAutoCompleteFn)
	local savedSource = editBox.__kkSavedACSource
	local savedParams = editBox.__kkSavedACParams
	if savedSource then
		AutoCompleteEditBox_SetAutoCompleteSource(editBox, savedSource, unpack(savedParams or {}))
	else
		AutoCompleteEditBox_SetAutoCompleteSource(editBox, nil)
	end
	AutoComplete_HideIfAttachedTo(editBox)
	editBox.__kkEmojiACActive = nil
end

ActivateEmojiAutocomplete = function(editBox)
	if not editBox.__kkEmojiACActive then
		editBox.__kkSavedACSource = editBox.autoCompleteSource
		editBox.__kkSavedACParams = editBox.autoCompleteParams
		editBox.__kkSavedAutoCompleteFn = editBox.customAutoCompleteFunction
	end
	AutoCompleteEditBox_SetAutoCompleteSource(editBox, GetEmojiAutoCompleteMatches)
	AutoCompleteEditBox_SetCustomAutoCompleteFunction(editBox, CompleteEmojiToken)
	editBox.__kkEmojiACActive = true
	AutoComplete_Update(editBox, editBox:GetText(), GetEditBoxCursor(editBox))
end

CompleteEmojiToken = function(editBox, _, nameInfo)
	local token = nameInfo and nameInfo.insertToken
	if not token then
		return false
	end

	local cursorPosition = GetEditBoxCursor(editBox)
	local text = editBox:GetText()
	local beginning = strsub(text, 1, cursorPosition)
	local incomplete = GetIncompleteShortcode(beginning)
	if not incomplete then
		return false
	end

	local startPos = strlen(beginning) - strlen(incomplete) + 1
	local newBeginning = strsub(beginning, 1, startPos - 1) .. token .. " "
	local newText = newBeginning .. strsub(text, cursorPosition + 1)
	local newCursor = strlen(newBeginning)

	editBox.ignoreTextChange = true
	editBox:SetText(newText)
	editBox:SetCursorPosition(newCursor)
	editBox.ignoreTextChange = nil
	ClearEmojiAutocomplete(editBox)
	return true
end

local function OnEditBoxTextChanged(editBox, userInput)
	if editBox.ignoreTextChange then
		return
	end
	if editBox.disallowAutoComplete then
		ClearEmojiAutocomplete(editBox)
		return
	end
	if not C["Chat"].Emojis or not C["Chat"].EmojiAutocomplete then
		return
	end

	local text = editBox:GetText()
	local cursorPosition = GetEditBoxCursor(editBox)
	local beginning = strsub(text, 1, cursorPosition)
	local shortCode = GetIncompleteShortcode(beginning)

	if not userInput and not shortCode and not editBox.__kkEmojiACActive then
		return
	end

	if shortCode then
		ActivateEmojiAutocomplete(editBox)
	else
		ClearEmojiAutocomplete(editBox)
	end
end

local function SetupEditBoxAutocomplete(editBox)
	if not editBox or not editBox.HookScript or editBox.__kkEmojiAutoCompleteHooked then
		return
	end
	editBox.__kkEmojiAutoCompleteHooked = true
	hookedEditBoxes[#hookedEditBoxes + 1] = editBox
	editBox:HookScript("OnTextChanged", OnEditBoxTextChanged)
end

local function InstallEditBoxAutocomplete()
	if not (C["Chat"].Emojis and C["Chat"].EmojiAutocomplete) then
		return
	end
	BuildAutocompleteCatalog()
	InstallAutocompleteLayoutHook()

	for i = 1, NUM_CHAT_WINDOWS do
		local editBox = _G["ChatFrame" .. i .. "EditBox"]
		if editBox then
			SetupEditBoxAutocomplete(editBox)
		end
	end

	if CHAT_FRAMES then
		for _, frameName in ipairs(CHAT_FRAMES) do
			local frame = _G[frameName]
			local editBox = frame and (frame.editBox or _G[frameName .. "EditBox"])
			if editBox then
				SetupEditBoxAutocomplete(editBox)
			end
		end
	end
end

local function TeardownEditBoxAutocomplete()
	for i = 1, #hookedEditBoxes do
		ClearEmojiAutocomplete(hookedEditBoxes[i])
	end
end

-- ---
-- Plain-segment replacement (skip existing |H…|h spans)
-- ---

local function ReplaceInSegment(segment, useLinks, textureKey)
	if not SegmentMightHaveEmoticon(segment) then
		return segment
	end

	for i = 1, #entries do
		local entry = entries[i]
		local literal = entry.literal
		local pat = entry.pattern
		local tex = entry[textureKey]
		-- Plain find first — patterns like :* otherwise backtrack forever.
		if tex and strfind(segment, literal, 1, true) then
			segment = gsub(segment, "([%s%p]-)(" .. pat .. ")([%s%p]*)", function(prefix, matched, suffix)
				local mid = tex
				if useLinks then
					mid = HelvmojiLink(matched) .. mid
				end
				return prefix .. mid .. suffix
			end)
		end
	end
	return segment
end

local function ContainsBlockedSlash(msg)
	return strfind(msg, "/run", 1, true) or strfind(msg, "/dump", 1, true) or strfind(msg, "/script", 1, true)
end

local function TransformMessageBody(msg)
	if not msg or msg == "" then
		return msg
	end
	if ContainsBlockedSlash(msg) then
		return msg
	end

	wipe(segmentParts)
	local partCount = 0
	local cursor = 1
	local len = strlen(msg)

	while cursor <= len do
		local linkStart = strfind(msg, "|H", cursor, true)
		local plainEnd = linkStart and (linkStart - 1) or len

		if plainEnd >= cursor then
			partCount = partCount + 1
			segmentParts[partCount] = ReplaceInSegment(strsub(msg, cursor, plainEnd), true, "chatTexture")
		end

		if not linkStart then
			break
		end

		cursor = linkStart
		local _, linkEnd = strfind(msg, "|h.-|h", cursor)
		linkEnd = linkEnd or len
		if linkEnd >= cursor then
			partCount = partCount + 1
			segmentParts[partCount] = strsub(msg, cursor, linkEnd)
			cursor = linkEnd + 1
		else
			break
		end
	end

	if partCount == 0 then
		return msg
	end
	if partCount == 1 then
		return segmentParts[1]
	end
	return tconcat(segmentParts, nil, 1, partCount)
end

local function TransformBubbleBody(msg)
	if not msg or msg == "" or K.IsSecret(msg) or type(msg) ~= "string" then
		return msg
	end
	if ContainsBlockedSlash(msg) then
		return msg
	end
	return ReplaceInSegment(msg, false, "bubbleTexture")
end

local function ReflowBubbleString(str)
	if not str or not str.GetStringWidth or not str.SetWidth then
		return
	end
	local w = str:GetStringWidth()
	if not w or w <= 0 then
		return
	end
	str:SetWidth(w < BUBBLE_MAX_TEXT_WIDTH and w or BUBBLE_MAX_TEXT_WIDTH)
end

-- ---
-- Speech bubbles (optional)
-- ---

local bubbleCVars = {
	CHAT_MSG_SAY = "chatBubbles",
	CHAT_MSG_YELL = "chatBubbles",
	CHAT_MSG_MONSTER_SAY = "chatBubbles",
	CHAT_MSG_MONSTER_YELL = "chatBubbles",
	CHAT_MSG_EMOTE = "chatBubbles",
	CHAT_MSG_TEXT_EMOTE = "chatBubbles",
	CHAT_MSG_PARTY = "chatBubblesParty",
	CHAT_MSG_PARTY_LEADER = "chatBubblesParty",
	CHAT_MSG_MONSTER_PARTY = "chatBubblesParty",
	CHAT_MSG_INSTANCE_CHAT = "chatBubblesParty",
	CHAT_MSG_INSTANCE_CHAT_LEADER = "chatBubblesParty",
	CHAT_MSG_RAID = "chatBubblesRaid",
	CHAT_MSG_RAID_LEADER = "chatBubblesRaid",
	CHAT_MSG_RAID_WARNING = "chatBubblesRaid",
}

local function ShouldPollBubbleEvent(event)
	local cvar = bubbleCVars[event]
	if not cvar then
		return false
	end
	if GetCVarBool(cvar) then
		return true
	end
	if cvar == "chatBubblesParty" and event:find("INSTANCE", 1, true) then
		return GetCVarBool("chatBubblesRaid")
	end
	return false
end

local function ApplyEmojisToBubble(chatBubble)
	if not chatBubble or chatBubble:IsForbidden() then
		return
	end

	local frame = chatBubble.GetChildren and chatBubble:GetChildren()
	if not frame or frame:IsForbidden() then
		return
	end

	local str = frame.String
	if not str or not str.GetText or not str.SetText then
		return
	end

	local text = str:GetText()
	if not text or text == "" or K.IsSecret(text) then
		chatBubble.__kkEmojiApplied = nil
		return
	end

	-- Recycled bubbles keep old applied text while String resets to :D — key off applied, not source.
	if chatBubble.__kkEmojiApplied == text then
		return
	end

	local newText = TransformBubbleBody(text)
	if newText ~= text then
		str:SetText(newText)
		ReflowBubbleString(str)
		chatBubble.__kkEmojiApplied = newText
	else
		chatBubble.__kkEmojiApplied = text
	end
end

local function PollChatBubbles()
	if not (C["Chat"].Emojis and C["Chat"].EmojiBubbles and C_ChatBubbles_GetAllChatBubbles) then
		return
	end

	local bubbles = C_ChatBubbles_GetAllChatBubbles()
	if not bubbles then
		return
	end

	for i = 1, #bubbles do
		ApplyEmojisToBubble(bubbles[i])
	end
end

local function CreateBubbleWorker()
	if bubbleWorker or not C_ChatBubbles_GetAllChatBubbles then
		return
	end

	bubbleWorker = CreateFrame("Frame")
	bubbleWorker:Hide()

	bubbleWorker:SetScript("OnUpdate", function(self, elapsed)
		bubblePollElapsed = bubblePollElapsed + (elapsed or 0)
		if bubblePollElapsed < 0.1 then
			return
		end
		bubblePollElapsed = 0
		PollChatBubbles()
		self:Hide()
	end)

	bubbleWorker:SetScript("OnEvent", function(self, event)
		if not (C["Chat"].Emojis and C["Chat"].EmojiBubbles) then
			return
		end
		if ShouldPollBubbleEvent(event) then
			bubblePollElapsed = 0
			self:Show()
		end
	end)
end

local function EnsureBubbleWorkerEvents()
	if not bubbleWorker then
		return
	end
	for event in pairs(bubbleCVars) do
		bubbleWorker:RegisterEvent(event)
	end
end

local function TearDownBubbleWorker()
	if not bubbleWorker then
		return
	end
	bubbleWorker:UnregisterAllEvents()
	bubbleWorker:Hide()
end

local function SyncBubbleWorker()
	if not (C["Chat"].Emojis and C["Chat"].EmojiBubbles) then
		TearDownBubbleWorker()
		return
	end
	if not bubbleWorker then
		CreateBubbleWorker()
	end
	EnsureBubbleWorkerEvents()
	if bubbleWorker then
		bubbleWorker:Hide()
	end
end

-- ---
-- Chat message filter
-- ---

function Module:SetupEmojis(_, msg)
	if not msg or K.IsSecret(msg) or type(msg) ~= "string" then
		return msg
	end
	BuildReplacementList()
	return TransformMessageBody(msg)
end

-- Filter callback: (chatFrame, event, msg, …). Colon form eats chatFrame as self.
function Module:ApplyEmojis(event, msg, ...)
	if not C["Chat"].Emojis then
		return
	end
	if not msg or K.IsSecret(msg) or type(msg) ~= "string" then
		return
	end

	local newMsg = Module:SetupEmojis(event, msg)
	if newMsg == msg then
		return
	end
	return false, newMsg, ...
end

function Module:UpdateEmojis()
	local enable = C["Chat"].Emojis
	if enable and not filtersInstalled then
		BuildReplacementList()
		for _, event in ipairs(CHAT_EVENTS) do
			ChatFrame_AddMessageEventFilter(event, Module.ApplyEmojis)
		end
		filtersInstalled = true
	elseif not enable and filtersInstalled then
		for _, event in ipairs(CHAT_EVENTS) do
			ChatFrame_RemoveMessageEventFilter(event, Module.ApplyEmojis)
		end
		filtersInstalled = false
	end

	SyncBubbleWorker()

	if enable and C["Chat"].EmojiAutocomplete then
		InstallEditBoxAutocomplete()
	else
		TeardownEditBoxAutocomplete()
	end
end

function Module:CreateEmojis()
	Module:UpdateEmojis()
end
