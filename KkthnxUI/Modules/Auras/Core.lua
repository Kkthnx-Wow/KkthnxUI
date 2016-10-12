local K, C, L = select(2, ...):unpack()

local KkthnxUIAuras = CreateFrame("Frame")

function KkthnxUIAuras:Enable()
	self:DisableBlizzardAuras()
	self:CreateHeaders()

	local EnterWorld = CreateFrame("Frame")
	EnterWorld:RegisterEvent("PLAYER_ENTERING_WORLD")
	EnterWorld:SetScript("OnEvent", function(self, event)
		KkthnxUIAuras:OnEnterWorld()
	end)
end

K.Auras = KkthnxUIAuras
KkthnxUIAuras:RegisterEvent("PLAYER_LOGIN")
KkthnxUIAuras:SetScript("OnEvent", KkthnxUIAuras.Enable)
