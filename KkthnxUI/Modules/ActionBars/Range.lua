local K, C, L = select(2, ...):unpack()
if C.ActionBar.Enable ~= true then return end

-- Lua API
local unpack = unpack

-- Wow API
local IsUsableAction = IsUsableAction
local ActionHasRange = ActionHasRange
local IsActionInRange = IsActionInRange

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: TOOLTIP_UPDATE_TIME

local KkthnxUIActionBars = CreateFrame("Frame")

function KkthnxUIActionBars:RangeOnUpdate(elapsed)
	if (not self.rangeTimer) then
		return
	end

	if (self.rangeTimer == TOOLTIP_UPDATE_TIME) then
		KkthnxUIActionBars.RangeUpdate(self)
	end
end

function KkthnxUIActionBars:RangeUpdate()
	local Icon = self.icon
	local NormalTexture = self.NormalTexture
	local ID = self.action

	if not ID then return end

	local IsUsable, NotEnoughMana = IsUsableAction(ID)
	local HasRange = ActionHasRange(ID)
	local InRange = IsActionInRange(ID)

	if IsUsable then -- Usable
		if (HasRange and InRange == false) then -- Out of range
			Icon:SetVertexColor(unpack(C.ActionBar.OutOfRange))
			NormalTexture:SetVertexColor(unpack(C.ActionBar.OutOfRange))
		else -- In range
			Icon:SetVertexColor(1.0, 1.0, 1.0)
			NormalTexture:SetVertexColor(1.0, 1.0, 1.0)
		end
	elseif NotEnoughMana then -- Not enough power
		Icon:SetVertexColor(unpack(C.ActionBar.OutOfMana))
		NormalTexture:SetVertexColor(unpack(C.ActionBar.OutOfMana))
	else -- Not usable
		Icon:SetVertexColor(0.3, 0.3, 0.3)
		NormalTexture:SetVertexColor(0.3, 0.3, 0.3)
	end
end

hooksecurefunc("ActionButton_OnUpdate", KkthnxUIActionBars.RangeOnUpdate)
hooksecurefunc("ActionButton_Update", KkthnxUIActionBars.RangeUpdate)
hooksecurefunc("ActionButton_UpdateUsable", KkthnxUIActionBars.RangeUpdate)