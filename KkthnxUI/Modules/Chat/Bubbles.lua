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
local GetCVarBool = GetCVarBool
local GetAllChatBubbles = C_ChatBubbles and C_ChatBubbles.GetAllChatBubbles

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

local function OnEvent(self, event)
	local cvar = SPAWN_EVENTS[event]
	if cvar and GetCVarBool(cvar) then
		self.elapsed = 0
		self:Show()
	end
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
	watcher:SetScript("OnEvent", OnEvent)
	watcher:SetScript("OnUpdate", OnUpdate)
end
