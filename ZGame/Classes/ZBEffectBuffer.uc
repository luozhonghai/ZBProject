class ZBEffectBuffer extends Actor;

var ZombieRushPC MyPCOwner;
var ZombieRushPawn MyPawn;
var float VelocityScale;
event PostBeginPlay()
{
	MyPCOwner = ZombieRushPC(Owner);	
	VelocityScale = 1.0;
}
function AddDingciEffect()
{
	if(IsTimerActive('RemoveDingciEffect'))
	 return;
	 
	if(MyPawn == None)
	  MyPawn = ZombieRushPawn(MyPCOwner.Pawn);

	///////Set Corresponding Anim

	///////////
	MyPawn.CustomTakeDamage(10);
	VelocityScale = 0.5;
	SetTimer(20,false,'RemoveDingciEffect');
}
function RemoveDingciEffect()
{
	///////Reset Corresponding Anim

	///////////

   	VelocityScale = 1.0;
}
event Destroyed()
{
	super.Destroyed();
	ClearTimer('RemoveDingciEffect');
}