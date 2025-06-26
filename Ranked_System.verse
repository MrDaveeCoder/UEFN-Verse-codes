using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }

manipulation_types := enum{Increment, Decrement, Set}

rank_types := enum{Unranked, Bronze_1, Bronze_2, Bronze_3,
Silver_1, Silver_2, Silver_3, Gold_1, Gold_2, Gold_3,
Platinum_1, Platinum_2, Platinum_3, Diamond_1, Diamond_2, Diamond_3,
Elite, Champion, Unreal}


(RankType:rank_types).GetRankTexture():texture=
    case(RankType):
        rank_types.Unranked => RankUi.Unranked
        rank_types.Bronze_1 => RankUi.Bronze_1
        rank_types.Bronze_2 => RankUi.Bronze_2
        rank_types.Bronze_3 => RankUi.Bronze_3
        rank_types.Silver_1 => RankUi.Silver_1
        rank_types.Silver_2 => RankUi.Silver_2
        rank_types.Silver_3 => RankUi.Silver_3
        rank_types.Gold_1 => RankUi.Gold_1
        rank_types.Gold_2 => RankUi.Gold_2
        rank_types.Gold_3 => RankUi.Gold_3
        rank_types.Platinum_1 => RankUi.Platinum_1
        rank_types.Platinum_2 => RankUi.Platinum_2
        rank_types.Platinum_3 => RankUi.Platinum_3
        rank_types.Diamond_1 => RankUi.Diamond_1
        rank_types.Diamond_2 => RankUi.Diamond_2
        rank_types.Diamond_3 => RankUi.Diamond_3
        rank_types.Elite => RankUi.Elite
        rank_types.Champion => RankUi.Champion
        rank_types.Unreal => RankUi.Unreal

    
(RankType:rank_types).GetRankName():string=
    case(RankType):
        rank_types.Unranked => "UNRANKED"
        rank_types.Bronze_1 => "BRONZE I"
        rank_types.Bronze_2 => "BRONZE II"
        rank_types.Bronze_3 => "BRONZE III"
        rank_types.Silver_1 => "SILVER I"
        rank_types.Silver_2 => "SILVER II"
        rank_types.Silver_3 => "SILVER III"
        rank_types.Gold_1 => "GOLD I"
        rank_types.Gold_2 => "GOLD II"
        rank_types.Gold_3 => "GOLD III"
        rank_types.Platinum_1 => "PLATINUM I"
        rank_types.Platinum_2 => "PLATINUM II"
        rank_types.Platinum_3 => "PLATINUM III"
        rank_types.Diamond_1 => "DIAMOND I"
        rank_types.Diamond_2 => "DIAMOND II"
        rank_types.Diamond_3 => "DIAMOND III"
        rank_types.Elite => "ELITE"
        rank_types.Champion => "CHAMPION"
        rank_types.Unreal => "UNREAL"


        
rank_manager_data := class<concrete>:
    @editable
    Trigger : trigger_device = trigger_device{}
    @editable
    ManipulationType : manipulation_types = manipulation_types.Increment
    @editable
    Value : int = 50

    var MaybeMainDevice : ?rank_system = false

    OnTriggered(MaybeAgent:?agent):void=
        if(MainDevice := MaybeMainDevice?, Agent := MaybeAgent?):
            MainDevice.RankPointsAction(Agent, ManipulationType, Value)


rank_system_agent_data := class:
    var RankMainCanvas : canvas = canvas{}
    var CurrentRankImage : texture = RankUi.Unranked
    var PointsNeedToNextRank : int = 0


rank_data := class<concrete>:
    @editable
    RankType : rank_types = rank_types.Unranked
    @editable
    RankColor : color = color{}
    @editable
    RankPoints : int = 0


rank_system := class(creative_device):

    @editable
    RanksData : []rank_data = array{}
    @editable
    RankManagersData : []rank_manager_data = array{}

    @editable
    FPS : float = 5.0
    @editable
    WithResetPoints : logic = false # <-- | True - It restet current points per new rank | False - It NOT reset current points per new rank
    @editable
    RankBarXValue : float = 250.0

    @editable
    RankNameHud : hud_message_device = hud_message_device{}
    @editable
    NewRankAP : audio_player_device = audio_player_device{}

    var AgentDataMap : [agent]rank_system_agent_data = map{}

    StringMessage<localizes>(String:string):message= "{String}"

    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers()):
            OnPlayerJoined(Player)

        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoined)


        for(RankManagerData : RankManagersData):
            set RankManagerData.MaybeMainDevice = option{Self}
            RankManagerData.Trigger.TriggeredEvent.Subscribe(RankManagerData.OnTriggered)


        spawn. CheckRankForAllPlayers()



    OnPlayerJoined(Agent:agent):void=
        if:
            not AgentDataMap[Agent]
            set AgentDataMap[Agent] = rank_system_agent_data{}

        InitNewPlayer(Agent)
        InitPlayerRankUI(Agent)


    InitNewPlayer(Agent:agent):void=
        if:
            AgentData := AgentDataMap[Agent]
            Player := player[Agent]
            PlayerData := Player.GetPlayerSavedData()
        then:
            CurrentRank := PlayerData.CurrentRank

            if(CurrentRank >= RanksData.Length-1, RankData := RanksData[RanksData.Length-1]):
                set AgentData.PointsNeedToNextRank = 2147483647
                set AgentData.CurrentRankImage = RankData.RankType.GetRankTexture()

            else if(NextRankData := RanksData[CurrentRank + 1], RankData := RanksData[CurrentRank]):
                set AgentData.PointsNeedToNextRank = NextRankData.RankPoints
                set AgentData.CurrentRankImage = RankData.RankType.GetRankTexture()


    CheckRankForAllPlayers()<suspends>:void=
        LOOP_EXPIRE_TIME : float = 300.0
        var CURRENT_LOOP_TIME : float = LOOP_EXPIRE_TIME
        L_FPS := 1.0/FPS
        loop:
            Sleep(L_FPS)
            set CURRENT_LOOP_TIME -= L_FPS
            for(Player : GetPlayspace().GetPlayers()):
                CheckRank(Player)

            if(CURRENT_LOOP_TIME <= 0.0):
                spawn. CheckRankForAllPlayers()
                break


    CheckRank(Agent:agent):void=
        if:
            AgentData := AgentDataMap[Agent]
            Player := player[Agent]
            PlayerData := Player.GetPlayerSavedData()
        then:
            CurrentRank := PlayerData.CurrentRank
            CurrentRP := PlayerData.CurrentRP

            if(CurrentRP >= AgentData.PointsNeedToNextRank):
                OnNewRank(Agent, CurrentRank+1)


    OnNewRank(Agent:agent, NewRank:int):void=
        if:
            AgentData := AgentDataMap[Agent]
            Player := player[Agent]
            PlayerData := Player.GetPlayerSavedData()
        then:
            CurrentRP := PlayerData.CurrentRP
            var NewRankPoints : int = 0

            if(WithResetPoints = true):
                set NewRankPoints = CurrentRP - AgentData.PointsNeedToNextRank

            else if(WithResetPoints = false):
                set NewRankPoints = CurrentRP

            if(NewRankPoints <= 0):
                set NewRankPoints = 0

            NewPlayerSavedData := player_saved_data:
                MakePlayerData<constructor>(PlayerData)
                CurrentRank := NewRank
                CurrentRP := NewRankPoints

            Player.SavePlayerSavedData(NewPlayerSavedData)

            if(NewRank >= RanksData.Length-1, RankData := RanksData[RanksData.Length-1]):
                set AgentData.PointsNeedToNextRank = 2147483647
                set AgentData.CurrentRankImage = RankData.RankType.GetRankTexture()

            else if(NextRankData := RanksData[NewRank + 1], RankData := RanksData[NewRank]):
                set AgentData.PointsNeedToNextRank = NextRankData.RankPoints
                set AgentData.CurrentRankImage = RankData.RankType.GetRankTexture()



    RankPointsAction(Agent:agent, ActionType:manipulation_types, IntValue:int):void=
        if:
            AgentData := AgentDataMap[Agent]
            Player := player[Agent]
            PlayerData := Player.GetPlayerSavedData()
        then:
            CurrentRP := PlayerData.CurrentRP
            var NewRP : int = CurrentRP
            case(ActionType):
                manipulation_types.Increment =>
                    set NewRP += IntValue

                manipulation_types.Decrement =>
                    set NewRP -= IntValue

                manipulation_types.Set =>
                    set NewRP = IntValue

            if(NewRP <= 0):
                set NewRP = 0

            NewPlayerSavedData := player_saved_data:
                MakePlayerData<constructor>(PlayerData)
                CurrentRP := NewRP

            Player.SavePlayerSavedData(NewPlayerSavedData)


    InitPlayerRankUI(Agent:agent):void=
        var RankStackBox : stack_box = stack_box{Orientation := orientation.Horizontal}

        var RankFiller : color_block = color_block{DefaultOpacity := 0.0}
        var RankBarBackground : color_block = color_block{DefaultColor:=NamedColors.White, DefaultOpacity := 0.2}
        var RankBar : color_block = color_block{DefaultColor:=NamedColors.Green}

        var RankImage : texture_block = texture_block{DefaultImage := RankUi.Unranked}

        var RankPointsText : text_block = text_block{DefaultText:=StringMessage("0/75"), DefaultTextColor:=NamedColors.White}

        RankStackBox.AddWidget(stack_box_slot{
            Widget := RankBar
            HorizontalAlignment := horizontal_alignment.Fill
            VerticalAlignment := vertical_alignment.Fill
            Distribution := option{1.0}
        })

        RankStackBox.AddWidget(stack_box_slot{
            Widget := RankFiller
            HorizontalAlignment := horizontal_alignment.Fill
            VerticalAlignment := vertical_alignment.Fill
        })


        if(Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            NewCanvas := canvas:
                Slots := array:
                    canvas_slot{
                        Widget := RankBarBackground
                        Anchors := anchors{Minimum := vector2{X:=0.0, Y:=1.0}, Maximum := vector2{X:=0.0, Y:=1.0}}
                        Offsets := margin{Left := 135.0, Top := -200.0, Right:=RankBarXValue, Bottom:=20.0}
                        ZOrder := 0
                        SizeToContent := false
                    }
                    canvas_slot{
                        Widget := RankStackBox
                        Anchors := anchors{Minimum := vector2{X:=0.0, Y:=1.0}, Maximum := vector2{X:=0.0, Y:=1.0}}
                        Offsets := margin{Left := 135.0, Top := -200.0, Right:=RankBarXValue, Bottom:=20.0}
                        ZOrder := 1
                        SizeToContent := false
                    }
                    canvas_slot{
                        Widget := RankPointsText
                        Anchors := anchors{Minimum := vector2{X:=0.0, Y:=1.0}, Maximum := vector2{X:=0.0, Y:=1.0}}
                        Offsets := margin{Left:=255.0, Top:=-220.0, Right:=165.0, Bottom:=41.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        ZOrder := 1
                        SizeToContent := true
                    }
                    canvas_slot{
                        Widget := RankImage
                        Anchors := anchors{Minimum := vector2{X:=0.0, Y:=1.0}, Maximum := vector2{X:=0.0, Y:=1.0}}
                        Offsets := margin{Left := 50.0, Top := -235.0, Right:=75.0, Bottom:=75.0}
                        ZOrder := 1
                        SizeToContent := false
                    }

            PlayerUI.AddWidget(NewCanvas)
            if(set AgentDataMap[Agent].RankMainCanvas = NewCanvas){}
            spawn. TrackPlayerRank(Agent, RankFiller, RankBar, RankPointsText, RankImage)

            


    TrackPlayerRank(Agent:agent, RankFiller:color_block, RankBar:color_block, RankText:text_block, RankImage:texture_block)<suspends>:void=
        LOOP_EXPIRE_TIME : float = 300.0
        var CURRENT_LOOP_TIME : float = LOOP_EXPIRE_TIME

        L_FPS := 1.0/FPS

        var CurrentRP : float = 0.0
        var RankPoints : float = 0.0
        var NeededRP : float = 0.0
        var RankPercentage : float = 0.0
        if:
            AgentData := AgentDataMap[Agent]
            Player := player[Agent]
        then:
            loop:
                Sleep(L_FPS)
                set CURRENT_LOOP_TIME -= L_FPS

                PlayerData := Player.GetPlayerSavedData()

                CurrentRank := PlayerData.CurrentRank
                set CurrentRP = PlayerData.CurrentRP * 1.0
                set NeededRP = AgentData.PointsNeedToNextRank * 1.0

                if(RankData := RanksData[CurrentRank]):
                    set RankPoints = RankData.RankPoints * 1.0


                if(WithResetPoints = true):
                    set RankPercentage = CurrentRP / NeededRP 

                else if(WithResetPoints = false):
                    set RankPercentage = (CurrentRP - RankPoints) / (NeededRP - RankPoints)

                var NewRankXValue : float = RankBarXValue - (RankBarXValue * RankPercentage)
                if(IntRP := Int[CurrentRP], IntNextRP := Int[NeededRP]):
                    if(CurrentRank >= RanksData.Length -1):
                        RankText.SetText(StringMessage("{IntRP}"))
                        set NewRankXValue = 0.0
                    else:
                        RankText.SetText(StringMessage("{IntRP}/{IntNextRP}"))


                RankFiller.SetDesiredSize(vector2{X:=NewRankXValue, Y:=0.0})
                RankImage.SetImage(AgentData.CurrentRankImage)

                if(RankData := RanksData[CurrentRank]):
                    RankBar.SetColor(RankData.RankColor)
                    RankNameHud.SetText(StringMessage("{RankData.RankType.GetRankName()}"))
                    RankNameHud.Show(Agent)


                if:
                    not Player.IsActive[]
                then:
                    break
                

                if(CURRENT_LOOP_TIME <= 0.0):
                    spawn. TrackPlayerRank(Agent, RankFiller, RankBar, RankText, RankImage)
                    break
