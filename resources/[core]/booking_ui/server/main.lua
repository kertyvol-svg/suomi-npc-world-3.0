-- Booking UI server-side handler
local function confirmBooking(arrestId)
  local ok = pcall(function()
    local arrest = exports['arrest_system']:getArrestById(arrestId)
    if arrest then
      -- Log booking confirmation
      TriggerEvent('evidence_system:server:createEvidence', {
        caseId = arrest.personId,
        type = 'booking_record',
        description = 'Subject booked at ' .. arrest.bookedAt .. ' for reason: ' .. arrest.reason,
        foundAt = 'Police Station',
        foundBy = arrest.officerName
      })
    end
  end)

  return ok
end

local function releaseSubject(arrestId)
  local ok = pcall(function()
    exports['arrest_system']:releaseNpc(arrestId)
  end)

  return ok
end

RegisterNetEvent('booking_ui:server:confirmBooking', function(data)
  confirmBooking(data.arrestId)
end)

RegisterNetEvent('booking_ui:server:releaseSubject', function(data)
  releaseSubject(data.arrestId)
end)
