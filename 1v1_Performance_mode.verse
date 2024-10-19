using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary/Diagnostics }
using {/Fortnite.com/Teams}
using {/Verse.org/Simulation}
using {/Fortnite.com/Characters}
using {/Verse.org/Random}
using {/Fortnite.com/Game}
using {/Fortnite.com/FortPlayerUtilities}
using {/UnrealEngine.com/Temporary/SpatialMath}

HideProps := class(creative_device):

    @editable
    Switch : switch_device = switch_device{}

    # For this prop you need to place down a small cube and make it invisible, and connect each props and devices that you want to be hid to it.
    @editable
    HideBlock : creative_prop = creative_prop{}

    var OgTransform : transform = transform{}

    # Shrinking down and moving away the selected props.
    HideAll(Agent:agent):void=
        spawn{HideBlock.MoveTo(transform{Scale:= vector3{X:= 0.1, Y:= 0.1, Z:= 0.1}, Rotation:= OgTransform.Rotation, Translation:= vector3{X:= 0.0, Y:= -768.0, Z:= -4224.0}}, 0.1)}

    # Placing the props and devices back to it's original place.
    ShowAll(Agent:agent):void=
        spawn{HideBlock.MoveTo(OgTransform, 0.1)}

    OnBegin<override>()<suspends>:void=

        set OgTransform = HideBlock.GetTransform()

        # If this switch being turned on or off then it will hide or show each prop connected to the prop.
        Switch.TurnedOnEvent.Subscribe(HideAll)
        Switch.TurnedOffEvent.Subscribe(ShowAll)