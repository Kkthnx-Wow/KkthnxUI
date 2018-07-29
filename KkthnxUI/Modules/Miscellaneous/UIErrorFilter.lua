local K = unpack(select(2, ...))
local Module = K:NewModule("UIErrorFilter", "AceEvent-3.0")


-- unregister LUA_WARNING from other addons (ie. UIParent and possibly !BugGrabber)
local Frames = {GetFramesRegisteredForEvent("LUA_WARNING")}

function Module:OnEvent(_, _, warnMessage)
	if (warnMessage:match("^Couldn't open"))
	or (warnMessage:match("^Error loading"))
	or (warnMessage:match("^%(null%)"))
	or (warnMessage:match("^Deferred XML")) then
		return
	end

	geterrorhandler()(warnMessage, true)
end

function Module:OnEnable()
	for _, Frame in ipairs(Frames) do
		self.UnregisterEvent(Frame, "LUA_WARNING")
	end

	self:RegisterEvent("LUA_WARNING")
end