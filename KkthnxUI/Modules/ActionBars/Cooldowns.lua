local K, C, L = select(2, ...):unpack()

local GetCVar = GetCVar
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame

local CD = CreateFrame("Frame")

function CD:UpdateCooldown(start, duration, enable, charges, maxcharges, forceShowdrawedge)
	local Enabled = GetCVar("countdownForCooldowns")

	if (Enabled) then
		if not self.IsCooldownTextEdited then
			local NumRegions = self:GetNumRegions()

			for i = 1, NumRegions do
				local Region = select(i, self:GetRegions())

				if Region.GetText then
					Region:SetFont(C.Media.Font, 14, "OUTLINE")
					Region:SetPoint("CENTER", 1, 0)
					Region:SetTextColor(1, 0, 0)
				end
			end

			self.IsCooldownTextEdited = true
		end
	end
end

function CD:AddHooks()
	hooksecurefunc("CooldownFrame_Set", CD.UpdateCooldown)
end

CD:AddHooks()