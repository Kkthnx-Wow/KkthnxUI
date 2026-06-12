--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Provides a reusable spark texture for Health and Power status bars.
-- - Design: The spark is anchored to the bar's STATUS BAR TEXTURE RIGHT edge,
--            not a calculated pixel offset. This makes it follow K:SmoothBar
--            animation with zero lag — the texture edge IS the visual fill position.
--            The texture reference is cached at creation time to avoid repeated
--            API lookups on every PostUpdate call.
-- - Events: Driven by oUF's Health.PostUpdate and Power.PostUpdate callbacks.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

-- REASON: Localize the global environment and WoW API functions used in
-- PostUpdate callbacks. These fire on UNIT_HEALTH/UNIT_POWER_FREQUENT — frequent
-- enough to benefit from local lookup vs. global hash on each call.
local _G = _G
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitIsConnected = _G.UnitIsConnected

local IsSecret = K.IsSecret

-- ---------------------------------------------------------------------------
-- SPARK TEXTURE FACTORY
-- ---------------------------------------------------------------------------

-- REASON: Shared factory — one function, consistent appearance on every bar.
-- PERF: The status bar texture reference is captured once at creation and stored
-- on the spark itself (spark.barTex). PositionSpark reads spark.barTex rather
-- than calling bar:GetStatusBarTexture() on every PostUpdate, eliminating a
-- repeated method call on a hot path.
function Module.CreateBarSpark(_, bar)
	local spark = bar:CreateTexture(nil, "OVERLAY", nil, 7)
	spark:SetTexture(C["Media"].Textures.Spark128Texture)
	spark:SetBlendMode("ADD")
	spark:SetAlpha(0.75)
	spark:Hide()

	-- PERF: Cache the texture reference now; it never changes after bar creation.
	spark.barTex = bar:GetStatusBarTexture()

	return spark
end

-- ---------------------------------------------------------------------------
-- INTERNAL: ANCHOR SPARK TO BAR TEXTURE EDGE
-- ---------------------------------------------------------------------------

-- REASON: Anchoring CENTER to the barTex RIGHT point means WoW's own frame
-- layout engine repositions the spark every frame as the texture grows/shrinks.
-- No OnUpdate, no math — smooth bar interpolation is handled for free.
-- This solves the lag seen with K:SmoothBar where data values update
-- instantly but the visual fill lags behind by design.
local function PositionSpark(spark, bar)
	-- SECRET (12.0): With native StatusBar interpolation, feeding the bar a secret
	-- health/power value marks the whole bar (and its fill texture) secret, so the
	-- texture's geometry getters return secret numbers. SetSize/SetPoint reject
	-- secret args in tainted execution, and the spark is anchored to the fill
	-- texture's RIGHT edge — which is exactly the value we can no longer read.
	-- Guarding the texture height covers both the size and the anchor: if it's
	-- secret we simply hide the spark (we have no legal edge to mark).
	local height = spark.barTex:GetHeight()
	if IsSecret(height) then
		spark:Hide()
		return
	end

	-- REASON: Fixed 64px width matches the Spark128 texture's natural dimensions
	-- and is consistent with the castbar spark sizing used elsewhere in the addon.
	spark:SetSize(64, height)
	spark:ClearAllPoints()
	spark:SetPoint("CENTER", spark.barTex, "RIGHT", 0, 0)

	local r, g, b = bar:GetStatusBarColor()
	if r and not IsSecret(r) then
		spark:SetVertexColor(r, g, b)
	end

	spark:Show()
end

-- ---------------------------------------------------------------------------
-- HEALTH SPARK CALLBACK
-- ---------------------------------------------------------------------------

-- REASON: oUF calls Health.PostUpdate(element, unit, cur, max) after each
-- UNIT_HEALTH / UNIT_MAXHEALTH event. We use the real values only for the
-- show/hide decision — position is driven by the texture edge, not cur/max math.
function Module.PostUpdateHealthSpark(element, unit, cur, max)
	local spark = element.Spark
	if not spark then
		return
	end

	-- dead/ghost:   health is 0, bar is meaningless.
	-- disconnected: bar shows max but data is stale.
	-- These are non-secret booleans, so they are always safe to test.
	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		spark:Hide()
		return
	end

	-- SECRET (12.0): health is a secret number in combat/instances, so we cannot
	-- compare cur/max to gate the empty/full edge. Only apply the numeric gate when
	-- the values are readable; otherwise defer entirely to PositionSpark, which
	-- self-guards on the (possibly secret) fill-texture geometry.
	if not IsSecret(cur) and not IsSecret(max) then
		-- WARNING: Hide spark whenever it has no meaningful edge to show:
		-- cur <= 0:     empty bar — nothing to mark.
		-- cur >= max:   full bar — no deficit edge.
		if cur <= 0 or max <= 0 or cur >= max then
			spark:Hide()
			return
		end
	end

	PositionSpark(spark, element)
end

-- ---------------------------------------------------------------------------
-- POWER SPARK CALLBACK
-- ---------------------------------------------------------------------------

-- REASON: oUF calls Power.PostUpdate(element, unit, cur, min, max) after each
-- UNIT_POWER_FREQUENT / UNIT_POWER_UPDATE event. The signature includes min
-- (non-zero for some alternate power types), so it is named explicitly.
-- oUF always provides numeric values; nil guards are not needed here.
function Module.PostUpdatePowerSpark(element, unit, cur, min, max)
	local spark = element.Spark
	if not spark then
		return
	end

	-- dead/ghost / offline: power is irrelevant. Non-secret booleans, safe to test.
	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		spark:Hide()
		return
	end

	-- SECRET (12.0): power can be a secret number in combat/instances. Only apply
	-- the numeric edge gate when values are readable; otherwise defer to
	-- PositionSpark, which self-guards on the (possibly secret) fill-texture geometry.
	if not IsSecret(cur) and not IsSecret(min) and not IsSecret(max) then
		-- WARNING: Hide spark when power has no meaningful edge:
		-- cur <= 0 or cur <= min:  at the floor — nothing to mark.
		-- cur >= max:              full bar — no edge to show.
		if max <= 0 or cur <= (min or 0) or cur >= max then
			spark:Hide()
			return
		end
	end

	PositionSpark(spark, element)
end
