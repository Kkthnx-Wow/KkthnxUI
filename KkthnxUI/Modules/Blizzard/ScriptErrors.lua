local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G

-- Wow API
local UIParent = _G.UIParent
local IsAddOnLoaded = _G.IsAddOnLoaded
local LoadAddOn = _G.LoadAddOn

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ScriptErrorsFrame, ScriptErrorsFrameScrollFrameText, EventTraceFrame, FrameStackTooltip
-- GLOBALS: EventTraceTooltip

local isInit = false

local function ScriptErrors_Init()
	if not isInit then
		local isLoaded = true

		if not IsAddOnLoaded("Blizzard_DebugTools") then
			isLoaded = LoadAddOn("Blizzard_DebugTools")
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
				_G["EventTraceFrame"..texs[i]]:SetTexture(nil)
			end

			FrameStackTooltip:HookScript("OnShow", function(self)
				self:SetBackdrop(K.Backdrop)
				self:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])
				self:SetBackdropBorderColor(C.Media.Border_Color[1], C.Media.Border_Color[2], C.Media.Border_Color[3])
			end)

			EventTraceTooltip:HookScript("OnShow", function(self)
				self:SetTemplate("Transparent")
			end)

			isInit = true

			return true
		end
	end
end

local Loading = CreateFrame("Frame")
Loading:RegisterEvent("PLAYER_LOGIN")
if K.WoWBuild == 24015 then
	Loading:SetScript("OnEvent", ScriptErrors_Init)
end