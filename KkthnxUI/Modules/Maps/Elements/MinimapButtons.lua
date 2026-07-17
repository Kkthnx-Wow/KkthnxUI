--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Shared minimap addon-button helpers (junk texture filter, labels).
-- - Design: Strip junk textures from collected minimap buttons.
-- - Events: N/A
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]
local Module = K:GetModule("Minimap")

local ipairs = _G.ipairs
local pairs = _G.pairs
local select = _G.select
local type = _G.type
local string_find = _G.string.find
local string_gsub = _G.string.gsub

-- REASON: Decorative Blizzard minimap button chrome — not the addon icon itself.
local MINIMAP_BTN_JUNK = {
	[136430] = true, -- MiniMap-TrackingBorder
	[136467] = true, -- UI-Minimap-Background
	[136477] = true, -- UI-Minimap-ZoomButton-Highlight (some LibDBIcon buttons)
}

local MINIMAP_BTN_JUNK_PATH = {
	["Interface\\Minimap\\MiniMap%-TrackingBorder"] = true,
	["Interface\\Minimap\\UI%-Minimap%-Background"] = true,
	["Interface\\Minimap\\UI%-Minimap%-ZoomButton%-Highlight"] = true,
	["Interface\\CharacterFrame"] = true,
	["Interface\\Minimap"] = true,
}

-- Weak table: per-button snapshot for optional restore (flyout / recycle bin).
local buttonDecorationState = setmetatable({}, { __mode = "k" })

function Module:IsJunkMinimapTexture(region)
	if not region or not region.IsObjectType or not region:IsObjectType("Texture") then
		return false
	end

	local texID = region.GetTextureFileID and region:GetTextureFileID()
	if texID and MINIMAP_BTN_JUNK[texID] then
		return true
	end

	local texPath = region:GetTexture()
	if texPath and type(texPath) == "string" then
		for pattern in pairs(MINIMAP_BTN_JUNK_PATH) do
			if string_find(texPath, pattern) then
				return true
			end
		end
	end

	return false
end

-- REASON: Hide tracking borders / minimap chrome on collected addon buttons.
function Module:StripMinimapButtonJunk(btn)
	if not btn then
		return
	end

	local saved = buttonDecorationState[btn]
	if not saved then
		saved = { junk = {} }
		for _, region in ipairs({ btn:GetRegions() }) do
			if Module:IsJunkMinimapTexture(region) then
				saved.junk[#saved.junk + 1] = {
					region = region,
					alpha = region:GetAlpha(),
					shown = region:IsShown(),
				}
			end
		end

		local hl = btn.GetHighlightTexture and btn:GetHighlightTexture()
		if hl and Module:IsJunkMinimapTexture(hl) then
			saved.junk[#saved.junk + 1] = {
				region = hl,
				alpha = hl:GetAlpha(),
				shown = hl:IsShown(),
			}
		end

		buttonDecorationState[btn] = saved
	end

	for _, info in ipairs(saved.junk) do
		info.region:SetTexture(nil)
		info.region:SetAlpha(0)
		info.region:Hide()
	end
end

function Module:RestoreMinimapButtonJunk(btn)
	local saved = buttonDecorationState[btn]
	if not saved then
		return
	end

	for _, info in ipairs(saved.junk) do
		info.region:SetAlpha(info.alpha)
		if info.shown then
			info.region:Show()
		end
	end

	buttonDecorationState[btn] = nil
end

-- REASON: Human-readable label for recycle-bin tooltips / sorting.
function Module:GetMinimapButtonLabel(btn)
	local name = btn and btn.GetName and btn:GetName() or ""
	name = string_gsub(name, "^LibDBIcon10_", "")
	name = string_gsub(name, "^Lib_GPI_Minimap_", "")
	name = string_gsub(name, "MinimapButton$", "")
	name = string_gsub(name, "_MinimapButton$", "")
	return name
end

-- REASON: Normalize a collected minimap button icon to KKUI square texcoords.
function Module:SkinMinimapAddonButton(btn, opts)
	opts = opts or {}
	if not btn then
		return
	end

	local name = btn.GetName and btn:GetName() or ""
	Module:StripMinimapButtonJunk(btn)

	for i = 1, btn:GetNumRegions() do
		local region = select(i, btn:GetRegions())
		if region and region.IsObjectType and region:IsObjectType("Texture") then
			if Module:IsJunkMinimapTexture(region) then
				region:SetTexture(nil)
				region:Hide()
			else
				if not region.__ignored then
					region:ClearAllPoints()
					region:SetAllPoints()
				end
				if not opts.skipTexCoord and not opts.goodLooking then
					region:SetTexCoord(unpack(K.TexCoords))
				end
			end
		end
	end

	local size = opts.size or 22
	btn:SetSize(size, size)
end
