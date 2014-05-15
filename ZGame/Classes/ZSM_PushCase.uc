class ZSM_PushCase extends ZBSpecialMove;

var() ZombiePawn.AnimationParaConfig		AnimCfg_PushCase;
var() float PushSpeed,PushDelay;
var float PreviousGroundSpeed,PushStartDelay;

function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);

//	PawnOwner.setphysics(PHYS_Custom);
	if (PawnOwner.health > 0)
	{
		PawnOwner.PlayConfigAnim(AnimCfg_PushCase);
		PreviousGroundSpeed = PawnOwner.GroundSpeed;
        PawnOwner.GroundSpeed = PushSpeed;

		PushStartDelay =  0.0;
	}
}

function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);
	PawnOwner.Acceleration = vect(0,0,0);
	PawnOwner.StopConfigAnim(AnimCfg_PushCase, 0.1);
	//PawnOwner.setphysics(PHYS_Walking);
	PawnOwner.GroundSpeed = PreviousGroundSpeed;
}
event tickspecial(float deltaTime)
{
 //   PawnOwner.move(PawnOwner.Velocity*deltaTime);

	PushStartDelay+=deltaTime;
	if(PushStartDelay >= PushDelay)
	{
		if(!ZombiePlayerPawn(PawnOwner).TraceCaseBlocked())
	     PawnOwner.Acceleration = 2048*vector(PawnOwner.rotation);
	}
}
DefaultProperties
{
	AnimCfg_PushCase=(AnimationNames=("zhujue_tuixiangzi"),PlayRate=1.000000,bCauseActorAnimEnd=True,bTriggerFakeRootMotion=True,FakeRootMotionMode=RMM_Accel,bLoop=true,blendintime=0.0,blendouttime=0.4)

		bDisableMovement=true
		bDisableTurn=true

		PushSpeed = 60
		PushDelay =  0.5
}
