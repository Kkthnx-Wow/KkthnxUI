local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local function SkinDebugTools()
	if not IsAddOnLoaded("Blizzard_DebugTools") then
		return
	end

	-- EventTraceFrame
	EventTraceFrame:CreateBorder()
	EventTraceFrameCloseButton:SkinCloseButton()
end

Module.NewSkin["Blizzard_DebugTools"] = SkinDebugTools