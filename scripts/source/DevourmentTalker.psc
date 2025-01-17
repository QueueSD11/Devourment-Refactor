ScriptName DevourmentTalker extends ObjectReference conditional
import Logging


DevourmentManager property Manager auto
Actor property PlayerRef auto
Actor property target auto
ObjectReference property HerStomach auto


String PREFIX = "DevourmentTalker"


Function ClearPrompt()
	Self.Disable()
	Self.MoveTo(Manager.HerStomach)
EndFunction


Function PrepareForDialog(Actor ktarget)
	if ktarget
		target = ktarget
		self.SetDisplayName(Namer(ktarget, true))
	else
		self.setDisplayName("")
	endIf

	self.MoveTo(PlayerRef)
	self.Enable()
	float angle = PlayerRef.GetAngleZ()
	float px = PlayerRef.GetPositionX() + Math.sin(angle) * 20.0
	float py = PlayerRef.GetPositionY() + Math.cos(angle) * 20.0
	float pz = PlayerRef.GetPositionZ() + 20.0
EndFunction


Function ShowPrompt(Topic dial, float timeout = -1.0)
	if self.IsEnabled()
		ClearPrompt()
	endIf

	Enable()
	MoveTo(playerRef)
	
	if timeout > 0.0
		RegisterForSingleUpdate(timeout)
	endIf

	Say(dial)
EndFunction


Event OnUpdate()
	ClearPrompt()
EndEvent
