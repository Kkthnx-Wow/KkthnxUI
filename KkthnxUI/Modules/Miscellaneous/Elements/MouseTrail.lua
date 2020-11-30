local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

-- REMINDER: Reports of texture just being stuck on screen?

local _G = _G

local GetCursorPosition = _G.GetCursorPosition

local x = 0
local y = 0
local speed = 0

local function OnUpdate(_, elapsed)
	local dX = x
	local dY = y

	x, y = GetCursorPosition()
	dX = x - dX
	dY = y - dY

	local weight = 2048 ^ -elapsed
	speed = min(weight * speed + (1 - weight) * sqrt(dX * dX + dY * dY) / elapsed, 1024)

	local size = speed / 6 - 16
	if size > 0 then
		local scale = UIParent:GetEffectiveScale()
		Module.Texture:SetSize(size, size)
		Module.Texture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", (x + 0.5 * dX) / scale, (y + 0.5 * dY) / scale)
		Module.Texture:Show()
		Module.Texture:SetVertexColor(unpack(C["Misc"].MouseTrailColor))
	else
		Module.Texture:Hide()
	end
end

function Module:CreateMouseTrail()
	if C["Misc"].MouseTrail then
		Module.Frame = CreateFrame("Frame", nil, UIParent)
		Module.Frame:SetFrameStrata("TOOLTIP")

		Module.Texture = Module.Frame:CreateTexture()
		Module.Texture:SetTexture([[Interface\Cooldown\star4]]) -- Create texture picker dropdown in future?
		Module.Texture:SetBlendMode("ADD")
		Module.Texture:SetAlpha(0.5)

		Module.Frame:SetScript("OnUpdate", OnUpdate)
	end
end