local K, C = unpack(select(2, ...))

local _G = _G

local DisableAddOn = _G.DisableAddOn
local ReloadUI = _G.ReloadUI
local StaticPopup_Show = _G.StaticPopup_Show
local UNKNOWN = _G.UNKNOWN

-- Prevent users config errors and using other UIs over mine.

K.Conflicts = {}
-- If a UI does not use a color to color their name in their TOC then we will default it to |cffffd100UINAME|r
if K.IsAddOnEnabled("ShestakUI") then
	K.Conflicts.ButtonText = "|cffffd100ShestakUI|r"
	K.Conflicts.DisableText = "ShestakUI"
elseif K.IsAddOnEnabled("ElvUI") then
	K.Conflicts.ButtonText = "|cff1784d1ElvUI|r"
	K.Conflicts.DisableText = "ElvUI"
elseif K.IsAddOnEnabled("Tukui") then
	K.Conflicts.ButtonText = "|cffff8000Tukui|r"
	K.Conflicts.DisableText = "Tukui"
elseif K.IsAddOnEnabled("DiabolicUI") then
	K.Conflicts.ButtonText = "|cff8a0707Diabolic|r|cffffffffUI|r"
	K.Conflicts.DisableText = "DiabolicUI"
else
	-- Fallbacks
	K.Conflicts.ButtonText = UNKNOWN
	K.Conflicts.DisableText = UNKNOWN
end

if IsAddOnLoaded("DiabolicUI") or IsAddOnLoaded("ElvUI") or IsAddOnLoaded("Tukui") or IsAddOnLoaded("ShestakUI") then
	StaticPopup_Show("KKTHNXUI_INCOMPATIBLE")
end

-- Actionbar Conflicts
if C["ActionBar"].RightBars > 3 then
	C["ActionBar"].RightBars = 3
end

if C["ActionBar"].BottomBars > 3 then
	C["ActionBar"].BottomBars = 3
end

if C["ActionBar"].BottomBars == 3 and C["ActionBar"].RightBars == 3 then
	C["ActionBar"].BottomBars = 3
	C["ActionBar"].RightBars = 2
end

if C["ActionBar"].SplitBars == true then
	C["ActionBar"].BottomBars = 3
	C["ActionBar"].RightBars = 2
end

if C["ActionBar"].BottomBars < 1 then
	C["ActionBar"].BottomBars = 1
end

if C["ActionBar"].PetBarHorizontal == true then
	C["ActionBar"].StanceBarHorizontal = false
end

-- Errors
if C["Error"].Black == true and C["Error"].White == true then
	C["Error"].White = false
end

if C["Error"].Combat == true then
	C["Error"].Black = false
	C["Error"].White = false
end

-- Auto-overwrite script config is X addon is found
-- Here we use our own functions to check for addons.
if K.IsAddOnEnabled("SexyMap") or K.IsAddOnEnabled("bdMinimap") or K.IsAddOnEnabled("BasicMinimap") or K.IsAddOnEnabled("RicoMiniMap") or K.IsAddOnEnabled("Chinchilla") then
	C["Minimap"].Enable = false
end

if K.IsAddOnEnabled("XPerl") or K.IsAddOnEnabled("Stuf") or K.IsAddOnEnabled("PitBull4") or K.IsAddOnEnabled("ShadowedUnitFrames") or K.IsAddOnEnabled("oUF_Abu") then
	C["Unitframe"].Enable = false
end

if (K.IsAddOnEnabled("Dominos") or K.IsAddOnEnabled("Bartender4") or K.IsAddOnEnabled("RazerNaga") or K.IsAddOnEnabled("daftMainBar")) or (K.IsAddOnEnabled("ConsolePortBar") and K.IsAddOnEnabled("ConsolePort")) then -- We have to check for main ConsolePort addon too.
	C["ActionBar"].Enable = false
end

if K.IsAddOnEnabled("WorldQuestTracker") or K.IsAddOnEnabled("Mapster") or K.IsAddOnEnabled("WorldQuestsList") then
	C["WorldMap"].SmallWorldMap = false
end

if K.IsAddOnEnabled("BadBoy") then
	C["Chat"].SpamFilter = false
end

if K.IsAddOnEnabled("AdiBags") or K.IsAddOnEnabled("ArkInventory") or K.IsAddOnEnabled("cargBags_Nivaya") or K.IsAddOnEnabled("cargBags") or K.IsAddOnEnabled("Bagnon") or K.IsAddOnEnabled("Combuctor") or K.IsAddOnEnabled("TBag") or K.IsAddOnEnabled("BaudBag") then
	C["Inventory"].Enable = false
end

if K.IsAddOnEnabled("Prat-3.0") or K.IsAddOnEnabled("Chatter") then
	C["Chat"].Enable = false
end

if K.IsAddOnEnabled("TidyPlates") or K.IsAddOnEnabled("Aloft") or K.IsAddOnEnabled("Kui_Nameplates") or K.IsAddOnEnabled("bdNameplates") then
	C["Nameplates"].Enable = false
end

if K.IsAddOnEnabled("TipTop") or K.IsAddOnEnabled("TipTac") or K.IsAddOnEnabled("FreebTip") or K.IsAddOnEnabled("bTooltip") or K.IsAddOnEnabled("PhoenixTooltip") or K.IsAddOnEnabled("Icetip") or K.IsAddOnEnabled("rTooltip") then
	C["Tooltip"].Enable = false
end

if K.IsAddOnEnabled("TipTacTalents") then
	C["Tooltip"].Talents = false
end

if K.IsAddOnEnabled("ConsolePortBar") then
	C["DataBars"].Artifact = false
	C["DataBars"].Experience = false
end

if K.IsAddOnEnabled("cInterrupt") then
	C["Announcements"].Interrupt = false
end

if K.IsAddOnEnabled("NiceBubbles") then
	C["Skins"].ChatBubble = false
end

if K.IsAddOnEnabled("ChatSounds") then
	C["Chat"].WhispSound = false
end

if K.IsAddOnEnabled("MBB") or K.IsAddOnEnabled("MinimapButtonFrame") then
	C["Minimap"].CollectButtons = false
end

if K.IsAddOnEnabled("OmniCC") or K.IsAddOnEnabled("ncCooldown") or K.IsAddOnEnabled("CooldownCount") then
	C["Cooldown"].Enable = false
end
