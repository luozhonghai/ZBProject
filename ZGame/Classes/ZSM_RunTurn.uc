class ZSM_RunTurn extends ZBSpecialMove;


var() ZombiePawn.AnimationParaConfig		AnimCfg_TurnLeft;
var() ZombiePawn.AnimationParaConfig		AnimCfg_TurnRight;
var() ZombiePawn.AnimationParaConfig    AnimCfg_TurnBack;

var() ZombiePawn.AnimationParaConfig    AnimCfg_TurnLeft_Slow;
var() ZombiePawn.AnimationParaConfig    AnimCfg_TurnRight_Slow;
var() ZombiePawn.AnimationParaConfig    AnimCfg_TurnBack_Slow;

var() ZombiePawn.AnimationParaConfig    AnimCfg_TurnLeft_Weak;
var() ZombiePawn.AnimationParaConfig    AnimCfg_TurnRight_Weak;
var() ZombiePawn.AnimationParaConfig    AnimCfg_TurnBack_Weak;

var() ZombiePawn.AnimationParaConfig    AnimCfg_TurnLeft_Injured;
var() ZombiePawn.AnimationParaConfig    AnimCfg_TurnRight_Injured;
var() ZombiePawn.AnimationParaConfig    AnimCfg_TurnBack_Injured;

var ZombiePawn.AnimationParaConfig TargetAnim;
var Rotator InitRot;
function SpecialMoveStarted(bool bForced, ESpecialMove PrevMove, optional INT InSpecialMoveFlags)
{
  local ZombiePlayerPawn ZPP;
	 Super.SpecialMoveStarted(bForced, PrevMove);
   PawnOwner.Mesh.RootMotionRotationMode = RMRM_RotateActor;
   ZPP = ZombiePlayerPawn(PawnOwner);
    if(InSpecialMoveFlags == 1)
    {
      if (ZPP.GetCustomHealth() <= 40)
        TargetAnim = AnimCfg_TurnLeft_Injured;
      
      if(ZPP.GetPower() <= 20)
        TargetAnim = AnimCfg_TurnLeft_Weak;
      else if(ZPP.GetPower() <= 60)
        TargetAnim = AnimCfg_TurnLeft_Slow;
      else
        TargetAnim = AnimCfg_TurnLeft;
    }
      
    else if(InSpecialMoveFlags == 2)
    {
      if (ZPP.GetCustomHealth() <= 40)
        TargetAnim = AnimCfg_TurnRight_Injured;
      
      if(ZPP.GetPower() <= 20)
        TargetAnim = AnimCfg_TurnRight_Weak;
      else if(ZPP.GetPower() <= 60)
        TargetAnim = AnimCfg_TurnRight_Slow;
      else
        TargetAnim = AnimCfg_TurnRight;
    }

    else if(InSpecialMoveFlags == 3)
    {
      if (ZPP.GetCustomHealth() <= 40)
        TargetAnim = AnimCfg_TurnBack_Injured;
      
      if(ZPP.GetPower() <= 20)
        TargetAnim = AnimCfg_TurnBack_Weak;
      else if(ZPP.GetPower() <= 60)
        TargetAnim = AnimCfg_TurnBack_Slow;
      else
        TargetAnim = AnimCfg_TurnBack;
    }

    
    ZPP.PlayConfigAnim(TargetAnim);
    InitRot = ZPP.Rotation;
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

    AnimCfg_TurnLeft=(AnimationNames=("actor-fastTurnleft"),BlendInTime=0.1,BlendOutTime=0.15,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[1]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
    AnimCfg_TurnRight=(AnimationNames=("actor-fastTurnrigh"),BlendInTime=0.1,BlendOutTime=0.15,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[1]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
    AnimCfg_TurnBack=(AnimationNames=("zhujue-zhuanshen"),BlendInTime=0.1,BlendOutTime=0.15,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[1]=RBA_Translate,FakeRootMotionMode=RMM_Accel)

    AnimCfg_TurnLeft_Slow=(AnimationNames=("actor-slowTurnleft"),BlendInTime=0.1,BlendOutTime=0.15,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[1]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
    AnimCfg_TurnRight_Slow=(AnimationNames=("actor-slowTurnright"),BlendInTime=0.1,BlendOutTime=0.15,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[1]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
    AnimCfg_TurnBack_Slow=(AnimationNames=("actor-slowTurnaround"),BlendInTime=0.1,BlendOutTime=0.15,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[1]=RBA_Translate,FakeRootMotionMode=RMM_Accel)

    AnimCfg_TurnLeft_Weak=(AnimationNames=("actor-weakTurnleft"),BlendInTime=0.1,BlendOutTime=0.15,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[1]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
    AnimCfg_TurnRight_Weak=(AnimationNames=("actor-weakTurnright"),BlendInTime=0.1,BlendOutTime=0.15,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[1]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
    AnimCfg_TurnBack_Weak=(AnimationNames=("actor-weakTurnaround"),BlendInTime=0.1,BlendOutTime=0.15,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[1]=RBA_Translate,FakeRootMotionMode=RMM_Accel)

    AnimCfg_TurnLeft_Injuried=(AnimationNames=("actor-InjuredTurnleft"),BlendInTime=0.1,BlendOutTime=0.15,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[1]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
    AnimCfg_TurnRight_Injuried=(AnimationNames=("actor-InjuredTurnright"),BlendInTime=0.1,BlendOutTime=0.15,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[1]=RBA_Translate,FakeRootMotionMode=RMM_Accel)
    AnimCfg_TurnBack_Injuried=(AnimationNames=("actor-InjuredTurnaround"),BlendInTime=0.1,BlendOutTime=0.15,PlayRate=1.000000,bCauseActorAnimEnd=True,RootBoneTransitionOption[0]=RBA_Translate,RootBoneTransitionOption[1]=RBA_Translate,FakeRootMotionMode=RMM_Accel)

    UseCustomRMM=True
	  RMMInAction=RMM_Accel 
}