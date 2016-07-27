local K, C, L, _ = select(2, ...):unpack()

local _G = _G
local unpack, pairs, print = unpack, pairs, print
local InCombatLockdown = InCombatLockdown
local CreateFrame, UIParent = CreateFrame, UIParent

-- Movement Function(by Allez)
K.MoverFrames = {
	AchievementAnchor,
	ActionBarAnchor,
	BuffsAnchor,
	COOLDOWN_Anchor,
	LootRollAnchor,
	MinimapAnchor,
	PVE_PVP_CC_Anchor,
	PVE_PVP_DEBUFF_Anchor,
	P_BUFF_ICON_Anchor,
	P_PROC_ICON_Anchor,
	PetActionBarAnchor,
	PlayerCastbarAnchor,
	PlayerFrameAnchor,
	PowerBarAnchor,
	PulseCDAnchor,
	RightActionBarAnchor,
	SPECIAL_P_BUFF_ICON_Anchor,
	ShiftHolder,
	T_BUFF_Anchor,
	T_DEBUFF_ICON_Anchor,
	T_DE_BUFF_BAR_Anchor,
	TargetCastbarAnchor,
	TargetCastbarAnchor,
	TargetFrameAnchor,
	TooltipAnchor,
	TotemHolder,
	VehicleAnchor,
	WatchFrameAnchor,
}

local moving = false
local movers = {}
local placed = {
	"Butsu",
	"StuffingFrameBags",
	"StuffingFrameBank",
	"alDamageMeterFrame",
	"PlayerFrame",
	"TargetFrame",
}

local SetPosition = function(mover)
	local ap, _, rp, x, y = mover:GetPoint()
	SavedPositions[mover.frame:GetName()] = {ap, "UIParent", rp, x, y}
end

local OnDragStart = function(self)
	self:StartMoving()
	self.frame:ClearAllPoints()
	self.frame:SetAllPoints(self)
end

local OnDragStop = function(self)
	self:StopMovingOrSizing()
	SetPosition(self)
end

local CreateMover = function(frame)
	local mover = CreateFrame("Frame", nil, UIParent)
	mover:SetBackdrop(K.Backdrop)
	mover:SetBackdropColor(unpack(C.Media.Backdrop_Color))
	mover:SetBackdropBorderColor(.18, .71, 1, 1)
	mover:SetAllPoints(frame)
	mover:SetFrameStrata("TOOLTIP")
	mover:EnableMouse(true)
	mover:SetMovable(true)
	mover:SetClampedToScreen(true)
	mover:RegisterForDrag("LeftButton")
	mover:SetScript("OnDragStart", OnDragStart)
	mover:SetScript("OnDragStop", OnDragStop)
	mover:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(K.Color.r, K.Color.g, K.Color.b) end)
	mover:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(0.18, 0.71, 1) end)
	mover.frame = frame

	mover.name = mover:CreateFontString(nil, "OVERLAY")
	mover.name:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
	mover.name:SetPoint("CENTER")
	mover.name:SetTextColor(1, 1, 1)
	mover.name:SetText(frame:GetName())
	mover.name:SetWidth(frame:GetWidth() - 4)
	movers[frame:GetName()] = mover
end

local GetMover = function(frame)
	if movers[frame:GetName()] then
		return movers[frame:GetName()]
	else
		return CreateMover(frame)
	end
end

local InitMove = function(msg)
	if InCombatLockdown() then print("|cffffe02e"..ERR_NOT_IN_COMBAT.."|r") return end
	if msg and (msg == "reset" or msg == "куыуе") then
		SavedPositions = {}
		for i, v in pairs(placed) do
			if _G[v] then
				_G[v]:SetUserPlaced(false)
			end
		end
		ReloadUI()
		return
	end
	if not moving then
		for i, v in pairs(K.MoverFrames) do
			local mover = GetMover(v)
			if mover then mover:Show() end
		end
		moving = true
	else
		for i, v in pairs(movers) do
			v:Hide()
		end
		moving = false
	end
end

local RestoreUI = function(self)
	if InCombatLockdown() then
		if not self.shedule then self.shedule = CreateFrame("Frame", nil, self) end
		self.shedule:RegisterEvent("PLAYER_REGEN_ENABLED")
		self.shedule:SetScript("OnEvent", function(self)
			RestoreUI(self:GetParent())
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
			self:SetScript("OnEvent", nil)
		end)
		return
	end
	for frame_name, point in pairs(SavedPositions) do
		if _G[frame_name] then
			_G[frame_name]:ClearAllPoints()
			_G[frame_name]:SetPoint(unpack(point))
		end
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent(event)
	RestoreUI(self)
end)

SlashCmdList.MOVING = InitMove
SLASH_MOVING1 = "/moveui"