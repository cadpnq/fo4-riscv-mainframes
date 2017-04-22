Scriptname mainframe:OutputPanelScript extends mainframe:PanelBaseScript


import mainframe:Common

Activator Property Output Auto

ObjectReference[] Outputs

Event OnInit()
  Outputs = MakeConnectors(self, Output, 1)
  PositionConnectorsInLine(Self, Outputs, 0, 0, 0, 3)
  AttachConnectors(Self, Outputs)
EndEvent

Event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
  DeleteConnectors(Outputs)
EndEvent

int Function Read(int address)
  Return 0
EndFunction

Function Write(int address, int value)
  WriteOutputs(Outputs, value)
EndFunction
