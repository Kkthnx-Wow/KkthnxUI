local K, C, L, _ = select(2, ...):unpack()
if C.Skins.WeakAuras ~= true then return end

local pairs = pairs
local select = select
local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded

-- WEAKAURAS SKIN
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event)
	if not IsAddOnLoaded("WeakAuras") then return end

	local function Skin_WeakAuras(frame)
		if not frame.shadow then
			-- WE JUST USE OUR PIXEL SHADOW HERE
			frame:CreatePixelShadow()
		end

		if frame.icon then
			frame.icon:SetTexCoord(unpack(K.TexCoords))
			frame.icon.SetTexCoord = K.Noop
		end

		if frame.bar then
			frame.bar.fg:SetTexture(C.Media.Texture)
			frame.bar.bg:SetTexture(C.Media.Blank)
		end

		if frame.stacks then
			frame.stacks:SetFont(C.Media.Font, select(2, frame.stacks:GetFont()), C.Media.Font_Style)
			frame.stacks:SetShadowOffset(0, -0)
		end

		if frame.timer then
			frame.timer:SetFont(C.Media.Font, select(2, frame.timer:GetFont()), C.Media.Font_Style)
			frame.timer:SetShadowOffset(0, -0)
		end

		if frame.text then
			frame.text:SetFont(C.Media.Font, select(2, frame.text:GetFont()), C.Media.Font_Style)
			frame.text:SetShadowOffset(0, -0)
		end
	end

	for weakAura, _ in pairs(WeakAuras.regions) do
		if WeakAuras.regions[weakAura].regionType == "icon" or WeakAuras.regions[weakAura].regionType == "aurabar" then
			Skin_WeakAuras(WeakAuras.regions[weakAura].region)
		end
	end
end)