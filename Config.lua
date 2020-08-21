Config = {
    DiscordToken = "",
    GuildId = "",

    --Make sure to update this list with the discord roles you want to check for from your guild and their correct IDs.
    --Then, update lines 347-389 of server.lua to match these roles. If I had the time, I would make it all config based and use a forloop instead.
    --If you wish to use a for loop instead, change this table to contain tables of '{ RoleID = YourRoleID, Name = 'YourRolesNameInDiscord', 
                                                                                    --PermsLvl = YourDesiredPermsLevel --[[0-999, where 990+ is staff]],  [, DefaultPrio = 5000000}
    --Then, change lines 347-389 of server.lua to something like 
        
        --for k, v in pairs(Config.QueueRoles) do
            --if IsRolePresent(PlayerDataTable, v.Name) then
                --PlayerDataTable.Perms = v.PermsLvl
                --if0 v.PermsLvl then
                    --PlayerDataTable.Prio = v.PermsLvl
                --end
                --PlayerDataTable.RoleName = v.Name
                --break
            --end
        --end
    
        --if not PlayerDataTable.RoleName then
            --print("Rejected - Not Whitelisted")
            --deferrals.presentCard(AdaptiveCardCreateAccountData, function()
                --setKickReason   ("Please relaunch and try again.")
                --deferrals.done  ("Please relaunch and try again.")
            --end)
        --return
    
    QueueRoles = {
        { RoleID = '168361491453025058'  , Name = 'Developer'            },
        { RoleID = '657793321910200365'  , Name = 'Staff'                },
        { RoleID = '642361754245909096'  , Name = 'Playtester'           }           
    }
}
