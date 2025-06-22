using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }


Health_Modifier := class(creative_device):

    # Triggers for the 200 and for the 175 health changing. 
    @editable
    Trigger200 : trigger_device = trigger_device{}
    @editable
    Trigger175 : trigger_device = trigger_device{}

    # Switches for the heashot only and for the overshield mode. 
    # NOTE: you need to place two seperate trigger for both of the switches and set it so that if the trigger is triggered then the switch's state is toggeled (ON/OFF).
    @editable
    SwitchHeadshotOnly : switch_device = switch_device{}
    @editable
    SwitchOvershield : switch_device = switch_device{}

    # Class devices for the 200 health, for the 175 health and for the overshield options.
    @editable
    Class200 : class_and_team_selector_device = class_and_team_selector_device{}
    @editable
    Class175 : class_and_team_selector_device = class_and_team_selector_device{}
    @editable
    ClassOvershield : class_and_team_selector_device = class_and_team_selector_device{}
    @editable
    ClassCustom : class_and_team_selector_device = class_and_team_selector_device{}

    # Triggers for the custom health options.
    @editable
    TriggerPlus1S : trigger_device = trigger_device{}
    @editable
    TriggerPlus5S : trigger_device = trigger_device{}
    @editable
    TriggerMinus1S : trigger_device = trigger_device{}
    @editable
    TriggerMinus5S : trigger_device = trigger_device{}
    @editable
    TriggerPlus1H : trigger_device = trigger_device{}
    @editable
    TriggerPlus5H : trigger_device = trigger_device{}
    @editable
    TriggerMinus1H : trigger_device = trigger_device{}
    @editable
    TriggerMinus5H : trigger_device = trigger_device{}


    OnBegin<override>()<suspends>:void=
        Trigger200.TriggeredEvent.Subscribe(OnTriggered200)
        Trigger175.TriggeredEvent.Subscribe(OnTriggered175)
        # -----------------------------------------------
        SwitchHeadshotOnly.TurnedOnEvent.Subscribe(OnSwitchHeadshotOnlyTurnedOn)
        SwitchHeadshotOnly.TurnedOffEvent.Subscribe(OnSwitchHeadshotOnlyTurnedOff)
        SwitchOvershield.TurnedOnEvent.Subscribe(OnSwitchOvershieldTurnedOn)
        SwitchOvershield.TurnedOffEvent.Subscribe(OnSwitchOvershieldTurnedOff)
        # -----------------------------------------------
        TriggerPlus1S.TriggeredEvent.Subscribe(OnTriggeredPlus1S)
        TriggerPlus5S.TriggeredEvent.Subscribe(OnTriggeredPlus5S)
        TriggerMinus1S.TriggeredEvent.Subscribe(OnTriggeredMinus1S)
        TriggerMinus5S.TriggeredEvent.Subscribe(OnTriggeredMinus5S)
        # -----------------------------------------------
        TriggerPlus1H.TriggeredEvent.Subscribe(OnTriggeredPlus1H)
        TriggerPlus5H.TriggeredEvent.Subscribe(OnTriggeredPlus5H)
        TriggerMinus1H.TriggeredEvent.Subscribe(OnTriggeredMinus1H)
        TriggerMinus5H.TriggeredEvent.Subscribe(OnTriggeredMinus5H)

    # -----------------------------------------------

    # Segment for the 200 health and for the 175 health change.
    OnTriggered200(Agent : ?agent):void=
        AllPlayers := GetPlayspace().GetPlayers()
        for(allplayers : AllPlayers):
            Class200.ChangeClass(allplayers)

    OnTriggered175(Agent : ?agent):void=
        AllPlayers := GetPlayspace().GetPlayers()
        for(allplayers : AllPlayers):
            Class175.ChangeClass(allplayers)
    
    # -----------------------------------------------

    # Segment for the headshot only and for the overshiekd change.
    OnSwitchHeadshotOnlyTurnedOn(Agent : agent):void=
        AllPlayers := GetPlayspace().GetPlayers()
        for(allplayers : AllPlayers):
            Class175.ChangeClass(allplayers)

    OnSwitchHeadshotOnlyTurnedOff(Agent : agent):void=
        AllPlayers := GetPlayspace().GetPlayers()
        for(allplayers : AllPlayers):
            Class200.ChangeClass(allplayers)

    OnSwitchOvershieldTurnedOn(Agent : agent):void=
        AllPlayers := GetPlayspace().GetPlayers()
        for(allplayers : AllPlayers):
            ClassOvershield.ChangeClass(allplayers)
        
    OnSwitchOvershieldTurnedOff(Agent : agent):void=
        AllPlayers := GetPlayspace().GetPlayers()
        for(allplayers : AllPlayers):
            Class200.ChangeClass(allplayers)

    # -----------------------------------------------

    # Segment for the custom shield options. 
    OnTriggeredPlus1S(PossibleAgent : ?agent):void=
        if (Agent := PossibleAgent?):
            if(Player := player[Agent]):
                if(FC := Agent.GetFortCharacter[]):
                    FC.SetMaxShield(FC.GetMaxShield()+1.0)

    OnTriggeredPlus5S(PossibleAgent : ?agent):void=
        if (Agent := PossibleAgent?):
            if(Player := player[Agent]):
                if(FC := Agent.GetFortCharacter[]):
                    FC.SetMaxShield(FC.GetMaxShield()+5.0)
    
    OnTriggeredMinus1S(PossibleAgent : ?agent):void=
        if (Agent := PossibleAgent?):
            if(Player := player[Agent]):
                if(FC := Agent.GetFortCharacter[]):
                    FC.SetMaxShield(FC.GetMaxShield()-1.0)

    OnTriggeredMinus5S(PossibleAgent : ?agent):void=
        if (Agent := PossibleAgent?):
            if(Player := player[Agent]):
                if(FC := Agent.GetFortCharacter[]):
                    FC.SetMaxShield(FC.GetMaxShield()-5.0)

    # -----------------------------------------------

    # Segment for the custom health options. 
    OnTriggeredPlus1H(PossibleAgent : ?agent):void=
        if (Agent := PossibleAgent?):
            if(Player := player[Agent]):
                if(FC := Agent.GetFortCharacter[]):
                    FC.SetMaxHealth(FC.GetMaxHealth()+1.0)

    OnTriggeredPlus5H(PossibleAgent : ?agent):void=
        if (Agent := PossibleAgent?):
            if(Player := player[Agent]):
                if(FC := Agent.GetFortCharacter[]):
                    FC.SetMaxHealth(FC.GetMaxHealth()+5.0)
    
    OnTriggeredMinus1H(PossibleAgent : ?agent):void=
        if (Agent := PossibleAgent?):
            if(Player := player[Agent]):
                if(FC := Agent.GetFortCharacter[]):
                    FC.SetMaxHealth(FC.GetMaxHealth()-1.0)

    OnTriggeredMinus5H(PossibleAgent : ?agent):void=
        if (Agent := PossibleAgent?):
            if(Player := player[Agent]):
                if(FC := Agent.GetFortCharacter[]):
                    FC.SetMaxHealth(FC.GetMaxHealth()-5.0)
