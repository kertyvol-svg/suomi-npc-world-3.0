local ActiveInteractions = {}
local PlayerInteractionState = {}

local function getNpcById(npcId)
  local npc = exports['npc_core']:getNpcById(npcId)
  return npc
end

local function getPersonIdentity(personId)
  local identity = exports['npc_identity']:getPersonIdentity(personId)
  return identity
end

local function determineNpcReaction(npc)
  local rand = math.random(0, 100) / 100

  if rand <= Config.npcReactions.comply then
    return 'comply'
  elseif rand <= Config.npcReactions.comply + Config.npcReactions.resist then
    return 'resist'
  else
    return 'flee'
  end
end

local function startInteraction(data)
  local npcId = data.npcId
  local playerId = data.playerId
  local interactionType = data.interactionType or 'stop'

  if not npcId or not playerId then
    return false
  end

  local npc = getNpcById(npcId)
  if not npc then
    return false
  end

  local identity = getPersonIdentity(npc.id)
  if not identity then
    return false
  end

  local interactionId = 'interaction_' .. tostring(os.time()) .. '_' .. tostring(math.random(1000, 9999))

  local interaction = {
    id = interactionId,
    npcId = npcId,
    playerId = playerId,
    type = interactionType,
    startTime = os.time(),
    status = 'active',
    npcName = identity.name,
    npcState = npc.state or 'idle',
    warningGiven = false,
    searched = false,
    itemsFound = {},
    npcReaction = determineNpcReaction(npc)
  }

  ActiveInteractions[interactionId] = interaction
  PlayerInteractionState[playerId] = interactionId

  TriggerClientEvent('police_interaction:client:interactionStarted', playerId, interaction)
  TriggerEvent('npc_identity:server:setState', npcId, 'stopped')

  if Config.debug then
    print(('[police_interaction] Interaction started: %s | Type: %s | NPC: %s'):format(
      interactionId,
      interactionType,
      identity.name
    ))
  end

  return interaction
end

local function handleNpcReaction(interactionId)
  local interaction = ActiveInteractions[interactionId]
  if not interaction then
    return
  end

  local reaction = interaction.npcReaction

  if reaction == 'comply' then
    TriggerClientEvent('police_interaction:client:npcComplies', interaction.playerId, interaction)
  elseif reaction == 'resist' then
    TriggerClientEvent('police_interaction:client:npcResists', interaction.playerId, interaction)
  elseif reaction == 'flee' then
    TriggerClientEvent('police_interaction:client:npcFlees', interaction.playerId, interaction)
  end

  if Config.debug then
    print(('[police_interaction] NPC reaction: %s | %s'):format(interaction.npcName, reaction))
  end
end

local function warnNpc(interactionId)
  local interaction = ActiveInteractions[interactionId]
  if not interaction then
    return false
  end

  interaction.warningGiven = true
  TriggerClientEvent('police_interaction:client:warningGiven', interaction.playerId, interaction)
  return true
end

local function generateFoundItems()
  local items = {}
  local rand = math.random(0, 100)

  if rand < 30 then
    table.insert(items, { name = 'Wallet', description = 'Cash and ID' })
  end
  if rand < 20 then
    table.insert(items, { name = 'Phone', description = 'Mobile device' })
  end
  if rand < 10 then
    table.insert(items, { name = 'Keys', description = 'House/Vehicle keys' })
  end
  if rand < 5 then
    table.insert(items, { name = 'Weapon', description = 'Illegal firearm' })
  end

  return items
end

local function searchNpc(interactionId)
  local interaction = ActiveInteractions[interactionId]
  if not interaction then
    return false
  end

  if interaction.npcReaction ~= 'comply' and not interaction.warningGiven then
    return false
  end

  interaction.searched = true
  interaction.itemsFound = generateFoundItems()

  TriggerClientEvent('police_interaction:client:searchComplete', interaction.playerId, interaction)
  return true
end

local function arrestNpc(interactionId, officerName, reason)
  local interaction = ActiveInteractions[interactionId]
  if not interaction then
    return false
  end

  if interaction.npcReaction == 'flee' then
    TriggerClientEvent('police_interaction:client:arrestFailed', interaction.playerId, interaction)
    return false
  end

  local arrestData = {
    personId = interaction.npcId,
    reason = reason or 'Violation',
    officerName = officerName or 'Unknown Officer',
    durationMinutes = Config.defaultArrestDuration
  }

  local arrest = exports['arrest_system']:arrestNpc(arrestData)

  if arrest then
    interaction.status = 'arrested'
    interaction.arrestId = arrest.id

    TriggerClientEvent('police_interaction:client:arrestSuccess', interaction.playerId, {
      interaction = interaction,
      arrest = arrest
    })

    if Config.debug then
      print(('[police_interaction] Arrest made: %s | NPC: %s'):format(arrest.id, interaction.npcName))
    end

    return arrest
  end

  return false
end

local function endInteraction(interactionId)
  local interaction = ActiveInteractions[interactionId]
  if not interaction then
    return false
  end

  interaction.status = 'ended'
  interaction.endTime = os.time()

  if PlayerInteractionState[interaction.playerId] == interactionId then
    PlayerInteractionState[interaction.playerId] = nil
  end

  return true
end

RegisterNetEvent('police_interaction:server:startInteraction', function(npcId, interactionType)
  local src = source
  local interaction = startInteraction({
    npcId = npcId,
    playerId = src,
    interactionType = interactionType
  })

  if interaction then
    TriggerClientEvent('police_interaction:client:interactionStarted', src, interaction)
  end
end)

RegisterNetEvent('police_interaction:server:handleReaction', function(interactionId)
  handleNpcReaction(interactionId)
end)

RegisterNetEvent('police_interaction:server:warnNpc', function(interactionId)
  warnNpc(interactionId)
end)

RegisterNetEvent('police_interaction:server:searchNpc', function(interactionId)
  searchNpc(interactionId)
end)

RegisterNetEvent('police_interaction:server:arrestNpc', function(interactionId, officerName, reason)
  arrestNpc(interactionId, officerName, reason)
end)

RegisterNetEvent('police_interaction:server:endInteraction', function(interactionId)
  endInteraction(interactionId)
end)

exports('startInteraction', startInteraction)
exports('getInteraction', function(interactionId)
  return ActiveInteractions[interactionId]
end)
exports('getPlayerInteraction', function(playerId)
  local interactionId = PlayerInteractionState[playerId]
  if interactionId then
    return ActiveInteractions[interactionId]
  end
  return nil
end)
