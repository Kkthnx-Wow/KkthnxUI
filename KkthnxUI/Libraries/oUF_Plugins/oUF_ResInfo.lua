local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "ResInfo element requires oUF")

local LibResInfo = LibStub("LibResInfo-1.0", true)
assert(LibResInfo, "ResInfo element requires LibResInfo-1.0")

local Update, Path, ForceUpdate, Enable, Disable

local displayText = {
	CASTING = "|cffffff00RES|r",
	PENDING = "|cff00ff00RES|r",
	SELFRES = "|cffff00ffSS|r",
}

function Update(self, event, unit)
	if unit ~= self.unit then return end
	local element = self.ResInfo

	if element.PreUpdate then
		element:PreUpdate(unit)
	end

	local status, endTime, casterUnit, casterGUID = LibResInfo:UnitHasIncomingRes(unit)
	element:SetText(displayText[status or ""] or "") -- nil causes 0 height which might disrupt layouts

	if element.PostUpdate then
		element:PostUpdate(unit, status, text)
	end
end

function Path(self, ...)
	return (self.ResInfo.Override or Update)(self, ...)
end

function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

function Enable(self)
	local element = self.ResInfo
	if not element then return end

	if element:IsObjectType("FontString") and not element:GetFont() then
		element:SetFontObject("GameFontHighlightSmall")
	end

	element.__owner = self
	element.ForceUpdate = ForceUpdate

	element:Show()

	return true
end

function Disable(self)
	local element = self.ResInfo
	if not element then return end

	element:Hide()
end

oUF:AddElement("ResInfo", Update, Enable, Disable)

local function Callback(event, unit, guid)
	for i = 1, #oUF.objects do
		local frame = oUF.objects[i]
		if frame.unit and frame.ResInfo then
			Update(frame, event, frame.unit)
		end
	end
end

LibResInfo.RegisterCallback("oUF_ResInfo", "LibResInfo_ResCastStarted", Callback)
LibResInfo.RegisterCallback("oUF_ResInfo", "LibResInfo_ResCastCancelled", Callback)
LibResInfo.RegisterCallback("oUF_ResInfo", "LibResInfo_ResPending", Callback)
LibResInfo.RegisterCallback("oUF_ResInfo", "LibResInfo_ResUsed", Callback)
LibResInfo.RegisterCallback("oUF_ResInfo", "LibResInfo_ResExpired", Callback)