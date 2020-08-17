
AddEventHandler('onClientResourceStart', function (resourceName)
    if GetCurrentResourceName() == resourceName then
        TriggerServerEvent("dfsqu:SetPlayerConnectedID")
    end
end)

--- CLIENT
AddEventHandler("kashacters:PlayerSpawned", function ()
    TriggerServerEvent("dfsqueue:CharacterJoined")
end)

