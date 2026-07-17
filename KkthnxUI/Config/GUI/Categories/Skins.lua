local K = KkthnxUI[1]
K.GUIBuilder = K.GUIBuilder or {}
local B = K.GUIBuilder

function B.CreateSkinsCategory()
	if not B or not B.Ready() then return end
	local K, GUI, C, L, enableTextColor = B.K, B.GUI, B.C, B.L, B.enableTextColor
	local GENERAL, COLORS, PLAYER, TARGET, FILTERS = B.GENERAL, B.COLORS, B.PLAYER, B.TARGET, B.FILTERS

	local skinsIcon = "Interface\\Icons\\INV_Misc_Desecrated_ClothChest"
	local skinsCategory = GUI:AddCategory(L["Skins"], skinsIcon, "Skins")

	local function ResetDetails()
		local skinsModule = K:GetModule("Skins")
		if skinsModule and skinsModule.ResetDetailsAnchor then
			skinsModule:ResetDetailsAnchor(true)
		end
	end

	-- Blizzard Skins
	local blizzardSkinsSection = GUI:AddSection(skinsCategory, L["Blizzard Skins"])
	GUI:CreateSwitch(blizzardSkinsSection, "Skins.BlizzardFrames", L["Skin Some Blizzard Frames & Objects"], L["Skins.BlizzardFrames Desc"], nil, nil, true)
	GUI:CreateSwitch(blizzardSkinsSection, "Skins.ChatBubbles", L["ChatBubbles Skin"], L["Skins.ChatBubbles Desc"], nil, nil, true)
	GUI:CreateSlider(blizzardSkinsSection, "Skins.ChatBubbleAlpha", L["ChatBubbles Background Alpha"], 0, 1, 0.1, L["Skins.ChatBubbleAlpha Desc"])

	-- AddOn Skins (apply at load — toggling mid-session needs /reload)
	local addonSkinsSection = GUI:AddSection(skinsCategory, L["AddOn Skins"])
	GUI:CreateSwitch(addonSkinsSection, "Skins.Bartender4", L["Bartender4 Skin"], L["Skins.Bartender4 Desc"], nil, nil, true)
	GUI:CreateSwitch(addonSkinsSection, "Skins.BigDebuffs", "BigDebuffs Support", L["Skins.BigDebuffs Desc"])
	GUI:CreateSwitch(addonSkinsSection, "Skins.BigWigs", L["BigWigs Skin"], L["Skins.BigWigs Desc"], nil, nil, true)
	GUI:CreateSwitch(addonSkinsSection, "Skins.ButtonForge", L["ButtonForge Skin"], L["Skins.ButtonForge Desc"], nil, nil, true)
	GUI:CreateSwitch(addonSkinsSection, "Skins.ChocolateBar", L["ChocolateBar Skin"], L["Skins.ChocolateBar Desc"], nil, nil, true)
	GUI:CreateSwitch(addonSkinsSection, "Skins.DeadlyBossMods", L["Deadly Boss Mods Skin"], L["Skins.DeadlyBossMods Desc"], nil, nil, true)
	GUI:CreateSwitch(addonSkinsSection, "Skins.Details", L["Details Skin"], L["Skins.Details Desc"], nil, nil, true)
	GUI:CreateSwitch(addonSkinsSection, "Skins.Dominos", L["Dominos Skin"], L["Skins.Dominos Desc"], nil, nil, true)
	GUI:CreateSwitch(addonSkinsSection, "Skins.Hekili", "Hekili Skin", L["Skins.Hekili Desc"], nil, nil, true)
	GUI:CreateSwitch(addonSkinsSection, "Skins.RareScanner", L["RareScanner Skin"], L["Skins.RareScanner Desc"], nil, nil, true)
	GUI:CreateSwitch(addonSkinsSection, "Skins.WeakAuras", L["WeakAuras Skin"], L["Skins.WeakAuras Desc"], nil, nil, true)

	-- Details Reset
	GUI:CreateButtonWidget(addonSkinsSection, "Skins.ResetDetails", L["Reset Details"], L["Reset Details"], L["ResetDetails Desc"], function()
		ResetDetails()
	end)

	-- Font Tweaks
	local fontTweaksSection = GUI:AddSection(skinsCategory, L["Font Tweaks"])
	GUI:CreateSlider(fontTweaksSection, "Skins.QuestFontSize", L["Adjust QuestFont Size"], 10, 30, 1, L["QuestFontSize Desc"])
	GUI:CreateSlider(fontTweaksSection, "Skins.ObjectiveFontSize", L["Adjust ObjectiveFont Size"], 10, 30, 1, L["ObjectiveFontSize Desc"])
end
