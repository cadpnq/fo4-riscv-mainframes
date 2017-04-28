Scriptname mainframe:DumbRackScript extends mainframe:BaseScript

int Function Read(int address)
	mainframe:BaseScript NextRack = ISPSelf.GetObject("NextRack") as mainframe:BaseScript
	If(NextRack)
		Return NextRack.Read(address)
	Else
		Return 0
	EndIf
EndFunction

Function Write(int address, int value)
	mainframe:BaseScript NextRack = ISPSelf.GetObject("NextRack") as mainframe:BaseScript
	If(NextRack)
		NextRack.Write(address, value)
	EndIf
EndFunction
