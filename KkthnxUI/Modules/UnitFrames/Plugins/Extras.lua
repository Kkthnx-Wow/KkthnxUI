local K, C, L, _ = select(2, ...):unpack()

-- LUA API
local _G = _G
local pairs, ipairs = pairs, ipairs

-- WOW API
local IsResting = IsResting
local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS
local InCombatLockdown = InCombatLockdown

-- HIDE CLASS RESOURCES OPTION
-- WE ADD THIS SINCE WE CAN ALREADY PROVIDE THIS SINCE 7.0.3 PREPATCH
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

-- REMOVE PORTRAIT DAMAGE SPAM
if C.Unitframe.CombatFeedback == true then
	PlayerHitIndicator:SetText(nil)
	PlayerHitIndicator.SetText = K.Noop
	-- PET
	PetHitIndicator:SetText(nil)
	PetHitIndicator.SetText = K.Noop
end

-- REMOVE GROUP NUMBER FRAME
if C.Unitframe.GroupNumber == true then
	PlayerFrameGroupIndicator.Show = K.Noop
end

-- REMOVE PVPICONS
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

-- STOP RED FLASH RESTING
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