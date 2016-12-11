local K, C, L = unpack(select(2, ...))
if C.Skins.WeakAuras ~= true then return end

local pairs = pairs
local select = select
local CreateFrame = CreateFrame

-- WEAKAURAS SKIN
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event)
	if not K.CheckAddOn("WeakAuras") then return end

	local function Skin_WeakAuras(frame)
		if not frame.shadow then
			-- We just use our pixel shadow here
			frame:CreateShadow()
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
