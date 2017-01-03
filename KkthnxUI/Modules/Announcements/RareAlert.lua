local K, C, L = unpack(select(2, ...))
if not C.Announcments.RareAlert ~= true then return end

-- Wow API
local ChatTypeInfo = ChatTypeInfo
local GetCurrentMapAreaID =GetCurrentMapAreaID
local GetObjectIconTextureCoords = GetObjectIconTextureCoords
local PlaySoundFile = PlaySoundFile
local print = print
local RaidNotice_AddMessage = RaidNotice_AddMessage

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: C_Vignettes, RaidWarningFrame

local AlertBackList = {
	[971] = true, -- </ Alliance garrison > --
	[976] = true, -- </ Horde garrison > --
}

local RareAlert = CreateFrame("Frame")
RareAlert:RegisterEvent("VIGNETTE_ADDED")
RareAlert:SetScript("OnEvent", function(self, event, ID)
	if AlertBackList[GetCurrentMapAreaID()] or not ID then return end -- </ Kill it if we do not have an id or from BackList > --

	self.Vignettes = self.Vignettes or {}
	if self.Vignettes[ID] then return end
	local X, Y, Name, Icon = C_Vignettes.GetVignetteInfoFromInstanceID(ID)
	local Left, Right, Top, Bottom = GetObjectIconTextureCoords(Icon)
	PlaySoundFile("Sound\\Interface\\RaidWarning.ogg")
	local String = "|TInterface\\MINIMAP\\ObjectIconsAtlas:0:0:0:0:256:256:"..(Left * 256)..":"..(Right * 256)..":"..(Top * 256)..":"..(Bottom * 256).."|t"
	RaidNotice_AddMessage(RaidWarningFrame, String..Name.." spotted!", ChatTypeInfo["RAID_WARNING"])
	print(String..Name, "spotted!")
	self.Vignettes[ID] = true
end)