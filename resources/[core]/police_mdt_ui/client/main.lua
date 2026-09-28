-- Police MDT UI Client-side handler
local MDTOpen = false

local function toggleMDT()
  MDTOpen = not MDTOpen

  if MDTOpen then
    SendNUIMessage({ type = 'show' })
    SetNuiFocus(true, true)
  else
    SendNUIMessage({ type = 'hide' })
    SetNuiFocus(false, false)
  end
end

RegisterCommand('mdt', function()
  toggleMDT()
end, false)

RegisterCommand('closemdt', function()
  MDTOpen = false
  SendNUIMessage({ type = 'hide' })
  SetNuiFocus(false, false)
end, false)

-- Key listener for opening MDT (default: F7)
CreateThread(function()
  while true do
    Wait(0)

    if IsControlJustReleased(0, 168) then -- F7 key
      toggleMDT()
    end
  end
end)
