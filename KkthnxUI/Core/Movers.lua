local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local table_insert = table.insert
local unpack = unpack
local pairs = pairs

-- Wow API
local CreateFrame = _G.CreateFrame
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT
local InCombatLockdown = _G.InCombatLockdown
local Name = _G.UnitName("player")
local Realm = _G.GetRealmName()
local UIParent = _G.UIParent

local Movers = CreateFrame("Frame")
Movers:RegisterEvent("PLAYER_ENTERING_WORLD")
Movers:RegisterEvent("PLAYER_REGEN_DISABLED")
Movers.Frames = {}
Movers.Defaults = {}

local classColor = K.Class == "PRIEST" and K.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[K.Class] or RAID_CLASS_COLORS[K.Class])

local function SetModifiedBackdrop(self)
	if self.Backdrop then self = self.Backdrop end
	self:SetBackdropColor(classColor.r * .15, classColor.g * .15, classColor.b * .15, C["Media"].BackdropColor[4])
end

local function SetOriginalBackdrop(self)
	if self.Backdrop then self = self.Backdrop end
	self:SetBackdropColor(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])
end

function Movers:SaveDefaults(frame, a1, p, a2, x, y)
	if not a1 then
		return
	end

	if not p then
		p = UIParent
	end

	local Data = Movers.Defaults
	local Frame = frame:GetName()

	Data[Frame] = {a1, p:GetName(), a2, x, y}
end

function Movers:RestoreDefaults(button)
	local FrameName = self.Parent:GetName()
	local Data = Movers.Defaults[FrameName]
	local SavedVariables = KkthnxUIData[Realm][Name].Movers

	if (button == "RightButton") and (Data) then
		local Anchor1, ParentName, Anchor2, X, Y = unpack(Data)
		local Frame = _G[FrameName]
		local Parent = _G[ParentName]

		Frame:ClearAllPoints()
		Frame:SetPoint(Anchor1, Parent, Anchor2, X, Y)

		Frame.DragInfo:ClearAllPoints()
		Frame.DragInfo:SetAllPoints(Frame)

		-- Delete Saved Variable
		SavedVariables[FrameName] = nil
	end
end

function Movers:RegisterFrame(frame)
	local Anchor1, Parent, Anchor2, X, Y = frame:GetPoint()

	table_insert(self.Frames, frame)

	self:SaveDefaults(frame, Anchor1, Parent, Anchor2, X, Y)
end

function Movers:OnDragStart()
	self:StartMoving()
end

function Movers:OnDragStop()
	self:StopMovingOrSizing()

	local Data = KkthnxUIData[Realm][Name].Movers
	local Anchor1, Parent, Anchor2, X, Y = self:GetPoint()
	local FrameName = self.Parent:GetName()
	local Frame = self.Parent

	Frame:ClearAllPoints()
	Frame:SetPoint(Anchor1, Parent, Anchor2, X, Y)

	if not Parent then
		Parent = UIParent
	end

	Data[FrameName] = {Anchor1, Parent:GetName(), Anchor2, X, Y}
end

function Movers:CreateDragInfo()
	self.DragInfo = CreateFrame("Button", nil, self)
	self.DragInfo:SetAllPoints(self)
	self.DragInfo:SetTemplate("Transparent")
	self.DragInfo:SetBackdropBorderColor(72/255, 133/255, 237/255)
	self.DragInfo:FontString("Text", C["Media"].Font, 12)
	self.DragInfo.Text:SetText(self:GetName())
	self.DragInfo.Text:SetPoint("CENTER")
	self.DragInfo.Text:SetTextColor(72/255, 133/255, 237/255)
	self.DragInfo:SetFrameLevel(100)
	self.DragInfo:SetFrameStrata("HIGH")
	self.DragInfo:SetMovable(true)
	self.DragInfo:RegisterForDrag("LeftButton")
	self.DragInfo:Hide()
	self.DragInfo:SetScript("OnMouseUp", Movers.RestoreDefaults)
	self.DragInfo:HookScript("OnEnter", SetModifiedBackdrop)
	self.DragInfo:HookScript("OnLeave", SetOriginalBackdrop)

	self.DragInfo.Parent = self.DragInfo:GetParent()
end

function Movers:StartOrStopMoving()
	if InCombatLockdown() then
		return K.Print(ERR_NOT_IN_COMBAT)
	end

	if not self.IsEnabled then
		self.IsEnabled = true
	else
		self.IsEnabled = false
	end

	for i = 1, #self.Frames do
		local Frame = Movers.Frames[i]

		if self.IsEnabled then
			if not Frame.DragInfo then
				self.CreateDragInfo(Frame)
			end

			if Frame.unit then
				Frame.oldunit = Frame.unit
				Frame.unit = "player"
				Frame:SetAttribute("unit", "player")
			end

			Frame.DragInfo:SetScript("OnDragStart", self.OnDragStart)
			Frame.DragInfo:SetScript("OnDragStop", self.OnDragStop)
			Frame.DragInfo:SetParent(UIParent)
			Frame.DragInfo:Show()

			if Frame.DragInfo:GetFrameLevel() ~= 100 then
				Frame.DragInfo:SetFrameLevel(100)
			end

			if Frame.DragInfo:GetFrameStrata() ~= "HIGH" then
				Frame.DragInfo:SetFrameStrata("HIGH")
			end

			if Frame.DragInfo:GetHeight() < 12 then
				Frame.DragInfo:ClearAllPoints()
				Frame.DragInfo:SetWidth(Frame:GetWidth())
				Frame.DragInfo:SetHeight(12)
				Frame.DragInfo:SetPoint("TOP", Frame)
			end
		else
			if Frame.unit then
				Frame.unit = Frame.oldunit
				Frame:SetAttribute("unit", Frame.unit)
			end

			if Frame.DragInfo then
				Frame.DragInfo:SetParent(Frame.DragInfo.Parent)
				Frame.DragInfo:Hide()
				Frame.DragInfo:SetScript("OnDragStart", nil)
				Frame.DragInfo:SetScript("OnDragStop", nil)

				if Frame.DragInfo.CurrentHeight then
					Frame.DragInfo:ClearAllPoints()
					Frame.DragInfo:SetAllPoints(Frame)
				end
			end
		end
	end
end

function Movers:IsRegisteredFrame(frame)
	local Match = false

	for i = 1, #self.Frames do
		if self.Frames[i] == frame then
			Match = true
		end
	end

	return Match
end

Movers:SetScript("OnEvent", function(self, event)
	if (event == "PLAYER_ENTERING_WORLD") then
		if not KkthnxUIData[Realm][Name].Movers then
			KkthnxUIData[Realm][Name].Movers = {}
		end

		local Data = KkthnxUIData[Realm][Name].Movers

		for Frame, Position in pairs(Data) do
			local Frame = _G[Frame]
			local IsRegistered = self:IsRegisteredFrame(Frame)

			if Frame and IsRegistered then
				local Anchor1, Parent, Anchor2, X, Y = Frame:GetPoint()

				self:SaveDefaults(Frame, Anchor1, Parent, Anchor2, X, Y)

				Anchor1, Parent, Anchor2, X, Y = unpack(Position)

				Frame:ClearAllPoints()
				Frame:SetPoint(Anchor1, _G[Parent], Anchor2, X, Y)
			end
		end
	elseif (event == "PLAYER_REGEN_DISABLED") then
		if self.IsEnabled then
			self:StartOrStopMoving()
		end
	end
end)

K["Movers"] = Movers