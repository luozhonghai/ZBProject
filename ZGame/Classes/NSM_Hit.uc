class NSM_Hit extends ZBSpecialMove;


var() ZombiePawn.AnimationParaConfig		AnimCfg_Hit;

var() ZombiePawn.AnimationParaConfig		AnimCfg_Hit_Leg;

function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);

//	PawnOwner.Mesh.RootMotionMode = RMM_Ignore;
	if (PawnOwner.health > 0)
	{
		PawnOwner.PlayConfigAnim(AnimCfg_Hit);
	}
}

function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);

	if (PawnOwner.health > 0)
	{
	//	PawnOwner.StopConfigAnim(AnimCfg_Hit, 0);
	}
}

event tickspecial(float deltaTime)
{

//	EatEndDelay+=deltaTime;

	if (ZombieControllerBase(PawnOwner.Controller).globalPlayerController.InteractZombie!=none
		&&PawnOwner != ZombieControllerBase(PawnOwner.Controller).globalPlayerController.InteractZombie)
	{
		PawnOwner.EndSpecialMove();

	}
}

DefaultProperties
{
	//zombie01-zhua   zombie-baotui
	AnimCfg_Hit=(AnimationNames=("zombie01-zhua"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=true)
	
	AnimCfg_Hit_Leg=(AnimationNames=("zombie-baotui"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=true)
}
