-- Dispatch UI client-side handler
local DispatchOpen = false

local function toggleDispatchUI()
  DispatchOpen = not DispatchOpen

  if DispatchOpen then
    SendNUIMessage({ type = 'show' })
    SetNuiFocus(true, true)
  else
    SendNUIMessage({ type = 'hide' })
    SetNuiFocus(false, false)
  end
end

RegisterCommand('dispatch', function()
  toggleDispatchUI()
end, false)

RegisterCommand('closedispatch', function()
  DispatchOpen = false
  SendNUIMessage({ type = 'hide' })
  SetNuiFocus(false, false)
end, false)

RegisterNetEvent('dispatch_ui:client:loadCalls', function(calls)
  SendNUIMessage({
    type = 'loadCalls',
    data = calls
  })
end)

RegisterNetEvent('dispatch_ui:client:updateCall', function(call)
  SendNUIMessage({
    type = 'addCall',
    data = call
  })
end)

RegisterNetEvent('dispatch_ui:client:callAccepted', function(callId)
  print('[dispatch_ui] Call ' .. callId .. ' accepted')
end)

RegisterNetEvent('dispatch_ui:client:statusUpdated', function(unitId, status)
  print('[dispatch_ui] Unit ' .. unitId .. ' status: ' .. status)
end)

-- Key listener for opening dispatch (default: F6)
CreateThread(function()
  while true do
    Wait(0)

    if IsControlJustReleased(0, 167) then -- F6 key
      toggleDispatchUI()
    end
  end
end)
