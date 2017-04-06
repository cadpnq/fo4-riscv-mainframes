Scriptname mainframe:CPUScript extends mainframe:BaseScript

int[] Registers
int ProgramCounter

Event OnInit()
	Registers = new int[32]
EndEvent

Function Cycle()
; fetch instruction
	int Instruction = Read(ProgramCounter)

; execute instruction
; increment ProgramCounter or jump
	ProgramCounter += 4
EndFunction

int Function Read(int address)
	ExpansionRackScript NextRack = ISPSelf.GetObject("NextRack") as ExpansionRackScript
	If(NextRack)
		Return NextRack.Read(address)
	Else
		Return 0
	EndIf
EndFunction

Function Write(int address, int value)
	ExpansionRackScript NextRack = ISPSelf.GetObject("NextRack") as ExpansionRackScript
	If(NextRack)
		NextRack.Write(address, value)
	EndIf
EndFunction