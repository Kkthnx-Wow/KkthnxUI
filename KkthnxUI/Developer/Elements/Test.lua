local K = unpack(select(2, ...))
local Module = K:NewModule("Test")

-- Sourced: AzeriteUI (Goldpaw)

function Module:ApplyExperimentalFeatures()
	-- Minifix for MaxDPS for now
	if (not ActionButton_GetPagedID) then
		ActionButton_GetPagedID = function(self)
			return self.action
		end
	end

	if (not ActionButton_CalculateAction) then
		ActionButton_CalculateAction = function(self, button)
			if (not button) then
				button = SecureButton_GetEffectiveButton(self)
			end

			if (self:GetID() > 0) then
				local page = SecureButton_GetModifiedAttribute(self, "actionpage", button)
				if ( not page ) then
					page = GetActionBarPage()
					if ( self.isExtra ) then
						page = GetExtraBarIndex()
					elseif ( self.buttonType == "MULTICASTACTIONBUTTON" ) then
						page = GetMultiCastBarIndex()
					end
				end
				return (self:GetID() + ((page - 1) * NUM_ACTIONBAR_BUTTONS))
			else
				return SecureButton_GetModifiedAttribute(self, "action", button) or 1
			end
		end
	end
end

function Module:OnEnable()
	Module:ApplyExperimentalFeatures()
end