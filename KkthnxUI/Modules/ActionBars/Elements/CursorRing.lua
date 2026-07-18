--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Notes:
-- - Purpose: Class-coloured cooldown ring under the cursor during GCD (and optionally cast).
-- - Design: DurationObject swipe only — no GetTime() arithmetic. OnUpdate tracks the mouse
--   only while the ring is visible. Soft donut art doubles as chrome + swipe texture.
-- - Events: SPELL_UPDATE_COOLDOWN, ACTIONBAR_UPDATE_COOLDOWN, UNIT_SPELLCAST_*, PLAYER_REGEN_ENABLED
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("ActionBar")

local CreateFrame = CreateFrame
local GetCursorPosition = GetCursorPosition
local UIParent = UIParent
local UnitAffectingCombat = UnitAffectingCombat
local UnitCastingDuration = UnitCastingDuration
local UnitChannelDuration = UnitChannelDuration
local floor = math.floor

local GCD_SPELL_ID = 61304
local C_Spell_GetSpellCooldownDuration = C_Spell and C_Spell.GetSpellCooldownDuration
local RING_TEXTURE = K.MediaFolder .. "Cursor\\CursorRing"
local POLL_INTERVAL = 0.05

local eventsRegistered = false
local root, ringArt, gcdCooldown, castCooldown
local pollFrame, trackFrame
local pollElapsed = 0
local lastX, lastY, lastScale
local gcdActive, castActive

local function cfg()
	return C["ActionBar"]
end

-- IsZero() can be Secret in combat — never branch on the raw return.
-- nil (secret) → treat as non-zero so we don't wipe an active swipe mid-fight.
local function DurationIsZero(durObj)
	if not durObj then
		return true
	end
	if not durObj.IsZero then
		return false
	end
	local z = K.BooleanIsTrue(durObj:IsZero())
	if z == nil then
		return false
	end
	return z
end

local function IsGCDInactive()
	if not C_Spell_GetSpellCooldownDuration then
		return true
	end
	return DurationIsZero(C_Spell_GetSpellCooldownDuration(GCD_SPELL_ID))
end

local function StopTrack()
	if trackFrame then
		trackFrame:SetScript("OnUpdate", nil)
		trackFrame:Hide()
	end
	lastX, lastY, lastScale = nil, nil, nil
end

local function StopPoll()
	if pollFrame then
		pollFrame:SetScript("OnUpdate", nil)
		pollFrame:Hide()
	end
	pollElapsed = 0
end

local function UpdateVisibility()
	if not root then
		return
	end
	local show = gcdActive or castActive
	if show and cfg().CursorRingCombatOnly and not UnitAffectingCombat("player") then
		show = false
	end
	root:SetShown(show)
	if show then
		if not trackFrame then
			trackFrame = CreateFrame("Frame")
		end
		trackFrame:SetScript("OnUpdate", function()
			if not (root and root:IsShown()) then
				StopTrack()
				return
			end
			local x, y = GetCursorPosition()
			local scale = UIParent:GetEffectiveScale()
			if scale == 0 then
				return
			end
			x, y = x / scale, y / scale
			if x == lastX and y == lastY and scale == lastScale then
				return
			end
			lastX, lastY, lastScale = x, y, scale
			root:ClearAllPoints()
			root:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
		end)
		trackFrame:Show()
	else
		StopTrack()
	end
end

local function ClearGCD()
	gcdActive = false
	if gcdCooldown then
		gcdCooldown:Clear()
		gcdCooldown:Hide()
	end
	UpdateVisibility()
	if not castActive then
		StopPoll()
	end
end

local function ClearCast()
	castActive = false
	if castCooldown then
		castCooldown:Clear()
		castCooldown:Hide()
	end
	UpdateVisibility()
end

local function StartPoll()
	if not pollFrame then
		pollFrame = CreateFrame("Frame")
		pollFrame:Hide()
	end
	pollElapsed = 0
	pollFrame:SetScript("OnUpdate", function(_, elapsed)
		pollElapsed = pollElapsed + (elapsed or 0)
		if pollElapsed < POLL_INTERVAL then
			return
		end
		pollElapsed = 0
		if gcdActive and IsGCDInactive() then
			ClearGCD()
		end
	end)
	pollFrame:Show()
end

local function ApplyGCD(durObj)
	if not (gcdCooldown and durObj) then
		return
	end
	if cfg().CursorRingCombatOnly and not UnitAffectingCombat("player") then
		ClearGCD()
		return
	end

	gcdCooldown:Show()
	gcdCooldown:SetCooldownFromDurationObject(durObj)
	K.MaskCooldownSwipeFromDurationObject(gcdCooldown, durObj)
	gcdActive = true
	UpdateVisibility()
	StartPoll()
end

local function OnSpellCooldownUpdate()
	if not cfg().CursorRing then
		return
	end
	if not C_Spell_GetSpellCooldownDuration then
		return
	end

	local durObj = C_Spell_GetSpellCooldownDuration(GCD_SPELL_ID)
	if IsGCDInactive() then
		ClearGCD()
		return
	end
	ApplyGCD(durObj)
end

local function ApplyCastDuration(durObj)
	if not (castCooldown and durObj and cfg().CursorRingShowCast) then
		ClearCast()
		return
	end
	if DurationIsZero(durObj) then
		ClearCast()
		return
	end
	if cfg().CursorRingCombatOnly and not UnitAffectingCombat("player") then
		ClearCast()
		return
	end

	castCooldown:Show()
	castCooldown:SetCooldownFromDurationObject(durObj)
	K.MaskCooldownSwipeFromDurationObject(castCooldown, durObj)
	castActive = true
	UpdateVisibility()
end

local function RefreshCast()
	if not cfg().CursorRing or not cfg().CursorRingShowCast then
		ClearCast()
		return
	end

	-- Prefer active cast, then channel. DurationObjects — no ms arithmetic.
	if UnitCastingDuration then
		local castDur = UnitCastingDuration("player")
		if castDur and not DurationIsZero(castDur) then
			ApplyCastDuration(castDur)
			return
		end
	end
	if UnitChannelDuration then
		local channelDur = UnitChannelDuration("player")
		if channelDur and not DurationIsZero(channelDur) then
			ApplyCastDuration(channelDur)
			return
		end
	end
	ClearCast()
end

local function OnRegenEnabled()
	if cfg().CursorRingCombatOnly then
		ClearGCD()
		ClearCast()
	end
end

local function StyleRingArt()
	if not ringArt then
		return
	end
	ringArt:SetTexture(RING_TEXTURE)
	ringArt:SetAllPoints()
	ringArt:SetBlendMode("ADD")
	ringArt:SetVertexColor(K.r, K.g, K.b, 1)
	ringArt:SetAlpha(0.55)
end

local function StyleCooldown(cd, alpha, inset)
	cd:ClearAllPoints()
	if inset and inset > 0 then
		cd:SetPoint("TOPLEFT", inset, -inset)
		cd:SetPoint("BOTTOMRIGHT", -inset, inset)
	else
		cd:SetAllPoints()
	end
	cd:SetDrawBling(false)
	cd:SetDrawEdge(false)
	cd:SetHideCountdownNumbers(true)
	cd:SetReverse(true)
	if cd.SetUseCircularEdge then
		cd:SetUseCircularEdge(true)
	end

	local a = alpha or 0.90
	-- Same donut as chrome — swipe reveals the ring, never a square fill.
	cd:SetSwipeTexture(RING_TEXTURE, K.r, K.g, K.b, a)
	cd:SetSwipeColor(K.r, K.g, K.b, a)
end

local function BuildFrames()
	if root then
		return
	end

	local size = cfg().CursorRingSize or 48
	root = CreateFrame("Frame", "KKUI_CursorRing", UIParent)
	root:SetSize(size, size)
	root:SetFrameStrata("TOOLTIP")
	root:EnableMouse(false)
	root:Hide()

	ringArt = root:CreateTexture(nil, "BACKGROUND", nil, 0)
	StyleRingArt()

	gcdCooldown = CreateFrame("Cooldown", nil, root, "CooldownFrameTemplate")
	StyleCooldown(gcdCooldown, 0.90, 0)
	gcdCooldown:Hide()

	castCooldown = CreateFrame("Cooldown", nil, root, "CooldownFrameTemplate")
	StyleCooldown(castCooldown, 1.0, floor(size * 0.12))
	castCooldown:Hide()
end

local function ApplyLayout()
	if not root then
		return
	end
	local size = cfg().CursorRingSize or 48
	root:SetSize(size, size)
	StyleRingArt()
	StyleCooldown(gcdCooldown, 0.90, 0)
	StyleCooldown(castCooldown, 1.0, floor(size * 0.12))
end

local function RegisterEvents()
	if eventsRegistered then
		return
	end
	eventsRegistered = true
	K:RegisterEvent("SPELL_UPDATE_COOLDOWN", OnSpellCooldownUpdate)
	K:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", OnSpellCooldownUpdate)
	K:RegisterEvent("PLAYER_REGEN_ENABLED", OnRegenEnabled)
	K:RegisterUnitEvent("UNIT_SPELLCAST_START", RefreshCast, "player")
	K:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", RefreshCast, "player")
	K:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", RefreshCast, "player")
	K:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", RefreshCast, "player")
	K:RegisterUnitEvent("UNIT_SPELLCAST_STOP", ClearCast, "player")
	K:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", ClearCast, "player")
	K:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", ClearCast, "player")
	K:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", ClearCast, "player")
end

local function UnregisterEvents()
	if not eventsRegistered then
		return
	end
	eventsRegistered = false
	K:UnregisterEvent("SPELL_UPDATE_COOLDOWN", OnSpellCooldownUpdate)
	K:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN", OnSpellCooldownUpdate)
	K:UnregisterEvent("PLAYER_REGEN_ENABLED", OnRegenEnabled)
	K:UnregisterEvent("UNIT_SPELLCAST_START", RefreshCast)
	K:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START", RefreshCast)
	K:UnregisterEvent("UNIT_SPELLCAST_DELAYED", RefreshCast)
	K:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", RefreshCast)
	K:UnregisterEvent("UNIT_SPELLCAST_STOP", ClearCast)
	K:UnregisterEvent("UNIT_SPELLCAST_FAILED", ClearCast)
	K:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED", ClearCast)
	K:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", ClearCast)
	ClearGCD()
	ClearCast()
	StopPoll()
	StopTrack()
	if root then
		root:Hide()
	end
end

function Module:CreateCursorRing()
	if not cfg().CursorRing then
		UnregisterEvents()
		return
	end

	BuildFrames()
	ApplyLayout()
	RegisterEvents()
	OnSpellCooldownUpdate()
	RefreshCast()
end

function Module:UpdateCursorRing()
	if not cfg().CursorRing then
		UnregisterEvents()
		return
	end
	if not cfg().CursorRingShowCast then
		ClearCast()
	end
	ApplyLayout()
	OnSpellCooldownUpdate()
	RefreshCast()
end
