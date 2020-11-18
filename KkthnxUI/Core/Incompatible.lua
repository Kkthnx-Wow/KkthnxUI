local K, C, L = unpack(select(2, ...))

local _G = _G
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local DisableAddOn = _G.DisableAddOn
local IsAddOnLoaded = _G.IsAddOnLoaded
local UIParent = _G.UIParent

-- Locals
L["FoundIncompatibleAddon"] = "Incompatible AddOns:"
L["DisableIncompatibleAddon"] = "Disable All!"

-- Incompatible check
local IncompatibleAddOns = {
	["DuffedUI"] = true,
	["ElvUI"] = true,
	["NDui"] = true,
	["Tukui"] = true,
}

local AddonDependency = {}

local function CheckIncompatible()
	local IncompatibleList = {}
	for addon in pairs(IncompatibleAddOns) do
		if IsAddOnLoaded(addon) then
			table_insert(IncompatibleList, addon)
		end
	end

	if #IncompatibleList > 0 then
		local frame = CreateFrame("Frame", nil, UIParent)
		frame:SetPoint("TOP", 0, -200)
		frame:SetFrameStrata("HIGH")
		frame:CreateBorder()
		K.CreateFontString(frame, 18, L["FoundIncompatibleAddon"], "", true, "TOP", 10, -10)

		local offset = 0
		for _, addon in pairs(IncompatibleList) do
			K.CreateFontString(frame, 14, addon, false, "TOPLEFT", 10, -(50 + offset))
			offset = offset + 24
		end
		frame:SetSize(300, 100 + offset)

		local close = CreateFrame("Button", nil, frame, "BackdropTemplate")
		close:SetSize(16, 16)
		close:SetPoint("TOPRIGHT", -10, -10)
		close:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
		close:StyleButton()

		close.Icon = close:CreateTexture(nil, "ARTWORK")
		close.Icon:SetAllPoints()
		close.Icon:SetTexCoord(unpack(K.TexCoords))
		close.Icon:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\CloseButton_32")
		close:SetScript("OnClick", function()
			frame:Hide()
		end)

		local disable = CreateFrame("Button", nil, frame, "BackdropTemplate")
		disable:SetSize(150, 25)
		disable:SetPoint("BOTTOM", 0, 10)
		disable:SkinButton()
		disable.text = K.CreateFontString(disable, 12, L["DisableIncompatibleAddon"], "", true)
		disable.text:SetTextColor(1, 0, 0)
		disable:SetScript("OnClick", function()
			for _, addon in pairs(IncompatibleList) do
				DisableAddOn(addon, true)
				if AddonDependency[addon] then
					DisableAddOn(AddonDependency[addon], true)
				end
			end
			ReloadUI()
		end)
	end
end
K:RegisterEvent("PLAYER_LOGIN", CheckIncompatible)