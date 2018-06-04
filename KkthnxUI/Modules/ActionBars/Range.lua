local _, C = unpack(select(2, ...))
if C["ActionBar"].Enable ~= true then
	return
end

-- Lua API
local _G = _G
local unpack = unpack

-- Wow API
local ActionHasRange = _G.ActionHasRange
local hooksecurefunc = _G.hooksecurefunc
local IsActionInRange = _G.IsActionInRange
local IsUsableAction = _G.IsUsableAction
local TOOLTIP_UPDATE_TIME = _G.TOOLTIP_UPDATE_TIME

local function RangeUpdate(self)
	local Icon = self.icon
	local ID = self.action

	if not ID then return end

	local IsUsable, NotEnoughMana = IsUsableAction(ID)
	local HasRange = ActionHasRange(ID)
	local InRange = IsActionInRange(ID)

	if self.outOfRange then
		Icon:SetVertexColor(unpack(C["ActionBar"].OutOfRange))
	else
		if IsUsable then -- Usable
			if (HasRange and InRange == false) then -- Out of range
				Icon:SetVertexColor(unpack(C["ActionBar"].OutOfRange))
			else -- In range
				Icon:SetVertexColor(1.0, 1.0, 1.0)
			end
		elseif NotEnoughMana then -- Not enough power
			Icon:SetVertexColor(unpack(C["ActionBar"].OutOfMana))
		else -- Not usable
			Icon:SetVertexColor(0.4, 0.4, 0.4)
		end
	end
end

local function RangeOnUpdate(self)
	if (not self.rangeTimer) then
		return
	end

	if (self.rangeTimer == TOOLTIP_UPDATE_TIME or .2) then
		RangeUpdate(self)
	end
end

hooksecurefunc("ActionButton_OnUpdate", RangeOnUpdate)
hooksecurefunc("ActionButton_Update", RangeUpdate)
hooksecurefunc("ActionButton_UpdateUsable", RangeUpdate)