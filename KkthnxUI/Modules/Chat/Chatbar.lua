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
	bar:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -10)
	bar:SetHeight(18)

	-- Border offset is 4px outside each button, so buttons need an 8px gap or
	-- their borders overlap and look stacked. Each button is sized to its label.
	local PADDING = 14
	local GAP = 8
	local buttons = BuildButtons()
	local x = 0
	for _, data in ipairs(buttons) do
		local button = CreateFrame("Button", nil, bar)
		button:SetHeight(18)
		-- Same gradient the rest of the UI uses, so the row reads as ours rather
		-- than a flat black strip.
		K.CreateGradientBackground(button, 0.85)
		K.CreateBorder(button)

		local text = button:CreateFontString(nil, "OVERLAY")
		K.SetFont(text, 11, K.FontOutlineStyle())
		text:SetPoint("CENTER")
		text:SetText(data[4])
		text:SetTextColor(data[1], data[2], data[3])

		local width = math.ceil(text:GetStringWidth()) + PADDING
		button:SetWidth(width)
		button:SetPoint("LEFT", bar, "LEFT", x, 0)
		x = x + width + GAP

		button:SetScript("OnClick", data[5])
		button:SetScript("OnEnter", function(self)
			self.KKUI_Border:SetVertexColor(data[1], data[2], data[3], 1)
		end)
		button:SetScript("OnLeave", function(self)
			K.ResetBorderColor(self.KKUI_Border)
		end)
	end

	bar:SetWidth(math.max(1, x - GAP))
	self.chatBar = bar
	return bar
end
