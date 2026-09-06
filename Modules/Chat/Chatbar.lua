--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Chat/Chatbar.lua
	Purpose:
		A compact row of channel buttons below the chat that open the edit box on
		the right channel with one click. Each button is coloured to its channel.
		Whisper replies to the last whisper. Emote and roll fire directly.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

local Module = K:GetModule("Chat")

local _G = _G

-- Open the main edit box on a given chat type.
local function OpenChat(chatType)
	local edit = _G.ChatFrame1EditBox
	if not edit then
		return
	end
	edit:SetAttribute("chatType", chatType)
	ChatEdit_UpdateHeader(edit)
	edit:Show()
	edit:SetFocus()
end

-- { r, g, b, label, onClick }
local function BuildButtons()
	return {
		{ 1, 1, 1, "Say", function()
			OpenChat("SAY")
		end },
		{ 1, 0.5, 1, "Wsp", function()
			ChatFrame_ReplyTell(_G.ChatFrame1)
		end },
		{ 0.65, 0.65, 1, "Party", function()
			OpenChat("PARTY")
		end },
		{ 1, 0.28, 0.04, "Raid", function()
			OpenChat("RAID")
		end },
		{ 1, 0.5, 0, "Inst", function()
			OpenChat("INSTANCE_CHAT")
		end },
		{ 0.25, 1, 0.25, "Guild", function()
			OpenChat("GUILD")
		end },
		{ 1, 0.75, 0.75, "Emote", function()
			OpenChat("EMOTE")
		end },
		{ 1, 1, 0.4, "Roll", function()
			RandomRoll(1, 100)
		end },
	}
end

function Module:CreateChatBar()
	local anchor = _G.ChatFrame1
	if not anchor then
		return
	end

	local bar = CreateFrame("Frame", "KKUI_ChatBar", UIParent)
	bar:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -12)
	bar:SetHeight(20)

	-- The same horizontal gradient the chat window wears, so the channel row reads
	-- as a continuation of the chat skin: dark on the left fading to clear on the
	-- right, with a class-coloured hairline along the top and bottom.
	-- The chat gradient reaches about 4px left of the frame, so the bar gradient is
	-- extended the same amount to sit flush under it.
	local color = K.ClassColor or { r = 0.4, g = 0.6, b = 1 }
	local grad = bar:CreateTexture(nil, "BACKGROUND")
	grad:SetPoint("TOPLEFT", bar, "TOPLEFT", -4, 0)
	grad:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0)
	grad:SetColorTexture(1, 1, 1)
	K.ShadeGradient(grad)
	for _, edge in ipairs({ "TOP", "BOTTOM" }) do
		local line = bar:CreateTexture(nil, "ARTWORK")
		line:SetHeight(1)
		line:SetPoint(edge .. "LEFT", bar, edge .. "LEFT", -4, 0)
		line:SetPoint(edge .. "RIGHT")
		line:SetColorTexture(1, 1, 1)
		K.FadeGradient(line, color.r, color.g, color.b, K.GradientAlpha.line)
	end

	-- Borderless labels sitting on the bar gradient, so the row matches the chat
	-- window rather than looking like a strip of boxed buttons. Hover lifts a soft
	-- channel-coloured wash behind the label instead of a border.
	-- Labels are left-anchored and the first one sits at the bar's left edge, so the
	-- row lines up flush with the chat text above it. The button is just wide enough
	-- for its label plus a little breathing room for the hover wash.
	local PADDING = 8
	local GAP = 8
	local buttons = BuildButtons()
	local x = 0
	for _, data in ipairs(buttons) do
		local button = CreateFrame("Button", nil, bar)
		button:SetHeight(20)

		local text = button:CreateFontString(nil, "OVERLAY")
		K.SetFont(text, 11, K.FontOutlineStyle())
		text:SetPoint("LEFT")
		text:SetText(data[4])
		text:SetTextColor(data[1], data[2], data[3])

		-- Highlight hugs the label itself, not the button, so it stays centred on the
		-- text even though the label is left-anchored for the flush alignment.
		local hover = button:CreateTexture(nil, "ARTWORK")
		hover:SetPoint("LEFT", text, "LEFT", -4, 0)
		hover:SetPoint("RIGHT", text, "RIGHT", 4, 0)
		hover:SetPoint("TOP", button, "TOP")
		hover:SetPoint("BOTTOM", button, "BOTTOM")
		hover:SetColorTexture(data[1], data[2], data[3], 0.2)
		hover:Hide()

		local width = math.ceil(text:GetStringWidth()) + PADDING
		button:SetWidth(width)
		button:SetPoint("LEFT", bar, "LEFT", x, 0)
		x = x + width + GAP

		button:SetScript("OnClick", data[5])
		button:SetScript("OnEnter", function()
			hover:Show()
			text:SetTextColor(K.Colors.offWhite[1], K.Colors.offWhite[2], K.Colors.offWhite[3])
		end)
		button:SetScript("OnLeave", function()
			hover:Hide()
			text:SetTextColor(data[1], data[2], data[3])
		end)
	end

	bar:SetWidth(math.max(1, x - GAP))
	self.chatBar = bar
	return bar
end
