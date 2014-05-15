class ZSM_GetHurt extends ZBSpecialMove;

var() ZombiePawn.AnimationParaConfig		AnimCfg_Hurt;

var() ZombiePawn.AnimationParaConfig		AnimCfg_Die;

var() ZombiePawn.AnimationParaConfig		AnimCfg_CollideCheval;

function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);

	if (ZombiePlayerPawn(PawnOwner).GetCustomHealth() > 0)
	{
		PawnOwner.PlayConfigAnim(AnimCfg_Hurt);
	}
	
	else
	{
		if(InSpecialMoveFlags == 1)
			PawnOwner.PlayConfigAnim(AnimCfg_CollideCheval);
		else
	    	PawnOwner.PlayConfigAnim(AnimCfg_Die);
	    if( PCOwner.InteractZombie==none)
          ZombieRushGame(PawnOwner.WorldInfo.Game).PawnDied();
	  }

}

function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);

	if (ZombiePlayerPawn(PawnOwner).GetCustomHealth() <= 0 && PCOwner.InteractZombie==none)
	{
      ZombieRushGame(PawnOwner.WorldInfo.Game).PawnDied();
	}
}

function bool CanChainMove(ESpecialMove NextMove)
{
	return FALSE;
}
DefaultProperties
{

//	AnimCfg_Hurt=(AnimationNames=("HD_heidi_hit01"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel)

		AnimCfg_Hurt=(AnimationNames=("zhujue-zhengzha"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bloop=true)

	//AnimCfg_Die=(AnimationNames=("HD_heidi_hit02"),PlayRate=1.000000,BlendOutTime=-1,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel)

	AnimCfg_Die=(AnimationNames=("zhujue-siwang"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=false,blendintime=0.0,blendouttime=-1)

	AnimCfg_CollideCheval=(AnimationNames=("zhujue-zhasi"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=false,blendintime=0.0,blendouttime=-1)

	bDisableMovement=true
	bDisableTurn=true
}