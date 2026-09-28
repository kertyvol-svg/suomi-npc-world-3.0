fx_version 'cerulean'
game 'gta5'

lua54 'yes'

name 'police_mdt_ui'
description 'Police MDT Frontend UI for Suomi NPC World 3.0'
author 'kertyvol-svg'

ui_page 'ui/mdt.html'

files {
  'ui/mdt.html',
  'ui/mdt-styles.css',
  'ui/mdt.js'
}

server_scripts {
  'server/main.lua'
}

client_scripts {
  'client/main.lua'
}
