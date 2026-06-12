--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Highlights the player's own name and guild tags in chat.
-- - Design: Uses ChatFrame_AddMessageEventFilter for efficient filtering.
-- - Events: Various chat message events.
-----------------------------------------------------------------------------]]
local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Chat")

-- PERF: Localize frequently used functions
local string_gsub = string.gsub

-- ---------------------------------------------------------------------------
-- Highlight Pattern Logic
-- ---------------------------------------------------------------------------
-- Highlights for professional and distinct colors
local HIGHLIGHT_COLOR = "|cff669DFF" -- KkthnxUI Blue
local GUILD_COLOR = "|cff40ff40"     -- Guild Green

-- Cached patterns for performance
local namePattern
local guildPattern = "(<[^>]+>)"

-- REASON: Escapes Lua pattern magic characters to prevent logic errors with special names.
local function GetNamePattern(name)
    local escaped = name:gsub("([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
    return "%f[%a]" .. escaped .. "%f[%A]"
end

-- ---------------------------------------------------------------------------
-- Message Filter
-- ---------------------------------------------------------------------------
-- WARNING: This runs on every chat message. Keep logic minimal to prevent frame rate drops.
local function HighlightFilter(_, _, msg, ...)
    if not msg then
        return
    end

    local changed = false

    -- 1. Highlight Player Name
    if C["Chat"].HighlightPlayer then
        if not namePattern then
            namePattern = GetNamePattern(K.Name)
        end
        local newMsg, count = string_gsub(msg, namePattern, HIGHLIGHT_COLOR .. "%0|r")
        if count > 0 then
            msg = newMsg
            changed = true
        end
    end

    -- 2. Highlight Guild Tags
    if C["Chat"].HighlightGuild then
        local newMsg, count = string_gsub(msg, guildPattern, GUILD_COLOR .. "%1|r")
        if count > 0 then
            msg = newMsg
            changed = true
        end
    end

    if changed then
        return false, msg, ...
    end
end

-- ---------------------------------------------------------------------------
-- Module Registration
-- ---------------------------------------------------------------------------
local events = {
    "CHAT_MSG_BN_WHISPER",
    "CHAT_MSG_BN_WHISPER_INFORM",
    "CHAT_MSG_CHANNEL",
    "CHAT_MSG_COMMUNITIES_CHANNEL",
    "CHAT_MSG_GUILD",
    "CHAT_MSG_INSTANCE_CHAT",
    "CHAT_MSG_INSTANCE_CHAT_LEADER",
    "CHAT_MSG_OFFICER",
    "CHAT_MSG_PARTY",
    "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_RAID_WARNING",
    "CHAT_MSG_SAY",
    "CHAT_MSG_WHISPER",
    "CHAT_MSG_WHISPER_INFORM",
    "CHAT_MSG_YELL",
}

function Module:CreateChatHighlight()
    if not C["Chat"].Enable then
        return
    end

    for _, event in ipairs(events) do
        ChatFrame_AddMessageEventFilter(event, HighlightFilter)
    end
end
