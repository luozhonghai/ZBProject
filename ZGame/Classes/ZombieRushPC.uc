class ZombieRushPC extends ZombiePC;


var Vector RushDir;

var float SwipeTraceDistance;
var float MinMoveDistance,MinTapDistance;

var Vector OrientVect[4];
var int OrientIndex,OldOrientIndex;
var Vector OldVelocity;

var float TurnIntervalTime;

var float RollDegThreshold, PitchDegThreshold;
var float 	StrafeCoeff;
var float 	StrafeMaxVel,ForwardVel;
var Vector StrafeVelocity;


var PawnCollisionSphere PawnCSphere;

//long press time for Accelerated rush
var float LongPressTime;
var bool bLongPressTimer;

//knock by Blockade
var Vector KonckVelocity;
var float KnockMag;
// move to certain location
var Vector TraversalTargetLocation;


// latent move command
var int LatentTurnCommand;

//effect caused by item like dingci
var ZBEffectBuffer EntityBuffer;


var float DefaultSpeed;

var Rotator InitRot;
function SetupZones()
{
	super.SetupZones();
	//MPI.OnMobileMotion=OnRushMobileMotion;
	EntityBuffer = Spawn(class'ZBEffectBuffer',self);
}

event Possess(Pawn aPawn, bool bVehicleTransition)
{
	super.Possess(aPawn,bVehicleTransition);
	//SetTimer(1.0,false,'R1');  
}
function TransitToActor(Actor inActor)
{
	/*
	if(inActor.Tag == '0')
	  OrientIndex = 0;
	if(inActor.Tag == '1')
	  OrientIndex = 1;
	if(inActor.Tag == '2')
	  OrientIndex = 2;
	if(inActor.Tag == '3')
	  OrientIndex = 3;*/
	 Pawn.SetRotation(inActor.Rotation);
	 ReCalcOrientVector();
	 RushDir =  OrientVect[OrientIndex];
}
//function OnRushMobileMotion(PlayerInput PInput, vector CurrentAttitude, vector CurrentRotationRate, vector CurrentGravity, vector CurrentAcceleration)
function OnRushMobileMotion(vector CurrentAttitude)
{
	local Rotator RotAttitude;
	local float CurrentRollDeg,CurrentPitchDeg,StrafeMag;
	//RotAttitude = Rotator(CurrentAttitude);
	CurrentRollDeg = CurrentAttitude.z * UnrRotToDeg ;
    CurrentPitchDeg = CurrentAttitude.x * UnrRotToDeg ;
   if(OrientIndex ==1 || OrientIndex == 3)
   {
	if(CurrentRollDeg > RollDegThreshold){
		 StrafeMag  = FMin(StrafeCoeff * (CurrentRollDeg - RollDegThreshold),StrafeMaxVel);
         StrafeVelocity = StrafeMag * OrientVect[0];
	}
	else if (CurrentRollDeg < -RollDegThreshold){
		  StrafeMag = FMin(StrafeCoeff * (-RollDegThreshold - CurrentRollDeg),StrafeMaxVel);
		  StrafeVelocity = StrafeMag * OrientVect[2];
	}
	else
		  StrafeVelocity = vect(0,0,0);
	}
	else
	{
		if(CurrentPitchDeg > PitchDegThreshold){
		 StrafeMag  = FMin(StrafeCoeff * (CurrentPitchDeg - RollDegThreshold),StrafeMaxVel);
         StrafeVelocity = StrafeMag * OrientVect[1];
		}
		else if (CurrentPitchDeg < -PitchDegThreshold){
		  StrafeMag = FMin(StrafeCoeff * (-PitchDegThreshold - CurrentPitchDeg),StrafeMaxVel);
		  StrafeVelocity = StrafeMag * OrientVect[3];
		}
		else
		  StrafeVelocity = vect(0,0,0);
	}

}


function HurtByZombieCinematicRecover()
{
	ZombiePlayerPawn(Pawn).HurtByZombieRecover();
	SetCinematicMode(false,false,false,true,false,true);

	//cancel reference to zombie when push zombie ,save it for recover its state in
	//HurtByZombieZombieRecover()
	//LastInteractZombie = InteractZombie;
	InteractZombie = none; 

	gotoState('PlayerRush');
}

state DoingSpecialMove
{
	function PlayerMove( float DeltaTime )
	{
	}
}
state EatByZombie
{
	function PlayerMove( float DeltaTime )
	{
	}
begin:
	HurtByZombieEat();
};

state CaptureByZombie
{
	function PlayerMove( float DeltaTime )
	{
	}
	exec function StartFire( optional byte FireModeNum ){}
	event BeginState(Name PreviousStateName)
	{
		TouchEvents.remove(0,TouchEvents.length-1);
		Pawn.ZeroMovementVariables();
		bSwipeCapturePlayer = true;
		SwipeCounter = 0;

		// ZombiePlayerPawn(Pawn).CustomTakeDamage(10);

		if (ZombiePlayerPawn(Pawn).GetCustomHealth()<=0)
		{
			CaptureActTimeEnd();
		}


		ZombieHud(myhud).SetActionFunction(TapActionButton);


		SetTimer(6.0,false,'CaptureActTimeEnd');

		SetTimer(4.0,false,'TakeCaptureExDamage');
		DumpStateStack();
	}

	event EndState(Name NextStateName)
	{
		Pawn.ZeroMovementVariables();
		bSwipeCapturePlayer = true;
		SwipeCounter = 0;
		ZombieHud(myhud).RestoreActionFunction();
	}

	function TakeCaptureExDamage()
	{
		ZombiePlayerPawn(Pawn).CustomTakeDamage(40);

		clearTimer('TakeCaptureExDamage');

		if (ZombiePlayerPawn(Pawn).GetCustomHealth()<=0)
		{
			CaptureActTimeEnd();
		}
	}

	function CaptureActTimeEnd()
	{
		clearTimer('CaptureActTimeEnd');
		gotoState('EatByZombie');   
	}

	function TapActionButton()
	{
		SwipeCounter += 1;

		if (SwipeCounter>=TargetSwipeNum)
		{
			clearTimer('CaptureActTimeEnd');
			clearTimer('TakeCaptureExDamage');
			HurtByZombieCinematicPreRecover();
		}
	}
		function DoSwipeMove(Vector2D startLocation, Vector2D endLocation)
	{
	}
	function InternalOnInputTouch(int Handle, ETouchType Type, Vector2D TouchLocation, float DeviceTimestamp, int TouchpadIndex)
	{
		local Actor PickedActor;
		local STouchEvent TouchEvent;
		local int Index;


	//	ZombieHud(myHud).HudCheckTouchEvent_CaptureByZombie(Handle,Type,TouchLocation,ViewportSize);


		//LocalPlayer(Player).ViewportClient.GetViewportSize(ViewportSize);
		// Handle new touch events
		if (Type == Touch_Began)
		{
			// Ensure that this is a new touch event
			if (TouchEvents.Find('Handle', Handle) != INDEX_NONE)
			{
				return;
			}

			// Setup the touch event
			TouchEvent.Handle = Handle;
			TouchEvent.ScreenLocation = TouchLocation;
			TouchEvent.TouchBeginLocation = TouchLocation;
			TouchEvent.LastTouchTime = worldinfo.timeseconds;
			TouchEvent.HasBeenProcessed = false;

			// Add the touch event to the TouchEvents array
			TouchEvents.AddItem(TouchEvent);
		}
		else if (Type == Touch_Moved)
		{
			Index = TouchEvents.Find('Handle', Handle);
			if (Index == INDEX_NONE)
			{
				return;
			}
		}
		// Handle existing touch events
		else if (Type == Touch_Ended || Type == Touch_Cancelled)
		{			
			Index = TouchEvents.Find('Handle', Handle);
			if (Index == INDEX_NONE)
			{
				return;
			}
			SwipeCounter += 1;
			if (SwipeCounter>=TargetSwipeNum)
			{
				HurtByZombieCinematicPreRecover();
			}
			//	ClientMessage("ZombiePC.TouchEvents"@TouchLocation.x@TouchLocation.y);
			// Remove the touch event from the TouchEvents array
			TouchEvents.Remove(Index, 1);
		}
	}
};

state PlayerWalking
{
	event BeginState(Name PreviousStateName)
	{
		//计算四个方向向量
		ReCalcOrientVector();

	//	PawnCSphere=Spawn(class'PawnCollisionSphere',self);
	//	PawnCSphere.SetBase(Pawn);
		//PawnCSphere.SetHardAttach(true);
		gotoState('PlayerRush');
	}
}


state PlayerRush extends PlayerWalking
{
	event BeginState(Name PreviousStateName)
	{
         RushDir =  OrientVect[OrientIndex];
         if(PreviousStateName != 'PlayerTurn')
		 	//Pawn.SetMovementPhysics();
		 	Pawn.SetPhysics(PHYS_Walking);
		 else
		 {
		 	if(LatentTurnCommand != -1)
		 	{
		 	  OldOrientIndex = OrientIndex;
		 	  OrientIndex = LatentTurnCommand;
		 	  TurnMove(OldOrientIndex,OrientIndex);
		 	}
		 }
	}
   event EndState(Name NextStateName)
    {
		LongPressTime = 0.0f;
		bLongPressTimer = false;
		SetDashSpeed(false);
	}
	function PlayerMove( float DeltaTime )
	{
		local float OldVelocityZ;
		OnRushMobileMotion(PlayerInput.aTilt);
		
		 WorldInfo.WorldGravityZ =   ZombieRushGame(WorldInfo.Game).CustomGravityZ;
		 
		 if(ZombieRushPawn(Pawn)!=none && ZombieRushPawn(Pawn).bHitWall)
		 {
		 //	ZombieRushPawn(Pawn).bHitWall = false;
		     return;
		 }
		 
		 // consume power when run
		if(VSize(Pawn.Velocity) > 10)
           ZombiePlayerPawn(Pawn).ConsumePower(1.67 * DeltaTime);

 		// set ground speed
		if(!ZombiePlayerPawn(Pawn).bIsJumping){
		       SetDashSpeed(true);	

        if(ZombiePlayerPawn(Pawn).PlayerPower>0)
          Pawn.Acceleration = Pawn.AccelRate * RushDir;
        else
          GotoState('PlayerStop');

          if(bLongPressTimer)
					LongPressTime+= DeltaTime;
		  if(LongPressTime >= 0.5f){
                    bLongPressTimer = false;
		}
        //  Pawn.Acceleration = vect(0,0,0);
        /*
		  Pawn.Velocity.X = FMin (abs(Pawn.Velocity.X) + 600  * DeltaTime, ForwardVel)  * RushDir.x;
		  Pawn.Velocity.Y = FMin (abs(Pawn.Velocity.Y) + 600  * DeltaTime, ForwardVel)  * RushDir.y;	
		  */	   
		//  Pawn.Acceleration = Pawn.AccelRate * Normal (ForwardVel * RushDir + StrafeVelocity ) ;

		 // Pawn.SetLocation(Pawn.Location + Pawn.Velocity * DeltaTime);
          
		}
	 else
       {
        //  OldVelocityZ = Pawn.Velocity.Z;
       	//  Pawn.Velocity = ForwardVel * Normal (ForwardVel * RushDir + StrafeVelocity ) ;
        //  Pawn.Velocity.Z = OldVelocityZ;
       	  Pawn.Velocity.X = ForwardVel * RushDir.x;
		  Pawn.Velocity.Y = ForwardVel * RushDir.y;
            //   Pawn.Velocity += StrafeVelocity;
		}	
		
	  Pawn.SetRotation(Rotator(RushDir));
	  SetRotation(Pawn.rotation);
      ViewShake( deltaTime );
	//UpdateRotation(DeltaTime);
	}

	function InternalOnInputTouch(int Handle, ETouchType Type, Vector2D TouchLocation, float DeviceTimestamp, int TouchpadIndex)
	{
		local STouchEvent TouchEvent;
		local int Index;

		if(ZombieRushPawn(Pawn).IsDoingASpecialMove())
		 //	ZombieRushPawn(Pawn).bHitWall = false;
		     return;
		if( ZombieHud(myHUD).HudCheckTouchEvent(Handle,Type,TouchLocation,ViewportSize))
		  	return;

		if (Type == Touch_Began)
		{
			// Ensure that this is a new touch event
			if (TouchEvents.Find('Handle', Handle) != INDEX_NONE)
			{
				return;
			}
			// Setup the touch event
			TouchEvent.Handle = Handle;
			TouchEvent.ScreenLocation = TouchLocation;
			TouchEvents.AddItem(TouchEvent);
		}

//Touch_Stationary no use right now
		else if(Type == Touch_Stationary){
			Index = TouchEvents.Find('Handle', Handle);
			if (Index == INDEX_NONE)
			{
				return;
			}
			if( TouchEvents[Index].ScreenLocation ==  TouchLocation)
				bLongPressTimer = true;
         }
		else if(Type == Touch_Moved){
			Index = TouchEvents.Find('Handle', Handle);
			if (Index == INDEX_NONE)
			{
				return;
			}
		}

		// Handle existing touch events
		else if (Type == Touch_Ended || Type == Touch_Cancelled)
		{			
			Index = TouchEvents.Find('Handle', Handle);
			if (Index == INDEX_NONE)
			{
				return;
			}			
			if(CustomVSize2D(TouchEvents[Index].ScreenLocation,TouchLocation)>MinMoveDistance)
			   DoSwipeMove(TouchEvents[Index].ScreenLocation,TouchLocation);         
			//	ClientMessage("ZombiePC.TouchEvents"@TouchLocation.x@TouchLocation.y);
			// Remove the touch event from the TouchEvents array
           else if(LongPressTime<0.5f
           	&&CustomVSize2D(TouchEvents[Index].ScreenLocation,TouchLocation)<MinTapDistance)
           {
               	  DoTouchMove(TouchLocation);
            } 
            TouchEvents.Remove(Index, 1);
			LongPressTime = 0.0f;
			bLongPressTimer = false;
			SetDashSpeed(false);
		}
	}

};
state PlayerStop extends PlayerRush
{
	event BeginState(Name PreviousStateName)
	{
		Pawn.ZeroMovementVariables();
	}
	function PlayerMove( float DeltaTime )
	{
		 if(ZombiePlayerPawn(Pawn).PlayerPower >= 60)
		 	GotoState('PlayerRush');
		 ZombiePlayerPawn(Pawn).RestorePower(6 * DeltaTime);
		 Pawn.SetRotation(Rotator(RushDir));
	 	 SetRotation(Pawn.rotation);
	}

}

state KnockByBlockade
{
	event BeginState(Name PrevStateName)
    {
    	SetPhysics(PHYS_Custom);
    }
	 event EndState(Name NextStateName)
    {  
    //	SetPhysics(PHYS_Falling);
    //	Pawn.velocity = vect(0,0,0);
    }	
    event PlayerTick(float deltaTime)
    {
    	Pawn.velocity = KonckVelocity;
    }
Begin:

     Sleep(0.1);
     if(!FastTrace(100*Normal(Pawn.velocity) + Pawn.location, Pawn.Location))
     {
     	Pawn.velocity = vect(0,0,0);
     	ZombieRushPawn(Pawn).bHitWall = true;
     }
     else
     {
     	ZombieRushPawn(Pawn).bHitWall = false;
     }
     GotoState('PlayerRush');
}

function PawnRanintoBlockade(vector HitNormal, optional bool bInverse)
{
	HitNormal.Z = 0;
	if(!bInverse)
	 KonckVelocity = KnockMag * Normal(HitNormal cross vect(0,0,1));
	else
	 KonckVelocity = KnockMag * Normal(HitNormal cross vect(0,0,-1));
	GotoState('KnockByBlockade');
	 //+Vsize(Velocity) * 25 * Normal(HitNormal);
}

function PawnRanOffBlockade(vector HitNormal, optional bool bInverse)
{
	HitNormal.Z = 0;
	if(!bInverse)
	 KonckVelocity = KnockMag * Normal(HitNormal cross vect(0,0,1));
	else
	 KonckVelocity = KnockMag * Normal(HitNormal cross vect(0,0,-1));
	// KonckVelocity = 1500 * Normal(HitNormal);
	GotoState('KnockByBlockade');
	 //+Vsize(Velocity) * 25 * Normal(HitNormal);
}

function DoSwipeMove(Vector2D startLocation, Vector2D endLocation)
{
         local float deltaX,deltaY,absDeltaY,absDeltaX;
		 local Vector HitLocation,HitNormal,TraceLoc;
         local Actor HitActor;
     
		 TraceLoc = SwipeTraceDistance * RushDir + Pawn.location;
		 ////HitActor = Trace(HitLocation, HitNormal, CamPos, TargetLoc, TRUE, vect(12,12,12), HitInfo,TRACEFLAG_Blocking);
		 HitActor = Trace(HitLocation, HitNormal, TraceLoc ,Pawn.location, FALSE, vect(12,12,12));
		 deltaY = endLocation.Y - startLocation.Y;
		 deltaX = endLocation.X - startLocation.X;
		 absDeltaX = abs(deltaX);
		 absDeltaY = abs(endLocation.Y - startLocation.Y);

		 OldOrientIndex = OrientIndex;
         if (deltaX > 0.1 && absDeltaX > absDeltaY ) //swipe right
         {
		     OrientIndex = 0;
		     ZombieRushPawn(Pawn).bHitWall = false;
		 }
		 else if(deltaX < -0.1 && absDeltaX > absDeltaY) //swipe left
		 {
			OrientIndex = 2;
			ZombieRushPawn(Pawn).bHitWall = false;
		  }
		 else if(deltaY < -0.1)  //swipe up
		 {
		 	OrientIndex = 3;
			ZombieRushPawn(Pawn).bHitWall = false;
		 }
		  else if(deltaY > 0.1)  //swipe down
		 {
		 	OrientIndex = 1;
			ZombieRushPawn(Pawn).bHitWall = false;
		 }

		OldVelocity = Pawn.Velocity;	
		RushDir = OrientVect[OrientIndex]; 
		 Pawn.Velocity = vect(0,0,0);
		 if (Vsize(OldVelocity) > 500 && GetStateName()=='PlayerRush')
		 {
		    TurnMove(OldOrientIndex, OrientIndex);
		 }		
		 return;
}

function  TurnMove(int OldOrient, int NewOrient)
{
	if(OldOrient == (NewOrient+1)%4 )
	    GotoState('PlayerTurn','TurnLeft');
	else if(NewOrient == (OldOrient+1)%4 )
	    GotoState('PlayerTurn','TurnRight');
	else if(NewOrient == (OldOrient+2)%4 )
	    GotoState('PlayerTurn','TurnBack');
}

State PlayerTurn
{
	event BeginState(Name PreviousStateName)
	{
         RushDir =  OrientVect[OrientIndex];
		 Pawn.SetPhysics(PHYS_Custom);
		 Pawn.Velocity = OldVelocity;
		 TurnIntervalTime = 0.3;
		 LatentTurnCommand = -1;

		 InitRot = Pawn.Rotation;
	}
	 event EndState(Name NextStateName)
    {
		StopLatentExecution();

         Pawn.SetPhysics(PHYS_Walking);
	     Pawn.SetRotation(Rotator(RushDir));
	}
	//can`t fire in PlayerTurn State
	 exec function StartFire( optional byte FireModeNum )
	{
	}
	function InternalOnInputTouch(int Handle, ETouchType Type, Vector2D TouchLocation, float DeviceTimestamp, int TouchpadIndex)
	{
		local STouchEvent TouchEvent;
		local int Index;
		if (Type == Touch_Began)
		{
			// Ensure that this is a new touch event
			if (TouchEvents.Find('Handle', Handle) != INDEX_NONE)
			{
				return;
			}
			// Setup the touch event
			TouchEvent.Handle = Handle;
			TouchEvent.ScreenLocation = TouchLocation;
			TouchEvents.AddItem(TouchEvent);
		}
		// Handle existing touch events
		else if (Type == Touch_Ended || Type == Touch_Cancelled)
		{			
			Index = TouchEvents.Find('Handle', Handle);
			if (Index == INDEX_NONE)
			{
				return;
			}			
			if(CustomVSize2D(TouchEvents[Index].ScreenLocation,TouchLocation)>MinMoveDistance)
			   LatentTurnCommand = GetNextTurnCommand(TouchEvents[Index].ScreenLocation,TouchLocation);         
            TouchEvents.Remove(Index, 1);
		}
	}
	function int GetNextTurnCommand(Vector2D startLocation, Vector2D endLocation)
{
         local float deltaX,deltaY,absDeltaY,absDeltaX;
		 deltaY = endLocation.Y - startLocation.Y;
		 deltaX = endLocation.X - startLocation.X;
		 absDeltaX = abs(deltaX);
		 absDeltaY = abs(endLocation.Y - startLocation.Y);

         if (deltaX > 0.1 && absDeltaX > absDeltaY ) //swipe right
         {
		     ZombieRushPawn(Pawn).bHitWall = false;
		     return 0;
		 }
		 else if(deltaX < -0.1 && absDeltaX > absDeltaY) //swipe left
		 {
			ZombieRushPawn(Pawn).bHitWall = false;
			return 2;
		  }
		 else if(deltaY < -0.1)  //swipe up
		 {
			ZombieRushPawn(Pawn).bHitWall = false;
			return 3;
		 }
		  else if(deltaY > 0.1)  //swipe down
		 {
			ZombieRushPawn(Pawn).bHitWall = false;
			return 1;
		 }
		 return -1;
}
	function PlayerMove( float DeltaTime )
	{
		if(TurnIntervalTime > 0)
		{
		    TurnIntervalTime-=DeltaTime;
		    Pawn.Velocity = FMax(Vsize(Pawn.Velocity)-1400 * DeltaTime, 50 ) * OrientVect[OldOrientIndex];
		    if(TurnIntervalTime <= 0)
		      Pawn.Velocity = vect (0,0,0);
		}
		else
		{
			Pawn.Velocity = FMin(Vsize(Pawn.Velocity)+1400 * DeltaTime, ForwardVel*1.0) * OrientVect[OrientIndex];
		}
		Pawn.Move( Pawn.Velocity * DeltaTime);
		//Pawn.SetRotation(InitRot + QuatToRotator(Pawn.Mesh.RootMotionDelta.Rotation));
	}
	begin:
	TurnLeft:
     ZombieRushPawn(Pawn).DoSpecialMove(SM_RunTurn,false,none,1);
     FinishAnim(ZombieRushPawn(Pawn).CurrentActiveCustomAnimNode.GetCustomAnimNodeSeq());
     ZombieRushPawn(Pawn).EndSpecialMove();
	TurnRight:
	ZombieRushPawn(Pawn).DoSpecialMove(SM_RunTurn,false,none,2);
	FinishAnim(ZombieRushPawn(Pawn).CurrentActiveCustomAnimNode.GetCustomAnimNodeSeq());
	 ZombieRushPawn(Pawn).EndSpecialMove();

	 TurnBack:
	ZombieRushPawn(Pawn).DoSpecialMove(SM_RunTurn,false,none,3);
	FinishAnim(ZombieRushPawn(Pawn).CurrentActiveCustomAnimNode.GetCustomAnimNodeSeq());
	 ZombieRushPawn(Pawn).EndSpecialMove();
}
function  DoTouchMove(Vector2d TouchLocation)
{
	local Vector HitLocation,HitNormal,TraceLoc;
    local Actor HitActor,PickedActor;
		 TraceLoc = 300 * RushDir + Pawn.location;//(46: collisioncomponent radius)
		    ////HitActor = Trace(HitLocation, HitNormal, CamPos, TargetLoc, TRUE, vect(12,12,12), HitInfo,TRACEFLAG_Blocking);
		 HitActor = Trace(HitLocation, HitNormal, TraceLoc ,Pawn.location, FALSE, vect(12,12,12));
			`if(`isdefined(debug))
			DrawdebugLine(Pawn.location,TraceLoc,255,0,0,true);
			`endif
		 if( HitActor != None )
		 {
			 if(HitActor.IsA('InterpActor')&&HitActor.Tag=='luzhang_03')
			 {
			 	LatentClimbBlockade(HitLocation);
				 return;
			 }
             PickedActor = PickActor(TouchLocation);
			  if( PickedActor.IsA('ZBAIPawnBase')&&ZombieRushPawn(Pawn).WeaponList[2].isInState('Active'))
			 {
			 	   AvailableShootZombie = ZBAIPawnBase(PickedActor);
			 	  super.StartFire(0); 
			 	  return;       
			 }
		 }
             CustomJump();
}

function LatentClimbBlockade(Vector ClimbPoint)
{
		TraversalTargetLocation = ClimbPoint;
		PushState('MoveToCertainPoint');
}

state MoveToCertainPoint
{
	event BeginState(Name PreviousStateName)
	{
         RushDir =  OrientVect[OrientIndex];
		 Pawn.SetPhysics(PHYS_Custom);
	}
   event EndState(Name NextStateName)
    {
		SetDashSpeed(false);
	}
	function PlayerMove( float DeltaTime )
	{
		if (VSize(TraversalTargetLocation-Pawn.Location) <= Pawn.GetCollisionRadius() + 30)
		{
			ClimbBlockade();
			PopState();
		}
		else
		{
			Pawn.Velocity = ForwardVel * RushDir;
			Pawn.Move( Pawn.Velocity * DeltaTime);
		}		    
	}
	function InternalOnInputTouch(int Handle, ETouchType Type, Vector2D TouchLocation, float DeviceTimestamp, int TouchpadIndex)
	{
	}
}
function ClimbBlockade()
{
	if (!ZombiePlayerPawn(Pawn).IsDoingASpecialMove())
	{
		ZombiePlayerPawn(Pawn).DoSpecialMove(SM_ClimbBlocade);
	}

}
function CustomJump()
{
	if (!ZombiePlayerPawn(Pawn).IsDoingASpecialMove()&&ZombiePlayerPawn(Pawn).GetPower()>20)
	{
		ZombiePlayerPawn(Pawn).DoRushJump();
	}

}

function ReCalcOrientVector()
{
	local vector X,Y,Z;
	GetAxes(Pawn.rotation,X,Y,Z);
	   //cametype1
	   /*
    OrientIndex=0;
    OrientVect[0] = X;
	OrientVect[1] = Y;
	OrientVect[2] = -X;
	OrientVect[3] = -Y;*/

	//cametype2
	OrientIndex=2;
    OrientVect[0] = -X;
	OrientVect[1] = -Y;
	OrientVect[2] = X;
	OrientVect[3] = Y;
}
function SetDashSpeed(bool bDash,optional bool bInjuryPawn)
{
//rushPC 600 NORMAL SPEED   GROUND SPEED 10000
     if (ZombiePlayerPawn(Pawn).GetPower()>60)
     {
		 ForwardVel = DefaultSpeed;       //15m/s 775
		//  Pawn.GroundSpeed = 525;		//10 m/s
		if(ZombieRushPawn(Pawn)!=none)
		  ZombieRushPawn(Pawn).SetWalkingStatus(false);
     }
	 else if(ZombiePlayerPawn(Pawn).GetPower()>20)
	 {
		// Pawn.GroundSpeed = 525;		//10 m/s
	     ForwardVel = 630;		//12 m/s  630
	     if(ZombieRushPawn(Pawn)!=none)
		  ZombieRushPawn(Pawn).SetWalkingStatus(false);
	  }
	 else   // only can walk
	 {
		ForwardVel = 160;   //3m/s
		if(ZombieRushPawn(Pawn)!=none)
		  ZombieRushPawn(Pawn).SetWalkingStatus(true);
		}
	ForwardVel *= EntityBuffer.VelocityScale;
	Pawn.GroundSpeed = ForwardVel;
}


event NotifyDirectorControl(bool bNowControlling, SeqAct_Interp CurrentMatinee)
{
	super.NotifyDirectorControl(bNowControlling, CurrentMatinee);

	if (bNowControlling)
	{
		MPI.OnInputTouch = OffsetMatineeTouch;
	}
	else
	{
		MPI.OnInputTouch = InternalOnInputTouch;
		LastOffset.Yaw = 0;
		LastOffset.Pitch = 0;
		MatineeOffset.Yaw = 0;
		MatineeOffset.Pitch = 0;
		bFingerIsDown = false;
	}

	// remember if we are controlling or not
	bApplyBackTouchToViewOffset = bNowControlling;
}



event bool NotifyHitWall(vector HitNormal, actor Wall){
  `log("NotifyHitWall");
}

event bool NotifyBump(Actor Other, Vector HitNormal){
  `log("NotifyBump");
}

exec function coeff(float a=60, float b=600){
	StrafeCoeff =a;
	StrafeMaxVel = b;
}

`if(`isdefined(debug))
exec function WP(EWeaponType PendingType)
{
  ZombieRushPawn(Pawn).ConsoleSetActiveWeaponByType(PendingType);
}
exec function GRSPEED(float Speed)
{
  DefaultSpeed = Speed;
}
exec function R1 ()
{
	Pawn.Mesh.RootMotionRotationMode = RMRM_RotateActor;
}
exec function R2 ()
{
	Pawn.Mesh.RootMotionRotationMode = RMRM_Ignore;
}
exec function Power (float value)
{
	ZombieRushPawn(Pawn).PlayerPower = value;
}
`endif
exec function StartFire( optional byte FireModeNum )
{
	NormalStateName = GetStateName();

	if(!ZombiePlayerPawn(Pawn).IsDoingSpecialMove(SM_Combat_GetHurt)&&Pawn.physics!=PHYS_Falling){
		if(ZombieRushPawn(Pawn).WeaponType==1||ZombieRushPawn(Pawn).AmmoNum[ZombieRushPawn(Pawn).WeaponType]>0)
		{
		   GotoState('DoingSpecialMove');
		   if(Pawn.Weapon== ZombieRushPawn(Pawn).WeaponList[1] )	
		     super.StartFire(1);
		   else if(Pawn.Weapon== ZombieRushPawn(Pawn).WeaponList[2] )	
		     super.StartFire(0);
		  }
		//  ApplyAdhesion();
	}
}


DefaultProperties
{
	CameraClass=class'ZBRushCamera'
	SwipeTraceDistance=2000

	OldOrientIndex=0
	OrientIndex=0

	MinMoveDistance=15
    MinTapDistance=8
	StrafeCoeff=100
	StrafeMaxVel=600
	ForwardVel = 630    // infact 630->467
    
	RollDegThreshold=5
	PitchDegThreshold=5
	NormalStateName=PlayerRush

	TurnIntervalTime=0.3
	LatentTurnCommand=-1
	KnockMag=900.0
	DefaultSpeed=775
}
