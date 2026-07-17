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
local NotSecret = K.NotSecret
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
	if Module.ApplyStyleFilter(self, unit) then
		Module.UpdateThreatIndicator(self, status, isCustomUnit)
	else
		local connected = UnitIsConnected(unit)
		if NotSecret(connected) and not connected then
			r, g, b = 0.7, 0.7, 0.7
		else
			local controlled = UnitPlayerControlled(unit)
			local tapped = UnitIsTapDenied(unit)
			if NotSecret(tapped) and tapped and NotSecret(controlled) and not controlled then
				r, g, b = 0.6, 0.6, 0.6
			elseif useExecuteColor then
				local executeColor = C["Nameplate"].ExecuteColor
				r, g, b = executeColor[1], executeColor[2], executeColor[3]
			elseif isPlayer then
				if isFriendly then
					if C["Nameplate"].FriendlyCC then
						r, g, b = K.UnitColor(unit)
					else
						-- Friendly players without class color → Colors.lua friendly reaction.
						local fr = K.Colors.reaction and K.Colors.reaction[5]
						if fr then
							r, g, b = fr[1] or fr.r, fr[2] or fr.g, fr[3] or fr.b
						else
							local manaColor = K.Colors.power["MANA"]
							r, g, b = manaColor[1], manaColor[2], manaColor[3]
						end
					end
				else
					-- HostileCC: class color; otherwise Colors.lua hostile reaction (not TargetColor).
					if C["Nameplate"].HostileCC then
						r, g, b = K.UnitColor(unit)
					else
						local hr = K.Colors.reaction and K.Colors.reaction[2]
						if hr then
							r, g, b = hr[1] or hr.r, hr[2] or hr.g, hr[3] or hr.b
						else
							r, g, b = K.UnitColor(unit)
						end
					end
				end
			else
				-- NPCs: prefer Colors.lua reaction (via GetNpcReactionColor) over sparse selection table.
				local nr, ng, nb = K.GetNpcReactionColor(unit)
				if nr then
					r, g, b = nr, ng, nb
				else
					local selection = UnitSelectionType and UnitSelectionType(unit, true)
					if NotSecret(selection) and selection then
						if selection == 3 then
							local playerControlled = UnitPlayerControlled(unit)
							if NotSecret(playerControlled) then
								selection = playerControlled and 5 or 3
							end
						end

						local selColor = K.Colors.selection[selection]
						if selColor then
							r, g, b = selColor[1], selColor[2], selColor[3]
						end
					end

					if not r then
						r, g, b = K.UnitColor(unit)
					end
				end
			end
		end

		if status and (C["Nameplate"].TankMode or K.Role == "Tank") then
			local insecureColor = C["Nameplate"].InsecureColor
			local offTankColor = C["Nameplate"].OffTankColor
			local revertThreat = C["Nameplate"].DPSRevertThreat
			local secureColor = C["Nameplate"].SecureColor
			local transColor = C["Nameplate"].TransColor

			if status == 3 then
				if K.Role ~= "Tank" and revertThreat then
					r, g, b = insecureColor[1], insecureColor[2], insecureColor[3]
				elseif isOffTank then
					r, g, b = offTankColor[1], offTankColor[2], offTankColor[3]
				else
					r, g, b = secureColor[1], secureColor[2], secureColor[3]
				end
			elseif status == 2 or status == 1 then
				r, g, b = transColor[1], transColor[2], transColor[3]
			elseif status == 0 then
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
	-- working in combat without us ever comparing health in Lua.
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

