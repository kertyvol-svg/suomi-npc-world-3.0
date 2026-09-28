-- Police MDT UI Server-side handler
local function searchPerson(query)
  local results = {}
  local ok = pcall(function()
    results = exports['police_mdt']:searchPerson(query)
  end)

  if not ok then
    return {}
  end

  return results
end

local function searchVehicle(plate)
  local results = {}
  local ok = pcall(function()
    results = exports['police_mdt']:searchVehicle(plate)
  end)

  if not ok then
    return {}
  end

  return results
end

RegisterNetEvent('police_mdt_ui:server:searchPerson', function(query)
  local src = source
  local results = searchPerson(query)
  TriggerClientEvent('police_mdt_ui:client:personSearchResults', src, results)
end)

RegisterNetEvent('police_mdt_ui:server:searchVehicle', function(plate)
  local src = source
  local results = searchVehicle(plate)
  TriggerClientEvent('police_mdt_ui:client:vehicleSearchResults', src, results)
end)
