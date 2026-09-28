local DailyLife = {
  schedules = {
    work = { 'work', 'walking', 'idle' },
    civilian = { 'walking', 'idle', 'shopping' },
    police = { 'patrol', 'idle', 'investigation' },
    mechanic = { 'work', 'walking', 'idle' }
  },

  tasks = {
    work = { x = 120.0, y = -1285.0, z = 29.0 },
    shopping = { x = 138.0, y = -1268.0, z = 29.0 },
    home = { x = 165.0, y = -1255.0, z = 29.0 },
    patrol = { x = 190.0, y = -1270.0, z = 29.0 }
  }
}

local function getCurrentHour()
  return tonumber(os.date('%H'))
end

local function decideStateForNpc(identity)
  local hour = getCurrentHour()

  if identity.job == 'police' then
    if hour >= 7 and hour <= 18 then
      return 'patrol'
    end
    return 'idle'
  end

  if identity.job == 'mechanic' then
    if hour >= 8 and hour <= 17 then
      return 'work'
    end
    return 'walking'
  end

  if hour >= 9 and hour <= 12 then
    return 'walking'
  elseif hour >= 13 and hour <= 16 then
    return 'shopping'
  else
    return 'idle'
  end
end

local function updateNpcRoutine(npcId, identity)
  if not identity then
    return
  end

  local nextState = decideStateForNpc(identity)
  TriggerEvent('npc_identity:server:setState', npcId, nextState)
  identity.state = nextState

  if nextState == 'work' then
    identity.work = 'garage_downtown'
  elseif nextState == 'shopping' then
    identity.home = 'market_district'
  end
end

CreateThread(function()
  while true do
    Wait(15000)

    local identities = exports['npc_identity']:getAllIdentities()
    for _, identity in ipairs(identities) do
      updateNpcRoutine(identity.id, identity)
    end
  end
end)

RegisterNetEvent('npc_daily_life:server:requestRoutine', function()
  local src = source
  local identities = exports['npc_identity']:getAllIdentities()
  TriggerClientEvent('npc_daily_life:client:receiveRoutine', src, identities)
end)

exports('decideStateForNpc', decideStateForNpc)
exports('updateNpcRoutine', updateNpcRoutine)
