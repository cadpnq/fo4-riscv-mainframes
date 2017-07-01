#include "f4se/PluginAPI.h"
#include "f4se_common/f4se_version.h"
#include "f4se_common/SafeWrite.h"

#include "f4se/GameMenus.h"
#include "f4se/GameData.h"
#include "f4se/GameReferences.h"
#include "f4se/GameRTTI.h"

#include <shlobj.h>

#include "riscv_decoder.h"

IDebugLog	gLog;
PluginHandle	g_pluginHandle = kPluginHandle_Invalid;

F4SEPapyrusInterface		* g_papyrus = nullptr;

extern "C"
{

bool F4SEPlugin_Query(const F4SEInterface * f4se, PluginInfo * info)
{
	gLog.OpenRelative(CSIDL_MYDOCUMENTS, "\\My Games\\Fallout4\\F4SE\\riscv_decoder.log");
	_DMESSAGE("RISC-V");

	// populate info structure
	info->infoVersion =	PluginInfo::kInfoVersion;
	info->name =		"RISC";
	info->version =		1;

	// store plugin handle so we can identify ourselves later
	g_pluginHandle = f4se->GetPluginHandle();

	if(f4se->isEditor)
	{
		_FATALERROR("loaded in editor, marking as incompatible");
		return false;
	}

	g_papyrus = (F4SEPapyrusInterface *)f4se->QueryInterface(kInterface_Papyrus);
	if(!g_papyrus)
	{
		_WARNING("couldn't get papyrus interface");
	}

	// supported runtime version
	return true;
}

bool RegisterFuncs(VirtualMachine * vm)
{	
	riscv_decoder::RegisterFuncs(vm);
	return true;
}

bool F4SEPlugin_Load(const F4SEInterface * f4se)
{
	if (g_papyrus)
		g_papyrus->Register(RegisterFuncs);
	return true;
}
};