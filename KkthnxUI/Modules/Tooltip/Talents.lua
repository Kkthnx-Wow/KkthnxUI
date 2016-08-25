local K, C, L, _ = select(2, ...):unpack()
if C.Tooltip.Enable ~= true or C.Tooltip.Talents ~= true then return end

-- TARGET TALENTS(TIPTACTALENTS BY AEZAY)

-- LUA API
local _G = _G
local ipairs = ipairs

-- WOW API
local CreateFrame = CreateFrame
local isInspect = isInspect
local GetText, GetMouseFocus, GetUnit = GetText, GetMouseFocus, GetUnit
local UnitIsPlayer, UnitLevel, UnitName, UnitIsUnit = UnitIsPlayer, UnitLevel, UnitName, UnitIsUnit
local CanInspect = CanInspect
local GatherTalents = GatherTalents
local InspectFrame = InspectFrame

local gtt = GameTooltip

-- STRING CONSTANTS
local TALENTS_PREFIX = TALENTS..":|cffffffff "
local TALENTS_NA = NOT_APPLICABLE:lower()
local TALENTS_NONE = NO.." "..TALENTS

-- OPTION CONSTANTS
local CACHE_SIZE = 25 -- CHANGE CACHE SIZE HERE (DEFAULT 25)
local INSPECT_DELAY = 0.2 -- THE TIME DELAY FOR THE SCHEDULED INSPECTION
local INSPECT_FREQ = 2 -- HOW OFTEN AFTER AN INSPECTION ARE WE ALLOWED TO INSPECT AGAIN?

-- VARIABLES
local ttt = CreateFrame("Frame","TipTacTalents")
local cache = {}
local current = {}

-- TIME OF THE LAST INSPECT REUQEST. INIT THIS TO ZERO, JUST TO MAKE SURE. THIS IS A GLOBAL SO OTHER ADDONS COULD USE THIS VARIABLE AS WELL
lastInspectRequest = 0

-- ALLOW THESE TO BE ACCESSED EXTERNALLY FROM OTHER ADDONS
ttt.cache = cache
ttt.current = current

ttt:Hide()

-- HELPER FUNCTION TO DETERMINE IF AN "INSPECT FRAME" IS OPEN. NATIVE INSPECT AS WELL AS EXAMINER IS SUPPORTED.
local function IsInspectFrameOpen() return (InspectFrame and InspectFrame:IsShown()) or (Examiner and Examiner:IsShown()) end

local function GatherTalents(isInspect)
	-- NEW MOP CODE
	local spec = isInspect and GetInspectSpecialization(current.unit) or GetSpecialization()
	if (not spec or spec == 0) then
		current.format = TALENTS_NONE
	elseif (isInspect) then
		local _, specName = GetSpecializationInfoByID(spec)
		--local _, specName = GetSpecializationInfoForClassID(spec,current.classID)
		current.format = specName or TALENTS_NA
	else
		-- MOP NOTE: IS IT NO LONGER POSSIBLE TO QUERY THE DIFFERENT TALENT SPEC GROUPS ANYMORE?
		-- local group = GetActiveSpecGroup(isInspect) or 1	-- AZ: REPLACED WITH GETACTIVESPECGROUP(), BUT THAT DOES NOT SUPPORT INSPECT?
		local _, specName = GetSpecializationInfo(spec)
		current.format = specName or TALENTS_NA
	end
	-- SET THE TIPS LINE OUTPUT, FOR INSPECT, ONLY UPDATE IF THE TIP IS STILL SHOWING A UNIT!
	if (not isInspect) then
		gtt:AddLine(TALENTS_PREFIX..current.format)
	elseif (gtt:GetUnit()) then
		for i = 2, gtt:NumLines() do
			if ((_G["GameTooltipTextLeft"..i]:GetText() or ""):match("^"..TALENTS_PREFIX)) then
				_G["GameTooltipTextLeft"..i]:SetFormattedText("%s%s",TALENTS_PREFIX,current.format)
				-- DO NOT CALL SHOW() IF THE TIP IS FADING OUT, THIS ONLY WORKS WITH TIPTAC, IF TIPTACTALENTS ARE USED ALONE, IT MIGHT STILL BUG THE FADEOUT
				if (not gtt.fadeOut) then
					gtt:Show()
				end
				break
			end
		end
	end
	-- ORGANISE CACHE
	local cacheSize = CACHE_SIZE
	for i = #cache, 1, -1 do
		if (current.name == cache[i].name) then
			tremove(cache,i)
			break
		end
	end
	if (#cache > cacheSize) then
		tremove(cache,1)
	end
	-- CACHE THE NEW ENTRY
	if (cacheSize > 0) then
		cache[#cache + 1] = CopyTable(current)
	end
end

-- ONEVENT
ttt:SetScript("OnEvent", function(self, event, guid)
	self:UnregisterEvent(event)
	if (guid == current.guid) then
		GatherTalents(1)
	end
end)

-- ONUPDATE
ttt:SetScript("OnUpdate", function(self, elapsed)
	self.nextUpdate = (self.nextUpdate - elapsed)
	if (self.nextUpdate <= 0) then
		self:Hide()
		-- MAKE SURE THE MOUSEOVER UNIT IS STILL OUR UNIT
		-- CHECK ISINSPECTFRAMEOPEN() AGAIN: SINCE IF THE USER RIGHT-CLICKS A UNIT FRAME, AND CLICKS INSPECT, IT COULD CAUSE TTT TO SCHEDULE AN INSPECT, WHILE THE INSPECTION WINDOW IS OPEN
		if (UnitGUID("mouseover") == current.guid) and (not IsInspectFrameOpen()) then
			lastInspectRequest = GetTime()
			self:RegisterEvent("INSPECT_READY")
			NotifyInspect(current.unit)
		end
	end
end)

-- HOOK: ONTOOLTIPSETUNIT
gtt:HookScript("OnTooltipSetUnit", function(self, ...)
	-- ABORT ANY DELAYED INSPECT IN PROGRESS
	ttt:Hide()
	-- GET THE UNIT -- CHECK THE UNITFRAME UNIT IF THIS TIP IS FROM A CONCATED UNIT, SUCH AS "TARGETTARGET".
	local _, unit = self:GetUnit()
	if (not unit) then
		local mFocus = GetMouseFocus()
		if (mFocus) and (mFocus.unit) then
			unit = mFocus.unit
		end
	end
	-- NO UNIT OR NOT A PLAYER
	if (not unit) or (not UnitIsPlayer(unit)) then
		return
	end
	-- ONLY BOTHER FOR PLAYERS OVER LEVEL 9
	local level = UnitLevel(unit)
	if (level > 9 or level == -1) then
		-- WIPE CURRENT RECORD
		wipe(current)
		current.unit = unit
		current.name = UnitName(unit)
		current.guid = UnitGUID(unit)
		-- NO NEED FOR INSPECTION ON THE PLAYER
		if (UnitIsUnit(unit, "player")) then
			GatherTalents()
			return
		end
		-- SHOW CACHED TALENTS, IF AVAILABLE
		local cacheLoaded = false
		for _, entry in ipairs(cache) do
			if (current.name == entry.name) then
				self:AddLine(TALENTS_PREFIX..entry.format)
				current.format = entry.format
				cacheLoaded = true
				break
			end
		end
		-- QUEUE AN INSPECT REQUEST
		if (CanInspect(unit)) and (not IsInspectFrameOpen()) then
			local lastInspectTime = (GetTime() - lastInspectRequest)
			ttt.nextUpdate = (lastInspectTime > INSPECT_FREQ) and INSPECT_DELAY or (INSPECT_FREQ - lastInspectTime + INSPECT_DELAY)
			ttt:Show()
			if (not cacheLoaded) then
				self:AddLine(TALENTS_PREFIX.."Loading...")
			end
		end
	end
end)