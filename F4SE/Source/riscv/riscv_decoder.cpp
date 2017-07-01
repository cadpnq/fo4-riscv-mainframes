#include "riscv_decoder.h"

#include "f4se/PapyrusVM.h"
#include "f4se/PapyrusNativeFunctions.h"

#include <math.h>

#define MASK(width) ((unsigned int) -1) >> (32 - width)
#define DECODE(value, width, start) ((MASK(width) << start) & value) >> start

int b_mask[] = {-1, 8, 9, 10, 11, 25, 26, 27, 28, 29, 30, 7, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31};
int i_mask[] = {20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31};
int j_mask[] = {-1, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 20, 12, 13, 14, 15, 16, 17, 18, 19, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31};
int s_mask[] = {7, 8, 9, 10, 11, 25, 26, 27, 28, 29, 30, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31};
int u_mask[] = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31};

UInt32 decode(UInt32 instruction, int mask[])
{
	UInt32 value = 0;

	for (int i = 0; i <= 32; i++) {
		if (mask[i] == -1) 
			continue;
		if ((instruction >> mask[i]) & 1)
			value |= 1 << mask[i];
	}

	return value;
}

namespace riscv_decoder
{
	UInt32 opcode(StaticFunctionTag* base, UInt32 arg1)
	{
		return DECODE(arg1, 7, 0);
	}

	UInt32 rd(StaticFunctionTag* base, UInt32 arg1)
	{
		return DECODE(arg1, 5, 7);
	}

	UInt32 func3(StaticFunctionTag* base, UInt32 arg1)
	{
		return DECODE(arg1, 3, 12);
	}

	UInt32 rs1(StaticFunctionTag* base, UInt32 arg1)
	{
		return DECODE(arg1, 5, 15);
	}

	UInt32 rs2(StaticFunctionTag* base, UInt32 arg1)
	{
		return DECODE(arg1, 5, 20);
	}

	UInt32 func7(StaticFunctionTag* base, UInt32 arg1)
	{
		return DECODE(arg1, 7, 25);
	}

	UInt32 b_immediate(StaticFunctionTag* base, UInt32 arg1)
	{
		return decode(arg1, b_mask);
	}

	UInt32 i_immediate(StaticFunctionTag* base, UInt32 arg1)
	{
		return decode(arg1, i_mask);
	}

	UInt32 j_immediate(StaticFunctionTag* base, UInt32 arg1)
	{
		return decode(arg1, j_mask);
	}

	UInt32 s_immediate(StaticFunctionTag* base, UInt32 arg1)
	{
		return decode(arg1, s_mask);
	}

	UInt32 u_immediate(StaticFunctionTag* base, UInt32 arg1)
	{
		return decode(arg1, u_mask);
	}
}

void riscv_decoder::RegisterFuncs(VirtualMachine* vm)
{
	vm->RegisterFunction(
		new NativeFunction1 <StaticFunctionTag, UInt32, UInt32>("opcode", "RISCV", riscv_decoder::opcode, vm));

	vm->RegisterFunction(
		new NativeFunction1 <StaticFunctionTag, UInt32, UInt32>("rd", "RISCV", riscv_decoder::rd, vm));

	vm->RegisterFunction(
		new NativeFunction1 <StaticFunctionTag, UInt32, UInt32>("func3", "RISCV", riscv_decoder::func3, vm));

	vm->RegisterFunction(
		new NativeFunction1 <StaticFunctionTag, UInt32, UInt32>("rs1", "RISCV", riscv_decoder::rs1, vm));

	vm->RegisterFunction(
		new NativeFunction1 <StaticFunctionTag, UInt32, UInt32>("rs2", "RISCV", riscv_decoder::rs2, vm));

	vm->RegisterFunction(
		new NativeFunction1 <StaticFunctionTag, UInt32, UInt32>("func7", "RISCV", riscv_decoder::func7, vm));


	vm->RegisterFunction(
		new NativeFunction1 <StaticFunctionTag, UInt32, UInt32>("b_immediate", "RISCV", riscv_decoder::b_immediate, vm));

	vm->RegisterFunction(
		new NativeFunction1 <StaticFunctionTag, UInt32, UInt32>("i_immediate", "RISCV", riscv_decoder::i_immediate, vm));

	vm->RegisterFunction(
		new NativeFunction1 <StaticFunctionTag, UInt32, UInt32>("j_immediate", "RISCV", riscv_decoder::j_immediate, vm));

	vm->RegisterFunction(
		new NativeFunction1 <StaticFunctionTag, UInt32, UInt32>("s_immediate", "RISCV", riscv_decoder::s_immediate, vm));

	vm->RegisterFunction(
		new NativeFunction1 <StaticFunctionTag, UInt32, UInt32>("u_immediate", "RISCV", riscv_decoder::u_immediate, vm));


	vm->SetFunctionFlags("RISCV", "opcode", IFunction::kFunctionFlag_NoWait);
	vm->SetFunctionFlags("RISCV", "rd", IFunction::kFunctionFlag_NoWait);
	vm->SetFunctionFlags("RISCV", "func3", IFunction::kFunctionFlag_NoWait);
	vm->SetFunctionFlags("RISCV", "rs1", IFunction::kFunctionFlag_NoWait);
	vm->SetFunctionFlags("RISCV", "rs2", IFunction::kFunctionFlag_NoWait);
	vm->SetFunctionFlags("RISCV", "func7", IFunction::kFunctionFlag_NoWait);

	vm->SetFunctionFlags("RISCV", "b_immediate", IFunction::kFunctionFlag_NoWait);
	vm->SetFunctionFlags("RISCV", "i_immediate", IFunction::kFunctionFlag_NoWait);
	vm->SetFunctionFlags("RISCV", "j_immediate", IFunction::kFunctionFlag_NoWait);
	vm->SetFunctionFlags("RISCV", "s_immediate", IFunction::kFunctionFlag_NoWait);
	vm->SetFunctionFlags("RISCV", "u_immediate", IFunction::kFunctionFlag_NoWait);
}
