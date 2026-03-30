local navMode = hs.hotkey.modal.new()
local usedAsNavigation = false

local function sendNavigationKey(key)
  return function()
    usedAsNavigation = true
    hs.eventtap.keyStroke({}, key, 0)
  end
end

navMode:bind({}, "h", sendNavigationKey("left"))
navMode:bind({}, "j", sendNavigationKey("down"))
navMode:bind({}, "k", sendNavigationKey("up"))
navMode:bind({}, "l", sendNavigationKey("right"))
navMode:bind({}, "i", sendNavigationKey("home"))
navMode:bind({}, "o", sendNavigationKey("end"))

hs.hotkey.bind({}, "escape", function()
  usedAsNavigation = false
  navMode:enter()
end, function()
  navMode:exit()

  if not usedAsNavigation then
    hs.eventtap.keyStroke({}, "escape", 0)
  end
end)
