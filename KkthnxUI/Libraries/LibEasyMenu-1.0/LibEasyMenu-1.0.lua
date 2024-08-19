-- LibEasyMenu - A library for creating dropdown menus in World of Warcraft addons

-- Version information
local MAJOR, MINOR = "LibEasyMenu-1.0", 1

-- Create a new library using LibStub
local LibEasyMenu = LibStub:NewLibrary(MAJOR, MINOR)

-- Check if the library is already loaded
if not LibEasyMenu then
	return
end -- No upgrade needed

-- Initialize the dropdown menu items
function LibEasyMenu.Initialize(frame, level, menuList)
	-- Iterate through the menu items
	for index, menuItem in ipairs(menuList) do
		-- Assign an index to the menu item
		menuItem.index = index

		-- Add the menu item to the dropdown
		UIDropDownMenu_AddButton(menuItem, level)
	end
end

-- Create a dropdown menu
function LibEasyMenu.Create(menuList, menuFrame, anchor, x, y, displayMode, autoHideDelay)
	-- Set default values for optional parameters
	displayMode = displayMode or "MENU"
	menuFrame = menuFrame or CreateFrame("Frame")

	-- Set the display mode of the menu frame
	menuFrame.displayMode = displayMode

	-- Initialize the dropdown menu
	UIDropDownMenu_Initialize(menuFrame, LibEasyMenu.Initialize, displayMode, nil, menuList)

	-- Show the dropdown menu
	ToggleDropDownMenu(1, nil, menuFrame, anchor, x, y, menuList, nil, autoHideDelay)
end

-- Return the library
return LibEasyMenu
