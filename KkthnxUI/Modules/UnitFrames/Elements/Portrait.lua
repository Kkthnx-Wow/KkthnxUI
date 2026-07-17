--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Shared portrait factory for unit frames (Ellesmere CreatePortrait patterns).
-- - Design: Keeps KKUI layout (detached left/right, overlay, 3D) in one place.
-- - Events: N/A — wired via oUF Portrait.Override in Core.lua.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

local CreateFrame = _G.CreateFrame

function Module.GetPortraitStyle()
	return C["Unitframe"].PortraitStyle
end

function Module.IsPortraitEnabled(style)
	return (style or C["Unitframe"].PortraitStyle) ~= 0
end

function Module.IsDetachedPortrait(style)
	local portraitStyle = style or C["Unitframe"].PortraitStyle
	return portraitStyle ~= 0 and portraitStyle ~= 4
end

function Module.IsOverlayPortrait(style)
	return (style or C["Unitframe"].PortraitStyle) == 4
end

function Module.IsClassPortraitStyle(style)
	local portraitStyle = style or C["Unitframe"].PortraitStyle
	return portraitStyle == 2 or portraitStyle == 3
end

-- REASON: Indicator anchoring (raid target, resurrect, target glow) uses portrait or health.
function Module.GetPortraitAnchor(frame, style)
	if Module.IsDetachedPortrait(style) and frame.Portrait then
		return frame.Portrait
	end
	return frame.Health
end

local function getPortraitSize(health, power, extra)
	local powerHeight = power and power:GetHeight() or 0
	return health:GetHeight() + powerHeight + (extra or 6)
end

-- REASON: Central portrait builder — side "left" (player/party/pet) or "right" (target/etc).
function Module:CreateUnitPortrait(frame, opts)
	opts = opts or {}
	local portraitStyle = opts.style or C["Unitframe"].PortraitStyle

	-- SECRET (12.0): SecureHealth/SecurePower installs the secret-safe UpdateColor
	-- override (HealthColorOverride/PowerColorOverride in Core.lua). Every unit style
	-- except Raid/SimpleParty/MainTank (which build no portrait and call SecureHealth
	-- directly) relies on this function to install it via the SecurePortrait chain
	-- below. That chain never ran when portraits were disabled (PortraitStyle == 0),
	-- silently leaving Player/Target/Focus/Pet/FocusTarget/TargetOfTarget/Boss/Arena
	-- frames on oUF's stock UpdateColor, which compares UnitIsPlayer/UnitReaction
	-- directly and can error on secret values in combat/instances. Call it
	-- unconditionally, before the early returns, so it always runs.
	Module:SecureHealth(frame)

	if portraitStyle == 0 then
		return nil
	end

	local health = frame.Health
	if not health then
		return nil
	end

	local power = frame.Power
	local side = opts.side or "right"
	local size = getPortraitSize(health, power, opts.sizeExtra)
	local anchorSelf, anchorFrame, anchorPoint, xOff, yOff

	if side == "left" then
		anchorSelf, anchorFrame, anchorPoint, xOff, yOff = "TOPRIGHT", frame, "TOPLEFT", -6, 0
	else
		anchorSelf, anchorFrame, anchorPoint, xOff, yOff = "TOPLEFT", frame, "TOPRIGHT", 6, 0
	end

	if portraitStyle == 4 then
		frame.Portrait = CreateFrame("PlayerModel", opts.modelName, frame)
		frame.Portrait:SetFrameStrata(frame:GetFrameStrata())
		frame.Portrait:SetPoint("TOPLEFT", health, "TOPLEFT", 1, -1)
		frame.Portrait:SetPoint("BOTTOMRIGHT", health, "BOTTOMRIGHT", -1, 1)
		frame.Portrait:SetAlpha(opts.overlayAlpha or 0.6)
	elseif portraitStyle == 5 then
		frame.Portrait = CreateFrame("PlayerModel", opts.modelName, health)
		frame.Portrait:SetFrameStrata(frame:GetFrameStrata())
		frame.Portrait:SetSize(size, size)
		frame.Portrait:SetPoint(anchorSelf, anchorFrame, anchorPoint, xOff, yOff)
		frame.Portrait:CreateBorder()
		Module:ApplyPortraitAlphaFix(frame)
	else
		frame.Portrait = health:CreateTexture(nil, "BACKGROUND", nil, 1)
		frame.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		frame.Portrait:SetSize(size, size)
		frame.Portrait:SetPoint(anchorSelf, anchorFrame, anchorPoint, xOff, yOff)

		frame.Portrait.Border = CreateFrame("Frame", nil, frame)
		frame.Portrait.Border:SetAllPoints(frame.Portrait)
		frame.Portrait.Border:CreateBorder()

		if Module.IsClassPortraitStyle(portraitStyle) then
			frame.Portrait.PostUpdate = Module.UpdateClassPortraits
		end
	end

	Module:SecurePortrait(frame)
	return frame.Portrait
end

-- REASON: Name tag format differs when level sits on detached portrait vs on the bar.
function Module:TagUnitName(frame, style, opts)
	opts = opts or {}
	style = style or C["Unitframe"].PortraitStyle
	local prefix = opts.prefix or ""
	local useClassColor = opts.classColor ~= false and C["Unitframe"].HealthbarColor ~= 1
	local nameTag = useClassColor and "[color][name]" or "[name]"
	local levelTag = opts.levelTag or "[fulllevel]"
	local suffix = opts.suffix
	if suffix == nil then
		suffix = "[afkdnd]"
	end

	if style == 0 or style == 4 then
		local tag = prefix .. nameTag
		if levelTag and levelTag ~= "" then
			tag = tag .. " " .. levelTag
		end
		if suffix and suffix ~= "" then
			tag = tag .. suffix
		end
		frame:Tag(frame.Name, tag)
	else
		frame:Tag(frame.Name, prefix .. nameTag .. (suffix or ""))
	end
end

-- REASON: Boss/arena/party show level above detached portrait; pet/ToT below.
function Module:CreatePortraitLevelTag(frame, style, opts)
	opts = opts or {}
	style = style or C["Unitframe"].PortraitStyle
	local show = Module.IsDetachedPortrait(style)
	if opts.show ~= nil then
		show = opts.show
	end

	local anchor = Module.GetPortraitAnchor(frame, style)
	return Module:CreateLevelTagString(frame, anchor, {
		tag = opts.tag or "[nplevel]",
		layout = opts.layout or "above",
		show = show,
	})
end
