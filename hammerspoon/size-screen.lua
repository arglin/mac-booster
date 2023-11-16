hs.hotkey.bind({"shift", "alt", "cmd"}, "8", function()
    local win = hs.window.frontmostWindow()
    local f = win:frame()
    hs.settings.set("backwardFrame", f)
    hs.settings.set("backwardFullScreenMode", win:isFullScreen())

    local screen = win:screen()
    local max = screen:frame()
    local windowEdgeGap = hs.settings.get("windowEdgeGap")

    local G1f = {}
    local G1winW = math.floor(max.w * 0.8)
    local G1winH = math.floor(max.h * 0.8)
    local G1startX = max.x + (max.w - G1winW) / 2
    local G1startY = max.y + (max.h - G1winH) / 2
    G1f.x = G1startX
    G1f.y = G1startY
    G1f.w = G1winW
    G1f.h = G1winH

        if (win:isFullScreen()) then
            win:setFullScreen(false)
        end
    win:setFrame(G1f, 0)
    win:centerOnScreen(screen)
end)

hs.hotkey.bind({"shift", "alt", "cmd"}, "9", function()
    local win = hs.window.frontmostWindow()
    local f = win:frame()
    hs.settings.set("backwardFrame", f)
    hs.settings.set("backwardFullScreenMode", win:isFullScreen())

    local screen = win:screen()
    local max = screen:frame()
    local windowEdgeGap = hs.settings.get("windowEdgeGap")

    local G2f = {}
    local G2winW = max.w - 2 * windowEdgeGap
    local G2winH = max.h - 2 * windowEdgeGap
    local G2startX = max.x + (max.w - G2winW) / 2
    local G2startY = max.y + (max.h - G2winH) / 2
    G2f.x = G2startX
    G2f.y = G2startY
    G2f.w = G2winW
    G2f.h = G2winH

    if (win:isFullScreen()) then
        win:setFullScreen(false)
    end
    win:setFrame(G2f, 0)
    win:centerOnScreen(screen)
end)

hs.hotkey.bind({"shift", "alt", "cmd"}, "s", function()
    local win = hs.window.frontmostWindow()
    local f = win:frame()
    hs.settings.set("backwardFrame", f)
    hs.settings.set("backwardFullScreenMode", win:isFullScreen())

    local screen = win:screen()
    win:centerOnScreen(screen)
end)

hs.hotkey.bind({"shift", "alt", "cmd"}, "-", function()
    local windowEdgeGap = hs.settings.get("windowEdgeGap")
    local win = hs.window.frontmostWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = f.x + 10
    f.y = f.y + 10
    f.w = f.w - 20
    f.h = f.h - 20

        if (win:isFullScreen()) then
            win:setFullScreen(false)
        end
    win:setFrame(f, 0.2)
end)

hs.hotkey.bind({"shift", "alt", "cmd"}, "=", function()
    local windowEdgeGap = hs.settings.get("windowEdgeGap")
    local win = hs.window.frontmostWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = (f.x - 10 - max.x) > windowEdgeGap and (f.x - 10) or (windowEdgeGap + max.x)
    f.y = (f.y - 10 - max.y) > windowEdgeGap and (f.y - 10) or (windowEdgeGap + max.y)
    f.w = f.w + 20
    f.h = f.h + 20

        if (win:isFullScreen()) then
            win:setFullScreen(false)
        end
        win:setFrame(f, 0.2)
end)

hs.hotkey.bind({"shift", "alt", "cmd"}, "0", function()

    local backwardFrame = hs.settings.get("backwardFrame")
    local backwardFullScreenMode = hs.settings.get("backwardFullScreenMode")
    local win = hs.window.frontmostWindow()
    local f = win:frame()
    hs.settings.set("backwardFrame", f)
    hs.settings.set("backwardFullScreenMode", win:isFullScreen())

    if (backwardFullScreenMode) then
        win:setFullScreen(true)
        return
    end

    f.x = backwardFrame._x
    f.y = backwardFrame._y
    f.w = backwardFrame._w
    f.h = backwardFrame._h

    win:setFullScreen(false)
    win:setFrame(f)
end)
