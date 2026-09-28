-- Booking UI client-side handler
local BookingOpen = false

local function toggleBooking(arrest)
  BookingOpen = not BookingOpen

  if BookingOpen and arrest then
    SendNUIMessage({ type = 'show', arrest = arrest })
    SetNuiFocus(true, true)
  else
    SendNUIMessage({ type = 'hide' })
    SetNuiFocus(false, false)
  end
end

RegisterCommand('booking', function(args)
  toggleBooking({
    id = 'arrest_' .. tostring(os.time()),
    personId = 'npc_001',
    reason = 'Armed Robbery, Assault',
    officerName = 'Officer Johnson',
    bookedAt = os.date('%Y-%m-%d %H:%M:%S'),
    releaseAt = os.date('%Y-%m-%d %H:%M:%S', os.time() + 1800),
    durationMinutes = 30
  })
end, false)

RegisterNetEvent('booking_ui:client:showBooking', function(arrest)
  toggleBooking(arrest)
end)

RegisterNetEvent('booking_ui:client:hideBooking', function()
  BookingOpen = false
  SendNUIMessage({ type = 'hide' })
  SetNuiFocus(false, false)
end)
