
--[[
-- Create a window filter to track active windows
windowFilter = hs.window.filter.new()

-- Callback function to move cursor to top center of the active window

local function moveCursorToTopCenter()
    local win = hs.window.focusedWindow()
    local win_screen = win:screen()

    local win_frame = win:frame()
    local win_screen_frame = win_screen:frame()

    local cursor_position = hs.mouse.getRelativePosition()
    local cursor_screen_frame = hs.mouse.getCurrentScreen():frame()
    local cursor_global_X = cursor_screen_frame.x + cursor_position.x
    local cursor_global_Y = cursor_screen_frame.y + cursor_position.y

    -- Only move cursor if it's not within the window range
    if cursor_global_X < win_frame.x or cursor_global_X > win_frame.x + win_frame.w or
       cursor_global_Y < win_frame.y or cursor_global_Y > win_frame.y + win_frame.h then

        local cursor_target_relative_X = win_frame.x + win_frame.w / 2 - win_screen_frame.x
        local cursor_target_relative_Y = win_frame.y + win_frame.h /2  - win_screen_frame.y
        hs.mouse.setRelativePosition({ x = cursor_target_relative_X, y = cursor_target_relative_Y }, win_screen)
    end
end
-- Watch for active window changes
windowFilter:subscribe(hs.window.filter.windowFocused, moveCursorToTopCenter)
]]


-- Get the screen dimensions
screenFrame = hs.screen.mainScreen():frame()
screenWidth = screenFrame.w
screenHeight = screenFrame.h

-- Calculate the center coordinates
centerX = screenWidth / 2
centerY = screenHeight / 2

-- Create a new canvas and set its properties
canvas = hs.canvas.new({x = 0, y = 0, w = screenWidth, h = screenHeight})
canvas:level("overlay")
canvas:behavior("canJoinAllSpaces")
canvas:show()

-- Draw the center line
canvas:line({x = centerX, y = 0}, {x = centerX, y = screenHeight})
canvas:line({x = 0, y = centerY}, {x = screenWidth, y = centerY})


