local ActiveCrimeEvents = {}

local function getCurrentTime()
  return os.date('%Y-%m-%d %H:%M:%S')
end

local function randomChoice(list)
  if not list or #list == 0 then
    return nil
  end

  return list[math.random(1, #list)]
end

local function getNpcIdentities()
  local ok, result = pcall(function()
    return exports['npc_identity']:getAllIdentities()
  end)

  if not ok or not result then
    return {}
  end

  return result
end

local function setNpcMood(npcId, mood)
  if not npcId then
    return
  end

  local ok = pcall(function()
    exports['npc_identity']:setMood(npcId, mood)
  end)

  if not ok and Config.debug then
    print(('[npc_crime] Failed to set mood for %s'):format(npcId))
  end
end

local function addNpcMemory(npcId, key, value)
  if not npcId then
    return
  end

  local ok = pcall(function()
    exports['npc_identity']:addMemory(npcId, key, value)
  end)

  if not ok and Config.debug then
    print(('[npc_crime] Failed to store memory for %s'):format(npcId))
  end
end

local function createCrimeEvent(data)
  local suspect = data.suspect
  local location = data.location or randomChoice(Config.locations)
  local crimeType = data.type or randomChoice(Config.crimes)

  if not suspect then
    return nil
  end

  local event = {
    id = data.id or ('crime_' .. tostring(os.time()) .. '_' .. tostring(math.random(1000, 9999))),
    type = crimeType,
    severity = data.severity or 'medium',
    location = location,
    suspectId = suspect.id,
    suspectName = suspect.fullName,
    district = suspect.district or 'downtown',
    vehiclePlate = data.vehiclePlate or 'ABC-123',
    witnessIds = data.witnessIds or {},
    status = 'active',
    createdAt = getCurrentTime(),
    description = data.description or 'Suspicious activity observed in the area.'
  }

  ActiveCrimeEvents[event.id] = event

  if Config.debug then
    print(('[npc_crime] Created crime event %s for %s at %s'):format(event.id, suspect.fullName, location))
  end

  pcall(function()
    TriggerEvent('npc_identity:server:setState', suspect.id, 'crime')
    setNpcMood(suspect.id, 'agitated')
    addNpcMemory(suspect.id, 'latestCrime', event.id)
  end)

  for _, witness in ipairs(event.witnessIds) do
    if witness and witness.id then
      pcall(function()
        TriggerEvent('npc_identity:server:setState', witness.id, 'witness')
        TriggerEvent('npc_identity:server:setMood', witness.id, 'scared')
        exports['npc_identity']:toggleWitness(witness.id, true)
        addNpcMemory(witness.id, 'lastSeenCrime', event.id)
      end)
    end
  end

  TriggerEvent('npc_dispatch:server:createCall', {
    callId = event.id,
    type = event.type,
    severity = event.severity,
    location = event.location,
    suspectId = event.suspectId,
    suspectName = event.suspectName,
    witnessIds = event.witnessIds,
    vehiclePlate = event.vehiclePlate,
    details = event.description,
    createdAt = event.createdAt,
    district = event.district,
    status = 'pending'
  })

  return event
end

local function getWitnessesForSuspect(suspect)
  local identities = getNpcIdentities()
  local witnessList = {}

  for _, identity in ipairs(identities) do
    if identity.id ~= suspect.id and identity.job ~= 'police' then
      table.insert(witnessList, identity)
    end
  end

  table.sort(witnessList, function(a, b)
    return a.fullName < b.fullName
  end)

  local selected = {}
  local maxWitnesses = math.min(Config.witnessMax, #witnessList)
  local count = 0

  while count < maxWitnesses do
    local witness = randomChoice(witnessList)
    if witness and not selected[witness.id] then
      selected[witness.id] = witness
      count = count + 1
    else
      break
    end
  end

  local result = {}
  for _, witness in pairs(selected) do
    table.insert(result, witness)
  end

  return result
end

local function generateRandomCrime()
  local identities = getNpcIdentities()
  if #identities == 0 then
    return nil
  end

  local suspect = nil
  local filtered = {}

  for _, identity in ipairs(identities) do
    if identity.job ~= 'police' and identity.state ~= 'arrested' then
      table.insert(filtered, identity)
    end
  end

  if #filtered == 0 then
    return nil
  end

  suspect = randomChoice(filtered)
  local witnesses = getWitnessesForSuspect(suspect)
  local vehiclePlate = 'ABC-' .. tostring(math.random(100, 999))

  return createCrimeEvent({
    suspect = suspect,
    type = randomChoice(Config.crimes),
    severity = math.random(1, 100) > 70 and 'high' or 'medium',
    location = randomChoice(Config.locations),
    witnessIds = witnesses,
    vehiclePlate = vehiclePlate,
    description = ('Suspicious behavior observed near %s.'):format(randomChoice(Config.locations))
  })
end

local function getActiveCrimes()
  local list = {}
  for _, event in pairs(ActiveCrimeEvents) do
    table.insert(list, event)
  end
  return list
end

RegisterNetEvent('npc_crime:server:generateCrime', function(data)
  local npcId = data and data.suspectId
  local suspect = nil

  if npcId then
    local identities = getNpcIdentities()
    for _, identity in ipairs(identities) do
      if identity.id == npcId then
        suspect = identity
        break
      end
    end
  end

  if not suspect then
    suspect = randomChoice(getNpcIdentities())
  end

  local event = createCrimeEvent({
    suspect = suspect,
    type = data and data.type or randomChoice(Config.crimes),
    severity = data and data.severity or 'medium',
    location = data and data.location or randomChoice(Config.locations),
    witnessIds = getWitnessesForSuspect(suspect),
    vehiclePlate = data and data.vehiclePlate or ('ABC-' .. tostring(math.random(100, 999)))
  })

  TriggerClientEvent('npc_crime:client:crimeCreated', source, event)
end)

RegisterNetEvent('npc_crime:server:requestActiveCrimes', function()
  local src = source
  TriggerClientEvent('npc_crime:client:receiveActiveCrimes', src, getActiveCrimes())
end)

RegisterNetEvent('npc_crime:server:resolveCrime', function(crimeId)
  if ActiveCrimeEvents[crimeId] then
    ActiveCrimeEvents[crimeId].status = 'resolved'
  end
end)

CreateThread(function()
  while true do
    Wait(Config.crimeLoopInterval * 1000)

    local roll = math.random()
    if roll <= Config.randomCrimeChance then
      generateRandomCrime()
    end
  end
end)

exports('createCrimeEvent', createCrimeEvent)
exports('generateRandomCrime', generateRandomCrime)
exports('getActiveCrimes', getActiveCrimes)
