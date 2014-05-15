class ZSM_GunFire extends ZBSpecialMove;


var() ZombiePawn.AnimationParaConfig		AnimCfg_Animation;


var() float PreFireTime;
var float FireDelay;
var bool bFirTimer;
function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	local rotator newRot;
	Super.SpecialMoveStarted(bForced, PrevMove);
	
	if(PCOwner.AvailableShootZombie!=none){
		 newRot = rotator(PCOwner.AvailableShootZombie.location - PawnOwner.location);
         PawnOwner.setrotation(newRot);
	}

	PawnOwner.PlayConfigAnim(AnimCfg_Animation);
	PCOwner.gotoState('PlayerAttacking');
	//bFirTimer=true;

	//PawnOwner.SoundGroupClass.static.PlayATKSoundOne(PawnOwner);

}
function PlayFire()
{
	ZBWeaponGun(PawnOwner.weapon).ProjectileFire();
}
function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);
	PawnOwner.weapon.ClearPendingFire( 0 );
	PawnOwner.weapon.GotoState('Active');
	if(PCOwner.InteractZombie==none)
		PCOwner.gotoState(PCOwner.NormalStateName);
}

event tickspecial(float deltaTime)
{
	if (bFirTimer)
	{
		FireDelay+=deltaTime;

		if (FireDelay>PreFireTime)
		{
			bFirTimer=false;
			FireDelay=0;
            PlayFire();
		}
	}
}
DefaultProperties
{
	AnimCfg_Animation=(AnimationNames=("zhujue-shoot"),BlendInTime=0.05,BlendOutTime=0.05,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[2]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
	bDisableMovement=True
	UseCustomRMM=True
	RMMInAction=RMM_Translate
	bDisableTurn=true
	 PreFireTime=0.2
}
