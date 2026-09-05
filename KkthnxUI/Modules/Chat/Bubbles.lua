--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Chat/Bubbles.lua
	Purpose:
		Give the in-world chat bubbles our border and dark background instead of
		the stock rounded art. Bubbles are created and pooled by the client, so we
		watch the chat events that spawn them and, a frame later, walk the live
		bubble list and style any we have not touched yet. Each bubble is styled
		once and flagged, so the walk stays cheap.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("Chat")

local pairs = pairs
local wipe = wipe
local GetCVarBool = GetCVarBool
local CreateFrame = CreateFrame
local Ambiguate = Ambiguate
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local IsSecret = K.IsSecret
local GetAllChatBubbles = C_ChatBubbles and C_ChatBubbles.GetAllChatBubbles

-- A bubble carries no reference to whoever spoke, only the words. The chat event
-- that spawns it does know, so the sender is stashed against the message text as
-- it arrives and looked up again when the bubble turns up a frame later. Cleared
-- on a loading screen so the tables cannot grow forever.
local senderByMessage = {}
local guidByMessage = {}

-- The events that spawn a bubble, paired with the cvar that has to be on for
-- that kind to appear. No point walking the list if the bubble is disabled.
local SPAWN_EVENTS = {
	CHAT_MSG_SAY = "chatBubbles",
	CHAT_MSG_YELL = "chatBubbles",
	CHAT_MSG_MONSTER_SAY = "chatBubbles",
	CHAT_MSG_MONSTER_YELL = "chatBubbles",
	CHAT_MSG_PARTY = "chatBubblesParty",
	CHAT_MSG_PARTY_LEADER = "chatBubblesParty",
	CHAT_MSG_MONSTER_PARTY = "chatBubblesParty",
}

-- How far our backdrop sits inside the bubble holder, in the bubble's own space.
local INSET = 4

-- The bubble's own text. Blizzard keeps it on the holder, but fall back to a scan
-- so a layout change does not silently kill the name.
local function BubbleText(holder)
	if holder.String then
		return holder.String
	end
	for _, region in ipairs({ holder:GetRegions() }) do
		if region.GetObjectType and region:GetObjectType() == "FontString" then
			return region
		end
	end
end

-- Put the speaker's name above the bubble, class coloured. Bubbles are pooled, so
-- this runs on every show and clears itself when the message is not one we saw.
local function UpdateBubbleName(bubble, holder)
	local label = bubble.KKUI_Name
	if not label then
		return
	end

	local str = BubbleText(holder)
	local text = str and str:GetText()
	if not text or IsSecret(text) then
		label:SetText("")
		return
	end

	local sender = senderByMessage[text]
	if not sender then
		label:SetText("")
		return
	end

	-- Class colour when the speaker resolves, otherwise our own accent.
	local color
	local guid = guidByMessage[text]
	if guid and not IsSecret(guid) then
		local _, class = GetPlayerInfoByGUID(guid)
		if class and not IsSecret(class) then
			color = K.Colors.class and K.Colors.class[class]
			if not color and _G.RAID_CLASS_COLORS then
				color = _G.RAID_CLASS_COLORS[class]
			end
		end
	end

	local r = color and (color.r or color[1]) or K.Colors.accent[1]
	local g = color and (color.g or color[2]) or K.Colors.accent[2]
	local b = color and (color.b or color[3]) or K.Colors.accent[3]
	label:SetText(sender)
	label:SetTextColor(r, g, b)
end

-- Style one bubble. The first child is the holder that carries the text, the
-- default backdrop on its BORDER layer, and a pointer tail. We drop both and
-- give the holder our own look.
local function SkinBubble(bubble)
	if bubble.KKUI_Styled then
		return
	end

	local holder = bubble:GetChildren()
	if not holder or holder:IsForbidden() then
		return
	end

	holder:DisableDrawLayer("BORDER")
	if holder.Tail then
		holder.Tail:SetAlpha(0)
	end

	-- Chat bubbles live in the WorldFrame, which does not inherit the UI scale. Our
	-- border is sized in pixel perfect units derived from UIParent, so drawn straight
	-- onto the holder it comes out at the wrong thickness against the rest of the UI.
	-- Put the art on its own frame and scale that back to the UI's effective scale.
	-- Scaling the holder itself is not an option, it would take the text with it.
	local backdrop = CreateFrame("Frame", nil, holder)
	backdrop:SetScale(UIParent:GetEffectiveScale())
	backdrop:SetPoint("TOPLEFT", holder, "TOPLEFT", INSET, -INSET)
	backdrop:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", -INSET, INSET)
	backdrop:SetFrameLevel(math.max(0, holder:GetFrameLevel() - 1))

	K.CreateBackground(backdrop, 0.05, 0.05, 0.05, 0.9)
	K.CreateBorder(backdrop)

	bubble.KKUI_Backdrop = backdrop

	-- Speaker name above the bubble. Parented to the holder rather than our scaled
	-- backdrop so it sits in the same space as the bubble's own text and matches its
	-- size. The client reuses bubbles, so the name is refreshed on every show rather
	-- than written once.
	if C.Chat.BubbleName then
		local name = holder:CreateFontString(nil, "OVERLAY")
		local font, size, outline = GameFontNormal:GetFont()
		name:SetFont(font, size * 0.9, outline)
		name:SetPoint("BOTTOM", holder, "TOP", 0, 2)
		name:SetJustifyH("CENTER")
		bubble.KKUI_Name = name

		UpdateBubbleName(bubble, holder)
		bubble:HookScript("OnShow", function(self)
			UpdateBubbleName(self, holder)
		end)
	end

	bubble.KKUI_Styled = true
end

-- A short pulse after a spawning event: the bubble is not on the list on the
-- same frame it is requested, so give it a moment then style everything unstyled.
local watcher

local function OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed < 0.1 then
		return
	end
	self.elapsed = 0
	self:Hide()

	for _, bubble in pairs(GetAllChatBubbles()) do
		SkinBubble(bubble)
	end
end

local function OnEvent(self, event, message, sender, _, _, _, _, _, _, _, _, _, guid)
	if event == "PLAYER_ENTERING_WORLD" then
		wipe(senderByMessage)
		wipe(guidByMessage)
		return
	end

	local cvar = SPAWN_EVENTS[event]
	if not (cvar and GetCVarBool(cvar)) then
		return
	end

	-- Stash who said it against the words, which is the only handle the bubble
	-- gives us later. Both can be secret on Midnight, and a secret cannot key a
	-- table, so an unreadable message simply goes unnamed.
	if C.Chat.BubbleName and message and not IsSecret(message) and sender and not IsSecret(sender) then
		senderByMessage[message] = Ambiguate(sender, "none")
		guidByMessage[message] = (guid and not IsSecret(guid)) and guid or nil
	end

	self.elapsed = 0
	self:Show()
end

function Module:SetupBubbles()
	if not C.Chat.SkinBubbles or not GetAllChatBubbles then
		return
	end

	watcher = CreateFrame("Frame")
	watcher:Hide()
	for event in pairs(SPAWN_EVENTS) do
		watcher:RegisterEvent(event)
	end
	-- Drop the caches on a loading screen so they cannot grow for a whole session.
	watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
	watcher:SetScript("OnEvent", OnEvent)
	watcher:SetScript("OnUpdate", OnUpdate)
end
