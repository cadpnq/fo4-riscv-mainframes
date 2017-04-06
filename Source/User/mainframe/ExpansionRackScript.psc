Scriptname mainframe:ExpansionRackScript extends mainframe:BaseScript

int Function Read(int address)
	If(address >= 8192)
		ExpansionRackScript NextRack = ISPSelf.GetObject("NextRack") as ExpansionRackScript
		If(NextRack)
			Return NextRack.Read(address - 8192)
		Else
			Return 0
		EndIf
	Else
		int PanelNumber = Math.floor(address / 1024)
		String PanelName = "Panel" + PanelNumber
		PanelBaseScript Panel = ISPSelf.GetObject(PanelName) as PanelBaseScript
		If(Panel)
			Return Panel.Read(address - (1024 * PanelNumber))
		Else
			Return 0
		EndIf
	EndIf
	Return 0
EndFunction

Function Write(int address, int value)
	If(address >= 8192)
		ExpansionRackScript NextRack = ISPSelf.GetObject("NextRack") as ExpansionRackScript
		If(NextRack)
			NextRack.Write(address - 8192, value)
		EndIf
	Else
		int PanelNumber = Math.floor(address / 1024)
		String PanelName = "Panel" + PanelNumber
		PanelBaseScript Panel = ISPSelf.GetObject(PanelName) as PanelBaseScript
		If(Panel)
			Panel.Write(address - (1024 * PanelNumber), value)
		EndIf
	EndIf
EndFunction