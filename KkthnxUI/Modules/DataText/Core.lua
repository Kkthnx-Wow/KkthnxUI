local K = unpack(KkthnxUI)
local Module = K:NewModule("DataText")

function Module:OnEnable()
	self.CheckLoginTime = GetTime()

	-- local frame = CreateFrame("Frame", "KKUI_GlowTestFunction", UIParent)
	-- frame:SetSize(100, 100)
	-- frame:SetPoint("CENTER")
	-- frame:CreateBorder()

	-- frame.glowFrame = K.CreateGlowFrame(frame, 94)

	-- K.ShowOverlayGlow(frame.glowFrame, 3, { 1, 0.82, 0.2, 1 })
	-- K.HideOverlayGlow(self, 3)

	self:CreateDurabilityDataText()
	self:CreateGoldDataText()
	self:CreateGuildDataText()
	self:CreateSystemDataText()
	self:CreateLatencyDataText()
	self:CreateLocationDataText()
	self:CreateSocialDataText()
	self:CreateTimeDataText()
	self:CreateCoordsDataText()
end
