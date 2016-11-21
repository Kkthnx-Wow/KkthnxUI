local K, C, L = select(2, ...):unpack()
if not KkthnxUIEditedDefaultConfig then return end

-- This Module loads custom settings for edited package

--[[
	To add your own custom config into your edited version,
	You need to create the addons (example: GoogleUI and
	GoogleUI_Config) and add your custom configuration into
	GoogleUI_Config.
	*!* ----------------------------------------------- *!*
	Example what your config will look like.

	local C = {}

	C["ActionBar"] = {
		["RightBars"] = 3,
		["BottomBars"] = 1,
		["RightBarsMouseover"] = false,
		["SelfCast"] = true,
	}

	KkthnxUIEditedDefaultConfig = C
	*!* ----------------------------------------------- *!*
	Don't forget to add in the .toc, in your edited KkthnxUI
	(ex: GoogleUI) version: ## RequiredDeps: KkthnxUI

	That's it! That's all!
--]]

local settings = KkthnxUIEditedDefaultConfig

for group, options in pairs(settings) do
	if not C[group] then C[group] = {} end

	for option, value in pairs(options) do
		if group ~= "Media" then C[group][option] = value end
	end
end