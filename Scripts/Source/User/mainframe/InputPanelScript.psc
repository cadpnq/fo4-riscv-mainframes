Scriptname mainframe:InputPanelScript extends mainframe:PanelBaseScript

import mainframe:Common

Activator Property Input Auto

ObjectReference[] Inputs

Event OnInit()
  Inputs = MakeConnectors(self, Input, 1)
  PositionConnectorsInLine(Self, Inputs, 0, 0, 0, 3)
  AttachConnectors(Self, Inputs)
EndEvent

Event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
  DeleteConnectors(Inputs)
EndEvent

int Function Read(int address)
  Return ReadInputs(Inputs)
EndFunction

Function Write(int address, int value)
EndFunction
