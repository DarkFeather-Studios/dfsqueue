--[[
    Text Colors:
    ^0 = Thin White
    ^1 = Light Red
    ^2 = Neon Green
    ^3 = Bone White
    ^4 = Ocean Blue
    ^5 = Sky Blue
    ^6 = Magenta
    ^7 = Default White
    ^8 = Red
    ^9 = Indigo"
]]

local MaxPlayers = 46--
local HardCap = GetConvarInt("sv_maxclients", 64)
local ServerLockdownTime = 3 * 60 * 1000
local ServerTimeToAcceptAllPlayers = ServerLockdownTime
local QueueAcceptingAllPlayers = false
local Queued = {}
local Connected = {}
local HasServerStarted = false
local PositionInQueue = -1
local DroppedPlayerSteams = {}
local Disconnected = {}

local AdaptiveCardQueueData = ""
local WeatherDelayCardData = [[{
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "ColumnSet",
                    "columns": [
                        {
                            "type": "Column",
                            "width": "auto",
                            "items": [
                                {
                                    "type": "Image",
                                    "size": "Small",
                                    "url": "https://adaptivecards.io/content/airplane.png"
                                }
                            ]
                        },
                        {
                            "type": "Column",
                            "width": "stretch",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Your Private Flight Status",
                                    "horizontalAlignment": "Right",
                                    "isSubtle": true,
                                    "color": "Dark",
                                    "weight": "Bolder"
                                },
                                {
                                    "type": "TextBlock",
                                    "text": "DELAYED",
                                    "horizontalAlignment": "Right",
                                    "spacing": "None",
                                    "size": "Large",
                                    "color": "Attention"
                                }
                            ]
                        }
                    ]
                },
                {
                    "type": "ColumnSet",
                    "spacing": "Medium",
                    "separator": true,
                    "columns": [
                        {
                            "type": "Column",
                            "width": 1,
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Flight",
                                    "isSubtle": true,
                                    "weight": "Bolder"
                                },
                                {
                                    "type": "TextBlock",
                                    "text": "DFS-097432",
                                    "spacing": "Small"
                                }
                            ]
                        },
                        {
                            "type": "Column",
                            "width": 1,
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Flights Ahead of You",
                                    "isSubtle": true,
                                    "horizontalAlignment": "Center",
                                    "weight": "Bolder"
                                },
                                {
                                    "type": "TextBlock",
                                    "text": "WEATHER DELAY",
                                    "color": "Attention",
                                    "weight": "Bolder",
                                    "horizontalAlignment": "Center",
                                    "spacing": "Small"
                                }
                            ]
                        },
                        {
                            "type": "Column",
                            "width": 1,
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Total Flights",
                                    "isSubtle": true,
                                    "horizontalAlignment": "Right",
                                    "weight": "Bolder"
                                },
                                {
                                    "type": "TextBlock",
                                    "text": "WEATHER DELAY",
                                    "color": "Attention",
                                    "horizontalAlignment": "Right",
                                    "weight": "Bolder",
                                    "spacing": "Small"
                                }
                            ]
                        }
                    ]
                },
                {
                    "type": "ColumnSet",
                    "spacing": "Medium",
                    "separator": true,
                    "columns": [
                        {
                            "type": "Column",
                            "width": 1,
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "North Yankton Regional"
                                },
                                {
                                    "type": "TextBlock",
                                    "text": "NYRA",
                                    "size": "ExtraLarge",
                                    "color": "Accent",
                                    "spacing": "None"
                                }
                            ]
                        },
                        {
                            "type": "Column",
                            "width": "auto",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": " "
                                },
                                {
                                    "type": "Image",
                                    "url": "https://adaptivecards.io/content/airplane.png",
                                    "size": "Small"
                                }
                            ]
                        },
                        {
                            "type": "Column",
                            "width": 1,
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Los Santos International",
                                    "horizontalAlignment": "Right"
                                },
                                {
                                    "type": "TextBlock",
                                    "text": "LSIA",
                                    "horizontalAlignment": "Right",
                                    "size": "ExtraLarge",
                                    "color": "Accent",
                                    "spacing": "None"
                                }
                            ]
                        }
                    ]
                }
            ],
            "backgroundImage": {
                "url": "",
                "horizontalAlignment": "Center",
                "verticalAlignment": "Center"
            }
        }]]
 
local AdaptiveCardCreateAccountData = [[
    {
        "type": "AdaptiveCard",
        "body": [
            {
                "type": "TextBlock",
                "text": "Whoops, Your Boarding Pass Declined!",
                "maxLines": 1,
                "spacing": "None",
                "wrap": true,
                "horizontalAlignment": "Center",
                "size": "Large",
                "color": "Accent",
                "weight": "Bolder"
            },
            {
                "type": "TextBlock",
                "text": "Click to...",
                "horizontalAlignment": "Center",
                "weight": "Bolder"
            },
            {
                "type": "ActionSet",
                "actions": [
                    {
                        "type": "Action.OpenUrl",
                        "title": "Join Us!",
                        "style": "positive",
                        "url": ""
                    },
                    {
                        "type": "Action.OpenUrl",
                        "title": "Check Our Discord",
                        "style": "positive",
                        "url": ""
                    },
                    {
                        "type": "Action.Submit",
                        "title": "Relaunch and Try Again",
                        "style": "positive"
                    }
                ]
            },
            {
                "type": "TextBlock",
                "text": "ERROR_NO_WHITELIST",
                "size": "Small",
                "fontType": "Monospace",
                "weight": "Lighter",
                "color": "Accent",
                "horizontalAlignment": "Right"
            }
        ],
        "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
        "version": "1.0",
        "backgroundImage": {
            "url": "",
            "verticalAlignment": "Center",
            "horizontalAlignment": "Center"
        },
        "verticalContentAlignment": "Center"
    }
]]

function table.removeKey(table, _value)
    for key, value in pairs(table) do
        if value == _value then
            value = nil
        end
    end
end

RegisterNetEvent("playerDropped")
AddEventHandler("playerDropped", function(reason)
    local src = source
    if reason ~= "Character Switch" then
        local PlayerDataTable
        for k, Player in pairs(Connected) do
            if Player.ServerID == src then
                PlayerDataTable = Player
                RemoveUserDiscordRole(PlayerDataTable.DiscordData, 706103729228873789)
                Player.ConnectionStatus = reason
                Player.Disconnected = GetGameTimer()
                table.insert(DroppedPlayerSteams, Player.SteamID)
                break
            end
        end
        print (string.format("^3Disconnected %s %s#%d from the City; %s.^7", PlayerDataTable.RoleName, PlayerDataTable.DiscordData.user.username, PlayerDataTable.DiscordData.user.discriminator, reason))

        Citizen.CreateThread(function()
            local TimeToWaitTill = GetGameTimer() + 200 * 1000
            while TimeToWaitTill > GetGameTimer() do Wait(1000) end
            table.removeKey(DroppedPlayerSteams, PlayerDataTable.SteamID)
        end)
    end
end)

AddEventHandler("playerConnecting", function (name, setKickReason, deferrals)
    local src = source
    deferrals.defer() 

    print('Player Authenticating...')
    repeat
        deferrals.presentCard(WeatherDelayCardData) 
        Wait(1000)
    until HasServerStarted

    local PlayerIdentifers = exports.dfs:GetTheirIdentifiers(src)
    if not PlayerIdentifers.ServerID then
        deferrals.done("Could not assign you a ServerID.")
        print("^8Rejected - Server Malfunction^7")
        return
    end

    deferrals.update("Checking your Passport...")
    if not PlayerIdentifers.DiscordID then --TODO: Make into a card
        print("^8Rejected - No Discord^7")
        setKickReason("Could not find your DiscordID.") 
        deferrals.done("Could not find your DiscordID.")
        return
    end
    if not PlayerIdentifers.SteamID then --TODO: Make into a card
        print("^8Rejected - No Steam^7")
        setKickReason("Could not find your SteamID.")
        deferrals.done("Could not find your SteamID.")
        return
    end

    local PlayerDataTable = {
        ServerID = PlayerIdentifers.ServerID,
        ConnectionObj = deferrals,
        DiscordID = PlayerIdentifers.DiscordID,
        SteamID = PlayerIdentifers.SteamID,
        SetKickReason = setKickReason,
        Prio = 500000000,
        DiscordData = GetUserDiscordData(PlayerIdentifers.ServerID),
        ConnectionStatus = "Online",
        Disconnected = 0,
        RoleName = "MISSINGROLE"
    }
    
    VerifyAccount(PlayerDataTable)

        --Add each of the roles in your config here. Delete this default toles block when you're done.
    if IsRolePresent(PlayerDataTable, "Executive Team") then
        PlayerDataTable.Perms = 999
        PlayerDataTable.Prio = 1000000000
        PlayerDataTable.RoleName = "Executive"
    elseif IsRolePresent(PlayerDataTable, "Developer") then
        PlayerDataTable.Perms = 999
        PlayerDataTable.Prio = 1000000000
        PlayerDataTable.RoleName = "Developer"
    elseif IsRolePresent(PlayerDataTable, "Staff Administrator") then
        PlayerDataTable.Perms = 998
        PlayerDataTable.Prio = 900000000
        PlayerDataTable.RoleName = "Staff Administrator"
    elseif IsRolePresent(PlayerDataTable, "Staff Manager") then
        PlayerDataTable.Perms = 998
        PlayerDataTable.Prio = 900000000
        PlayerDataTable.RoleName = "Staff Manager"
    elseif IsRolePresent(PlayerDataTable, "Staff") then
        PlayerDataTable.Perms = 997
        PlayerDataTable.Prio = 800000000
        PlayerDataTable.RoleName = "Staff Member"
    elseif IsRolePresent(PlayerDataTable, "Trial Staff") then
        PlayerDataTable.Perms = 996
        PlayerDataTable.Prio = 700000000
        PlayerDataTable.RoleName = "Trial Staff Member"
    elseif IsRolePresent(PlayerDataTable, "Playtester") then
        PlayerDataTable.Perms = 950
        PlayerDataTable.RoleName = "Player"
    elseif IsRolePresent(PlayerDataTable, "Whitelisted") then
        PlayerDataTable.Perms = 0
        PlayerDataTable.RoleName = "Player"
    else
        print("Rejected - Not Whitelisted")
        deferrals.presentCard(AdaptiveCardCreateAccountData, function()
            setKickReason   ("Please relaunch and try again.")
            deferrals.done  ("Please relaunch and try again.")
        end)
        return
    end

    AddUserDiscordRole(PlayerDataTable.DiscordData, 706103729228873789)
    
    MySQL.Sync.execute(string.format("UPDATE `dfs_useraccounts` SET `permission_level` = %d, `prio_points` = %d WHERE `steam_id` = '%s' AND `discord_id` = '%s'", 
            PlayerDataTable.Perms, PlayerDataTable.Prio, PlayerDataTable.SteamID, PlayerDataTable.DiscordID))

    print (string.format("^5Added %s %s#%d to the Queue!^7", PlayerDataTable.RoleName, PlayerDataTable.DiscordData.user.username, PlayerDataTable.DiscordData.user.discriminator))


    PutPlayerInQueue(PlayerDataTable)
end)

function IsRolePresent(PlayerDataTable, RoleName)
    if not PlayerDataTable.DiscordData or not PlayerDataTable.DiscordData.roles then return false end
    for _, RoleID in pairs(PlayerDataTable.DiscordData.roles) do
        for _, RoleConfig in pairs(Config.QueueRoles) do
            if RoleConfig.Name == RoleName and RoleConfig.RoleID == RoleID then
                return true
            end
        end
    end

    return false
end

function VerifyAccount(PlayerDataTable)
    local IsBanned = MySQL.Sync.fetchScalar("SELECT `banned` FROM `dfs_useraccounts` WHERE `discord_id`='"..PlayerDataTable.DiscordID
    .."' AND `steam_id`='"..PlayerDataTable.SteamID.."'")
    local BanReason
    local BannedUntil
    if IsBanned == nil then --Account does not exist
        MySQL.Sync.execute("INSERT INTO `dfs_useraccounts` (discord_id, steam_id) VALUES ('"..PlayerDataTable.DiscordID.."', '"
        ..PlayerDataTable.SteamID.."')")
    elseif exports.dfs:tobool(IsBanned) then --AccountIsBanned
        BanReason = MySQL.Sync.fetchScalar(" SELECT `banned_reason` FROM `dfs_useraccounts` WHERE `discord_id`='"..
        PlayerDataTable.DiscordID.."' AND `steam_id`='"..PlayerDataTable.SteamID.."'")
        BannedUntil = math.floor(tonumber(MySQL.Sync.fetchScalar("SELECT `banned_until` FROM `dfs_useraccounts` WHERE `discord_id`='"..
        PlayerDataTable.DiscordID.."' AND `steam_id`='"..PlayerDataTable.SteamID.."'")) / 1000)
        if BannedUntil < os.time() then 
            MySQL.Sync.execute("UPDATE `dfs_useraccounts` SET `banned` = 0 WHERE `discord_id`='"..PlayerDataTable.DiscordID.."' AND `steam_id`='"..PlayerDataTable.SteamID.."'")
            VerifyAccount(PlayerDataTable)
            return
        else
            local BannedUntilFormatted = os.date("%B %d %Y at %H:%M ", BannedUntil)
            PlayerDataTable.SetKickReason("You are banned until "..BannedUntilFormatted.." for: "..BanReason)
            PlayerDataTable.ConnectionObj.done("You are banned until "..BannedUntilFormatted.." for: "..BanReason)
            print("Rejected - Banned")
            CancelEvent()
            return
        end
    else --IsBanned == false
        PlayerDataTable.Prio = tonumber(MySQL.Sync.fetchScalar("SELECT `prio_points` FROM `dfs_useraccounts` WHERE `discord_id`='"..
        PlayerDataTable.DiscordID.."' AND `steam_id`='"..PlayerDataTable.SteamID.."'"))
    end
end

function PutPlayerInQueue(PlayerDataTable)
    local HasPlacedPlayerInQueue = false
    Wait(0)
    for Index, PlayerInQueue in pairs(Queued) do
        if PlayerInQueue.Prio < PlayerDataTable.Prio then
            table.insert(Queued, Index, PlayerDataTable)
            HasPlacedPlayerInQueue = true
            break
        end
    end
    if #Queued == 0 or not HasPlacedPlayerInQueue then
        table.insert(Queued, #Queued + 1, PlayerDataTable)
    end
end

function UpdateAllPlayersPlaceCards()
    for Index,Player in pairs(Queued) do
        PositionInQueue = Index
        AdaptiveCardQueueData = [[{
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "ColumnSet",
                    "columns": [
                        {
                            "type": "Column",
                            "width": "auto",
                            "items": [
                                {
                                    "type": "Image",
                                    "size": "Small",
                                    "url": "https://adaptivecards.io/content/airplane.png"
                                }
                            ]
                        },
                        {
                            "type": "Column",
                            "width": "stretch",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Your Private Flight Status",
                                    "horizontalAlignment": "Right",
                                    "isSubtle": true,
                                    "color": "Dark",
                                    "weight": "Bolder"
                                },
                                {
                                    "type": "TextBlock",
                                    "text": "DELAYED",
                                    "horizontalAlignment": "Right",
                                    "spacing": "None",
                                    "size": "Large",
                                    "color": "Attention"
                                }
                            ]
                        }
                    ]
                },
                {
                    "type": "ColumnSet",
                    "spacing": "Medium",
                    "separator": true,
                    "columns": [
                        {
                            "type": "Column",
                            "width": 1,
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Flight",
                                    "isSubtle": true,
                                    "weight": "Bolder"
                                },
                                {
                                    "type": "TextBlock",
                                    "text": "DFS-097432",
                                    "spacing": "Small"
                                }
                            ]
                        },
                        {
                            "type": "Column",
                            "width": 1,
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Flights Ahead of You",
                                    "isSubtle": true,
                                    "horizontalAlignment": "Center",
                                    "weight": "Bolder"
                                },
                                {
                                    "type": "TextBlock",
                                    "text": "]]..(PositionInQueue - 1)..[[",
                                    "color": "Attention",
                                    "weight": "Bolder",
                                    "horizontalAlignment": "Center",
                                    "spacing": "Small"
                                }
                            ]
                        },
                        {
                            "type": "Column",
                            "width": 1,
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Total Flights",
                                    "isSubtle": true,
                                    "horizontalAlignment": "Right",
                                    "weight": "Bolder"
                                },
                                {
                                    "type": "TextBlock",
                                    "text": "]]..#Queued..[[",
                                    "color": "Attention",
                                    "horizontalAlignment": "Right",
                                    "weight": "Bolder",
                                    "spacing": "Small"
                                }
                            ]
                        }
                    ]
                },
                {
                    "type": "ColumnSet",
                    "spacing": "Medium",
                    "separator": true,
                    "columns": [
                        {
                            "type": "Column",
                            "width": 1,
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "North Yankton Regional"
                                },
                                {
                                    "type": "TextBlock",
                                    "text": "NYRA",
                                    "size": "ExtraLarge",
                                    "color": "Accent",
                                    "spacing": "None"
                                }
                            ]
                        },
                        {
                            "type": "Column",
                            "width": "auto",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": " "
                                },
                                {
                                    "type": "Image",
                                    "url": "https://adaptivecards.io/content/airplane.png",
                                    "size": "Small"
                                }
                            ]
                        },
                        {
                            "type": "Column",
                            "width": 1,
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Los Santos International",
                                    "horizontalAlignment": "Right"
                                },
                                {
                                    "type": "TextBlock",
                                    "text": "LSIA",
                                    "horizontalAlignment": "Right",
                                    "size": "ExtraLarge",
                                    "color": "Accent",
                                    "spacing": "None"
                                }
                            ]
                        }
                    ]
                }
            ],
            "backgroundImage": {
                "url": "",
                "horizontalAlignment": "Center",
                "verticalAlignment": "Center"
            }
        }]]
        Player.ConnectionObj.presentCard(AdaptiveCardQueueData)
    end
end

Citizen.CreateThread(function ()
    while true do
        Wait(49)
        local _Connected = {}
        for Index, Player in pairs(Connected) do
            if GetPlayerEndpoint(Player.ServerID) ~= nil then
                table.insert(_Connected, Player)
            else    
                table.insert(Disconnected, Player)
            end
        end
        Connected = _Connected
    end
end)

function table.Contains(set, item)
    for key, value in pairs(set) do
        if value == item then return true end
    end
    return false
end

Citizen.CreateThread(function() --PlayerHandlerThread
    while not HasServerStarted do Wait(100) end
    print("\n\n---->> Started Queue. Staff have a padding of "..math.floor(ServerLockdownTime / 1000).." seconds before anyone can connect <<----\n\n")
    while true do
        Wait(100)

        local _Queued = {}
        for Index, Player in pairs(Queued) do
            if GetPlayerEndpoint(Player.ServerID) ~= nil then
                if Player.Perms >= 996 and #Connected < HardCap then
                    --print (string.format("^6Connected %s %s#%d to the City!^7", Player.RoleName, Player.DiscordData.user.username, Player.DiscordData.user.discriminator))
                    Player.ConnectionObj.update("Welcome back, conductor!")
                    Player.ConnectionObj.done()
                    table.insert(Connected, Player)
                elseif table.Contains(DroppedPlayerSteams, GetPlayerIdentifiers(Player.ServerID)[1]) and #Connected < HardCap then
                    print (string.format("^6Connected %s %s#%d to the City after a disconnect!^7", Player.RoleName, Player.DiscordData.user.username, Player.DiscordData.user.discriminator))
                    table.removeKey(DroppedPlayerSteams, GetPlayerIdentifiers(Player.ServerID)[1])
                    Player.ConnectionObj.update("Our national guard is the best!")
                    Player.ConnectionObj.done()
                    table.insert(Connected, Player)
                elseif QueueAcceptingAllPlayers and #Connected < MaxPlayers then
                    print (string.format("^6Connected %s %s#%d to the City!^7", Player.RoleName, Player.DiscordData.user.username, Player.DiscordData.user.discriminator))
                    Player.ConnectionObj.update("All Boarding!")
                    Player.ConnectionObj.done()
                    table.insert(Connected, Player)
                else
                    table.insert(_Queued, #_Queued + 1, Player)
                end
            end
        end
        Queued = _Queued

        if not QueueAcceptingAllPlayers and ServerTimeToAcceptAllPlayers < GetGameTimer() then --if greater than 0 and not -1
            QueueAcceptingAllPlayers = true
        end
        UpdateAllPlayersPlaceCards()
    end
end)

--usage /prio VictimPlayerID +/-Points
RegisterCommand("prio", function (source, args, raw)
    local src = source
    if not exports.db_perms:HasPermission_sv(src, "prio", 996) then return end
    local TargetID = tonumber(args[1])
    local Points = tonumber(args[2])
    local Prio
    local PlayerIdentifers = exports.dfs:GetTheirIdentifiers(TargetID) 
    if TargetID ~= nil then
        Prio = MySQL.Sync.fetchScalar("SELECT `prio_points` FROM `dfs_useraccounts` WHERE `discord_id`='"..PlayerIdentifers.DiscordID..
        "' AND `steam_id`='"..PlayerIdentifers.SteamID.."'")
        if Points ~= nil then
            if Points > 10000 then Points = 10000
            elseif Points < -10000 then Points = -10000
            end
            Prio = Prio + Points
            MySQL.Sync.execute("UPDATE `dfs_useraccounts` SET prio_points = '"..Prio.."' WHERE `discord_id`='"..PlayerIdentifers.DiscordID..
            "' AND `steam_id`='"..PlayerIdentifers.SteamID.."'")
            if Points >= 0 then
                TriggerEvent("alerts:sendto", src, {255, 255, 255}, {0, 160, 16}, "System", "Increased "..TargetID.."'s prio by "..Points.." points!")
            else
                TriggerEvent("alerts:sendto", src, {255, 255, 255}, {193, 0, 0}, "System", "Decreased "..TargetID.."'s prio by "..Points.." points!")
            end
        else
            local FromDefault = Prio-500000000
            local plural = ''
            if FromDefault > 1 then plural = 's' end
            TriggerEvent("alerts:sendto", src, {255, 255, 255}, {0, 160, 16}, "System", "Player "..TargetID.." has "..FromDefault.." Prio Point" .. plural)
        end
    end
end)

RegisterCommand("getplayers", function (source, args, raw)
    local src = source
    if not exports.db_perms:HasPermission_sv(src, "getplayers", 998) then return end
    if src > 0 then 
        TriggerEvent("alerts:sendto", src, {255, 255, 255}, {193, 0, 0}, "System", "There are "..#Queued.." players in queue, and "..#Connected
        .." players connected to the server.")
    else
        print("^5There are "..#Queued.." players in queue, and "..#Connected
        .." players connected to the server.^7")
    end
end)

RegisterNetEvent("dfsqu:SetPlayerConnectedID")
AddEventHandler("dfsqu:SetPlayerConnectedID", function ()
    local src = source
    local PlayerIdentifers = exports.dfs:GetTheirIdentifiers(src)
    for Index, Player in pairs(Connected) do
        if Player.DiscordID == PlayerIdentifers.DiscordID and Player.SteamID == PlayerIdentifers.SteamID then
            Player.ServerID = src
            return
        end
    end
end)

RegisterCommand("getplayer", function (source, args, raw)
    local src = source
    if not exports.db_perms:HasPermission_sv(src, "getplayer", 996) then return end
    local PlayerDataTable
    local IDtoFind = tonumber(args[1])

    for Index, Player in pairs(Connected) do
        if Player.ServerID == IDtoFind then
            PlayerDataTable = Player
            break
        end
    end

    if not PlayerDataTable then
        for Index, Player in pairs(Disconnected) do
            if Player.ServerID == IDtoFind then
                PlayerDataTable = Player
                break
            end
        end
    end

    if PlayerDataTable then
        local DiscordUserName = string.format("%s#%d", PlayerDataTable.DiscordData.user.username, PlayerDataTable.DiscordData.user.discriminator)
        local DisconnectedAgo = PlayerDataTable.Disconnected
        if DisconnectedAgo > 0 then
            DisconnectedAgo = math.floor((GetGameTimer() - PlayerDataTable.Disconnected) / 1000 / 60)
        end
        if src > 0 then
            TriggerEvent("alerts:sendto", src, {255, 255, 255}, {193, 85, 0}, "System", string.format("ID: %d, Prio: %d, %s, Discord Name: %s,\
            ConnectedStatus: %s (%d Mins Ago)", PlayerDataTable.ServerID, PlayerDataTable.Prio-500000000, PlayerDataTable.SteamID, 
            DiscordUserName, PlayerDataTable.ConnectionStatus, DisconnectedAgo))
        else
            print(string.format("^5ID: %d, Prio: %d, %s, Discord Name: %s, ConnectedStatus: %s (%d Mins Ago)^7", 
            PlayerDataTable.ServerID, PlayerDataTable.Prio-500000000, PlayerDataTable.SteamID, DiscordUserName, PlayerDataTable.ConnectionStatus, DisconnectedAgo))
        end
    else
        if src > 0 then
            TriggerEvent("alerts:sendto", src, {255, 255, 255}, {193, 0, 0}, "System", string.format("Record for ID "..IDtoFind.." does not exist"))
        else
            print(string.format("^1Record for ID "..IDtoFind.." does not exist^7"))
        end
    end
end)

RegisterCommand("kickall", function (source, args, raw)
    local src = source
    if not exports.db_perms:HasPermission_sv(src, "kickall", 998) then return end
    KickAllPlayers("All players have been kicked by an admin! Reason:"..string.sub(raw, 8)..". Please relaunch FiveM and reconnect.")
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    KickAllPlayers("PlayerTracker is restarting...  ")
  end)


function KickAllPlayers(Message)
    for Index, Player in pairs(Connected) do
        DropPlayer(Player.ServerID, Message)
    end
    ServerTimeToAcceptAllPlayers = GetGameTimer() + ServerLockdownTime
end

RegisterCommand("setmaxplayers", function (source, args, raw)
    local src = source
    if not exports.db_perms:HasPermission_sv(src, "setserverslots", 999) then return end
    local RequestedMaxSlots = tonumber(args[1])
    if RequestedMaxSlots > HardCap then
        MaxPlayers = HardCap
    elseif type(RequestedMaxSlots) == "number" then
        MaxPlayers = RequestedMaxSlots
    end
end)

RegisterCommand("ban", function (source, args, raw)
    local src = source
    if not exports.db_perms:HasPermission_sv(src, "ban", 997) then return end
    local BanTarget = tonumber(args[1])
    local BanDays = tonumber(args[2])
    if BanTarget == nil or BanTarget ~= BanTarget then
        
        if src > 0 then
            TriggerEvent("alerts:sendto", src, {255, 255, 255}, {0, 0, 0}, "System", "You did not specify a ban target!") 
        else
            print("^1You did not specify a ban target!^7")
        end
        return 
    end
    if BanDays == nil or BanDays ~= BanDays then 
        if src > 0 then
            TriggerEvent("alerts:sendto", src, {255, 255, 255}, {0, 0, 0}, "System", "You did not specify a ban length!") 
        else
            print("^1You did not specify a ban length!^7")
        end
        return 
    end
    if BanDays > 7 then BanDays = 7 end
    local BanReason = "No Reason Specifed - Report to Admin"
    if #args > 2 then
        BanReason = ""
        for k, v in pairs(args) do
            if k > 2 then
                BanReason = BanReason .. v .. " "
            end
        end
    end

    for k, Player in pairs(Connected) do
        if Player.ServerID == BanTarget then
            BanPlayer(src, Player, BanDays, BanReason)
            return
        end
    end

    for k, Player in pairs(Disconnected) do
        if Player.ServerID == BanTarget then
            BanPlayer(src, Player, BanDays, BanReason)
            return
        end
    end


    if src > 0 then
        TriggerEvent("alerts:sendto", src, {255, 255, 255}, {0, 0, 0}, "System", "No record for ID "..BanTarget.."!")
    else
        print("^1No record for ID "..BanTarget.."!^7")
    end
end)

function BanPlayer(Caller, PlayerDataTable, Days, Reason)
    MySQL.Sync.execute("UPDATE `dfs_useraccounts` SET banned = '1', banned_until = NOW() + INTERVAL "..Days.." DAY, banned_reason = '"..Reason.."' WHERE `discord_id`='"..
    PlayerDataTable.DiscordID.."' AND `steam_id`='"..PlayerDataTable.SteamID.."'")
    DropPlayer(PlayerDataTable.ServerID, "Banned: "..Reason)

    if Caller > 0 then
        TriggerEvent("alerts:sendto", src, {255, 255, 255}, {0, 0, 255}, "System", ""..PlayerDataTable.ServerID.." is banned for "..Days.."; "..Reason)
    else
        print("^3"..PlayerDataTable.ServerID.." is banned for "..Days.."; "..Reason.."^7")
    end
end

AddEventHandler("onServerResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Wait(0)
        print ("dfs_queue: Server is safely accepting connections!")
        HasServerStarted = true
    end
end)
