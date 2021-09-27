Scriptname DevourmentPseudoAI extends ActiveMagicEffect
import Logging


Actor property PlayerRef auto
DevourmentManager property Manager auto
Keyword property BeingSwallowed auto
MagicEffect property DontSwallowMe auto
Spell property VoreSpell auto
Spell property Diminution auto
Spell property BellyPortSpell auto


float property SwallowRange = 225.0 autoReadOnly
float property CombatInterval = 5.0 autoReadOnly


String PREFIX = "DevourmentPseudoAI"
String predName
Actor Pred
bool DEBUGGING = false
bool bleedoutVore
float reach


Event OnEffectStart(Actor akTarget, Actor akCaster)
{ Checks the combat state and which types of Noms are allowed. }

	if !AssertNotNone(PREFIX, "OnEffectStart", "akTarget", akTarget)
		Dispel()
		return
	endIf

	pred = akTarget
	predName = Namer(pred, true)
	reach = SwallowRange + pred.GetLength()
	bleedoutVore = !Game.IsPluginInstalled("SexLabDefeat.esp")

	if Manager.validPredator(pred)
		RegisterForSingleUpdate(CombatInterval)
		RegisterForAnimationEvent(pred, "HitFrame")
		RegisterForActorAction(0)
	endIf
EndEvent


Event OnEffectFinish(Actor akTarget, Actor akCaster)
	UnregisterForAnimationEvent(pred, "HitFrame")
	UnregisterForActorAction(0)
EndEvent 


Event OnCombatStateChanged(Actor newTarget, int aeCombatState)
	if DEBUGGING
		Log3(PREFIX, "OnCombatStateChanged", predName, aeCombatState, Namer(newTarget))
	endIf
EndEvent


Event onLoad()
{ When a pred is loaded, refresh their state. }

	if DEBUGGING
		Log1(PREFIX, "onLoad", predName)
	endIf

EndEvent


Event OnUpdate()
	Actor prey = pred.GetCombatTarget()

	if combatCheck(prey, pred.getCombatState())
		if DEBUGGING
			Log1(PREFIX, "OnUpdate", predName)
		endIf
		DoANom(prey)
	endIf

	registerForSingleUpdate(CombatInterval)
EndEvent


Event OnActorAction(int actionType, Actor akActor, Form source, int slot)
	Actor prey = pred.GetCombatTarget()

	if combatCheck(prey, pred.getCombatState())
		if DEBUGGING
			Log1(PREFIX, "OnActorAction", predName)
		endIf
		DoANom(prey)
	endIf

	registerForSingleUpdate(CombatInterval)
EndEvent


Event OnAnimationEvent(ObjectReference akSource, string asEventName)
	Actor prey = pred.GetCombatTarget()

	if combatCheck(prey, pred.getCombatState())
		if DEBUGGING
			Log1(PREFIX, "OnAnimationEvent", predName)
		endIf
		DoANom(prey)
	endIf

	registerForSingleUpdate(CombatInterval)
EndEvent


bool Function combatCheck(Actor newTarget, int combatState)
	if combatState == 0 || newTarget == none || pred == none
		return false

	elseif combatState > 0 && newTarget && PlayerCheck(newTarget) && Manager.IsValidDigestion(pred, newTarget)

		if DEBUGGING
			Log4(PREFIX, "combatCheck", "PASSED", predName, combatState, Namer(newTarget))
		endIf
		return true
	else 
		if DEBUGGING
			Log4(PREFIX, "combatCheck", "FAILED", predName, combatState, Namer(newTarget))
		endIf
		return false
	endIf
endFunction	


Function DoANom(Actor prey)
{ 
	Don't swallow anyone who is already being swallowed or too far away. If the prey is uninjured and higher level, don't swallow. 
	Print out appropriate debugging messages.
}

	if !prey 
		if DEBUGGING
			Log1(PREFIX, "DoANom_Combat", "No prey")
		endIf

	elseif prey.getLevel() > pred.getLevel() && prey.getAVPercentage("Health") > 0.50
		if DEBUGGING
			Log2(PREFIX, "DoANom_Combat", "Too high level and not damaged enough", Namer(prey))
		endIf

	elseif !bleedoutVore && prey.IsBleedingOut()
		if DEBUGGING
			Log1(PREFIX, "DoANom_Combat", "Bleeding out and BleedoutVore is disabled.")
		endIf

	elseif pred.getDistance(prey) > reach
		if DEBUGGING
			Log4(PREFIX, "DoANom_Combat", "Too far", Namer(prey), pred.getDistance(prey), reach)
		endIf

		if pred.GetActorValue("Conjuration") > 50.0
			BellyPortSpell.Cast(pred, prey)
		elseif pred.GetActorValue("Alteration") > 50.0
			Diminution.Cast(pred, prey)
		endIf

	elseif prey.hasMagicEffectWithKeyword(BeingSwallowed)
		if DEBUGGING
			Log2(PREFIX, "DoANom_Combat", "Already being swallowed", Namer(prey))
		endIf

	elseif Manager.GetFullnessWith(pred, prey) > 1.5
		if DEBUGGING
			Log1(PREFIX, "DoANom_Combat", "Too full")
		endIf

	elseif !PlayerCheck(prey)
		if DEBUGGING
			Log1(PREFIX, "DoANom_Combat", "Failed PlayerCheck")
		endIf

	else
		VoreSpell.cast(pred, prey)
		ConsoleUtil.PrintMessage(predName + " is trying to nom " + Namer(prey, true) + "!")
		if DEBUGGING
			Log3(PREFIX, "DoANom_Combat", predName, Namer(prey, true), "Nomming")
		endIf
	endIf
EndFunction


bool Function PlayerCheck(Actor target)
	if target == PlayerRef
		return Manager.playerPreference != 1
	else
		return Manager.playerPreference != 2
	endIf
EndFunction
