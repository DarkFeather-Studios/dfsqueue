fx_version 'adamant'

game 'gta5'

dependency 'dfs'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server.lua',
    'Config.lua',
    'DiscordPerms.lua'
}

client_script 'client.lua'

file "html/img/ArpAdaptiveCard.png"