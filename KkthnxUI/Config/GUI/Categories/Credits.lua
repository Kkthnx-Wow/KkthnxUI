local K = KkthnxUI[1]
K.GUIBuilder = K.GUIBuilder or {}
local B = K.GUIBuilder

function B.CreateCreditsCategory()
	if not B or not B.Ready() then return end
	local K, GUI, C, L, enableTextColor = B.K, B.GUI, B.C, B.L, B.enableTextColor
	local GENERAL, COLORS, PLAYER, TARGET, FILTERS = B.GENERAL, B.COLORS, B.PLAYER, B.TARGET, B.FILTERS

	local creditsCategory = GUI:AddCategory(L["Credits"], "Interface\\Icons\\Achievement_General", "Credits")
	local contributorsSection = GUI:AddSection(creditsCategory, L["GUI.Section.Contributors"])

	if GUI.CreateCredits then
		GUI:CreateCredits(contributorsSection, {
			{ name = "Aftermathh" },
			{ name = "Alteredcross", class = "ROGUE" },
			{ name = "Alza" },
			{ name = "Azilroka", class = "SHAMAN" },
			{ name = "Benik", color = "|cff00c0fa" }, -- Custom blue color
			{ name = "Blazeflack" },
			{ name = "Caellian" },
			{ name = "Caith" },
			{ name = "Cassamarra", class = "HUNTER" },
			{ name = "Darth Predator" },
			{ name = "Elv" },
			{ name = "|cffe31c73Faffi|r|cfffc4796GS|r", class = "PRIEST" }, -- Custom colored name
			{ name = "Goldpaw", class = "DRUID" },
			{ name = "Haleth" },
			{ name = "Haste" },
			{ name = "Hungtar" },
			{ name = "Hydra" },
			{ name = "Ishtara" },
			{ name = "LightSpark" },
			{ name = "Magicnachos", class = "PRIEST" },
			{ name = "Merathilis", class = "DRUID" },
			{ name = "moerf", class = "WARLOCK" },
			{ name = "Nightcracker" },
			{ name = "P3lim" },
			{ name = "Palooza", class = "PRIEST" },
			{ name = "Rav99", class = "DEMONHUNTER" },
			{ name = "Roth" },
			{ name = "Shestak" },
			{ name = "|cff49CAF5S|r|cff80C661i|r|cffFFF461m|r|cffF6885Fp|r|cffCD84B9y|r" }, -- Simpy's rainbow colors: Turquoise, Sea Green, Khaki, Salmon, Orchid
			{ name = "siweia" },
		}, "Community Contributors & Supporters")
	end

	-- Special Recognition
	local specialSection = GUI:AddSection(creditsCategory, L["GUI.Section.SpecialRecognition"])

	if GUI.CreateCredits then
		GUI:CreateCredits(specialSection, {
			{ name = "All Beta Testers", color = { 0.8, 0.8, 1, 1 } },
			{ name = "Discord Community", color = { 0.4, 0.6, 1, 1 } },
			{ name = "GitHub Contributors", color = { 0.2, 0.8, 0.2, 1 } },
		}, "Special Thanks")
	end

	-- Message
	local messageSection = GUI:AddSection(creditsCategory, L["GUI.Section.ForeverGrateful"])
	if GUI.CreateCredits then
		GUI:CreateCredits(messageSection, {
			{ name = "To everyone who has supported KkthnxUI since the WOTLK days...", color = { 1, 0.9, 0.7, 1 } },
			{ name = "" },
			{ name = "None of this would be possible without the incredible people", color = { 0.9, 0.9, 0.9, 1 } },
			{ name = "who have stood behind me, believed in this project, and", color = { 0.9, 0.9, 0.9, 1 } },
			{ name = "stuck with me through every expansion, every challenge,", color = { 0.9, 0.9, 0.9, 1 } },
			{ name = "and every moment of doubt.", color = { 0.9, 0.9, 0.9, 1 } },
			{ name = "" },
			{ name = "From those late nights in Northrend to the epic battles", color = { 0.8, 0.9, 1, 1 } },
			{ name = "in the Shadowlands and beyond, you've been there.", color = { 0.8, 0.9, 1, 1 } },
			{ name = "Through bug reports, feature requests, kind words,", color = { 0.8, 0.9, 1, 1 } },
			{ name = "and unwavering loyalty - you made this journey possible.", color = { 0.8, 0.9, 1, 1 } },
			{ name = "" },
			{ name = "Your feedback shaped every feature. Your patience", color = { 1, 0.8, 0.9, 1 } },
			{ name = "carried me through every setback. Your enthusiasm", color = { 1, 0.8, 0.9, 1 } },
			{ name = "fueled every late-night coding session.", color = { 1, 0.8, 0.9, 1 } },
			{ name = "" },
			{ name = "KkthnxUI isn't just an addon - it's a community,", color = { 0.9, 1, 0.8, 1 } },
			{ name = "a family built over years of shared adventures.", color = { 0.9, 1, 0.8, 1 } },
			{ name = "Every line of code carries the spirit of everyone", color = { 0.9, 1, 0.8, 1 } },
			{ name = "who believed this crazy dream could become reality.", color = { 0.9, 1, 0.8, 1 } },
			{ name = "" },
			{ name = "From the bottom of my heart, thank you.", color = { 1, 0.7, 0.7, 1 } },
			{ name = "For your trust. For your friendship. For your support.", color = { 1, 0.7, 0.7, 1 } },
			{ name = "For making this journey more than I ever imagined.", color = { 1, 0.7, 0.7, 1 } },
			{ name = "" },
			{ name = "Here's to many more years of adventure together!", color = { 1, 0.9, 0.5, 1 } },
			{ name = "" },
			{ name = "With endless gratitude and love,", color = { 0.9, 0.8, 1, 1 } },
			{ name = "Kkthnx", color = { 1, 0.6, 0.6, 1 }, atlas = "GarrisonTroops-Health" },
		}, "")
	end
end
