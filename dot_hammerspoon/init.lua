local navMode = hs.hotkey.modal.new()
local holdDelaySeconds = 0.06
local capsLockKeyCode = hs.keycodes.map.capslock or 57
local capsLockTimer = nil
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
navMode:bind({}, "f", sendNavigationKey("escape"))

local capsLockLayer = hs.eventtap.new({ hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp }, function(event)
  if event:getKeyCode() ~= capsLockKeyCode then
    return false
  end

  local eventType = event:getType()

  if eventType == hs.eventtap.event.types.keyDown then
    navModeActive = false

    if capsLockTimer then
      capsLockTimer:stop()
    end

    capsLockTimer = hs.timer.doAfter(holdDelaySeconds, function()
      navModeActive = true
      navMode:enter()
    end)

    return true
  end

  if capsLockTimer then
    capsLockTimer:stop()
    capsLockTimer = nil
  end

  if navModeActive then
    navMode:exit()
  end

  navModeActive = false
  return true
end)

capsLockLayer:start()
