--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Core/Skins.lua
	Purpose:
		Reusable skinning helpers so every widget in the addon shares one look.
		Each strips the Blizzard art from a standard template and applies our
		background plus border. Written defensively: missing regions are skipped
		so the same call works across game flavors.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

local _G = _G

-- Shared palette, built around the #5C8BCF steel-blue theme.
local accent = { 0.361, 0.545, 0.812 } -- #5C8BCF main accent
local gold = { 0.953, 0.690, 0.263 } -- #F3B043 warm gold
K.Colors = {
	accent = accent,
	gold = gold,
	silver = { 0.773, 0.835, 0.910 }, -- #C5D5E8
	voidDark = { 0.059, 0.075, 0.094 }, -- #0F1318 main backdrop
	panel = { 0.090, 0.114, 0.149 }, -- #171D26 inner panels
	borderSubtle = { 0.169, 0.212, 0.282 }, -- #2B3648
	borderFocus = { 0.259, 0.329, 0.439 }, -- #425470
	crimson = { 0.898, 0.325, 0.325 }, -- #E55353 alert
	jade = { 0.306, 0.741, 0.529 }, -- #4EBD87 success
	ember = { 0.902, 0.502, 0.235 }, -- #E6803C caution, the step between gold and crimson
}

-- Shared vertical gradient background, inset one pixel so our border stays clean.
-- Returns the texture so the caller can shift it on hover.
local function GradientBG(frame, r1, g1, b1, a1, r2, g2, b2, a2)
	local bg = frame:CreateTexture(nil, "BACKGROUND")
	bg:SetPoint("TOPLEFT", 1, -1)
	bg:SetPoint("BOTTOMRIGHT", -1, 1)
	bg:SetColorTexture(1, 1, 1)
	bg:SetGradient("VERTICAL", CreateColor(r1, g1, b1, a1), CreateColor(r2, g2, b2, a2))
	frame.KKUI_Background = bg
	return bg
end
K.GradientBG = GradientBG

-- Cooldown swipe. On Midnight the default radial swipe texture does not render, so
-- every cooldown frame we skin needs a real blank texture with our tint or it shows
-- no wipe at all, just the number. Colour defaults to a dark 80% swipe. Pass a
-- red-ish tint for loss-of-control cooldowns. Idempotent and safe to call once per
-- frame. Numbers stay Blizzard's native ones (the only ones that can read a secret
-- cooldown duration on Midnight), so this never touches SetHideCountdownNumbers.
local COOLDOWN_SWIPE_TEX = "Interface\\BUTTONS\\WHITE8X8"
function K.StyleCooldownSwipe(cooldown, r, g, b, a)
	if not (cooldown and cooldown.SetSwipeTexture) then
		return
	end
	cooldown:SetDrawSwipe(true)
	cooldown:SetSwipeTexture(COOLDOWN_SWIPE_TEX, r or 0, g or 0, b or 0, a or 0.8)
	cooldown:SetDrawEdge(false)
	if cooldown.SetUseCircularEdge then
		cooldown:SetUseCircularEdge(false)
	end
end

-- Panel backdrop: a subtle top-lit vertical gradient with a faint accent line at
-- the top edge, so large frames read with depth instead of a flat black slab.
-- Pair with K.CreateBorder. Returns the background texture.
function K.CreateGradientBackground(frame, alpha)
	local a = alpha or 0.95
	local bg = frame:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetColorTexture(1, 1, 1)
	bg:SetGradient("VERTICAL", CreateColor(0.05, 0.062, 0.08, a), CreateColor(0.09, 0.114, 0.149, a))
	frame.KKUI_Background = bg

	local top = frame:CreateTexture(nil, "BORDER")
	top:SetHeight(1)
	top:SetPoint("TOPLEFT", 1, -1)
	top:SetPoint("TOPRIGHT", -1, -1)
	top:SetColorTexture(accent[1], accent[2], accent[3], 0.18)
	return bg
end
local white = "Interface\\BUTTONS\\WHITE8X8"

-- ---------------------------------------------------------------------------
-- Button (UIPanelButtonTemplate and friends)
-- ---------------------------------------------------------------------------

-- Hide every existing texture region on a frame (state textures included).
local function StripTextures(frame)
	if frame.SetNormalTexture then
		frame:SetNormalTexture(0)
		frame:SetPushedTexture(0)
		frame:SetDisabledTexture(0)
	end
	if frame.SetHighlightTexture then
		frame:SetHighlightTexture(0)
	end
	for _, region in ipairs({ frame:GetRegions() }) do
		if region.GetObjectType and region:GetObjectType() == "Texture" then
			region:SetAlpha(0)
		end
	end
	if frame.NineSlice then
		frame.NineSlice:SetAlpha(0)
	end
end
K.StripTextures = StripTextures

-- emphasize: gold text + gold hover border, for important actions (Reload, etc.).
function K.SkinButton(button, emphasize)
	if button.__skinned then
		return button
	end
	button.__skinned = true

	StripTextures(button)

	local bg = GradientBG(button, 0.09, 0.114, 0.149, 0.9, 0.05, 0.065, 0.085, 0.9)
	K.CreateBorder(button)

	local restColor = emphasize and gold or { 1, 1, 1 }
	local hoverColor = emphasize and { 1, 0.92, 0.4 } or { 0.7, 0.85, 1 }
	local hoverBorder = emphasize and gold or accent

	local fs = button:GetFontString()
	if fs then
		fs:SetTextColor(restColor[1], restColor[2], restColor[3])
	end

	-- Hover: lift the fill toward the accent and light the border, so every control
	-- reacts the same and the hover reads at a glance.
	button:HookScript("OnEnter", function(self)
		bg:SetGradient("VERTICAL", CreateColor(0.22, 0.34, 0.52, 1), CreateColor(0.13, 0.20, 0.32, 1))
		if self.KKUI_Border then
			self.KKUI_Border:SetVertexColor(hoverBorder[1], hoverBorder[2], hoverBorder[3], 1)
		end
		if fs then
			fs:SetTextColor(hoverColor[1], hoverColor[2], hoverColor[3])
		end
	end)
	button:HookScript("OnLeave", function(self)
		bg:SetGradient("VERTICAL", CreateColor(0.09, 0.114, 0.149, 0.9), CreateColor(0.05, 0.065, 0.085, 0.9))
		if self.KKUI_Border then
			K.ResetBorderColor(self.KKUI_Border)
		end
		if fs then
			fs:SetTextColor(restColor[1], restColor[2], restColor[3])
		end
	end)
	return button
end

-- ---------------------------------------------------------------------------
-- Checkbox
-- ---------------------------------------------------------------------------

function K.SkinCheckBox(check)
	if check.__skinned then
		return check
	end
	check.__skinned = true

	check:SetSize(16, 16)

	if check.SetNormalTexture then
		check:SetNormalTexture(0)
		check:SetPushedTexture(0)
		check:SetDisabledTexture(0)
	end

	-- One flat fill, no two-tone gradient, so the box does not read as a panel
	-- nested inside the frame.
	K.CreateBackground(check, 0.09, 0.114, 0.149, 0.9)
	K.CreateBorder(check)

	-- Highlight fills the whole box so hover reads clearly.
	local hl = check:GetHighlightTexture()
	if hl then
		hl:SetColorTexture(accent[1], accent[2], accent[3], 0.25)
		hl:ClearAllPoints()
		hl:SetPoint("TOPLEFT", check, "TOPLEFT", 1, -1)
		hl:SetPoint("BOTTOMRIGHT", check, "BOTTOMRIGHT", -1, 1)
	end

	-- A single crisp green checkmark, centred and drawn a little larger than the
	-- box so it reads boldly and slightly overhangs the frame.
	local checked = check:GetCheckedTexture()
	if checked then
		checked:SetAtlas("common-icon-checkmark", true)
		checked:SetVertexColor(0.306, 0.741, 0.529, 1) -- #4EBD87 jade
		checked:SetDrawLayer("OVERLAY", 7)
		checked:ClearAllPoints()
		checked:SetPoint("CENTER", check, "CENTER", 2, 2)
		checked:SetSize(22, 22)
	end

	return check
end

-- ---------------------------------------------------------------------------
-- Close button (UIPanelCloseButton)
-- ---------------------------------------------------------------------------

function K.SkinCloseButton(button)
	if button.__skinned then
		return button
	end
	button.__skinned = true

	button:SetSize(22, 22)
	if button.SetNormalTexture then
		button:SetNormalTexture(0)
		button:SetPushedTexture(0)
		button:SetHighlightTexture(0)
		button:SetDisabledTexture(0)
	end

	-- Red gradient background so the close button reads as a distinct action.
	local bg = button:CreateTexture(nil, "BACKGROUND")
	bg:SetPoint("TOPLEFT", 1, -1)
	bg:SetPoint("BOTTOMRIGHT", -1, 1)
	bg:SetColorTexture(1, 1, 1)
	bg:SetGradient("VERTICAL", CreateColor(0.42, 0.12, 0.12, 0.95), CreateColor(0.68, 0.22, 0.22, 0.95))
	button.KKUI_Background = bg
	K.CreateBorder(button)

	-- Yellow X drawn from two rotated bars, so it stays crisp at any size.
	local function XBar(rotation)
		local t = button:CreateTexture(nil, "OVERLAY")
		t:SetColorTexture(0.953, 0.69, 0.263)
		t:SetSize(13, 2.5)
		t:SetPoint("CENTER")
		t:SetRotation(rotation)
		return t
	end
	local a = XBar(0.7854) -- 45 degrees
	local b = XBar(-0.7854)

	button:HookScript("OnEnter", function()
		bg:SetGradient("VERTICAL", CreateColor(0.60, 0.20, 0.20, 1), CreateColor(0.898, 0.325, 0.325, 1))
		a:SetColorTexture(1, 0.86, 0.4)
		b:SetColorTexture(1, 0.86, 0.4)
	end)
	button:HookScript("OnLeave", function()
		bg:SetGradient("VERTICAL", CreateColor(0.42, 0.12, 0.12, 0.95), CreateColor(0.68, 0.22, 0.22, 0.95))
		a:SetColorTexture(0.953, 0.69, 0.263)
		b:SetColorTexture(0.953, 0.69, 0.263)
	end)
	return button
end

-- ---------------------------------------------------------------------------
-- Slider
-- ---------------------------------------------------------------------------

function K.SkinSlider(slider)
	if slider.__skinned then
		return slider
	end
	slider.__skinned = true

	local thumb = slider:GetThumbTexture()

	-- Remove the default track art but leave the thumb alone.
	if slider.SetBackdrop then
		slider:SetBackdrop(nil)
	end
	for _, region in ipairs({ slider:GetRegions() }) do
		if region:GetObjectType() == "Texture" and region ~= thumb then
			region:SetAlpha(0)
		end
	end

	-- Thin track. It is a sibling of the slider (parented to the holder) sitting
	-- one frame level below, so the slider's thumb still draws above it. A track
	-- parented to the slider would be a child and would cover the thumb.
	local track = CreateFrame("Frame", nil, slider:GetParent())
	track:SetFrameLevel(math.max(0, slider:GetFrameLevel() - 1))
	track:SetPoint("LEFT", slider, "LEFT", 0, 0)
	track:SetPoint("RIGHT", slider, "RIGHT", 0, 0)
	track:SetHeight(6)
	K.CreateBackground(track, 0.08, 0.08, 0.08, 0.95)
	K.CreateBorder(track)
	slider.KKUI_Track = track

	-- Handle: a crisp accent bar with its own thin border, brighter on hover.
	if thumb then
		thumb:SetTexture(white)
		thumb:SetVertexColor(accent[1], accent[2], accent[3], 1)
		thumb:SetSize(12, 20)

		local edge = slider:CreateTexture(nil, "OVERLAY")
		edge:SetColorTexture(0, 0, 0, 0.8)
		edge:SetDrawLayer("OVERLAY", 1)
		edge:SetPoint("TOPLEFT", thumb, "TOPLEFT", -1, 1)
		edge:SetPoint("BOTTOMRIGHT", thumb, "BOTTOMRIGHT", 1, -1)
		edge:SetColorTexture(accent[1] * 0.5, accent[2] * 0.5, accent[3] * 0.5, 1)
		-- Keep the coloured thumb on top of its edge.
		thumb:SetDrawLayer("OVERLAY", 2)

		slider:HookScript("OnEnter", function()
			thumb:SetVertexColor(accent[1] + 0.15, accent[2] + 0.1, accent[3], 1)
		end)
		slider:HookScript("OnLeave", function()
			thumb:SetVertexColor(accent[1], accent[2], accent[3], 1)
		end)
	end
	return slider
end

-- ---------------------------------------------------------------------------
-- Edit box
-- ---------------------------------------------------------------------------

function K.SkinEditBox(edit)
	if edit.__skinned then
		return edit
	end
	edit.__skinned = true

	-- InputBoxTemplate art lives in named regions (when named) or the region
	-- list (when not). Hide both ways so it works either way.
	local name = edit:GetName()
	for _, suffix in ipairs({ "Left", "Middle", "Right" }) do
		local region = name and _G[name .. suffix]
		if region then
			region:SetAlpha(0)
		end
	end
	for _, region in ipairs({ edit:GetRegions() }) do
		if region.GetObjectType and region:GetObjectType() == "Texture" then
			region:SetAlpha(0)
		end
	end

	K.CreateBackground(edit, 0.1, 0.1, 0.1, 0.85)
	K.CreateBorder(edit)
	return edit
end

-- ---------------------------------------------------------------------------
-- Scroll bar (UIPanelScrollFrameTemplate's child scroll bar)
-- ---------------------------------------------------------------------------

function K.SkinScrollBar(bar)
	if not bar or bar.__skinned then
		return bar
	end
	bar.__skinned = true

	local name = bar:GetName()
	local up = bar.ScrollUpButton or (name and _G[name .. "ScrollUpButton"])
	local down = bar.ScrollDownButton or (name and _G[name .. "ScrollDownButton"])
	local thumb = bar.ThumbTexture
	if not thumb and bar.GetThumbTexture then
		thumb = bar:GetThumbTexture()
	end

	for _, arrow in ipairs({ up, down }) do
		if arrow then
			for _, region in ipairs({ arrow:GetRegions() }) do
				if region:GetObjectType() == "Texture" then
					region:SetTexture(nil)
				end
			end
			arrow:SetWidth(1)
			arrow:SetHeight(1)
		end
	end

	-- Track background.
	if not bar.KKUI_Background then
		K.CreateBackground(bar, 0.1, 0.1, 0.1, 0.6)
	end

	if thumb then
		thumb:SetTexture(white)
		thumb:SetVertexColor(accent[1], accent[2], accent[3], 0.8)
		-- A narrower thumb leaves a small gap to the track on both sides so the
		-- bar reads as thumb-inside-track rather than a solid filled column.
		thumb:SetWidth(6)
	end
	return bar
end
