local K, C = KkthnxUI[1], KkthnxUI[2]

-- Lua APIs
local pairs = pairs
local unpack = unpack

-- WoW APIs
local CreateColor = CreateColor
local CreateFrame = CreateFrame
local GetProfessionInfo = GetProfessionInfo
local InCombatLockdown = InCombatLockdown
local hooksecurefunc = hooksecurefunc

--- Applies KkthnxUI styling to individual profession spell buttons.
-- @param button The spell button frame to style (e.g., SpellButton1, SpellButton2).
-- Strips default textures, applies texture coordinates, repositions icon, and adds custom border.
local function HandleSkillButton(button)
	if not button or InCombatLockdown() then
		return
	end

	-- Remove default checked/pushed textures for cleaner appearance
	button:SetCheckedTexture(0)
	button:SetPushedTexture(0)

	if button.IconTexture then
		-- Apply KkthnxUI texture coordinates (crop edges)
		button.IconTexture:SetTexCoord(unpack(K.TexCoords))
		button.IconTexture:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
		button.IconTexture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)

		-- Add custom border only once to avoid duplicate borders
		if not button.KKUI_Border then
			button:CreateBorder(nil, nil, nil, nil, -7, nil, nil, nil, nil, 3)
			button.KKUI_Border = true
		end
	end

	-- Hide the default name frame overlay
	local buttonName = button:GetName()
	if buttonName then
		local nameFrame = _G[buttonName .. "NameFrame"]
		if nameFrame then
			nameFrame:Hide()
		end
	end
end

--- Reskins a profession button's status bar and associated spell buttons.
-- @param professionButton The profession frame (e.g., PrimaryProfession1, SecondaryProfession1).
-- Styles the experience bar with custom texture/gradient and processes spell buttons.
local function ReskinProfessionButton(professionButton)
	if not professionButton then
		return
	end

	local statusBar = professionButton.statusBar
	if statusBar then
		-- Remove Blizzard's default textures
		statusBar:StripTextures()
		statusBar:SetHeight(16)

		-- Apply KkthnxUI texture and green gradient for profession XP bar
		statusBar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
		statusBar:GetStatusBarTexture():SetGradient("VERTICAL", CreateColor(0, 0.6, 0, 1), CreateColor(0, 0.8, 0, 1))

		-- Center the rank text (e.g., "75/150")
		if statusBar.rankText then
			statusBar.rankText:SetPoint("CENTER")
		end

		statusBar:CreateBorder()
	end

	-- Style spell buttons (iterate to avoid code duplication)
	for i = 1, 2 do
		local spellButton = professionButton["SpellButton" .. i]
		if spellButton then
			HandleSkillButton(spellButton)
		end
	end
end

--- Reskins primary profession icons (the large icons on left side of professions book).
-- @param professionIndex The index (1 or 2) for primary professions.
-- Hides default borders, applies texture coordinates, and adds custom border to profession icons.
local function ReskinProfessionIcons(professionIndex)
	local professionName = "PrimaryProfession" .. professionIndex
	local professionButton = _G[professionName]
	if not professionButton then
		return
	end

	-- Cache the icon border name to avoid repeated string concatenation
	local iconBorder = _G[professionName .. "IconBorder"]
	if iconBorder then
		iconBorder:Hide() -- Hide Blizzard's default icon border
	end

	local professionIcon = professionButton.icon
	if not professionIcon then
		return
	end

	-- Reposition profession name text to accommodate styled icon
	if professionButton.professionName then
		professionButton.professionName:ClearAllPoints()
		professionButton.professionName:SetPoint("TOPLEFT", 100, -4)
	end

	-- Ensure icon is always visible and not greyed out
	professionIcon:SetAlpha(1)
	professionIcon:SetDesaturated(false)
	professionIcon:SetTexCoord(unpack(K.TexCoords))

	-- Create background frame for custom border (prevents border from being attached directly to icon)
	local bg = CreateFrame("Frame", nil, professionButton)
	bg:SetAllPoints(professionIcon)
	bg:SetFrameLevel(professionButton:GetFrameLevel())
	bg:CreateBorder()
end

--- Hides the tutorial button on the professions book if user has disabled tutorial buttons.
-- Respects user's NoTutorialButtons config setting.
local function HideTutorialButtons()
	if C["General"].NoTutorialButtons then
		local tutorialButton = _G.ProfessionsBookFrameTutorialButton
		if tutorialButton then
			tutorialButton:Hide()
		end
	end
end

--- Main skin function for Blizzard's Professions Book (called when addon loads).
-- Styles all profession frames (primary + secondary professions) with KkthnxUI theme.
-- This is registered in the C.themes table and called by the skinning system.
C.themes["Blizzard_ProfessionsBook"] = function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	-- List of all profession frames to style (2 primary, 3 secondary)
	local professionFrames = {
		"PrimaryProfession1",
		"PrimaryProfession2",
		"SecondaryProfession1",
		"SecondaryProfession2",
		"SecondaryProfession3",
	}

	-- Apply styling to each profession frame
	for i, professionName in pairs(professionFrames) do
		local professionFrame = _G[professionName]
		if professionFrame then
			ReskinProfessionButton(professionFrame)

			-- Only primary professions (indices 1-2) have large icons that need special styling
			if i <= 2 then
				ReskinProfessionIcons(i)
			end
		end
	end

	-- Hook FormatProfession to maintain icon texture when profession data updates
	-- This ensures our styling persists when Blizzard refreshes the profession UI
	hooksecurefunc("FormatProfession", function(frame, index)
		-- Avoid taint during combat by skipping UI modifications
		if InCombatLockdown() then
			return
		end

		if index and frame then
			local _, texture = GetProfessionInfo(index)
			if frame.icon and texture then
				frame.icon:SetTexture(texture)
			end
		end
	end)

	HideTutorialButtons()
end
