--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Misc/CursorTrail.lua
	Purpose:
		A soft glowing trail behind the mouse pointer, so the cursor stays
		findable in a busy fight.

		Dots are dropped along the path and left where they land, then aged out
		over a lifetime. Dragging dots along behind the pointer instead makes a
		snake that is always catching up, which reads as lag no matter how the
		easing is tuned.

		Spacing is measured from the last dropped dot rather than the last frame,
		or a slow drag never travels far enough in one frame to place anything. A
		fast flick is filled in with intermediate dots so the line has no gaps.

		SetPoint runs once per dot when it is placed. The per frame pass only
		touches size, colour and alpha, and it stops entirely once the pointer is
		still and the last dot has faded. Off by default.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:NewModule("CursorTrail")

local CreateFrame = CreateFrame
local GetCursorPosition = GetCursorPosition
local GetTime = GetTime
local UnitAffectingCombat = UnitAffectingCombat
local floor, sqrt, min, max = math.floor, math.sqrt, math.min, math.max

-- Shapes the tail can be drawn with, all stock game art. Our own Glow texture is
-- a vertical gradient strip meant for status bars, so it is not one of them.
local SHAPES = {
	Glow = [[Interface\GLUES\Models\UI_Draenei\GenericGlow64]],
	Spark = [[Interface\Cooldown\star4]],
	Ping = [[Interface\Cooldown\ping4]],
	Streak = [[Interface\CastingBar\UI-CastingBar-Spark]],
}

-- A frame longer than this means a loading screen or an alt-tab, so the samples
-- either side of it are not part of one stroke.
local HITCH = 0.25
-- Pixels of movement that count as the pointer having moved at all.
local NUDGE = 0.5
-- How often the idle watcher looks for that movement.
local WATCH = 0.05
-- Ceiling on gap filling, so one enormous jump cannot place hundreds of dots.
local MAX_FILL = 12

local holder, watcher, ticker
local pool, born = {}, {}
local capacity, live, head = 0, 0, 0
local lastX, lastY, emitX, emitY, lastTick
local turning, inCinematic, asleep = 0, false, true

-- Settings read once on enable, so the per frame pass never walks the config.
local size, spacing, lifetime, opacity, shrink, combatOnly, hideTurning

local function Suppressed()
	if inCinematic then
		return true
	end
	if hideTurning and turning > 0 then
		return true
	end
	if combatOnly and not UnitAffectingCombat("player") then
		return true
	end
	return false
end

local function Clear()
	live, head = 0, 0
	lastX, lastY, emitX, emitY = nil, nil, nil, nil
	for i = 1, capacity do
		pool[i]:Hide()
	end
	holder:Hide()
end

-- Drop one dot and anchor it. Nothing moves it again, it only fades.
local function Emit(x, y, now)
	head = head % capacity + 1
	born[head] = now
	if live < capacity then
		live = live + 1
	end
	local dot = pool[head]
	dot:ClearAllPoints()
	dot:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
end

-- Age every live dot. Returns whether any of them are still worth drawing.
local function Paint(now)
	local visible = false
	for i = 0, live - 1 do
		local index = (head - i - 1) % capacity + 1
		local age = now - born[index]
		local dot = pool[index]
		if age >= lifetime then
			dot:Hide()
		else
			local gone = age / lifetime
			dot:SetAlpha(opacity * (1 - gone))
			if shrink then
				local scaled = size * (1 - gone * 0.75)
				dot:SetSize(scaled, scaled)
			end
			dot:Show()
			visible = true
		end
	end

	-- Retire dead dots off the tail end so live stays honest.
	while live > 0 do
		local oldest = (head - live) % capacity + 1
		if now - born[oldest] < lifetime then
			break
		end
		live = live - 1
	end

	return visible
end

local Wake

local function Sleep()
	ticker:SetScript("OnUpdate", nil)
	asleep = true
	watcher:SetScript("OnUpdate", watcher.Check)
end

local function OnTick()
	local now = GetTime()
	if lastTick and now - lastTick > HITCH then
		Clear()
	end
	lastTick = now

	local scale = UIParent:GetEffectiveScale()
	local x, y = GetCursorPosition()
	x, y = x / scale, y / scale

	local moved = true
	if lastX then
		local dx, dy = x - lastX, y - lastY
		moved = (dx * dx + dy * dy) >= (NUDGE * NUDGE)
	end
	lastX, lastY = x, y

	local blocked = Suppressed()
	if blocked then
		-- Do not bridge a stroke across a mouselook or a cinematic.
		emitX, emitY = nil, nil
	elseif not emitX then
		-- Seed the origin without dropping a dot, or waking up parks a blob under
		-- a stationary pointer.
		emitX, emitY = x, y
	else
		local dx, dy = x - emitX, y - emitY
		local travelled = sqrt(dx * dx + dy * dy)
		if travelled >= spacing then
			-- Fill the gap a fast flick leaves, so the line stays continuous.
			local steps = min(MAX_FILL, max(1, floor(travelled / spacing)))
			for step = 1, steps do
				local along = step / steps
				Emit(emitX + dx * along, emitY + dy * along, now)
			end
			emitX, emitY = x, y
		end
	end

	if Paint(now) then
		holder:Show()
	else
		holder:Hide()
	end

	-- Nothing moving and nothing left on screen, so there is nothing to draw.
	-- Motion while suppressed must not hold the loop open either, or combat only
	-- would tick forever on an idle character wiggling the mouse.
	if (not moved or blocked) and live == 0 then
		Sleep()
	end
end

function Wake()
	if not asleep then
		return
	end
	asleep = false
	watcher:SetScript("OnUpdate", nil)
	lastTick = GetTime()
	ticker:SetScript("OnUpdate", OnTick)
end

-- Cheap poll while asleep. This is the one thing that cannot be event driven,
-- since pointer movement raises nothing, so it runs at 20Hz instead of every
-- frame and does nothing but compare two numbers.
local function OnWatch(self, elapsed)
	self.wait = (self.wait or 0) + elapsed
	if self.wait < WATCH then
		return
	end
	self.wait = 0
	if Suppressed() then
		return
	end
	local scale = UIParent:GetEffectiveScale()
	local x, y = GetCursorPosition()
	x, y = x / scale, y / scale
	if not lastX then
		lastX, lastY = x, y
		Wake()
		return
	end
	local dx, dy = x - lastX, y - lastY
	if (dx * dx + dy * dy) >= (NUDGE * NUDGE) then
		Wake()
	end
end

function Module:PLAYER_STARTED_LOOKING()
	turning = turning + 1
end

function Module:PLAYER_STOPPED_LOOKING()
	turning = max(0, turning - 1)
end

function Module:PLAYER_STARTED_TURNING()
	turning = turning + 1
end

function Module:PLAYER_STOPPED_TURNING()
	turning = max(0, turning - 1)
end

function Module:CINEMATIC_START()
	inCinematic = true
	Clear()
end

function Module:CINEMATIC_STOP()
	inCinematic = false
end

-- Dots are anchored in screen units, so a scale change leaves every one of them
-- in the wrong place.
function Module:UI_SCALE_CHANGED()
	Clear()
end

function Module:PLAYER_ENTERING_WORLD()
	Clear()
	turning, inCinematic = 0, false
end

-- Combat only: come back up so the first swing of the mouse in combat draws.
function Module:PLAYER_REGEN_DISABLED()
	if combatOnly then
		Wake()
	end
end

function Module:OnEnable()
	local db = C.Misc
	if not db.CursorTrail then
		return
	end

	capacity = db.CursorTrailLength
	size = db.CursorTrailSize
	spacing = db.CursorTrailSpacing
	lifetime = db.CursorTrailLifetime
	opacity = db.CursorTrailAlpha
	shrink = db.CursorTrailShrink
	combatOnly = db.CursorTrailCombat
	hideTurning = db.CursorTrailHideTurning

	local r, g, b
	if db.CursorTrailClassColor then
		r, g, b = K.ClassColor.r, K.ClassColor.g, K.ClassColor.b
	else
		local custom = db.CursorTrailColor
		r, g, b = custom[1], custom[2], custom[3]
	end

	holder = CreateFrame("Frame", "KKUI_CursorTrail", UIParent)
	holder:SetAllPoints(UIParent)
	holder:SetFrameStrata("TOOLTIP")
	holder:EnableMouse(false)
	holder:Hide()

	local shape = SHAPES[db.CursorTrailShape] or SHAPES.Glow
	for i = 1, capacity do
		local dot = holder:CreateTexture(nil, "ARTWORK")
		dot:SetTexture(shape)
		dot:SetSize(size, size)
		dot:SetVertexColor(r, g, b)
		dot:SetBlendMode("ADD")
		dot:Hide()
		pool[i] = dot
	end

	ticker = CreateFrame("Frame")
	watcher = CreateFrame("Frame")
	watcher.Check = OnWatch

	self:RegisterEvent("PLAYER_STARTED_LOOKING", "PLAYER_STARTED_LOOKING")
	self:RegisterEvent("PLAYER_STOPPED_LOOKING", "PLAYER_STOPPED_LOOKING")
	self:RegisterEvent("PLAYER_STARTED_TURNING", "PLAYER_STARTED_TURNING")
	self:RegisterEvent("PLAYER_STOPPED_TURNING", "PLAYER_STOPPED_TURNING")
	self:RegisterEvent("CINEMATIC_START", "CINEMATIC_START")
	self:RegisterEvent("CINEMATIC_STOP", "CINEMATIC_STOP")
	self:RegisterEvent("UI_SCALE_CHANGED", "UI_SCALE_CHANGED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "PLAYER_ENTERING_WORLD")
	if combatOnly then
		self:RegisterEvent("PLAYER_REGEN_DISABLED", "PLAYER_REGEN_DISABLED")
	end

	Wake()
end
