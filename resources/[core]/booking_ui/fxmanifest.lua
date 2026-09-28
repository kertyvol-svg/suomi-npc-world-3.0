fx_version 'cerulean'
game 'gta5'

lua54 'yes'

name 'booking_ui'
description 'Booking and custody management UI for Suomi NPC World 3.0'
author 'kertyvol-svg'

ui_page 'ui/booking.html'

files {
  'ui/booking.html',
  'ui/booking-styles.css',
  'ui/booking.js'
}

server_scripts {
  'server/main.lua'
}

client_scripts {
  'client/main.lua'
}
