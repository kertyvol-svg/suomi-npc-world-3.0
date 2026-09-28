local Warrants = {}
local BOLOs = {}

local function createWarrant(data)
  local warrant = {
    id = data.id or ('warrant_' .. tostring(os.time()) .. '_' .. tostring(math.random(1000, 9999))),
    personId = data.personId,
    personName = data.personName or 'Unknown',
    reason = data.reason or 'Unknown',
    issuedAt = os.date('%Y-%m-%d %H:%M:%S'),
    issuedBy = data.issuedBy or 'Officer',
    status = 'active',
    description = data.description or ''
  }

  Warrants[warrant.id] = warrant

  if Config.debug then
    print(('[warrant_system] Created warrant %s for %s | Reason: %s'):format(warrant.id, warrant.personName, warrant.reason))
  end

  TriggerEvent('npc_identity:server:addMemory', data.personId, 'warrant_' .. warrant.id, warrant)

  return warrant
end

local function createBOLO(data)
  local bolo = {
    id = data.id or ('bolo_' .. tostring(os.time()) .. '_' .. tostring(math.random(1000, 9999))),
    personId = data.personId,
    personName = data.personName or 'Unknown',
    description = data.description or '',
    reason = data.reason or 'Unknown',
    dangerous = data.dangerous or false,
    vehicleInfo = data.vehicleInfo or {},
    issuedAt = os.date('%Y-%m-%d %H:%M:%S'),
    issuedBy = data.issuedBy or 'Dispatch',
    status = 'active',
    lastSeen = data.lastSeen or 'Unknown'
  }

  BOLOs[bolo.id] = bolo

  if Config.debug then
    print(('[warrant_system] Created BOLO %s for %s | Reason: %s | Dangerous: %s'):format(
      bolo.id,
      bolo.personName,
      bolo.reason,
      bolo.dangerous and 'YES' or 'NO'
    ))
  end

  TriggerEvent('npc_identity:server:addMemory', data.personId, 'bolo_' .. bolo.id, bolo)

  return bolo
end

local function getWarrants()
  local list = {}
  for _, warrant in pairs(Warrants) do
    table.insert(list, warrant)
  end
  return list
end

local function getBOLOs()
  local list = {}
  for _, bolo in pairs(BOLOs) do
    table.insert(list, bolo)
  end
  return list
end

local function revokeWarrant(warrantId)
  if Warrants[warrantId] then
    Warrants[warrantId].status = 'revoked'
    return true
  end
  return false
end

local function revokeBOLO(boloId)
  if BOLOs[boloId] then
    BOLOs[boloId].status = 'revoked'
    return true
  end
  return false
end

RegisterNetEvent('warrant_system:server:createWarrant', function(data)
  createWarrant(data)
end)

RegisterNetEvent('warrant_system:server:createBOLO', function(data)
  createBOLO(data)
end)

RegisterNetEvent('warrant_system:server:requestWarrants', function()
  local src = source
  TriggerClientEvent('warrant_system:client:receiveWarrants', src, getWarrants())
end)

RegisterNetEvent('warrant_system:server:requestBOLOs', function()
  local src = source
  TriggerClientEvent('warrant_system:client:receiveBOLOs', src, getBOLOs())
end)

RegisterNetEvent('warrant_system:server:revokeWarrant', function(warrantId)
  revokeWarrant(warrantId)
end)

RegisterNetEvent('warrant_system:server:revokeBOLO', function(boloId)
  revokeBOLO(boloId)
end)

exports('createWarrant', createWarrant)
exports('createBOLO', createBOLO)
exports('getWarrants', getWarrants)
exports('getBOLOs', getBOLOs)
exports('revokeWarrant', revokeWarrant)
exports('revokeBOLO', revokeBOLO)
