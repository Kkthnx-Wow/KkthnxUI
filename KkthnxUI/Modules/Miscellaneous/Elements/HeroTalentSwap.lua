--[[-----------------------------------------------------------------------------
-- Hero Talent Swap — right-click hero talent button to swap inactive tree.
-- Overlay uses SetPassThroughButtons for left-click (create out of combat).
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")

local CreateFrame = _G.CreateFrame
local CreateAtlasMarkup = _G.CreateAtlasMarkup
local GameTooltip = _G.GameTooltip
local UnitLevel = _G.UnitLevel
local format = string.format
local ipairs = ipairs
local UIParent = _G.UIParent

local overlay
local RIGHT_CLICK_MARKUP = CreateAtlasMarkup and CreateAtlasMarkup("NPE_RightClick", 18, 18) or "R-Click"

local function GetInactiveHeroSelection()
	if not (C_ClassTalents and C_Traits and C_SpecializationInfo) then
		return
	end
	local configID = C_ClassTalents.GetActiveConfigID()
	if not configID then
		return
	end
	local specIndex = C_SpecializationInfo.GetSpecialization()
	if not specIndex then
		return
	end
	local specID = C_SpecializationInfo.GetSpecializationInfo(specIndex)
	if not specID then
		return
	end
	local specs, requiredLevel = C_ClassTalents.GetHeroTalentSpecsForClassSpec(configID, specID)
	if not specs or (requiredLevel and requiredLevel > UnitLevel("player")) then
		return
	end
	local activeTreeID = C_ClassTalents.GetActiveHeroTalentSpec()
	if not activeTreeID then
		return
	end
	local inactiveTreeID
	for _, treeID in ipairs(specs) do
		if treeID ~= activeTreeID then
			inactiveTreeID = treeID
			break
		end
	end
	if not inactiveTreeID then
		return
	end
	local inactiveTreeInfo = C_Traits.GetSubTreeInfo(configID, inactiveTreeID)
	if not inactiveTreeInfo or not inactiveTreeInfo.subTreeSelectionNodeIDs then
		return
	end
	for _, nodeID in ipairs(inactiveTreeInfo.subTreeSelectionNodeIDs) do
		local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
		if nodeInfo and nodeInfo.isVisible and nodeInfo.isAvailable then
			for _, entryID in ipairs(nodeInfo.entryIDs) do
				local entryInfo = C_Traits.GetEntryInfo(configID, entryID)
				if entryInfo and entryInfo.subTreeID == inactiveTreeID then
					return configID, nodeID, entryID, inactiveTreeInfo
				end
			end
		end
	end
end

local function OnOverlayEnter(self)
	local _, _, _, treeInfo = GetInactiveHeroSelection()
	if not treeInfo then
		return
	end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	local atlas = treeInfo.iconElementID and CreateAtlasMarkup(treeInfo.iconElementID, 16, 16) or ""
	GameTooltip:SetText(RIGHT_CLICK_MARKUP .. " Swap to " .. atlas .. " " .. (treeInfo.name or ""))
	GameTooltip:Show()
end

local function OnOverlayLeave()
	GameTooltip:Hide()
end

local function OnOverlayClick(_, button)
	if button ~= "RightButton" then
		return
	end
	local configID, nodeID, entryID = GetInactiveHeroSelection()
	if configID then
		C_Traits.SetSelection(configID, nodeID, entryID)
	end
end

local function AttachOverlay()
	if not overlay or not PlayerSpellsFrame or not PlayerSpellsFrame.TalentsFrame then
		return
	end
	local container = PlayerSpellsFrame.TalentsFrame.HeroTalentsContainer
	local heroButton = container and container.HeroSpecButton
	if not heroButton then
		return
	end
	overlay:SetParent(heroButton)
	overlay:SetAllPoints()
	overlay:Show()
end

local function EnsureOverlay()
	if not C["Misc"].HeroTalentSwap then
		if overlay then
			overlay:Hide()
		end
		return
	end
	if overlay then
		AttachOverlay()
		return
	end
	-- SetPassThroughButtons is protected — create early out of combat.
	overlay = CreateFrame("Button", nil, UIParent)
	overlay:RegisterForClicks("RightButtonUp")
	if overlay.SetPassThroughButtons then
		overlay:SetPassThroughButtons("LeftButton")
	end
	if overlay.SetPropagateMouseMotion then
		overlay:SetPropagateMouseMotion(true)
	end
	overlay:Hide()
	overlay:SetScript("OnEnter", OnOverlayEnter)
	overlay:SetScript("OnLeave", OnOverlayLeave)
	overlay:SetScript("OnClick", OnOverlayClick)
	AttachOverlay()
end

function Module:CreateHeroTalentSwap()
	if not C["Misc"].HeroTalentSwap then
		return
	end
	-- PlayerSpells is LOD — wait for ADDON_LOADED if it isn't up yet.
	if C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("Blizzard_PlayerSpells") then
		EnsureOverlay()
	else
		local f = CreateFrame("Frame")
		f:RegisterEvent("ADDON_LOADED")
		f:SetScript("OnEvent", function(self, _, name)
			if name == "Blizzard_PlayerSpells" then
				EnsureOverlay()
				self:UnregisterAllEvents()
			end
		end)
	end
end

function Module:UpdateHeroTalentSwap()
	if C["Misc"].HeroTalentSwap then
		Module:CreateHeroTalentSwap()
	elseif overlay then
		overlay:Hide()
		overlay:SetParent(UIParent)
	end
end
