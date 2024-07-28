local K, C = KkthnxUI[1], KkthnxUI[2]

local select = select

local function SkinDeathRecapFrame()
	local DeathRecapFrame = DeathRecapFrame

	-- Disable the border draw layer and hide unwanted elements
	DeathRecapFrame:DisableDrawLayer("BORDER")
	DeathRecapFrame.Background:Hide()
	DeathRecapFrame.BackgroundInnerGlow:Hide()
	DeathRecapFrame.Divider:Hide()

	-- Create a new border for the frame
	DeathRecapFrame:CreateBorder()

	-- Skin the bottom close button (without a parent key)
	local closeButton = select(8, DeathRecapFrame:GetChildren())
	if closeButton then
		closeButton:SkinButton()
	end

	-- Skin the close button at the top right corner
	DeathRecapFrame.CloseXButton:SkinCloseButton()
end

local function SkinRecapEvents()
	for i = 1, NUM_DEATH_RECAP_EVENTS do
		local recap = DeathRecapFrame["Recap" .. i].SpellInfo
		recap.IconBorder:Hide()
		recap.Icon:SetTexCoord(unpack(K.TexCoords))
		recap:CreateBorder()
	end
end

C.themes["Blizzard_DeathRecap"] = function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	SkinDeathRecapFrame()
	SkinRecapEvents()
end
