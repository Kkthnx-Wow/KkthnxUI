--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Skins chat bubbles for various chat channels.
-- - Design: Hooks into chat message events to identify and reskin chat bubbles with custom borders.
-- - Events: CHAT_MSG_SAY, CHAT_MSG_YELL, etc.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local ipairs = _G.ipairs
local pairs = _G.pairs
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local GetCVarBool = _G.GetCVarBool
local UIParent = _G.UIParent
local C_ChatBubbles_GetAllChatBubbles = _G.C_ChatBubbles.GetAllChatBubbles

local function reskinChatBubble(chatbubble)
	local frame = chatbubble:GetChildren()
	if not frame or frame:IsForbidden() then
		return
	end

	if not chatbubble.styled then
		local bg = CreateFrame("Frame", nil, frame)
		bg:SetFrameLevel(frame:GetFrameLevel())
		bg:SetScale(UIParent:GetEffectiveScale())
		bg:SetAllPoints(frame)
		bg:CreateBorder(nil, nil, nil, nil, -18, nil, nil, nil, nil, 14)

		frame:DisableDrawLayer("BORDER")
		frame.Tail:SetAlpha(0)

		local backdropColor = C["Media"].Backdrops.ColorBackdrop
		bg.KKUI_Background:SetVertexColor(backdropColor[1], backdropColor[2], backdropColor[3], C["Skins"].ChatBubbleAlpha)

		chatbubble.kkuiBG = bg
		chatbubble.styled = true
	end

	-- REASON: Re-tint the border to the message's channel colour on each shared poll cycle so
	-- recycled bubbles pick up the right colour. This replaces a permanent per-bubble OnUpdate
	-- that polled text colour every 0.1s for the life of every bubble (pure wasted CPU).
	local bg = chatbubble.kkuiBG
	if bg then
		local str = frame.String
		if str and str.GetTextColor then
			local r, g, b = str:GetTextColor()
			bg.KKUI_Border:SetVertexColor(r or 1, g or 1, b or 1)
		else
			K.SetBorderColor(bg.KKUI_Border)
		end
	end
end

-- REASON: Main entry point for Blizzard Chat Bubbles skinning.
table_insert(C.defaultThemes, function()
	if not C["Skins"].ChatBubbles then
		return
	end

	local bubbleHook = CreateFrame("Frame")
	local events = {
		CHAT_MSG_SAY = "chatBubbles",
		CHAT_MSG_YELL = "chatBubbles",
		CHAT_MSG_MONSTER_SAY = "chatBubbles",
		CHAT_MSG_MONSTER_YELL = "chatBubbles",
		CHAT_MSG_PARTY = "chatBubblesParty",
		CHAT_MSG_PARTY_LEADER = "chatBubblesParty",
		CHAT_MSG_MONSTER_PARTY = "chatBubblesParty",
	}

	for event in pairs(events) do
		bubbleHook:RegisterEvent(event)
	end

	bubbleHook:SetScript("OnEvent", function(self, event)
		if GetCVarBool(events[event]) then
			self.elapsed = 0
			self:Show()
		end
	end)

	bubbleHook:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed

		if self.elapsed > 0.1 then
			local chatBubbles = C_ChatBubbles_GetAllChatBubbles()
			if chatBubbles then
				for _, chatbubble in ipairs(chatBubbles) do
					reskinChatBubble(chatbubble)
				end
			end

			self:Hide()
		end
	end)

	bubbleHook:Hide()
end)
