Scriptname mainframe:CPUScript extends mainframe:BaseScript
import Binlib

; Note that I'm making a choice of simple over fast. Lots of optimizations are possible.

;0110111
;lui
int OPGROUP0 = 55

;0010111
;auipc
int OPGROUP1 = 23

;1101111
;jal
int OPGROUP2 = 111

;1100111
;jalr
int OPGROUP3 = 103

;1100011
;beq, bne, blt, bge, bltu, bgeu
int OPGROUP4 = 99

;0000011
;lb, lh, lw, lbu, lhu
int OPGROUP5 = 3

;0100011
;sb, sh, sw
int OPGROUP6 = 35

;0010011
;addi, slti, sltiu, xori, ori, andi, slli, srli, srai
int OPGROUP7 = 19

;0110011
;add, sub, sll, slt, sltu, xor, srl, sra, or, and
int OPGROUP8 = 51

int BEQ
int BNE
int BLT
int BGE
int BLTU
int BGEU

int LB
int LH
int LW
int LBU
int LHU

int SB
int SH
int SW

int ADDI
int SLTI
int SLTIU
int XORI
int ORI
int ANDI
int SLLI
int SRLI_SRAI

int ADD_SUB
int SLL
int SLT
int SLTU
int XOR
int SRL_SRA
int OR
int AND

int[] Registers
int ProgramCounter
int InstructionRegister

Event OnInit()
	Registers = new int[32]
EndEvent

Function Cycle()
; fetch instruction
	InstructionRegister = ReadWord(ProgramCounter)
	
	Debug.Trace(InstructionRegister)
	int f3
	int f7
	int op = opcode()
	If (op == OPGROUP0)
; instruction LUI
		SetRegister(rd(), u_immediate())
	ElseIf (op == OPGROUP1)
; instruction AUIPC
		SetRegister(rd(), u_immediate() + ProgramCounter)
	ElseIf (op == OPGROUP2)
; instruction JAL
		SetRegister(rd(), ProgramCounter + 4)
		ProgramCounter += j_immediate()
		Return
	ElseIf (op == OPGROUP3)
; instruction JALR
		SetRegister(rd(), ProgramCounter + 4)
		ProgramCounter = i_immediate() + rs1()
		Return
	ElseIf (op == OPGROUP4)
		f3 = funct3()
; instruction BEQ
		If (f3 == BEQ)
			If (Registers[rs1()] == Registers[rs2()])
				ProgramCounter += b_immediate()
				Return
			EndIf
; instruction BNE
		ElseIf (f3 == BNE)
			If (Registers[rs1()] != Registers[rs2()])
				ProgramCounter += b_immediate()
				Return
			EndIf
; instruction BLT
		ElseIf (f3 == BLT)
			If (Registers[rs1()] < Registers[rs2()])
				ProgramCounter += b_immediate()
				Return
			EndIf
; instruction BGE
		ElseIf (f3 == BGE)
			If (Registers[rs1()] >= Registers[rs2()])
				ProgramCounter += b_immediate()
				Return
			EndIf
; unsigned branches not currently implemented
; instruction BLTU
		ElseIf (f3 == BLTU)
			Return
; instruction BGEU
		ElseIf (f3 == BGEU)
			Return
		EndIf
	ElseIf (op == OPGROUP5)
		f3 = funct3()
; instruction LB
		If (f3 == LB)
			SetRegister(rd(), Read(rs1() + i_immediate()))
; instruction LH
		ElseIf (f3 == LH)
			SetRegister(rd(), ReadHalfword(rs1() + i_immediate()))
; instruction LW
		ElseIf (f3 == LW)
			SetRegister(rd(), ReadWord(rs1() + i_immediate()))
; instruction LBU
		ElseIf (f3 == LBU)
; instruction LHU
		ElseIf (f3 == LHU)
		EndIf
	ElseIf (op == OPGROUP6)
		f3 = funct3()
; instruction SB
		If (f3 == SB)
			Write(rs1() + s_immediate(), rs2())
; instruction SH
		ElseIf (f3 == SH)
			WriteHalfword(rs1() + s_immediate(), rs2())
; instruction SW
		ElseIf (f3 == SW)
			WriteWord(rs1() + s_immediate(), rs2())
		EndIf
	ElseIf (op == OPGROUP7)
		f3 = funct3()
; instruction ADDI
		If (f3 == ADDI)
			SetRegister(rd(), rs1() + i_immediate())
; instruction SLTI
		ElseIf (f3 == SLTI)
; instruction SLTIU
		ElseIf (f3 == SLTIU)
; instruction XORI
		ElseIf (f3 == XORI)
			SetRegister(rd(), Binlib.BitwiseXOR(rs1(), i_immediate()))
; instruction ORI
		ElseIf (f3 == ORI)
			SetRegister(rd(), Binlib.BitwiseOR(rs1(), i_immediate()))
; instruction ANDI
		ElseIf (f3 == ANDI)
			SetRegister(rd(), Binlib.BitwiseAND(rs1(), i_immediate()))
; instruction SLLI
		ElseIf (f3 == SLLI)
		ElseIf (f3 == SRLI_SRAI)
; instruction SRLI
; instruction SRAI
		EndIF
	ElseIf (op == OPGROUP8)
		f3 = funct3()
		If (f3 == ADD_SUB)
; instruction ADD
; instruction SUB
; instruction SLL
		ElseIf (f3 == SLL)
; instruction SLT
		ElseIf (f3 == SLT)
			If (rs1() < rs2())
				SetRegister(rd(), 1)
			Else
				SetRegister(rd(), 0)
			EndIf
; instruction SLTU
		ElseIf (f3 == SLTU)
; instruction XOR
		ElseIf (f3 == XOR)
			SetRegister(rd(), Binlib.BitwiseXOR(rs1(), rs2()))
		ElseIf (f3 == SRL_SRA)
; instruction SRL
; instruction SRA
; instruction OR
		ElseIf (f3 == OR)
			SetRegister(rd(), Binlib.BitwiseOR(rs1(), rs2()))
; instruction AND
		ElseIf (f3 == AND)
			SetRegister(rd(), Binlib.BitwiseAND(rs1(), rs2()))
		EndIf
	EndIf

; increment ProgramCounter
	ProgramCounter += 4
EndFunction

; setting a register gets its own function so we can catch any attempt at
; changing the value of register 0 which must always remain 0
Function SetRegister(int register, int value)
	If(register == 0)
		Return
	EndIf
	Registers[register] = value
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

int Function ReadHalfword(int address)
	Return Binlib.BitwiseOR(Read(address), Binlib.LeftShift(Read(address + 1), 8))
EndFunction

Function WriteHalfword(int address, int value)
EndFunction

int Function ReadWord(int address)
	Return Binlib.BitwiseOR(ReadHalfword(address), Binlib.LeftShift(ReadHalfword(address + 2), 16))
EndFunction

Function WriteWord(int address, int value)
EndFunction

; Decoding functions
int Function opcode()
EndFunction

int Function rd()
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