
hs.hotkey.bind({"shift", "alt", "cmd"}, "[", function()
    local allScreens = hs.screen.allScreens()
    local win = hs.window.frontmostWindow()
    local f = win:frame()
    hs.settings.set("backwardFrame", f)
    local nextScreen = allScreens[1]
    win:moveToScreen(nextScreen, false, true, 0)
end)

hs.hotkey.bind({"shift", "alt", "cmd"}, "]", function()
    local allScreens = hs.screen.allScreens()
    local win = hs.window.frontmostWindow()
    local f = win:frame()
    hs.settings.set("backwardFrame", f)
    local nextScreen = allScreens[2]
    win:moveToScreen(nextScreen, false, true, 0)
end)

hs.hotkey.bind({"shift", "alt", "cmd"}, "\\", function()
    local allScreens = hs.screen.allScreens()
    local win = hs.window.frontmostWindow()
    local f = win:frame()
    hs.settings.set("backwardFrame", f)
    local nextScreen = allScreens[3]
    win:moveToScreen(nextScreen, false, true, 0)
end)

hs.hotkey.bind({"shift", "alt", "cmd"}, "space", function()
    local win = hs.window.frontmostWindow()
    local f = win:frame()
    hs.settings.set("backwardFrame", f)
    local nextScreen = win:screen():next()
    win:moveToScreen(nextScreen, true, false, 0)
end)
