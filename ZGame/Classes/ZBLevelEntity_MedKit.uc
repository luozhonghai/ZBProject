class ZBLevelEntity_MedKit extends ZBLevelEntity;

var() int PowerAmount;
//add health instant
event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	local ZombiePlayerPawn P;
	P = ZombiePlayerPawn(Other);
	if( P != None )
	{
	   // givebullettopanw();
	  P.RestorePower(PowerAmount);
	   Destroy();
	}
}

defaultproperties
{
	PowerAmount=40
	CollisionComponent=CollisionCylinder0
	Begin Object Class=StaticMeshComponent Name=BulletPickUpComp
		//model of MedKit
		StaticMesh=StaticMesh'Pickups.Armor_ShieldBelt.Mesh.S_UN_Pickups_Shield_Belt'
		Scale3D=(X=1.5,Y=1.5,Z=1.5)
		AlwaysLoadOnClient=TRUE
		AlwaysLoadOnServer=TRUE

		CastShadow=FALSE
		bCastDynamicShadow=FALSE
		bAcceptsLights=TRUE
		bForceDirectLightMap=TRUE
		LightingChannels=(BSP=TRUE,Dynamic=FALSE,Static=TRUE,CompositeDynamic=TRUE)
		LightEnvironment=DroppedPickupLightEnvironment

		CollideActors=FALSE
		MaxDrawDistance=7000
	End Object
	EnitityMesh=BulletPickUpComp
	Components.Add(BulletPickUpComp)
}