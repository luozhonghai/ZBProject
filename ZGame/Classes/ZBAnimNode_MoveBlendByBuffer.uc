class ZBAnimNode_MoveBlendByBuffer extends UDKAnimBlendBase;

// Body...
var ZombieRushPawn ZP;
var ZombieRushPC ZPC;
event OnBecomeRelevant()
{
	//  SetPosition(0.0,false);
	//PlayAnim(bLooping,Rate,0.0);
	ZP = ZombieRushPawn(SkelComponent.Owner);
	
}



event TickAnim(Float DeltaSeconds)
{
	if (ZP!=none)
	{
		ZPC = ZombieRushPC(ZP.Controller);
		if(ZPC != none)
		{
			if(ZPC.EntityBuffer.bActive == true && VSize(ZP.Velocity)>0)
			{
				SetActiveChild(1,0.1);
			}
			else
			{
				SetActiveChild(0,0.1);
			}
		}
	}
}
defaultproperties
{	
	bTickAnimInScript=true
	bCallScriptEventOnBecomeRelevant=true
}