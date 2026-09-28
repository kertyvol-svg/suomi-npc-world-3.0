local Npcs = {}

local function registerNpc(data)
  local npc = {
    id = data.id or ('npc_' .. tostring(#Npcs + 1)),
    name = data.name or 'Matti Virtanen',
    model = data.model or Config.defaultModel,
    coords = data.coords or vector3(0.0, 0.0, 0.0),
    state = data.state or Config.defaultState,
    job = data.job or Config.defaultJob,
    district = data.district or Config.defaultDistrict,
    crimeLevel = data.crimeLevel or 0,
    createdAt = os.time()
  }

  Npcs[npc.id] = npc

  if Config.debug then
    print(('[npc_core] Registered NPC: %s | state=%s | job=%s | district=%s'):format(
      npc.name,
      npc.state,
      npc.job,
      npc.district
    ))
  end

  return npc
end

local function getNpcById(id)
  return Npcs[id]
end

local function spawnNpcForPlayer(src, npc)
  TriggerClientEvent('npc_core:client:spawnNpc', src, npc)
end

RegisterNetEvent('npc_core:server:createNpc', function(data)
  local src = source
  local npc = registerNpc(data)

  if src and src > 0 then
    spawnNpcForPlayer(src, npc)
  end
end)

RegisterNetEvent('npc_core:server:requestNpcList', function()
  local src = source
  local npcList = {}

  for _, npc in pairs(Npcs) do
    table.insert(npcList, npc)
  end

  TriggerClientEvent('npc_core:client:receiveNpcList', src, npcList)
end)

RegisterNetEvent('npc_core:server:updateNpcState', function(id, state)
  if not Npcs[id] then
    return
  end

  Npcs[id].state = state

  if Config.debug then
    print(('[npc_core] Updated NPC state: %s -> %s'):format(id, state))
  end
end)

exports('registerNpc', registerNpc)
exports('getNpcById', getNpcById)
exports('getNpcList', function()
  local list = {}
  for _, npc in pairs(Npcs) do
    table.insert(list, npc)
  end
  return list
end)

AddEventHandler('onResourceStart', function(resourceName)
  if resourceName ~= GetCurrentResourceName() then
    return
  end

  local initialNpcs = {
    {
      id = 'npc_001',
      name = 'Matti Virtanen',
      model = 'mp_m_freemode_01',
      coords = vector3(123.0, -1280.0, 29.0),
      state = 'idle',
      job = 'mechanic',
      district = 'downtown'
    },
    {
      id = 'npc_002',
      name = 'Janne Korhonen',
      model = 'mp_f_freemode_01',
      coords = vector3(143.0, -1270.0, 29.0),
      state = 'walking',
      job = 'civilian',
      district = 'downtown'
    },
    {
      id = 'npc_003',
      name = 'Ari Nieminen',
      model = 's_m_y_cop_01',
      coords = vector3(170.0, -1260.0, 29.0),
      state = 'patrol',
      job = 'police',
      district = 'downtown'
    }
  }

  for _, npcData in ipairs(initialNpcs) do
    registerNpc(npcData)
  end
end)
