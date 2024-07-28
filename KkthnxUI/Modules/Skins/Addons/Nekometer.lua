local K = KkthnxUI[1]
local Module = K:GetModule("Skins")

-- Localize global functions for better performance
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local CreateFrame = CreateFrame

local function ReskinNekometer()
	if not IsAddOnLoaded("nekometer") or not NekometerMainFrame then
		return
	end

	NekometerMainFrame:SetBackdrop(nil)

	if not _G["NekometerOverlayFrame"] then
		local NekometerOverlayFrame = CreateFrame("Frame", "NekometerOverlayFrame", NekometerMainFrame)
		NekometerOverlayFrame:SetAllPoints(NekometerMainFrame)

		if not NekometerOverlayFrame.KKUI_Border then
			NekometerOverlayFrame:CreateBorder()
			NekometerOverlayFrame.KKUI_Border = true
		end
	end

	local point, relativeTo, relativePoint, xOfs, yOfs = NekometerMainFrame:GetPoint()
	if not (point == "BOTTOMRIGHT" and relativeTo == UIParent and relativePoint == "BOTTOMRIGHT" and xOfs == -500 and yOfs == 4) then
		NekometerMainFrame:ClearAllPoints()
		NekometerMainFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -500, 4)
	end
end

Module:RegisterSkin("nekometer", ReskinNekometer)
