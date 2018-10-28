local K, C = unpack(select(2, ...))
local Module = K:NewModule("NoTalkingHead", "AceEvent-3.0")

function Module:UpdateTalkingHead(event, ...)
	if (event == "ADDON_LOADED") then
		local addon = ...
		if (addon ~= "Blizzard_TalkingHeadUI") then
			return
		end
		self:UnregisterEvent("ADDON_LOADED", "UpdateTalkingHead")
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
			return self:RegisterEvent("ADDON_LOADED", "UpdateTalkingHead")
		end
	end
end

function Module:OnEnable()
	self:UpdateTalkingHead()
end