--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Shared unit-frame font strings (bar values, names, level lines).
-- - Design: Shared unit-frame font strings (bar values, names, level lines).
-- - Events: N/A — tags refresh via oUF.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

local function getUIFontSize()
	return K.UIFontSize or 12
end

-- REASON: Stretch a font string between two anchors (names, level tags).
local function anchorStretched(fs, pointA, relativeA, relPointA, xA, yA, pointB, relativeB, relPointB, xB, yB)
	fs:SetPoint(pointA, relativeA, relPointA, xA, yA)
	fs:SetPoint(pointB, relativeB, relPointB, xB, yB)
end

-- REASON: Standard health/power value tag on a status bar.
function Module:CreateBarValueTag(frame, bar, tag, opts)
	opts = opts or {}
	local size = opts.size or 12
	local fs = K.CreateFontString(bar, size, "", "", false, opts.anchor or "CENTER", opts.x or 0, opts.y or 0)
	if opts.color then
		fs:SetTextColor(opts.color[1], opts.color[2], opts.color[3], opts.color[4] or 1)
	end
	frame:Tag(fs, tag)
	bar.Value = fs
	return fs
end

-- REASON: Unit name line — replaces raw CreateFontString + SetFontObject blocks.
-- Layouts: aboveHealth | aboveFrame | belowPower | aboveOverlay | custom (opts.points).
function Module:CreateUnitNameString(frame, opts)
	opts = opts or {}
	local parent = opts.parent or frame
	local size = opts.size or getUIFontSize()
	local fs = K.CreatePlainFS(parent, size, "", "OVERLAY")
	fs:SetWordWrap(opts.wordWrap == true)
	-- REASON: Centered names read more consistently against the centered health value
	-- text on the bar below; pass justifyH = "LEFT" explicitly for any layout that
	-- specifically needs left alignment.
	fs:SetJustifyH(opts.justifyH or "CENTER")
	if opts.width then
		fs:SetWidth(opts.width)
	end

	local layout = opts.layout or "aboveHealth"
	if layout == "aboveHealth" then
		local health = opts.relativeTo or frame.Health
		anchorStretched(fs, "BOTTOMLEFT", health, "TOPLEFT", opts.x or 0, opts.y or 4, "BOTTOMRIGHT", health, "TOPRIGHT", opts.xRight or 0, opts.y or 4)
	elseif layout == "aboveFrame" then
		anchorStretched(fs, "BOTTOMLEFT", frame, "TOPLEFT", opts.x or 3, opts.y or -15, "BOTTOMRIGHT", frame, "TOPRIGHT", opts.xRight or -3, opts.y or -15)
	elseif layout == "belowPower" then
		local power = opts.relativeTo or frame.Power
		anchorStretched(fs, "TOPLEFT", power, "BOTTOMLEFT", opts.x or 0, opts.y or -4, "TOPRIGHT", power, "BOTTOMRIGHT", opts.xRight or 0, opts.y or -4)
	elseif layout == "aboveOverlay" then
		local overlay = opts.relativeTo or frame.Overlay or frame
		anchorStretched(fs, "BOTTOMLEFT", overlay, "TOPLEFT", opts.x or 3, opts.y or -15, "BOTTOMRIGHT", overlay, "TOPRIGHT", opts.xRight or -3, opts.y or -15)
	elseif layout == "custom" and opts.points then
		for i = 1, #opts.points do
			local p = opts.points[i]
			fs:SetPoint(p[1], p[2], p[3], p[4], p[5])
		end
	end

	if opts.key then
		frame[opts.key] = fs
	else
		frame.Name = fs
	end
	return fs
end

-- REASON: Portrait level line (boss/arena/party/pet).
function Module:CreateLevelTagString(frame, anchor, opts)
	opts = opts or {}
	local size = opts.size or getUIFontSize()
	local fs = K.CreatePlainFS(frame, size, "", "OVERLAY")
	fs:SetJustifyH(opts.justifyH or "CENTER")

	local layout = opts.layout or "above"
	if layout == "centerAbove" then
		fs:SetPoint("TOP", anchor, 0, opts.y or 15)
	elseif layout == "above" then
		anchorStretched(fs, "BOTTOMLEFT", anchor, "TOPLEFT", 0, 4, "BOTTOMRIGHT", anchor, "TOPRIGHT", 0, 4)
	else
		anchorStretched(fs, "TOPLEFT", anchor, "BOTTOMLEFT", 0, -4, "TOPRIGHT", anchor, "BOTTOMRIGHT", 0, -4)
	end

	if opts.show == false then
		fs:Hide()
	elseif anchor == nil then
		fs:Hide()
	end

	frame:Tag(fs, opts.tag or "[nplevel]")
	frame.Level = fs
	return fs
end

-- REASON: oUF DebuffHighlight element texture — one factory for all unit styles.
function Module:CreateDebuffHighlight(frame, opts)
	opts = opts or {}
	if opts.enabled == false then
		return
	end

	local parent = opts.parent or frame.Health
	if not parent then
		return
	end

	local tex = parent:CreateTexture(nil, "OVERLAY")
	tex:SetAllPoints(parent)
	tex:SetTexture(C["Media"].Textures.White8x8Texture)
	tex:SetVertexColor(0, 0, 0, 0)
	tex:SetBlendMode("ADD")

	frame.DebuffHighlight = tex
	frame.DebuffHighlightAlpha = opts.alpha or 0.45
	frame.DebuffHighlightFilter = opts.filter ~= false
	return tex
end
