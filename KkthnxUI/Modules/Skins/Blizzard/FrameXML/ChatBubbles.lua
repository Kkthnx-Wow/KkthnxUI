local C = KkthnxUI[2]

local table_insert = table.insert

local C_ChatBubbles_GetAllChatBubbles = C_ChatBubbles.GetAllChatBubbles

local function reskinChatBubble(chatbubble)
	if chatbubble.styled then
		return
	end

	local frame = chatbubble:GetChildren()
	if frame and not frame:IsForbidden() then
		local bg = CreateFrame("Frame", nil, frame)
		bg:SetFrameLevel(frame:GetFrameLevel())
		bg:SetScale(UIParent:GetEffectiveScale())
		bg:SetAllPoints(frame)
		bg:CreateBorder(nil, nil, nil, nil, -18, nil, nil, nil, nil, 14)

		frame:DisableDrawLayer("BORDER")
		frame.Tail:SetAlpha(0)

		bg.KKUI_Background:SetVertexColor(C["Media"].Backdrops.ColorBackdrop[1], C["Media"].Backdrops.ColorBackdrop[2], C["Media"].Backdrops.ColorBackdrop[3], C["Skins"].ChatBubbleAlpha)
	end

	chatbubble.styled = true
end

table_insert(C.defaultThemes, function()
	if not C["Skins"].ChatBubbles then
		return
	end

	-- Create a table of chat events to listen for
	local events = {
		CHAT_MSG_SAY = "chatBubbles",
		CHAT_MSG_YELL = "chatBubbles",
		CHAT_MSG_MONSTER_SAY = "chatBubbles",
		CHAT_MSG_MONSTER_YELL = "chatBubbles",
		CHAT_MSG_PARTY = "chatBubblesParty",
		CHAT_MSG_PARTY_LEADER = "chatBubblesParty",
		CHAT_MSG_MONSTER_PARTY = "chatBubblesParty",
	}

	-- Create a frame to hook chat events and reskin chat bubbles
	local bubbleHook = CreateFrame("Frame")

	-- Register the chat events to listen for
	for event in next, events do
		bubbleHook:RegisterEvent(event)
	end

	bubbleHook:SetScript("OnEvent", function(self, event)
		if GetCVarBool(events[event]) then
			self.elapsed = 0
			self:Show()
		end
	end)

	bubbleHook:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = self.elapsed + elapsed

		-- Only reskin chat bubbles every 0.1 seconds
		if self.elapsed > 0.1 then
			for _, chatbubble in pairs(C_ChatBubbles_GetAllChatBubbles()) do
				reskinChatBubble(chatbubble)
			end

			self:Hide()
		end
	end)

	bubbleHook:Hide()
end)
