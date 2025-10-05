local K, C = KkthnxUI[1], KkthnxUI[2]

-- Localize frequently used globals
local table_insert = table.insert
local pairs = pairs
local ipairs = ipairs
local CreateFrame = CreateFrame
local GetCVarBool = GetCVarBool
local UIParent = UIParent
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

		local backdropColor = C["Media"].Backdrops.ColorBackdrop
		bg.KKUI_Background:SetVertexColor(backdropColor[1], backdropColor[2], backdropColor[3], C["Skins"].ChatBubbleAlpha)

		local str = frame.String
		if str and str.GetTextColor then
			-- Throttle border color updates to reduce per-frame cost; use HookScript to avoid clobbering
			local accum = 0
			frame:HookScript("OnUpdate", function(_, elapsed)
				accum = accum + (elapsed or 0)
				if accum > 0.1 then
					accum = 0
					local r, g, b = str:GetTextColor()
					bg.KKUI_Border:SetVertexColor(r, g, b)
				end
			end)
			local r, g, b = str:GetTextColor()
			bg.KKUI_Border:SetVertexColor(r, g, b)
		else
			K.SetBorderColor(bg.KKUI_Border)
		end
	end

	chatbubble.styled = true
end

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
