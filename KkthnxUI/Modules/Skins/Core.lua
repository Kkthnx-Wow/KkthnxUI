local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("BlizzardSkin", "AceEvent-3.0")

K.SkinFuncs = {}
K.SkinFuncs["KkthnxUI"] = {}

function Module:ADDON_LOADED(event, addon)
	if IsAddOnLoaded("Skinner") or IsAddOnLoaded("Aurora") then
		self:UnregisterEvent("ADDON_LOADED")
		return
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