using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

var PlayerSavedDataMap : weak_map(player, player_saved_data) = map{}

player_saved_data := class<final><persistable>:
    CurrentRank : int = 0
    CurrentRP : int = 0


MakePlayerData<constructor>(OldData:player_saved_data) := player_saved_data:
    CurrentRank := OldData.CurrentRank
    CurrentRP := OldData.CurrentRP


(Player:player).InitPlayerSavedData():void=
    if:
        Player.IsActive[]
        not PlayerSavedDataMap[Player]
        set PlayerSavedDataMap[Player] = player_saved_data{}

(Player:player).GetPlayerSavedData()<transacts>:player_saved_data=
    var NewPlayerSavedData : player_saved_data = player_saved_data{}
    if:
        Player.IsActive[]
        PlayerData := PlayerSavedDataMap[Player]
        set NewPlayerSavedData = PlayerData

    return NewPlayerSavedData

(Player:player).SavePlayerSavedData(NewData:player_saved_data)<transacts>:void=
    if:
        Player.IsActive[]
        PlayerData := PlayerSavedDataMap[Player]
        set PlayerSavedDataMap[Player] = NewData


persistance_manager := class(creative_device):

    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers()):
            OnPlayerJoined(Player)

        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoined)


    OnPlayerJoined(Player:player):void=
        Player.InitPlayerSavedData()
