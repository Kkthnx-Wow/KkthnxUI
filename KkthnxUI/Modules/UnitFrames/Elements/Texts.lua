--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/UnitFrames/Elements/Texts.lua
	Purpose:
		Text on and around a unit: the name above the health bar, and the health
		and power values centred on their bars.

		Midnight note: health and power numbers can be secret, which rules out
		string.format and any arithmetic on them. So the values are not tags. They
		are driven from the bar's own PostUpdate straight into SetFormattedText,
		which is a C call that accepts secret arguments. Percentages come from
		UnitHealthPercent / UnitPowerPercent with the ScaleTo100 curve rather than
		cur / max, for the same reason.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("UnitFrames")
local Build = Module.Build

local IsSecret = K.IsSecret
local AbbreviateNumbers = AbbreviateNumbers
local UnitHealthPercent = UnitHealthPercent
local UnitPowerPercent = UnitPowerPercent
local UnitIsConnected = UnitIsConnected
local UnitIsDeadOrGhost = UnitIsDeadOrGhost

local SCALE_TO_100 = CurveConstants and CurveConstants.ScaleTo100

local function NewText(parent, size)
	local text = parent:CreateFontString(nil, "OVERLAY")
	K.SetFont(text, size, K.FontOutlineStyle())
	text:SetWordWrap(false)
	return text
end
Module.NewText = NewText

-- A centered label on a gradient toast strip that spans the anchor's width and
-- sits just above it. Shared by the name (over the health bar) and the level
-- (over the portrait) so both are laid out and sized identically. Returns the
-- font string, the strip is attached as text.BG.
--   self    the unit frame (owns the regions)
--   anchor  the frame the strip spans and sits above (health bar / portrait)
--   size    font size
--   yOffset gap between the anchor top and the label baseline
function Module.GradientLabel(self, anchor, size, yOffset)
	local text = NewText(self, size or 12)
	text:SetJustifyH("CENTER")
	text:SetPoint("BOTTOM", anchor, "TOP", 0, yOffset or 6)

	-- Our own gradient rather than the AftLevelup-ToastBG atlas, whose violet was
	-- baked into the art, so it matched nothing else and its colour and alpha could
	-- not be touched. Two mirrored halves give the same fade out to both edges.
	local shade = K.CreateTextShade(self, "BACKGROUND", -2)
	local height = (size or 12) + 6
	local bottom = (yOffset or 6) - 3

	-- Span the anchor width and sit above it at a fixed height. Sizing from the
	-- name fontstring instead (its TOP/BOTTOM) collapsed the strip to nothing on any
	-- frame whose name had not populated yet, so some party members showed no
	-- gradient while others did. A deterministic height keeps every frame identical.
	local holder = shade.Holder
	holder:SetPoint("LEFT", anchor, "LEFT", 0, 0)
	holder:SetPoint("RIGHT", anchor, "RIGHT", 0, 0)
	holder:SetPoint("BOTTOM", anchor, "TOP", 0, bottom)
	holder:SetHeight(height)

	shade:SetColor(K.Colors.accent[1], K.Colors.accent[2], K.Colors.accent[3], K.GradientAlpha.strip)
	shade:Show()
	-- The holder is what the upward stack anchors to, so hand that over rather than
	-- the shade table, which is not a region.
	text.BG = holder

	return text
end

-- ---------------------------------------------------------------------------
-- Name
-- ---------------------------------------------------------------------------

-- Name above the health bar. Pushed onto the upward stack so it always sits
-- directly on top of health with nothing overlapping it.
function Build.Name(self, size)
	-- Centered name on the gradient strip above the health bar.
	local name = Module.GradientLabel(self, self.Health or self, size or 12)
	-- The explicit |r closes the name colour so the AFK flag keeps its own grey.
	self:Tag(name, "[kkui:namecolor][kkui:name]|r[kkui:afkdnd]")
	self.Name = name
	-- Push the name's gradient strip onto the upward stack so anything above the
	-- frame (debuffs) sits above the gradient, not on top of it.
	self.__stackUp = name.BG or name
	return name
end

-- Name on the health bar itself. Group and companion frames use this: they are
-- laid out by a header or packed tight, so nothing may spill outside the frame.
function Build.NameCenter(self, size, yOffset, tag, rightPad)
	local name = NewText(self.Health, size or 11)
	-- LEFT plus RIGHT bounds the text to the bar so long names clip instead of
	-- bleeding into the neighbouring frame. It also centres it vertically, so a
	-- yOffset is all we need to share the bar with the health value. A rightPad
	-- left-aligns the name and reserves room on the right for a health value.
	name:SetJustifyH(rightPad and "LEFT" or "CENTER")
	name:SetPoint("LEFT", self.Health, "LEFT", 3, yOffset or 0)
	name:SetPoint("RIGHT", self.Health, "RIGHT", -(rightPad or 3), yOffset or 0)
	self:Tag(name, tag or "[kkui:namecolor][kkui:name]")
	self.Name = name
	return name
end

-- ---------------------------------------------------------------------------
-- Bar values
-- ---------------------------------------------------------------------------

local function UpdateHealthText(element, unit, cur)
	local text = element.__kkuiText
	if not text then
		return
	end

	if not UnitIsConnected(unit) then
		text:SetText(PLAYER_OFFLINE)
		return
	end
	if UnitIsDeadOrGhost(unit) then
		text:SetText(DEAD)
		return
	end

	local mode = C.Unitframe.HealthFormat
	if mode == "Current" then
		text:SetText(AbbreviateNumbers(cur))
	elseif mode == "Percent" then
		local perc = UnitHealthPercent(unit, true, SCALE_TO_100)
		-- Full health reads as just the value, no redundant 100%.
		if not IsSecret(perc) and perc >= 100 then
			text:SetText(AbbreviateNumbers(cur))
		else
			text:SetFormattedText("%d%%", perc)
		end
	else
		local perc = UnitHealthPercent(unit, true, SCALE_TO_100)
		if not IsSecret(perc) and perc >= 100 then
			text:SetText(AbbreviateNumbers(cur))
		else
			text:SetFormattedText("%s - %d%%", AbbreviateNumbers(cur), perc)
		end
	end
end

local function UpdatePowerText(element, unit, cur)
	local text = element.__kkuiText
	if not text then
		return
	end

	-- nil power type means "whatever the bar is showing", and unmodified false so
	-- the number matches the fill rather than the raw value.
	local mode = C.Unitframe.PowerFormat
	if mode == "Current" then
		text:SetText(AbbreviateNumbers(cur))
	elseif mode == "Percent" then
		text:SetFormattedText("%d%%", UnitPowerPercent(unit, nil, false, SCALE_TO_100))
	else
		text:SetFormattedText("%s  %d%%", AbbreviateNumbers(cur), UnitPowerPercent(unit, nil, false, SCALE_TO_100))
	end
end

-- Health value, centred on the health bar.
function Build.HealthText(self, size, yOffset, anchor)
	if C.Unitframe.HealthFormat == "None" then
		return
	end
	local text = NewText(self.Health, size or 12)
	if anchor == "RIGHT" then
		text:SetPoint("RIGHT", self.Health, "RIGHT", -3, yOffset or 0)
		text:SetJustifyH("RIGHT")
	else
		text:SetPoint("CENTER", self.Health, "CENTER", 0, yOffset or 0)
		text:SetJustifyH("CENTER")
	end

	self.Health.__kkuiText = text
	self.Health.PostUpdate = UpdateHealthText
	self.HealthValue = text
	return text
end

-- Power value, centred on the power bar.
function Build.PowerText(self, size)
	if not self.Power or C.Unitframe.PowerFormat == "None" then
		return
	end
	local text = NewText(self.Power, size or 11)
	text:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
	text:SetJustifyH("CENTER")

	self.Power.__kkuiText = text
	self.Power.PostUpdate = UpdatePowerText
	self.PowerValue = text
	return text
end
