local K, C, L = unpack(select(2, ...))
if C.Auras.Enable ~= true then return end

-- Wow API
local CreateFrame = CreateFrame

local KkthnxUIAuras = CreateFrame("Frame")

function KkthnxUIAuras:Enable()
	self:DisableBlizzardAuras()
	self:CreateHeaders()

	local EnterWorld = CreateFrame("Frame")
	EnterWorld:RegisterEvent("PLAYER_ENTERING_WORLD")
	EnterWorld:SetScript("OnEvent", function(self, event)
		KkthnxUIAuras:OnEnterWorld()

		if event == "PLAYER_ENTERING_WORLD" then
			self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		end
	end)
end

K.Auras = KkthnxUIAuras
KkthnxUIAuras:RegisterEvent("PLAYER_LOGIN")
KkthnxUIAuras:SetScript("OnEvent", KkthnxUIAuras.Enable)