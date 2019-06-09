local K, C = unpack(select(2, ...))
local Module = K:NewModule("TooltipQuality", "AceHook-3.0")
local GetModule = K:GetModule("Tooltip")

function Module:SetBorderColor(_, tt)
	if not tt.GetItem then
		return
	end

	local _, link = tt:GetItem()

	if link then
		local _, _, quality = GetItemInfo(link)
		if quality then
			tt:SetBackdropBorderColor(GetItemQualityColor(quality))
		end
	end
end

function Module:ToggleState()
	if C["Tooltip"].ItemQualityBorder then
		if not self:IsHooked(GetModule, "SetStyle", "SetBorderColor") then
			self:SecureHook(GetModule, "SetStyle", "SetBorderColor")
		end
	else
		self:UnhookAll()
	end
end

function Module:OnEnable()
	if not C["Tooltip"].ItemQualityBorder then return end

	self:ToggleState()
end