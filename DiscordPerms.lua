local FormattedToken = "Bot "..Config.DiscordToken

function DiscordRequest(method, endpoint, jsondata)
    local data = nil
    PerformHttpRequest("https://discordapp.com/api/"..endpoint, function(errorCode, resultData, resultHeaders)
		data = {data=resultData, code=errorCode, headers=resultHeaders}
	end, method, #jsondata > 0 and json.encode(jsondata) or "", {["Content-Type"] = "application/json", ["Authorization"] = FormattedToken})

    while data == nil do
        Citizen.Wait(0)
    end
	
    return data
end

function GetUserDiscordData(user)
	local ReturnedData = DiscordRequest("GET", ("guilds/%s/members/%s"):format(Config.GuildId, string.gsub(exports.dfs:GetTheirIdentifiers(user).DiscordID, "discord:", "")), {})
	if ReturnedData.code ~= 200 then
		print("dfs_queue.DiscordPerms.lua:GetUserDiscordData(user): ERROR: Got an invalid response from the Discord API. Data:  "..ReturnedData.code)
		return {}
	else
		print("dfs_queue.DiscordPerms.lua:GetUserDiscordData(user): API Normal Response: " .. json.encode(ReturnedData))
	end
	return json.decode(ReturnedData.data)
end

function AddUserDiscordRole(PlayerDiscordData, RoleID)
	print("UserID:"..PlayerDiscordData.user.id.." RoleID:"..RoleID)
	local result = DiscordRequest("PUT", ("guilds/%s/members/%s/roles/%d"):format(Config.GuildId, PlayerDiscordData.user.id, RoleID), "")
	print(json.encode(result))
end

function RemoveUserDiscordRole(PlayerDiscordData, RoleID)
	DiscordRequest("DELETE", ("guilds/%s/members/%s/roles/%d?Content-Length=0"):format(Config.GuildId, PlayerDiscordData.user.id, RoleID), "")
end
--[[
	https://discordapp.com/api/guilds/%s/members/%s/roles/%d
	Sample Data from GetUserDiscordData (unfiltered)
	{
		"user": 
		{
			"id": "529833928941633551",
			"username": "x otikoruk x",
			"avatar": "74c9df05954951dcdf0b8cf41b78d08c",
			"discriminator": "4064",
			"public_flags": 0
		}, 
		"roles": ["657093081933414411", "657721384230977549", "662361254244909066", "662361491953025054", "662374462636949515", "678082144790118406", "679544658703286299", "680304076801703957"], 
		"nick": "Brooks",
		"premium_since": "2020-01-31T21:12:46.926000+00:00",
		"mute": false,
		"deaf": false,
		"joined_at": "2019-12-19T02:23:45.991000+00:00"
	}
]]

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

Citizen.CreateThread(function()
	local ServerConnectionData = DiscordRequest("GET", "guilds/"..Config.GuildId, {})
	if ServerConnectionData.code == 200 then
		local data = json.decode(ServerConnectionData.data)
		print("^2Connected to your discord server! Debug: "..data.name.." ("..data.id..")^0")
	else
		print("^8=============\nCould NOT connect to discord. Error Data: " .. (ServerConnectionData.data or ServerConnectionData.code) .. "\n=============^0")
	end
end)