--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Misc/CursorTrail.lua
	Purpose:
		A short trail of fading dots behind the mouse pointer, so the cursor stays
		findable in a busy fight.

		Cursor position raises no event, so following it needs a per frame sample.
		An idle pointer costs two comparisons and returns, which also covers
		mouselook, where GetCursorPosition stops changing. Off by default, and
		nothing is created until it is switched on.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:NewModule("CursorTrail")

local CreateFrame = CreateFrame
local GetCursorPosition = GetCursorPosition

local driver, segments
local count, lastX, lastY

-- Ring of past cursor positions, written in place so the per frame path never
-- allocates. head is the index of the newest sample.
local history, head = {}, 0

local function Position(seg, index)
	local sample = history[(index % count) + 1]
	seg:SetPoint("CENTER", UIParent, "BOTTOMLEFT", sample[1], sample[2])
end

local function OnUpdate()
	local scale = UIParent:GetEffectiveScale()
	local x, y = GetCursorPosition()
	x, y = x / scale, y / scale

	if x == lastX and y == lastY then
		return
	end
	lastX, lastY = x, y

	head = head + 1
	local slot = history[(head % count) + 1]
	slot[1], slot[2] = x, y

	-- Newest sample sits on the pointer, each older one a step further back and
	-- more transparent.
	for i = 1, count do
		Position(segments[i], head - i + 1)
	end
end

function Module:OnEnable()
	if not C.Misc.CursorTrail then
		return
	end

	count = C.Misc.CursorTrailLength
	local size = C.Misc.CursorTrailSize
	local color = C.Misc.CursorTrailClassColor and K.ClassColor or nil
	local r, g, b
	if color then
		r, g, b = color.r, color.g, color.b
	else
		local custom = C.Misc.CursorTrailColor
		r, g, b = custom[1], custom[2], custom[3]
	end

	local x, y = GetCursorPosition()
	local scale = UIParent:GetEffectiveScale()
	x, y = x / scale, y / scale

	-- Seed every slot at the current pointer so the tail never starts stacked in
	-- the bottom left corner.
	for i = 1, count do
		history[i] = { x, y }
	end

	driver = CreateFrame("Frame", "KKUI_CursorTrail", UIParent)
	driver:SetFrameStrata("TOOLTIP")

	segments = {}
	for i = 1, count do
		local seg = driver:CreateTexture(nil, "OVERLAY")
		seg:SetTexture(C.Media.Textures.Glow)
		seg:SetSize(size, size)
		seg:SetVertexColor(r, g, b)
		seg:SetBlendMode("ADD")
		seg:SetAlpha(1 - (i - 1) / count)
		Position(seg, -i + 1)
		segments[i] = seg
	end

	driver:SetScript("OnUpdate", OnUpdate)
end
