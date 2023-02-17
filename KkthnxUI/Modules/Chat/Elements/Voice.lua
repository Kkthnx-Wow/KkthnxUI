local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Chat")
local VoiceActivityEventFrame = CreateFrame("Frame")

-- Sourced: Elv (ElvUI)

local math_modf = math.modf
local select = select

local C_VoiceChat_GetMemberName = C_VoiceChat.GetMemberName
local C_VoiceChat_SetPortraitTexture = C_VoiceChat.SetPortraitTexture
local CreateFrame = CreateFrame
local UIParent = UIParent

Module.voiceTalkingList = {}

-- http://www.wowwiki.com/ColorGradient
local function VoiceColorGradient(_, perc, ...)
	if perc >= 1 then
		return select(select("#", ...) - 2, ...)
	elseif perc <= 0 then
		return ...
	end

	local num = select("#", ...) / 3
	local segment, relperc = math_modf(perc * (num - 1))
	local r1, g1, b1, r2, g2, b2 = select((segment * 3) + 1, ...)

	return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
end

local function GetAvailableHead()
	for _, ChatHead in ipairs(Module.ChatHeadFrame) do
		if not ChatHead:IsShown() then
			return ChatHead
		end
	end
end

local function GetHeadByID(memberID)
	for _, ChatHead in ipairs(Module.ChatHeadFrame) do
		if ChatHead.memberID == memberID then
			return ChatHead
		end
	end
end

local function ConfigureHead(memberID, channelID)
	local frame = GetAvailableHead()
	if not frame then
		return
	end

	frame.memberID = memberID
	frame.channelID = channelID

	C_VoiceChat_SetPortraitTexture(frame.Portrait.texture, memberID, channelID)

	local memberName = C_VoiceChat_GetMemberName(memberID, channelID)
	local r, g, b = Voice_GetVoiceChannelNotificationColor(channelID)
	if frame.Name then
		frame.Name:SetText(memberName or "")
		frame.Name:SetVertexColor(r, g, b, 1)
	end

	frame:Show()
end

local function DeconfigureHead(memberID, channelID) -- memberID, channelID
	local frame = GetHeadByID(memberID)
	if not frame then
		return
	end

	frame.memberID = nil
	frame.channelID = nil
	frame:Hide()
end

VoiceActivityEventFrame:SetScript("OnEvent", function(_, event, ...)
	if event == "VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED" then
		local memberID, channelID, isTalking = ...

		if isTalking then
			Module.voiceTalkingList[memberID] = channelID
			ConfigureHead(memberID, channelID)
		else
			Module.voiceTalkingList[memberID] = nil
			DeconfigureHead(memberID, channelID)
		end
	elseif event == "VOICE_CHAT_CHANNEL_MEMBER_ENERGY_CHANGED" then
		local memberID, channelID, volume = ...
		local frame = GetHeadByID(memberID)
		if frame and channelID == frame.channelID then
			frame.StatusBar.anim.progress:SetChange(volume)
			frame.StatusBar.anim.progress:Play()

			frame.StatusBar:SetStatusBarColor(VoiceColorGradient(volume, 1, 0, 0, 1, 1, 0, 0, 1, 0))
		end
	end
end)

function Module:CreateVoiceActivity()
	-- Register voice activity events
	for i, event in ipairs({
		"VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED",
		"VOICE_CHAT_CHANNEL_MEMBER_ENERGY_CHANGED",
		"VOICE_CHAT_CHANNEL_TRANSMIT_CHANGED",
		"VOICE_CHAT_COMMUNICATION_MODE_CHANGED",
		"VOICE_CHAT_CHANNEL_MEMBER_REMOVED",
		"VOICE_CHAT_CHANNEL_REMOVED",
		"VOICE_CHAT_CHANNEL_DEACTIVATED",
	}) do
		VoiceActivityEventFrame:RegisterEvent(event)
	end
	_G.VoiceActivityManager:UnregisterAllEvents()

	Module.ChatHeadFrame = CreateFrame("Frame", "KKUI_ChatHeadFrame", UIParent)
	Module.ChatHeadFrame:SetPoint("LEFT", UIParent, "LEFT", 18, -280)
	Module.ChatHeadFrame:SetSize(200, 20)
	K.Mover(Module.ChatHeadFrame, "Voice Overlay", "Voice Overlay", { "LEFT", UIParent, "LEFT", 18, -280 }, 200, 20)

	local CHAT_MAX_HEADS = 5
	local CHAT_HEAD_HEIGHT = 20
	for i = 1, CHAT_MAX_HEADS do
		local chatHead = CreateFrame("Frame", "KKUI_ChatHead" .. i, Module.ChatHeadFrame)
		chatHead:SetSize(200, CHAT_HEAD_HEIGHT)

		chatHead.Portrait = CreateFrame("Frame", nil, chatHead)
		chatHead.Portrait:SetSize(CHAT_HEAD_HEIGHT, CHAT_HEAD_HEIGHT)
		chatHead.Portrait:SetPoint("TOPLEFT", chatHead, "TOPLEFT")
		chatHead.Portrait:CreateBorder()

		chatHead.Portrait.Texture = chatHead.Portrait:CreateTexture(nil, "OVERLAY")
		chatHead.Portrait.Texture:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		chatHead.Portrait.Texture:SetAllPoints(chatHead.Portrait)

		chatHead.Name = chatHead:CreateFontString(nil, "OVERLAY")
		chatHead.Name:SetFontObject(K.UIFont)
		chatHead.Name:SetFont(select(1, chatHead.Name:GetFont()), 14, select(3, chatHead.Name:GetFont()))
		chatHead.Name:SetPoint("LEFT", chatHead.Portrait, "RIGHT", 6, 0)

		chatHead.StatusBar = CreateFrame("StatusBar", nil, chatHead)
		chatHead.StatusBar:SetOrientation("VERTICAL")
		chatHead.StatusBar:SetPoint("RIGHT", chatHead.Portrait, "LEFT", -6, 0)
		chatHead.StatusBar:SetSize(8, CHAT_HEAD_HEIGHT)
		chatHead.StatusBar:CreateBorder()
		chatHead.StatusBar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
		chatHead.StatusBar:SetMinMaxValues(0, 1)

		chatHead.StatusBar.Anim = CreateAnimationGroup(chatHead.StatusBar)
		chatHead.StatusBar.Anim.Progress = chatHead.StatusBar.Anim:CreateAnimation("Progress")
		chatHead.StatusBar.Anim.Progress:SetEasing("Out")
		chatHead.StatusBar.Anim.Progress:SetDuration(0.3)

		chatHead:Hide()
		Module.ChatHeadFrame[i] = chatHead
	end

	for i, ChatHead in ipairs(Module.ChatHeadFrame) do
		ChatHead:ClearAllPoints()
		ChatHead:SetPoint("BOTTOM", i == 1 and Module.ChatHeadFrame or Module.ChatHeadFrame[i - 1], "TOP", 0, 6)
	end
end
