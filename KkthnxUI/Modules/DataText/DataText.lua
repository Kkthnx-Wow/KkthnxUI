local K, C = unpack(select(2, ...))
local Module = K:NewModule("Infobar")

local _G = _G
local table_insert = _G.table.insert
local unpack = _G.unpack

local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent
local GetTime = _G.GetTime

function Module:RegisterInfobar(name, point)
	if not self.Modules then
		self.Modules = {}
	end

	local info = CreateFrame("Frame", nil, UIParent)
	info.text = info:CreateFontString(nil, "OVERLAY")
	info.text:SetFontObject(K.GetFont(C["UIFonts"].DataTextFonts))
	info.text:SetFont(select(1, info.text:GetFont()), 13, select(3, info.text:GetFont()))

	info.point = info.text:SetPoint(unpack(point))

	info.text.glow = info:CreateTexture(nil, "BACKGROUND", nil, -1)
	info.text.glow:SetHeight(12)
	info.text.glow:SetPoint("TOPLEFT", info.text, "TOPLEFT", -6, 6)
	info.text.glow:SetPoint("BOTTOMRIGHT", info.text, "BOTTOMRIGHT", 6, -6)
	info.text.glow:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\Shader")
	info.text.glow:SetVertexColor(0, 0, 0, 0.5)

	info:SetAllPoints(info.text)

	info.name = name
	table_insert(self.Modules, info)

	return info
end

function Module:LoadInfobar(info)
	if info.eventList then
		for _, event in pairs(info.eventList) do
			info:RegisterEvent(event)
		end
		info:SetScript("OnEvent", info.onEvent)
	end

	if info.onEnter then
		info:SetScript("OnEnter", info.onEnter)
	end

	if info.onLeave then
		info:SetScript("OnLeave", info.onLeave)
	end

	if info.onMouseUp then
		info:SetScript("OnMouseUp", info.onMouseUp)
	end

	if info.onUpdate then
		info:SetScript("OnUpdate", info.onUpdate)
	end
end

function Module:OnEnable()
	if not self.Modules then
		return
	end

	for _, info in pairs(self.Modules) do
		self:LoadInfobar(info)
	end

	self.loginTime = GetTime()
end