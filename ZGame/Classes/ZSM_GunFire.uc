class ZSM_GunFire extends ZBSpecialMove;


var() ZombiePawn.AnimationParaConfig		AnimCfg_Animation;

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
	{
		if(ZombieRushPawn(PawnOwner).TotalAmmo > 0 
			&& ZombieRushPawn(PawnOwner).AmmoNum[ZombieRushPawn(PawnOwner).CurrentWeaponType] == 0)
		  PawnOwner.DoSpecialmove(SM_Gun_Reload,true);
		else
			PCOwner.gotoState(PCOwner.NormalStateName);
	}
}

event tickspecial(float deltaTime)
{
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
