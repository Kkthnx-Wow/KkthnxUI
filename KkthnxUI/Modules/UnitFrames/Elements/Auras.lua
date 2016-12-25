local K, C, L = unpack(select(2, ...))
if C.Unitframe.Enable ~= true then return end

-- Lua API
local floor = math.floor
local format = string.format
local unpack = unpack

-- Wow API
local CreateFrame = CreateFrame
local GetTime = GetTime
local UnitAura = UnitAura

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: GameTooltip, Aura_OnClick, DebuffTypeColor

local createAuraIcon
do
	local function UpdateTooltip(self)
		GameTooltip:SetUnitAura(self:GetParent().__owner.unit, self:GetID(), self.filter)
	end

	local function Aura_OnEnter(self)
		if(not self:IsVisible()) then return end

		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
		UpdateTooltip(self)
	end

	local function Aura_OnLeave()
		GameTooltip:Hide()
	end

	local function fixCooldownFlash(self, start, duration)
		if (self.duration == duration) and (self.starttime == start) then return; end
		self.starttime = start
		self.duration = duration
		self:_SetCooldown(start, duration)
	end

	function createAuraIcon( element, index )
		element.createdIcons = element.createdIcons + 1

		local button = CreateFrame("Button", element:GetName()..index, element)

		local icon = button:CreateTexture(nil, "BACKGROUND")
		icon:SetAllPoints(button)
		icon:SetTexCoord(.03, .97, .03, .97)
		button.icon = icon

		local overlay = button:CreateTexture(nil, "OVERLAY")
		overlay:SetTexture(C.Media.Border_White)
		overlay:SetPoint("TOPRIGHT", button.icon, 1.35, 1.35)
		overlay:SetPoint("BOTTOMLEFT", button.icon, -1.35, -1.35)
		button.overlay = overlay

		local shadow = button:CreateTexture(nil, "BACKGROUND")
		shadow:SetPoint("TOPLEFT", button.icon, "TOPLEFT", -5, 5)
		shadow:SetPoint("BOTTOMRIGHT", button.icon, "BOTTOMRIGHT", 5, -5)
		shadow:SetTexture(C.Media.Border_Shadow)
		shadow:SetVertexColor(0, 0, 0, 1)
		button.shadow = shadow

		local cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
		cd:SetFrameLevel(button:GetFrameLevel())
		cd:SetAllPoints(button)
		cd:SetReverse(true)
		cd:SetDrawEdge(true)
		if (element.__owner.onUpdateFrequency) then -- Fix the blinking cooldown on "invalid" units
			cd._SetCooldown = cd.SetCooldown
			cd.SetCooldown = fixCooldownFlash
		end
		button.cd = cd

		local count = K.SetFontString(button, C.Media.Font, 11, C.Media.Font_Style, "RIGHT")
		count:SetPoint("BOTTOMRIGHT", 2, 0)
		button.count = count

		local stealable = button:CreateTexture(nil, "OVERLAY")
		stealable:SetPoint("TOPLEFT", button.icon, "TOPLEFT", -5, 5)
		stealable:SetPoint("BOTTOMRIGHT", button.icon, "BOTTOMRIGHT", 5, -5)
		stealable:SetTexture(C.Media.Border_Shadow)
		stealable:SetVertexColor(1, 190/255, 82/255)
		stealable:SetDrawLayer("OVERLAY", 1)
		stealable:SetBlendMode("ADD")
		button.stealable = stealable

		if C.Unitframe.AuraTimer then
			button.cd.noCooldownCount = true
			if button.cd.SetHideCountdownNumbers then
				button.cd:SetHideCountdownNumbers(true)
			end
			button.timer = K.SetFontString(button.cd, C.Media.Font, C.Media.Font_Size, C.Media.Font_Style, "CENTER")
			button.timer:SetPoint("CENTER", button, "TOP", 0, 0)
		end

		button:EnableMouse(true)
		button:RegisterForClicks("LeftButtonUp")
		button:SetScript("OnClick", Aura_OnClick)
		button:SetScript("OnEnter", Aura_OnEnter)
		button:SetScript("OnLeave", Aura_OnLeave)

		-- if (element.largeAuraList) then -- i should really make a custom element by now THIS IS GETTING OUT OF HAND
		-- 	button._SetSize = button.SetSize
		-- 	button.SetSize = K.Noop
		-- end

		element[element.createdIcons] = button
		return button
	end
end

-- Update icon
local postUpdateIcon
do
	local MINUTE = 60
	local function GetTimes(remaining)
		if remaining < MINUTE then
			if remaining < 3 then -- this 2.5 usually
				return format("%.1f", remaining), 0.051
			end
			local mSecLeft = remaining % 1
			return floor(remaining + .5), mSecLeft > .5 and mSecLeft - .49 or mSecLeft + 0.51

		elseif remaining < 10*MINUTE then
			local secLeft = remaining % MINUTE
			if remaining < 90 then
				return format("%dm", floor(remaining/MINUTE + 0.5)), secLeft + .51
			end
			return format("%dm", floor(remaining/MINUTE + 0.5)), secLeft > 30 and secLeft - 29 or secLeft + 31

		else -- Hide timers longer than 10 minutes
			return "", (remaining % MINUTE) + 31
		end
	end

	local function UpdateAura( button, elapsed )
		if not (button.timeLeft) then return; end
		button.timeLeft = button.timeLeft - elapsed

		if button.nextupdate > 0 then
			button.nextupdate = button.nextupdate - elapsed
			return;
		end

		if (button.timeLeft <= 0) then
			button.timer:SetText("")
			button:SetScript("OnUpdate", nil)
			return;
		end

		local text
		text, button.nextupdate = GetTimes(button.timeLeft)
		button.timer:SetText(text)
	end

	local IS_PLAYER = {
		player = true,
		vehicle = true,
		pet = true,
	}

	function postUpdateIcon(element, unit, button, index, offset)
		local name, _, texture, count, dtype, duration, expirationTime, caster, canStealOrPurge, shouldConsolidate, spellID = UnitAura(unit, index, button.filter)
		button.overlay:Show()
		button.shadow:Show()

		if (button.isDebuff) then
			local color = DebuffTypeColor[dtype] or DebuffTypeColor["none"]
			button.overlay:SetVertexColor(color.r, color.g, color.b)
		else
			local color = C.Media.Border_Color
			button.overlay:SetVertexColor(color[1], color[2], color[3])
		end

		button.spellID = spellID

		if C.Unitframe.PlayerDebuffsOnly and unit == "target" and button.isDebuff and not button.isPlayer then
			button.icon:SetDesaturated(true)
		else
			button.icon:SetDesaturated(false)
		end

		if (button.cd.noCooldownCount) then
			if (duration and duration > 0) then
				if (not button.timer:IsShown()) then
					button.timer:Show()
				end
				local text
				button.timeLeft = expirationTime - GetTime()
				text, button.nextupdate = GetTimes(button.timeLeft)
				button.timer:SetText(text)
				button:SetScript("OnUpdate", UpdateAura)
			else
				if (button.timer:IsShown()) then
					button.timer:Hide()
				end
				button.timeLeft = 0
				button:SetScript("OnUpdate", nil)
			end
		end

		-- if (element.largeAuraList) then
		-- 	element.largeAuraList[offset] = IS_PLAYER[button.owner]
		-- end
	end
end

local function postUpdate(self, unit)
	self:GetParent().Health:ForceUpdate()
end

local GrowthTable = {
	TOPLEFT = {"RIGHT", "DOWN"},
	TOPRIGHT = {"LEFT", "DOWN"},
	BOTTOMLEFT = {"RIGHT", "UP"},
	BOTTOMRIGHT = {"LEFT", "UP"},
}

local function createElement(self, type, initialAnchor, size, gap, columns, rows)
	local element = CreateFrame("Frame", self:GetName()..type, self)
	element.showStealableBuffs = true
	element.initialAnchor = initialAnchor
	element["growth-x"] = GrowthTable[initialAnchor][1]
	element["growth-y"] = GrowthTable[initialAnchor][2]
	element.size = size
	element.spacing = gap
	element:SetWidth((size + gap) * columns)
	element:SetHeight((size + gap) * rows)

	element.CreateIcon = createAuraIcon
	element.PostUpdateIcon = postUpdateIcon
	element.PostUpdate = postUpdate
	element.parent = self

	return element
end

function K.AddBuffs(self, initialAnchor, size, gap, columns, rows)
	local Buffs = createElement(self, "Buffs", initialAnchor, size, gap, columns, rows)
	Buffs.num = columns * rows

	return Buffs
end

function K.AddDebuffs(self, initialAnchor, size, gap, columns, rows)
	local Debuffs = createElement(self, "Debuffs", initialAnchor, size, gap, columns, rows)
	Debuffs.num = columns * rows

	return Debuffs
end

function K.AddAuras(self, initialAnchor, size, gap, columns, rows)
	local Auras = createElement(self, "Auras", initialAnchor, size, gap, columns, rows)
	Auras.numDebuffs = floor(rows * columns / 2)
	Auras.numBuffs = floor(rows * columns / 2)

	Auras.gap = true
	Auras.PostUpdateGapIcon = function(element, unit, icon, visibleBuffs)
		icon.shadow:Hide()
	end

	return Auras
end