class ZombieRushPawn extends ZombiePlayerPawn;


enum EWeaponType
  {
	EWT_None,
	EWT_Axe,
	EWT_Pistol,
	EWT_Rifle,
	EWT_ScatterGun,
};

var int TotalAmmo;
var array<int> AmmoNum;
var array<ZBWeapon> WeaponList;
  
// Only in walking status, won't be tripped over by some blockades
var private bool  bWalkingStatus;
var bool bHitWall;

var actor interactActor;

var EWeaponType CurrentWeaponType;

event RanInto(Actor Other)
{
	super.RanInto(Other);										
}
event Initialize()
{
	// Ensure Pawn initializes first
	super.Initialize();		
	//Add all weapons and switch to the certain
	AddRushGameWeapons();
}
function AddRushGameWeapons()
{	
	WeaponList[1] = Spawn(class'ZBWeaponAxe', , , self.Location);
	WeaponList[2] = Spawn(class'ZBWeaponGun', , , self.Location);
	InvManager.AddInventory( WeaponList[1],true );
	WeaponList[1].bCanThrow = false; // don't allow default weapon to be thrown out
	InvManager.AddInventory( WeaponList[2],true );
	WeaponList[2].bCanThrow = false; // don't allow default weapon to be thrown out
	super.SetActiveWeapon(WeaponList[0]);
}
function SetActiveWeaponByType(EWeaponType PendingType)
{
	CurrentWeaponType = PendingType;
	super.SetActiveWeapon(WeaponList[PendingType]);
}
function ConsoleSetActiveWeaponByType(EWeaponType PendingType)
{
	CurrentWeaponType = PendingType;
	super.SetActiveWeapon(WeaponList[PendingType]);
}
function AddWeaponAmmo(EWeaponType PendingType, int Num)
{
	if(Num>0)
	  AmmoNum[PendingType] += Num;
}	

event Bump( Actor Other, PrimitiveComponent OtherComp, Vector HitNormal )
{
	super.Bump(Other,OtherComp,HitNormal);
	//`log("Bumping");
    if(InterpActor(Other)!=None)
	{
		if(Other.tag == 'dingci_01')
	        ZombieRushPC(Controller).EntityBuffer.AddDingciEffect();
	}
}

event HitWall( vector HitNormal, actor Wall, PrimitiveComponent WallComp )
{
	//use to find avoid direction when hit wall
	local Vector ForwardTraceVector,X,Y,Z;
	super.HitWall(HitNormal,Wall,WallComp);
	
	if(bHitWall)
	   return;
	bHitWall = true;
	
	//PlayerController(Controller).ClientMessage("Wall.Tag"@Wall.Tag@Wall);
	if(InterpActor(Wall)!=None)
	{
		if(bWalkingStatus)
		   return;
		   
		if(Wall.Tag=='luzhang_01' || Wall.Tag=='luzhang')
		{
		   if(abs(Vector(Wall.Rotation) dot vector(Rotation)) < 0.75)
	        TripOverByBlockade();
	       else
	        RanintoBlockade(-HitNormal);
	  }
	   else if(Wall.Tag == 'zhangai_02')
	    		TripOverByBlockade();
	    else if(Wall.tag == 'juma_01')
	        CollideCheval();
	    else if(Wall.tag == 'dingci_01')
	        ZombieRushPC(Controller).EntityBuffer.AddDingciEffect();
	 }

	else if(ZBLevelEntity_BlockadeTrip(Wall)!=None)
	{
		if(bWalkingStatus)
		   return;
		if(ZBLevelEntity_BlockadeTrip(Wall).BlockadeType==0)
		{
		   if(abs(Vector(Wall.Rotation) dot vector(Rotation)) < 0.75)
			TripOverByBlockade();
		   else
	        RanintoBlockade(-HitNormal);
		}
		if(ZBLevelEntity_BlockadeTrip(Wall).BlockadeType==1) //"luzhang_03"
		{
			/*
			if(abs(Vector(Wall.Rotation) dot vector(Rotation)) > 0.4)
	          RanintoBlockade(HitNormal);*/
		}
	 }
	else if(ZBLevelEntity_Cheval(Wall)!=None)
	{
       CollideCheval();
	 }
	 else
	 {
	 	GetAxes(Rotation,X,Y,Z);
	 	Y *= GetCollisionRadius();
	 	Z *= GetCollisionHeight();
	 	ForwardTraceVector = Vector(Rotation) * (GetCollisionRadius() + 150);
	 	// need other content !!!!!not trace pawns
	 	if(FastTrace(ForwardTraceVector + Location + Y - Z, Location + Y - Z))
	 		RanOffBlockade(HitNormal);
	 	else if(FastTrace(ForwardTraceVector + Location - Y - Z, Location - Y - Z))
	 	  RanOffBlockade(HitNormal,true);
	 	else
	 	{
	 		ZombieRushPC(Controller).GotoState('DoingSpecialMove');
	 		DoSpecialMove(SM_RunIntoWall,true);
	 	}
	 }
}

event Landed(vector HitNormal, Actor FloorActor)
{
//	bHitWall = false;
Super.Landed(HitNormal, FloorActor);
    GotoState('IgnoreWall');
	if(SpecialMove==SM_PHYS_Trans_Jump)
	{
		ZSM_JumpStart(SpecialMoves[SpecialMove]).Landed(true);
	}
	if(VerifySMHasBeenInstanced(SM_PHYS_Trans_Jump))
	{
		if (SpecialMove == SM_None)  //µ¥¶ÀÂäµØÊ± SpecialMove = SM_None
		{ 
			SpecialMove=SM_PHYS_Trans_Jump;
		}
       ZSM_JumpStart(SpecialMoves[SM_PHYS_Trans_Jump]).Landed(false);
	}

	bIsJumping=false;
	
	//CylinderComponent.SetCylinderSize(30,46);  cat
  //  CylinderComponent.SetCylinderSize(35,86);
	EndSpecialMove();
	super.Landed(HitNormal,FloorActor);
}

State IgnoreWall
{
	ignores HitWall,Landed;
	event BeginState(name previousStateName)
	{
		`log("IgnoreWall");
	}
	begin:
	Sleep(1.0);
	GotoState('');
}
function TripOverByBlockade()
{
	`log("TripOverByBlockade");

	setphysics(PHYS_Interpolating);
	SetCollision(false,false);
    bCollideWorld = false;
	self.DoSpecialMove(SM_TripOver);
}

function CollideCheval()
{
	   PlayerHealth=0;
	   ZombieRushPC(Controller).GotoState('DoingSpecialMove');
	   DoSpecialMove(SM_Combat_GetHurt,true,none,1);

}

function  RanintoBlockade(vector HitNormal,optional bool bInverse)
{
	ZombieRushPC(Controller).PawnRanintoBlockade(HitNormal,bInverse);
}

function RanOffBlockade(vector HitNormal,optional bool bInverse)
{
	ZombieRushPC(Controller).PawnRanOffBlockade(HitNormal,bInverse);
}
///burn by fire collection
function  BurnToDeath()
{
	ZombieRushPC(Controller).GotoState('DoingSpecialMove');
	DoSpecialMove(SM_Combat_GetHurt,true);
}


function SetWalkingStatus(bool flag)
{
	bWalkingStatus = flag;
}
function bool GetWalkingStatus()
{
	return bWalkingStatus;
}

function RestorePower(float amount)
{
	PlayerPower+=amount;

	if (PlayerPower>=100)
	{
		PlayerPower=100;
	}
}


//AnimNotify
function AnimNotify_Shoot()
{
	if(IsDoingSpecialMove(SM_GunAttack))
	   ZSM_GunFire(SpecialMoves[SpecialMove]).PlayFire();
}
defaultproperties
{
	WeaponList(0)=None

	TotalAmmo=100
	AmmoNum(0)=-1
	AmmoNum(1)=-1
	AmmoNum(2)=5
	AmmoNum(3)=10
	AmmoNum(4)=10
	PlayerPower=100
	
	WalkableFloorZ=0.78
	MaxStepHeight=26.0
	MaxJumpHeight=49.0


  //AccelRate = 0
  WalkJumpScale=100       //45
	AirControl=+0.35


}