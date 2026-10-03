--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Chat/History.lua
	Purpose:
		Keep recent player chat across a reload or relog. We capture the finished
		line as it reaches the chat frame (player links, class colours, and channel
		prefix already in it), save it per character, and replay it under a quiet
		divider the next time you log in.

		Kept safe for Midnight: a secret line is never stored, capture only keeps
		real player chat (lines that carry a player link, so system and loot spam
		stay out), and replay only writes to the chat frame through AddMessage, so
		no protected or secret path is ever touched. Restore is skipped where the
		client has forced addon chat restrictions.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("Chat")

local _G = _G
local ipairs = ipairs
local tremove = table.remove
local UnitName = UnitName
local GetRealmName = GetRealmName
local GetServerTime = GetServerTime
local GetCVarBool = GetCVarBool
local IsSecret = K.IsSecret

local NUM_FRAMES = Constants.ChatFrameConstants.MaxChatWindows
local MAX_LINES = 100 -- how many lines we keep per character
local MAX_AGE = 60 * 60 * 24 * 3 -- drop anything older than three days on restore
local MAX_TEXT = 4096

local buffer = {}
local restoring = false -- replayed lines must not be captured again

local function CharKey()
	local name = UnitName("player")
	local realm = GetRealmName()
	if not name or not realm then
		return nil
	end
	return name .. " - " .. realm
end

-- Only keep genuine player chat: those lines carry a player or Battle.net link.
-- System, loot, and combat text do not, so this keeps the log clean on its own.
local function IsPlayerChat(text)
	return text:find("|Hplayer:", 1, true) or text:find("|HBNplayer:", 1, true)
end

local function Capture(frame, text)
	if restoring or not C.Chat.HistoryPersist then
		return
	end
	if type(text) ~= "string" or IsSecret(text) or #text > MAX_TEXT then
		return
	end
	if not IsPlayerChat(text) then
		return
	end
	buffer[#buffer + 1] = { text = text, t = GetServerTime(), f = frame:GetID() }
	if #buffer > MAX_LINES then
		tremove(buffer, 1)
	end
end

-- Replay the saved lines under a divider so it is clear where the old session
-- ends and the live one begins. Each line goes back to the window it came from,
-- so whispers return to the whisper tab and not into General. Lines saved before
-- the window was recorded go to the main window. The lines that are still fresh
-- seed the buffer with their original times, so a line ages out three days after
-- it was said rather than three days after it was last replayed.
local function Restore(saved)
	if not saved or #saved == 0 then
		return
	end
	if GetCVarBool and GetCVarBool("addonChatRestrictionsForced") then
		return
	end

	local now = GetServerTime()
	local dividers = {}
	restoring = true
	for _, line in ipairs(saved) do
		if type(line) == "table" and type(line.text) == "string" and not IsSecret(line.text) then
			if not line.t or (now - line.t) < MAX_AGE then
				local id = line.f
				local frame = id and _G["ChatFrame" .. id] or _G.ChatFrame1
				if not frame then
					frame = _G.ChatFrame1
				end
				if frame and not dividers[frame] then
					dividers[frame] = true
					frame:AddMessage(" ")
					frame:AddMessage("|cff669dff" .. (K.Title or "KkthnxUI") .. ":|r previous chat", 0.6, 0.6, 0.6)
				end
				if frame then
					frame:AddMessage(line.text)
					buffer[#buffer + 1] = line
				end
			end
		end
	end
	restoring = false

	while #buffer > MAX_LINES do
		tremove(buffer, 1)
	end
end

function Module:SetupHistory()
	if not C.Chat.HistoryPersist then
		return
	end
	if type(_G.KkthnxUIDB) ~= "table" then
		return
	end
	_G.KkthnxUIDB.chatHistory = _G.KkthnxUIDB.chatHistory or {}

	local key = CharKey()
	if not key then
		return
	end

	-- Capture the line as each frame prints it. The hook gets the same arguments the
	-- frame did, before our own AddMessage wrappers reshape the text, which is what
	-- we want: the replay goes back through those wrappers.
	for i = 1, NUM_FRAMES do
		local frame = _G["ChatFrame" .. i]
		if frame and frame.AddMessage then
			hooksecurefunc(frame, "AddMessage", Capture)
		end
	end

	-- Replay last session. The fresh lines land in the buffer, so the next logout
	-- keeps a rolling window rather than resetting it.
	local saved = _G.KkthnxUIDB.chatHistory[key]
	if saved then
		Restore(saved)
	end

	-- Persist on logout and reload.
	local watcher = CreateFrame("Frame")
	watcher:RegisterEvent("PLAYER_LOGOUT")
	watcher:SetScript("OnEvent", function()
		if C.Chat.HistoryPersist then
			_G.KkthnxUIDB.chatHistory[key] = buffer
		end
	end)
end
