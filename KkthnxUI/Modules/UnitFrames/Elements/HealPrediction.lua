--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Shared incoming heal / absorb bars for unit frames and nameplates.
-- - Design: oUF HealthPrediction element with canonical widget keys + legacy aliases.
-- - Absorbs: Ellesmere dual-clip (curClip / missClip) for secret-safe shield rendering.
-- - Events: UNIT_HEAL_PREDICTION, UNIT_ABSORB_AMOUNT_CHANGED, etc. via oUF.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

local CreateFrame = _G.CreateFrame

local function addShieldOverlay(bar)
	local tex = bar:CreateTexture(nil, "ARTWORK", nil, 1)
	tex:SetAllPoints(bar:GetStatusBarTexture())
	tex:SetTexture("Interface\\RaidFrame\\Shield-Overlay")
	tex:SetHorizTile(true)
	tex:SetVertTile(true)
end

local function maskStatusBarTexture(bar, mask)
	if not bar or not mask then
		return
	end
	local fill = bar:GetStatusBarTexture()
	if fill and fill.AddMaskTexture then
		fill:AddMaskTexture(mask)
	end
end

local function updateAbsorbClipAnchors(health, curClip, missClip)
	local hpTex = health:GetStatusBarTexture()
	if not hpTex or not curClip or not missClip then
		return
	end

	curClip:ClearAllPoints()
	curClip:SetPoint("TOPLEFT", health, "TOPLEFT", 0, 0)
	curClip:SetPoint("BOTTOMRIGHT", hpTex, "BOTTOMRIGHT", 0, 0)

	missClip:ClearAllPoints()
	missClip:SetPoint("TOPLEFT", hpTex, "TOPRIGHT", -1, 0)
	missClip:SetPoint("BOTTOMRIGHT", health, "BOTTOMRIGHT", 0, 0)
end

local function updateHealClipAnchors(health, healClip)
	local hpTex = health:GetStatusBarTexture()
	if not hpTex or not healClip then
		return
	end

	healClip:ClearAllPoints()
	healClip:SetPoint("TOPLEFT", health, "TOPLEFT", 0, 0)
	healClip:SetPoint("BOTTOMRIGHT", hpTex, "BOTTOMRIGHT", 0, 0)
end

local function syncDualAbsorbBars(element)
	local back = element.damageAbsorb
	local forward = element.damageAbsorbForward
	if not (back and forward) then
		return
	end

	local minVal, maxVal = back:GetMinMaxValues()
	forward:SetMinMaxValues(minVal, maxVal)
	forward:SetValue(back:GetValue())

	if back:IsShown() then
		forward:Show()
	else
		forward:Hide()
	end
end

local function updateAbsorbStrips(element, unit)
	if not element.absorbStrip or not element.values then
		return
	end

	local maxHealth = _G.UnitHealthMax(unit)
	if not maxHealth then
		return
	end

	local shieldAmt = select(1, element.values:GetDamageAbsorbs())
	element.absorbStrip:SetMinMaxValues(0, maxHealth)
	element.absorbStrip:SetValue(shieldAmt)
	if element.damageAbsorb:IsShown() then
		element.absorbStrip:Show()
	else
		element.absorbStrip:Hide()
	end

	local healStrip = element.healAbsorbStrip
	if healStrip then
		local healAmt = select(1, element.values:GetHealAbsorbs())
		healStrip:SetMinMaxValues(0, maxHealth)
		healStrip:SetValue(healAmt)
		if element.healAbsorb:IsShown() then
			healStrip:Show()
		else
			healStrip:Hide()
		end
	end
end

local function elementPreUpdate(element, unit)
	local owner = element.__owner
	local health = owner and owner.Health
	if health and element.curClip and element.missClip then
		updateAbsorbClipAnchors(health, element.curClip, element.missClip)
		local barWidth = health:GetWidth()
		if barWidth and barWidth > 0 then
			element.damageAbsorb:SetWidth(barWidth)
			if element.damageAbsorbForward then
				element.damageAbsorbForward:SetWidth(barWidth)
			end
		end
	end
	if health and element.healClip then
		updateHealClipAnchors(health, element.healClip)
		local barWidth = health:GetWidth()
		if barWidth and barWidth > 0 and element.healAbsorb then
			element.healAbsorb:SetWidth(barWidth)
		end
	end
end

local function elementPostUpdate(element, unit)
	syncDualAbsorbBars(element)
	updateAbsorbStrips(element, unit)
	Module.PostUpdatePrediction(element, unit)
end

-- REASON: One factory for all KKUI heal-prediction layouts (player, party, raid, plates).
function Module:CreateHealPrediction(frame, opts)
	opts = opts or {}
	local health = frame.Health
	if not health then
		return
	end

	local absorbMask = health:CreateMaskTexture()
	absorbMask:SetAllPoints(health)
	absorbMask:SetTexture(C["Media"].Textures.White8x8Texture or "Interface\\Buttons\\WHITE8X8")

	local container = CreateFrame("Frame", nil, frame)
	container:SetAllPoints(health)
	local frameLevel = container:GetFrameLevel()
	local normalTexture = opts.texture or K.GetTexture(C["General"].Texture)
	local barWidth = health:GetWidth() or 100
	local barHeight = health:GetHeight() or 10
	local hpLevel = health:GetFrameLevel()

	local myBar = CreateFrame("StatusBar", nil, container)
	myBar:SetPoint("TOP")
	myBar:SetPoint("BOTTOM")
	myBar:SetPoint("LEFT", health:GetStatusBarTexture(), "RIGHT")
	myBar:SetStatusBarTexture(normalTexture)
	myBar:SetStatusBarColor(0, 1, 0.5, 0.5)
	myBar:SetFrameLevel(frameLevel)
	myBar:Hide()

	local otherBar = CreateFrame("StatusBar", nil, container)
	otherBar:SetPoint("TOP")
	otherBar:SetPoint("BOTTOM")
	otherBar:SetPoint("LEFT", myBar:GetStatusBarTexture(), "RIGHT")
	otherBar:SetStatusBarTexture(normalTexture)
	otherBar:SetStatusBarColor(0, 1, 0, 0.5)
	otherBar:SetFrameLevel(frameLevel)
	otherBar:Hide()

	-- Dual-clip damage absorb (Ellesmere pattern): forward into missing HP, backfill into filled HP.
	local curClip = CreateFrame("Frame", nil, health)
	curClip:SetClipsChildren(true)

	local missClip = CreateFrame("Frame", nil, health)
	missClip:SetClipsChildren(true)
	updateAbsorbClipAnchors(health, curClip, missClip)

	local backfillBar = CreateFrame("StatusBar", nil, curClip)
	backfillBar:SetStatusBarTexture(normalTexture)
	backfillBar:SetStatusBarColor(0.66, 1, 1)
	backfillBar:SetReverseFill(true)
	backfillBar:SetPoint("TOPRIGHT", health, "TOPRIGHT", 0, 0)
	backfillBar:SetPoint("BOTTOMRIGHT", health, "BOTTOMRIGHT", 0, 0)
	backfillBar:SetWidth(barWidth)
	backfillBar:SetHeight(barHeight)
	backfillBar:SetFrameLevel(hpLevel + 1)
	backfillBar:SetAlpha(0.5)
	backfillBar:Hide()
	addShieldOverlay(backfillBar)
	maskStatusBarTexture(backfillBar, absorbMask)

	local forwardBar = CreateFrame("StatusBar", nil, missClip)
	forwardBar:SetStatusBarTexture(normalTexture)
	forwardBar:SetStatusBarColor(0.66, 1, 1)
	forwardBar:SetPoint("TOPLEFT", health:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
	forwardBar:SetPoint("BOTTOMLEFT", health:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
	forwardBar:SetWidth(barWidth)
	forwardBar:SetHeight(barHeight)
	forwardBar:SetFrameLevel(hpLevel + 1)
	forwardBar:SetAlpha(0.5)
	forwardBar:Hide()
	addShieldOverlay(forwardBar)
	maskStatusBarTexture(forwardBar, absorbMask)

	local overAbsorbBar = CreateFrame("StatusBar", nil, container)
	overAbsorbBar:SetAllPoints()
	overAbsorbBar:SetStatusBarTexture(normalTexture)
	overAbsorbBar:SetStatusBarColor(0.66, 1, 1)
	overAbsorbBar:SetFrameLevel(frameLevel)
	overAbsorbBar:SetAlpha(0.35)
	overAbsorbBar:Hide()
	addShieldOverlay(overAbsorbBar)
	maskStatusBarTexture(overAbsorbBar, absorbMask)

	-- Heal absorb: own clip frame (Ellesmere) so placement is independent of shield clips.
	local healClip = CreateFrame("Frame", nil, health)
	healClip:SetClipsChildren(true)
	updateHealClipAnchors(health, healClip)

	local healAbsorbBar = CreateFrame("StatusBar", nil, healClip)
	healAbsorbBar:SetStatusBarTexture(normalTexture)
	healAbsorbBar:SetStatusBarColor(1, 0, 0.5)
	healAbsorbBar:SetReverseFill(true)
	healAbsorbBar:SetPoint("TOPRIGHT", health, "TOPRIGHT", 0, 0)
	healAbsorbBar:SetPoint("BOTTOMRIGHT", health, "BOTTOMRIGHT", 0, 0)
	healAbsorbBar:SetWidth(barWidth)
	healAbsorbBar:SetHeight(barHeight)
	healAbsorbBar:SetFrameLevel(hpLevel + 1)
	healAbsorbBar:SetAlpha(0.35)
	healAbsorbBar:Hide()
	addShieldOverlay(healAbsorbBar)
	maskStatusBarTexture(healAbsorbBar, absorbMask)

	local absorbStrip
	local healAbsorbStrip
	if opts.absorbStrips then
		local stripHeight = opts.stripHeight or 3

		absorbStrip = CreateFrame("StatusBar", nil, frame)
		absorbStrip:SetHeight(stripHeight)
		absorbStrip:SetPoint("BOTTOMLEFT", health, "TOPLEFT", 0, 0)
		absorbStrip:SetPoint("BOTTOMRIGHT", health, "TOPRIGHT", 0, 0)
		absorbStrip:SetReverseFill(true)
		absorbStrip:SetStatusBarTexture(normalTexture)
		absorbStrip:SetStatusBarColor(0.66, 1, 1, 0.9)
		absorbStrip:SetFrameLevel(hpLevel + 3)
		absorbStrip:Hide()

		healAbsorbStrip = CreateFrame("StatusBar", nil, frame)
		healAbsorbStrip:SetHeight(stripHeight)
		healAbsorbStrip:SetPoint("BOTTOMLEFT", absorbStrip, "TOPLEFT", 0, 0)
		healAbsorbStrip:SetPoint("BOTTOMRIGHT", absorbStrip, "TOPRIGHT", 0, 0)
		healAbsorbStrip:SetReverseFill(true)
		healAbsorbStrip:SetStatusBarTexture(normalTexture)
		healAbsorbStrip:SetStatusBarColor(0.78, 0.11, 0.11, 0.9)
		healAbsorbStrip:SetFrameLevel(hpLevel + 3)
		healAbsorbStrip:Hide()
	end

	backfillBar:HookScript("OnHide", function()
		forwardBar:Hide()
		healAbsorbBar:Hide()
	end)

	local overAbsorb = health:CreateTexture(nil, "OVERLAY", nil, 2)
	overAbsorb:SetWidth(8)
	overAbsorb:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
	overAbsorb:SetBlendMode("ADD")
	overAbsorb:SetPoint("TOPLEFT", health, "TOPRIGHT", -5, 0)
	overAbsorb:SetPoint("BOTTOMLEFT", health, "BOTTOMRIGHT", -5, 0)
	overAbsorb:Hide()

	local overHealAbsorb = container:CreateTexture(nil, "OVERLAY")
	overHealAbsorb:SetWidth(15)
	overHealAbsorb:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb")
	overHealAbsorb:SetBlendMode("ADD")
	overHealAbsorb:SetPoint("TOPRIGHT", health, "TOPLEFT", 5, 2)
	overHealAbsorb:SetPoint("BOTTOMRIGHT", health, "BOTTOMLEFT", 5, -2)
	overHealAbsorb:Hide()

	local element = {
		healingPlayer = myBar,
		healingOther = otherBar,
		damageAbsorb = backfillBar,
		damageAbsorbForward = forwardBar,
		healAbsorb = healAbsorbBar,
		overDamageAbsorbIndicator = overAbsorb,
		overHealAbsorbIndicator = overHealAbsorb,
		overAbsorbBar = overAbsorbBar,
		incomingHealOverflow = opts.incomingHealOverflow or 1,
		PreUpdate = elementPreUpdate,
		PostUpdate = elementPostUpdate,
		absorbMask = absorbMask,
		curClip = curClip,
		missClip = missClip,
		healClip = healClip,
		absorbStrip = absorbStrip,
		healAbsorbStrip = healAbsorbStrip,
		-- Legacy aliases for texture/smooth refresh paths in Core.lua.
		myBar = myBar,
		otherBar = otherBar,
		absorbBar = backfillBar,
		healAbsorbBar = healAbsorbBar,
		overAbsorb = overAbsorb,
		overHealAbsorb = overHealAbsorb,
	}

	if _G.Enum and _G.Enum.UnitDamageAbsorbClampMode then
		element.damageAbsorbClampMode = _G.Enum.UnitDamageAbsorbClampMode.MaximumHealth
	end

	frame.HealthPrediction = element
	frame.predicFrame = container
	return element
end
