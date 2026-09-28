-- Dispatch UI server-side handler
local DispatchCalls = {}

local function sendCallToPlayer(src, call)
  TriggerClientEvent('dispatch_ui:client:updateCall', src, call)
end

local function broadcastCall(call)
  TriggerClientEvent('dispatch_ui:client:updateCall', -1, call)
end

RegisterNetEvent('dispatch_ui:server:getActiveCalls', function()
  local src = source
  local activeCalls = exports['npc_dispatch']:getActiveCalls()

  TriggerClientEvent('dispatch_ui:client:loadCalls', src, activeCalls)
end)

RegisterNetEvent('dispatch_ui:server:acceptCall', function(callId, unitId)
  local src = source
  exports['npc_dispatch']:acceptCall(callId, unitId)
  TriggerClientEvent('dispatch_ui:client:callAccepted', src, callId)
end)

RegisterNetEvent('dispatch_ui:server:setUnitStatus', function(unitId, status)
  local src = source
  TriggerClientEvent('dispatch_ui:client:statusUpdated', src, unitId, status)
end)

AddEventHandler('onResourceStart', function(resourceName)
  if resourceName ~= GetCurrentResourceName() then
    return
  end

  print('[dispatch_ui] Dispatch UI system initialized')
end)
