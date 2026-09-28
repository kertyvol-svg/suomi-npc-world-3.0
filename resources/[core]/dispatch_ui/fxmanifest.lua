fx_version 'cerulean'
game 'gta5'

lua54 'yes'

name 'dispatch_ui'
description 'Dispatch call management UI for Suomi NPC World 3.0'
author 'kertyvol-svg'

ui_page 'ui/dispatch.html'

files {
  'ui/dispatch.html',
  'ui/styles.css',
  'ui/dispatch.js'
}

server_scripts {
  'server/main.lua'
}

client_scripts {
  'client/main.lua'
}
