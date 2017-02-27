local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G

-- Wow API
local UIParent = _G.UIParent
local GetCVar = _G.GetCVar
local DigsiteBar_Init = _G.DigsiteBar_Init

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: ArcheologyDigsiteProgressBar, ArchaeologyFrameArtifactPageSolveFrameStatusBar
-- GLOBALS: UIPARENT_MANAGED_FRAME_POSITIONS, ScriptErrorsFrame, ScriptErrorsFrameScrollFrameText

local Movers = K.Movers

local isInit = false

local function DigsiteBar_Init()
	if not isInit then
		local isLoaded = true

		if not _G.IsAddOnLoaded("Blizzard_ArchaeologyUI") then
			isLoaded = _G.LoadAddOn("Blizzard_ArchaeologyUI")
		end

		if isLoaded then
			ArcheologyDigsiteProgressBar:StripTextures()
			ArcheologyDigsiteProgressBar.FillBar:StripTextures()
			ArcheologyDigsiteProgressBar.FillBar:SetStatusBarTexture(C.Media.Texture)
			ArcheologyDigsiteProgressBar.FillBar:SetStatusBarColor(0.7, 0.2, 0)
			ArcheologyDigsiteProgressBar.FillBar:SetFrameLevel(ArchaeologyFrameArtifactPageSolveFrameStatusBar:GetFrameLevel() + 2)
			ArcheologyDigsiteProgressBar.FillBar:SetBackdrop({bgFile = C.Media.Blank,insets = {left = -1, right = -1, top = -1, bottom = -1}})
			ArcheologyDigsiteProgressBar.FillBar:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])
			ArcheologyDigsiteProgressBar.BarTitle:SetFont(C.Media.Font, C.Media.Font_Size)
			ArcheologyDigsiteProgressBar.BarTitle:SetPoint("CENTER", 0, 16)
			ArcheologyDigsiteProgressBar.BarTitle:SetShadowOffset(K.Mult, K.Mult)
			ArcheologyDigsiteProgressBar:ClearAllPoints()
			ArcheologyDigsiteProgressBar:SetPoint("TOP", UIParent, "TOP", 0, -400)
			UIPARENT_MANAGED_FRAME_POSITIONS["ArcheologyDigsiteProgressBar"] = nil
			Movers:RegisterFrame(ArcheologyDigsiteProgressBar)

			isInit = true

			return true
		end
	end
end

local Loading = CreateFrame("Frame")
Loading:RegisterEvent("PLAYER_LOGIN")
Loading:SetScript("OnEvent", function()
	DigsiteBar_Init()
end)