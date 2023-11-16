

hs.hotkey.bind({"shift", "alt", "cmd"}, "1", function()
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
    local twoThirdW = math.floor(2 * max.w / 3 - 2 * windowEdgeGap)
    local H = max.h - 2 * windowEdgeGap

    if ((f.x == startX) and (f.y == startY) and (f.w == thirdW) and (f.h == H)) then
        f.x = startX
        f.y = startY
        f.w = twoThirdW
        f.h = H
    elseif ((f.x == startX) and (f.y == startY) and (f.w == halfW) and (f.h == H)) then
        f.x = startX
        f.y = startY
        f.w = thirdW
        f.h = H
    else
        f.x = startX
        f.y = startY
        f.w = halfW
        f.h = H
    end
    if (win:isFullScreen()) then
       win:setFullScreen(false)
    end
    win:setFrame(f)
end)

hs.hotkey.bind({"shift", "alt", "cmd"}, "2", function()
    local win = hs.window.frontmostWindow()
    local f = win:frame()
    hs.settings.set("backwardFrame", f)
    hs.settings.set("backwardFullScreenMode", win:isFullScreen())

    local screen = win:screen()
    local max = screen:frame()
    local windowEdgeGap = hs.settings.get("windowEdgeGap")

    local endX = max.x + max.w - windowEdgeGap
    local endY = max.y + windowEdgeGap
    local halfW = math.floor(max.w / 2 - 2 * windowEdgeGap)
    local thirdW = math.floor(max.w / 3 - 2 * windowEdgeGap)
    local twoThirdW = math.floor(2 * max.w / 3 - 2 * windowEdgeGap)
    local H = max.h - 2 * windowEdgeGap

    if ((f.x == endX - thirdW) and (f.y == endY) and (f.w == thirdW) and (f.h == H)) then
        f.x = endX - twoThirdW
        f.y = endY
        f.w = twoThirdW
        f.h = H
    elseif ((f.x == endX - halfW) and (f.y == endY) and (f.w == halfW) and (f.h == H)) then
        f.x = endX - thirdW
        f.y = endY
        f.w = thirdW
        f.h = H
    else
        f.x = endX - halfW
        f.y = endY
        f.w = halfW
        f.h = H
    end
    if (win:isFullScreen()) then
        win:setFullScreen(false)
    end
    win:setFrame(f)
end)
