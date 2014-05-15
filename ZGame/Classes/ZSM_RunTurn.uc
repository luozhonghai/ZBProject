class ZSM_RunTurn extends ZBSpecialMove;


var() ZombiePawn.AnimationParaConfig		AnimCfg_TurnLeft;
var() ZombiePawn.AnimationParaConfig		AnimCfg_TurnRight;
var() ZombiePawn.AnimationParaConfig    AnimCfg_TurnBack;

var Rotator InitRot;
function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
	Super.SpecialMoveStarted(bForced, PrevMove);
   PawnOwner.Mesh.RootMotionRotationMode = RMRM_RotateActor;
    if(InSpecialMoveFlags == 1)
      PawnOwner.PlayConfigAnim(AnimCfg_TurnLeft);
    else if(InSpecialMoveFlags == 2)
      PawnOwner.PlayConfigAnim(AnimCfg_TurnRight);
    else if(InSpecialMoveFlags == 3)
      PawnOwner.PlayConfigAnim(AnimCfg_TurnBack);

    InitRot = PawnOwner.Rotation;
}

event tickspecial(float deltaTime)
{
 // PawnOwner.SetRotation(InitRot + QuatToRotator(PawnOwner.Mesh.RootMotionDelta.Rotation));
}

function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);
	PawnOwner.Mesh.RootMotionRotationMode = RMRM_Ignore;
  if(!PCOwner.IsInstate('CaptureByZombie'))
     PCOwner.GotoState('PlayerRush');
  //   PawnOwner.Mesh.RootMotionRotationMode = RMRM_RotateActor;
}

DefaultProperties
{
 //   AnimCfg_TurnLeft=(AnimationNames=("run_turnleft"),BlendInTime=0.1,BlendOutTime=0.15,PlayRate=1.200000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[1]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
 //   AnimCfg_TurnRight=(AnimationNames=("run_turnright"),BlendInTime=0.1,BlendOutTime=0.15,PlayRate=1.200000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[1]=RBA_Translate,FakeRootMotionMode=RMM_Accel)

    AnimCfg_TurnLeft=(AnimationNames=("zhujue-run_left"),BlendInTime=0.1,BlendOutTime=0.15,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[1]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
    AnimCfg_TurnRight=(AnimationNames=("zhujue-run_right"),BlendInTime=0.1,BlendOutTime=0.15,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[1]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
    AnimCfg_TurnBack=(AnimationNames=("zhujue-zhuanshen"),BlendInTime=0.1,BlendOutTime=0.15,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[1]=RBA_Translate,FakeRootMotionMode=RMM_Accel)


    UseCustomRMM=True
	  RMMInAction=RMM_Accel 
}