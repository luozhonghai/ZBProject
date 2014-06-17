class ZSM_Gun_Reload extends ZBSpecialMove;

var() ZombiePawn.AnimationParaConfig		AnimCfg_Animation;

function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);
	PawnOwner.PlayConfigAnim(AnimCfg_Animation);
}
function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);
	PCOwner.gotoState('PlayerRush');
	ZombieRushPawn(PawnOwner).AmmoNum[ZombieRushPawn(PawnOwner).CurrentWeaponType] += 10;
}

defaultproperties
{
	AnimCfg_Animation=(AnimationNames=("zhujue-Reload"),BlendInTime=0.05,BlendOutTime=0.05,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[2]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
	bDisableMovement=True
}