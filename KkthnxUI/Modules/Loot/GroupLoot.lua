local K, C = unpack(select(2, ...))
local GroupLoot = K:GetModule("Loot")
-- Lib Globals
local _G = _G
local unpack = _G.unpack

-- WoW Globals
local GetLootRollItemInfo = _G.GetLootRollItemInfo -- Comment out only for testing.
local ITEM_QUALITY_COLORS = _G.ITEM_QUALITY_COLORS
local NUM_GROUP_LOOT_FRAMES = _G.NUM_GROUP_LOOT_FRAMES

-- Locals
GroupLoot.PreviousFrame = {}

function GroupLoot:TestGroupLootFrames()
	GetLootRollItemInfo = function(RollID)
		Texture = 135226
		Name = "Atiesh, Greatstaff of the Guardian"
		Count = RollID
		Quality	= RollID + 1
		BindOnPickUp = math.random(0, 1) > 0.5
		CanNeed	= true
		CanGreed = true
		CanDisenchant = true
		ReasonNeed = 0
		ReasonGreed	= 0
		ReasonDisenchant = 0
		DeSkillRequired	 = 0

		return Texture, Name, Count, Quality, BindOnPickUp, CanNeed, CanGreed, CanDisenchant, ReasonNeed, ReasonGreed, ReasonDisenchant, DeSkillRequired
	end

	function GroupLootFrame_OnUpdate() end

	for i = 1, NUM_GROUP_LOOT_FRAMES do
		GroupLootFrame_OpenNewFrame(i, 300)
		_G["GroupLootFrame" .. i].Timer:SetValue(math.random(8, 300))
	end
end

function GroupLoot:SkinGroupLoot(Frame)
	Frame:StripTextures()
	Frame:SetSize(242, 84)

	if (Frame.Timer.Background) then
		Frame.Timer.Background:Kill()
	end

	if (_G[Frame:GetName().."NameFrame"]) then
		_G[Frame:GetName().."NameFrame"]:Kill()
	end

	if (_G[Frame:GetName().."Corner"]) then
		_G[Frame:GetName().."Corner"]:Kill()
	end

	if (Frame.IconFrame.Border) then
		Frame.IconFrame.Border:Hide()
	end

	Frame.OverlayContrainerFrame = CreateFrame("Frame", nil, Frame)
	Frame.OverlayContrainerFrame:SetFrameLevel(Frame:GetFrameLevel() - 1)
	Frame.OverlayContrainerFrame:SetSize(240, 32)
	Frame.OverlayContrainerFrame:SetPoint("CENTER", Frame, 0, 0)
	Frame.OverlayContrainerFrame:CreateBorder()

	Frame.Name:ClearAllPoints()
	Frame.Name:SetPoint("LEFT", Frame.OverlayContrainerFrame, 6, 0)
	Frame.Name:FontTemplate(C.Media.Font, 12)

	Frame.IconFrame.Count:ClearAllPoints()
	Frame.IconFrame.Count:SetPoint("BOTTOMRIGHT", -2, 4)
	Frame.IconFrame.Count:FontTemplate(C.Media.Font, 12)

	Frame.Timer:StripTextures(true)
	Frame.Timer:SetStatusBarTexture(C.Media.Texture)
	Frame.Timer:ClearAllPoints()
	Frame.Timer:SetSize(Frame.OverlayContrainerFrame:GetWidth() + 1, 10)
	Frame.Timer:SetPoint("BOTTOMLEFT", Frame.OverlayContrainerFrame, 0, -16)

	Frame.Timer.OverlayTimerFrame = CreateFrame("Frame", nil, Frame.Timer)
	Frame.Timer.OverlayTimerFrame:SetFrameLevel(Frame.Timer:GetFrameLevel())
	Frame.Timer.OverlayTimerFrame:SetAllPoints()
	Frame.Timer.OverlayTimerFrame:CreateBorder()

	Frame.IconFrame:CreateBorder()
	Frame.IconFrame:CreateInnerShadow()
	Frame.IconFrame:SetSize(32, 32)
	Frame.IconFrame:ClearAllPoints()
	Frame.IconFrame:SetPoint("LEFT", Frame.OverlayContrainerFrame, -38, 0)

	Frame.IconFrame.Icon:SetTexCoord(unpack(K.TexCoords))
	Frame.IconFrame.Icon:SetAllPoints()
	Frame.IconFrame.Icon:SetSnapToPixelGrid(false)
	Frame.IconFrame.Icon:SetTexelSnappingBias(0)

	Frame.PassButton:ClearAllPoints()
	Frame.PassButton:SetPoint("RIGHT", Frame.OverlayContrainerFrame, 0, 0)
	Frame.PassButton:SkinCloseButton(nil, nil, 16)

	Frame.DisenchantButton:SetSize(24, 24)
	Frame.DisenchantButton:ClearAllPoints()
	Frame.DisenchantButton:SetPoint("LEFT", Frame.PassButton, -24, -2)

	Frame.GreedButton:SetSize(24, 24)
	Frame.GreedButton:ClearAllPoints()
	Frame.GreedButton:SetPoint("LEFT", Frame.DisenchantButton, -24, 0)

	Frame.NeedButton:SetSize(24, 24)
	Frame.NeedButton:ClearAllPoints()
	Frame.NeedButton:SetPoint("LEFT", Frame.GreedButton, -24, 0)
end

function GroupLoot:GroupLootFrameOnShow()
	local _, _, _, Quality = GetLootRollItemInfo(self.rollID)
	local Color = ITEM_QUALITY_COLORS[Quality]

	self:SetBackdrop(nil)
	self.OverlayContrainerFrame:SetBackdropColor(Color.r * 0.25, Color.g * 0.25, Color.b * 0.25, 0.7)
	self.Timer:SetStatusBarColor(1, 0.82, 0, 0.50)
	--self.Name:SetVertexColor(1, 1, 1)
end

function GroupLoot:UpdateGroupLootContainer()
	for i = 1, NUM_GROUP_LOOT_FRAMES do
		local Frame = _G["GroupLootFrame" .. i]
		local Mover = GroupLoot.Mover

		Frame:ClearAllPoints()

		if (i == 1) then
			Frame:SetPoint("CENTER", Mover, 24, -34)
		else

			Frame:SetPoint("BOTTOM", GroupLoot.PreviousFrame, "BOTTOM", 0, -54)
		end

		GroupLoot.PreviousFrame = Frame
	end
end

function GroupLoot:SkinFrames()
	for i = 1, NUM_GROUP_LOOT_FRAMES do
		local Frame = _G["GroupLootFrame" .. i]
		self:SkinGroupLoot(Frame)
	end
end

function GroupLoot:AddMover()
	self.Mover = CreateFrame("Frame", "KKUI_GroupLoot", UIParent)
	self.Mover:SetPoint("TOP", UIParent, 0, 0)
	self.Mover:SetSize(284, 22)

	K.Mover(self.Mover, "GroupLoot Mover", "GroupLoot Mover", {"TOP", UIParent, 0, 0}, 284, 22)
end

function GroupLoot:AddHooks()
	for i = 1, NUM_GROUP_LOOT_FRAMES do
		local Frame = _G["GroupLootFrame" .. i]
		Frame:HookScript("OnShow", self.GroupLootFrameOnShow)
	end

	-- So we can move the Group Loot Container.
	UIPARENT_MANAGED_FRAME_POSITIONS.GroupLootContainer = nil
	hooksecurefunc("GroupLootContainer_Update", self.UpdateGroupLootContainer)
end

function GroupLoot:CreateGroupLoot()
	if not C["Loot"].GroupLoot then
		return
	end

	self:AddMover()
	self:SkinFrames()
	self:AddHooks()
	-- self:TestGroupLootFrames()
end
