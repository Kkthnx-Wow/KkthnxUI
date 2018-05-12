local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("BlizzardSkin", "AceEvent-3.0")

local _G = _G
local pairs = pairs
local type = type

local hooksecurefunc = _G.hooksecurefunc
local IsAddOnLoaded = _G.IsAddOnLoaded

K.SkinFuncs = {}
K.SkinFuncs["KkthnxUI"] = {}

-- DropDownMenu library support
function K.SkinLibDropDownMenu(prefix)
	if _G[prefix.."_UIDropDownMenu_CreateFrames"] and not K[prefix.."_UIDropDownMenuSkinned"] then
		local bd = _G[prefix.."_DropDownList1Backdrop"]
		local mbd = _G[prefix.."_DropDownList1MenuBackdrop"]
		if bd and not bd.template then
			bd:SetTemplate("Transparent", true)
		end
		if mbd and not mbd.template then
			mbd:SetTemplate("Transparent", true)
		end

		K[prefix.."_UIDropDownMenuSkinned"] = true
		hooksecurefunc(prefix.."_UIDropDownMenu_CreateFrames", function()
			local lvls = _G[(prefix == "Lib" and "LIB" or prefix).."_UIDROPDOWNMENU_MAXLEVELS"]
			local ddbd = lvls and _G[prefix.."_DropDownList"..lvls.."Backdrop"]
			local ddmbd = lvls and _G[prefix.."_DropDownList"..lvls.."MenuBackdrop"]
			if ddbd and not ddbd.template then
				ddbd:SetTemplate("Transparent", true)
			end
			if ddmbd and not ddmbd.template then
				ddmbd:SetTemplate("Transparent", true)
			end
		end)
	end
end

function Module:ADDON_LOADED(event, addon)
	if IsAddOnLoaded("Skinner") or IsAddOnLoaded("Aurora") then
		self:UnregisterEvent("ADDON_LOADED")
		return
	end

	if not K.L_UIDropDownMenuSkinned then -- LibUIDropDownMenu
		K.SkinLibDropDownMenu("L")
	end
	if not K.Lib_UIDropDownMenuSkinned then -- NoTaint_UIDropDownMenu
		K.SkinLibDropDownMenu("Lib")
	end

	for _addon, skinfunc in pairs(K.SkinFuncs) do
		if type(skinfunc) == "function" then
			if _addon == addon then
				if skinfunc then
					skinfunc()
				end
			end
		elseif type(skinfunc) == "table" then
			if _addon == addon then
				for _, skinfunc in pairs(K.SkinFuncs[_addon]) do
					if skinfunc then
						skinfunc()
					end
				end
			end
		end
	end
end

Module:RegisterEvent("ADDON_LOADED")