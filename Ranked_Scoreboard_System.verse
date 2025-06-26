using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Colors }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }

stats := enum{Rank, RankPoints}

scoreboard_agent_data := class:
    var UIWidget : canvas = canvas{}
    var RanksTextureBlocks : []texture_block = array{}
    var NamesTextBlock : []text_block = array{}
    var StatsTextBlock : []text_block = array{}
    var Backgrounds : []color_block = array{}

scoreboard_system := class(creative_device):

    @editable
    RankSystem : rank_system = rank_system{}
    @editable
    HowMuchPlayersOnScoreboard : int = 5
    @editable
    StatToTrack : stats = stats.RankPoints
    @editable
    FPS : float = 10.0

    var AgentDataMap : [agent]scoreboard_agent_data = map{}

    S_AgentToMessage<localizes>(Agent:agent):message= "{Agent}"
    S_StringToMessage<localizes>(String:string):message= "{String}"

    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers()):
            OnPlayerJoined(Player)

        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoined)
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerJoined)

        spawn. UptadeUIForAllPlayer()


    OnPlayerJoined(Agent:agent):void=
        if:
            not AgentDataMap[Agent]
            set AgentDataMap[Agent] = scoreboard_agent_data{}

        for(Player : GetPlayspace().GetPlayers()):
            RemoveUI(Player)
            InitUI(Player)


    OnPlayerRemoved(Agent:agent):void=
        for(Player : GetPlayspace().GetPlayers()):
            RemoveUI(Player)
            InitUI(Player)



    BubbleSortPlayers(Players:[]player):[]player=
        var SortedPlayers : []player = Players
        P_Length := SortedPlayers.Length
        if(P_Length - 1 > 0):
            for(I := 0..P_Length-1):
                for(J := 0..P_Length - I - 2):
                    if(PlayerA := SortedPlayers[J], PlayerB := SortedPlayers[J + 1]):
                        PlayerAData := PlayerA.GetPlayerSavedData()
                        PlayerBData := PlayerB.GetPlayerSavedData()

                        var StatsA : int = 0
                        var StatsB : int = 0

                        if(StatToTrack = stats.Rank):
                            set StatsA = PlayerAData.CurrentRank
                            set StatsB = PlayerBData.CurrentRank

                        else if(StatToTrack = stats.RankPoints):
                            set StatsA = PlayerAData.CurrentRP
                            set StatsB = PlayerBData.CurrentRP

                        if(StatsA < StatsB):
                            if:
                                set SortedPlayers[J] = PlayerB
                                set SortedPlayers[J + 1] = PlayerA

        return SortedPlayers

        
    UptadeUIForAllPlayer()<suspends>:void=
        LOOP_EXPIRE_TIME : float = 300.0
        var CURRENT_LOOP_TIME : float = LOOP_EXPIRE_TIME
        L_FPS := 1.0/FPS
        loop:
            Sleep(L_FPS)
            set CURRENT_LOOP_TIME -= L_FPS
            BestPlayers := BubbleSortPlayers(GetPlayspace().GetPlayers())
            for(Player : GetPlayspace().GetPlayers(), AgentData := AgentDataMap[Player]):
                for:
                    Idx := 0..AgentData.NamesTextBlock.Length - 1
                    RankTextureBlock := AgentData.RanksTextureBlocks[Idx]
                    NameTextBlock := AgentData.NamesTextBlock[Idx]
                    StatTextBlock := AgentData.StatsTextBlock[Idx]
                    Background := AgentData.Backgrounds[Idx]
                    BestPlayer := BestPlayers[Idx]
                    RankAgentData := RankSystem.AgentDataMap[BestPlayer]
                do:
                    PlayerData := BestPlayer.GetPlayerSavedData()
                    RankTextureBlock.SetImage(RankAgentData.CurrentRankImage)
                    NameTextBlock.SetText(S_AgentToMessage(BestPlayer))
                    StatTextBlock.SetText(S_StringToMessage("{PlayerData.CurrentRP}"))
                    if(Player = BestPlayer):
                        Background.SetColor(Black)
                    else:
                        Background.SetColor(White)


            if(CURRENT_LOOP_TIME <= 0.0):
                spawn. UptadeUIForAllPlayer()
                break


    RemoveUI(Agent:agent):void=
        if(Player := player[Agent], PlayerUI := GetPlayerUI[Player], Widget := AgentDataMap[Agent].UIWidget):
            PlayerUI.RemoveWidget(Widget)
            Widget.SetVisibility(widget_visibility.Hidden)


    InitUI(Agent:agent):void=
        if(AgentData := AgentDataMap[Agent], Player := player[Agent]):
            BestPlayers := BubbleSortPlayers(GetPlayspace().GetPlayers())
            PlayerData := Player.GetPlayerSavedData()

            set AgentData.RanksTextureBlocks = array{}
            set AgentData.NamesTextBlock = array{}
            set AgentData.StatsTextBlock = array{}
            set AgentData.Backgrounds = array{}

            var CanvasSlots : []canvas_slot = array{}

            Y_Difference := 45.0
          var Current_Y : float = 100.0 # Change this into any value you have to (change it to 400 if you need it to be under a minimap).

            for(I := 0..HowMuchPlayersOnScoreboard - 1, BestPlayer := BestPlayers[I]):
                var BackgroundColor : color = color{}
                var RankImage : texture = RankUi.Unranked
                if(BestPlayer = Agent):
                    set BackgroundColor = Black
                else:
                    set BackgroundColor = White

                if(RankAgentData := RankSystem.AgentDataMap[BestPlayer]):
                    set RankImage = RankAgentData.CurrentRankImage

                var Background : color_block = color_block{DefaultColor:=BackgroundColor, DefaultOpacity:=0.2}

                var PlayerRankTextureBlock : texture_block = texture_block{DefaultImage:=RankImage}
                var PlayerNameTextBlock : text_block = text_block{DefaultText:=S_AgentToMessage(BestPlayer), DefaultTextColor:=White, DefaultJustification:=text_justification.Left}
                var PlayerStatTextBlock : text_block = text_block{DefaultText:=S_StringToMessage("{PlayerData.CurrentRP}"), DefaultTextColor:=White, DefaultJustification:=text_justification.Right}

                set CanvasSlots += array{
                    canvas_slot:
                        Widget := Background
                        Anchors := anchors{Minimum:=vector2{X:=1.0, Y:=0.0}, Maximum:=vector2{X:=1.0, Y:=0.0}}
                        Offsets := margin{Left:=-235.0, Top:=Current_Y, Right:=440.0, Bottom:=44.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := false
                        ZOrder := 0

                    canvas_slot:
                        Widget := PlayerRankTextureBlock
                        Anchors := anchors{Minimum:=vector2{X:=1.0, Y:=0.0}, Maximum:=vector2{X:=1.0, Y:=0.0}}
                        Offsets := margin{Left:=-430.0, Top:=Current_Y, Right:=40.0, Bottom:=40.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := false
                        ZOrder := 1

                    canvas_slot:
                        Widget := PlayerNameTextBlock
                        Anchors := anchors{Minimum:=vector2{X:=1.0, Y:=0.0}, Maximum:=vector2{X:=1.0, Y:=0.0}}
                        Offsets := margin{Left:=-260.0, Top:=Current_Y, Right:=260.0, Bottom:=41.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := false
                        ZOrder := 1
                    
                    canvas_slot:
                        Widget := PlayerStatTextBlock
                        Anchors := anchors{Minimum:=vector2{X:=1.0, Y:=0.0}, Maximum:=vector2{X:=1.0, Y:=0.0}}
                        Offsets := margin{Left:=-115.0, Top:=Current_Y, Right:=195.0, Bottom:=41.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := false
                        ZOrder := 1
                }

                set Current_Y += Y_Difference

                set AgentData.RanksTextureBlocks += array{PlayerRankTextureBlock}
                set AgentData.NamesTextBlock += array{PlayerNameTextBlock}
                set AgentData.StatsTextBlock += array{PlayerStatTextBlock}
                set AgentData.Backgrounds += array{Background}


            if(PlayerUI := GetPlayerUI[Player]):
                NewCanvas := canvas:
                    Slots := CanvasSlots

                PlayerUI.AddWidget(NewCanvas)
                set AgentData.UIWidget = NewCanvas
