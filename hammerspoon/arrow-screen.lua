

hs.hotkey.bind({"shift", "alt", "cmd"}, "left", function()
    local win = hs.window.frontmostWindow()
    local f = win:frame()
    local max = win:screen():frame()
    local windowEdgeGap = hs.settings.get("windowEdgeGap")

    f.x = max.x + windowEdgeGap
    win:setFrame(f, 0.5)
end)


hs.hotkey.bind({"shift", "alt", "cmd"}, "down", function()
    local win = hs.window.frontmostWindow()
    local f = win:frame()
    local max = win:screen():frame()
    local windowEdgeGap = hs.settings.get("windowEdgeGap")

    f.y = max.y + max.h - f.h - windowEdgeGap

    win:setFrame(f, 0.5)
end)


hs.hotkey.bind({"shift", "alt", "cmd"}, "up", function()
    local win = hs.window.frontmostWindow()
    local f = win:frame()
    local max = win:screen():frame()
    local windowEdgeGap = hs.settings.get("windowEdgeGap")

    f.y = max.y + windowEdgeGap

    win:setFrame(f, 0.5)
end)

hs.hotkey.bind({"shift", "alt", "cmd"}, "right", function()
    local win = hs.window.frontmostWindow()
    local f = win:frame()
    local max = win:screen():frame()
    local windowEdgeGap = hs.settings.get("windowEdgeGap")

    f.x = max.x + max.w - f.w - windowEdgeGap

    win:setFrame(f, 0.5)
end)
