local spawnedPeds = {}

local function loadModel(model)
  if not IsModelValid(model) then
    return false
  end

  RequestModel(model)

  local timeout = 0
  while not HasModelLoaded(model) and timeout < 100 do
    Wait(50)
    timeout = timeout + 1
  end

  return HasModelLoaded(model)
end

local function spawnNpc(npc)
  if not npc or not npc.coords then
    return nil
  end

  local model = npc.model or Config.defaultModel
  local hash = GetHashKey(model)

  if not loadModel(hash) then
    print(('[npc_core] Failed to load model: %s'):format(model))
    return nil
  end

  local ped = CreatePed(4, hash, npc.coords.x, npc.coords.y, npc.coords.z, 0.0, false, false)

  if not ped or ped == 0 then
    print(('[npc_core] Failed to create NPC: %s'):format(npc.name))
    return nil
  end

  SetEntityHeading(ped, 0.0)
  FreezeEntityPosition(ped, true)
  SetBlockingOfNonTemporaryEvents(ped, true)
  SetPedCanRagdoll(ped, false)

  spawnedPeds[npc.id] = ped

  return ped
end

RegisterNetEvent('npc_core:client:spawnNpc', function(npc)
  spawnNpc(npc)
end)

RegisterNetEvent('npc_core:client:requestSpawn', function()
  local list = exports['npc_core']:getNpcList()

  for _, npc in ipairs(list) do
    spawnNpc(npc)
  end
end)

CreateThread(function()
  Wait(2000)

  TriggerServerEvent('npc_core:server:requestNpcList')
end)

RegisterNetEvent('npc_core:client:receiveNpcList', function(npcList)
  for _, npc in ipairs(npcList) do
    spawnNpc(npc)
  end
end)
