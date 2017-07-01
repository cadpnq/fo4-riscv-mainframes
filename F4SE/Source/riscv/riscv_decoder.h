#pragma once

#include "f4se/GameTypes.h"

struct StaticFunctionTag;
class VirtualMachine;

namespace riscv_decoder 
{
	void RegisterFuncs(VirtualMachine* vm);
}
