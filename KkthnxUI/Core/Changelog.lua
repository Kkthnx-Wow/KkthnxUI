local K = unpack(select(2,...))

--[[
### Guiding Principles
Changelogs are for humans, not machines.
There should be an entry for every single version.
The same types of changes should be grouped.
Versions and sections should be linkable.
The latest version comes first.
The release date of each version is displayed.
Mention whether you follow Semantic Versioning.

### Types of changes
-- 'Added' for new features.
-- 'Changed' for changes in existing functionality.
-- 'Deprecated' for soon-to-be removed features.
-- 'Removed' for now removed features.
-- 'Fixed' for any bug fixes.
--]]

local KKUI_ChangeLog = {
	{
		Version = "[10.2.8] - 2021-08-6",
		General = "All notable changes to this project will be documented in this file. The format is based on "..K.SystemColor.."[Keep a Changelog]|r and this project adheres to "..K.SystemColor.."[Semantic Versioning]|r",
		Sections = {
			{
				Header = "Added",
				Entries = {
					"Tank and healer icons for party/raid frames",
					"Button forge addon skin",
					"Check to ignore pixel border option if we are sizing the border",
					"Code to scale the script errors frame",
					"Default loot frame skin (people love the default loot frame i guess)",
					"Domination rank module for tooltips",
					"Domination remove button on item socketing frame to easly remove domination socketed sockets",
					"Domination shards frame on item socketing frame to easly add shards you have",
					"Maw buffs mover in raid, blizz loves this BelowMinimap shit",
					"New actionbar layout 4",
					"No portaits support for party frames",
					"Options to turn off castbar icons",
					"Safety checks with portaits function in unitframes",
					"Wider transmog frame code, it loooooooooks so good",
				},
			},

			{
				Header = "Fixed",
				Entries = {
					"Talking head frame skin",
					"Boss frames mover size being bigger than the frame itself",
					"Chat ebitbox inset so it will not overlap character count",
					"Checkquest slash command",
					"Gold datatext throwing nil error for tooltip on bags",
					"Left over code in actionbar code that was causing an error in hardmode",
					"Nil error with raid index group numbers",
					"Raid debuffs not working at all"
				},
			},

			{
				Header = "Removed",
				Entries = {
					"Font template api",
					"Map pin code as there are so many damn addons to handle it if needed",
				},
			},

			{
				Header = "Changed",
				Entries = {
					"All actionbar code and added global scaling for them",
					"Announcements for interrupts, dispells and more",
					"Aurawatch auras list",
					"Cargbags library code",
					"Extra quest button lists and fixed ignore list",
					"Gui headers names to better flow",
					"Minimap ping code to not be in the middle of minimap",
					"Pulse cooldown code to prevent error if trying to use it when it is off",
					"Quest icon code for nameplates",
					"Quest notifier to be less intrusive when announcing",
					"Raid debuffs lib to use our cooldown timer",
					"Sim craft addon skin code and renabled it",
					"Skip cinematic code to be less intrusive (spacebar)",
					"Sort minimap button code",
					"Unitframe code for sizing health/power properly (player, target, tot, pet, focus, focustarget, party and raid)",
				}
			}
		}
	},
}

local function CreateChangeLog(event)
	if not KkthnxUIDB.Variables[K.Realm][K.Name].InstallComplete then -- Do not show this unless we have installed the UI
		return
	end

	if not KkthnxUIDB.Variables[K.Realm][K.Name].ChangeLog then
		KkthnxUIDB.Variables[K.Realm][K.Name].ChangeLog = {}
	end

	K.ChangeLog:Register(K.Title, KKUI_ChangeLog, KkthnxUIDB.Variables[K.Realm][K.Name].ChangeLog, "lastReadVersion", "onlyShowWhenNewVersion")
	K.ChangeLog:ShowChangelog(K.Title)

	K:UnregisterEvent(event, CreateChangeLog)
end
K:RegisterEvent("PLAYER_ENTERING_WORLD", CreateChangeLog)