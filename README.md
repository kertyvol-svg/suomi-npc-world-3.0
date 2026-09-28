local ActiveCalls = {}

local function getCurrentTime()
  return os.date('%Y-%m-%d %H:%M:%S')
end

local function createCall(data)
  local call = {
    id = data.callId or ('call_' .. tostring(os.time()) .. '_' .. tostring(math.random(100, 999))),
    type = data.type or 'disturbance',
    severity = data.severity or 'medium',
    location = data.location or 'Downtown',
    suspectId = data.suspectId or nil,
    suspectName = data.suspectName or 'Unknown suspect',
    witnessIds = data.witnessIds or {},
    vehiclePlate = data.vehiclePlate or 'UNKNOWN',
    details = data.details or 'Unknown situation.',
    district = data.district or 'downtown',
    createdAt = data.createdAt or getCurrentTime(),
    status = data.status or 'pending'
  }

  ActiveCalls[call.id] = call

  if Config.debug then
    print(('[npc_dispatch] New call created: %s | %s | %s'):format(call.id, call.type, call.location))
  end

  TriggerClientEvent('npc_dispatch:client:callUpdated', -1, call)

  return call
end

local function getActiveCalls()
  local list = {}
  for _, call in pairs(ActiveCalls) do
    table.insert(list, call)
  end
  return list
end

local function acceptCall(callId, unitId)
  if not ActiveCalls[callId] then
    return nil
  end

  ActiveCalls[callId].status = 'accepted'
  ActiveCalls[callId].unitId = unitId or 'unit_unknown'

  TriggerClientEvent('npc_dispatch:client:callUpdated', -1, ActiveCalls[callId])

  return ActiveCalls[callId]
end

RegisterNetEvent('npc_dispatch:server:createCall', function(data)
  createCall(data)
end)

RegisterNetEvent('npc_dispatch:server:acceptCall', function(callId, unitId)
  acceptCall(callId, unitId)
end)

RegisterNetEvent('npc_dispatch:server:requestCalls', function()
  local src = source
  TriggerClientEvent('npc_dispatch:client:receiveCalls', src, getActiveCalls())
end)

exports('createCall', createCall)
exports('acceptCall', acceptCall)
exports('getActiveCalls', getActiveCalls)

CreateThread(function()
  Wait(1500)

  TriggerEvent('npc_dispatch:server:createCall', {
    callId = 'dispatch_demo_call_001',
    type = 'armed_robbery',
    severity = 'high',
    location = 'Vespucci Blvd 24',
    suspectName = 'Matti Virtanen',
    witnessIds = {},
    vehiclePlate = 'ABC-123',
    details = 'Witness reported an armed suspect fleeing from the scene.',
    district = 'downtown',
    status = 'pending'
  })
end)
