local ActiveArrests = {}

local function nowISO()
  return os.date('%Y-%m-%d %H:%M:%S')
end

local function arrestNpc(data)
  local personId = data.personId
  local reason = data.reason or 'Unspecified'
  local officerName = data.officerName or 'Unknown Officer'
  local durationMinutes = data.durationMinutes or Config.bookingDurationMinutes

  if not personId then
    return nil
  end

  local arrest = {
    id = data.id or ('arrest_' .. tostring(os.time()) .. '_' .. tostring(math.random(1000, 9999))),
    personId = personId,
    reason = reason,
    officerName = officerName,
    durationMinutes = durationMinutes,
    bookedAt = nowISO(),
    releaseAt = os.date('%Y-%m-%d %H:%M:%S', os.time() + (durationMinutes * 60)),
    status = 'in_custody',
    jailCoords = Config.jailCoords,
    processingStage = 'booked'
  }

  ActiveArrests[arrest.id] = arrest

  TriggerEvent('npc_identity:server:setState', personId, 'arrested')
  TriggerEvent('npc_identity:server:addMemory', personId, 'latest_arrest', arrest)

  if Config.debug then
    print(('[arrest_system] Arrest created: %s | Person: %s | Reason: %s'):format(
      arrest.id,
      personId,
      reason
    ))
  end

  return arrest
end

local function releaseNpc(arrestId)
  if not ActiveArrests[arrestId] then
    return false
  end

  ActiveArrests[arrestId].status = 'released'
  ActiveArrests[arrestId].processingStage = 'released'
  ActiveArrests[arrestId].releasedAt = nowISO()

  TriggerEvent('npc_identity:server:setState', ActiveArrests[arrestId].personId, 'idle')

  if Config.debug then
    print(('[arrest_system] Arrest released: %s'):format(arrestId))
  end

  return true
end

local function getActiveArrests()
  local list = {}
  for _, arrest in pairs(ActiveArrests) do
    table.insert(list, arrest)
  end
  return list
end

local function getArrestById(arrestId)
  return ActiveArrests[arrestId]
end

RegisterNetEvent('arrest_system:server:arrestNpc', function(data)
  local arrest = arrestNpc(data)
  TriggerClientEvent('arrest_system:client:arrestUpdated', source, arrest)
end)

RegisterNetEvent('arrest_system:server:releaseNpc', function(arrestId)
  local released = releaseNpc(arrestId)
  TriggerClientEvent('arrest_system:client:arrestReleased', source, { success = released, arrestId = arrestId })
end)

RegisterNetEvent('arrest_system:server:getArrests', function()
  local src = source
  TriggerClientEvent('arrest_system:client:arrestsList', src, getActiveArrests())
end)

CreateThread(function()
  while true do
    Wait(60000)

    for arrestId, arrest in pairs(ActiveArrests) do
      if arrest.status == 'in_custody' then
        local currentTime = os.time()
        local releaseUnix = os.time({ year = tonumber(string.sub(arrest.releaseAt, 1, 4)), month = tonumber(string.sub(arrest.releaseAt, 6, 7)), day = tonumber(string.sub(arrest.releaseAt, 9, 10)), hour = tonumber(string.sub(arrest.releaseAt, 12, 13)), min = tonumber(string.sub(arrest.releaseAt, 15, 16)), sec = tonumber(string.sub(arrest.releaseAt, 18, 19)) })

        if currentTime >= releaseUnix then
          releaseNpc(arrestId)
        end
      end
    end
  end
end)

exports('arrestNpc', arrestNpc)
exports('releaseNpc', releaseNpc)
exports('getActiveArrests', getActiveArrests)
exports('getArrestById', getArrestById)
