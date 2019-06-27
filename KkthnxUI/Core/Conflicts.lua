local K, C = unpack(select(2, ...))

-- Prevent users config errors and using other UIs over mine.

local _G = _G

local DisableAddOn = _G.DisableAddOn
local ReloadUI = _G.ReloadUI
local IsAddOnLoaded = _G.IsAddOnLoaded

-- Force user to disable KkthnxUI if another AddOn is enabled with it!
if IsAddOnLoaded("KkthnxUI") and IsAddOnLoaded("Tukui") or IsAddOnLoaded("ElvUI") or IsAddOnLoaded("DiabolicUI") or IsAddOnLoaded("DuffedUI") or IsAddOnLoaded("ShestakUI") then
	StaticPopupDialogs.KKTHNXUI_INCOMPATIBLE = {
		text = "Oh no, you have |cff4488ffKkthnxUI|r and another UserInterface enabled at the same time. Disable KkthnxUI!",
		button1 = "Disable KkthnxUI",
		OnAccept = function()
			DisableAddOn("KkthnxUI")
			ReloadUI()
		end,
		OnCancel = function()
			DisableAddOn("KkthnxUI")
			ReloadUI()
		end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 0,
		showAlert = 1,
		EditBoxOnEscapePressed = function()
			DisableAddOn("KkthnxUI")
			ReloadUI()
		end,
	}

	StaticPopup_Show("KKTHNXUI_INCOMPATIBLE")
	return
end

-- Auto-overwrite script config is X addon is found. Here we use our own functions to check for addons.
if C["DataBars"].Enable == false then
	C["DataBars"].TrackHonor = false
end

if K.CheckAddOnState("flyPlateBuffs") then
	C["Nameplates"].TrackAuras = false
end

if K.CheckAddOnState("SexyMap")
or K.CheckAddOnState("bdMinimap")
or K.CheckAddOnState("BasicMinimap")
or K.CheckAddOnState("RicoMiniMap")
or K.CheckAddOnState("Chinchilla") then
	C["Minimap"].Enable = false
end

if K.CheckAddOnState("XPerl")
or K.CheckAddOnState("Stuf")
or K.CheckAddOnState("PitBull4")
or K.CheckAddOnState("ShadowedUnitFrames") then
	C["Unitframe"].Enable = false
	C["Party"].Enable = false
	C["Arena"].Enable = false
	C["Boss"].Enable = false
end

if K.CheckAddOnState("Dominos")
or K.CheckAddOnState("Bartender4")
or K.CheckAddOnState("RazerNaga")
or K.CheckAddOnState("daftMainBar")
or (K.CheckAddOnState("ConsolePortBar") and K.CheckAddOnState("ConsolePort")) then -- We have to check for main ConsolePort addon too.
	C["ActionBar"].Enable = false
end

if K.CheckAddOnState("Mapster")
or K.CheckAddOnState("WorldQuestsList") then
	C["WorldMap"].SmallWorldMap = false
end

if K.CheckAddOnState("AdiBags")
or K.CheckAddOnState("ArkInventory")
or K.CheckAddOnState("cargBags_Nivaya")
or K.CheckAddOnState("cargBags")
or K.CheckAddOnState("Bagnon")
or K.CheckAddOnState("Combuctor")
or K.CheckAddOnState("TBag")
or K.CheckAddOnState("BaudBag") then
	C["Inventory"].Enable = false
end

if K.CheckAddOnState("Prat-3.0")
or K.CheckAddOnState("Chatter") then
	C["Chat"].Enable = false
end

if K.CheckAddOnState("TidyPlates")
or K.CheckAddOnState("Aloft")
or K.CheckAddOnState("Kui_Nameplates")
or K.CheckAddOnState("bdNameplates")
or K.CheckAddOnState("NiceNameplates") then
	C["Nameplates"].Enable = false
end

if K.CheckAddOnState("TipTop")
or K.CheckAddOnState("TipTac")
or K.CheckAddOnState("FreebTip")
or K.CheckAddOnState("bTooltip")
or K.CheckAddOnState("PhoenixTooltip")
or K.CheckAddOnState("Icetip")
or K.CheckAddOnState("rTooltip") then
	C["Tooltip"].Enable = false
end

if K.CheckAddOnState("TipTacTalents") then
	C["Tooltip"].Talents = false
end

if K.CheckAddOnState("ConsolePortBar") then
	C["DataBars"].Enable = false
end

if K.CheckAddOnState("cInterrupt") then
	C["Announcements"].Interrupt = false
end

if K.CheckAddOnState("NiceBubbles") then
	C["Skins"].ChatBubble = false
end

if K.CheckAddOnState("ChatSounds") then
	C["Chat"].WhispSound = false
end

if K.CheckAddOnState("MBB")
or K.CheckAddOnState("MinimapButtonFrame") then
	C["Minimap"].CollectButtons = false
end

if K.CheckAddOnState("OmniCC")
or K.CheckAddOnState("ncCooldown")
or K.CheckAddOnState("CooldownCount") then
	C["ActionBar"].Cooldowns = false
end