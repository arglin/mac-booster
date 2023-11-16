

hs.hotkey.bind({"shift", "alt", "cmd"}, "3", function()
    local win = hs.window.frontmostWindow()
    local f = win:frame()
    local f = win:frame()
    hs.settings.set("backwardFrame", f)
    hs.settings.set("backwardFullScreenMode", win:isFullScreen())

    local screen = win:screen()
    local max = screen:frame()
    local windowEdgeGap = hs.settings.get("windowEdgeGap")

    local startX = max.x + windowEdgeGap
    local startY = max.y + windowEdgeGap
    local halfW = math.floor(max.w / 2 - 2 * windowEdgeGap)
    local thirdW = math.floor(max.w / 3 - 2 * windowEdgeGap)
    local halfH = math.floor(max.h / 2 - 2 * windowEdgeGap)

    if ((f.x == startX) and (f.y == startY) and (f.w == halfW) and (f.h == halfH)) then
        f.x = startX
        f.y = startY
        f.w = thirdW
        f.h = halfH
    else
        f.x = startX
        f.y = startY
        f.w = halfW
        f.h = halfH
    end
    if (win:isFullScreen()) then
        win:setFullScreen(false)
    end
    win:setFrame(f)
end)


hs.hotkey.bind({"shift", "alt", "cmd"}, "4", function()
    local win = hs.window.frontmostWindow()
    local f = win:frame()
    hs.settings.set("backwardFrame", f)
    hs.settings.set("backwardFullScreenMode", win:isFullScreen())

    local screen = win:screen()
    local max = screen:frame()
    local windowEdgeGap = hs.settings.get("windowEdgeGap")

    local startX = max.x + windowEdgeGap
    local startY = max.y + windowEdgeGap
    local halfW = math.floor(max.w / 2 - 2 * windowEdgeGap)
    local thirdW = math.floor(max.w / 3 - 2 * windowEdgeGap)
    local halfH = math.floor(max.h / 2 - 2 * windowEdgeGap)

    if ((f.x == startX + math.floor(max.w / 2)) and (f.y == startY) and (f.w == halfW) and (f.h == halfH)) then
        f.x = startX + math.floor(2 * max.w / 3)
        f.y = startY
        f.w = thirdW
        f.h = halfH
    else
        f.x = startX + math.floor(max.w / 2)
        f.y = startY
        f.w = halfW
        f.h = halfH
    end
        if (win:isFullScreen()) then
            win:setFullScreen(false)
        end
    win:setFrame(f)
end)


hs.hotkey.bind({"shift", "alt", "cmd"}, "5", function()
    local win = hs.window.frontmostWindow()
    local f = win:frame()
    hs.settings.set("backwardFrame", f)
    hs.settings.set("backwardFullScreenMode", win:isFullScreen())
    local screen = win:screen()
    local max = screen:frame()
    local windowEdgeGap = hs.settings.get("windowEdgeGap")

    local startX = max.x + windowEdgeGap
    local startY = max.y + windowEdgeGap + math.floor(max.h / 2)
    local halfW = math.floor(max.w / 2 - 2 * windowEdgeGap)
    local thirdW = math.floor(max.w / 3 - 2 * windowEdgeGap)
    local halfH = math.floor(max.h / 2 - 2 * windowEdgeGap)

    if ((f.x == startX) and (f.y == startY) and (f.w == halfW) and (f.h == halfH)) then
        f.x = startX
        f.y = startY
        f.w = thirdW
        f.h = halfH

    else
        f.x = startX
        f.y = startY
        f.w = halfW
        f.h = halfH
    end
        if (win:isFullScreen()) then
            win:setFullScreen(false)
        end
    win:setFrame(f)
end)

hs.hotkey.bind({"shift", "alt", "cmd"}, "6", function()
    local win = hs.window.frontmostWindow()
    local f = win:frame()
    hs.settings.set("backwardFrame", f)
    hs.settings.set("backwardFullScreenMode", win:isFullScreen())

    local screen = win:screen()
    local max = screen:frame()
    local windowEdgeGap = hs.settings.get("windowEdgeGap")

    local startX = max.x + windowEdgeGap
    local startY = max.y + windowEdgeGap  + math.floor(max.h / 2)
    local halfW = math.floor(max.w / 2 - 2 * windowEdgeGap)
    local thirdW = math.floor(max.w / 3 - 2 * windowEdgeGap)
    local halfH = math.floor(max.h / 2 - 2 * windowEdgeGap)

    if ((f.x == startX + math.floor(max.w / 2)) and (f.y == startY) and (f.w == halfW) and (f.h == halfH)) then
        f.x = startX + math.floor(2 * max.w / 3)
        f.y = startY
        f.w = thirdW
        f.h = halfH
    else
        f.x = startX + math.floor(max.w / 2)
        f.y = startY
        f.w = halfW
        f.h = halfH
    end
        if (win:isFullScreen()) then
            win:setFullScreen(false)
        end
    win:setFrame(f)
end)


hs.hotkey.bind({"shift", "alt", "cmd"}, "7", function()
    local win = hs.window.frontmostWindow()
    local f = win:frame()
    hs.settings.set("backwardFrame", f)
    hs.settings.set("backwardFullScreenMode", win:isFullScreen())

    local screen = win:screen()
    local max = screen:frame()
    local windowEdgeGap = hs.settings.get("windowEdgeGap")

    local startX = max.x + windowEdgeGap
    local startUpY = max.y + windowEdgeGap
    local startDownY = max.y + windowEdgeGap + math.floor(max.h / 2)
    local thirdW = math.floor(max.w / 3 - 2 * windowEdgeGap)
    local W = max.w - 2 * windowEdgeGap
    local halfH = math.floor(max.h / 2 - 2 * windowEdgeGap)

    if ((f.x == startX + math.floor(max.w / 3)) and (f.y == startUpY) and (f.w == thirdW) and (f.h == halfH)) then
        f.x = startX + math.floor(max.w / 3)
        f.y = startDownY
        f.w = thirdW
        f.h = halfH
    else
        f.x = startX + math.floor(max.w / 3)
        f.y = startUpY
        f.w = thirdW
        f.h = halfH
    end
    if (win:isFullScreen()) then
        win:setFullScreen(false)
    end
    win:setFrame(f)
end)
