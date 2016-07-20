local K, C, L, _ = select(2, ...):unpack()

local GetAddOnInfo = GetAddOnInfo

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

if C.Error.Black == true and C.Error.White == true then
	C.Error.White = false
end

if C.Error.Combat == true then
	C.Error.Black = false
	C.Error.White = false
end

if C.Unitframe.PercentHealth == true then
	C.Unitframe.ClassHealth = false
end

if C.Unitframe.Enable == false then
	C.Filger.Enable = false
end

-- Auto-overwrite script config is X addon is found
if (select(4, GetAddOnInfo("SexyMap"))) or (select(4, GetAddOnInfo("wMinimap"))) then
	C.Minimap.Enable = false
end

if (select(4, GetAddOnInfo("Stuf"))) or (select(4, GetAddOnInfo("PitBull4"))) or (select(4, GetAddOnInfo("ShadowedUnitFrames"))) then
	C.Unitframe.Enable = false
	C.Unitframe.EnhancedFrames = false
end

if (select(4, GetAddOnInfo("QuestHelper"))) then -- This is a temp fix until I figure out what to blacklist from shitty questhelper.
	C.Skins.MinimapButtons = false
end

if (select(4, GetAddOnInfo("Mapster"))) then
	C["map"].enable = false
end

if (select(4, GetAddOnInfo("Dominos"))) or (select(4, GetAddOnInfo("Bartender4"))) or (select(4, GetAddOnInfo("RazerNaga"))) then
	C.ActionBar.Enable = false
end

if (select(4, GetAddOnInfo("KkthnxUI_OldBars"))) then
	C.ActionBar.Enable = false
end

if (select(4, GetAddOnInfo("XPerl"))) or (select(4, GetAddOnInfo("Stuf"))) or (select(4, GetAddOnInfo("PitBull4"))) or (select(4, GetAddOnInfo("ShadowedUnitFrames"))) then
	C.Unitframe.Enable = false
end

if (select(4, GetAddOnInfo("AdiBags"))) or (select(4, GetAddOnInfo("ArkInventory"))) or (select(4, GetAddOnInfo("cargBags_Nivaya"))) or (select(4, GetAddOnInfo("cargBags"))) or (select(4, GetAddOnInfo("Bagnon"))) or (select(4, GetAddOnInfo("Combuctor"))) or (select(4, GetAddOnInfo("TBag"))) or (select(4, GetAddOnInfo("BaudBag"))) then
	C.Bag.Enable = false
end

if (select(4, GetAddOnInfo("Prat-3.0"))) or (select(4, GetAddOnInfo("Chatter"))) then
	C.Chat.Enable = false
end

if (select(4, GetAddOnInfo("TidyPlates"))) or (select(4, GetAddOnInfo("Aloft"))) or (select(4, GetAddOnInfo("dNamePlates"))) or (select(4, GetAddOnInfo("caelNamePlates"))) then
	C.Nameplate.Enable = false
end

if (select(4, GetAddOnInfo("TipTac"))) or (select(4, GetAddOnInfo("FreebTip"))) or (select(4, GetAddOnInfo("bTooltip"))) or (select(4, GetAddOnInfo("PhoenixTooltip"))) or (select(4, GetAddOnInfo("Icetip"))) or (select(4, GetAddOnInfo("rTooltip"))) then
	C.Tooltip.Enable = false
end

if (select(4, GetAddOnInfo("TipTacTalents"))) then
	C.Tooltip.Talents = false
end

if (select(4, GetAddOnInfo("GnomishVendorShrinker"))) or (select(4, GetAddOnInfo("AlreadyKnown"))) then
	C.Misc.AlreadyKnown = false
end

if (select(4, GetAddOnInfo("BadBoy"))) then
	C.Chat.Spam = false
end

if (select(4, GetAddOnInfo("NiceBubbles"))) then
	C.Skins.ChatBubble = false
end

if (select(4, GetAddOnInfo("ChatSounds"))) then
	C.Chat.WhispSound = false
end

if (select(4, GetAddOnInfo("Doom_CooldownPulse"))) then
	C.PulseCD.Enable = false
end