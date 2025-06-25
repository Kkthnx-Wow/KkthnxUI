-- Script to extract missing localization strings from GUI files
-- This will help identify what needs to be added to locale files

local function extractMissingLocales()
	local missingStrings = {}
	local guiFile = "Config/GUI.lua"

	-- Read the GUI file
	local file = io.open(guiFile, "r")
	if not file then
		print("Could not open GUI file")
		return
	end

	local content = file:read("*all")
	file:close()

	-- Extract strings from CreateSwitch
	for str in content:gmatch('Window:CreateSwitch%([^)]*"([^"]+)"[^)]*%)') do
		if not str:match("^L%[") and not str:match("^enableTextColor") and not str:match("^newFeatureIcon") then
			table.insert(missingStrings, { type = "Switch", text = str })
		end
	end

	-- Extract strings from CreateSlider
	for str in content:gmatch('Window:CreateSlider%([^)]*"([^"]+)"[^)]*%)') do
		if not str:match("^L%[") and not str:match("^enableTextColor") and not str:match("^newFeatureIcon") then
			table.insert(missingStrings, { type = "Slider", text = str })
		end
	end

	-- Extract strings from CreateDropdown
	for str in content:gmatch('Window:CreateDropdown%([^)]*"([^"]+)"[^)]*%)') do
		if not str:match("^L%[") and not str:match("^enableTextColor") and not str:match("^newFeatureIcon") then
			table.insert(missingStrings, { type = "Dropdown", text = str })
		end
	end

	-- Extract strings from CreateEditBox
	for str in content:gmatch('Window:CreateEditBox%([^)]*"([^"]+)"[^)]*%)') do
		if not str:match("^L%[") and not str:match("^enableTextColor") and not str:match("^newFeatureIcon") then
			table.insert(missingStrings, { type = "EditBox", text = str })
		end
	end

	-- Extract strings from CreateSection
	for str in content:gmatch('Window:CreateSection%("([^"]+)"%)') do
		if not str:match("^L%[") and not str:match("^enableTextColor") and not str:match("^newFeatureIcon") then
			table.insert(missingStrings, { type = "Section", text = str })
		end
	end

	-- Remove duplicates
	local uniqueStrings = {}
	local seen = {}
	for _, item in ipairs(missingStrings) do
		if not seen[item.text] then
			seen[item.text] = true
			table.insert(uniqueStrings, item)
		end
	end

	-- Sort by type and text
	table.sort(uniqueStrings, function(a, b)
		if a.type == b.type then
			return a.text < b.text
		end
		return a.type < b.type
	end)

	-- Output results
	print("Missing localization strings found:")
	print("==================================")

	local currentType = ""
	for _, item in ipairs(uniqueStrings) do
		if item.type ~= currentType then
			currentType = item.type
			print("\n" .. currentType .. " elements:")
		end
		print('  L["' .. item.text .. '"] = "' .. item.text .. '"')
	end

	print("\nTotal missing strings: " .. #uniqueStrings)
end

-- Run the extraction
extractMissingLocales()
