

hs.hotkey.bind({"shift", "alt", "cmd"}, "F", function()
    local win = hs.window.frontmostWindow()
    local f = win:frame()
    hs.settings.set("backwardFrame", f)
    hs.settings.set("backwardFullScreenMode", win:isFullScreen())

    if (win:isFullScreen()) then
        win:setFullScreen(false)
    else
        win:setFullScreen(true)
    end
end)


hs.hotkey.bind({"shift", "alt", "cmd"}, "Q", function()
    spoon.AClock:toggleShowPersistent()
end)
