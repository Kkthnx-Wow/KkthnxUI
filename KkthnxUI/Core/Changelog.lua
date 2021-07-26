local K = unpack(select(2,...))

local KKUI_ChangeLog = {
	{
		Version = "10.2.8.Beta",
		General = "10.2.8 is not officially released yet so anything you see below could change between now and release. There is no release date as of right now so do not ask!",
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
					"Added domination remove button on item socketing frame to easly remove domination socketed sockets",
					"Added domination shards frame on item socketing frame to easly add shards you have",
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
					"Fixed boss frames mover size being bigger than the frame itself",
					"Fixed chat ebitbox inset so it will not overlap character count",
					"Fixed checkquest slash command",
					"Fixed gold datatext throwing nil error for tooltip on bags",
					"Fixed left over code in actionbar code that was causing an error in hardmode",
					"Fixed nil error with raid index group numbers",
					"Fixed raid debuffs not working at all"
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
					"Updated all actionbar code and added global scaling for them",
					"Updated announcements for interrupts, dispells and more",
					"Updated aurawatch auras list",
					"Updated cargbags library code",
					"Updated extra quest button lists and fixed ignore list",
					"Updated gui headers names to better flow",
					"Updated minimap ping code to not be in the middle of minimap",
					"Updated pulse cooldown code to prevent error if trying to use it when it is off",
					"Updated quest icon code for nameplates",
					"Updated quest notifier to be less intrusive when announcing",
					"Updated raid debuffs lib to use our cooldown timer",
					"Updated sim craft addon skin code and renabled it",
					"Updated skip cinematic code to be less intrusive (spacebar)",
					"Updated sort minimap button code",
					"Updated unitframe code for sizing health/power properly (player, target, tot, pet, focus, focustarget, party and raid)",
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

		K.ChangeLog:Register(K.Title, KKUI_ChangeLog, KkthnxUIDB.Variables[K.Realm][K.Name].ChangeLog, "lastReadVersion", "onlyShowWhenNewVersion")
		K.ChangeLog:ShowChangelog(K.Title)
	end
end
changeLogEventFrame:RegisterEvent("ADDON_LOADED")
changeLogEventFrame:RegisterEvent("PLAYER_LOGIN")
changeLogEventFrame:SetScript("OnEvent", onevent)