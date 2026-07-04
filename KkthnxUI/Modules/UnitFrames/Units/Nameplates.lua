--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Nameplate oUF style (UpdateColor + CreatePlates). Submodules in Nameplates/.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

-- Lua / WoW API (UpdateColor + CreatePlates only)
local CreateFrame = CreateFrame
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitHealthPercent = UnitHealthPercent
local UnitIsConnected = UnitIsConnected
local UnitIsTapDenied = UnitIsTapDenied
local UnitPlayerControlled = UnitPlayerControlled
local UnitSelectionType = UnitSelectionType

local IsSecret = K.IsSecret
local NP = Module.NP

-- ---------------------------------------------------------------------------
-- Unit Coloring
-- ---------------------------------------------------------------------------
function Module:UpdateColor(_, unit)
	-- REASON: Early exit for invalid units or mismatching frame ownership.
	if not unit or self.unit ~= unit then
		return
	end

	local element = self.Health
	local isCustomUnit = self.isCustomUnit
	local isPlayer = self.isPlayer
	local isFriendly = self.isFriendly
	local isOffTank, status = Module:CheckThreatStatus(unit)

	local health = UnitHealth(unit)
	local healthMax = UnitHealthMax(unit)
	if not health or not healthMax then
		return
	end

	local executeRatio = C["Nameplate"].ExecuteRatio
	local useExecuteColor = false
	-- SECRET (12.0): UnitHealth/UnitHealthMax can be secret while target changes
	-- run through a tainted secure path. Execute coloring is logic, not display
	-- routing, so skip it when we cannot legally inspect health values.
	if not IsSecret(health) and not IsSecret(healthMax) and executeRatio > 0 then
		local healthPerc = healthMax > 0 and (health / healthMax) * 100 or 100
		useExecuteColor = not isFriendly and healthPerc <= executeRatio
	end
	local r, g, b

	-- REASON: Style filters (custom units, priority NPCs, target coloring) have high priority.
	-- If a filter applies, we skip standard coloring to avoid overrides.
	if Module.ApplyStyleFilter(self, unit) then
		Module.UpdateThreatIndicator(self, status, isCustomUnit)
	else
		-- REASON: Priority chain for standard unit coloring, similar to ElvUI's cleaner logic.
		if not UnitIsConnected(unit) then
			-- 1. Disconnected status
			r, g, b = 0.7, 0.7, 0.7
		elseif UnitIsTapDenied(unit) and not UnitPlayerControlled(unit) then
			-- 2. Tapping status (greyed out)
			r, g, b = 0.6, 0.6, 0.6
		elseif useExecuteColor then
			-- 3. Execute phase coloring
			local executeColor = C["Nameplate"].ExecuteColor
			r, g, b = executeColor[1], executeColor[2], executeColor[3]
		elseif self.Auras.hasTheDot then
			-- 4. Active DoT coloring (if enabled)
			local dotColor = C["Nameplate"].DotColor
			r, g, b = dotColor[1], dotColor[2], dotColor[3]
		elseif isPlayer then
			-- 5. Player coloring (Friendly vs Hostile settings)
			if isFriendly then
				if C["Nameplate"].FriendlyCC then
					r, g, b = K.UnitColor(unit)
				else
					-- REASON: Use default mana color for friendly players if class color is disabled.
					local manaColor = K.Colors.power["MANA"]
					r, g, b = manaColor[1], manaColor[2], manaColor[3]
				end
			else
				-- REASON: Hostiles use reaction coloring by default if HostileCC is disabled.
				r, g, b = K.UnitColor(unit)
			end
		else
			-- 6. Selection Type coloring (Retail primary, provides more granular NPC/Guard colors)
			local selection = UnitSelectionType and UnitSelectionType(unit, true)
			if selection then
				-- REASON: Special handling for friendly NPCs/Guards to match specific selection colors.
				if selection == 3 then
					selection = UnitPlayerControlled(unit) and 5 or 3
				end

				local color = K.Colors.selection[selection]
				if color then
					r, g, b = color[1], color[2], color[3]
				end
			end

			-- 7. Default NPC reaction coloring fallback
			if not r then
				r, g, b = K.UnitColor(unit)
			end
		end

		-- REASON: Threat coloring overrides base health color for tanks for better visibility.
		-- We check for either Tank Mode or the player's active Role.
		if status and (C["Nameplate"].TankMode or K.Role == "Tank") then
			local insecureColor = C["Nameplate"].InsecureColor
			local offTankColor = C["Nameplate"].OffTankColor
			local revertThreat = C["Nameplate"].DPSRevertThreat
			local secureColor = C["Nameplate"].SecureColor
			local transColor = C["Nameplate"].TransColor

			if status == 3 then
				-- Aggro Secure
				if K.Role ~= "Tank" and revertThreat then
					r, g, b = insecureColor[1], insecureColor[2], insecureColor[3]
				else
					if isOffTank then
						r, g, b = offTankColor[1], offTankColor[2], offTankColor[3]
					else
						r, g, b = secureColor[1], secureColor[2], secureColor[3]
					end
				end
			elseif status == 2 or status == 1 then
				-- Threat transition
				r, g, b = transColor[1], transColor[2], transColor[3]
			elseif status == 0 then
				-- No threat / Losing aggro
				if K.Role ~= "Tank" and revertThreat then
					r, g, b = secureColor[1], secureColor[2], secureColor[3]
				else
					r, g, b = insecureColor[1], insecureColor[2], insecureColor[3]
				end
			end
		end

		if r or g or b then
			element:SetStatusBarColor(r, g, b)
		end

		Module.UpdateThreatIndicator(self, status, isCustomUnit)
	end

	-- REASON: Update name text color for units in execute range for immediate feedback.
	-- SECRET (12.0): UnitHealthPercent(unit, true, curve) returns a ColorMixin the
	-- engine evaluates from the (secret) health internally, so execute feedback keeps
	-- working in combat without us ever comparing health in Lua. Mirrors NDui.
	if NP.executedCurve and C["Nameplate"].ExecuteRatio > 0 and not isFriendly then
		local healthColor = UnitHealthPercent(unit, true, NP.executedCurve)
		if healthColor then
			self.nameText:SetTextColor(healthColor:GetRGB())
		end
		self._lastExecuteColor = nil
	elseif self._lastExecuteColor ~= false then
		self._lastExecuteColor = false
		self.nameText:SetTextColor(1, 1, 1)
	end
end

