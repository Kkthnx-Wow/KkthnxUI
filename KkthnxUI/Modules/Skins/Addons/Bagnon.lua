local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("BagnonSkin", "AceEvent-3.0")

if not K.CheckAddOnState("Bagnon") then return end

function Module:BagnonSkin(event, addon)
	for k, frame in Bagnon:IterateFrames() do
		if frame and not frame.isSkinned then
			frame:SetTemplate("Transparent")
			frame.isSkinned = true
		end
	end
end

function Module:OnEnable()
	if C["Skins"].Bagnon ~= true then return end
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "BagnonSkin")
	self:RegisterEvent("BANKFRAME_OPENED", "BagnonSkin")
	self:RegisterEvent("GUILDBANKFRAME_OPENED", "BagnonSkin")
	self:RegisterEvent("VOID_STORAGE_OPEN", "BagnonSkin")
end

function Module:OnDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("BANKFRAME_OPENED")
	self:UnregisterEvent("GUILDBANKFRAME_OPENED")
	self:UnregisterEvent("VOID_STORAGE_OPEN")
end