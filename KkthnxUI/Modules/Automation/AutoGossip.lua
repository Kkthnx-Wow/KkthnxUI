local K, C = unpack(select(2, ...))
local Module = K:GetModule("Automation")
local AutoGossipEventFrame = CreateFrame("Frame")

-- Automate gossip
local _G = _G
local string_split = _G.string.split

local GetGossipOptions = _G.GetGossipOptions
local GetNumGossipActiveQuests = _G.GetNumGossipActiveQuests
local GetNumGossipAvailableQuests = _G.GetNumGossipAvailableQuests
local GetNumGossipOptions = _G.GetNumGossipOptions
local IsShiftKeyDown = _G.IsShiftKeyDown
local UnitGUID = _G.UnitGUID

-- Function to skip gossip
local function SkipGossip()
    if IsShiftKeyDown() or not KkthnxUIData[K.Realm][K.Name].AutoQuest then
		return
    end

	local _, gossipType = GetGossipOptions()
	if gossipType and gossipType == "gossip" then
		SelectGossipOption(1)
	end
end

-- Event handler
AutoGossipEventFrame:SetScript("OnEvent", function()
	-- Special treatment for specific NPCs
	local npcGuid = UnitGUID("target") or nil
	if npcGuid then
		local _, _, _, _, _, npcID = string_split("-", npcGuid)
		if npcID then
			-- Open rogue doors in Dalaran (Broken Isles) automatically
			if npcID == "96782" or npcID == "93188"	or npcID == "97004" then
				SkipGossip()
				return
			end
		end
    end

	-- Process gossip
	if GetNumGossipOptions() == 1 and GetNumGossipAvailableQuests() == 0 and GetNumGossipActiveQuests() == 0 then
		SkipGossip()
	end
end)

function Module:CreateAutoGossip()
	if C["Automation"].AutoQuest then
		AutoGossipEventFrame:RegisterEvent("GOSSIP_SHOW")
	else
		AutoGossipEventFrame:UnregisterEvent("GOSSIP_SHOW")
	end
end