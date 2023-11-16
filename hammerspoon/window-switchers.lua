hs.spaces.setDefaultMCwaitTime(1)

hs.hotkey.bind({"shift", "alt", "cmd"}, "d", function()
   hs.spaces.gotoSpace(1)
end)
--[[
-- Create a new eventtap object for tracking trackpad events
local trackpadEventTap = hs.eventtap.new({ hs.eventtap.event.types.gesture }, function(event)
    print(event:touches())
    -- Check if the event is a trackpad touch event
    if event:getProperty(hs.eventtap.event.properties.eventSourceUserData) == "com.apple.driver.AppleBluetoothMultitouch.trackpad" then
        -- Handle the trackpad touch event
        -- You can access the position and other properties of the event using event:location(), event:getProperty(), etc.
        -- Add your custom logic here
        print("Trackpad touch event detected")
    end
end)

-- Start the eventtap
trackpadEventTap:start()


eventtap = require "hs.eventtap"

-- Function to handle event
function handleEvent(event)
    if event:getType() == eventtap.event.types["gesture"] then
        local touches = event:getTouches()

        if #touches == 2 then
             if touches[1].normalizedPosition.x > 0.2 and touches[2].normalizedPosition.x < 0.8 then
            -- Two fingers touched
                print("Two fingers touched!")
                print(hs.inspect(touches[1]))
             end
            -- Do something here
        end
    end
end

-- Create an event tap for gesture events
gestureTap = eventtap.new({ eventtap.event.types["gesture"] }, handleEvent)

-- Start the event tap
gestureTap:start()
]]
