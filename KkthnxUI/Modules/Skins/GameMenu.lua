--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Skins/GameMenu.lua
	Purpose:
		Skin the pause menu (GameMenuFrame) to match the rest of the UI and add a
		KkthnxUI button that opens our options. The retail menu builds its buttons
		from a pool and lays them out on every open, so we reskin the pool through
		its InitButtons hook and reposition our own button (and regrow the frame) in
		a Layout hook. Retail only for now: older
		flavours use the fixed, named-button menu, which is a separate job.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:NewModule("GameMenu")

local _G = _G
local ipairs = ipairs
local tsort = table.sort
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local HideUIPanel = HideUIPanel

-- Gap above our inserted button (kept to the base gap so it reads as part of the
-- Options group), a fallback gap, the minimum gap every button gets so the tight
-- Blizzard spacing opens up, and the padding under the last button.
local INSERT_GAP = 6
local FALLBACK_GAP = 6
local MIN_GAP = 6
local BOTTOM_PAD = 16
local floor = math.floor

-- Our button is inserted into the stack just under Options and the frame regrows.
local kkuiButton

-- Give a pool button our flat look: strip its art, add our background and border,
-- and tint the highlight to the accent colour.
local function StyleMenuButton(button)
	if button.__kkuiStyled then
		return
	end
	button.__kkuiStyled = true

	if button.DisableDrawLayer then
		button:DisableDrawLayer("BACKGROUND")
	end
	if K.SkinButton then
		K.SkinButton(button)
	else
		K.CreateGradientBackground(button, 0.85)
		K.CreateBorder(button)
	end

	local hl = button.GetHighlightTexture and button:GetHighlightTexture()
	if hl then
		local a = K.ClassColor or { r = 0.36, g = 0.55, b = 0.81 }
		hl:SetColorTexture(a.r or a[1], a.g or a[2], a.b or a[3], 0.25)
	end
end

-- Strip the Blizzard window chrome and drop in ours plus a header divider.
local function SkinFrame(frame)
	if frame.__kkuiSkinned then
		return
	end
	frame.__kkuiSkinned = true

	if frame.Border then
		frame.Border:SetAlpha(0)
	end
	if frame.NineSlice then
		frame.NineSlice:SetAlpha(0)
	end
	if K.StripTextures then
		K.StripTextures(frame)
	end
	K.CreateGradientBackground(frame, 0.95)
	K.CreateBorder(frame)

	local header = frame.Header
	if header then
		if K.StripTextures then
			K.StripTextures(header)
		end
		if header.Text then
			header.Text:SetTextColor(1, 0.82, 0)
		end
		-- A thin accent divider under the header, like the rest of our panels.
		local line = header:CreateTexture(nil, "ARTWORK")
		line:SetHeight(1)
		line:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 4)
		line:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 4)
		local a = K.ClassColor or { r = 0.36, g = 0.55, b = 0.81 }
		line:SetColorTexture(a.r or a[1], a.g or a[2], a.b or a[3], 0.5)
	end
end

-- Our options button, created once and re-anchored on every layout.
local function EnsureButton(frame)
	if kkuiButton then
		return kkuiButton
	end
	local button = CreateFrame("Button", "KKUI_GameMenuButton", frame, "UIPanelButtonTemplate")
	button:SetText("|cff5C8BCFKkthnxUI|r")
	StyleMenuButton(button)
	button.__kkuiStyled = true
	button:SetScript("OnClick", function()
		if InCombatLockdown() then
			return
		end
		HideUIPanel(frame)
		if K.ToggleConfigGUI then
			K.ToggleConfigGUI()
		end
	end)
	kkuiButton = button
	return button
end

-- After Blizzard lays the pool out, reproduce its exact spacing (so the visual
-- groups and the larger gaps between them are kept) and only slot our button in
-- just under Options, then regrow the frame to fit. Runs on every open and is
-- fully idempotent, so the height never creeps.
local function OnLayout(frame)
	if not frame.buttonPool then
		return
	end
	local button = EnsureButton(frame)

	if InCombatLockdown() then
		button:Hide()
		return
	end

	-- Gather the active pool buttons in their current top-to-bottom order.
	local order = {}
	for poolButton in frame.buttonPool:EnumerateActive() do
		order[#order + 1] = poolButton
	end
	if #order == 0 then
		button:Hide()
		return
	end
	tsort(order, function(a, b)
		return (a:GetTop() or 0) > (b:GetTop() or 0)
	end)

	-- Measure the gap Blizzard left above each button so we can reproduce it,
	-- including the bigger breaks between groups.
	local gapAbove = {}
	for i = 2, #order do
		local above, below = order[i - 1], order[i]
		local gap = (above:GetBottom() or 0) - (below:GetTop() or 0)
		gapAbove[below] = floor(gap + 0.5)
		if gapAbove[below] < 0 then
			gapAbove[below] = FALLBACK_GAP
		end
	end

	local width, height = order[1]:GetWidth(), order[1]:GetHeight()
	button:SetSize(width or 200, height or 34)
	gapAbove[button] = INSERT_GAP

	-- Match the pool buttons' font so our label sits at the same size as the rest.
	-- A Button swaps to its highlight font on mouseover, so all three states have to
	-- be set or the label shrinks back to the template default when hovered.
	local ref = order[1]
	if ref.GetNormalFontObject then
		local normal = ref:GetNormalFontObject()
		local highlight = ref:GetHighlightFontObject()
		local disabled = ref:GetDisabledFontObject()
		if normal then
			button:SetNormalFontObject(normal)
			button:SetHighlightFontObject(highlight or normal)
			button:SetDisabledFontObject(disabled or normal)
		end
	end

	-- Rebuild the order with our button right after Options (fall back to the end).
	local optionsText = _G.GAMEMENU_OPTIONS or "Options"
	local flow, inserted = {}, false
	for _, poolButton in ipairs(order) do
		flow[#flow + 1] = poolButton
		if not inserted and poolButton:GetText() == optionsText then
			flow[#flow + 1] = button
			inserted = true
		end
	end
	if not inserted then
		flow[#flow + 1] = button
	end
	button:Show()

	-- Keep the first button where Blizzard anchored it, then chain the rest below
	-- using each button's own measured gap, so the grouping is preserved.
	local topOffset = (frame:GetTop() or 0) - (flow[1]:GetTop() or 0)
	local totalGap = 0
	for i = 2, #flow do
		-- Open the tight rows up to at least MIN_GAP while keeping the larger breaks
		-- Blizzard leaves between the button groups.
		local gap = gapAbove[flow[i]] or FALLBACK_GAP
		if gap < MIN_GAP then
			gap = MIN_GAP
		end
		flow[i]:ClearAllPoints()
		flow[i]:SetPoint("TOP", flow[i - 1], "BOTTOM", 0, -gap)
		totalGap = totalGap + gap
	end

	frame:SetHeight(topOffset + #flow * (height or 34) + totalGap + BOTTOM_PAD)
end

function Module:OnEnable()
	if C.Skins and C.Skins.GameMenu == false then
		return
	end
	local frame = _G.GameMenuFrame
	if not frame then
		return
	end

	SkinFrame(frame)

	if frame.InitButtons then
		hooksecurefunc(frame, "InitButtons", function(self)
			if not self.buttonPool then
				return
			end
			for poolButton in self.buttonPool:EnumerateActive() do
				StyleMenuButton(poolButton)
			end
		end)
	end

	if frame.Layout then
		hooksecurefunc(frame, "Layout", OnLayout)
	end
end
