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
-- on the selected tab rather than always the first window.
local function CurrentFrame()
	if _G.FCF_GetCurrentChatFrame then
		local frame = _G.FCF_GetCurrentChatFrame()
		if frame then
			return frame
		end
	end
	return _G.SELECTED_CHAT_FRAME or _G.ChatFrame1
end

-- opts (optional): atlas = atlas name used instead of texture (with a texture
-- fallback for older flavours), subtext = a second yellow tooltip line.
local function MakeButton(parent, texture, tooltip, onClick, texCoord, opts)
	opts = opts or {}
	local button = CreateFrame("Button", nil, parent)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:SetSize(SIZE, SIZE)
	K.CreateGradientBackground(button, 0.85)
	K.CreateBorder(button)

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
		local color = K.ClassColor
		self.KKUI_Border:SetVertexColor(color.r, color.g, color.b, 1)
		self.icon:SetVertexColor(color.r, color.g, color.b)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(tooltip, 1, 1, 1)
		if opts.subtext then
			GameTooltip:AddLine(opts.subtext, 1, 0.82, 0, true)
		end
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function(self)
		K.ResetBorderColor(self.KKUI_Border)
		self.icon:SetVertexColor(IDLE, IDLE, IDLE)
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
	bar:SetPoint("TOPLEFT", anchor, "TOPRIGHT", GAP, 0)
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

	-- Fade the strip in on hover of the chat, the tabs, or the strip itself.
	local function FadeIn()
		UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), FADE_IN)
	end
	local function FadeOut()
		if bar:IsMouseOver() or anchor:IsMouseOver() then
			return
		end
		UIFrameFadeOut(bar, 0.6, bar:GetAlpha(), FADE_OUT)
	end
	bar:SetScript("OnEnter", FadeIn)
	bar:SetScript("OnLeave", FadeOut)
	anchor:HookScript("OnEnter", FadeIn)
	anchor:HookScript("OnLeave", FadeOut)

	-- Only show the jump-to-newest button while the window is scrolled up, checked
	-- on a light throttle so it tracks manual scrolling and new incoming lines.
	local elapsed = 0
	bar:SetScript("OnUpdate", function(_, delta)
		elapsed = elapsed + delta
		if elapsed < 0.2 then
			return
		end
		elapsed = 0
		local frame = CurrentFrame()
		scroll:SetShown(frame and not frame:AtBottom())
	end)

	return bar
end
