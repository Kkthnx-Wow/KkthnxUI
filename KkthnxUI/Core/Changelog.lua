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
		Version = "[10.2.9] - TBA",
		General = "All notable changes to this project will be documented in this file. The format is based on "..K.SystemColor.."[Keep a Changelog]|r and this project adheres to "..K.SystemColor.."[Semantic Versioning]|r",
		Sections = {
			{
				Header = "Added",
				Entries = {
					"New arrow texture",
					"New quest tool for adding helpful tips for some quests and world quests",
				},
			},

			{
				Header = "Fixed",
				Entries = {
					"BNet anchor mover throwing nil error",
				},
			},

			{
				Header = "Removed",
				Entries = {
				},
			},

			{
				Header = "Changed",
				Entries = {
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