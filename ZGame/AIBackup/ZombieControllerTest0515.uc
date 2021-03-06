class ZombieControllerTest extends ZombieControllerBase implements(IDebugInterface);

var bool attackReady_melee;
//actual timers for the cooldowns
var float timer_melee;


var int index;
var int counter;

//keep record of previous state
var Name previousState;

var Name moveToPlayerState;
//for wander
var Vector WanderLocation,WanderCenter;
var Vector SpawnLocation;
var float WanderRange;


var ZBAIPawnBase ActiveAIPawn;


////Navigation
var bool PlayerPawnIsReachable;

var Vector targetDestinationPosition;

var Vector tempDest;


// record distance from player
var float distanceToPlayer;


var		transient int	AwareUpdateFrameCount;
var		transient array<Actor>	NearbyDynamics;
var(Path) float AwareRadius;
var(Path) float AvoidOtherRadius;
var(Path) float AvoidOtherStrength;
var(Path)	int		AwareUpdateInterval;

var float MoveToPlayerExpireTime;

//for setDashSpeed()
var const float DefaultIdleSpeed,DefaultChaseSpeed;
//for push rot set
var vector PushOrientDir;


function DrawDebug(HUD myHud)
{
	//local Vector DebugInfoLoc;
	// DebugInfoLoc = myHud.Canvas.Project(Pawn.Location);
	myHud.Canvas.SetPos(400, 200);
//	myHud.Canvas.DrawText("Controller State"@GetStateName() @"PawnSpeed"@Pawn.GroundSpeed);
    myHud.Canvas.DrawText("Controller rOT"@rotation @"PawnRot"@Pawn.Rotation);
}
function initializeGame()
{
	super.initializeGame();

	if (Pawn == none)
	{
		return;
	}

	//cast the ActiveAIPawn
	ActiveAIPawn = ZBAIPawnBase(Pawn);

	SpawnLocation = ActiveAIPawn.location;
	//get the AnimationNode for animations
	AnimationNodeSlot = AnimNodeSlot(Pawn.Mesh.FindAnimNode('CustomSlot'));

	//give the zombie the force weapon
//	ActiveAIPawn.AddDefaultInventory();
}


protected event ExecuteWhatToDoNext()
{
	if(ActiveAIPawn.health<=0)
        GotoState('ZombieDying');
	
    distanceToPlayer = VSize(globalPlayerController.Pawn.Location - Pawn.Location);
	if(distanceToPlayer <ActiveAIPawn.GetCollisionRadius()+ActivePlayerPawn.GetCollisionRadius()+70
		&&globalPlayerController.InteractZombie==none)
		//&&AI_PlayerOnSameHeight())
	//	&&!ZombiePawn(globalPlayerController.Pawn).IsDoingASpecialMove())
		GotoState('MeleeAttackPlayer');
	//else if(globalPlayerController.InteractZombie!=none//||ZombiePawn(globalPlayerController.Pawn).IsDoingASpecialMove())
	else if(distanceToPlayer < ActiveAIPawn.meleePrepareRange )
        GotoState('MeleeAttackPreparing');
	else if(AI_PlayerInsight()
		||previousState == moveToPlayerState&&distanceToPlayer < ActiveAIPawn.moveToPlayerCancelRange)
		//&&globalPlayerController.InteractZombie==none)
	{
		if(frand()>0.3)
		GotoState(moveToPlayerState);
		else
		GotoState(moveToPlayerState,'Idle');
	}
	else 

		GotoState('Patrol');
}

///////
//AI function
/////////

function bool AI_PlayerOnSameHeight()
{
	return abs(globalPlayerController.Pawn.Location.z-ActiveAIPawn.Location.z)<10;
}
function bool AI_PlayerInsight()
{
	local float DotToTarget;
	local Vector ToTestWPNorm;
	ToTestWPNorm = globalPlayerController.Pawn.Location - ActiveAIPawn.Location;
	distanceToPlayer = VSize(ToTestWPNorm);
	ToTestWPNorm /= distanceToPlayer;
	DotToTarget = ToTestWPNorm Dot Vector(ActiveAIPawn.Rotation);
	if (( DotToTarget > 0 && distanceToPlayer < ActiveAIPawn.moveToPlayerUpperRange
		|| distanceToPlayer < ActiveAIPawn.moveToPlayerNearRange)
	&& FastTrace(ActivePlayerPawn.Location,ActiveAIPawn.Location))  //180du	
	{
		return true;
	}
	else
		return false;
}
///////////////////////////////////////////////////////////////////////////////////////
//AI STATES
///////////////////////////////////////////////////////////////////////////////////////

state ZombieDying
{
begin:
	ActiveAIPawn.CustomDie();
};
/** Basic patrol */
state Patrol
{
	event BeginState(Name PreviousStateName)
	{
		index = int(RandRange(1, 5));
		//ActiveAIPawn.GroundSpeed = ActiveAIPawn.speed_outsideMeleeRange;
		SetDashSpeed(false);
		ActiveAIPawn.AccelRate = ActiveAIPawn.speed_normalAccel;
		WanderCenter = ActiveAIPawn.Location;
	}


	simulated function Tick(float DeltaTime)
	{
		global.tick(DeltaTime);
		if ( AI_PlayerInsight() )
		//	&&globalPlayerController.InteractZombie==none
		{
			StopLatentExecution();
			WhatToDoNext();
		}
	}

	function Vector CalculateMovementDirection()
	{
		local Vector destination;
		local Rotator vectorRotation;
		//get random angle
		vectorRotation.Yaw = (FRand() * 360 * 182);
		//get the normalized vector between pawn and player
		destination = Normal(ActivePlayerPawn.Location - ActiveAIPawn.Location);
		//apply the rotation to the vector
		destination = destination << vectorRotation;
		ActiveAIPawn.SetRotation(Rotator(destination));
		//`log(""$(vectorRotation.Yaw / 182));
		return destination;
	}

	event bool NotifyHitWall(vector HitNormal, actor Wall)
	{
		StopLatentExecution();
		WhatToDoNext();
		//LatentWhatToDoNext();
		return true;
	}
Begin:
	previousState = GetStateName();
	for(counter = 0; counter < index; counter++)
	{
		//`log("11");
		WanderLocation = ActiveAIPawn.Location + (CalculateMovementDirection() * ActiveAIPawn.other_movementVectorLength * RandRange(0.7, 1));
		if (VSize(WanderLocation - WanderCenter)<=WanderRange)
		{
			MoveTo(WanderLocation, ActiveAIPawn);
		}
		else
		{
			//just idle
			Sleep(0.5);
			/*
			ActiveAIPawn.SetRotation(Rotator(SpawnLocation-ActiveAIPawn.location));
			MoveTo(SpawnLocation, ActiveAIPawn);*/
		}
		Sleep(RandRange(1.3, 2));
	}
	//Sleep(RandRange(1.3, 2));
	LatentWhatToDoNext();
}



state MoveToPlayerNoNav
{
	event BeginState(Name PreviousStateName)
	{
		//	ActiveAIPawn.GroundSpeed = ActiveAIPawn.speed_outsideMeleeRange;
		ActiveAIPawn.AccelRate = ActiveAIPawn.speed_normalAccel;
		SetDashSpeed(false);

		if (AnimationNodeSlot.bIsPlayingCustomAnim)
		{
			AnimationNodeSlot.StopCustomAnim(0.5f);
		}
		MoveToPlayerExpireTime = 3.0f;
	}
	event bool NotifyHitWall(vector HitNormal, actor Wall)
	{
		StopLatentExecution();
		WhatToDoNext();
		//LatentWhatToDoNext();
		return true;
	}
	simulated function Tick(float DeltaTime)
	{
		global.tick(DeltaTime);
		if(MoveToPlayerExpireTime > 0)
            MoveToPlayerExpireTime -= DeltaTime;
        if(MoveToPlayerExpireTime<=0 && MoveToPlayerExpireTime>-5)
         {
         	MoveToPlayerExpireTime = -10;
			StopLatentExecution();
			WhatToDoNext();
		}
		distanceToPlayer = VSize(globalPlayerController.Pawn.Location - Pawn.Location);
		if (distanceToPlayer < ActiveAIPawn.meleePrepareRange)
		{
			StopLatentExecution();
			WhatToDoNext();
		}
		else if(globalPlayerController.InteractZombie!=none//||ZombiePawn(globalPlayerController.Pawn).IsDoingASpecialMove())
			&&distanceToPlayer < ActiveAIPawn.meleePrepareRange )
		{
			//GotoState('MeleeAttackPreparing');
			StopLatentExecution();
			WhatToDoNext();
		}

		//performPhysics(DeltaTime);
	}
	function Vector CalculateDirectMovementDirection()
	{
		local Vector destination;
		//get the normalized vector between pawn and player
		destination = Normal(ActivePlayerPawn.Location - ActiveAIPawn.Location);
		return destination;
	}
Begin:
	previousState = GetStateName();
	if (attackReady_melee)
	{
	// MoveTo(ActivePlayerPawn.Location + (CalculateDirectMovementDirection() * ActiveAIPawn.direct_movementVectorLength * RandRange(0.5, 1.0)), ActivePlayerPawn);
		MoveToward(ActivePlayerPawn,ActivePlayerPawn);
	    LatentWhatToDoNext();
	}
	else
	{
		Pawn.ZeroMovementVariables();
		Focus = ActivePlayerPawn;
		Sleep(0.2);
		LatentWhatToDoNext();
	}
Idle:
      StopLatentExecution();
      Sleep(RandRange(0.5,3));
      LatentWhatToDoNext();
}
//move towards Player  not move direct
state MoveToPlayer
{
	event BeginState(Name PreviousStateName)
	{
	//	ActiveAIPawn.GroundSpeed = ActiveAIPawn.speed_outsideMeleeRange;
		ActiveAIPawn.AccelRate = ActiveAIPawn.speed_normalAccel;
        SetDashSpeed(true);

		if (AnimationNodeSlot.bIsPlayingCustomAnim)
		{
			AnimationNodeSlot.StopCustomAnim(0.5f);
		}
	}
	simulated function Tick(float DeltaTime)
	{
		global.tick(DeltaTime);

		distanceToPlayer = VSize(globalPlayerController.Pawn.Location - Pawn.Location);
		if (distanceToPlayer <ActiveAIPawn.GetCollisionRadius()+ActivePlayerPawn.GetCollisionRadius()+10)
		{
			StopLatentExecution();
		}
		else if((globalPlayerController.InteractZombie!=none||ZombiePawn(globalPlayerController.Pawn).IsDoingASpecialMove())
			&&distanceToPlayer < ActiveAIPawn.meleePrepareRange )
			//GotoState('MeleeAttackPreparing');
			StopLatentExecution();  

		performPhysics(DeltaTime);
	}
	function Vector CalculateMovementDirection()
	{
		local Vector destination;
		local Rotator vectorRotation;
		//get random angle in front of pawn
		vectorRotation.Yaw = (FRand() * 60 * 182) - (30*182);
		//get the normalized vector between pawn and player
		destination = Normal(ActivePlayerPawn.Location - ActiveAIPawn.Location);
		//apply the rotation to the vector
		destination = destination << vectorRotation;
		//make the spider face the direction he's walking if it's far from the player
		if(VSize(ActiveAIPawn.Location - ActivePlayerPawn.Location) > ActiveAIPawn.range_movelookAtPlayer)
		{
			ActiveAIPawn.SetRotation(Rotator(destination));
		}
		return destination;
	}
     function Vector CalculateDirectMovementDirection()
	 {
		 local Vector destination;
		 //get the normalized vector between pawn and player
		 destination = Normal(ActivePlayerPawn.Location - ActiveAIPawn.Location);
		 return destination;
	 }
Begin:
	 previousState = GetStateName();
	if (attackReady_melee)
	{

		//determine whether the target is currently directly reachable
				if (NavActorReachable(ActivePlayerPawn))
				{	
					//LastValidLocation = Unit.Location;	

					if(distanceToPlayer > ActiveAIPawn.moveToPlayerNearRange)
					 MoveTo(ActiveAIPawn.Location + (CalculateMovementDirection() * ActiveAIPawn.other_movementVectorLength * RandRange(0.5, 1.5)), ActivePlayerPawn);
					else
					 MoveTo(ActivePlayerPawn.Location + (CalculateDirectMovementDirection() * ActiveAIPawn.other_movementVectorLength * RandRange(0.5, 1.5)), ActivePlayerPawn);

				}
				else if( NavigationHandle.GetNextMoveLocation( TempDest, 30) )
				{
					Focus = none;
					if (!NavigationHandle.SuggestMovePreparation( TempDest,self))
					{
						MoveTo(TempDest,none);//,30,false); //and move to our navigation point
					
						FindPathToUnit(ActivePlayerPawn);
						Sleep(0.0);
					}
				}

				else
				{
					FindPathToUnit(ActivePlayerPawn);
					Sleep(0.0);
				}
				

			LatentWhatToDoNext();
	}

	else
	{
		Pawn.ZeroMovementVariables();
		Sleep(0.2);
		LatentWhatToDoNext();
	}
}


state MeleeAttackCold
{
begin:
	
    previousState = GetStateName();
	Sleep(2.0);

	LatentWhatToDoNext();
};

state MeleeAttackPreparing
{
	event BeginState(Name PreviousStateName)
	{
		stopLatentExecution();
		Pawn.ZeroMovementVariables();
		ActiveAIPawn.DoSpecialMove(SM_Zombie_MeleeAttackPre);
		//Focus = none;
	}

	event EndState(Name NextStateName)
	{
		if(ActiveAIPawn.IsDoingSpecialMove(SM_Zombie_MeleeAttackPre))
	       ActiveAIPawn.EndSpecialMove();
	}

	simulated function Tick(float DeltaTime)
	{
		global.tick(DeltaTime);
		if (distanceToPlayer <ActiveAIPawn.GetCollisionRadius()+ActivePlayerPawn.GetCollisionRadius()+50)
		{
			StopLatentExecution();
		//	WhatToDoNext();
		}
		performPhysics(DeltaTime);
	}
begin:
	previousState = GetStateName();
//	while(ActiveAIPawn.IsDoingASpecialMove())
//		Sleep(0.0);
   if(globalPlayerController.InteractZombie!=none)
   {
   	  Focus = ActivePlayerPawn;
	  Sleep(randrange(0.5,1.5));
   }
   else
   {
   	SetDashSpeed(true);
   	Focus = ActivePlayerPawn;
   	MoveToward(ActivePlayerPawn,ActivePlayerPawn,0.0,true);  
   }
	LatentWhatToDoNext();
	
};
//executes a melee attack
state MeleeAttackPlayer
{
	event BeginState(Name PreviousStateName)
	{
		Pawn.ZeroMovementVariables();
		ClientSetRotation(Pawn.Rotation);
	}

	simulated function Tick(float DeltaTime)
	{
		global.tick(DeltaTime);

		performPhysics(DeltaTime);
	}

	function Vector CalculateMovementDirection()
	{
		local Vector destination;
		local Rotator vectorRotation;
		vectorRotation.Yaw = (FRand() * 180 * 182) - (90*182);
		vectorRotation.Yaw -= (-180 * 182);
		destination = Normal(ActivePlayerPawn.Location - ActiveAIPawn.Location);
		destination = destination << vectorRotation;
		//�泯 player
		//ActiveAIPawn.SetRotation(Rotator(destination));
		return destination;
	}

begin:
	previousState = GetStateName();
	if(attackReady_melee)
	{
		attackReady_melee = false;
		stoplatentexecution();
		if(ActiveAIPawn.health<=0)
			LatentWhatToDoNext();
	//	Focus = ActiveAIPawn;
    //    FinishRotation();
    //    Focus = ActiveAIPawn;
        globalPlayerController.HurtByZombieCinematic(ActiveAIPawn);
	//	ZombiePlayerPawn(ActivePlayerPawn).HurtByZombie(rotator(pawn.location-ActivePlayerPawn.location),ActiveAIPawn);
        Focus = none;
	    ActiveAIPawn.SaveLastRot();
	    PushOrientDir = pawn.location - ActivePlayerPawn.location;
	   // PushOrientDir.z = 0;
	    ClientSetLocation(ActivePlayerPawn.location,rotator(PushOrientDir));
		ActiveAIPawn.PlayerHurtByMe(ActivePlayerPawn.location,rotator(PushOrientDir));
		//ClientSetRotation(rotator(ActivePlayerPawn.location - pawn.location));
	//	`log("Commit attack");
	//	 LatentWhatToDoNext();
	}
	else
	{
		Pawn.ZeroMovementVariables();
		Sleep(0.05);
		LatentWhatToDoNext();
	}
}

state Hurt
{
	event BeginState(Name PreviousStateName)
	{
		stopLatentExecution();
	//	Focus = none;
		Pawn.Zeromovementvariables();
	}

	event PushedState()
	{
		stopLatentExecution();
	}
begin:
    previousState = GetStateName();
	Pawn.SetRotation(rotator(ActivePlayerPawn.location-location));
//	Focus = ActivePlayerPawn;
	//MoveTo(Pawn.Location, globalPlayerController.Pawn);
	while(ActiveAIPawn.IsDoingASpecialMove())
		Sleep(0.0);

	Sleep(0.2);
	//LatentWhatToDoNext();
	if(distanceToPlayer <ActiveAIPawn.moveToPlayerUpperRange){
      distanceToPlayer = VSize(globalPlayerController.Pawn.Location - Pawn.Location);
	  gotoState(moveToPlayerState);
	}
	else
      LatentWhatToDoNext();
NoFocus:
    Focus = none;
	//goto 'begin';
	//PopState();
}
///////////////////////////////////////////////////////////////////////////////////////
//////////////////////Functions that run in the background/////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
/**manages all of the timers in this class based on if flags are turned on/off*/
function updateTimers(float DeltaTime)
{
	//Melee Attack Cooldown
	if (attackReady_melee == false)
	{
		timer_melee += DeltaTime;
		if (timer_melee > ActiveAIPawn.cooldown_seconds_meleeAttack)
		{
			attackReady_melee = true;
			timer_melee = 0;
		}
	}
}
/*
simulated function Tick(float DeltaTime)
{
	updateTimers(DeltaTime);
}*/

function SetDashSpeed(bool bDash)
{
	if (bDash)
	{
	//	Pawn.GroundSpeed = 300;
		Pawn.GroundSpeed = DefaultChaseSpeed;		//9 m/s =450
	}
	else
		Pawn.GroundSpeed = DefaultIdleSpeed; //50
}

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	updateTimers(DeltaTime);
	distanceToPlayer = VSize(globalPlayerController.Pawn.Location - Pawn.Location);
/*
	AwareUpdateFrameCount++;
	if(AwareUpdateFrameCount >= AwareUpdateInterval)
	{
		AwareUpdateFrameCount = 0;
		UpdatePartnerInfo();
	}*/
}


function UpdatePartnerInfo()
{
	local Actor checked;
	local Vector checkcenter;

	if(NearbyDynamics.Length>0)
	{
		NearbyDynamics.Remove(0,NearbyDynamics.Length);
	}
	checkcenter = Pawn.Location;//+0.5f*AwareRadius*Normal(Velocity);
// Test location is out in front of agent
//FCheckResult* Link = GWorld->Hash->
//RestrictedOverlapCheck(GMainThreadMemStack, this, Location+0.5f*AwareRadius*Velocity.SafeNormal(), AwareRadius);

	foreach OverlappingActors( class'Actor', checked,AwareRadius ,checkcenter)
	{
	NearbyDynamics.AddItem(checked);
/*
	if(AttackPawn(checked)!=none)
	{
		if(AttackPawn(checked).NearbyDynamics.Find(self)==-1)
			AttackPawn(checked).NearbyDynamics.AddItem(self);
	}*/
	}
}


function vector CalcIntraCrowdForce()
{
	local Actor FlockActor;
	local Vector ResultForce;
	local int i;
	local Vector ToFlockActor;
	local FLOAT ToFlockActorMag;
	local FLOAT Overlap;


	local Vector FlockVel;
	local INT FlockCount;


	for(i=0; i<NearbyDynamics.Length; i++)
	{
		FlockActor = NearbyDynamics[i];
		if( FlockActor!=none&& (FlockActor != self) )
		{
			if ( ZBAIPawnBase(FlockActor)!=none)
			{
				// if it isn't an agent, have to be more aggressive about avoidance, since other guy isn't avoiding me
				FlockVel += FlockActor.Velocity;
				ToFlockActor = FlockActor.Location - ActiveAIPawn.Location;
				ToFlockActorMag = VSize(ToFlockActor);

				if( AvoidOtherRadius > ToFlockActorMag )
				{
					ToFlockActorMag = ToFlockActorMag;
					Overlap =AvoidOtherRadius - ToFlockActorMag;
					// normalize
					ToFlockActor /= fMax(0.001f, ToFlockActorMag);

					ResultForce += ((Overlap/AvoidOtherRadius) * (-ToFlockActor) * (AvoidOtherStrength));

					// FIXMESTEVE - also reduce based on velocity component that's toward this guy
				}
				FlockCount++;
			}
		}
	}
	return ResultForce;
}



function performPhysics(FLOAT DeltaTime)
{
  local Vector TotalForce;
// Update forces between crowd members
    AwareUpdateFrameCount++;
	if(AwareUpdateFrameCount >= AwareUpdateInterval)
	{
		AwareUpdateFrameCount = 0;
		UpdatePartnerInfo();
	}


	TotalForce += CalcIntraCrowdForce();

	TotalForce.Z = 0.f;

	Pawn.Velocity += TotalForce * DeltaTime;
}
DefaultProperties
{
		WanderRange=800;  //1000

		AvoidOtherRadius=180 //80

		AwareRadius=230

		AvoidOtherStrength=5200.0//1200

		AwareUpdateInterval=30

		moveToPlayerState="MoveToPlayerNoNav"
		DefaultIdleSpeed=50
		DefaultChaseSpeed=400
}
