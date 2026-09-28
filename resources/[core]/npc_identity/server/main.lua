local NPCIdentities = {}
local NPCMemory = {}
local NPCFlags = {}

local function createIdentity(npcId, data)
  local identity = {
    id = npcId,
    firstName = data.firstName or 'Matti',
    lastName = data.lastName or 'Virtanen',
    fullName = (data.firstName or 'Matti') .. ' ' .. (data.lastName or 'Virtanen'),
    age = data.age or 32,
    gender = data.gender or 'male',
    job = data.job or Config.defaultJob,
    district = data.district or Config.defaultDistrict,
    home = data.home or Config.defaultHome,
    work = data.work or Config.defaultWork,
    state = data.state or Config.defaultState,
    mood = data.mood or Config.defaultMood,
    phone = data.phone or Config.defaultPhone,
    criminalRecord = data.criminalRecord or {},
    vehicles = data.vehicles or {},
    relationships = data.relationships or {},
    memory = data.memory or {},
    createdAt = os.time()
  }

  NPCIdentities[npcId] = identity
  NPCMemory[npcId] = identity.memory
  NPCFlags[npcId] = {
    witness = false,
    policeAware = false,
    wantsToFlee = false,
    isArrested = false
  }

  if Config.debug then
    print(('[npc_identity] Registered identity for %s (%s)'):format(identity.fullName, identity.job))
  end

  TriggerEvent('npc_core:server:updateNpcState', npcId, identity.state)

  return identity
end

local function getIdentity(npcId)
  return NPCIdentities[npcId]
end

local function setState(npcId, state)
  if not NPCIdentities[npcId] then
    return false
  end

  NPCIdentities[npcId].state = state
  TriggerEvent('npc_core:server:updateNpcState', npcId, state)

  if Config.debug then
    print(('[npc_identity] %s changed state to %s'):format(npcId, state))
  end

  return true
end

local function setMood(npcId, mood)
  if not NPCIdentities[npcId] then
    return false
  end

  NPCIdentities[npcId].mood = mood
  return true
end

local function addMemory(npcId, key, value)
  if not NPCMemory[npcId] then
    NPCMemory[npcId] = {}
  end

  NPCMemory[npcId][key] = value
  NPCIdentities[npcId].memory = NPCMemory[npcId]
  return true
end

local function toggleWitness(npcId, bool)
  if not NPCFlags[npcId] then
    NPCFlags[npcId] = {}
  end

  NPCFlags[npcId].witness = bool
  return true
end

local function getAllIdentities()
  local list = {}
  for _, owner in pairs(NPCIdentities) do
    table.insert(list, owner)
  end
  return list
end

RegisterNetEvent('npc_identity:server:createIdentity', function(data)
  local src = source
  local npcId = data.id or ('npc_' .. tostring(os.time()))
  local identity = createIdentity(npcId, data)

  if src and src > 0 then
    TriggerClientEvent('npc_identity:client:identityReady', src, identity)
  end
end)

RegisterNetEvent('npc_identity:server:setState', function(npcId, state)
  setState(npcId, state)
end)

RegisterNetEvent('npc_identity:server:setMood', function(npcId, mood)
  setMood(npcId, mood)
end)

RegisterNetEvent('npc_identity:server:addMemory', function(npcId, key, value)
  addMemory(npcId, key, value)
end)

exports('createIdentity', createIdentity)
exports('getIdentity', getIdentity)
exports('setState', setState)
exports('setMood', setMood)
exports('addMemory', addMemory)
exports('toggleWitness', toggleWitness)
exports('getAllIdentities', getAllIdentities)

AddEventHandler('onResourceStart', function(resourceName)
  if resourceName ~= GetCurrentResourceName() then
    return
  end

  createIdentity('npc_001', {
    firstName = 'Matti',
    lastName = 'Virtanen',
    age = 37,
    gender = 'male',
    job = 'mechanic',
    district = 'downtown',
    home = 'palomino_ave_18',
    work = 'garage_downtown',
    state = 'work',
    mood = 'focused',
    phone = '050-440-1802',
    vehicles = { {plate = 'ABC-123', model = 'BMW 320'} },
    memory = { lastKnownCrime = 'none' }
  })

  createIdentity('npc_002', {
    firstName = 'Janne',
    lastName = 'Korhonen',
    age = 29,
    gender = 'male',
    job = 'civilian',
    district = 'downtown',
    home = 'sandy_shores',
    work = 'market',
    state = 'walking',
    mood = 'neutral',
    phone = '050-222-2401',
    memory = { lastKnownCrime = 'none' }
  })

  createIdentity('npc_003', {
    firstName = 'Ari',
    lastName = 'Nieminen',
    age = 41,
    gender = 'male',
    job = 'police',
    district = 'downtown',
    home = 'police_station',
    work = 'patrol',
    state = 'patrol',
    mood = 'alert',
    phone = '050-911-7732',
    memory = { lastKnownCrime = 'traffic_stop' }
  })
end)
