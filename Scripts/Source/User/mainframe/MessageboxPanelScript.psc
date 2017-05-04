Scriptname mainframe:MessageboxPanelScript extends mainframe:PanelBaseScript

Event OnInit()
EndEvent

int Function Read(int address)
  Return 0
EndFunction

Function Write(int address, int value)
  Debug.Messagebox(value)
EndFunction
