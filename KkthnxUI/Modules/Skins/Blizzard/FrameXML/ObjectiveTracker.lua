local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Skins")

local r, g, b = K.r, K.g, K.b
local select, pairs = select, pairs

local function reskinHeader(header)
	if not header then
		return
	end

	header.Text:SetTextColor(r, g, b)
	header.Background:SetTexture(nil)
	local bg = header:CreateTexture(nil, "ARTWORK")
	bg:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
	bg:SetTexCoord(0, 0.66, 0, 0.31)
	bg:SetVertexColor(r, g, b, 0.8)
	bg:SetPoint("BOTTOMLEFT", 0, -4)
	bg:SetSize(250, 30)
	header.bg = bg -- accessable for other addons
end

local function HotkeyShow(self)
	local item = self:GetParent()
	if item.rangeOverlay then
		item.rangeOverlay:Show()
	end
end
local function HotkeyHide(self)
	local item = self:GetParent()
	if item.rangeOverlay then
		item.rangeOverlay:Hide()
	end
end
local function HotkeyColor(self, r, g, b)
	local item = self:GetParent()
	if item.rangeOverlay then
		if r == 0.6 and g == 0.6 and b == 0.6 then
			item.rangeOverlay:SetVertexColor(0, 0, 0, 0)
		else
			item.rangeOverlay:SetVertexColor(0.8, 0.1, 0.1, 0.5)
		end
	end
end

local function reskinItemButton(block)
	if InCombatLockdown() then
		return
	end -- will break quest item button

	local item = block and block.itemButton
	if not item then
		return
	end

	if not item.skinned then
		item:CreateBorder()
		item:SetNormalTexture(0)

		item.icon:SetTexCoord(unpack(K.TexCoords))
		item.icon:SetAllPoints()

		item.Cooldown:SetAllPoints()
		item.Count:ClearAllPoints()
		item.Count:SetPoint("TOPLEFT", 1, -1)
		item.Count:SetFontObject(K.UIFont)
		item.Count:SetShadowOffset(5, -5)

		local rangeOverlay = item:CreateTexture(nil, "OVERLAY")
		rangeOverlay:SetTexture(C["Media"].Textures.White8x8Texture)
		rangeOverlay:SetAllPoints()
		item.rangeOverlay = rangeOverlay

		hooksecurefunc(item.HotKey, "Show", HotkeyShow)
		hooksecurefunc(item.HotKey, "Hide", HotkeyHide)
		hooksecurefunc(item.HotKey, "SetVertexColor", HotkeyColor)
		HotkeyColor(item.HotKey, item.HotKey:GetTextColor())
		item.HotKey:SetAlpha(0)
		item.skinned = true
	end

	-- if item.backdrop then
	-- 	item.backdrop:SetFrameLevel(3)
	-- end
end

tinsert(C.defaultThemes, function()
	if IsAddOnLoaded("!KalielsTracker") then
		return
	end

	-- Reskin Progressbars
	BonusObjectiveTrackerProgressBar_PlayFlareAnim = K.Noop

	hooksecurefunc("QuestObjectiveSetupBlockButton_Item", reskinItemButton)
	hooksecurefunc(_G.BONUS_OBJECTIVE_TRACKER_MODULE, "AddObjective", reskinItemButton)

	-- Reskin Headers
	local headers = {
		ObjectiveTrackerBlocksFrame.QuestHeader,
		ObjectiveTrackerBlocksFrame.AchievementHeader,
		ObjectiveTrackerBlocksFrame.ScenarioHeader,
		ObjectiveTrackerBlocksFrame.CampaignQuestHeader,
		ObjectiveTrackerBlocksFrame.ProfessionHeader,
		BONUS_OBJECTIVE_TRACKER_MODULE.Header,
		WORLD_QUEST_TRACKER_MODULE.Header,
		ObjectiveTrackerFrame.BlocksFrame.UIWidgetsHeader,
	}
	for _, header in pairs(headers) do
		reskinHeader(header)
	end
end)
