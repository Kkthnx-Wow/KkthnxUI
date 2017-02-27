local K, C, L = unpack(select(2, ...))
if C.ActionBar.Enable ~= true then return end

-- Lua API
local _G = _G
local unpack = unpack

-- Wow API
local ActionHasRange = _G.ActionHasRange
local IsActionInRange = _G.IsActionInRange
local IsUsableAction = _G.IsUsableAction

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: TOOLTIP_UPDATE_TIME

local function Button_RangeUpdate(self)
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

local function Button_RangeOnUpdate(self, elapsed)
	if (not self.rangeTimer) then
		return
	end

	if (self.rangeTimer == TOOLTIP_UPDATE_TIME) then
		Button_RangeUpdate(self)
	end
end

hooksecurefunc("ActionButton_OnUpdate", Button_RangeOnUpdate)
hooksecurefunc("ActionButton_Update", Button_RangeUpdate)
hooksecurefunc("ActionButton_UpdateUsable", Button_RangeUpdate)