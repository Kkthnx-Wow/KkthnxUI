local K, C, L, _ = select(2, ...):unpack()
if C.Skins.WeakAuras ~= true then return end

local pairs = pairs
local select = select
local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded

--	WeakAuras skin
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event)
	if not IsAddOnLoaded("WeakAuras") then return end

	local function Skin_WeakAuras(frame)
		if not frame.border then
			K.CreateBorder(frame, 10, 2.5)
		end

		if frame.icon then
			frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			frame.icon.SetTexCoord = K.Noop
		end

		if frame.bar then
			frame.bar.fg:SetTexture(C.Media.Texture)
			frame.bar.bg:SetTexture(C.Media.Texture)
		end

		if frame.stacks then
			frame.stacks:SetFont(C.Media.Font, select(2, frame.stacks:GetFont()), C.Media.Font_Style)
		end

		if frame.timer then
			frame.timer:SetFont(C.Media.Font, select(2, frame.timer:GetFont()), C.Media.Font_Style)
		end

		if frame.text then
			frame.text:SetFont(C.Media.Font, select(2, frame.text:GetFont()), C.Media.Font_Style)
		end
	end

	for weakAura, _ in pairs(WeakAuras.regions) do
		if WeakAuras.regions[weakAura].regionType == "icon" or WeakAuras.regions[weakAura].regionType == "aurabar" then
			Skin_WeakAuras(WeakAuras.regions[weakAura].region)
		end
	end
end)