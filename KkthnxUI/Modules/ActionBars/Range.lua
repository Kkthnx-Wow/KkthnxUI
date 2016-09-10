local K, C, L, _ = select(2, ...):unpack()
if C.ActionBar.Enable ~= true then return end

local _G = _G
local ActionBars = CreateFrame("Frame")
local IsUsableAction = IsUsableAction
local IsActionInRange = IsActionInRange
local ActionHasRange = ActionHasRange
local HasAction = HasAction

function ActionBars:RangeOnUpdate(elapsed)
	if (not self.rangeTimer) then
		return
	end

	if (self.rangeTimer == TOOLTIP_UPDATE_TIME) then
		ActionBars.RangeUpdate(self)
	end
end

function ActionBars:RangeUpdate()
	local Icon = self.icon
	local NormalTexture = self.NormalTexture
	local ID = self.action

	if not ID then return end

	local IsUsable, NotEnoughMana = IsUsableAction(ID)
	local HasRange = ActionHasRange(ID)
	local InRange = IsActionInRange(ID)

	if IsUsable then -- USABLE
		if (HasRange and InRange == false) then -- OUT OF RANGE
			Icon:SetVertexColor(unpack(C.ActionBar.OutOfRange))
			NormalTexture:SetVertexColor(unpack(C.ActionBar.OutOfRange))
		else -- In range
			Icon:SetVertexColor(1.0, 1.0, 1.0)
			NormalTexture:SetVertexColor(1.0, 1.0, 1.0)
		end
	elseif NotEnoughMana then -- NOT ENOUGH POWER
		Icon:SetVertexColor(unpack(C.ActionBar.OutOfMana))
		NormalTexture:SetVertexColor(unpack(C.ActionBar.OutOfMana))
	else -- NOT USABLE
		Icon:SetVertexColor(0.3, 0.3, 0.3)
		NormalTexture:SetVertexColor(0.3, 0.3, 0.3)
	end
end

hooksecurefunc("ActionButton_OnUpdate", ActionBars.RangeOnUpdate)
hooksecurefunc("ActionButton_Update", ActionBars.RangeUpdate)
hooksecurefunc("ActionButton_UpdateUsable", ActionBars.RangeUpdate)