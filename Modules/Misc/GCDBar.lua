--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Misc/GCDBar.lua
	Purpose:
		A bar tracking the global cooldown, with the icon of the spell that
		started it.

		The fill is handed to the engine. C_Spell.GetSpellCooldownDuration returns
		a duration object, and StatusBar:SetTimerDuration renders it in C from
		there, so the bar animates at full framerate with no Lua running per frame
		and nothing to poll. It also never reads the value, so a secret cooldown
		cannot break it.

		It hides between cooldowns. The duration object reports how long is left,
		so the hide is scheduled once at that exact moment rather than polled for.
		Off by default.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local Module = K:NewModule("GCDBar")

local CreateFrame = CreateFrame
local UnitAffectingCombat = UnitAffectingCombat
local C_Spell = C_Spell
local C_Timer = C_Timer

-- The hidden spell the client hangs the global cooldown on.
local GCD_SPELL = 61304

local bar, icon
local combatAlpha, restAlpha
local hideTimer

local function HideBar()
	hideTimer = nil
	bar:Hide()
end

-- refreshOnly means "update a bar that is already up, but do not open one".
-- Cooldown chatter fires constantly and knows nothing about which spell caused
-- it, so letting it open the bar flashes an empty icon box.
local function Arm(refreshOnly)
	-- Always take a fresh object. A stored handle goes stale when a cooldown is
	-- reset, and re-arming it plays the original countdown out again instead of
	-- the new one.
	local duration = C_Spell.GetSpellCooldownDuration(GCD_SPELL)
	if not duration or not duration:IsActive() then
		return
	end
	if refreshOnly and not bar:IsShown() then
		return
	end

	bar:SetTimerDuration(duration, Enum.StatusBarInterpolation.Immediate, bar.direction)
	bar:Show()

	-- Hide at the moment the cooldown ends. The duration object knows how long is
	-- left, so this is one shot at a known time rather than something polled for.
	-- Cancelling the old handle is what keeps a finished cooldown from hiding the
	-- one that replaced it, and it costs no closure per cast.
	if hideTimer then
		hideTimer:Cancel()
	end
	if duration:HasSecretValues() then
		-- Remaining time is unreadable, so fall back to the cooldown update below.
		hideTimer = nil
		return
	end
	hideTimer = C_Timer.NewTimer(duration:GetRemainingDuration(), HideBar)
end

local function SetAlpha()
	bar:SetAlpha(UnitAffectingCombat("player") and combatAlpha or restAlpha)
end

-- The spell that just went off owns the global cooldown that follows it, so read
-- the icon here rather than guessing from the cooldown alone.
function Module:UNIT_SPELLCAST_SUCCEEDED(_, unit, _, spellID)
	if unit ~= "player" then
		return
	end
	if icon and spellID then
		-- GetSpellTexture returns nothing when the spell is unknown, and passing
		-- that straight through would blank the icon instead of leaving the last
		-- one up.
		local texture = C_Spell.GetSpellTexture(spellID)
		if texture then
			icon:SetTexture(texture)
			icon:Show()
		end
	end
	Arm()
end

-- Keeps an open bar in step with a cooldown that changed under it, and closes it
-- when the remaining time could not be read.
function Module:SPELL_UPDATE_COOLDOWN()
	Arm(true)
	-- Also the safety net for a cooldown whose remaining time could not be read,
	-- since this fires again once it has run out.
	if not hideTimer and bar:IsShown() then
		local duration = C_Spell.GetSpellCooldownDuration(GCD_SPELL)
		if not duration or not duration:IsActive() then
			bar:Hide()
		end
	end
end

function Module:PLAYER_REGEN_DISABLED()
	SetAlpha()
end

function Module:PLAYER_REGEN_ENABLED()
	SetAlpha()
end

function Module:OnEnable()
	local db = C.Misc
	if not db.GCDBar then
		return
	end

	combatAlpha = db.GCDBarAlpha
	restAlpha = db.GCDBarRestAlpha

	local width, height = db.GCDBarWidth, db.GCDBarHeight
	local showIcon = db.GCDBarIcon

	bar = CreateFrame("StatusBar", "KKUI_GCDBar", UIParent)
	bar:SetSize(width, height)
	bar:SetPoint("CENTER", UIParent, "CENTER", 0, -215)
	bar:SetStatusBarTexture(K.GetTexture(C.Unitframe.Texture))
	bar:SetMinMaxValues(0, 1)
	bar:SetValue(0)
	bar:Hide()
	K.CreateBorder(bar)

	-- Drain reads better than fill for a cooldown, but both are one enum apart.
	bar.direction = db.GCDBarDrain and Enum.StatusBarTimerDirection.RemainingTime or Enum.StatusBarTimerDirection.ElapsedTime

	local bg = bar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetColorTexture(K.Colors.voidDark[1], K.Colors.voidDark[2], K.Colors.voidDark[3], 0.7)

	if db.GCDBarClassColor then
		bar:SetStatusBarColor(K.ClassColor.r, K.ClassColor.g, K.ClassColor.b)
	else
		local custom = db.GCDBarColor
		bar:SetStatusBarColor(custom[1], custom[2], custom[3])
	end

	if showIcon then
		-- The icon carries its own size rather than matching the bar. A GCD bar is
		-- typically a thin strip, and an icon that thin is unreadable.
		local holder = CreateFrame("Frame", nil, bar)
		local iconSize = db.GCDBarIconSize
		holder:SetSize(iconSize, iconSize)
		holder:SetPoint("RIGHT", bar, "LEFT", -6, 0)
		K.CreateBorder(holder)

		icon = holder:CreateTexture(nil, "ARTWORK")
		icon:SetPoint("TOPLEFT", holder, "TOPLEFT", 1, -1)
		icon:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", -1, 1)
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		-- Nothing to show until the first cast names a spell.
		icon:Hide()
		bar.Holder = holder
	end

	K.CreateMover(bar, "GCDBar", L["GCD Bar"], { "CENTER", UIParent, "CENTER", 0, -215 }, width, height)

	SetAlpha()

	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN", "SPELL_UPDATE_COOLDOWN")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "PLAYER_REGEN_ENABLED")
end
