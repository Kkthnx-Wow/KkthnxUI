--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/ActionBars/ProcGlow.lua
	Purpose:
		Reskin the spell-activation (proc) glow. LibActionButton shows procs
		through our embedded LibCustomGlow, so we swap that library's overlay-glow
		entry points for a themed pixel or autocast glow in the palette gold. The
		Default style leaves the stock button glow alone.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("ActionBars")

local LCG = LibStub and LibStub("LibCustomGlow-1.0-KkthnxUI", true)
local GLOW_KEY = "KKUI_Proc"

function Module:SetupProcGlow()
	if not LCG then
		return
	end
	local style = C.ActionBar.ProcGlow or "Pixel"
	local color = { K.Colors.gold[1], K.Colors.gold[2], K.Colors.gold[3], 1 }

	if style == "Default" then
		return
	elseif style == "Autocast" then
		LCG.ShowOverlayGlow = function(button)
			LCG.AutoCastGlow_Start(button, color, nil, nil, nil, nil, nil, GLOW_KEY)
		end
		LCG.HideOverlayGlow = function(button)
			LCG.AutoCastGlow_Stop(button, GLOW_KEY)
		end
	else
		-- Pixel glow: a ring of moving segments around the button.
		LCG.ShowOverlayGlow = function(button)
			LCG.PixelGlow_Start(button, color, 8, 0.25, nil, 2, 0, 0, false, GLOW_KEY)
		end
		LCG.HideOverlayGlow = function(button)
			LCG.PixelGlow_Stop(button, GLOW_KEY)
		end
	end
end
