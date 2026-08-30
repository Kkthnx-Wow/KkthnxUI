--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/UnitFrames/Elements/Castbar.lua
	Purpose:
		Castbars. The player, target, and focus bars are detached and get their
		own mover, the way the original KkthnxUI placed them. Boss and group bars
		stay attached under their unit.

		Midnight notes: cast progress is driven by the client through
		SetTimerDuration and a DurationObject, so nothing here does start/end
		arithmetic. "Can I interrupt this" arrives as a possibly secret boolean,
		so it is fed to a tint texture through SetAlphaFromBoolean instead of an
		if statement.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("UnitFrames")
local Build = Module.Build

local CreateFrame = CreateFrame
local CreateColor = CreateColor
local IsSecret = K.IsSecret

-- Blizzard's own cast colour language, tuned to sit in our palette: a warm gold
-- for a normal cast, silver grey for one you cannot interrupt (paired with the
-- padlock), and red when a cast is interrupted or fails.
local CAST_COLOR = { 0.85, 0.65, 0.13 } -- normal (gold / yellow)
local NOINTERRUPT_COLOR = { 0.6, 0.6, 0.65 } -- cannot interrupt (silver)
local FAIL_COLOR = { 0.85, 0.25, 0.25 } -- interrupted / failed (red)
-- ColorMixin objects for the secret-safe boolean colouring below.
local CAST_CLR = CreateColor(CAST_COLOR[1], CAST_COLOR[2], CAST_COLOR[3])
local NOINTERRUPT_CLR = CreateColor(NOINTERRUPT_COLOR[1], NOINTERRUPT_COLOR[2], NOINTERRUPT_COLOR[3])

-- ---------------------------------------------------------------------------
-- Callbacks
-- ---------------------------------------------------------------------------

-- Colour the whole bar by interruptibility. notInterruptible arrives as a
-- PostCastStart argument (the current oUF keeps it in element state, not on the
-- element), and it is a Midnight secret boolean, so we drive the colour through
-- SetVertexColorFromBoolean which handles the secret natively instead of an if.
local function OnCastStart(self, _, _, notInterruptible)
	-- Clear the interrupted state a previous cast may have left behind, so the timer
	-- text is allowed to update again.
	self.__failed = nil
	local tex = self:GetStatusBarTexture()
	-- Secret boolean (enemy casts) -> the secret-safe setter. A plain boolean or nil
	-- -> a normal branch, since the setter rejects non-secret values.
	if IsSecret(notInterruptible) then
		if tex and tex.SetVertexColorFromBoolean then
			tex:SetVertexColorFromBoolean(notInterruptible, NOINTERRUPT_CLR, CAST_CLR)
		end
	elseif notInterruptible then
		self:SetStatusBarColor(NOINTERRUPT_CLR:GetRGB())
	else
		self:SetStatusBarColor(CAST_COLOR[1], CAST_COLOR[2], CAST_COLOR[3])
	end
end

local function OnCastFail(self)
	self:SetStatusBarColor(FAIL_COLOR[1], FAIL_COLOR[2], FAIL_COLOR[3])
	-- Freeze the timer for the failed hold. oUF keeps the bar up for timeToHold and
	-- re-runs the time text during it, so a flag blocks those updates and the number
	-- stops instead of ticking on.
	self.__failed = true
	if self.Time then
		self.Time:SetText("")
	end
end

-- oUF passes a DurationObject, never a raw number, so this stays safe when the
-- remaining time is a secret value.
local function CustomTimeText(self, duration)
	if not self.Time or self.__failed then
		return
	end
	self.Time:SetFormattedText("%.1f", duration:GetRemainingDuration())
end

local function CustomDelayText(self, duration)
	if not self.Time or self.__failed then
		return
	end
	self.Time:SetFormattedText("%.1f|cffff5555%s%.1f|r", duration:GetRemainingDuration(), self.channeling and "-" or "+", self.delay)
end

-- Empower stage separators. A plain line reads better on our flat bars than the
-- Blizzard pip art.
local function CreatePip(element)
	local pip = CreateFrame("Frame", nil, element)
	pip:SetWidth(2)
	pip:SetFrameLevel(element:GetFrameLevel() + 3)
	local line = pip:CreateTexture(nil, "OVERLAY")
	line:SetAllPoints()
	line:SetColorTexture(0, 0, 0, 0.85)
	return pip
end

-- ---------------------------------------------------------------------------
-- Construction
-- ---------------------------------------------------------------------------

-- Parented to the bar rather than the holder so oUF hiding the bar takes the
-- icon with it. Sticking out past the bar's edge is fine, children are not
-- clipped to their parent.
local function AddIcon(cast, size, side)
	local holder = CreateFrame("Frame", nil, cast)
	holder:SetSize(size, size)
	if side == "right" then
		holder:SetPoint("LEFT", cast, "RIGHT", Module.GAP, 0)
	else
		holder:SetPoint("RIGHT", cast, "LEFT", -Module.GAP, 0)
	end
	K.CreateBackground(holder, 0.05, 0.05, 0.05, 0.9)
	K.CreateBorder(holder)

	local icon = holder:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("TOPLEFT", holder, "TOPLEFT", 1, -1)
	icon:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", -1, 1)
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	cast.Icon = icon
	cast.IconHolder = holder
	return holder
end

-- opts:
--   width, height   bar size
--   iconSide        "left" (default) or "right"
--   latency         show the latency safe zone (player only)
--   parent          frame the bar lives on, defaults to the unit frame
local function CreateBar(self, opts)
	local db = C.Unitframe.Castbar
	local parent = opts.parent or self

	local cast = CreateFrame("StatusBar", nil, parent)
	cast:SetStatusBarTexture(Module.Texture())
	cast:SetStatusBarColor(CAST_COLOR[1], CAST_COLOR[2], CAST_COLOR[3])
	cast:SetHeight(opts.height)
	-- Same blue gradient backdrop as the health and power bars so the empty part of
	-- the castbar matches the rest of the frame instead of reading flat black.
	K.CreateGradientBackground(cast, 0.9)
	K.CreateBorder(cast)

	cast.timeToHold = db.TimeToHold
	cast.PostCastStart = OnCastStart
	-- Same colouring when a cast flips interruptible mid-cast (a kick immunity
	-- dropping, say). PostCastInterruptible shares PostCastStart's signature.
	cast.PostCastInterruptible = OnCastStart
	cast.PostCastFail = OnCastFail
	cast.PostCastInterrupted = OnCastFail
	cast.CreatePip = CreatePip

	-- A padlock over the bar while the cast cannot be interrupted (with the grey
	-- bar colour from OnCastStart). oUF drives its alpha from notInterruptible, so
	-- it only shows on non-interruptible casts. Replaces the stock shield art.
	local shield = cast:CreateTexture(nil, "OVERLAY")
	shield:SetAtlas("UI-CharacterCreate-PadLock", false)
	local lock = opts.height * 1.1
	shield:SetSize(lock * (63 / 76), lock) -- keep the atlas aspect ratio
	shield:SetPoint("CENTER", cast, "CENTER", 0, 0)
	shield:SetAlpha(0)
	cast.Shield = shield

	if db.ShowSpark then
		local spark = cast:CreateTexture(nil, "OVERLAY")
		spark:SetTexture(C.Media.Textures.Spark)
		spark:SetBlendMode("ADD")
		-- Thin vertical glow, a touch taller than the bar. A wide/double-height
		-- spark reads as a blob at the fill edge.
		spark:SetSize(4, opts.height + 4)
		spark:SetPoint("CENTER", cast:GetStatusBarTexture(), "RIGHT", 0, 0)
		cast.Spark = spark
	end

	local name = Module.NewText(cast, opts.height >= 24 and 12 or 11)
	name:SetPoint("LEFT", cast, "LEFT", 4, 0)
	name:SetJustifyH("LEFT")
	cast.Text = name

	if db.ShowTimer then
		local time = Module.NewText(cast, opts.height >= 24 and 12 or 11)
		time:SetPoint("RIGHT", cast, "RIGHT", -4, 0)
		time:SetJustifyH("RIGHT")
		cast.Time = time
		cast.CustomTimeText = CustomTimeText
		cast.CustomDelayText = CustomDelayText

		-- Keep the spell name from running under the timer.
		name:SetPoint("RIGHT", time, "LEFT", -6, 0)
	else
		name:SetPoint("RIGHT", cast, "RIGHT", -4, 0)
	end

	if db.ShowIcon then
		AddIcon(cast, opts.height, opts.iconSide)
	end

	if opts.latency and db.ShowLatency then
		local safe = cast:CreateTexture(nil, "OVERLAY")
		safe:SetColorTexture(FAIL_COLOR[1], FAIL_COLOR[2], FAIL_COLOR[3], 0.6)
		cast.SafeZone = safe
	end

	self.Castbar = cast
	return cast
end

-- A free floating castbar: the bar and its icon live inside a holder parented to
-- UIParent, which is what the mover grabs. Detaching from the unit frame also
-- means the bar keeps its own alpha and visibility.
function Build.DetachedCastbar(self, key, label, width, height, point, iconSide)
	local db = C.Unitframe.Castbar
	if not db.Enable then
		return
	end

	local holder = CreateFrame("Frame", nil, UIParent)
	local totalWidth = db.ShowIcon and (width + height + Module.GAP) or width
	holder:SetSize(totalWidth, height)

	local cast = CreateBar(self, {
		width = width,
		height = height,
		iconSide = iconSide or "left",
		latency = self.unit == "player",
		parent = holder,
	})
	cast:SetWidth(width)
	if (iconSide or "left") == "left" and db.ShowIcon then
		cast:SetPoint("RIGHT", holder, "RIGHT", 0, 0)
	else
		cast:SetPoint("LEFT", holder, "LEFT", 0, 0)
	end

	cast.Holder = holder

	K.CreateMover(holder, key, label, point, totalWidth, height)
	return cast
end

-- An attached castbar, pushed onto the frame's downward stack.
function Build.Castbar(self, height, iconSide)
	local db = C.Unitframe.Castbar
	if not db.Enable then
		return
	end

	local cast = CreateBar(self, {
		height = height,
		iconSide = iconSide or "left",
	})
	Module.StackDown(self, cast, height)
	return cast
end

-- A castbar that sits above the frame, spanning the full width (portrait included)
-- so a compact frame keeps its own bar without a hanging icon. Its own background
-- and border, a square spell icon in its own slot beside the bar, name and timer.
-- side is the portrait side ("right" puts the icon slot on the right, matching a
-- right-hand portrait), defaulting to a left-hand slot.
function Build.TopCastbar(self, height, side)
	local db = C.Unitframe.Castbar
	if not db.Enable then
		return
	end
	local health = self.Health
	if not health then
		return
	end
	height = height or 16
	local rightSide = side == "right"

	local cast = CreateFrame("StatusBar", nil, self)
	cast:SetStatusBarTexture(Module.Texture())
	cast:SetStatusBarColor(CAST_COLOR[1], CAST_COLOR[2], CAST_COLOR[3])
	cast:SetHeight(height)
	-- The bar leaves a square-plus-gap for the icon on the portrait side and spans to
	-- the other edge of the frame, a small gap above the top.
	local outer = self.PortraitHolder or self
	if rightSide then
		cast:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, Module.GAP)
		cast:SetPoint("BOTTOMRIGHT", outer, "TOPRIGHT", -(height + Module.GAP), Module.GAP)
	else
		cast:SetPoint("BOTTOMLEFT", outer, "TOPLEFT", height + Module.GAP, Module.GAP)
		cast:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, Module.GAP)
	end
	K.CreateGradientBackground(cast, 0.9)
	K.CreateBorder(cast)

	cast.PostCastStart = OnCastStart
	cast.PostCastInterruptible = OnCastStart
	cast.PostCastFail = OnCastFail
	cast.PostCastInterrupted = OnCastFail

	-- Square spell icon in its own slot beside the bar. Parented to the bar so it
	-- hides with it when no cast is running.
	local holder = CreateFrame("Frame", nil, cast)
	holder:SetSize(height, height)
	if rightSide then
		holder:SetPoint("LEFT", cast, "RIGHT", Module.GAP, 0)
	else
		holder:SetPoint("RIGHT", cast, "LEFT", -Module.GAP, 0)
	end
	K.CreateGradientBackground(holder, 0.9)
	K.CreateBorder(holder)
	local icon = holder:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("TOPLEFT", holder, "TOPLEFT", 1, -1)
	icon:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", -1, 1)
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	cast.Icon = icon
	cast.IconHolder = holder

	if db.ShowSpark then
		local spark = cast:CreateTexture(nil, "OVERLAY")
		spark:SetTexture(C.Media.Textures.Spark)
		spark:SetBlendMode("ADD")
		spark:SetSize(4, height)
		spark:SetPoint("CENTER", cast:GetStatusBarTexture(), "RIGHT", 0, 0)
		cast.Spark = spark
	end

	local name = Module.NewText(cast, 10)
	name:SetPoint("LEFT", cast, "LEFT", 4, 0)
	name:SetJustifyH("LEFT")
	cast.Text = name

	if db.ShowTimer then
		local time = Module.NewText(cast, 10)
		time:SetPoint("RIGHT", cast, "RIGHT", -4, 0)
		time:SetJustifyH("RIGHT")
		cast.Time = time
		cast.CustomTimeText = CustomTimeText
		cast.CustomDelayText = CustomDelayText
		name:SetPoint("RIGHT", time, "LEFT", -4, 0)
	else
		name:SetPoint("RIGHT", cast, "RIGHT", -4, 0)
	end

	self.Castbar = cast
	return cast
end
