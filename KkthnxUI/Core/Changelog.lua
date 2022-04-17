local K = unpack(select(2, ...))

local function CreateChangeLog(event)
	if not KkthnxUIDB.Variables[K.Realm][K.Name].InstallComplete then -- Do not show this unless we have installed the UI
		return
	end

	K.ChangeLog:Register(K.Title, K.Changelog, KkthnxUIDB.ChangeLog, "lastReadVersion", "onlyShowWhenNewVersion")
	K.ChangeLog:ShowChangelog(K.Title)

	K:UnregisterEvent(event, CreateChangeLog)
end
K:RegisterEvent("PLAYER_ENTERING_WORLD", CreateChangeLog)
