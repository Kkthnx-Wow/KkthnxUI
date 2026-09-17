--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Chat/Debug.lua
	Purpose:
		Instrumentation for the chat window moving itself on a zone change.

		Several rounds of hooking the functions we assumed were responsible did
		not hold, so this records who actually touches the geometry rather than
		guessing again. It watches the chat frame, our holder, the dock, and every
		Blizzard entry point that restores chat geometry.

		Off until switched on, and the stream engine does the rest. See
		Core/Debug.lua.

			/kkdebug chat
			teleport
			/kkdebug dump chat
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:NewModule("ChatDebug")

-- Registered at load rather than on enable, so the stream is listed by /kkdebug
-- even if something later in setup fails.
local stream = K.Debug.Register("chat", "Chat window position and size")

function Module:OnEnable()
	local chat = _G.ChatFrame1
	if not chat then
		return
	end
	stream:Watch(chat, "ChatFrame1")
	stream:Watch(_G.GeneralDockManager, "Dock")

	-- The chat stays anchored to the holder while its resolved position changes,
	-- so the holder and the mover under it are what actually need watching.
	local holder = _G.KKUI_ChatHolder
	local mover = holder and holder.KKUI_Mover
	if holder then
		stream:Watch(holder, "Holder")
	else
		stream:Log("WARNING: KKUI_ChatHolder does not exist, holder is unwatched")
	end
	if mover then
		stream:Watch(mover, "Mover")
	else
		stream:Log("WARNING: no mover on the holder, mover is unwatched")
	end

	-- Blizzard's own restore paths. Any of these firing right before the window
	-- lands somewhere new names the culprit.
	for _, name in ipairs({
		"FCF_RestorePositionAndDimensions",
		"FCF_SavePositionAndDimensions",
		"FloatingChatFrame_Update",
		"FCF_DockFrame",
		"FCF_UnDockFrame",
		"FCFDock_UpdateTabs",
		"FCF_SetWindowSize",
		"ChatFrame_Update",
	}) do
		stream:WatchGlobal(name)
	end

	if _G.EditModeManagerFrame then
		stream:WatchMethod(_G.EditModeManagerFrame, "UpdateLayoutInfo", "EditMode:UpdateLayoutInfo")
		stream:WatchMethod(_G.EditModeManagerFrame, "UpdateSystems", "EditMode:UpdateSystems")
	end
	stream:WatchMethod(chat, "ApplySystemAnchor", "Chat:ApplySystemAnchor")
	stream:WatchMethod(chat, "UpdateSystemSettingWidth", "Chat:UpdateSystemSettingWidth")
	stream:WatchMethod(chat, "UpdateSystemSettingHeight", "Chat:UpdateSystemSettingHeight")

	-- Snapshot the resolved rect on everything that brackets a zone change, so
	-- the log has a before and an after either side of whatever moved it.
	stream:Events({
		"PLAYER_LEAVING_WORLD",
		"PLAYER_ENTERING_WORLD",
		"LOADING_SCREEN_DISABLED",
		"UPDATE_CHAT_WINDOWS",
		"UPDATE_FLOATING_CHAT_WINDOWS",
		"UI_SCALE_CHANGED",
		"DISPLAY_SIZE_CHANGED",
		"EDIT_MODE_LAYOUTS_UPDATED",
	}, chat)

	-- Snapshot the whole chain on the same events, since the last log showed the
	-- chat anchored correctly while its resolved position still changed, which can
	-- only mean something above it in the chain moved.
	local chain = CreateFrame("Frame")
	for _, event in ipairs({ "PLAYER_ENTERING_WORLD", "LOADING_SCREEN_DISABLED", "EDIT_MODE_LAYOUTS_UPDATED", "PLAYER_LEAVING_WORLD" }) do
		chain:RegisterEvent(event)
	end
	chain:SetScript("OnEvent", function(_, event)
		stream:Snapshot(_G.KKUI_ChatHolder, event .. " holder")
		stream:Snapshot(_G.KKUI_ChatHolder and _G.KKUI_ChatHolder.KKUI_Mover, event .. " mover")
		-- The settled reads are the ones that say where things really are.
		stream:SnapshotSettled(_G.KKUI_ChatHolder, event .. " holder")
		stream:SnapshotSettled(_G.GeneralDockManager, event .. " dock")
	end)
end
