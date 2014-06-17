class ZSM_RunIntoWall extends ZBSpecialMove;

var() ZombiePawn.AnimationParaConfig		AnimCfg_Animation;

var() CameraShake HitWallShake;
function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);
	if(PCOwner.PlayerCamera != none)
	  PCOwner.PlayerCamera.PlayCameraShake(HitWallShake,10.0);
	PawnOwner.PlayConfigAnim(AnimCfg_Animation);
}
function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);
	PCOwner.gotoState('PlayerRush');
}

defaultproperties
{
	AnimCfg_Animation=(AnimationNames=("zhujue- runintowall"),BlendInTime=0.05,BlendOutTime=0.05,PlayRate=1.500000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[2]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
	bDisableMovement=True
	HitWallShake=CameraShake'Zombie_Archetype.Camera.Shake_RuntoWall'
}