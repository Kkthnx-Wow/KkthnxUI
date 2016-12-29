local K, C, L = unpack(select(2, ...))
if IsAddOnLoaded("MoveAnything") then return end

-- Lua API
local ipairs = ipairs
local strfind = string.find
local tremove = table.remove

-- Wow API
local hooksecurefunc = hooksecurefunc

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: AlertFrame, FIRST_YOFFSET, next, GroupLootContainer, UIPARENT_MANAGED_FRAME_POSITIONS

local Movers = K.Movers

-- AlertFrameMove(by Gethe)
local AlertFrameHolder = CreateFrame("Frame", "AlertFrameHolder", UIParent)
AlertFrameHolder:SetWidth(180)
AlertFrameHolder:SetHeight(20)
AlertFrameHolder:SetPoint("TOP", UIParent, "TOP", 0, -18)
Movers:RegisterFrame(AlertFrameHolder)

local alertBlacklist = {
	GroupLootContainer = C.Loot.GroupLoot,
	TalkingHeadFrame = true
}

local POSITION, ANCHOR_POINT, YOFFSET = "BOTTOM", "TOP", -9

local function CheckGrow()
	local point = AlertFrameHolder:GetPoint()

	if strfind(point, "TOP") or point == "CENTER" or point == "LEFT" or point == "RIGHT" then
		POSITION = "TOP"
		ANCHOR_POINT = "BOTTOM"
		YOFFSET = 9
		FIRST_YOFFSET = YOFFSET - 2
	else
		POSITION = "BOTTOM"
		ANCHOR_POINT = "TOP"
		YOFFSET = -9
		FIRST_YOFFSET = YOFFSET + 2
	end
end

local ReplaceAnchors do
	local function QueueAdjustAnchors(self, relativeAlert)
		CheckGrow()

		for alertFrame in self.alertFramePool:EnumerateActive() do
			alertFrame:ClearAllPoints()
			alertFrame:SetPoint(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET)
			relativeAlert = alertFrame
		end

		-- if C.Loot.GroupLoot then
		-- 	GroupLootContainer:ClearAllPoints()
		-- 	GroupLootContainer:SetPoint(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET)
		-- else
		-- 	GroupLootContainer:ClearAllPoints()
		-- 	GroupLootContainer:SetPoint(POSITION, AlertFrameHolder, POSITION, 2, FIRST_YOFFSET)
		-- end

		return relativeAlert
	end

	local function SimpleAdjustAnchors(self, relativeAlert)
		CheckGrow()

		if self.alertFrame:IsShown() then
			self.alertFrame:ClearAllPoints()
			self.alertFrame:SetPoint(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET)
			return self.alertFrame
		end
		return relativeAlert
	end

	local function AnchorAdjustAnchors(self, relativeAlert)
		if self.anchorFrame:IsShown() then
			return self.anchorFrame
		end
		return relativeAlert
	end

	function ReplaceAnchors(alertFrameSubSystem)
		if alertFrameSubSystem.alertFramePool then
			local frame = alertFrameSubSystem.alertFramePool:GetNextActive()
			if alertBlacklist[alertFrameSubSystem.alertFramePool.frameTemplate] then
				return alertFrameSubSystem.alertFramePool.frameTemplate, true
			else
				alertFrameSubSystem.AdjustAnchors = QueueAdjustAnchors
			end
		elseif alertFrameSubSystem.alertFrame then
			local frame = alertFrameSubSystem.alertFrame
			if alertBlacklist[frame:GetName()] then
				return frame:GetName(), true
			else
				alertFrameSubSystem.AdjustAnchors = SimpleAdjustAnchors
			end
		elseif alertFrameSubSystem.anchorFrame then
			local frame = alertFrameSubSystem.anchorFrame
			if alertBlacklist[frame:GetName()] then
				return frame:GetName(), true
			else
				alertFrameSubSystem.AdjustAnchors = AnchorAdjustAnchors
			end
		end
	end
end

local function SetUpAlert()
	hooksecurefunc(AlertFrame, "UpdateAnchors", function(self)
		CheckGrow()
		self:ClearAllPoints()
		self:SetPoint(POSITION, AlertFrameHolder, POSITION, 2, FIRST_YOFFSET)
	end)

	hooksecurefunc(AlertFrame, "AddAlertFrameSubSystem", function(self, alertFrameSubSystem)
		local _, isBlacklisted = ReplaceAnchors(alertFrameSubSystem)
		if isBlacklisted then
			for i, alertSubSystem in ipairs(AlertFrame.alertFrameSubSystems) do
				if alertFrameSubSystem == alertSubSystem then
					return tremove(AlertFrame.alertFrameSubSystems, i)
				end
			end
		end
	end)

	local remove = {}
	for i, alertFrameSubSystem in ipairs(AlertFrame.alertFrameSubSystems) do
		local name, isBlacklisted = ReplaceAnchors(alertFrameSubSystem)
		if isBlacklisted then
			remove[i] = name
		end
	end

	for i, name in next, remove do
		tremove(AlertFrame.alertFrameSubSystems, i)
	end
end

local Loading = CreateFrame("Frame")
function Loading:OnEvent(event, addon)
	if (event == "PLAYER_LOGIN") then
		SetUpAlert()
	end
end
Loading:RegisterEvent("PLAYER_LOGIN")
Loading:SetScript("OnEvent", Loading.OnEvent)