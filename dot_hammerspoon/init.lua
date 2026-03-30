local navMode = hs.hotkey.modal.new()
local holdDelaySeconds = 0.15
local escapeTimer = nil
local navModeActive = false

local function sendNavigationKey(key)
  return function()
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
  navModeActive = false

  escapeTimer = hs.timer.doAfter(holdDelaySeconds, function()
    navModeActive = true
    navMode:enter()
  end)
end, function()
  if escapeTimer then
    escapeTimer:stop()
    escapeTimer = nil
  end

  if navModeActive then
    navMode:exit()
  else
    hs.eventtap.keyStroke({}, "escape", 0)
  end

  navModeActive = false
end)
