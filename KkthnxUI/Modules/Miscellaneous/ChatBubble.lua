local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G

local C_ChatBubbles_GetAllChatBubbles = _G.C_ChatBubbles.GetAllChatBubbles
local ChatTypeInfo = _G.ChatTypeInfo
local CreateFrame = _G.CreateFrame
local GetCVarBool = _G.GetCVarBool
local UIParent = _G.UIParent
local unpack = _G.unpack

local function getBackdrop(scale)
	return {
		bgFile = C["Media"].Blank,
		edgeFile = C["Media"].Glow,
		edgeSize = 4 * scale,
		insets = {
			left = 4 * scale,
			right = 4 * scale,
			top = 4 * scale,
			bottom = 4 * scale
		}
	}
end

local numBubbles = 0
local function SetupChatBubble()
	local function styleBubble(frame)
		numBubbles = numBubbles + 1

		for i = 1, frame:GetNumRegions() do
			local region = select(i, frame:GetRegions())
			if region:GetObjectType() == "Texture" then
				region:SetTexture(nil)
			elseif region:GetObjectType() == "FontString" then
				region:SetFontObject(K.GetFont(C["UIFonts"].ChatFonts))
			end
		end

		frame:SetFrameStrata("BACKGROUND")
		frame:SetFrameLevel(numBubbles % 128 + 1) -- try to avoid overlapping bubbles blending into each other
		frame:SetBackdrop(getBackdrop(1))
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

	local channels = {
		CHAT_MSG_SAY = "SAY",
		CHAT_MSG_YELL = "YELL",
		CHAT_MSG_PARTY = "PARTY",
		CHAT_MSG_PARTY_LEADER = "PARTY_LEADER",
	}

	local bubbleHook = CreateFrame("Frame")
	for event in next, events do
		bubbleHook:RegisterEvent(event)
	end

	bubbleHook:SetScript("OnEvent", function(self, event, msg)
		if GetCVarBool(events[event]) then
			self.elapsed = 0
			self.msg = msg

			local channel = channels[event]
			if channel then
				local info = ChatTypeInfo[channel]
				self.color = {info.r, info.g, info.b, 0.8}
			else
				self.color = nil
			end

			self:Show()
		end
	end)

	bubbleHook:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = self.elapsed + elapsed
		local chatbubble = findChatBubble(self.msg)
		if chatbubble or self.elapsed > 0.3 then
			self:Hide()
			if chatbubble then
				if not chatbubble.styled then
					styleBubble(chatbubble)
					chatbubble.styled = true
				end

				chatbubble:SetBackdropColor(0.04, 0.04, 0.04, 0.9)
				if self.color then
					chatbubble:SetBackdropBorderColor(unpack(self.color))
				else
					chatbubble:SetBackdropBorderColor(0, 0, 0, 0.8)
				end
			end
		end
	end)

	bubbleHook:Hide()
end

function Module:CreateChatBubble()
	if C["Skins"].ChatBubbles ~= true or K.CheckAddOnState("NiceBubbles") then
		return
	end

	SetupChatBubble()
end