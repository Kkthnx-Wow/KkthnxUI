if select(4, GetAddOnInfo("oUF_CombatFeedback")) then
	DisableAddOn("oUF_CombatFeedback")
end

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "CombatText element requires oUF")

local si = AbbreviateLargeNumbers
local L = CombatFeedbackText
local AMOUNT_MINUS, AMOUNT_PLUS = "-%s", "+%s"

local colors = {
	DEFAULT = { 1, 1, 1 },
	WOUND = { 1, 1, 0 },		-- no separate colors for CRITICAL, CRUSHING, GLANCING
	HEAL = { 0.2, 1, 0.2 },		-- no separate color for CRITICAL
	ENERGIZE = { 0.41, 0.8, 0.94 },	-- no separate color for CRITICAL
	ABSORB = { 0.8, 0.8, 0.8 },
	BLOCK = { 0.8, 0.8, 0.8 },
	DEFLECT = { 0.8, 0.8, 0.8 },
	DODGE = { 0.8, 0.8, 0.8 },
	EVADE = { 1, 1, 1 },
	IMMUNE = { 1, 1, 1 },
	INTERRUPT = { 1, 1, 0 },
	MISS = { 0.8, 0.8, 0.8 },
	PARRY = { 0.8, 0.8, 0.8 },
	RELFECT = { 1, 1, 1 },
	RESIST = { 0.8, 0.8, 0.8 },
}
oUF.colors.combatfeedback = colors

local active = {}

local updater = CreateFrame("Frame")
updater:Hide()

local next, pairs, GetTime = next, pairs, GetTime
updater:SetScript("OnUpdate", function(self)
	if not next(active) then
		self:Hide()
	end

	local fadeInTime = COMBATFEEDBACK_FADEINTIME
	local holdTime = COMBATFEEDBACK_HOLDTIME
	local fadeOutTime = COMBATFEEDBACK_FADEOUTTIME

	for element, startTime in pairs(active) do
		local elapsedTime = GetTime() - startTime
		local maxAlpha = element.maxAlpha
		if elapsedTime < fadeInTime then
			element:SetAlpha(elapsedTime / fadeInTime * maxAlpha)
		elseif elapsedTime < (fadeInTime + holdTime) then
			element:SetAlpha(1 * maxAlpha)
		elseif elapsedTime < (fadeInTime + holdTime + fadeOutTime) then
			element:SetAlpha(maxAlpha - ((elapsedTime - holdTime - fadeInTime) / fadeOutTime * maxAlpha))
		else
			element:Hide()
			active[element] = nil
		end
	end
end)

local Update = function(self, event, unit, combatEvent, flags, amount, school)
	if not combatEvent or unit ~= self.unit then return end

	if combatEvent == "WOUND" and amount < 1 then
		combatEvent = flags
	end

	local element = self.CombatText
	if element.ignore[combatEvent] then return end

	local color = colors[combatEvent] or colors.DEFAULT
	local text, text2 = L[combatEvent]

	local size = element.baseSize
	if not size then
		local _, baseSize = element:GetFont()
		element.baseSize = baseSize
		size = baseSize
	end

	if combatEvent == "WOUND" and amount > 0 then
		text, text2 = AMOUNT_MINUS, si(amount)
		if flags == "CRITICAL" or flags == "CRUSHING" then
			size = size * 1.25
		elseif flags == "GLANCING" then
			size = size * 0.8
		end
		if school == SCHOOL_MASK_PHYSICAL then
			color = colors.DEFAULT
		end
	elseif combatEvent == "HEAL" then
		text, text2 = AMOUNT_PLUS, si(amount)
		if flags == "CRITICAL" then
			size = size * 1.25
		end
	elseif combatEvent == "ENERGIZE" then
		text = si(amount)
		if flags == "CRITICAL" then
			size = size * 1.25
		end
	else
		size = size * 0.8
	end

	if text then
		local font, _, flags = element:GetFont()
		element:SetFont(font, size, flags)
		element:SetFormattedText(text, text2)
		element:SetTextColor(color[1], color[2], color[3])
		element:SetAlpha(0)
		element:Show()
		active[element] = GetTime()
		updater:Show()
	end
end

local Enable = function(self)
	local element = self.CombatText
	if not element then return end

	-- Can't upvalue in main chunk due to load order.
	-- Remove this if using outside of oUF Phanx.
	if ns.si then
		si = ns.si
	end

	element.__owner = self
	element.ForceUpdate = Update

	if not element:GetFont() then
		element:SetFontObject("GameFontHighlightMedium")
	end

	element.ignore = element.ignore or {}
	element.maxAlpha = element.maxAlpha or 0.75

	self:RegisterEvent("UNIT_COMBAT", Update)
	return true
end

local Disable = function(self)
	local element = self.CombatText
	if not element then return end

	self:UnregisterEvent("UNIT_COMBAT", Update)
	element:Hide()
	active[element] = nil
end

oUF:AddElement("CombatText", Update, Enable, Disable)