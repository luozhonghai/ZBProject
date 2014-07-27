class NSM_HitPre extends ZBSpecialMove;

var() array<ZombiePawn.AnimationParaConfig>		AnimCfg_HitPre;
var() ZombiePawn.AnimationParaConfig    AnimCfg_HitPre_Leg;
var int index;
function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);

	//	PawnOwner.Mesh.RootMotionMode = RMM_Ignore;
	if (PawnOwner.health > 0)
	{
		if(PawnOwner.ZombieType == EZT_Walk)
		{
		  index = Rand(3);
		  PawnOwner.PlayConfigAnim(AnimCfg_HitPre[index]);
		}
		else if(PawnOwner.ZombieType == EZT_Creep)
		  PawnOwner.PlayConfigAnim(AnimCfg_HitPre_Leg);
	}
}


function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);
  // loop anim should stop manually
	if (PawnOwner.health > 0)
	{
		if(PawnOwner.ZombieType == EZT_Walk)
		{
		  PawnOwner.StopConfigAnim(AnimCfg_HitPre[index], 0.2);
		}
		else if(PawnOwner.ZombieType == EZT_Creep)
		  PawnOwner.StopConfigAnim(AnimCfg_HitPre_Leg,0.2);
	}
}


DefaultProperties
{
	AnimCfg_HitPre(0)=(AnimationNames=("zombie01-movefast"),PlayRate=2.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=true)
  AnimCfg_HitPre(1)=(AnimationNames=("zombie02-move"),PlayRate=2.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=true)
	AnimCfg_HitPre(2)=(AnimationNames=("zombie03-move"),PlayRate=2.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=true)

  AnimCfg_HitPre_Leg=(AnimationNames=("zombie-paxing"),PlayRate=2.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=true)
}
