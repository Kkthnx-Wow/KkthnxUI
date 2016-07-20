local K, C, L, _ = select(2, ...):unpack()
if C.Tooltip.Enable ~= true or C.Tooltip.Talents ~= true then return end

-- Target Talents(TipTacTalents by Aezay)
-- Locals
local _G = _G
local ipairs = ipairs
local CreateFrame = CreateFrame
local GetTalentTabInfo = GetTalentTabInfo
local isInspect = isInspect
local GetText, GetMouseFocus, GetUnit = GetText, GetMouseFocus, GetUnit
local UnitIsPlayer, UnitLevel, UnitIsPlayer, UnitName, UnitIsUnit = UnitIsPlayer, UnitLevel, UnitIsPlayer, UnitName, UnitIsUnit
local CanInspect = CanInspect
local GatherTalents = GatherTalents
local InspectFrame = InspectFrame

local ttt = CreateFrame("Frame", "TipTacTalents")
local cache = {}
local current = {}
local TALENTS_PREFIX = TALENTS..":|cffffffff "
local CACHE_SIZE = 25	-- Change cache size here (Default 25)

-- Allow these to be accessed through other addons
ttt.cache = cache
ttt.current = current

-- Gather Talents
-- Target Talents(TipTacTalents by Aezay)
if C.Tooltip.Talents == true then
	local gtt = GameTooltip

	-- GatherTalents
	local function GatherTalents(isInspect)
		-- Inspect functions will always use the active spec when not inspecting
		local group = GetActiveTalentGroup(isInspect)
		-- Get points per tree, and set "maxTree" to the tree with most points
		local maxTree, _ = 1
		for i = 1, 3 do
			_, _, current[i] = GetTalentTabInfo(i,isInspect,nil,group)
			if (current[i] > current[maxTree]) then
				maxTree = i
			end
		end
		current.tree = GetTalentTabInfo(maxTree,isInspect,nil,group)
		-- Customise output. Use TipTac setting if it exists, otherwise just use formatting style one.
		local talentFormat = (TipTac_Config and TipTac_Config.talentFormat or 1)
		if (current[maxTree] == 0) then
			current.format = L_TOOLTIP_NO_TALENT
		elseif (talentFormat == 1) then
			current.format = current.tree.." ("..current[1].."/"..current[2].."/"..current[3]..")"
		elseif (talentFormat == 2) then
			current.format = current.tree
		elseif (talentFormat == 3) then
			current.format = current[1].."/"..current[2].."/"..current[3]
		end
		-- Set the tips line output, for inspect, only update if the tip is still showing a unit!
		if (not isInspect) then
			gtt:AddLine(TALENTS_PREFIX..current.format)
		elseif (gtt:GetUnit()) then
			for i = 2, gtt:NumLines() do
				if ((_G["GameTooltipTextLeft"..i]:GetText() or ""):match("^"..TALENTS_PREFIX)) then
					_G["GameTooltipTextLeft"..i]:SetFormattedText("%s%s",TALENTS_PREFIX,current.format)
					-- Do not call Show() if the tip is fading out, this only works with TipTac, if TipTacTalents are used alone, it might still bug the fadeout
					if (not gtt.fadeOut) then
						gtt:Show()
					end
					break
				end
			end
		end
		-- Organise Cache
		local cacheSize = (TipTac_Config and TipTac_Config.talentCacheSize or CACHE_SIZE)
		for i = #cache, 1, -1 do
			if (current.name == cache[i].name) then
				tremove(cache,i)
				break
			end
		end
		if (#cache > cacheSize) then
			tremove(cache,1)
		end
		-- Cache the new entry
		if (cacheSize > 0) then
			cache[#cache + 1] = CopyTable(current)
		end
	end

	-- OnEvent
	ttt:SetScript("OnEvent",function(self,event)
		self:UnregisterEvent("INSPECT_TALENT_READY")
		if (gtt:GetUnit() == current.name) then
			GatherTalents(1)
		end
	end)

	-- HOOK: OnTooltipSetUnit
	gtt:HookScript("OnTooltipSetUnit",function(self,...)
		-- Get the unit -- Check the UnitFrame unit if this tip is from a concated unit, such as "targettarget".
		local _, unit = self:GetUnit()
		if (not unit) then
			local mFocus = GetMouseFocus()
			if (mFocus) and (mFocus.unit) then
				unit = mFocus.unit
			end
		end
		-- Only for players over level 9 -- Ignore PvP flagged people, unless they are friendly
		if (UnitIsPlayer(unit)) and (UnitLevel(unit) > 9 or UnitLevel(unit) == -1) and (CanInspect(unit)) then
			wipe(current)
			current.name = UnitName(unit)
			-- Player
			if (UnitIsUnit(unit,"player")) then
				GatherTalents()
				-- Others
			else
				local allowInspect = (not InspectFrame or not InspectFrame:IsShown()) and (not Examiner or not Examiner:IsShown())
				if (allowInspect) then
					ttt:RegisterEvent("INSPECT_TALENT_READY")
					NotifyInspect(unit)
				end
				for _, entry in ipairs(cache) do
					if (current.name == entry.name) then
						self:AddLine(TALENTS_PREFIX..entry.format)
						current.tree = entry.tree
						current.format = entry.format
						current[1], current[2], current[3] = entry[1], entry[2], entry[3]
						return
					end
				end
				if (allowInspect) then
					self:AddLine(TALENTS_PREFIX..L_TOOLTIP_LOADING)
				end
			end
		end
	end)
end