local K, C = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

if not Module then
	return
end

local _G = _G

local blizzardCollectgarbage = _G.collectgarbage

function Module:CreateBlizzBugFixes()
	-- Some WoW addons call the lua collectgarbage function irresponsibly.
	-- This causes all execution to halt until it is finished.
	-- This can take more than half a second, which freezes the game in an annoying manner.
	-- Most addons don't need to make such calls, but some do anyway, causing these lockups.
	do
		local oldcollectgarbage = collectgarbage
		oldcollectgarbage("setpause", 110)
		oldcollectgarbage("setstepmul", 200)

		collectgarbage = function(opt, arg)
			if C["General"].FixGarbageCollect == false then
				return oldcollectgarbage(opt, arg)
			end

			-- print("collectgarbage was called by "..strtrim(debugstack(2, 1, 0)).."; opt == \""..tostring(opt).."\", arg == \""..tostring(arg).."\"")
			if opt == "collect" or opt == nil then
				-- fuck addons that want to run full garbage collections, blocking all execution for way too long; no!
			elseif opt == "count" then
				-- this probably just returns the GC's current count, so it should be okay
				return oldcollectgarbage(opt, arg)
			elseif opt == "setpause" then
				-- prevents addons from changing GC pause from default of 110, but still returns current value
				return oldcollectgarbage("setpause", 110)
			elseif opt == "setstepmul" then
				-- prevents addons from changing GC step multiplier from default of 200, but still returns current value
				return oldcollectgarbage("setstepmul", 200)
			elseif opt == "stop" then
				-- no brakes!
			elseif opt == "restart" then
				-- why? no
			elseif opt == "step" then
				--[[ used to think small steps were okay, but it turned out they weren't when a Dugi addon was using a step value of 100, so no here too
				if arg ~= nil then
					if arg <= 10000 then
						--addons running collectgarbage in small steps are okay
						return oldcollectgarbage(opt, arg)
					end
				else
					--default step value is probably okay too
					return oldcollectgarbage(opt, arg)
				end
				]]
			else
				-- if lua adds something new like isrunning to this, it should still work
				return oldcollectgarbage(opt, arg)
			end
		end

		-- UpdateAddOnMemoryUsage is a waste of time and some addons like Details call it periodically for no apparent reason
		-- this hook makes memory profiling addons that call GetAddOnMemoryUsage show 0 or the last returned value of course
		local oldUpdateAddOnMemoryUsage = UpdateAddOnMemoryUsage
		UpdateAddOnMemoryUsage = function(...)
			if C["General"].FixGarbageCollect == false then
				return oldUpdateAddOnMemoryUsage(...)
			end
		end

		-- macro to check current addon memory usage
		-- /run UpdateAddOnMemoryUsage()local total = 0 for i=1,GetNumAddOns()do total=total+GetAddOnMemoryUsage(i)end print(total)
	end
end