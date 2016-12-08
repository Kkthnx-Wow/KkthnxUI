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

-- Auto-overwrite script config is X addon is found
-- Here we use our own function to check.
if IsAddOnLoaded("SexyMap") or IsAddOnLoaded("bdMinimap") or IsAddOnLoaded("BasicMinimap") or IsAddOnLoaded("RicoMiniMap") or IsAddOnLoaded("Chinchilla") then
	C.Minimap.Enable = false
end

if IsAddOnLoaded("XPerl") or IsAddOnLoaded("Stuf") or IsAddOnLoaded("PitBull4") or IsAddOnLoaded("ShadowedUnitFrames") or IsAddOnLoaded("oUF_Abu") then
	C.Unitframe.Enable = false
end

if IsAddOnLoaded("Dominos") or IsAddOnLoaded("Bartender4") or IsAddOnLoaded("RazerNaga")  or IsAddOnLoaded("daftMainBar") or IsAddOnLoaded("ConsolePortBar") then
	C.ActionBar.Enable = false
end

if IsAddOnLoaded("WorldQuestTracker") or IsAddOnLoaded("Mapster") or IsAddOnLoaded("WorldQuestsList") then
	C.WorldMap.SmallWorldMap = false
end

if IsAddOnLoaded("AdiBags") or IsAddOnLoaded("ArkInventory") or IsAddOnLoaded("cargBags_Nivaya") or IsAddOnLoaded("cargBags") or IsAddOnLoaded("Bagnon") or IsAddOnLoaded("Combuctor") or IsAddOnLoaded("TBag") or IsAddOnLoaded("BaudBag") then
	C.Bags.Enable = false
end

if IsAddOnLoaded("Prat-3.0") or IsAddOnLoaded("Chatter") then
	C.Chat.Enable = false
end

if IsAddOnLoaded("TidyPlates") or IsAddOnLoaded("Aloft") or IsAddOnLoaded("Kui_Nameplates") then
	C.Nameplates.Enable = false
end

if IsAddOnLoaded("TipTop") or IsAddOnLoaded("TipTac") or IsAddOnLoaded("FreebTip") or IsAddOnLoaded("bTooltip") or IsAddOnLoaded("PhoenixTooltip") or IsAddOnLoaded("Icetip") or IsAddOnLoaded("rTooltip") then
	C.Tooltip.Enable = false
end

if IsAddOnLoaded("Pawn") then
	C.Tooltip.ItemIcon = false
end

if IsAddOnLoaded("TipTacTalents") then
	C.Tooltip.Talents = false
end

if IsAddOnLoaded("ConsolePortBar") then
	C.DataBars.Experience = false
	C.DataBars.Artifact = false
end

if IsAddOnLoaded("GnomishVendorShrinker") or IsAddOnLoaded("AlreadyKnown") then
	C.Misc.AlreadyKnown = false
end

if IsAddOnLoaded("cInterrupt") then
	C.Announcements.Interrupt = false
end

if IsAddOnLoaded("NiceBubbles") then
	C.Skins.ChatBubble = false
end

if IsAddOnLoaded("ChatSounds") then
	C.Chat.WhispSound = false
end

if IsAddOnLoaded("Doom_CooldownPulse") then
	C.PulseCD.Enable = false
end

if IsAddOnLoaded("MBB") or IsAddOnLoaded("MinimapButtonFrame") then
	C.Skins.MinimapButtons = false
	C.Minimap.CollectButtons = false
end
