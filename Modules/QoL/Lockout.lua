--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/QoL/Lockout.lua
	Purpose:
		Show the Bloodlust lockout (Sated, Exhaustion and the rest) as one icon
		with its countdown, so the group knows when the next lust is allowed.

		Only your own auras are watched, through a unit event for the player alone,
		so the rest of the game's aura traffic never reaches this file. The debuffs
		are looked up by their known spell ids, and nothing is ever read back off
		an aura that could be hidden. While the game hides the timing in combat the
		icon keeps its last known countdown, and shows without one if the debuff
		began in combat.
-----------------------------------------------------------------------------]]

local K, L = KkthnxUI[1], KkthnxUI[3]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("QoL")

local IsSecret = K.IsSecret
local CreateFrame = CreateFrame
local GetTime = GetTime
local ipairs = ipairs
local C_UnitAuras = C_UnitAuras
local C_Spell = C_Spell

local ICON_SIZE = 40

-- The lockout debuffs: Exhaustion (Heroism), Sated (Bloodlust), Temporal
-- Displacement (Time Warp), Insanity (Primal Rage), the two Fatigued, and the
-- Evoker Exhaustion.
local DEBUFFS = { 57723, 57724, 80354, 95809, 160455, 264689, 390435 }

local frame
local expiry -- last readable end time of the lockout, kept for combat

local function Find()
	for _, spellID in ipairs(DEBUFFS) do
		local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
		if aura then
			return aura, spellID
		end
	end
end

local function Update()
	local aura, spellID = Find()
	if aura and IsSecret(aura) then
		-- The game is hiding auras right now. Indexing the value would error, so
		-- leave whatever is on screen alone until it can be read again.
		return
	end
	if not aura then
		expiry = nil
		frame:Hide()
		return
	end

	frame.Icon:SetTexture(C_Spell.GetSpellTexture(spellID))
	frame:Show()

	local stop, duration = aura.expirationTime, aura.duration
	if stop and duration and not IsSecret(stop) and not IsSecret(duration) and duration > 0 then
		expiry = stop
		frame.Cooldown:SetCooldown(stop - duration, duration)
	elseif expiry and expiry > GetTime() then
		-- Hidden right now, so carry on from the last time that could be read.
		frame.Cooldown:SetCooldown(expiry - 600, 600)
	else
		frame.Cooldown:Clear()
	end
end

local function Build()
	frame = CreateFrame("Frame", nil, UIParent)
	frame:SetSize(ICON_SIZE, ICON_SIZE)
	frame:SetFrameStrata("MEDIUM")
	frame:Hide()
	K.CreateGradientBackground(frame, 0.9)
	K.CreateBorder(frame)

	frame.Icon = frame:CreateTexture(nil, "ARTWORK")
	frame.Icon:SetPoint("TOPLEFT", 1, -1)
	frame.Icon:SetPoint("BOTTOMRIGHT", -1, 1)
	frame.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	frame.Cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
	frame.Cooldown:SetAllPoints(frame.Icon)
	frame.Cooldown:SetHideCountdownNumbers(false)
	K.StyleCooldownSwipe(frame.Cooldown)

	K.CreateMover(frame, "LustLockout", L["Lust Lockout"], { "CENTER", UIParent, "CENTER", 0, 120 })
end

function Module:SetupLockout()
	Build()

	local watcher = CreateFrame("Frame")
	watcher:RegisterUnitEvent("UNIT_AURA", "player")
	watcher:SetScript("OnEvent", Update)

	self:RegisterEvent("PLAYER_ENTERING_WORLD", Update)
	Update()
end
