--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Displays an animated combat notification when entering/leaving combat.
-- - Design: Creates a frame with text and background texture that slides in with scaling animations on combat state change.
-- - Animation Phases: Slide-in, bounce scaling, hold, and slide-out with alpha fade.
-- - Events: PLAYER_REGEN_ENABLED, PLAYER_REGEN_DISABLED
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Miscellaneous")

-- PERF: Localize global functions and environment for faster lookups.
local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent

-- SG: Combat Animation Configuration
local COMBAT_ANIMATION_CONFIG = {
	slideInDistance = 350,
	nudgeDistance = -40,
	slideOutDistance = 480,
	yOffset = 150,
	minScale = 0.1,
	maxScale = 1.5,
	slideInDuration = 0.3,
	bounceDuration = 0.15,
	holdDuration = 0.8,
	nudgeDuration = 0.2,
	slideOutDuration = 0.5,
	textSize = 32,
	backgroundWidth = 150,
	backgroundHeight = 30,
	backgroundAlpha = 0.8,
}

-- REASON: Creates and configures a translation animation.
local function createTranslationAnimation(animGroup, order, offsetX, offsetY, duration, smoothing, delay)
	local translation = animGroup:CreateAnimation("Translation")
	translation:SetOffset(offsetX, offsetY)
	translation:SetDuration(duration)
	translation:SetOrder(order)
	if smoothing then
		translation:SetSmoothing(smoothing)
	end
	if delay then
		translation:SetStartDelay(delay)
	end
	return translation
end

-- REASON: Creates and configures an alpha animation.
local function createAlphaAnimation(animGroup, order, startAlpha, endAlpha, duration, delay)
	local alpha = animGroup:CreateAnimation("Alpha")
	alpha:SetFromAlpha(startAlpha)
	alpha:SetToAlpha(endAlpha)
	alpha:SetDuration(duration)
	alpha:SetOrder(order)
	if delay then
		alpha:SetStartDelay(delay)
	end
	return alpha
end

-- REASON: Creates and configures a scale animation.
local function createScaleAnimation(animGroup, order, startScaleX, startScaleY, endScaleX, endScaleY, duration, smoothing, delay)
	local scale = animGroup:CreateAnimation("Scale")
	scale:SetScaleFrom(startScaleX, startScaleY)
	scale:SetScaleTo(endScaleX, endScaleY)
	scale:SetDuration(duration)
	scale:SetOrder(order)
	scale:SetOrigin("CENTER", 0, 0)
	if smoothing then
		scale:SetSmoothing(smoothing)
	end
	if delay then
		scale:SetStartDelay(delay)
	end
	return scale
end

-- REASON: Sets up animation sequence for combat notification with four distinct phases.
local function setupAnimationSequence(animationGroup, config)
	-- Phase 1: Entrance (slide in from left + fade in + scale up)
	createTranslationAnimation(animationGroup, 1, config.slideInDistance, 0, config.slideInDuration, "IN")
	createAlphaAnimation(animationGroup, 1, 0, 1, config.slideInDuration)
	createScaleAnimation(animationGroup, 1, config.minScale, config.minScale, config.maxScale, config.maxScale, config.slideInDuration, "IN")

	-- Phase 2: Bounce (scale back to normal)
	createScaleAnimation(animationGroup, 2, config.maxScale, config.maxScale, 1.0, 1.0, config.bounceDuration, "OUT")

	-- Phase 3: Charging (nudge left with hold delay)
	createTranslationAnimation(animationGroup, 3, config.nudgeDistance, 0, config.nudgeDuration, nil, config.holdDuration)

	-- Phase 4: Exit (slide right + fade out + scale down)
	local totalExitDistance = -config.nudgeDistance + config.slideOutDistance
	createTranslationAnimation(animationGroup, 4, totalExitDistance, 0, config.slideOutDuration)
	createAlphaAnimation(animationGroup, 4, 1, 0, config.slideOutDuration)
	createScaleAnimation(animationGroup, 4, 1.0, 1.0, config.minScale, config.minScale, config.slideOutDuration)
end

-- REASON: Updates the visual state based on combat state (entering or leaving combat).
local function updateCombatNotification(frame, text, background, event)
	if event == "PLAYER_REGEN_DISABLED" then
		text:SetText(_G.ENTERING_COMBAT)
		text:SetTextColor(1, 0.1, 0.1)
		background:SetVertexColor(1, 0.1, 0.1, COMBAT_ANIMATION_CONFIG.backgroundAlpha)
	else
		text:SetText(_G.LEAVING_COMBAT)
		text:SetTextColor(0.1, 1, 0.1)
		background:SetVertexColor(0.1, 1, 0.1, COMBAT_ANIMATION_CONFIG.backgroundAlpha)
	end
end

-- Combat Animation
function Module:CreateCombatAnimation()
	if not C["Misc"].CombatAnimation then
		return
	end

	local config = COMBAT_ANIMATION_CONFIG

	-- Create main frame
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetSize(1, 1)
	frame:SetPoint("CENTER", -config.slideInDistance, config.yOffset)
	frame:Hide()

	-- Create text display
	local text = K.CreateFontString(frame, config.textSize, "")
	text:ClearAllPoints()
	text:SetPoint("CENTER")

	-- Create background texture
	local background = frame:CreateTexture(nil, "ARTWORK")
	background:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
	background:SetTexCoord(0, 0.66, 0, 0.31)
	background:SetPoint("BOTTOM", 0, -20)
	background:SetSize(config.backgroundWidth, config.backgroundHeight)

	-- Create animation group
	local animationGroup = frame:CreateAnimationGroup()
	setupAnimationSequence(animationGroup, config)

	-- Set animation cleanup on completion
	animationGroup:SetScript("OnFinished", function()
		frame:Hide()
	end)

	-- REASON: Handles combat state changes and triggers animation sequence.
	local function handleCombatStateChange(event)
		updateCombatNotification(frame, text, background, event)
		animationGroup:Stop()
		frame:Show()
		animationGroup:Play()
	end

	-- Register for combat events
	K:RegisterEvent("PLAYER_REGEN_ENABLED", handleCombatStateChange)
	K:RegisterEvent("PLAYER_REGEN_DISABLED", handleCombatStateChange)
end

Module:RegisterMisc("CombatAnimation", Module.CreateCombatAnimation)
