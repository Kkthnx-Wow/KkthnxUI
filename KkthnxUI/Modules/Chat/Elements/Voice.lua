local K, C = unpack(select(2, ...))
local Module = K:GetModule("Chat")
local VoiceActivityEventFrame = CreateFrame("Frame")

-- Sourced: Elv (ElvUI)

local _G = _G
local math_modf = _G.math.modf
local select = _G.select

local C_VoiceChat_GetMemberName = _G.C_VoiceChat.GetMemberName
local C_VoiceChat_SetPortraitTexture = _G.C_VoiceChat.SetPortraitTexture
local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent
local Voice_GetVoiceChannelNotificationColor = _G.Voice_GetVoiceChannelNotificationColor

local voiceTalkingList = {}

-- http://www.wowwiki.com/ColorGradient
local function VoiceColorGradient(_, perc, ...)
	if perc >= 1 then
		return select(select("#", ...) - 2, ...)
	elseif perc <= 0 then
		return ...
	end

	local num = select("#", ...) / 3
	local segment, relperc = math_modf(perc*(num-1))
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

local function DeconfigureHead(memberID) -- memberID, channelID
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
			voiceTalkingList[memberID] = channelID
			ConfigureHead(memberID, channelID)
		else
			voiceTalkingList[memberID] = nil
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
	VoiceActivityEventFrame:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED")
	VoiceActivityEventFrame:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_ENERGY_CHANGED")
	VoiceActivityEventFrame:RegisterEvent("VOICE_CHAT_CHANNEL_TRANSMIT_CHANGED")
	VoiceActivityEventFrame:RegisterEvent("VOICE_CHAT_COMMUNICATION_MODE_CHANGED")
	VoiceActivityEventFrame:RegisterEvent("VOICE_CHAT_CHANNEL_MEMBER_REMOVED")
	VoiceActivityEventFrame:RegisterEvent("VOICE_CHAT_CHANNEL_REMOVED")
	VoiceActivityEventFrame:RegisterEvent("VOICE_CHAT_CHANNEL_DEACTIVATED")
	_G.VoiceActivityManager:UnregisterAllEvents()

	-- Chat Heads Frame
	Module.ChatHeadFrame = CreateFrame("Frame", "KKUI_ChatHeadFrame", UIParent)
	Module.ChatHeadFrame:SetPoint("LEFT", UIParent, "LEFT", 18, -280)
	Module.ChatHeadFrame:SetSize(200, 20)
	K.Mover(Module.ChatHeadFrame, "Voice Overlay", "Voice Overlay", {"LEFT", UIParent, "LEFT", 18, -280}, 200, 20)

	local CHAT_MAX_HEADS = 5
	local CHAT_HEAD_HEIGHT = 20
	for i = 1, CHAT_MAX_HEADS do
		local chatHead = CreateFrame("Frame", "KKUI_ChatHeadFrame"..i, Module.ChatHeadFrame)
		chatHead:SetSize(200, CHAT_HEAD_HEIGHT)

		chatHead.Portrait = CreateFrame("Frame", nil, chatHead)
		chatHead.Portrait:SetWidth(CHAT_HEAD_HEIGHT)
		chatHead.Portrait:SetHeight(CHAT_HEAD_HEIGHT)
		chatHead.Portrait:SetPoint("TOPLEFT", chatHead, "TOPLEFT")
		chatHead.Portrait:CreateBorder()

		chatHead.Portrait.texture = chatHead.Portrait:CreateTexture(nil, "OVERLAY")
		chatHead.Portrait.texture:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		chatHead.Portrait.texture:SetAllPoints(chatHead.Portrait)

		chatHead.Name = chatHead:CreateFontString(nil, "OVERLAY")
		chatHead.Name:FontTemplate(nil, 14)
		chatHead.Name:SetPoint("LEFT", chatHead.Portrait, "RIGHT", 6, 0)

		chatHead.StatusBar = CreateFrame("StatusBar", nil, chatHead)
		chatHead.StatusBar:SetOrientation("Vertical")
		chatHead.StatusBar:SetPoint("RIGHT", chatHead.Portrait, "LEFT", -6, 0)
		chatHead.StatusBar:SetWidth(8)
		chatHead.StatusBar:SetHeight(CHAT_HEAD_HEIGHT)
		chatHead.StatusBar:CreateBorder()
		chatHead.StatusBar:SetStatusBarTexture(C["Media"].Statusbars.KkthnxUIStatusbar)
		chatHead.StatusBar:SetMinMaxValues(0, 1)

		chatHead.StatusBar.anim = _G.CreateAnimationGroup(chatHead.StatusBar)
		chatHead.StatusBar.anim.progress = chatHead.StatusBar.anim:CreateAnimation("Progress")
		chatHead.StatusBar.anim.progress:SetEasing("Out")
		chatHead.StatusBar.anim.progress:SetDuration(.3)

		chatHead:Hide()
		Module.ChatHeadFrame[i] = chatHead
	end

	for i, ChatHead in ipairs(Module.ChatHeadFrame) do
		ChatHead:ClearAllPoints()
		ChatHead:SetPoint("BOTTOM", i == 1 and Module.ChatHeadFrame or Module.ChatHeadFrame[i - 1], "TOP", 0, 6)
	end
end