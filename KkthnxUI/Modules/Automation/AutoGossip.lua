local K = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local _G = _G
local string_split = _G.string.split

local GetGossipOptions = _G.GetGossipOptions
local GetNumGossipActiveQuests = _G.GetNumGossipActiveQuests
local GetNumGossipAvailableQuests = _G.GetNumGossipAvailableQuests
local GetNumGossipOptions = _G.GetNumGossipOptions
local IsAltKeyDown = _G.IsAltKeyDown
local IsShiftKeyDown = _G.IsShiftKeyDown
local SelectGossipOption = _G.SelectGossipOption
local UnitGUID = _G.UnitGUID

-- Function to skip gossip
local function SetupSkipGossip()
    if not KkthnxUIData[K.Realm][K.Name].AutoQuest or IsShiftKeyDown() or not IsAltKeyDown() then
		return
	end

    local _, gossipType = GetGossipOptions()
    if gossipType and gossipType == "gossip" then
        SelectGossipOption(1)
    end
end

-- Event handler
function Module:GOSSIP_SHOW()
    -- Special treatment for specific NPCs
    local npcGuid = UnitGUID("target") or nil
    if npcGuid then
        local _, _, _, _, _, npcID = string_split("-", npcGuid)
        if npcID then
            -- Open rogue doors in Dalaran (Broken Isles) automatically
            if npcID == "96782"	-- Lucian Trias
            or npcID == "93188"	-- Mongar
            or npcID == "97004"	-- "Red" Jack Findle
            then
                SetupSkipGossip()
                return
            end
        end
    end

    -- Process gossip
    if GetNumGossipOptions() == 1 and GetNumGossipAvailableQuests() == 0 and GetNumGossipActiveQuests() == 0 then
        SetupSkipGossip()
    end
end

function Module:CreateAutoGossip()
    if not KkthnxUIData[K.Realm][K.Name].AutoQuest then
        return
    end

    K:RegisterEvent("GOSSIP_SHOW", self.GOSSIP_SHOW)
end