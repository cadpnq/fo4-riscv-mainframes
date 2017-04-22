; This file is based on ASPCommon.psc from Advanced Settlement Power
Scriptname mainframe:Common

import Math
import Binlib

;int direction_up = 0
;int direction_down = 1
;int direction_left = 2
;int direction_right = 3

;int connector_offset = 20

ObjectReference[] Function MakeConnectors(ObjectReference ParentObject, \
    Activator Connector, int Count) Global
	ObjectReference[] Connectors = new ObjectReference[Count]

	int i = 0
	While (i < Count)
		Connectors[i] = ParentObject.placeAtMe(Connector as Form, 1, False, False, True)
		i += 1
	EndWhile

	return Connectors
EndFunction

Function DeleteConnectors(ObjectReference[] Connectors) Global
	int i = Connectors.Length
	While (i)
		i -= 1
		Connectors[i].Delete()
		Connectors.RemoveLast()
	EndWhile
EndFunction

Function PositionConnectorsInLine(ObjectReference ParentObject, ObjectReference[] Connectors, int OffsetX, int OffsetY, int OffsetZ, int Direction) Global
	int direction_up = 0
	int direction_down = 1
	int direction_left = 2
	int direction_right = 3

	int connector_offset = 20

	int Xpos = OffsetX
	int Ypos = OffsetY
	int Zpos = OffsetZ

	int i = 0
	While (i < Connectors.Length)
		MoveRelativeTo(ParentObject, Connectors[i], Xpos, Ypos, Zpos, True)

		If (Direction == direction_up)
			Zpos += connector_offset
		ElseIf (Direction == direction_down)
			Zpos -= connector_offset
		ElseIf (Direction == direction_left)
			Xpos -= connector_offset
		ElseIf (Direction == direction_right)
			Xpos += connector_offset
		EndIf

		i += 1
	EndWhile
EndFunction

Function MoveRelativeTo(ObjectReference ParentObject, ObjectReference ObjectToMove, int OffsetX, int OffsetY, int OffsetZ, bool MatchAngle = True) Global
	float Xpos
	float Ypos
	float Zpos = OffsetZ

	float Angle
	float AngleZ = ParentObject.GetAngleZ()

	float Distance = sqrt(pow(OffsetX, 2) + pow(OffsetY, 2))

	If (OffsetX == 0 && OffsetY == 0)
		Angle = 0
	ElseIf (OffsetX == 0)
		If (OffsetY >= 0)
			Angle = 0
		Else
			Angle == 180
		EndIf
	ElseIf (OffsetY == 0)
		If (OffsetX >= 0)
			Angle = 90
		Else
			Angle = 270
		EndIf
	Else
		Angle = atan(OffsetY / OffsetX)
	EndIf

	AngleZ += Angle
	Xpos = Distance * Sin(AngleZ)
	Ypos = Distance * Cos(AngleZ)

	ObjectToMove.MoveTo(ParentObject, Xpos, Ypos, Zpos, MatchAngle)
EndFunction

int Function ReadInputs(ObjectReference[] Connectors) Global
	int retval

	int i = 0
	While (i < Connectors.Length)
		If (Connectors[i].IsPowered())
			retval += pow(2, i) as int
		EndIf

		i += 1
	EndWhile

	return retval
EndFunction

Function WriteOutputs(ObjectReference[] Connectors, int Value) Global
	int i = 0
	While (i < Connectors.Length)
		Connectors[i].SetOpen(GetBit(Value, i) == 0)

		i += 1
	EndWhile
EndFunction

Function AttachConnectors(ObjectReference Me, ObjectReference[] Connectors) Global
	int i = 0
	While (i < Connectors.Length)
			Connectors[i].AttachTo(Me)
		i += 1
	EndWhile
EndFunction
