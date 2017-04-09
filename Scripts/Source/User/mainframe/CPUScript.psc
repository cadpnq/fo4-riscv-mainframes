Scriptname mainframe:CPUScript extends mainframe:BaseScript

; Note that I'm making a choice of simple over fast. Lots of optimizations are possible.

int OPGROUP0 = 0
int OPGROUP1 = 0
int OPGROUP2 = 0
int OPGROUP3 = 0
int OPGROUP4 = 0
int OPGROUP5 = 0
int OPGROUP6 = 0
int OPGROUP7 = 0
int OPGROUP8 = 0

int[] Registers
int ProgramCounter
int InstructionRegister

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


; Decoding functions
int Function opcode()
EndFunction

int Function rs1()
EndFunction

int Function rs2()
EndFunction

int Function funct3()
EndFunction

int Function funct7()
EndFunction

int Function r_immediate()
EndFunction

int Function i_immediate()
EndFunction

int Function s_immediate()
EndFunction

int Function b_immediate()
EndFunction

int Function u_immediate()
EndFunction

int Function j_immediate()
EndFunction