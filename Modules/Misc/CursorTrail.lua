--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Misc/CursorTrail.lua
	Purpose:
		A trail of fading dots behind the mouse pointer, so the cursor stays
		findable in a busy fight.

		Each dot eases toward the one ahead of it, so the tail flows and bends with
		the stroke. The chase is scaled by frame time, which keeps it moving at the
		same speed whatever the framerate.

		Cursor position raises no event, so following it needs a per frame sample.
		The tail fades out once the pointer sits still, which also covers
		mouselook, where GetCursorPosition stops changing. Off by default, and
		nothing is created until it is switched on.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:NewModule("CursorTrail")

local CreateFrame = CreateFrame
local GetCursorPosition = GetCursorPosition
local InCombatLockdown = InCombatLockdown

-- A soft round glow. Our own Glow texture is a vertical gradient strip meant for
-- status bars, so it drew the tail as bars rather than dots.
local DOT = [[Interface\GLUES\Models\UI_Draenei\GenericGlow64]]

-- Seconds the pointer must sit still before the tail starts to go, then how long
-- it takes to go. Short enough not to linger, long enough that a pause while
-- reading a tooltip does not flicker it.
local IDLE_DELAY = 0.35
local FADE_TIME = 0.4

local driver, holder, segments
local count, smoothing, opacity
local lastX, lastY, idle, fade

-- Live position of each dot. Written in place so the per frame path never
-- allocates.
local trail = {}

local function OnUpdate(_, elapsed)
	local scale = UIParent:GetEffectiveScale()
	local x, y = GetCursorPosition()
	x, y = x / scale, y / scale

	if x == lastX and y == lastY then
		idle = idle + elapsed
		if fade == 0 then
			return
		end
		if idle > IDLE_DELAY then
			fade = fade - elapsed / FADE_TIME
			if fade <= 0 then
				fade = 0
				holder:Hide()
				return
			end
			holder:SetAlpha(fade * opacity)
		end
		return
	end

	lastX, lastY = x, y
	idle = 0
	if fade < 1 then
		fade = 1
		holder:SetAlpha(opacity)
		holder:Show()
	end

	-- Each dot eases toward the one in front rather than snapping to a fixed gap
	-- behind it. Chasing gives a tail that flows and bends with the stroke, where
	-- a hard distance clamp reads as a rigid string of beads.
	--
	-- The step is raised to the frame time so the chase covers the same ground per
	-- second at any framerate. A plain per frame lerp would whip at 200 fps and
	-- crawl at 30.
	local step = 1 - (1 - smoothing) ^ (elapsed * 60)
	local leadX, leadY = x, y
	for i = 1, count do
		local dot = trail[i]
		dot[1] = dot[1] + (leadX - dot[1]) * step
		dot[2] = dot[2] + (leadY - dot[2]) * step
		segments[i]:SetPoint("CENTER", UIParent, "BOTTOMLEFT", dot[1], dot[2])
		leadX, leadY = dot[1], dot[2]
	end
end

local function Start()
	if driver:GetScript("OnUpdate") then
		return
	end
	-- Reset the tail onto the pointer so it does not snap in from wherever it was
	-- left when combat ended.
	local scale = UIParent:GetEffectiveScale()
	local x, y = GetCursorPosition()
	x, y = x / scale, y / scale
	for i = 1, count do
		trail[i][1], trail[i][2] = x, y
		segments[i]:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
	end
	lastX, lastY, idle, fade = x, y, 0, 1
	holder:SetAlpha(opacity)
	holder:Show()
	driver:SetScript("OnUpdate", OnUpdate)
end

local function Stop()
	driver:SetScript("OnUpdate", nil)
	holder:Hide()
	fade = 0
end

function Module:PLAYER_REGEN_DISABLED()
	Start()
end

function Module:PLAYER_REGEN_ENABLED()
	Stop()
end

function Module:OnEnable()
	if not C.Misc.CursorTrail then
		return
	end

	count = C.Misc.CursorTrailLength
	smoothing = C.Misc.CursorTrailSmoothing
	opacity = C.Misc.CursorTrailAlpha

	local size = C.Misc.CursorTrailSize
	local r, g, b
	if C.Misc.CursorTrailClassColor then
		r, g, b = K.ClassColor.r, K.ClassColor.g, K.ClassColor.b
	else
		local custom = C.Misc.CursorTrailColor
		r, g, b = custom[1], custom[2], custom[3]
	end

	driver = CreateFrame("Frame")
	holder = CreateFrame("Frame", "KKUI_CursorTrail", UIParent)
	holder:SetFrameStrata("TOOLTIP")
	holder:Hide()

	segments = {}
	for i = 1, count do
		local seg = holder:CreateTexture(nil, "OVERLAY")
		seg:SetTexture(DOT)
		-- Taper size and alpha toward the tail so it reads as a trail, not a chain.
		-- Alpha falls on a curve rather than a straight line, which keeps the head
		-- bright and lets the tail disappear early instead of ending in a hard stop.
		local along = (i - 1) / count
		local scale = 1 - along * 0.65
		seg:SetSize(size * scale, size * scale)
		seg:SetVertexColor(r, g, b)
		seg:SetBlendMode("ADD")
		seg:SetAlpha((1 - along) ^ 1.5)
		segments[i] = seg
		trail[i] = { 0, 0 }
	end

	if C.Misc.CursorTrailCombat then
		-- Nothing runs out of combat, not even the sample.
		self:RegisterEvent("PLAYER_REGEN_DISABLED", "PLAYER_REGEN_DISABLED")
		self:RegisterEvent("PLAYER_REGEN_ENABLED", "PLAYER_REGEN_ENABLED")
		if InCombatLockdown() then
			Start()
		end
	else
		Start()
	end
end
