local K = unpack(select(2,...))

local changelog = {
    {
        Version = "10.2.8",
        General = "Below are listed changes for v10.2.8! If you find any issues please report them in KkthnxUI Discord @ https://discord.gg/YUmxqQm",
        Sections = {
            {
                Header = "Added",
                Entries = {
                    "Added back tank and healer icons for party/raid frames",
					"Added button forge addon skin",
					"Added check to ignore pixel border option if we are sizing the border",
					"Added code to scale the script errors frame",
					"Added default loot frame skin (people love the default loot frame i guess)",
					"Added domination rank module for tooltips",
					"Added maw buffs mover in raid, blizz loves this BelowMinimap shit",
					"Added new actionbar layout 4",
					"Added no portaits support for party frames",
					"Added options to turn off castbar icons",
					"Added safety checks with portaits function in unitframes",
					"Added wider transmog frame code, it loooooooooks so good",
                },
			},

			{
				Header = "Fixed",
                Entries = {
                    "Fixed and updated talking head frame skin",
					"Fixed chat ebitbox inset so it will not overlap character count",
					"Fixed checkquest slash command",
					"Fixed gold datatext throwing nil error for tooltip on bags",
					"Fixed left over code in actionbar code that was causing an error in hardmode",
					"Fixed nil error with raid index group numbers",
                },
			},

			{
				Header = "Removed",
                Entries = {
                    "Removed font template api",
					"Removed map pin code as there are so many damn addons to handle it if needed",
                },
			},

			{
				Header = "Updated",
                Entries = {
                    "Update announcements for interrupts, dispells and more",
					"Update pulse cooldown code to prevent error if trying to use it when it is off",
					"Updated all actionbar code and added global scaling for them",
					"Updated aurawatch auras list",
					"Updated cargbags library code",
					"Updated extra quest button lists and fixed ignore list",
					"Updated gui headers names to better flow",
					"Updated minimap ping code to not be in the middle of minimap",
					"Updated quest icon code for nameplates",
					"Updated quest notifier to be less intrusive when announcing",
					"Updated sim craft addon skin code and renabled it",
					"Updated skip cinematic code to be less intrusive (spacebar)",
					"Updated sort minimap button code",
					"Updated unitframe code for sizing health/power properly",
                }
            }
        }
    },
}

local changeLogEventFrame = CreateFrame("Frame")
local function onevent(_, event, addon)
    if ((event == "ADDON_LOADED" and addon == "KkthnxUI") or (event == "PLAYER_LOGIN")) then
        changeLogEventFrame:UnregisterEvent("ADDON_LOADED")
        changeLogEventFrame:UnregisterEvent("PLAYER_LOGIN")

        if not KkthnxUIDB.Variables[K.Realm][K.Name].ChangeLog then
			KkthnxUIDB.Variables[K.Realm][K.Name].ChangeLog = {}
		end

		K.ChangeLog:Register(K.Title, changelog, KkthnxUIDB.Variables[K.Realm][K.Name].ChangeLog, "lastReadVersion", "onlyShowWhenNewVersion")
		K.ChangeLog:ShowChangelog(K.Title)
    end
end
changeLogEventFrame:RegisterEvent("ADDON_LOADED")
changeLogEventFrame:RegisterEvent("PLAYER_LOGIN")
changeLogEventFrame:SetScript("OnEvent", onevent)