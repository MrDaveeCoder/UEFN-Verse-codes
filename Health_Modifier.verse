using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }


Health_Modifier := class(creative_device):

    # Here you have to use triggers and as many as you want.
    @editable
    TriggerPlusFiveS : trigger_device = trigger_device{}

    @editable
    TriggerPlusOneS : trigger_device = trigger_device{}

    @editable
    TriggerMinusFiveS : trigger_device = trigger_device{}

    @editable
    TriggerMinusOneS : trigger_device = trigger_device{}

    @editable
    TriggerPlusFiveH : trigger_device = trigger_device{}

    @editable
    TriggerPlusOneH : trigger_device = trigger_device{}

    @editable
    TriggerMinusFiveH : trigger_device = trigger_device{}

    @editable
    TriggerMinusOneH : trigger_device = trigger_device{}

    # Adds OnTriggered function to all the triggers that was added above.
    OnBegin<override>()<suspends>:void=
        TriggerPlusFiveS.TriggeredEvent.Subscribe(OnTriggered1)
        TriggerPlusOneS.TriggeredEvent.Subscribe(OnTriggered2)
        TriggerMinusFiveS.TriggeredEvent.Subscribe(OnTriggered3)
        TriggerMinusOneS.TriggeredEvent.Subscribe(OnTriggered4)
        
        TriggerPlusFiveH.TriggeredEvent.Subscribe(OnTriggered5)
        TriggerPlusOneH.TriggeredEvent.Subscribe(OnTriggered6)
        TriggerMinusFiveH.TriggeredEvent.Subscribe(OnTriggered7)
        TriggerMinusOneH.TriggeredEvent.Subscribe(OnTriggered8)

    # If the trigger gets triggered the code will get the player's health/shield and adds or removes the amount that was set.
    OnTriggered1(PossibleAgent : ?agent):void=
        if (Agent := PossibleAgent?):
            if(Player := player[Agent]):
                if(FC := Agent.GetFortCharacter[]):
                    FC.SetMaxShield(FC.GetMaxShield()+5.0)

    OnTriggered2(PossibleAgent : ?agent):void=
        if (Agent := PossibleAgent?):
            if(Player := player[Agent]):
                if(FC := Agent.GetFortCharacter[]):
                    FC.SetMaxShield(FC.GetMaxShield()+1.0)

    OnTriggered3(PossibleAgent : ?agent):void=
        if (Agent := PossibleAgent?):
            if(Player := player[Agent]):
                if(FC := Agent.GetFortCharacter[]):
                    FC.SetMaxShield(FC.GetMaxShield()-5.0)

    OnTriggered4(PossibleAgent : ?agent):void=
        if (Agent := PossibleAgent?):
            if(Player := player[Agent]):
                if(FC := Agent.GetFortCharacter[]):
                    FC.SetMaxShield(FC.GetMaxShield()-1.0)

    OnTriggered5(PossibleAgent : ?agent):void=
        if (Agent := PossibleAgent?):
            if(Player := player[Agent]):
                if(FC := Agent.GetFortCharacter[]):
                    FC.SetMaxHealth(FC.GetMaxHealth()+5.0)

    OnTriggered6(PossibleAgent : ?agent):void=
        if (Agent := PossibleAgent?):
            if(Player := player[Agent]):
                if(FC := Agent.GetFortCharacter[]):
                    FC.SetMaxHealth(FC.GetMaxHealth()+1.0)

    OnTriggered7(PossibleAgent : ?agent):void=
        if (Agent := PossibleAgent?):
            if(Player := player[Agent]):
                if(FC := Agent.GetFortCharacter[]):
                    FC.SetMaxHealth(FC.GetMaxHealth()-5.0)

    OnTriggered8(PossibleAgent : ?agent):void=
        if (Agent := PossibleAgent?):
            if(Player := player[Agent]):
                if(FC := Agent.GetFortCharacter[]):
                    FC.SetMaxHealth(FC.GetMaxHealth()-1.0)
