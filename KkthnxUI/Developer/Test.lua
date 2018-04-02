local K, C, L = unpack(select(2, ...))

local _G = _G

local COOLDOWN_TYPE_LOSS_OF_CONTROL = _G.COOLDOWN_TYPE_LOSS_OF_CONTROL
local hooksecurefunc = _G.hooksecurefunc

hooksecurefunc("CooldownFrame_Set", function(self)
  if self.currentCooldownType == COOLDOWN_TYPE_LOSS_OF_CONTROL then
    self:SetCooldown(0, 0)
  end
end)