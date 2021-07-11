local K, C = unpack(select(2, ...))

local _G = _G
local table_insert = _G.table.insert

local C_ChatBubbles_GetAllChatBubbles = _G.C_ChatBubbles.GetAllChatBubbles

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
		bg:CreateBorder(nil, nil, nil, nil, -14, nil, nil, nil, nil, nil, nil, nil, 10)
		bg.KKUI_Background:SetVertexColor(C["Media"].Backdrops.ColorBackdrop[1], C["Media"].Backdrops.ColorBackdrop[2], C["Media"].Backdrops.ColorBackdrop[3], C["Skins"].ChatBubbleAlpha)

		frame:DisableDrawLayer("BORDER")
		frame.Tail:SetAlpha(0)
		-- frame.String:SetFontObject(K.GetFont(C["UIFonts"].GeneralFonts))
		-- frame.String:SetFont(select(1, frame.String:GetFont()), 10, select(3, frame.String:GetFont()))
	end

	chatbubble.styled = true
end

table_insert(C.defaultThemes, function()
	if not C["Skins"].ChatBubbles then
		return
	end

	local events = {
		CHAT_MSG_SAY = "chatBubbles",
		CHAT_MSG_YELL = "chatBubbles",
		CHAT_MSG_MONSTER_SAY = "chatBubbles",
		CHAT_MSG_MONSTER_YELL = "chatBubbles",
		CHAT_MSG_PARTY = "chatBubblesParty",
		CHAT_MSG_PARTY_LEADER = "chatBubblesParty",
		CHAT_MSG_MONSTER_PARTY = "chatBubblesParty",
	}

	local bubbleHook = CreateFrame("Frame")
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
		if self.elapsed > 0.1 then
			for _, chatbubble in pairs(C_ChatBubbles_GetAllChatBubbles()) do
				reskinChatBubble(chatbubble)
			end
			self:Hide()
		end
	end)

	bubbleHook:Hide()
end)