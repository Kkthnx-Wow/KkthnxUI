local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

function Module.UpdateTalkingHead(self, event, ...)
	if (event == "ADDON_LOADED") then
		local addon = ...
		if (addon ~= "Blizzard_TalkingHeadUI") then
			return
		end

		K:UnregisterEvent("ADDON_LOADED", Module.UpdateTalkingHead)
	end

	local TalkingHeadFrame = _G.TalkingHeadFrame

	if C["Misc"].NoTalkingHead ~= true then
		if TalkingHeadFrame then
			-- The frame is loaded, so we re-register any needed events,
			-- just in case this is a manual user called re-enabling.
			-- Or in case another addon has disabled it.
			TalkingHeadFrame:RegisterEvent("TALKINGHEAD_REQUESTED")
			TalkingHeadFrame:RegisterEvent("TALKINGHEAD_CLOSE")
			TalkingHeadFrame:RegisterEvent("SOUNDKIT_FINISHED")
			TalkingHeadFrame:RegisterEvent("LOADING_SCREEN_ENABLED")
		else
			-- If the head hasn't been loaded yet, we queue the event.
			return K:RegisterEvent("ADDON_LOADED", Module.UpdateTalkingHead)
		end
	else
		if TalkingHeadFrame then
			TalkingHeadFrame:UnregisterEvent("TALKINGHEAD_REQUESTED")
			TalkingHeadFrame:UnregisterEvent("TALKINGHEAD_CLOSE")
			TalkingHeadFrame:UnregisterEvent("SOUNDKIT_FINISHED")
			TalkingHeadFrame:UnregisterEvent("LOADING_SCREEN_ENABLED")
			TalkingHeadFrame:Hide()
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
	self:UpdateTalkingHead()
end