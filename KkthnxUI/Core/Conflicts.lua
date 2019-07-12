local _, C = unpack(select(2, ...))

-- Prevent Users Config Errors And Using Other UIs Over Mine.

local _G = _G

local DisableAddOn = _G.DisableAddOn
local ReloadUI = _G.ReloadUI
local IsAddOnLoaded = _G.IsAddOnLoaded
local StaticPopupDialogs = _G.StaticPopupDialogs
local StaticPopup_Show = _G.StaticPopup_Show

-- Force User To Disable Kkthnxui If Another Addon Is Enabled With It!
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

-- Auto-Overwrite Script Config Is X Addon Is Found. Here We Use Our Own Functions To Check For Addons.
if C["DataBars"].Enable == false then
	C["DataBars"].TrackHonor = false
end

if IsAddOnLoaded("flyPlateBuffs") then
	C["Nameplates"].TrackAuras = false
end

if IsAddOnLoaded("SexyMap")
or IsAddOnLoaded("bdMinimap")
or IsAddOnLoaded("BasicMinimap")
or IsAddOnLoaded("RicoMiniMap")
or IsAddOnLoaded("Chinchilla") then
	C["Minimap"].Enable = false
end

if IsAddOnLoaded("XPerl")
or IsAddOnLoaded("Stuf")
or IsAddOnLoaded("PitBull4")
or IsAddOnLoaded("ShadowedUnitFrames") then
	C["Unitframe"].Enable = false
	C["Party"].Enable = false
	C["Arena"].Enable = false
	C["Boss"].Enable = false
end

if IsAddOnLoaded("Dominos")
or IsAddOnLoaded("Bartender4")
or IsAddOnLoaded("RazerNaga")
or IsAddOnLoaded("daftMainBar")
or (IsAddOnLoaded("ConsolePortBar") and IsAddOnLoaded("ConsolePort")) then -- We Have To Check For Main Consoleport Addon Too.
	C["DataBars"].Enable = false
	C["ActionBar"].Enable = false
	C["ActionBar"].MicroBar = false
	C["BagBar"].Enable = false
end

if IsAddOnLoaded("Mapster")
or IsAddOnLoaded("WorldQuestsList") then
	C["WorldMap"].SmallWorldMap = false
end

if IsAddOnLoaded("AdiBags")
or IsAddOnLoaded("ArkInventory")
or IsAddOnLoaded("cargBags_Nivaya")
or IsAddOnLoaded("cargBags")
or IsAddOnLoaded("Bagnon")
or IsAddOnLoaded("Combuctor")
or IsAddOnLoaded("TBag")
or IsAddOnLoaded("BaudBag") then
	C["Inventory"].Enable = false
end

if IsAddOnLoaded("Prat-3.0")
or IsAddOnLoaded("Chatter") then
	C["Chat"].Enable = false
end

if IsAddOnLoaded("TidyPlates")
or IsAddOnLoaded("Aloft")
or IsAddOnLoaded("Kui_Nameplates")
or IsAddOnLoaded("bdNameplates")
or IsAddOnLoaded("Plater")
or IsAddOnLoaded("NiceNameplates") then
	C["Nameplates"].Enable = false
end

if IsAddOnLoaded("TipTop")
or IsAddOnLoaded("TipTac")
or IsAddOnLoaded("FreebTip")
or IsAddOnLoaded("bTooltip")
or IsAddOnLoaded("PhoenixTooltip")
or IsAddOnLoaded("Icetip")
or IsAddOnLoaded("rTooltip") then
	C["Tooltip"].Enable = false
end

if IsAddOnLoaded("TipTacTalents") then
	C["Tooltip"].Talents = false
end

if IsAddOnLoaded("NiceBubbles") then
	C["Skins"].ChatBubble = false
end

if IsAddOnLoaded("ChatSounds") then
	C["Chat"].WhispSound = false
end

if IsAddOnLoaded("MBB")
or IsAddOnLoaded("MinimapButtonFrame") then
	C["Minimap"].CollectButtons = false
end

if IsAddOnLoaded("OmniCC")
or IsAddOnLoaded("ncCooldown")
or IsAddOnLoaded("CooldownCount") then
	C["ActionBar"].Cooldowns = false
end