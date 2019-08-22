local K = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

-- Soured: Baudzilla

local _G = _G
local math_sin, math_cos, math_rad = _G.math.sin, _G.math.cos, _G.math.rad

local ButtonAngle = math_rad(360) / 7
local ButtonIsDown
local CreateFrame = _G.CreateFrame
local GetCursorPosition = _G.GetCursorPosition
local GetNumGroupMembers = _G.GetNumGroupMembers
local IsInGroup, IsInRaid = _G.IsInGroup, _G.IsInRaid
local PlaySound = _G.PlaySound
local SetRaidTarget = _G.SetRaidTarget
local SetRaidTargetIconTexture = _G.SetRaidTargetIconTexture
local UIErrorsFrame = _G.UIErrorsFrame
local UnitExists, UnitIsDead = _G.UnitExists, _G.UnitIsDead
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local UnitIsGroupLeader = _G.UnitIsGroupLeader

function Module:RaidMarkCanMark()
	if not self.RaidMarkFrame then
		return false
	end

	if GetNumGroupMembers() > 0 then
		if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
			return true
		elseif IsInGroup() and not IsInRaid() then
			return true
		else
			UIErrorsFrame:AddMessage("You don't have permission to mark targets.", 1.0, 0.1, 0.1, 1.0)
			return false
		end
	else
		return true
	end
end

function Module:RaidMarkShowIcons()
	if not UnitExists("target") or UnitIsDead("target")then
		return
	end

	local x, y = GetCursorPosition()
	local scale = UIParent:GetEffectiveScale()
	self.RaidMarkFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
	self.RaidMarkFrame:Show()
end

function RaidMark_HotkeyPressed(keystate)
	ButtonIsDown = (keystate == "down") and Module:RaidMarkCanMark()
	if ButtonIsDown and Module.RaidMarkFrame then
		Module:RaidMarkShowIcons()
	elseif Module.RaidMarkFrame then
		Module.RaidMarkFrame:Hide()
	end
end

function Module.RaidMark_OnEvent()
	if ButtonIsDown and Module.RaidMarkFrame then
		Module:RaidMarkShowIcons()
	end
end
K:RegisterEvent("PLAYER_TARGET_CHANGED", Module.RaidMark_OnEvent)

function Module:RaidMarkButton_OnEnter()
	self.Texture:ClearAllPoints()
	self.Texture:SetPoint("TOPLEFT", -10, 10)
	self.Texture:SetPoint("BOTTOMRIGHT", 10, -10)
end

function Module:RaidMarkButton_OnLeave()
	self.Texture:SetAllPoints()
end

function Module:RaidMarkButton_OnClick(arg1)
	PlaySound(1115) -- U_CHAT_SCROLL_BUTTON
	SetRaidTarget("target", (arg1 ~= "RightButton") and self:GetID() or 0)
	self:GetParent():Hide()
end

function Module:CreateRaidMarker()
	local marker = CreateFrame("Frame", nil, UIParent)
	marker:EnableMouse(true)
	marker:SetSize(100, 100)
	marker:SetFrameStrata("DIALOG")

	for i = 1, 8 do
		local button = CreateFrame("Button", "RaidMarkIconButton" .. i, marker)
		button:SetSize(40, 40)
		button:SetID(i)
		button.Texture = button:CreateTexture(button:GetName() .. "NormalTexture", "ARTWORK")
		button.Texture:SetTexture([[Interface\AddOns\KkthnxUI\Media\Textures\UI-RaidTargetingIcons]])
		button.Texture:SetAllPoints()
		SetRaidTargetIconTexture(button.Texture, i)
		button:RegisterForClicks("LeftbuttonUp", "RightbuttonUp")
		button:SetScript("OnClick", Module.RaidMarkButton_OnClick)
		button:SetScript("OnEnter", Module.RaidMarkButton_OnEnter)
		button:SetScript("OnLeave", Module.RaidMarkButton_OnLeave)

		if i == 8 then
			button:SetPoint("CENTER")
		else
			local angle = ButtonAngle * (i - 1)
			button:SetPoint("CENTER", math_sin(angle) * 60, math_cos(angle) * 60)
		end
	end

	Module.RaidMarkFrame = marker
end