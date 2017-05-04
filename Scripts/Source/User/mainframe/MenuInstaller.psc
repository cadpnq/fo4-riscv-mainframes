ScriptName mainframe:MenuInstaller Extends Quest

FormList Property InstallTarget Auto Const
FormList Property Menu Auto Const

Event OnQuestInit()
	RegisterForRemoteEvent(Game.GetPlayer(), "OnPlayerLoadGame")
	Install()
EndEvent

Event Actor.OnPlayerLoadGame(Actor ActorRef)
	Install()
EndEvent

Function Install()
	InstallTarget.AddForm(Menu)
EndFunction

Function Uninstall()
	InstallTarget.RemoveAddedForm(Menu)
EndFunction
