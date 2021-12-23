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
		Version = "[10.2.9] - 2021-12-23",
		General = "All notable changes to this project will be documented in this file. The format is based on "..K.SystemColor.."[Keep a Changelog]|r and this project adheres to "..K.SystemColor.."[Semantic Versioning]|r",
		Sections = {
			{
				Header = "Added",
				Entries = {
					"New API to handle new backdrops in 9.1",
					"New arrow texture",
					"New bags per row options for bank and bags",
					"New bags size updates live now",
					"New map reveal data for 9.1",
					"New map reveal data for Zereth Mortis",
					"New quest tool for adding helpful tips for some quests and world quests",
					"New support added for LibDBIcon",
				},
			},

			{
				Header = "Fixed",
				Entries = {
					"BNet anchor mover throwing nil error",
					"Bag bar icon for main backpack display issue",
					"Cooldowns now obey parent",
					"Guild datatext error",
					"Search in bags should properly work now",
					"TalkingHead backdrop covering the screen",
					"Titles pane throwing c stack overflow :|",
				},
			},

			{
				Header = "Removed",
				Entries = {
					"Compatibility for old patches before 9.1 hit",
				},
			},

			{
				Header = "Changed",
				Entries = {
					"oUF core files",
					"New extra quest button filters",
					"Bags now show timwarped keystones level",
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