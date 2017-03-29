local K, C, L = unpack(select(2, ...))
if C.Blizzard.ColorTextures ~= true then return end

local pairs = pairs
local select = select
local unpack = unpack

local ColorTextures = CreateFrame("Frame")

-- Coloring frames
function ColorTextures:Style()
	for i, texture in pairs({
		-- Unit frames
		PlayerFrameTexture,
		PlayerFrameAlternateManaBarBorder,
		PlayerFrameAlternateManaBarRightBorder,
		PlayerFrameAlternateManaBarLeftBorder,
		TargetFrameTextureFrameTexture,
		PetFrameTexture,
		PartyMemberFrame1Texture,
		PartyMemberFrame2Texture,
		PartyMemberFrame3Texture,
		PartyMemberFrame4Texture,
		PartyMemberFrame1PetFrameTexture,
		PartyMemberFrame2PetFrameTexture,
		PartyMemberFrame3PetFrameTexture,
		PartyMemberFrame4PetFrameTexture,
		FocusFrameTextureFrameTexture,
		TargetFrameToTTextureFrameTexture,
		FocusFrameToTTextureFrameTexture,
		Boss1TargetFrameTextureFrameTexture,
		Boss2TargetFrameTextureFrameTexture,
		Boss3TargetFrameTextureFrameTexture,
		Boss4TargetFrameTextureFrameTexture,
		Boss5TargetFrameTextureFrameTexture,
		Boss1TargetFrameSpellBar.Border,
		Boss2TargetFrameSpellBar.Border,
		Boss3TargetFrameSpellBar.Border,
		Boss4TargetFrameSpellBar.Border,
		Boss5TargetFrameSpellBar.Border,
		Boss1TargetFrameSpellBar.BorderShield,
		Boss2TargetFrameSpellBar.BorderShield,
		Boss3TargetFrameSpellBar.BorderShield,
		Boss4TargetFrameSpellBar.BorderShield,
		Boss5TargetFrameSpellBar.BorderShield,
		CastingBarFrame.Border,
		CastingBarFrame.BorderShield,
		FocusFrameSpellBar.Border,
		FocusFrameSpellBar.BorderShield,
		TargetFrameSpellBar.Border,
		TargetFrameSpellBar.BorderShield,
		-- mainmenubar
		SlidingActionBarTexture0,
		SlidingActionBarTexture1,
		MainMenuBarTexture0,
		MainMenuBarTexture1,
		MainMenuBarTexture2,
		MainMenuBarTexture3,
		MainMenuMaxLevelBar0,
		MainMenuMaxLevelBar1,
		MainMenuMaxLevelBar2,
		MainMenuMaxLevelBar3,
		MainMenuXPBarTextureLeftCap,
		MainMenuXPBarTextureRightCap,
		MainMenuXPBarTextureMid,
		ReputationWatchBarTexture0,
		ReputationWatchBarTexture1,
		ReputationWatchBarTexture2,
		ReputationWatchBarTexture3,
		ReputationXPBarTexture0,
		ReputationXPBarTexture1,
		ReputationXPBarTexture2,
		ReputationXPBarTexture3,
		MainMenuBarLeftEndCap,
		MainMenuBarRightEndCap,
		StanceBarLeft,
		StanceBarMiddle,
		StanceBarRight,
		-- Arena frames
		ArenaEnemyFrame1Texture,
		ArenaEnemyFrame2Texture,
		ArenaEnemyFrame3Texture,
		ArenaEnemyFrame4Texture,
		ArenaEnemyFrame5Texture,
		ArenaEnemyFrame1SpecBorder,
		ArenaEnemyFrame2SpecBorder,
		ArenaEnemyFrame3SpecBorder,
		ArenaEnemyFrame4SpecBorder,
		ArenaEnemyFrame5SpecBorder,
		ArenaEnemyFrame1PetFrameTexture,
		ArenaEnemyFrame2PetFrameTexture,
		ArenaEnemyFrame3PetFrameTexture,
		ArenaEnemyFrame4PetFrameTexture,
		ArenaEnemyFrame5PetFrameTexture,
		ArenaPrepFrame1Texture,
		ArenaPrepFrame2Texture,
		ArenaPrepFrame3Texture,
		ArenaPrepFrame4Texture,
		ArenaPrepFrame5Texture,
		ArenaPrepFrame1SpecBorder,
		ArenaPrepFrame2SpecBorder,
		ArenaPrepFrame3SpecBorder,
		ArenaPrepFrame4SpecBorder,
		ArenaPrepFrame5SpecBorder,
		-- Panels
		CharacterFrameTitleBg,
		CharacterFrameBg,
		-- Minimap
		MinimapBorder,
		MinimapBorderTop,
		MiniMapTrackingButtonBorder,
	}) do
		texture:SetVertexColor(C.Blizzard.TexturesColor[1], C.Blizzard.TexturesColor[2], C.Blizzard.TexturesColor[3] or 0.31, 0.31, 0.31)
	end
end

ColorTextures:RegisterEvent("PLAYER_ENTERING_WORLD")
ColorTextures:SetScript("OnEvent", function()
	ColorTextures:Style()
end)