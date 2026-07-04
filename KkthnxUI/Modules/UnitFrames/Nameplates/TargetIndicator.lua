--[[-----------------------------------------------------------------------------
-- Target arrows, glow, and bounce animation on the current target's nameplate.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

local CreateFrame = CreateFrame
local math_rad = math.rad

function Module:UpdateTargetChange()
	local element = self.TargetIndicator
	local unit = self.unit

	if C["Nameplate"].TargetIndicator ~= 1 then
		local isTarget = K.UnitIsUnit(unit, "target") and not K.UnitIsUnit(unit, "player")
		element:SetShown(isTarget)

		local shouldPlayAnim = isTarget and not element.TopArrowAnim:IsPlaying()
		local shouldStopAnim = not isTarget and element.TopArrowAnim:IsPlaying()

		if shouldPlayAnim then
			element.TopArrowAnim:Play()
		elseif shouldStopAnim then
			element.TopArrowAnim:Stop()
		end
	end

	Module.UpdateThreatColor(self, nil, unit)
end

function Module:UpdateTargetIndicator()
	local style = C["Nameplate"].TargetIndicator
	local element = self.TargetIndicator
	local isNameOnly = self.plateType == "NameOnly"

	if style == 1 then
		element:Hide()
		return
	end

	local showTopArrow = style == 2 or style == 5
	local showRightArrow = style == 3 or style == 6
	local showGlow = (style == 4 or style == 5 or style == 6) and not isNameOnly
	local showNameGlow = (style == 4 or style == 5 or style == 6) and isNameOnly

	element.TopArrow:SetShown(showTopArrow)
	element.RightArrow:SetShown(showRightArrow)
	element.Glow:SetShown(showGlow)
	element.nameGlow:SetShown(showNameGlow)
	element:Show()
end

function Module:AddTargetIndicator(self)
	local targetIndicator = CreateFrame("Frame", nil, self)
	targetIndicator:SetAllPoints()
	targetIndicator:SetFrameLevel(0)
	targetIndicator:Hide()

	local function createArrow(parent, point, x, y, rotation)
		local arrow = parent:CreateTexture(nil, "BACKGROUND", nil, -5)
		arrow:SetSize(64, 64)
		arrow:SetTexture(C["Nameplate"].TargetIndicatorTexture)
		arrow:SetPoint(point, parent, point, x, y)
		if rotation then
			arrow:SetRotation(rotation)
		end
		return arrow
	end

	targetIndicator.TopArrow = createArrow(targetIndicator, "BOTTOM", 0, 40)
	local animGroup = targetIndicator.TopArrow:CreateAnimationGroup()
	animGroup:SetLooping("REPEAT")

	local anim1 = animGroup:CreateAnimation("Translation")
	anim1:SetOffset(0, -15)
	anim1:SetDuration(0.5)
	anim1:SetOrder(1)
	anim1:SetSmoothing("IN_OUT")

	local anim2 = animGroup:CreateAnimation("Translation")
	anim2:SetOffset(0, 15)
	anim2:SetDuration(0.5)
	anim2:SetOrder(2)
	anim2:SetSmoothing("IN_OUT")

	targetIndicator.TopArrowAnim = animGroup

	targetIndicator.RightArrow = createArrow(targetIndicator, "LEFT", 3, 0, math_rad(-90))

	targetIndicator.Glow = CreateFrame("Frame", nil, targetIndicator, "BackdropTemplate")
	targetIndicator.Glow:SetPoint("TOPLEFT", self.Health.backdrop, -2, 2)
	targetIndicator.Glow:SetPoint("BOTTOMRIGHT", self.Health.backdrop, 2, -2)
	targetIndicator.Glow:SetBackdrop({ edgeFile = C["Media"].Textures.GlowTexture, edgeSize = 4 })
	targetIndicator.Glow:SetBackdropBorderColor(unpack(C["Nameplate"].TargetIndicatorColor))
	targetIndicator.Glow:SetFrameLevel(0)

	targetIndicator.nameGlow = targetIndicator:CreateTexture(nil, "BACKGROUND", nil, -5)
	targetIndicator.nameGlow:SetSize(150, 80)
	targetIndicator.nameGlow:SetTexture("Interface\\GLUES\\Models\\UI_Draenei\\GenericGlow64")
	targetIndicator.nameGlow:SetVertexColor(102 / 255, 157 / 255, 255 / 255)
	targetIndicator.nameGlow:SetBlendMode("ADD")
	targetIndicator.nameGlow:SetPoint("CENTER", self, "BOTTOM")

	self.TargetIndicator = targetIndicator
	self:RegisterEvent("PLAYER_TARGET_CHANGED", Module.UpdateTargetChange, true)
	Module.UpdateTargetIndicator(self)
end
