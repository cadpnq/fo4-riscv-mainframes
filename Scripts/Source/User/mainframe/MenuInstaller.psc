; This file is based on DarthWane's CustomCategoriesInstallerScript
ScriptName mainframe:MenuInstaller Extends Quest

FormList Property InstallTarget Auto Const
FormList Property Menu Auto Const

Event OnQuestInit()
	RegisterForRemoteEvent(Game.GetPlayer(), "OnPlayerLoadGame")
	Install()
	SafetyLoop()
EndEvent

Event Actor.OnPlayerLoadGame(Actor ActorRef)
	If (Game.IsPluginInstalled("RISCV_Mainframes.esp"))
		Install()
	Else
    ; TODO: make this warning more serious
		Debug.MessageBox("You did not uninstall the RVM menu category.")
		UnregisterForAllEvents()
	EndIf
EndEvent

Function Install()
	InstallTarget.AddForm(Menu)
EndFunction

Function Uninstall()
	InstallTarget.RemoveAddedForm(Menu)
EndFunction

; this will make the script stick around even if the mod is uninstalled
Function SafetyLoop()
	While (Game.IsPluginInstalled("RISCV_Mainframes.esp"))
		Utility.Wait(60)
	EndWhile
EndFunction
