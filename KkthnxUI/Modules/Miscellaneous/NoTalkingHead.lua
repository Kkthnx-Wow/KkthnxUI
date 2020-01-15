local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

function Module.UpdateTalkingHead(event, ...)
	if (event == "ADDON_LOADED") then
		local addon = ...
		if (addon ~= "Blizzard_TalkingHeadUI") then
			return
		end

		K:UnregisterEvent("ADDON_LOADED", Module.UpdateTalkingHead)
	end

	local Database = C["Misc"]
	local frame = TalkingHeadFrame

	if Database.NoTalkingHead then
		if frame then
			frame:UnregisterEvent("TALKINGHEAD_REQUESTED")
			frame:UnregisterEvent("TALKINGHEAD_CLOSE")
			frame:UnregisterEvent("SOUNDKIT_FINISHED")
			frame:UnregisterEvent("LOADING_SCREEN_ENABLED")
			frame:Hide()
		else
			-- If no frame is found, the addon hasn't been loaded yet,
			-- and it should have been enough to just prevent blizzard from showing it.
			UIParent:UnregisterEvent("TALKINGHEAD_REQUESTED")

			-- Since other addons might load it contrary to our settings, though,
			-- we register our addon listener to take control of it when it's loaded.
			return K:RegisterEvent("ADDON_LOADED", Module.UpdateTalkingHead)
		end
	end
end

function Module:CreateNoTalkingHead()
	Module.UpdateTalkingHead()
end