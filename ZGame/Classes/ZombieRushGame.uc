class ZombieRushGame extends SimpleGame;

var(Zombie) float CustomGravityZ;
var string LevelTransFileName;
var bool bInTransLevel;

var EWeaponType PreWeaponType;
static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
	return class'ZGame.ZombieRushGame'; 
}

event PostLogin(PlayerController rPlayerController)
{
	local ZombiePawn lPawn;
	local ZombieSpawnNodeDistance lNode;
	//local NXActor lActor;

	super.PostLogin(rPlayerController);
    WorldInfo.WorldGravityZ = CustomGravityZ;

	/* Cycle through all the NXPawn and initialize them as well */
	foreach WorldInfo.AllPawns(class'ZombiePawn', lPawn)
	{
		lPawn.Initialize();
	}

	foreach AllActors(class'ZombieSpawnNodeDistance', lNode)
	{
		lNode.CustomInitialize();
	}
`if(`isdefined(debug))
	GetALocalPlayerController().ConsoleCommand("disableallscreenmessages");
`endif
}
function NavigationPoint FindPlayerStart( Controller Player, optional byte InTeam, optional string IncomingName )
{
  local LevelTransInfo LevelTransInfo;
  local NavigationPoint BestStart , N;
  local string CommingLevel;
	// Instance the save game state
	LevelTransInfo = new () class'LevelTransInfo';
	if (LevelTransInfo == None)
	{
		BestStart = ChoosePlayerStart(Player, InTeam);
		return BestStart;
	}
	// Attempt to deserialize the LevelTransInfo object from disk
	if (class'Engine'.static.BasicLoadObject(LevelTransInfo, LevelTransFileName, true, class'LevelTransInfo'.const.LEVELTRANS_REVISION))
	{
		// Start the map with the command line parameters required to then load the save game state
		//ConsoleCommand("start "$SaveGameState.PersistentMapFileName$"?Game="$SaveGameState.GameInfoClassName$"?SaveGameState="$FileName);
		CommingLevel = LevelTransInfo.LoadPrevLevelName();
		PreWeaponType = LevelTransInfo.LoadPrevWeaponType();
		ForEach WorldInfo.AllNavigationPoints( class 'NavigationPoint', N )
			if( string(N.Tag)~=CommingLevel )
			{
          BestStart = N;
          break;
			}
		if(BestStart == none)
		{
			BestStart = ChoosePlayerStart(Player, InTeam);
		}
	}
	else
	{
		BestStart = ChoosePlayerStart(Player, InTeam);
	}

	return BestStart;
}

function SavePrevLevelInfo()
{
	local LevelTransInfo LevelTransInfo;
  local PlayerController PC;
	// Instance the save game state
	LevelTransInfo = new () class'LevelTransInfo';
	if (LevelTransInfo == None)
	{
		return;
	}
	LevelTransInfo.SavePrevLevelName();

	LevelTransInfo.SavePrevWeaponType();

	// Serialize the save game state object onto disk
	if (class'Engine'.static.BasicSaveObject(LevelTransInfo, LevelTransFileName, true, class'LevelTransInfo'.const.LEVELTRANS_REVISION))
	{
`if(`isdefined(debug))
		// If successful then send a message
		foreach LocalPlayerControllers(class'PlayerController', PC)
		{
			PC.ClientMessage("Saved game state to "$LevelTransFileName$".", 'System');
		}
`endif

	}

}

function ClearTempLevelInfo()
{
	local LevelTransInfo LevelTransInfo;
	// Instance the save game state
	LevelTransInfo = new () class'LevelTransInfo';
	if (class'Engine'.static.BasicLoadObject(LevelTransInfo, LevelTransFileName, true, class'LevelTransInfo'.const.LEVELTRANS_REVISION))
	{
		LevelTransInfo.ClearPrevLevelName();
		LevelTransInfo.ClearPrevWeaponType();
		class'Engine'.static.BasicSaveObject(LevelTransInfo, LevelTransFileName, true, class'LevelTransInfo'.const.LEVELTRANS_REVISION);
	}
}
function PawnDied()
{
	local PlayerController PC;
	foreach LocalPlayerControllers(class'PlayerController', PC)
	{
		PC.ClientSetCameraFade(true,MakeColor(0,0,0,255),vect2d(0,1),2.0);
	}
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

	CustomGravityZ=-900//2500
  LevelTransFileName="LevelTrans.bin"
}
