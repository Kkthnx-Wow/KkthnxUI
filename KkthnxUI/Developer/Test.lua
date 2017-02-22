-- So I can test stuff.

-- Use this file for testing stuff that I do not want in the UI or I am unsure about.
-- This is a good file to mess around with code in for anyone else as well.

-- CodeName : Code Gone Wild ;D

local K, C, L = unpack(select(2, ...))
if not K.IsDeveloper() and not K.IsDeveloperRealm() then return end -- Check this code.

-- Always debug our temp code.
if LibDebug then LibDebug() end

-- Lua API
local _G = _G

-- Wow API
local UIParent = _G.UIParent
local GetCVar = _G.GetCVar

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: ArcheologyDigsiteProgressBar, ArchaeologyFrameArtifactPageSolveFrameStatusBar
-- GLOBALS: UIPARENT_MANAGED_FRAME_POSITIONS, ScriptErrorsFrame, ScriptErrorsFrameScrollFrameText
-- GLOBALS: EventTraceFrame, FrameStackTooltip, EventTraceTooltip

local Movers = K.Movers

do
	local isInit = false

	local DigsiteProgressBar = CreateFrame("Frame")
	DigsiteProgressBar:RegisterEvent("ADDON_LOADED")
	DigsiteProgressBar:SetScript("OnEvent", function()
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
	end)
end


do
	local isInit = false

	local ScriptErrors = CreateFrame("Frame")
	ScriptErrors:RegisterEvent("ADDON_LOADED")
	ScriptErrors:SetScript("OnEvent", function()
		if not isInit then
			local isLoaded = true

			if not _G.IsAddOnLoaded("Blizzard_DebugTools") then
				isLoaded = _G.LoadAddOn("Blizzard_DebugTools")
			end

			if isLoaded then
				ScriptErrorsFrame:SetParent(UIParent)
				ScriptErrorsFrameScrollFrameText:SetFont(C.Media.Font, 13)
				EventTraceFrame:SetTemplate("Transparent")

				local texs = {
					"TopLeft",
					"TopRight",
					"Top",
					"BottomLeft",
					"BottomRight",
					"Bottom",
					"Left",
					"Right",
					"TitleBG",
					"DialogBG",
				}

				for i = 1, #texs do
					_G["ScriptErrorsFrame"..texs[i]]:SetTexture(nil)
					_G["EventTraceFrame"..texs[i]]:SetTexture(nil)
				end

				FrameStackTooltip:HookScript("OnShow", function(self)
					self:SetBackdrop(K.Backdrop)
					self:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])
					self:SetBackdropBorderColor(C.Media.Backdrop_BorderColor[1], C.Media.Backdrop_BorderColor[2], C.Media.Backdrop_BorderColor[3])
				end)

				EventTraceTooltip:HookScript("OnShow", function(self)
					self:SetTemplate("Transparent")
				end)

				isInit = true

				return true
			end
		end
	end)
end