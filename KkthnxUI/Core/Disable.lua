local K, C, L = select(2, ...):unpack()

-- Prevent users config errors
if C.ActionBar.RightBars > 3 then
	C.ActionBar.RightBars = 3
end

if C.ActionBar.BottomBars > 3 then
	C.ActionBar.BottomBars = 3
end

if C.ActionBar.BottomBars == 3 and C.ActionBar.RightBars == 3 then
	C.ActionBar.BottomBars = 3
	C.ActionBar.RightBars = 2
end

if C.ActionBar.SplitBars == true then
	C.ActionBar.BottomBars = 3
	C.ActionBar.RightBars = 2
end

if C.ActionBar.BottomBars < 1 then
	C.ActionBar.BottomBars = 1
end

if C.ActionBar.PetBarHorizontal == true then
	C.ActionBar.StanceBarHorizontal = false
end

if C.Unitframe.Enable == false then
	C.Filger.Enable = false
end

if C.Unitframe.FlatClassPortraits == true then
	C.Unitframe.ClassPortraits = false
end

if C.Raidframe.Enable == false then
	C.Raidframe.RaidAsParty = false
end

-- Auto-overwrite script config is X addon is found
-- Here we use our own function to check.
if K.IsAddOnEnabled("SexyMap") or K.IsAddOnEnabled("bdMinimap") or K.IsAddOnEnabled("BasicMinimap") or K.IsAddOnEnabled("RicoMiniMap") or K.IsAddOnEnabled("Chinchilla") then
	C.Minimap.Enable = false
end

if K.IsAddOnEnabled("XPerl") or K.IsAddOnEnabled("Stuf") or K.IsAddOnEnabled("PitBull4") or K.IsAddOnEnabled("ShadowedUnitFrames") or K.IsAddOnEnabled("oUF_Abu") then
	C.Unitframe.Enable = false
end

if K.IsAddOnEnabled("Dominos") or K.IsAddOnEnabled("Bartender4") or K.IsAddOnEnabled("RazerNaga")  or K.IsAddOnEnabled("daftMainBar") or K.IsAddOnEnabled("ConsolePortBar") then
	C.ActionBar.Enable = false
end

if K.IsAddOnEnabled("WorldQuestTracker") or K.IsAddOnEnabled("Mapster") or K.IsAddOnEnabled("WorldQuestsList") then
	C.WorldMap.SmallWorldMap = false
end

if K.IsAddOnEnabled("AdiBags") or K.IsAddOnEnabled("ArkInventory") or K.IsAddOnEnabled("cargBags_Nivaya") or K.IsAddOnEnabled("cargBags") or K.IsAddOnEnabled("Bagnon") or K.IsAddOnEnabled("Combuctor") or K.IsAddOnEnabled("TBag") or K.IsAddOnEnabled("BaudBag") then
	C.Bags.Enable = false
end

if K.IsAddOnEnabled("Prat-3.0") or K.IsAddOnEnabled("Chatter") then
	C.Chat.Enable = false
end

if K.IsAddOnEnabled("TidyPlates") or K.IsAddOnEnabled("Aloft") or K.IsAddOnEnabled("Kui_Nameplates") then
	C.Nameplates.Enable = false
end

if K.IsAddOnEnabled("TipTop") or K.IsAddOnEnabled("TipTac") or K.IsAddOnEnabled("FreebTip") or K.IsAddOnEnabled("bTooltip") or K.IsAddOnEnabled("PhoenixTooltip") or K.IsAddOnEnabled("Icetip") or K.IsAddOnEnabled("rTooltip") then
	C.Tooltip.Enable = false
end

if K.IsAddOnEnabled("Pawn") then
	C.Tooltip.ItemIcon = false
end

if K.IsAddOnEnabled("TipTacTalents") then
	C.Tooltip.Talents = false
end

if K.IsAddOnEnabled("ConsolePortBar") then
	C.DataBars.Experience = false
	C.DataBars.Artifact = false
end

if K.IsAddOnEnabled("GnomishVendorShrinker") or K.IsAddOnEnabled("AlreadyKnown") then
	C.Misc.AlreadyKnown = false
end

if K.IsAddOnEnabled("BadBoy") then
	C.Chat.Spam = false
end

if K.IsAddOnEnabled("cInterrupt") then
	C.Announcements.Interrupt = false
end

if K.IsAddOnEnabled("NiceBubbles") then
	C.Skins.ChatBubble = false
end

if K.IsAddOnEnabled("ChatSounds") then
	C.Chat.WhispSound = false
end

if K.IsAddOnEnabled("Doom_CooldownPulse") then
	C.PulseCD.Enable = false
end

if K.IsAddOnEnabled("MBB") or K.IsAddOnEnabled("MinimapButtonFrame") then
	C.Skins.MinimapButtons = false
	C.Minimap.CollectButtons = false
end
