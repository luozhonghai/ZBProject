class ZombieRushGame extends SimpleGame;

var(Zombie) float CustomGravityZ;
static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
	return class'ZGame.ZombieRushGame'; 
}

event PostLogin(PlayerController rPlayerController)
{
	local ZombiePawn lPawn;
	//local NXActor lActor;

	super.PostLogin(rPlayerController);
    WorldInfo.WorldGravityZ = CustomGravityZ;

	/* Cycle through all the NXPawn and initialize them as well */
	foreach WorldInfo.AllPawns(class'ZombiePawn', lPawn)
	{
		lPawn.Initialize();
	}

	//foreach AllActors(class'ZombieSpawnNode')
}

function PawnDied()
{
	SetTimer(2.0f,false,'RestartGame');
}
function RestartGame()
{
	GetalocalPlayerController().Consolecommand("restartlevel");
}
DefaultProperties
{
	DefaultPawnClass=class'ZombieRushPawn'
	PlayerControllerClass=class'ZombieRushPC'
	HUDType=class'ZombieHud'

	CustomGravityZ=-1000//2500
}
