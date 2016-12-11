local K, C, L = unpack(select(2, ...))
if C.Skins.MinimapButtons ~= true or C.Minimap.Enable ~= true then return end

local match = string.match
local select = select
local find = string.find
local unpack = unpack

--	Skin addons icons on minimap
local buttons = {
	"GameTimeFrame",
	"GatherMatePin",
	"HandyNotesPin",
	"HelpOpenTicketButton",
	"MiniMapMailFrame",
	"MiniMapTrackingButton",
	"QueueStatusMinimapButton",
	"TimeManagerClockButton"
}

local function SkinButton(f)
	if not f or f:GetObjectType() ~= "Button" then return end

	for i, buttons in pairs(buttons) do
		if f:GetName() ~= nil then
			if f:GetName():match(buttons) then return end
		end
	end

	f:SetPushedTexture(nil)
	f:SetHighlightTexture(nil)
	f:SetDisabledTexture(nil)
	f:SetSize(19, 19)

	for i = 1, f:GetNumRegions() do
		local region = select(i, f:GetRegions())
		if (region:IsVisible() or region:IsShown()) and (region:GetObjectType() == "Texture") then
			local tex = tostring(region:GetTexture())

			-- if tex and (tex:find("Border") or tex:find("Background") or tex:find("AlphaMask")) then
			if tex and (strfind(tex, 'Border') or strfind(tex, 'Background') or strfind(tex, 'AlphaMask') or strfind(tex, 'Highlight')) then
				region:SetTexture(nil)
			else
				region:ClearAllPoints()
				region:SetInside()
				region:SetTexCoord(unpack(K.TexCoords))
				region:SetDrawLayer("ARTWORK")
				if f:GetName() == "PS_MinimapButton" then
					region.SetPoint = K.Noop
				end
			end
		end
	end
	K.CreateBorder(f)
	f:SetBackdrop(K.BorderBackdrop)
	f:SetBackdropColor(unpack(C.Media.Backdrop_Color))
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		for i = 1, Minimap:GetNumChildren() do
			SkinButton(select(i, Minimap:GetChildren()))
		end
	end

	if WIM3MinimapButton and WIM3MinimapButton:GetNumRegions() < 9 then
		SkinButton(WIM3MinimapButton)
		SkinButton(WIM3MinimapButton)
	end
	self = nil
end)