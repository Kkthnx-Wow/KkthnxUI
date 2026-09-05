--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Misc/GroupTools.lua
	Purpose:
		A group tools panel, shown only while you are in a party or raid. A movable
		tab folds out a panel with a ready check, a role check, a pull timer, a world
		marker bar, a target icon bar, and a live tank/healer/damage count. The pull
		timer and the world markers run through the game's own countdown and secure
		marker macros, so nothing here does a protected action from tainted code, and
		the leader-only tools grey out when you cannot use them.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:NewModule("GroupTools")

local _G = _G
local ipairs = ipairs
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsGroupAssistant = UnitIsGroupAssistant
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local GetNumGroupMembers = GetNumGroupMembers
local InitiateRolePoll = InitiateRolePoll
local floor = math.floor
local tostring = tostring
local C_PartyInfo = C_PartyInfo

-- Ready check moved to C_PartyInfo on retail, with the old global as a fallback.
local DoReadyCheck = (C_PartyInfo and C_PartyInfo.DoReadyCheck) or _G.DoReadyCheck

-- Can the player run leader-only tools (leader anywhere, or an assist in a raid)?
local function CanLead()
	return IsInGroup() and (UnitIsGroupLeader("player") or (IsInRaid() and UnitIsGroupAssistant("player")))
end

-- Disband confirmation. Uninvite every other member, then leave, which ends the
-- group. Registered as a single entry so Blizzard's dialog table is never replaced.
_G.StaticPopupDialogs["KKUI_GROUPTOOLS_DISBAND"] = {
	text = L["Disband the group?"],
	button1 = _G.YES,
	button2 = _G.NO,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	OnAccept = function()
		if not (UnitIsGroupLeader("player") and C_PartyInfo) then
			return
		end
		if IsInRaid() then
			for i = 1, GetNumGroupMembers() do
				local name = GetRaidRosterInfo(i)
				if name and name ~= UnitName("player") then
					UninviteUnit(name)
				end
			end
		else
			for i = GetNumGroupMembers() - 1, 1, -1 do
				local name = UnitName("party" .. i)
				if name then
					UninviteUnit(name)
				end
			end
		end
		if C_PartyInfo.LeaveParty then
			C_PartyInfo.LeaveParty()
		end
	end,
}

-- ---------------------------------------------------------------------------
-- Tooltips
-- ---------------------------------------------------------------------------

local MARK_NAME = {
	L["Star"], L["Circle"], L["Diamond"], L["Triangle"],
	L["Moon"], L["Square"], L["Cross"], L["Skull"],
}

-- Raid target icon (1 Star through 8 Skull) to the ground flare that matches it.
-- The two are numbered differently, so a button showing Star has to place flare 8.
-- Blizzard keeps the translation in WORLD_RAID_MARKER_ORDER and reads it the same
-- way in its own raid manager (CRFManagerRaidIconButtonMixin runs the displayed
-- marker through it before calling PlaceRaidMarker). The local copy is only a
-- fallback for a client that has not loaded the raid frame manager yet.
local FLARE_FOR_ICON = { 8, 4, 1, 7, 2, 3, 6, 5 }

local function WorldMarkerFor(icon)
	local order = _G.WORLD_RAID_MARKER_ORDER
	return (order and order[icon]) or FLARE_FOR_ICON[icon] or icon
end

local function SetTip(button, title, line)
	button:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(title, 1, 1, 1)
		if line then
			GameTooltip:AddLine(line, 0.7, 0.85, 1, true)
		end
		GameTooltip:Show()
	end)
	button:HookScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

-- ---------------------------------------------------------------------------
-- Button builders
-- ---------------------------------------------------------------------------

local function TextButton(parent, width, height, text, onClick)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(width, height)
	button.Text = button:CreateFontString(nil, "OVERLAY")
	K.SetFont(button.Text, 12, K.FontOutlineStyle())
	button.Text:SetPoint("CENTER")
	button.Text:SetText(text)
	K.SkinButton(button)
	if onClick then
		button:SetScript("OnClick", onClick)
	end
	return button
end

-- A square raid-target icon. secure buttons take their action from attributes
-- (world markers), plain ones run an OnClick (target icons).
local function IconButton(parent, size, index, secure)
	local button = CreateFrame("Button", nil, parent, secure and "SecureActionButtonTemplate" or nil)
	button:SetSize(size, size)
	K.CreateGradientBackground(button, 0.9)
	K.CreateBorder(button)
	button:HookScript("OnEnter", function(self)
		if self.KKUI_Border then
			self.KKUI_Border:SetVertexColor(1, 0.82, 0, 1)
		end
	end)
	button:HookScript("OnLeave", function(self)
		if self.KKUI_Border then
			K.ResetBorderColor(self.KKUI_Border)
		end
	end)
	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("TOPLEFT", 1, -1)
	icon:SetPoint("BOTTOMRIGHT", -1, 1)
	if index and index > 0 then
		-- The eight raid marks share one 4x4 sheet. SetRaidTargetIconTexture only sets
		-- the sprite cell now, so the texture has to be set here, and cropping it by
		-- hand keeps it independent of that helper.
		icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
		local col = (index - 1) % 4
		local row = floor((index - 1) / 4)
		icon:SetTexCoord(col * 0.25, col * 0.25 + 0.25, row * 0.25, row * 0.25 + 0.25)
	else
		icon:SetAtlas("common-icon-redx")
	end
	button.Icon = icon
	return button
end

-- ---------------------------------------------------------------------------
-- Panel
-- ---------------------------------------------------------------------------

local PAD = 8
local ROW = 22
local ICON = 24

function Module:BuildPanel(tab)
	local panel = CreateFrame("Frame", "KKUI_GroupToolsPanel", tab)
	-- Open below the role bar (which sits under the tab), or the tab if there is none.
	panel:SetPoint("TOP", self.RoleBar or tab, "BOTTOM", 0, -4)
	-- Wide enough for the marker rows: eight marks plus a clear button, evenly spaced.
	panel:SetWidth(9 * ICON + 8 * 4 + PAD * 2)
	K.CreateGradientBackground(panel, 0.95)
	K.CreateBorder(panel)
	panel:Hide()

	local y = -PAD
	self.leaderButtons = {}

	-- Ready check and role check side by side.
	local half = (panel:GetWidth() - PAD * 2 - 6) / 2
	local ready = TextButton(panel, half, ROW, READY_CHECK or L["Ready Check"], function()
		if DoReadyCheck then
			DoReadyCheck()
		end
	end)
	ready:SetPoint("TOPLEFT", panel, "TOPLEFT", PAD, y)
	local role = TextButton(panel, half, ROW, ROLE_POLL or L["Role Check"], function()
		if InitiateRolePoll then
			InitiateRolePoll()
		end
	end)
	role:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -PAD, y)
	SetTip(ready, READY_CHECK or L["Ready Check"], L["Ask the group to ready up."])
	SetTip(role, ROLE_POLL or L["Role Check"], L["Ask everyone to confirm their role."])
	self.leaderButtons[#self.leaderButtons + 1] = ready
	self.leaderButtons[#self.leaderButtons + 1] = role
	y = y - ROW - PAD

	-- Pull timer: the configured default and a cancel.
	local pull = TextButton(panel, half, ROW, (L["Pull"] .. " " .. (C.GroupTools.PullTime or 8)), function()
		if C_PartyInfo and C_PartyInfo.DoCountdown then
			C_PartyInfo.DoCountdown(C.GroupTools.PullTime or 8)
		end
	end)
	pull:SetPoint("TOPLEFT", panel, "TOPLEFT", PAD, y)
	local cancel = TextButton(panel, half, ROW, CANCEL or L["Cancel"], function()
		if C_PartyInfo and C_PartyInfo.DoCountdown then
			C_PartyInfo.DoCountdown(0)
		end
	end)
	cancel:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -PAD, y)
	SetTip(pull, L["Pull Timer"], L["Start an on-screen countdown for the group."])
	SetTip(cancel, CANCEL or L["Cancel"], L["Cancel a running pull timer."])
	self.leaderButtons[#self.leaderButtons + 1] = pull
	self.leaderButtons[#self.leaderButtons + 1] = cancel
	y = y - ROW - PAD

	-- Quick pull presets for common timers.
	local presets = { 3, 5, 8, 10 }
	local pw = (panel:GetWidth() - PAD * 2 - (#presets - 1) * 4) / #presets
	local px = PAD
	for _, sec in ipairs(presets) do
		local preset = TextButton(panel, pw, ROW, tostring(sec), function()
			if C_PartyInfo and C_PartyInfo.DoCountdown then
				C_PartyInfo.DoCountdown(sec)
			end
		end)
		preset:SetPoint("TOPLEFT", panel, "TOPLEFT", px, y)
		SetTip(preset, sec .. "s " .. L["Pull"], L["Start a countdown of this length."])
		self.leaderButtons[#self.leaderButtons + 1] = preset
		px = px + pw + 4
	end
	y = y - ROW - PAD

	-- World marker bar: secure worldmarker action, left places, right clears.
	local wmLabel = panel:CreateFontString(nil, "OVERLAY")
	K.SetFont(wmLabel, 11, K.FontOutlineStyle())
	wmLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", PAD, y)
	wmLabel:SetText(L["World Markers"])
	wmLabel:SetTextColor(0.7, 0.7, 0.7)
	y = y - 14

	local x = PAD
	for i = 1, 8 do
		local button = IconButton(panel, ICON, i, true)
		button:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y)
		button:RegisterForClicks("AnyUp")
		-- Secure worldmarker action: left toggles the ground marker, right clears it.
		-- The ground flare is NOT numbered the same way as the raid target icon, so
		-- placing marker i under icon i drops a different colour than the button
		-- shows. Blizzard keeps the translation in WORLD_RAID_MARKER_ORDER and its
		-- own raid manager runs every click through it, so use that same table.
		button:SetAttribute("marker", WorldMarkerFor(i))
		button:SetAttribute("type1", "worldmarker")
		button:SetAttribute("action1", "toggle")
		button:SetAttribute("type2", "worldmarker")
		button:SetAttribute("action2", "clear")
		SetTip(button, MARK_NAME[i], L["Left-click places the marker at your cursor, right-click clears it."])
		x = x + ICON + 4
	end
	local wmClear = IconButton(panel, ICON, 0, true)
	wmClear:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y)
	wmClear:RegisterForClicks("AnyUp")
	-- No marker on the clear action clears every ground marker.
	wmClear:SetAttribute("type1", "worldmarker")
	wmClear:SetAttribute("action1", "clear")
	SetTip(wmClear, L["Clear Markers"], L["Clear every ground marker."])
	y = y - ICON - PAD

	-- Target icon bar: mark the current target, or clear it.
	local tiLabel = panel:CreateFontString(nil, "OVERLAY")
	K.SetFont(tiLabel, 11, K.FontOutlineStyle())
	tiLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", PAD, y)
	tiLabel:SetText(L["Target Icons"])
	tiLabel:SetTextColor(0.7, 0.7, 0.7)
	y = y - 14

	x = PAD
	for i = 1, 8 do
		local button = IconButton(panel, ICON, i, true)
		button:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y)
		button:RegisterForClicks("AnyUp")
		-- Secure raidtarget action: toggle mark i on the current target.
		button:SetAttribute("unit", "target")
		button:SetAttribute("type1", "raidtarget")
		button:SetAttribute("marker", i)
		SetTip(button, MARK_NAME[i], L["Mark your current target."])
		x = x + ICON + 4
	end
	local tiClear = IconButton(panel, ICON, 0, true)
	tiClear:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y)
	tiClear:RegisterForClicks("AnyUp")
	tiClear:SetAttribute("unit", "target")
	tiClear:SetAttribute("type1", "raidtarget")
	tiClear:SetAttribute("marker", 0)
	SetTip(tiClear, L["Clear Icon"], L["Remove the mark from your target."])
	y = y - ICON - PAD

	-- Convert to raid and disband, leader only.
	local convert = TextButton(panel, half, ROW, CONVERT_TO_RAID or L["Convert to Raid"], function()
		if C_PartyInfo and C_PartyInfo.ConvertToRaid and not IsInRaid() then
			C_PartyInfo.ConvertToRaid()
		end
	end)
	convert:SetPoint("TOPLEFT", panel, "TOPLEFT", PAD, y)
	local disband = TextButton(panel, half, ROW, TEAM_DISBAND or L["Disband"], function()
		StaticPopup_Show("KKUI_GROUPTOOLS_DISBAND")
	end)
	disband:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -PAD, y)
	SetTip(convert, CONVERT_TO_RAID or L["Convert to Raid"], L["Turn the party into a raid."])
	SetTip(disband, TEAM_DISBAND or L["Disband"], L["Remove everyone and leave the group."])
	self.leaderButtons[#self.leaderButtons + 1] = convert
	self.leaderButtons[#self.leaderButtons + 1] = disband
	y = y - ROW - PAD

	-- Role summary along the bottom of the panel too, so it stays visible while the
	-- panel is open (the bar under the tab is hidden then).
	local roleContainer = CreateFrame("Frame", nil, panel)
	roleContainer:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, y)
	roleContainer:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, y)
	roleContainer:SetHeight(ROW)
	self.PanelRoleWidgets = self:BuildRoleWidgets(roleContainer)
	y = y - ROW

	panel:SetHeight(-y + PAD)
	self.Panel = panel
	return panel
end

-- A centred row of the three role icons with a live tally, in any parent. Each
-- count has a fixed width so the whole group centres cleanly.
function Module:BuildRoleWidgets(parent)
	local group = CreateFrame("Frame", nil, parent)
	group:SetHeight(18)
	group:SetPoint("CENTER", parent, "CENTER", 0, 0)

	local roleData = {
		{ atlas = "icons_16x16_damage", key = "damage" },
		{ atlas = "icons_16x16_tank", key = "tank" },
		{ atlas = "icons_16x16_heal", key = "heal" },
	}
	local widgets = {}
	local x = 0
	for i, data in ipairs(roleData) do
		local roleIcon = group:CreateTexture(nil, "OVERLAY")
		roleIcon:SetSize(16, 16)
		roleIcon:SetPoint("LEFT", group, "LEFT", x, 0)
		roleIcon:SetAtlas(data.atlas)
		local count = group:CreateFontString(nil, "OVERLAY")
		K.SetFont(count, 12, K.FontOutlineStyle())
		count:SetSize(16, 16)
		count:SetJustifyH("LEFT")
		count:SetPoint("LEFT", roleIcon, "RIGHT", 3, 0)
		count:SetText("0")
		widgets[data.key] = count
		x = x + 16 + 3 + 16 + (i < #roleData and 4 or 0)
	end
	group:SetWidth(x)
	return widgets
end

-- The always-on role summary under the tab, on the same gradient strip the unit
-- frame names use, no border so it reads as a name plate.
function Module:BuildRoleBar(tab)
	local bar = CreateFrame("Frame", "KKUI_GroupToolsRoleBar", tab)
	bar:SetSize(tab:GetWidth(), 22)
	bar:SetPoint("TOP", tab, "BOTTOM", 0, -4)
	-- Our own gradient rather than the AftLevelup-ToastBG atlas, so this strip and
	-- the unit frame name strips are the same colour and alpha, set in one place.
	local shade = K.CreateTextShade(bar, "BACKGROUND")
	shade.Holder:SetAllPoints(bar)
	shade:SetColor(K.StripColor[1], K.StripColor[2], K.StripColor[3], K.GradientAlpha.strip)
	shade:Show()
	bar:Hide()

	self.RoleWidgets = self:BuildRoleWidgets(bar)
	self.RoleBar = bar
	return bar
end

-- ---------------------------------------------------------------------------
-- State
-- ---------------------------------------------------------------------------

-- Grey the leader-only tools when the player cannot use them.
function Module:UpdateLeaderState()
	if not self.leaderButtons then
		return
	end
	local canLead = CanLead()
	for _, button in ipairs(self.leaderButtons) do
		button:SetEnabled(canLead)
		button.Text:SetTextColor(canLead and 1 or 0.5, canLead and 1 or 0.5, canLead and 1 or 0.5)
	end
end

-- Count the assigned roles across the group, including the player.
function Module:UpdateRoleCount()
	if not self.RoleWidgets then
		return
	end
	local tanks, heals, damage = 0, 0, 0
	local prefix = IsInRaid() and "raid" or "party"
	local members = GetNumGroupMembers()
	for i = 0, members do
		local unit = i == 0 and "player" or (prefix .. i)
		local role = UnitGroupRolesAssigned(unit)
		if role == "TANK" then
			tanks = tanks + 1
		elseif role == "HEALER" then
			heals = heals + 1
		elseif role == "DAMAGER" then
			damage = damage + 1
		end
	end
	for _, widgets in ipairs({ self.RoleWidgets, self.PanelRoleWidgets }) do
		if widgets then
			widgets.tank:SetText(tanks)
			widgets.heal:SetText(heals)
			widgets.damage:SetText(damage)
		end
	end
end

-- Panel holds secure marker buttons, so hiding it is blocked in combat. Defer any
-- hide to when the fight ends.
function Module:SetPanelShown(show)
	if not self.Panel then
		return
	end
	if not show and InCombatLockdown() then
		-- UpdateVisibility runs again on PLAYER_REGEN_ENABLED and calls back here.
		self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateVisibility")
		return
	end
	self.Panel:SetShown(show)
end

-- Show the tab only in a group, and refresh the tools while it is up.
function Module:UpdateVisibility()
	if not self.Tab then
		return
	end

	local inGroup = IsInGroup()

	-- The leader greying and the role counts touch plain buttons and font strings,
	-- so they stay live during a fight.
	if inGroup then
		self:UpdateLeaderState()
		self:UpdateRoleCount()
	end

	-- The panel carries secure world marker buttons, and that makes showing or
	-- hiding anything above them protected too, the tab included. GROUP_ROSTER_UPDATE
	-- fires plenty mid fight (someone joining, leaving, or being replaced), so any
	-- visibility change has to wait for combat to drop or the client blocks it
	-- (GitHub #148).
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateVisibility")
		return
	end

	self:UnregisterEvent("PLAYER_REGEN_ENABLED")

	if inGroup then
		self.Tab:Show()
		-- Role bar is up whenever the panel is closed.
		if self.RoleBar then
			self.RoleBar:SetShown(not (self.Panel and self.Panel:IsShown()))
		end
	else
		self.Tab:Hide()
		if self.RoleBar then
			self.RoleBar:Hide()
		end
		self:SetPanelShown(false)
	end
end

-- ---------------------------------------------------------------------------
-- Enable
-- ---------------------------------------------------------------------------

function Module:OnEnable()
	if not C.GroupTools.Enable then
		return
	end

	-- The tab: a small labelled button that folds the panel out. Movable, and shown
	-- only in a group.
	local tab = CreateFrame("Button", "KKUI_GroupToolsTab", UIParent)
	tab:SetSize(120, 24)
	tab.Text = tab:CreateFontString(nil, "OVERLAY")
	K.SetFont(tab.Text, 12, K.FontOutlineStyle())
	tab.Text:SetPoint("CENTER")
	tab.Text:SetText(L["Group Tools"])
	K.SkinButton(tab)
	tab:Hide()
	self.Tab = tab

	K.CreateMover(tab, "GroupTools", "Group Tools", { "TOP", UIParent, "TOP", 0, -26 }, 120, 24)

	self:BuildRoleBar(tab)
	self:BuildPanel(tab)
	tab:SetScript("OnClick", function()
		if InCombatLockdown() and self.Panel:IsShown() then
			return -- cannot hide the secure marker buttons mid-combat
		end
		-- The role summary and the full panel swap: opening the panel hides the role
		-- bar, closing it brings the role bar back.
		local openPanel = not self.Panel:IsShown()
		self:SetPanelShown(openPanel)
		if self.RoleBar then
			self.RoleBar:SetShown(not openPanel)
		end
	end)

	self:RegisterEvent("GROUP_ROSTER_UPDATE", "UpdateVisibility")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateVisibility")
	self:RegisterEvent("PARTY_LEADER_CHANGED", "UpdateVisibility")
	self:RegisterEvent("PLAYER_ROLES_ASSIGNED", "UpdateRoleCount")
	self:UpdateVisibility()
end
