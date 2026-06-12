--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Shared GUI foundation -- the single source of truth for config UI
--   styling. Owns the color theme (K.GUITheme), layout metrics (K.GUILayout),
--   and the widget factory (K.WidgetFactory) used by GUI/ExtraGUI/ProfileGUI.
-- - Design: Loaded after Functions.lua and before any GUI consumer, so every
--   config window reads the same palette and dimensions instead of its own copy.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local CreateFrame = CreateFrame

-- ---------------------------------------------------------------------------
-- UNIFIED WIDGET FACTORY
-- ---------------------------------------------------------------------------

-- NOTE: Centralized UI toolkit for consistent styling across all GUI modules.
K.WidgetFactory = K.WidgetFactory or {}

-- ---------------------------------------------------------------------------
-- GUI THEME (SINGLE SOURCE OF TRUTH)
-- ---------------------------------------------------------------------------

-- REASON: Before this, GUI.lua / ExtraGUI.lua / ProfileGUI.lua each kept their
-- own copy-pasted palette tables. They drifted (Accent was full strength in one
-- file, dimmed in another) and "uniform" was a lie. One table, one truth now.
-- WARNING: These tables are SHARED by reference. Do NOT mutate them per-widget
-- (no theme.Accent[1] = ... at a call site); read-only consumption only.
-- NOTE: AccentDim is the intentional 70% variant used by the main config + the
-- profile manager; ExtraGUI deliberately uses full Accent. Keep both.
K.GUITheme = K.GUITheme or {
	Accent = { K.r, K.g, K.b },
	AccentDim = { K.r * 0.7, K.g * 0.7, K.b * 0.7 },
	Text = { 0.9, 0.9, 0.9, 1 },
	WidgetBg = { 0.12, 0.12, 0.12, 0.8 },
	Sidebar = { 0.05, 0.05, 0.05, 0.95 },
	Selected = { 0.15, 0.15, 0.15, 0.9 },
	ButtonHover = { 0.18, 0.18, 0.18, 1 },
	Success = { 0.3, 0.9, 0.3 },
	Error = { 0.9, 0.3, 0.3 },
	Warning = { 0.9, 0.7, 0.2 },
	-- Text emphasis tiers (were hardcoded as raw 0.8/0.7/0.5 grays across the GUIs).
	Header = { 0.8, 0.8, 0.8 }, -- section labels ("Character Information:")
	Muted = { 0.7, 0.7, 0.7 }, -- secondary text (timestamps, "Available")
	Hint = { 0.5, 0.5, 0.5 }, -- low-priority hints
	-- Faction tints (were hardcoded in ProfileGUI's detail panel).
	FactionAlliance = { 0.2, 0.5, 1 },
	FactionHorde = { 1, 0.2, 0.2 },
}

-- ---------------------------------------------------------------------------
-- GUI LAYOUT METRICS (SHARED DIMENSIONS)
-- ---------------------------------------------------------------------------

-- REASON: ExtraGUI's header literally said "derived from the main GUI to ensure
-- visual consistency" and then hardcoded 880/640 anyway. That's not derivation,
-- that's a copy waiting to drift. These are the dims that are genuinely shared.
-- NOTE: panel-specific widths (e.g. the profile manager's narrower 560) stay
-- local to their file on purpose -- only the common metrics live here.
K.GUILayout = K.GUILayout or {
	PanelWidth = 880,
	PanelHeight = 640,
	Spacing = 8,
	HeaderHeight = 40,
	RowHeight = 28,
}

-- REASON: Creates a colored background texture with default or custom alpha.
function K.WidgetFactory.CreateBackdrop(parent, r, g, b, a)
	local bg = parent:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(C["Media"].Textures.White8x8Texture)
	bg:SetVertexColor(r or 0.05, g or 0.05, b or 0.05, a or 0.9)
	return bg
end

-- REASON: Creates a styled button with hover effects and consistent theme-aware coloring.
-- PERF: Hoist theme tables into file-scope locals so the per-frame OnEnter/OnLeave
-- scripts hit an upvalue instead of a K.GUITheme hash lookup every mouseover.
local ACCENT_COLOR = K.GUITheme.Accent
local TEXT_COLOR = K.GUITheme.Text

function K.WidgetFactory.CreateButton(parent, text, width, height, onClick)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(width or 120, height or 28)

	local buttonBg = button:CreateTexture(nil, "BACKGROUND")
	buttonBg:SetAllPoints()
	buttonBg:SetTexture(C["Media"].Textures.White8x8Texture)
	buttonBg:SetVertexColor(0.15, 0.15, 0.15, 1)
	button.KKUI_Background = buttonBg

	local buttonBorder = button:CreateTexture(nil, "BORDER")
	buttonBorder:SetPoint("TOPLEFT", -1, 1)
	buttonBorder:SetPoint("BOTTOMRIGHT", 1, -1)
	buttonBorder:SetTexture(C["Media"].Textures.White8x8Texture)
	buttonBorder:SetVertexColor(0.3, 0.3, 0.3, 0.8)
	button.KKUI_Border = buttonBorder

	button:SetScript("OnEnter", function(self)
		self.KKUI_Background:SetVertexColor(ACCENT_COLOR[1] * 0.8, ACCENT_COLOR[2] * 0.8, ACCENT_COLOR[3] * 0.8, 1)
		self.KKUI_Border:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		if self.Text then
			self.Text:SetTextColor(1, 1, 1, 1)
		end
	end)

	button:SetScript("OnLeave", function(self)
		self.KKUI_Background:SetVertexColor(0.15, 0.15, 0.15, 1)
		self.KKUI_Border:SetVertexColor(0.3, 0.3, 0.3, 0.8)
		if self.Text then
			self.Text:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		end
	end)

	button:SetScript("OnMouseDown", function(self)
		self.KKUI_Background:SetVertexColor(ACCENT_COLOR[1] * 0.6, ACCENT_COLOR[2] * 0.6, ACCENT_COLOR[3] * 0.6, 1)
	end)

	button:SetScript("OnMouseUp", function(self)
		if self:IsMouseOver() then
			self.KKUI_Background:SetVertexColor(ACCENT_COLOR[1] * 0.8, ACCENT_COLOR[2] * 0.8, ACCENT_COLOR[3] * 0.8, 1)
		else
			self.KKUI_Background:SetVertexColor(0.15, 0.15, 0.15, 1)
		end
	end)

	button.Text = button:CreateFontString(nil, "OVERLAY")
	button.Text:SetFontObject(K.UIFont)
	button.Text:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	button.Text:SetText(text)
	button.Text:SetPoint("CENTER")

	if onClick then
		button:SetScript("OnClick", onClick)
	end

	return button
end
