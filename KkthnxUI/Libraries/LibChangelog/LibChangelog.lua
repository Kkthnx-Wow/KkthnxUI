-- LibChangelog
-- Feature-rich changelog viewer with semantic version handling, search, unread filtering and robust UI

local MAJOR, MINOR = "LibChangelog-KkthnxUI", 1
local LibChangelog = LibStub:NewLibrary(MAJOR, MINOR)

if not LibChangelog then
	return
end

-- Lua APIs
local error = error

-- WoW APIs and UI functions
local CreateFrame = CreateFrame
local UIParent = UIParent
local GetLocale = GetLocale
local GameTooltip = GameTooltip
local IsControlKeyDown = IsControlKeyDown
local C_Timer = C_Timer

-- Local variables for GameFont constants
local GameFontNormalHuge = GameFontNormalHuge
local GameFontNormal = GameFontNormal
local GameFontHighlight = GameFontHighlight
local GameFontDisableHuge = GameFontDisableHuge
local GameFontDisable = GameFontDisable
local GameFontDisableHighlight = GameFontDisableHighlight

-- Debug toggle (can be set at runtime: LibStub("LibChangelog-KkthnxUI").GlobalDebug = true)
LibChangelog.GlobalDebug = LibChangelog.GlobalDebug or false
local function dbg(addonData, ...)
	if LibChangelog.GlobalDebug or (addonData and addonData.debug) then
		print("|cff99ccffLibChangelog|r:", ...)
	end
end

-- Localization strings for different languages
local L = {
	["enUS"] = {
		CHANGLOG_VIEWER = " Changelog",
		HIDE_UNTIL_NEXT_UPDATE = "Hide until next update",
		SEARCH = "Search:",
		UNREAD_ONLY = "Unread only",
		MARK_LATEST_READ = "Mark latest read",
		NO_ENTRIES = "No entries to display.",
	},
	["esES"] = {
		CHANGLOG_VIEWER = " Registro de cambios",
		HIDE_UNTIL_NEXT_UPDATE = "Ocultar hasta la próxima actualización",
		SEARCH = "Buscar:",
		UNREAD_ONLY = "Solo no leídos",
		MARK_LATEST_READ = "Marcar última como leída",
		NO_ENTRIES = "No hay entradas para mostrar.",
	},
	["deDE"] = {
		CHANGLOG_VIEWER = " Änderungsprotokoll",
		HIDE_UNTIL_NEXT_UPDATE = "Verstecken bis zum nächsten Update",
		SEARCH = "Suche:",
		UNREAD_ONLY = "Nur ungelesene",
		MARK_LATEST_READ = "Neueste als gelesen",
		NO_ENTRIES = "Keine Einträge vorhanden.",
	},
	["frFR"] = {
		CHANGLOG_VIEWER = " Journal des modifications",
		HIDE_UNTIL_NEXT_UPDATE = "Cacher jusqu'à la prochaine mise à jour",
		SEARCH = "Rechercher :",
		UNREAD_ONLY = "Non lus seulement",
		MARK_LATEST_READ = "Marquer la dernière lue",
		NO_ENTRIES = "Aucune entrée à afficher.",
	},
	["itIT"] = {
		CHANGLOG_VIEWER = " Registro delle modifiche",
		HIDE_UNTIL_NEXT_UPDATE = "Nascondi fino al prossimo aggiornamento",
		SEARCH = "Cerca:",
		UNREAD_ONLY = "Solo non letti",
		MARK_LATEST_READ = "Segna ultimo come letto",
		NO_ENTRIES = "Nessuna voce da mostrare.",
	},
	["koKR"] = {
		CHANGLOG_VIEWER = " 변경 로그",
		HIDE_UNTIL_NEXT_UPDATE = "다음 업데이트까지 숨기기",
		SEARCH = "검색:",
		UNREAD_ONLY = "읽지 않음만",
		MARK_LATEST_READ = "최신 항목 읽음 처리",
		NO_ENTRIES = "표시할 항목이 없습니다.",
	},
	["ptBR"] = {
		CHANGLOG_VIEWER = " Registro de mudanças",
		HIDE_UNTIL_NEXT_UPDATE = "Ocultar até a próxima atualização",
		SEARCH = "Pesquisar:",
		UNREAD_ONLY = "Somente não lidos",
		MARK_LATEST_READ = "Marcar último como lido",
		NO_ENTRIES = "Nenhuma entrada para exibir.",
	},
	["ruRU"] = {
		CHANGLOG_VIEWER = " Журнал изменений",
		HIDE_UNTIL_NEXT_UPDATE = "Скрыть до следующего обновления",
		SEARCH = "Поиск:",
		UNREAD_ONLY = "Только непрочитанные",
		MARK_LATEST_READ = "Отметить последний прочитанным",
		NO_ENTRIES = "Нет записей для отображения.",
	},
	["zhCN"] = {
		CHANGLOG_VIEWER = " 更新日志",
		HIDE_UNTIL_NEXT_UPDATE = "直到下次更新前隐藏",
		SEARCH = "搜索：",
		UNREAD_ONLY = "仅未读",
		MARK_LATEST_READ = "标记最新为已读",
		NO_ENTRIES = "没有可显示的条目。",
	},
	["zhTW"] = {
		CHANGLOG_VIEWER = " 更新日誌",
		HIDE_UNTIL_NEXT_UPDATE = "直到下次更新前隱藏",
		SEARCH = "搜尋：",
		UNREAD_ONLY = "僅未讀",
		MARK_LATEST_READ = "標記最新為已讀",
		NO_ENTRIES = "沒有可顯示的項目。",
	},
}

-- Retrieve the appropriate localization based on the player's language
local lang = GetLocale()
local localization = L[lang] or L["enUS"]

-- Helpers: safe skinning wrappers (methods exist in KkthnxUI but we guard for robustness)
local function SafeCall(object, methodName, ...)
	if object and methodName and object[methodName] then
		pcall(object[methodName], object, ...)
		return true
	end
	return false
end

-- Compute content width with fallbacks in case layout isn't finalized yet
local function GetContentWidth(frame)
	local w = (frame.scrollBar and frame.scrollBar:GetWidth()) or 0
	if not w or w <= 1 then
		local insetW = frame.Inset and frame.Inset:GetWidth() or 0
		local frameW = frame:GetWidth() or 0
		w = (insetW > 0 and insetW - 32) or (frameW > 0 and frameW - 60) or 460
	end
	if w < 1 then
		w = 460
	end
	return w
end

-- Parse a semantic version from a Version string like "[10.6.0] - 2024-12-19 - Patch 11.0.7"
-- Returns major, minor, patch as numbers; nil if not found
local function ParseSemanticVersion(versionString)
	if type(versionString) ~= "string" then
		return nil
	end
	local ver = versionString:match("%[(%d+%.%d+%.%d+)%]") or versionString:match("^(%d+%.%d+%.%d+)$")
	if not ver then
		return nil
	end
	local maj, min, pat = ver:match("^(%d+)%.(%d+)%.(%d+)$")
	if not maj then
		return nil
	end
	return tonumber(maj), tonumber(min), tonumber(pat)
end

-- Compare two Version strings semantically; returns -1, 0, 1 (a<b, a==b, a>b)
local function CompareVersions(a, b)
	if a == b then
		return 0
	end
	local aM, aN, aP = ParseSemanticVersion(a)
	local bM, bN, bP = ParseSemanticVersion(b)
	if not aM or not bM then
		-- Fallback to string compare if parsing failed
		if a == b then
			return 0
		end
		return a < b and -1 or 1
	end
	if aM ~= bM then
		return aM < bM and -1 or 1
	end
	if aN ~= bN then
		return aN < bN and -1 or 1
	end
	if aP ~= bP then
		return aP < bP and -1 or 1
	end
	return 0
end

local NEW_MESSAGE_FONTS = {
	version = GameFontNormalHuge,
	title = GameFontNormal,
	text = GameFontHighlight,
}

local VIEWED_MESSAGE_FONTS = {
	version = GameFontDisableHuge,
	title = GameFontDisable,
	text = GameFontDisableHighlight,
}

function LibChangelog:Register(addonName, changelogTable, savedVariablesTable, lastReadVersionKey, onlyShowWhenNewVersionKey, texts)
	if not addonName or not changelogTable or not savedVariablesTable or not lastReadVersionKey or not onlyShowWhenNewVersionKey then
		return error("LibChangelog: Missing required parameters (addonName, changelogTable, savedVariablesTable, lastReadVersionKey, onlyShowWhenNewVersionKey)", 2)
	end
	if self[addonName] then
		return error("LibChangelog: Addon '" .. addonName .. "' is already registered", 2)
	end

	-- Normalize and index changelog entries without reordering; newest is first in provided table
	local indexed = {}
	for i = 1, #changelogTable do
		local entry = changelogTable[i]
		if entry and type(entry) == "table" and entry.Version then
			local maj, min, pat = ParseSemanticVersion(entry.Version)
			entry.__semver = { maj = maj or -1, min = min or -1, pat = pat or -1 }
			indexed[#indexed + 1] = entry
		end
	end

	self[addonName] = {
		changelogTable = indexed,
		savedVariablesTable = savedVariablesTable,
		lastReadVersionKey = lastReadVersionKey,
		onlyShowWhenNewVersionKey = onlyShowWhenNewVersionKey,
		texts = texts or {},
	}

	-- Per-addon debug opt-in
	if texts and texts.debug then
		self[addonName].debug = true
	end

	dbg(self[addonName], "Registered:", addonName, "entries=", #indexed)
end

function LibChangelog:CreateString(frame, text, font, offset)
	if not frame then
		return error("LibChangelog:CreateString missing required parameter 'frame'", 2)
	end
	offset = offset or -5
	local entry = frame.scrollChild:CreateFontString(nil, "ARTWORK")
	entry:SetFontObject(font or GameFontNormal)
	entry:SetText(text)
	entry:SetJustifyH("LEFT")
	entry:SetWordWrap(true)
	local width = GetContentWidth(frame)
	entry:SetWidth(width)
	-- Debug: show when width looks suspicious
	if width < 50 then
		dbg(nil, "CreateString width too small:", width)
	end

	if frame.previous then
		entry:SetPoint("TOPLEFT", frame.previous, "BOTTOMLEFT", 0, offset)
	else
		entry:SetPoint("TOPLEFT", frame.scrollChild, "TOPLEFT", -5)
	end

	frame.previous = entry
	return entry
end

function LibChangelog:CreateBulletedListEntry(frame, text, font, offset)
	offset = offset or 0
	local BULLET_WIDTH = 12
	local bullet = self:CreateString(frame, " • ", font, offset)
	if bullet then
		bullet:SetWidth(BULLET_WIDTH)
		bullet:SetJustifyV("TOP")
	end

	local entry = self:CreateString(frame, text, font, offset)
	if entry then
		entry:SetPoint("TOPLEFT", bullet, "TOPRIGHT")
		local cw = GetContentWidth(frame) - BULLET_WIDTH
		entry:SetWidth(cw)
		if cw < 50 then
			dbg(nil, "Bulleted width too small:", cw)
		end
	end

	if bullet and entry then
		bullet:SetHeight(entry:GetStringHeight())
		frame.previous = bullet
	end

	return bullet
end

-- Decide if the changelog should auto-show based on saved variables and semantic version
function LibChangelog:_ShouldAutoShow(addonData)
	local first = addonData.changelogTable[1]
	if not first then
		return false
	end
	local saved = addonData.savedVariablesTable
	local lastRead = saved[addonData.lastReadVersionKey]
	local onlyWhenNew = saved[addonData.onlyShowWhenNewVersionKey]
	dbg(addonData, "AutoShow? first=", first.Version, "lastRead=", lastRead, "onlyNew=", onlyWhenNew)
	if not onlyWhenNew then
		return true
	end
	if not lastRead then
		return true
	end
	return CompareVersions(first.Version, lastRead) == 1
end

-- Build or rebuild the scroll content based on filters
function LibChangelog:_BuildContent(addonData)
	local frame = addonData.frame
	if not frame then
		return
	end
	-- Clear previous content (FontStrings are regions; also hide any leftover child frames)
	frame.previous = nil
	local child = frame.scrollChild
	if child then
		if child.GetRegions then
			local regions = { child:GetRegions() }
			for i = 1, #regions do
				regions[i]:Hide()
			end
		end
		if child.GetChildren then
			local children = { child:GetChildren() }
			for i = 1, #children do
				children[i]:Hide()
			end
		end
		local cw = GetContentWidth(frame)
		child:SetSize(cw, 1)
		dbg(addonData, "BuildContent widths: frame=", frame:GetWidth(), "inset=", frame.Inset and frame.Inset:GetWidth(), "scroll=", frame.scrollBar and frame.scrollBar:GetWidth(), "content=", cw)
	end

	local saved = addonData.savedVariablesTable
	local lastRead = saved[addonData.lastReadVersionKey]
	local filterText = frame.SearchBox and frame.SearchBox:GetText() or ""
	filterText = (filterText and filterText ~= "" and filterText:lower()) or nil
	local unreadOnly = frame.UnreadOnlyCheck and frame.UnreadOnlyCheck:GetChecked() or false

	local startIndex, endIndex = 1, #addonData.changelogTable
	if frame.LatestOnly then
		endIndex = 1
	end

	dbg(addonData, "Filter: unreadOnly=", unreadOnly, "filterText=", filterText or "<nil>", "range=", startIndex, "-", endIndex)

	local printed = 0
	local totalH = 0
	local createdCount = 0
	for i = startIndex, endIndex do
		local versionEntry = addonData.changelogTable[i]
		local isRead = (lastRead and CompareVersions(lastRead, versionEntry.Version) >= 0) or false
		local fonts = isRead and VIEWED_MESSAGE_FONTS or NEW_MESSAGE_FONTS

		local function matches()
			if not filterText then
				return true
			end
			if tostring(versionEntry.Version):lower():find(filterText, 1, true) then
				return true
			end
			if versionEntry.General and tostring(versionEntry.General):lower():find(filterText, 1, true) then
				return true
			end
			if versionEntry.Sections then
				for j = 1, #versionEntry.Sections do
					local section = versionEntry.Sections[j]
					if section.Header and tostring(section.Header):lower():find(filterText, 1, true) then
						return true
					end
					local entries = section.Entries
					if entries then
						for k = 1, #entries do
							if tostring(entries[k]):lower():find(filterText, 1, true) then
								return true
							end
						end
					end
				end
			end
			return false
		end

		local ok = matches()
		if printed < 5 then
			printed = printed + 1
			dbg(addonData, "Entry", i, versionEntry.Version, "isRead=", isRead, "matches=", ok)
		end

		if ok then
			createdCount = createdCount + 1
			local titleFS = self:CreateString(frame, "## " .. versionEntry.Version, fonts.version, -30)
			totalH = totalH + (titleFS:GetStringHeight() or 0) + 30
			if versionEntry.General then
				local gfs = self:CreateString(frame, versionEntry.General, fonts.text)
				totalH = totalH + (gfs:GetStringHeight() or 0) + 5
			end
			if versionEntry.Sections then
				for j = 1, #versionEntry.Sections do
					local section = versionEntry.Sections[j]
					local sh = self:CreateString(frame, "### " .. section.Header, fonts.title, -8)
					totalH = totalH + (sh:GetStringHeight() or 0) + 8
					local entries = section.Entries
					if entries then
						for k = 1, #entries do
							local efs = self:CreateBulletedListEntry(frame, entries[k], fonts.text)
							totalH = totalH + (efs and efs:GetHeight() or 0) + 0
						end
					end
				end
			end
		end
	end
	-- If nothing was created, show placeholder so users see something
	if createdCount == 0 then
		local fs = self:CreateString(frame, localization.NO_ENTRIES, GameFontHighlight)
		fs:SetJustifyH("CENTER")
		fs:SetPoint("TOP", frame.scrollChild, "TOP", 0, -16)
		totalH = totalH + (fs:GetStringHeight() or 16) + 16
	end
	-- Ensure the scroll child is tall enough
	if child then
		local minH = math.max(totalH + 40, frame.scrollBar:GetHeight() or 400)
		child:SetHeight(minH)
		if frame.scrollBar and frame.scrollBar.UpdateScrollChildRect then
			frame.scrollBar:UpdateScrollChildRect()
		end
		dbg(addonData, "Created entries:", createdCount, "computed height:", totalH, "-> child height:", minH)
	end
end

-- Create the frame lazily on first show
function LibChangelog:_EnsureFrame(addonName)
	local addonData = self[addonName]
	if not addonData then
		return nil
	end
	if addonData.frame then
		return addonData.frame
	end
	local frame = CreateFrame("Frame", "LibChangelogFrame_" .. addonName, UIParent, "ButtonFrameTemplate")
	if ButtonFrameTemplate_HidePortrait then
		ButtonFrameTemplate_HidePortrait(frame)
	end
	if frame.SetTitle then
		frame:SetTitle(addonData.texts.title or (addonName .. localization.CHANGLOG_VIEWER))
	end

	frame.Inset:SetPoint("TOPLEFT", 4, -25)
	frame:SetSize(560, 560)
	frame:SetPoint("CENTER")
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetResizable(true)
	if frame.SetResizeBounds then
		frame:SetResizeBounds(420, 360)
	elseif frame.SetMinResize then
		frame:SetMinResize(420, 360)
	end
	frame:SetClampedToScreen(true)
	frame:SetScript("OnDragStart", function(s)
		s:StartMoving()
	end)
	frame:SetScript("OnDragStop", function(s)
		s:StopMovingOrSizing()
	end)
	frame:SetScript("OnSizeChanged", function()
		LibChangelog:_BuildContent(addonData)
	end)
	frame:SetScript("OnShow", function()
		LibChangelog:_BuildContent(addonData)
	end)

	-- Apply KkthnxUI skins when available
	SafeCall(frame, "StripTextures")
	SafeCall(frame, "CreateBorder")

	-- Scroll area
	frame.scrollBar = CreateFrame("ScrollFrame", "LibChangelogScrollFrame_" .. addonName, frame.Inset, "UIPanelScrollFrameTemplate")
	frame.scrollBar:SetPoint("TOPLEFT", 10, -36)
	frame.scrollBar:SetPoint("BOTTOMRIGHT", -22, 6)

	frame.scrollChild = CreateFrame("Frame", "LibChangelogScrollChild_" .. addonName, frame.scrollBar)
	frame.scrollChild:SetPoint("TOPLEFT")
	frame.scrollChild:SetSize(1, 1)
	frame.scrollBar:SetScrollChild(frame.scrollChild)

	-- Skin scroll/close if available
	if frame.scrollBar.ScrollBar then
		SafeCall(frame.scrollBar.ScrollBar, "SkinScrollBar")
	end
	SafeCall(frame.CloseButton, "SkinCloseButton")

	-- Bottom-left: Hide until next update (existing behavior)
	frame.CheckButton = CreateFrame("CheckButton", "LibChangelogCheckButton_" .. addonName, frame, "UICheckButtonTemplate")
	frame.CheckButton:SetChecked(addonData.savedVariablesTable[addonData.onlyShowWhenNewVersionKey])
	frame.CheckButton:SetFrameStrata("HIGH")
	frame.CheckButton:SetSize(24, 24)
	frame.CheckButton:SetPoint("LEFT", frame, "BOTTOMLEFT", 6, 16)
	frame.CheckButton:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	frame.CheckButton:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
	frame.CheckButton:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight", "ADD")
	frame.CheckButton:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
	frame.CheckButton:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
	frame.CheckButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(addonData.texts.onlyShowWhenNewVersion or localization.HIDE_UNTIL_NEXT_UPDATE, 1, 1, 1)
		GameTooltip:Show()
	end)
	frame.CheckButton:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	frame.CheckButton:SetScript("OnClick", function(self)
		local isChecked = self:GetChecked()
		addonData.savedVariablesTable[addonData.onlyShowWhenNewVersionKey] = isChecked
		frame.CheckButton:SetChecked(isChecked)
	end)
	frame.CheckButton.Label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.CheckButton.Label:SetPoint("LEFT", frame.CheckButton, "RIGHT", 6, 0)
	frame.CheckButton.Label:SetText(addonData.texts.onlyShowWhenNewVersion or localization.HIDE_UNTIL_NEXT_UPDATE)

	-- Bottom-right: Unread only toggle
	frame.UnreadOnlyCheck = CreateFrame("CheckButton", "LibChangelogUnreadOnly_" .. addonName, frame, "UICheckButtonTemplate")
	frame.UnreadOnlyCheck:SetSize(20, 20)
	frame.UnreadOnlyCheck:SetPoint("RIGHT", frame, "BOTTOMRIGHT", -300, 16)
	frame.UnreadOnlyCheck:SetScript("OnClick", function()
		LibChangelog:_BuildContent(addonData)
	end)
	frame.UnreadOnlyLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.UnreadOnlyLabel:SetPoint("LEFT", frame.UnreadOnlyCheck, "RIGHT", 6, 0)
	frame.UnreadOnlyLabel:SetText(localization.UNREAD_ONLY)

	-- Bottom-right: Mark as read button (sets lastReadVersion to latest)
	frame.MarkRead = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	frame.MarkRead:SetSize(140, 20)
	frame.MarkRead:SetPoint("RIGHT", frame, "BOTTOMRIGHT", -6, 14)
	frame.MarkRead:SetText(localization.MARK_LATEST_READ)
	frame.MarkRead:SkinButton()
	frame.MarkRead:SetScript("OnClick", function()
		local first = addonData.changelogTable[1]
		if first then
			addonData.savedVariablesTable[addonData.lastReadVersionKey] = first.Version
			LibChangelog:_BuildContent(addonData)
		end
	end)

	addonData.frame = frame
	dbg(addonData, "EnsureFrame: size=", frame:GetWidth(), frame:GetHeight())
	return frame
end

function LibChangelog:ShowChangelog(addonName)
	local addonData = self[addonName]
	if not addonData then
		return error("LibChangelog: '" .. addonName .. "' was not registered. Please use :Register() first", 2)
	end

	-- Respect previous behavior: don't show if user wants only when new and latest is not newer than last read
	local saved = addonData.savedVariablesTable
	local firstEntry = addonData.changelogTable[1]
	if firstEntry then
		local lastRead = saved[addonData.lastReadVersionKey]
		local onlyWhenNew = saved[addonData.onlyShowWhenNewVersionKey]
		dbg(addonData, "Gate: first=", firstEntry.Version, "lastRead=", lastRead, "onlyNew=", onlyWhenNew)
		if onlyWhenNew and lastRead and CompareVersions(firstEntry.Version, lastRead) <= 0 then
			return
		end
	end

	local frame = self:_EnsureFrame(addonName)
	if not frame then
		return
	end

	frame.LatestOnly = false
	self:_BuildContent(addonData)
	frame:Show()

	-- Backward-compat: mark latest as read on open unless explicitly disabled via texts.autoMarkOnOpen = false
	if firstEntry then
		local autoMark = true
		if addonData.texts and addonData.texts.autoMarkOnOpen == false then
			autoMark = false
		end
		if autoMark then
			saved[addonData.lastReadVersionKey] = firstEntry.Version
		end
	end

	-- Schedule a rebuild next frame to ensure widths are available after layout
	if C_Timer and C_Timer.After then
		C_Timer.After(0, function()
			if addonData.frame and addonData.frame:IsShown() then
				dbg(addonData, "Deferred rebuild")
				LibChangelog:_BuildContent(addonData)
			end
		end)
	end
end

-- Show only the latest entry convenience
function LibChangelog:ShowLatest(addonName)
	local addonData = self[addonName]
	if not addonData then
		return error("LibChangelog: '" .. addonName .. "' was not registered. Please use :Register() first", 2)
	end
	local frame = self:_EnsureFrame(addonName)
	if not frame then
		return
	end
	frame.LatestOnly = true
	self:_BuildContent(addonData)
	frame:Show()
end

-- Optional helper to trigger auto-show logic from caller while distinguishing from manual open
function LibChangelog:AutoShow(addonName)
	local addonData = self[addonName]
	if not addonData then
		return
	end
	if self:_ShouldAutoShow(addonData) then
		self:ShowChangelog(addonName)
	end
end

-- Optional: allow replacing the changelog after registration
function LibChangelog:SetChangelog(addonName, changelogTable)
	local addonData = self[addonName]
	if not addonData then
		return error("LibChangelog: '" .. addonName .. "' was not registered. Please use :Register() first", 2)
	end
	local indexed = {}
	for i = 1, #changelogTable do
		local entry = changelogTable[i]
		if entry and type(entry) == "table" and entry.Version then
			local maj, min, pat = ParseSemanticVersion(entry.Version)
			entry.__semver = { maj = maj or -1, min = min or -1, pat = pat or -1 }
			indexed[#indexed + 1] = entry
		end
	end
	addonData.changelogTable = indexed
	if addonData.frame then
		self:_BuildContent(addonData)
	end
end

-- Optional: unregister an addon from the library
function LibChangelog:Unregister(addonName)
	local addonData = self[addonName]
	if not addonData then
		return
	end
	if addonData.frame then
		addonData.frame:Hide()
	end
	self[addonName] = nil
end
