-- Client-side police interaction system
local CurrentInteraction = nil
local InteractionMenu = false

local function showInteractionMenu(interaction)
  InteractionMenu = true

  local menuOptions = {
    { label = 'Warn NPC', action = 'warn' },
    { label = 'Search NPC', action = 'search' },
    { label = 'Request ID', action = 'requestid' },
    { label = 'Arrest', action = 'arrest' },
    { label = 'End Interaction', action = 'end' }
  }

  for i, option in ipairs(menuOptions) do
    print(i .. '. ' .. option.label)
  end
end

local function performWarning(interaction)
  print('[police_interaction] Warning given to ' .. interaction.npcName)
  TriggerServerEvent('police_interaction:server:warnNpc', interaction.id)
end

local function performSearch(interaction)
  print('[police_interaction] Searching ' .. interaction.npcName .. '...')
  TriggerServerEvent('police_interaction:server:searchNpc', interaction.id)
end

local function performArrest(interaction)
  print('[police_interaction] Arresting ' .. interaction.npcName .. '...')
  TriggerServerEvent('police_interaction:server:arrestNpc', interaction.id, 'Officer Badge 301', 'Violation of law')
end

local function endInteraction(interaction)
  print('[police_interaction] Ending interaction with ' .. interaction.npcName)
  TriggerServerEvent('police_interaction:server:endInteraction', interaction.id)
  CurrentInteraction = nil
  InteractionMenu = false
end

RegisterNetEvent('police_interaction:client:interactionStarted', function(interaction)
  CurrentInteraction = interaction
  print(('[police_interaction] Interaction started with %s | Type: %s'):format(interaction.npcName, interaction.type))
  print('Waiting for NPC reaction...')
  Wait(1000)
  TriggerServerEvent('police_interaction:server:handleReaction', interaction.id)
end)

RegisterNetEvent('police_interaction:client:npcComplies', function(interaction)
  print('[police_interaction] ' .. interaction.npcName .. ' complies with your request')
  showInteractionMenu(interaction)
end)

RegisterNetEvent('police_interaction:client:npcResists', function(interaction)
  print('[police_interaction] WARNING: ' .. interaction.npcName .. ' is resisting!')
  showInteractionMenu(interaction)
end)

RegisterNetEvent('police_interaction:client:npcFlees', function(interaction)
  print('[police_interaction] WARNING: ' .. interaction.npcName .. ' is fleeing the scene!')
end)

RegisterNetEvent('police_interaction:client:warningGiven', function(interaction)
  print('[police_interaction] You have warned ' .. interaction.npcName)
end)

RegisterNetEvent('police_interaction:client:searchComplete', function(interaction)
  print('[police_interaction] Search complete on ' .. interaction.npcName)
  if #interaction.itemsFound > 0 then
    print('Items found:')
    for _, item in ipairs(interaction.itemsFound) do
      print('  - ' .. item.name .. ' (' .. item.description .. ')')
    end
  else
    print('No items found')
  end
end)

RegisterNetEvent('police_interaction:client:arrestSuccess', function(data)
  print('[police_interaction] ' .. data.interaction.npcName .. ' has been arrested')
  print('Arrest ID: ' .. data.arrest.id)
  print('Open booking screen now')
  TriggerEvent('booking_ui:client:showBooking', data.arrest)
end)

RegisterNetEvent('police_interaction:client:arrestFailed', function(interaction)
  print('[police_interaction] Arrest failed! ' .. interaction.npcName .. ' is fleeing!')
end)

RegisterCommand('stopnpc', function(args)
  print('Attempting to stop nearby NPC...')
  TriggerServerEvent('police_interaction:server:startInteraction', 'npc_001', 'stop')
end, false)

RegisterCommand('warnnpc', function(args)
  if CurrentInteraction then
    performWarning(CurrentInteraction)
  else
    print('No active interaction')
  end
end, false)

RegisterCommand('searchnpc', function(args)
  if CurrentInteraction then
    performSearch(CurrentInteraction)
  else
    print('No active interaction')
  end
end, false)

RegisterCommand('arrestnpc', function(args)
  if CurrentInteraction then
    performArrest(CurrentInteraction)
  else
    print('No active interaction')
  end
end, false)

RegisterCommand('endinteraction', function(args)
  if CurrentInteraction then
    endInteraction(CurrentInteraction)
  else
    print('No active interaction')
  end
end, false)
