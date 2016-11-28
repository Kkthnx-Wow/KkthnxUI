local K, C, L = select(2, ...):unpack()
if C.Unitframe.Enable ~= true then return end

local _, ns = ...
local config = ns.Config

local GetTime = GetTime
local floor, fmod = floor, math.fmod
local day, hour, minute = 86400, 3600, 60

local function ExactTime(time)
	return format("%.1f", time), (time * 100 - floor(time * 100))/100
end

local function IsMine(unit)
	if (unit == "player" or unit == "vehicle" or unit == "pet") then
		return true
	else
		return false
	end
end

ns.UpdateAuraTimer = function(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if (self.elapsed < 0.1) then
		return
	end

	self.elapsed = 0

	local timeLeft = self.expires - GetTime()
	if (timeLeft <= 0) then
		self.remaining:SetText(nil)
	else
		if (timeLeft <= 5 and IsMine(self.owner)) then
			self.remaining:SetText("|cffff0000"..ExactTime(timeLeft).."|r")
			if (not self.ignoreSize) then
				self.remaining:SetFont(C.Media.Font, 12, "THINOUTLINE")
			end
		else
			self.remaining:SetText(K.FormatTime(timeLeft))
			if (not self.ignoreSize) then
				self.remaining:SetFont(C.Media.Font, 10, "THINOUTLINE")
			end
		end
	end
end

ns.PostUpdateIcon = function(icons, unit, icon, index, offset)
	icon:SetAlpha(1)

	if (icon.isStealable) then
		if (icon.Shadow) then
			icon.Shadow:SetVertexColor(1, 1, 0, 1)
		end
	else
		if (icon.Shadow) then
			icon.Shadow:SetVertexColor(0, 0, 0, 1)
		end
	end

	local colorPlayerDebuffsOnly = true
	if (colorPlayerDebuffsOnly) then
		if (unit == "target") then
			if (icon.isDebuff) then
				if (not IsMine(icon.owner)) then
					icon.overlay:SetVertexColor(0.45, 0.45, 0.45)
					icon.icon:SetDesaturated(true)
					-- icon:SetAlpha(0.55)
				else
					icon.icon:SetDesaturated(false)
					icon:SetAlpha(1)
				end
			end
		end
	end

	if (icon.remaining) then
		if (unit == "target" and icon.isDebuff and not IsMine(icon.owner) and (not UnitIsFriend("player", unit) and UnitCanAttack(unit, "player") and not UnitPlayerControlled(unit)) and not config.units.target.showAllTimers ) then
			if (icon.remaining:IsShown()) then
				icon.remaining:Hide()
			end

			icon:SetScript("OnUpdate", nil)
		else
			local _, _, _, _, _, duration, expirationTime = UnitAura(unit, index, icon.filter)
			if (duration and duration > 0) then
				if (not icon.remaining:IsShown()) then
					icon.remaining:Show()
				end
			else
				if (icon.remaining:IsShown()) then
					icon.remaining:Hide()
				end
			end

			icon.duration = duration
			icon.expires = expirationTime
			icon:SetScript("OnUpdate", ns.UpdateAuraTimer)
		end
	end
end

ns.UpdateAuraIcons = function(auras, button)
	if (not button.Shadow) then
		local size = button:GetSize()

		button:SetFrameLevel(1)

		button.icon:SetTexCoord(.03, .97, .03, .97)
		button.icon:SetAllPoints(button)
		button.icon:SetSize(size, size)

		local overlay = button:CreateTexture(nil, "OVERLAY")
		button.overlay:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Border\\BorderWhite")
		button.overlay:SetTexCoord(0, 1, 0, 1)
		button.overlay:ClearAllPoints()
		button.overlay:SetOutside(button, 1.36, 1.36)

		button.count:SetFont(C.Media.Font, 11, "THINOUTLINE")
		button.count:SetShadowOffset(0, 0)
		button.count:ClearAllPoints()
		button.count:SetPoint("BOTTOMRIGHT", button.icon, 2, 0)

		if (C.Unitframe.DisableCooldown) then
			button.cd:SetReverse()
			button.cd:SetDrawEdge(true)
			button.cd:ClearAllPoints()
			button.cd:SetPoint("TOPRIGHT", button.icon, "TOPRIGHT", -1, -1)
			button.cd:SetPoint("BOTTOMLEFT", button.icon, "BOTTOMLEFT", 1, 1)
		else
			auras.disableCooldown = true
			-- button.cd.noOCC = true

			button.remaining = button:CreateFontString(nil, "OVERLAY")
			button.remaining:SetFont(C.Media.Font, 8, "THINOUTLINE")
			button.remaining:SetShadowOffset(0, 0)
			button.remaining:SetPoint("TOP", button.icon, 0, 2)
		end

		if (not button.Shadow) then
			button.Shadow = button:CreateTexture(nil, "BACKGROUND")
			button.Shadow:SetPoint("TOPLEFT", button.icon, "TOPLEFT", -5, 5)
			button.Shadow:SetPoint("BOTTOMRIGHT", button.icon, "BOTTOMRIGHT", 5, -5)
			button.Shadow:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Border\\BorderShadow")
			button.Shadow:SetVertexColor(0, 0, 0, 1)
		end

		if (button.stealable) then
			local stealable = button:CreateTexture(nil, "OVERLAY")
			stealable:SetPoint("TOPLEFT", -5, 5)
			stealable:SetPoint("BOTTOMRIGHT", 5, -5)
		end

		button.overlay.Hide = function(self)
			self:SetVertexColor(0.5, 0.5, 0.5, 1)
		end
	end
end