ScriptName mainframe:BaseScript Extends ObjectReference

ISP_Script Property ISPSelf auto Hidden

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	ISPSelf = (Self as ObjectReference) as ISP_Script
	ISPSelf.Register(Self)
EndEvent

Event OnWorkshopObjectDestroyed(ObjectReference akReference)
	ISPSelf.Unregister(Self)
EndEvent

Event ISP_Script.OnSnapped(ISP_Script akSender, Var[] akArgs)
EndEvent

Event ISP_Script.OnUnsnapped(ISP_Script akSender, Var[] akArgs)
EndEvent

int Function Read(int address)
	Return 0
EndFunction

Function Write(int address, int value)
EndFunction
