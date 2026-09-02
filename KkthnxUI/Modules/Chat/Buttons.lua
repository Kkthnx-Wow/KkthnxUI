--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Chat/Buttons.lua
	Purpose:
		A slim vertical strip of icon buttons anchored to the left edge of the main
		chat window. It fades out while idle and brightens when the mouse is over the
		chat or the strip, so it stays out of the way until wanted. Buttons cover the
		common chat actions: channels, copy, jump to newest, and the config panel.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local Module = K:GetModule("Chat")

local _G = _G

local SIZE = 22
local GAP = 6
local FADE_IN = 1
local FADE_OUT = 0

-- Return the chat frame the user is currently looking at, so copy and scroll act
-- on the selected tab rather than always the first window. SELECTED_DOCK_FRAME is
-- the tab actually on screen. FCF_GetCurrentChatFrame is avoided here because it
-- only tracks the frame inside an FCF config action and is otherwise stale or
-- empty, which is what made the copy button open a blank window.
local function CurrentFrame()
	return _G.SELECTED_DOCK_FRAME or _G.SELECTED_CHAT_FRAME or _G.ChatFrame1
end

-- opts (optional): atlas = atlas name used instead of texture (with a texture
-- fallback for older flavours), subtext = a second yellow tooltip line.
local function MakeButton(parent, texture, tooltip, onClick, texCoord, opts)
	opts = opts or {}
	local button = CreateFrame("Button", nil, parent)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:SetSize(SIZE, SIZE)

	-- Same gradient skin as the chat, bar, and edit box: a horizontal fade with a
	-- class-coloured hairline top and bottom, no border. Hover brightens the lines.
	local color = K.ClassColor or { r = 0.4, g = 0.6, b = 1 }
	local grad = button:CreateTexture(nil, "BACKGROUND")
	grad:SetAllPoints()
	grad:SetColorTexture(1, 1, 1)
	K.ShadeGradient(grad, K.GradientAlpha.washSoft)
	button.KKUI_Lines = {}
	for _, edge in ipairs({ "TOP", "BOTTOM" }) do
		local line = button:CreateTexture(nil, "ARTWORK")
		line:SetHeight(1)
		line:SetPoint(edge .. "LEFT")
		line:SetPoint(edge .. "RIGHT")
		line:SetColorTexture(1, 1, 1)
		K.FadeGradient(line, color.r, color.g, color.b, K.GradientAlpha.lineSoft)
		button.KKUI_Lines[#button.KKUI_Lines + 1] = line
	end

	-- Desaturate every glyph and tint it a uniform soft grey so the mismatched
	-- Blizzard icon art reads as one cohesive monochrome set. Hover lifts both the
	-- icon and the border to the class colour together.
	local IDLE = 0.72
	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("TOPLEFT", 3, -3)
	icon:SetPoint("BOTTOMRIGHT", -3, 3)
	-- Prefer an atlas when one is given and supported, otherwise the texture path.
	if opts.atlas and C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(opts.atlas) then
		icon:SetAtlas(opts.atlas)
	else
		icon:SetTexture(texture)
	end
	icon:SetDesaturated(true)
	icon:SetVertexColor(IDLE, IDLE, IDLE)
	if texCoord then
		icon:SetTexCoord(unpack(texCoord))
	end
	button.icon = icon

	button:SetScript("OnEnter", function(self)
		local c = K.ClassColor
		self.icon:SetVertexColor(c.r, c.g, c.b)
		for _, line in ipairs(self.KKUI_Lines) do
			K.FadeGradient(line, c.r, c.g, c.b, K.GradientAlpha.lineActive, 0.2)
		end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(tooltip, 1, 1, 1)
		if opts.subtext then
			GameTooltip:AddLine(opts.subtext, 1, 0.82, 0, true)
		end
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function(self)
		local c = K.ClassColor
		self.icon:SetVertexColor(IDLE, IDLE, IDLE)
		for _, line in ipairs(self.KKUI_Lines) do
			K.FadeGradient(line, c.r, c.g, c.b, K.GradientAlpha.lineSoft)
		end
		GameTooltip:Hide()
	end)
	button:SetScript("OnClick", onClick)
	return button
end

function Module:CreateSideButtons()
	local anchor = _G.ChatFrame1
	if not anchor or self.sideButtons then
		return
	end

	-- The chat sits against the screen's left edge, so the strip goes on the right
	-- side of the window where there is room for it.
	local bar = CreateFrame("Frame", "KKUI_ChatButtons", UIParent)
	-- Lifted so the top button lines up with the tab strip rather than the frame's
	-- message top.
	bar:SetPoint("TOPLEFT", anchor, "TOPRIGHT", GAP, 6)
	bar:SetWidth(SIZE)
	bar:SetAlpha(FADE_OUT)

	local buttons = {}

	-- Toggle the channel quick-bar when it exists, otherwise open the edit box.
	buttons[#buttons + 1] = MakeButton(bar, "Interface\\GossipFrame\\ChatBubbleGossipIcon", L["Channels"] or "Channels", function()
		local channelBar = _G.KKUI_ChatBar
		if channelBar then
			channelBar:SetShown(not channelBar:IsShown())
		elseif ChatFrame_OpenChat then
			ChatFrame_OpenChat("", CurrentFrame())
		end
	end)

	buttons[#buttons + 1] = MakeButton(bar, C.Media.Textures.Copy or "Interface\\BUTTONS\\UI-GuildButton-PublicNote-Up", L["Copy"] or "Copy", function()
		Module:CopyChat(CurrentFrame())
	end)

	local scroll = MakeButton(bar, "Interface\\CHATFRAME\\UI-ChatIcon-ScrollDown-Up", L["Scroll to newest"] or "Scroll to newest", function()
		CurrentFrame():ScrollToBottom()
	end)
	buttons[#buttons + 1] = scroll
	self.scrollButton = scroll

	buttons[#buttons + 1] = MakeButton(bar, "Interface\\Buttons\\UI-GroupLoot-Dice-Up", L["Quick Roll"] or "Quick Roll", function(_, mouseButton)
		if mouseButton == "RightButton" then
			-- The tooltip swears a right-click is a guaranteed perfect roll. It is
			-- not. Print a local-only troll result so nobody but the roller sees it.
			local troll = -math.random(1, 100)
			K.Print(string.format(L["You roll a perfect %d out of 100. Flawless."] or "You roll a perfect %d out of 100. Flawless.", troll))
		elseif RandomRoll then
			RandomRoll(1, 100)
		end
	end, nil, { atlas = "charactercreate-icon-dice", subtext = L["Right-click for a guaranteed perfect roll."] or "Right-click for a guaranteed perfect roll." })

	buttons[#buttons + 1] = MakeButton(bar, "Interface\\Buttons\\UI-OptionsButton", L["Config"] or "Config", function()
		if K.ToggleConfigGUI then
			K.ToggleConfigGUI()
		end
	end)

	-- Stack the buttons top to bottom and size the strip to fit.
	local y = 0
	for _, button in ipairs(buttons) do
		button:SetPoint("TOP", bar, "TOP", 0, y)
		y = y - (SIZE + GAP)
	end
	bar:SetHeight(math.max(SIZE, -y - GAP))
	self.sideButtons = bar
	self.sideButtonList = buttons

	-- Drive the fade from a single throttled loop rather than OnEnter/OnLeave
	-- events. Event-based fading could strand the strip fully visible when a fade
	-- was interrupted or a leave never fired (opening the config panel over it, a
	-- fast mouse move). Here the target alpha is recomputed every tick from the
	-- live mouse-over state, so the strip can never get stuck. The tab dock counts
	-- as hovering the chat so the strip stays up while picking a tab.
	local dock = _G.GeneralDockManager
	local elapsed = 0
	local FADE_STEP = 4 -- alpha per second, so a full fade takes about a quarter second
	bar:SetScript("OnUpdate", function(_, delta)
		local over = bar:IsMouseOver() or anchor:IsMouseOver() or (dock and dock:IsMouseOver())
		local target = over and FADE_IN or FADE_OUT
		local current = bar:GetAlpha()
		if current ~= target then
			local step = FADE_STEP * delta
			if current < target then
				bar:SetAlpha(math.min(target, current + step))
			else
				bar:SetAlpha(math.max(target, current - step))
			end
		end

		-- Only show the jump-to-newest button while the window is scrolled up,
		-- checked on a light throttle so it tracks scrolling and new lines.
		elapsed = elapsed + delta
		if elapsed >= 0.2 then
			elapsed = 0
			local frame = CurrentFrame()
			scroll:SetShown(frame and not frame:AtBottom())
		end
	end)

	return bar
end
