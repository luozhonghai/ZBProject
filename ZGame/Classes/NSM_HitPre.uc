class NSM_HitPre extends ZBSpecialMove;

var() ZombiePawn.AnimationParaConfig		AnimCfg_HitPre;

function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);

	//	PawnOwner.Mesh.RootMotionMode = RMM_Ignore;
	if (PawnOwner.health > 0)
	{
		PawnOwner.PlayConfigAnim(AnimCfg_HitPre);
	}
}


function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);

	if (PawnOwner.health > 0)
	{
		PawnOwner.StopConfigAnim(AnimCfg_HitPre, 0);
	}
}


DefaultProperties
{
	AnimCfg_HitPre=(AnimationNames=("zombie01-movefast"),PlayRate=2.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=true)

}
