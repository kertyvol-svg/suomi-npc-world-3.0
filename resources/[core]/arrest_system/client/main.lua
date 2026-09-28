-- Client-side arrest system placeholder
-- This can be expanded later with player booking UI or arrest notifications.

RegisterNetEvent('arrest_system:client:arrestUpdated', function(arrest)
  if arrest then
    print(('[arrest_system] Arrest updated: %s | reason=%s'):format(arrest.id, arrest.reason))
  end
end)

RegisterNetEvent('arrest_system:client:arrestReleased', function(data)
  if data and data.success then
    print(('[arrest_system] Arrest released: %s'):format(data.arrestId))
  end
end)

RegisterNetEvent('arrest_system:client:arrestsList', function(arrests)
  print(('[arrest_system] Active arrests: %d'):format(#arrests))
end)
