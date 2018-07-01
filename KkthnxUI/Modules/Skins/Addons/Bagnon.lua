local K, C = unpack(select(2, ...))
if not K.CheckAddOnState("Bagnon") then
	return
end

local Module = K:GetModule("Skins")

function Module:BagnonSkin()
	for _, frame in Bagnon:IterateFrames() do
		if frame and not frame.isSkinned then

			frame.Backgrounds = frame:CreateTexture(nil, "BACKGROUND", -2)
			frame.Backgrounds:SetAllPoints()
			frame.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

			K.CreateBorder(frame)

			frame.isSkinned = true
		end
	end
end

function Module:OnEnable()
	if C["Skins"].Bagnon ~= true then
		return
	end

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