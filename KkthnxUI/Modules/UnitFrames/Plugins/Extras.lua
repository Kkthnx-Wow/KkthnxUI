local K, C, L, _ = select(2, ...):unpack()

-- LUA API
local _G = _G
local pairs, ipairs = pairs, ipairs

-- WOW API
local IsResting = IsResting
local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS
local InCombatLockdown = InCombatLockdown

-- Hide class resources option
-- We add this since we can already provide this since 7.0.3 prepatch
if C.Unitframe.ClassResources == true then
	for _, ClassResources in pairs({
		WarlockPowerFrame,
		PaladinPowerBarFrame,
		ComboPointPlayerFrame,
		RuneFrame,
	}) do
		ClassResources:UnregisterAllEvents()
		ClassResources.Show = K.Noop
		ClassResources:Hide()
	end
end

-- Remove portrait damage spam
if C.Unitframe.CombatFeedback == true then
	PlayerHitIndicator:SetText(nil)
	PlayerHitIndicator.SetText = K.Noop
	-- Pet
	PetHitIndicator:SetText(nil)
	PetHitIndicator.SetText = K.Noop
end

-- Remove group number frame
if C.Unitframe.GroupNumber == true then
	PlayerFrameGroupIndicator.Show = K.Noop
end

-- Remove pvpicons
if C.Unitframe.PvPIcon == true then
	PlayerPVPIcon:Kill()
	TargetFrameTextureFramePVPIcon:Kill()
	FocusFrameTextureFramePVPIcon:Kill()
	for i = 1, MAX_PARTY_MEMBERS do
		if not InCombatLockdown() then
			_G["PartyMemberFrame"..i.."PVPIcon"]:Kill()
		end
	end
end

-- Stop red flash resting
for _, Textures in ipairs({
	"PlayerAttackGlow",
	"PetAttackModeTexture",
	"PlayerRestGlow",
	"PlayerStatusGlow",
	"PlayerStatusTexture",
	"PlayerAttackBackground"

}) do
	hooksecurefunc("PlayerFrame_UpdateStatus", function()
		if (not InCombatLockdown() and IsResting("player")) then
			local Texture = _G[Textures]
			if Texture then
				Texture:Kill()
				Texture.Show = K.Noop
			end
		end
	end)
end