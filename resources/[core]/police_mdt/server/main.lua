local MDTCache = {}

local function searchPerson(query)
  if not query or query == '' then
    return {}
  end

  local identities = {}
  local ok = pcall(function()
    identities = exports['npc_identity']:getAllIdentities()
  end)

  if not ok then
    return {}
  end

  local results = {}
  local queryLower = string.lower(query)

  for _, identity in ipairs(identities) do
    local nameLower = string.lower(identity.fullName)

    if string.find(nameLower, queryLower) then
      local record = {
        id = identity.id,
        firstName = identity.firstName,
        lastName = identity.lastName,
        fullName = identity.fullName,
        age = identity.age,
        gender = identity.gender,
        job = identity.job,
        district = identity.district,
        home = identity.home,
        phone = identity.phone,
        vehicles = identity.vehicles or {},
        criminalRecord = identity.criminalRecord or {},
        lastSeen = identity.state or 'unknown',
        mood = identity.mood or 'neutral'
      }
      table.insert(results, record)
    end
  end

  return results
end

local function searchVehicle(plate)
  if not plate or plate == '' then
    return {}
  end

  local identities = {}
  local ok = pcall(function()
    identities = exports['npc_identity']:getAllIdentities()
  end)

  if not ok then
    return {}
  end

  local results = {}
  local plateLower = string.lower(plate)

  for _, identity in ipairs(identities) do
    if identity.vehicles then
      for _, vehicle in ipairs(identity.vehicles) do
        local vehiclePlate = vehicle.plate or ''
        if string.find(string.lower(vehiclePlate), plateLower) then
          local record = {
            plate = vehicle.plate,
            model = vehicle.model,
            color = vehicle.color or 'unknown',
            owner = identity.fullName,
            ownerId = identity.id,
            ownerJob = identity.job,
            stolen = vehicle.stolen or false,
            registered = vehicle.registered or true,
            insurance = vehicle.insurance or true,
            lastSpotted = vehicle.lastSpotted or 'never'
          }
          table.insert(results, record)
        end
      end
    end
  end

  return results
end

local function searchByPlate(plate)
  return searchVehicle(plate)
end

local function getPersonRecord(personId)
  local identities = {}
  local ok = pcall(function()
    identities = exports['npc_identity']:getAllIdentities()
  end)

  if not ok then
    return nil
  end

  for _, identity in ipairs(identities) do
    if identity.id == personId then
      return {
        id = identity.id,
        firstName = identity.firstName,
        lastName = identity.lastName,
        fullName = identity.fullName,
        age = identity.age,
        dob = identity.dob or ('14.05.' .. (2026 - identity.age)),
        gender = identity.gender,
        job = identity.job,
        district = identity.district,
        address = identity.home,
        phone = identity.phone,
        licenseStatus = identity.licenseStatus or 'valid',
        licenseExpires = identity.licenseExpires or '2027-12-31',
        vehicles = identity.vehicles or {},
        criminalRecord = identity.criminalRecord or {},
        lastSeen = identity.state or 'unknown',
        mood = identity.mood or 'neutral',
        memory = identity.memory or {},
        warrants = identity.warrants or {}
      }
    end
  end

  return nil
end

local function getCriminalHistory(personId)
  local identities = {}
  local ok = pcall(function()
    identities = exports['npc_identity']:getAllIdentities()
  end)

  if not ok then
    return {}
  end

  for _, identity in ipairs(identities) do
    if identity.id == personId then
      return identity.criminalRecord or {}
    end
  end

  return {}
end

local function getWarrants(personId)
  local identities = {}
  local ok = pcall(function()
    identities = exports['npc_identity']:getAllIdentities()
  end)

  if not ok then
    return {}
  end

  for _, identity in ipairs(identities) do
    if identity.id == personId then
      return identity.warrants or {}
    end
  end

  return {}
end

local function addCriminalRecord(personId, crime, description)
  local ok = pcall(function()
    local memory = {
      crime = crime,
      description = description,
      date = os.date('%Y-%m-%d %H:%M:%S'),
      status = 'recorded'
    }

    exports['npc_identity']:addMemory(personId, 'criminalRecord_' .. tostring(os.time()), memory)
  end)

  if Config.debug then
    print(('[police_mdt] Added criminal record for %s: %s'):format(personId, crime))
  end

  return ok
end

RegisterNetEvent('police_mdt:server:searchPerson', function(query)
  local src = source
  Wait(Config.searchDelay)

  local results = searchPerson(query)
  TriggerClientEvent('police_mdt:client:personSearchResults', src, results)
end)

RegisterNetEvent('police_mdt:server:searchVehicle', function(plate)
  local src = source
  Wait(Config.searchDelay)

  local results = searchVehicle(plate)
  TriggerClientEvent('police_mdt:client:vehicleSearchResults', src, results)
end)

RegisterNetEvent('police_mdt:server:getPersonRecord', function(personId)
  local src = source
  local record = getPersonRecord(personId)
  TriggerClientEvent('police_mdt:client:receivePersonRecord', src, record)
end)

RegisterNetEvent('police_mdt:server:getCriminalHistory', function(personId)
  local src = source
  local history = getCriminalHistory(personId)
  TriggerClientEvent('police_mdt:client:receiveCriminalHistory', src, history)
end)

RegisterNetEvent('police_mdt:server:getWarrants', function(personId)
  local src = source
  local warrants = getWarrants(personId)
  TriggerClientEvent('police_mdt:client:receiveWarrants', src, warrants)
end)

RegisterNetEvent('police_mdt:server:addCriminalRecord', function(personId, crime, description)
  addCriminalRecord(personId, crime, description)
end)

exports('searchPerson', searchPerson)
exports('searchVehicle', searchVehicle)
exports('getPersonRecord', getPersonRecord)
exports('getCriminalHistory', getCriminalHistory)
exports('getWarrants', getWarrants)
exports('addCriminalRecord', addCriminalRecord)
