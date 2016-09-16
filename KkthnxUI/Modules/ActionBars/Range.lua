local K, C, L, _ = select(2, ...):unpack()
if C.ActionBar.Enable ~= true then return end

local _G = _G
local unpack = unpack
local KkthnxUIRange = CreateFrame("Frame")
local IsUsableAction = IsUsableAction
local IsActionInRange = IsActionInRange
local ActionHasRange = ActionHasRange
local HasAction = HasAction

function KkthnxUIRange:RangeOnUpdate(elapsed)
	if not self.rangeTimer then return end
	KkthnxUIRange.RangeUpdate(self)
end

function KkthnxUIRange:RangeUpdate()
	local Name = self:GetName()
	local Icon = _G[Name.."Icon"]
	local NormalTexture = _G[Name.."NormalTexture"]
	local ID = self.action
	local IsUsable, NotEnoughMana = IsUsableAction(ID)
	local HasRange = ActionHasRange(ID)
	local InRange = IsActionInRange(ID)

	if IsUsable then
		if (HasRange and InRange == false) then
			Icon:SetVertexColor(unpack(C.ActionBar.OutOfRange))
			NormalTexture:SetVertexColor(unpack(C.ActionBar.OutOfRange))
		else
			Icon:SetVertexColor(1.0, 1.0, 1.0)
			NormalTexture:SetVertexColor(1.0, 1.0, 1.0)
		end
	elseif NotEnoughMana then
		Icon:SetVertexColor(unpack(C.ActionBar.OutOfMana))
		NormalTexture:SetVertexColor(unpack(C.ActionBar.OutOfMana))
	else
		Icon:SetVertexColor(.3, .3, .3)
		NormalTexture:SetVertexColor(.3, .3, .3)
    end
end

hooksecurefunc("ActionButton_OnUpdate", KkthnxUIRange.RangeOnUpdate)
hooksecurefunc("ActionButton_Update", KkthnxUIRange.RangeUpdate)
hooksecurefunc("ActionButton_UpdateUsable", KkthnxUIRange.RangeUpdate)