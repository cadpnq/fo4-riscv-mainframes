Scriptname mainframe:CPUScript extends mainframe:BaseScript
import Binlib

; Note that I'm making a choice of simple over fast. Lots of optimizations are possible.

int[] Property I_MASK Auto
int[] Property S_MASK Auto
int[] Property B_MASK Auto
int[] Property U_MASK Auto
int[] Property J_MASK Auto

int[] Property OPCODE_MASK Auto
int[] Property RD_MASK Auto
int[] Property RS1_MASK Auto
int[] Property RS2_MASK Auto
int[] Property FUNCT3_MASK Auto
int[] Property FUNCT7_MASK Auto

int OPGROUP0 = 55 ;0110111
;lui

int OPGROUP1 = 23 ;0010111
;auipc

int OPGROUP2 = 111 ;1101111
;jal

int OPGROUP3 = 103 ;1100111
;jalr

int OPGROUP4 = 99 ;1100011
;beq, bne, blt, bge, bltu, bgeu

int OPGROUP5 = 3 ;0000011
;lb, lh, lw, lbu, lhu

int OPGROUP6 = 35 ;0100011
;sb, sh, sw

int OPGROUP7 = 19 ;0010011
;addi, slti, sltiu, xori, ori, andi, slli, srli, srai

int OPGROUP8 = 51 ;0110011
;add, sub, sll, slt, sltu, xor, srl, sra, or, and

int BEQ = 0 ;000
int BNE = 1 ;001
int BLT = 4 ;100
int BGE = 5 ;101
int BLTU = 6 ;110
int BGEU = 7 ;111

int LB = 0 ;000
int LH = 1 ;001
int LW = 2 ;010
int LBU = 4 ;100
int LHU = 5 ;101

int SB = 0 ;000
int SH = 1 ;001
int SW = 2 ;010

int ADDI = 0 ;000
int SLTI = 2 ; 010
int SLTIU = 3 ;011
int XORI = 4 ;100
int ORI = 6 ;110
int ANDI = 7 ;111
int SLLI = 1 ;001
int SRLI_SRAI = 5 ;101
int SRLI = 0 ;0000000
int SRAI = 32 ;0100000

int ADD_SUB = 0 ;000
int ADD = 0 ;0000000
int SUB = 32 ;0100000
int SLL = 1 ;001
int SLT = 2 ;010
int SLTU = 3 ;011
int XOR = 4 ;100
int SRL_SRA = 5 ;101
int SRL = 0 ;0000000
int SRA = 32 ;0100000
int OR = 6 ;110
int AND = 7 ;111

int[] Registers
int ProgramCounter
int InstructionRegister
bool[] AInstructionRegister

Event OnInit()
	Registers = new int[32]
EndEvent

Function Cycle()
; fetch instruction
	InstructionRegister = ReadWord(ProgramCounter)
	AInstructionRegister = IntToArray(InstructionRegister)
	
;	Debug.Trace("instruction is: " + InstructionRegister)
;	Debug.Trace("opcode is: " + opcode())
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
		ProgramCounter = i_immediate() + Registers[rs1()]
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
			SetRegister(rd(), ExtendByte(Read(Registers[rs1()] + i_immediate())))
; instruction LH
		ElseIf (f3 == LH)
			SetRegister(rd(), ExtendHalfword(ReadHalfword(Registers[rs1()] + i_immediate())))
; instruction LW
		ElseIf (f3 == LW)
			SetRegister(rd(), ReadWord(Registers[rs1()] + i_immediate()))
; instruction LBU
		ElseIf (f3 == LBU)
			SetRegister(rd(), Read(Registers[rs1()] + i_immediate()))
; instruction LHU
		ElseIf (f3 == LHU)
			SetRegister(rd(), ReadHalfword(Registers[rs1()] + i_immediate()))
		EndIf
	ElseIf (op == OPGROUP6)
		f3 = funct3()
; instruction SB
		If (f3 == SB)
			Write(Registers[rs1()] + s_immediate(), Registers[rs2()])
; instruction SH
		ElseIf (f3 == SH)
			WriteHalfword(Registers[rs1()] + s_immediate(), Registers[rs2()])
; instruction SW
		ElseIf (f3 == SW)
			WriteWord(Registers[rs1()] + s_immediate(), Registers[rs2()])
		EndIf
	ElseIf (op == OPGROUP7)
		f3 = funct3()
; instruction ADDI
		If (f3 == ADDI)
			SetRegister(rd(), Registers[rs1()] + i_immediate())
; instruction SLTI
		ElseIf (f3 == SLTI)
; instruction SLTIU
		ElseIf (f3 == SLTIU)
; instruction XORI
		ElseIf (f3 == XORI)
			SetRegister(rd(), BitwiseXOR(Registers[rs1()], i_immediate()))
; instruction ORI
		ElseIf (f3 == ORI)
			SetRegister(rd(), BitwiseOR(Registers[rs1()], i_immediate()))
; instruction ANDI
		ElseIf (f3 == ANDI)
			SetRegister(rd(), BitwiseAND(Registers[rs1()], i_immediate()))
; instruction SLLI
		ElseIf (f3 == SLLI)
		ElseIf (f3 == SRLI_SRAI)
; instruction SRLI
; instruction SRAI
		EndIF
	ElseIf (op == OPGROUP8)
		f3 = funct3()
		If (f3 == ADD_SUB)
			f7 = funct7()
; instruction ADD
			If (f7 == ADD)
				SetRegister(rd(), Registers[rs1()] + Registers[rs2()])
; instruction SUB
			ElseIf (f7 == SUB)
				SetRegister(rd(), Registers[rs1()] - Registers[rs2()])
			EndIf
; instruction SLL
		ElseIf (f3 == SLL)
; instruction SLT
		ElseIf (f3 == SLT)
			If (Registers[rs1()] < Registers[rs2()])
				SetRegister(rd(), 1)
			Else
				SetRegister(rd(), 0)
			EndIf
; instruction SLTU
		ElseIf (f3 == SLTU)
; instruction XOR
		ElseIf (f3 == XOR)
			SetRegister(rd(), BitwiseXOR(Registers[rs1()], Registers[rs2()]))
		ElseIf (f3 == SRL_SRA)
; instruction SRL
; instruction SRA
; instruction OR
		ElseIf (f3 == OR)
			SetRegister(rd(), BitwiseOR(Registers[rs1()], Registers[rs2()]))
; instruction AND
		ElseIf (f3 == AND)
			SetRegister(rd(), BitwiseAND(Registers[rs1()], Registers[rs2()]))
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
	Return BitwiseOR(Read(address), LeftShift(Read(address + 1), 8))
EndFunction

Function WriteHalfword(int address, int value)
	Write(address, BitwiseAND(value, 255))
	Write(address + 1, BitwiseAND(RightShift(value, 255), 8))
EndFunction

int Function ReadWord(int address)
	Return BitwiseOR(ReadHalfword(address), LeftShift(ReadHalfword(address + 2), 16))
EndFunction

Function WriteWord(int address, int value)
	WriteHalfword(address, BitwiseAND(value, 65535))
	WriteHalfword(address + 2, BitwiseAND(RightShift(value, 16), 65535))
EndFunction

int Function ExtendByte(int value)
	If (GetBit(value, 7))
		Return BitwiseOR(value, -256)
	Else
		Return value
	EndIf
EndFunction

int Function ExtendHalfword(int value)
	If (GetBit(value, 15))
		Return BitwiseOR(value, -65536)
	Else
		Return Value
	EndIf
EndFunction

; Decoding functions
int Function decode(int[] mask)
	bool[] ret = new bool[32]
	
	int i = 0
	While (i < mask.Length)
		If (mask[i] >= 0)
			ret[i] = AInstructionRegister[mask[i]]
		EndIf
		
		i += 1
	EndWhile
	
	Return ArrayToInt(ret)
EndFunction

int Function opcode()
; todo: test if doing it with AND and bitshifts is faster
;	Return BitwiseAND(InstructionRegister, 127)
	Return decode(OPCODE_MASK)
EndFunction

int Function rd()
;	Return decodeRightShift(BitwiseAND(InstructionRegister, 3968), 7)
	Return decode(RD_MASK)
EndFunction

int Function rs1()
	Return decode(RS1_MASK)
EndFunction

int Function rs2()
	Return decode(RS2_MASK)
EndFunction

int Function funct3()
	Return decode(FUNCT3_MASK)
EndFunction

int Function funct7()
	Return decode(FUNCT7_MASK)
EndFunction

int Function i_immediate()
	Return decode(I_MASK)
EndFunction

int Function s_immediate()
	Return decode(S_MASK)
EndFunction

int Function b_immediate()
	Return decode(B_MASK)
EndFunction

int Function u_immediate()
	Return decode(U_MASK)
EndFunction

int Function j_immediate()
	Return decode(J_MASK)
EndFunction