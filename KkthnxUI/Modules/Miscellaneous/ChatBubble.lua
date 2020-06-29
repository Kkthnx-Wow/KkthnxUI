local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G

local CreateFrame = _G.CreateFrame
local GetCVarBool = _G.GetCVarBool
local C_ChatBubbles_GetAllChatBubbles = _G.C_ChatBubbles.GetAllChatBubbles

local function getBackdrop()
	return {
		bgFile = C["Media"].Blank,
		edgeFile = C["Media"].Border,
		edgeSize = 12,
		insets = {
			left = 8,
			right = 8,
			top = 8,
			bottom = 8
		}
	}
end

function Module:CreateChatBubbles()
	if not C["Skins"].ChatBubbles then
		return
	end

	local function styleBubble(frame)
		for i = 1, frame:GetNumRegions() do
			local region = select(i, frame:GetRegions())
			if region:GetObjectType() == "Texture" then
				region:SetTexture(nil)
			elseif region:GetObjectType() == "FontString" then
				region:SetFontObject(K.GetFont(C["UIFonts"].SkinFonts))
			end
		end

		frame:SetFrameStrata("BACKGROUND")
		frame:SetBackdrop(getBackdrop())
		frame:SetBackdropColor(.04, .04, .04, 0.9)
		frame:SetBackdropBorderColor(1, 1, 1, 1)
		frame:SetScale(UIParent:GetScale())
	end

	local function findChatBubble(msg)
		local chatbubbles = C_ChatBubbles_GetAllChatBubbles()
		for index = 1, #chatbubbles do
			local chatbubble = chatbubbles[index]
			for i = 1, chatbubble:GetNumRegions() do
				local region = select(i, chatbubble:GetRegions())
				if region:GetObjectType() == "FontString" and region:GetText() == msg then
					return chatbubble
				end
			end
		end
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

	bubbleHook:SetScript("OnEvent", function(self, event, msg)
		if GetCVarBool(events[event]) then
			self.elapsed = 0
			self.msg = msg
			self:Show()
		end
	end)

	bubbleHook:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = self.elapsed + elapsed
		local chatbubble = findChatBubble(self.msg)
		if chatbubble or self.elapsed > .3 then
			self:Hide()
			if chatbubble and not chatbubble.styled then
				styleBubble(chatbubble)
				chatbubble.styled = true
			end
		end
	end)

	bubbleHook:Hide()
end