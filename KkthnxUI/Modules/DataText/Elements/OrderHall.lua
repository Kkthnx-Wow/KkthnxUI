local K, C, L = select(2, ...):unpack()
--if not C.DataText.Right == true then return end

local DataText = K.DataTexts
local NameColor = DataText.NameColor
local ValueColor = DataText.ValueColor

local classcolor = ("|cff%.2x%.2x%.2x"):format(K.Color.r * 255, K.Color.g * 255, K.Color.b * 255)

--[[Variables]]--
local format = string.format
local tsort = table.sort
local C_Garrison_HasGarrison = C_Garrison.HasGarrison
local C_GarrisonGetBuildings = C_Garrison.GetBuildings
local C_GarrisonGetCompleteTalent = C_Garrison.GetCompleteTalent
local C_GarrisonGetFollowerShipments = C_Garrison.GetFollowerShipments
local C_GarrisonGetInProgressMissions = C_Garrison.GetInProgressMissions
local C_GarrisonGetInProgressMissions = C_Garrison.GetInProgressMissions
local C_GarrisonGetLandingPageShipmentInfo = C_Garrison.GetLandingPageShipmentInfo
local C_GarrisonGetLandingPageShipmentInfoByContainerID = C_Garrison.GetLandingPageShipmentInfoByContainerID
local C_GarrisonGetLooseShipments = C_Garrison.GetLooseShipments
local C_GarrisonGetTalentTrees = C_Garrison.GetTalentTrees
local C_GarrisonRequestLandingPageShipmentInfo = C_Garrison.RequestLandingPageShipmentInfo
local C_GarrisonRequestLandingPageShipmentInfo = C_Garrison.RequestLandingPageShipmentInfo
local CAPACITANCE_WORK_ORDERS = CAPACITANCE_WORK_ORDERS
local COMPLETE = COMPLETE
local COMPLETE = COMPLETE
local FOLLOWERLIST_LABEL_TROOPS = FOLLOWERLIST_LABEL_TROOPS
local GARRISON_LANDING_SHIPMENT_COUNT = GARRISON_LANDING_SHIPMENT_COUNT
local GARRISON_LANDING_SHIPMENT_COUNT = GARRISON_LANDING_SHIPMENT_COUNT
local GARRISON_TALENT_ORDER_ADVANCEMENT = GARRISON_TALENT_ORDER_ADVANCEMENT
local GetCurrencyInfo = GetCurrencyInfo
local GetMouseFocus = GetMouseFocus
local GetMouseFocus = GetMouseFocus
local HideUIPanel = HideUIPanel
local LE_FOLLOWER_TYPE_GARRISON_6_0 = LE_FOLLOWER_TYPE_GARRISON_6_0
local LE_FOLLOWER_TYPE_GARRISON_7_0 = LE_FOLLOWER_TYPE_GARRISON_7_0
local LE_FOLLOWER_TYPE_GARRISON_7_0 = LE_FOLLOWER_TYPE_GARRISON_7_0
local LE_FOLLOWER_TYPE_SHIPYARD_6_2 = LE_FOLLOWER_TYPE_SHIPYARD_6_2
local LE_GARRISON_TYPE_7_0 = LE_GARRISON_TYPE_7_0
local ORDER_HALL_MISSIONS = ORDER_HALL_MISSIONS
local ShowGarrisonLandingPage = ShowGarrisonLandingPage
local UnitClass = UnitClass

local function sortFunction(a, b) return a.missionEndTime < b.missionEndTime end

local function Update(self, event)
	if not GarrisonMissionFrame then
		LoadAddOn("Blizzard_GarrisonUI")
	elseif not OrderHallMissionFrame then
		LoadAddOn("Blizzard_OrderHallUI")
	end

	local Missions = {}
	C_GarrisonGetInProgressMissions(Missions, LE_FOLLOWER_TYPE_GARRISON_7_0)
	local CountInProgress = 0
	local CountCompleted = 0

	for i = 1, #Missions do
		if Missions[i].inProgress then
			local TimeLeft = Missions[i].timeLeft:match("%d")

			if (TimeLeft ~= "0") then CountInProgress = CountInProgress + 1 else CountCompleted = CountCompleted + 1 end
		end
	end

	if (CountInProgress > 0) then self.Text:SetText(format(L.DataText.NoOrderhallWO, CountCompleted, #Missions)) else self.Text:SetText(classcolor ..(L.DataText.OrderHall)) end
	--self:SetAllPoints(Text)
end

local OnLeave = function()
	GameTooltip:Hide()
end

local OnEnter = function(self)
	if InCombatLockdown() then return end

	C_GarrisonRequestLandingPageShipmentInfo()

	GameTooltip:SetOwner(self:GetTooltipAnchor() )
	GameTooltip:ClearLines()
	GameTooltip:ClearLines()

	if not (C_Garrison_HasGarrison(LE_GARRISON_TYPE_7_0)) then
		GameTooltip:AddLine(L.DataText.NoOrderHallUnlock)
		return
	end

	--[[Loose Work Orders]]--
	local looseShipments = C_GarrisonGetLooseShipments(LE_GARRISON_TYPE_7_0)
	if (looseShipments) then
		for i = 1, #looseShipments do
			local name, _, _, shipmentsReady, shipmentsTotal = C_GarrisonGetLandingPageShipmentInfoByContainerID(looseShipments[i])
			GameTooltip:AddLine(CAPACITANCE_WORK_ORDERS)
			GameTooltip:AddDoubleLine(name, format(GARRISON_LANDING_SHIPMENT_COUNT, shipmentsReady, shipmentsTotal), 1, 1, 1)
		end
	end

	--[[Orderhall Missions]]--
	local inProgressMissions = {}
	C_GarrisonGetInProgressMissions(inProgressMissions, LE_FOLLOWER_TYPE_GARRISON_7_0)
	local numMissions = #inProgressMissions
	if(numMissions > 0) then
		tsort(inProgressMissions, sortFunction)

		if (looseShipments) then GameTooltip:AddLine(" ") end
		GameTooltip:AddLine(ORDER_HALL_MISSIONS)
		for i = 1, numMissions do
			local mission = inProgressMissions[i]
			local timeLeft = mission.timeLeft:match("%d")
			local r, g, b = 1, 1, 1
			if(mission.isRare) then r, g, b = .09, .51, .81 end
			if(timeLeft and timeLeft == "0") then GameTooltip:AddDoubleLine(mission.name, COMPLETE, r, g, b, 0, 1, 0) else GameTooltip:AddDoubleLine(mission.name, mission.timeLeft, r, g, b) end
		end
	end

	--[[Troop Work Orders]]--
	local followerShipments = C_GarrisonGetFollowerShipments(LE_GARRISON_TYPE_7_0)
	local hasFollowers = false
	if (followerShipments) then
		for i = 1, #followerShipments do
			local name, _, _, shipmentsReady, shipmentsTotal = C_GarrisonGetLandingPageShipmentInfoByContainerID(followerShipments[i])
			if (name and shipmentsReady and shipmentsTotal ) then
				if(hasFollowers == false) then
					if(numMissions > 0) then GameTooltip:AddLine(" ") end
					GameTooltip:AddLine(FOLLOWERLIST_LABEL_TROOPS)
					GameTooltip:AddDoubleLine(name, format(GARRISON_LANDING_SHIPMENT_COUNT, shipmentsReady, shipmentsTotal), 1, 1, 1)
					hasFollowers = true
				end
			end
		end
	end

	--[[Talents]]--
	local talentTrees = C_GarrisonGetTalentTrees(LE_GARRISON_TYPE_7_0, select(3, UnitClass("player")))
	local hasTalent = false
	if (followerShipments) then GameTooltip:AddLine(" ") end
	if (talentTrees) then
		local completeTalentID = C_GarrisonGetCompleteTalent(LE_GARRISON_TYPE_7_0)
		for treeIndex, tree in ipairs(talentTrees) do
			for talentIndex, talent in ipairs(tree) do
				local showTalent = false;
				if (talent.isBeingResearched) then
					showTalent = true;
				end
				if (talent.id == completeTalentID) then
					showTalent = true;
				end
				if (showTalent) then
					GameTooltip:AddLine(GARRISON_TALENT_ORDER_ADVANCEMENT)
					GameTooltip:AddDoubleLine(talent.name, format(GARRISON_LANDING_SHIPMENT_COUNT, talent.isBeingResearched and 0 or 1, 1), 1, 1, 1);
				end
			end
		end
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(CURRENCY)
	GameTooltip:AddDoubleLine(K.Currency (1220))
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(L.DataText.ORDERHALLREPORT)
	GameTooltip:Show()
end

local OnMouseDown = function(self)
	if not (C_Garrison_HasGarrison(LE_GARRISON_TYPE_7_0)) then return end
	local isShown = GarrisonLandingPage and GarrisonLandingPage:IsShown()
	if (not isShown) then
		ShowGarrisonLandingPage(LE_GARRISON_TYPE_7_0)
	elseif (GarrisonLandingPage) then
		local currentGarrType = GarrisonLandingPage.garrTypeID
		HideUIPanel(GarrisonLandingPage)
		if (currentGarrType ~= LE_GARRISON_TYPE_7_0) then
			ShowGarrisonLandingPage(LE_GARRISON_TYPE_7_0)
		end
	end
end

local function Enable(self)
	if(not self.Text) then
		local Text = self:CreateFontString(nil, "OVERLAY")
		Text:SetFont(DataText.Font, DataText.Size, DataText.Flags)

		self.Text = Text
	end
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
	self:RegisterEvent("GARRISON_MISSION_LIST_UPDATE")
	self:RegisterEvent("GARRISON_MISSION_STARTED")
	self:RegisterEvent("GARRISON_MISSION_FINISHED")
	self:RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE")
	self:RegisterEvent("GARRISON_LANDINGPAGE_SHIPMENTS")
	self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
	self:RegisterEvent("GARRISON_LANDINGPAGE_SHIPMENTS")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnMouseDown", OnMouseDown )
	self:SetScript("OnEnter", OnEnter )
	self:SetScript("OnLeave", GameTooltip_Hide )
	self:Update()
end

local function Disable(self)
	self.Text:SetText("")
	self:UnregisterAllEvents()
	self:SetScript("OnMouseDown", nil )
	self:SetScript("OnEnter", nil )
	self:SetScript("OnLeave", nil )
	self:SetScript("OnEvent", nil )
end

DataText:Register(L.DataText.OrderHall, Enable, Disable, Update)