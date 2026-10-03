--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Skins/Details.lua
	Purpose:
		A native skin for the damage meter addon, so it matches the rest of the UI
		without a separate skin addon.

		Details has a public Details:InstallSkin(name, table), so this does not
		hook or touch Details at all. It registers a skin that appears in Details'
		own skin list, and nothing changes until a window picks it.

		The skin table is not written out by hand. A Details skin carries dozens of
		nested properties that change between Details versions, and a hand written
		copy goes stale on the next update. Instead this copies one of Details' own
		skins at install time and overrides only the look, so every key the
		installed version needs is already there.

		Details resolves bar textures and fonts by LibSharedMedia name and
		overwrites its own file fields from that name, so the overrides use names
		this addon registers with LibSharedMedia rather than file paths.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local Module = K:NewModule("DetailsSkin")

local _G = _G

local SKIN_NAME = "KkthnxUI"

-- Details' own skin used as the starting point. A clean one with no wallpaper art.
local BASE_SKIN = "Minimalistic v2"

-- The LibSharedMedia names the skin points at. The statusbar is already shared by
-- Core/Media.lua. The font gets its own name here, because the name it is shared
-- under elsewhere is the generic "Normal".
local MEDIA_NAME = "KkthnxUI"

local function RegisterFont()
	local LSM = K.LibSharedMedia
	if LSM then
		LSM:Register("font", MEDIA_NAME, K.GetFont(C.General and C.General.Font))
	end
end

local function Rgba(color, alpha)
	return { color[1], color[2], color[3], alpha or 1 }
end

local function BuildSkin(Details)
	local base = Details.skins and Details.skins[BASE_SKIN]
	if not base then
		return nil
	end

	local skin = K.DeepCopy(base)
	skin.author = "Kkthnx"
	skin.version = K.Version
	skin.site = "https://github.com/Kkthnx-Wow/KkthnxUI"
	skin.desc = L["Matches the KkthnxUI palette: a dark panel, class coloured bars, and our bar texture and font."]

	-- Our skin follows our palette and our addon, so it is rebuilt each session and
	-- never cached into Details' saved data.
	skin.no_cache = true
	skin.is_cached_skin = nil
	skin.skin_options = nil

	local colors = K.Colors
	local props = skin.instance_cprops or {}
	skin.instance_cprops = props

	props.skin = SKIN_NAME

	-- Window body: our panel colour, mostly opaque, no sidebars or status bar.
	props.bg_r, props.bg_g, props.bg_b = colors.voidDark[1], colors.voidDark[2], colors.voidDark[3]
	props.bg_alpha = 0.9
	props.color = { 1, 1, 1, 1 }
	props.show_sidebars = false
	props.show_statusbar = false
	if type(props.wallpaper) == "table" then
		props.wallpaper.enabled = false
	end

	-- Bars: our texture, class coloured, a dark track behind them.
	local row = props.row_info or {}
	props.row_info = row
	row.texture = MEDIA_NAME
	row.texture_background = MEDIA_NAME
	row.texture_class_colors = true
	row.texture_background_class_color = false
	row.fixed_texture_background_color = Rgba(colors.voidDark, 0.55)
	row.height = 18
	row.space = row.space or {}
	row.space.between = 2

	-- Bar text: our font, off white, outlined so it holds up on any class colour.
	row.font_face = MEDIA_NAME
	row.font_size = 12
	row.textL_class_colors = false
	row.textR_class_colors = false
	row.fixed_text_color = Rgba(colors.offWhite)
	row.textL_outline = true
	row.textR_outline = true

	-- Bars sit flush. The border art for a bar lives in a Details own media set.
	if type(row.backdrop) == "table" then
		row.backdrop.enabled = false
	end

	-- Title text uses the accent.
	local title = props.attribute_text or {}
	props.attribute_text = title
	title.enabled = true
	title.text_face = MEDIA_NAME
	title.text_size = 12
	title.text_color = Rgba(colors.accent)
	title.shadow = true

	if type(skin.micro_frames) == "table" then
		skin.micro_frames.font = MEDIA_NAME
		skin.micro_frames.color = Rgba(colors.offWhite, 0.8)
	end

	return skin
end

local function Install()
	local Details = _G.Details
	if not (Details and Details.InstallSkin) then
		return false
	end

	RegisterFont()

	local skin = BuildSkin(Details)
	if not skin then
		return false
	end
	return Details:InstallSkin(SKIN_NAME, skin)
end

-- Put the skin on every Details window. A one click version of picking it in each
-- window's options, offered from our own config. Returns how many were changed.
function Module:ApplyToAll()
	local Details = _G.Details
	if not (Details and Details.GetNumInstances) then
		return 0
	end
	if not (Details.skins and Details.skins[SKIN_NAME]) then
		Install()
	end

	local applied = 0
	for id = 1, Details:GetNumInstances() do
		local instance = Details:GetInstance(id)
		if instance and instance:IsEnabled() then
			instance:ChangeSkin(SKIN_NAME)
			applied = applied + 1
		end
	end
	return applied
end

function Module:ADDON_LOADED(_, addon)
	if addon == "Details" then
		self:UnregisterEvent("ADDON_LOADED")
		Install()
	end
end

function Module:OnEnable()
	if not C.Skins.Details then
		return
	end

	-- Details is a separate addon and may load before or after this one. Take it
	-- now if it is already there, otherwise wait for it.
	if _G.Details and _G.Details.InstallSkin then
		Install()
	else
		self:RegisterEvent("ADDON_LOADED", "ADDON_LOADED")
	end
end
