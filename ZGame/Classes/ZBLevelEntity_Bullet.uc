class ZBLevelEntity_Bullet extends ZBLevelEntity
   dependson(ZombieRushPawn);

var() int BulletNum;

//0 pistol
//1 rifle
//2 scatter gun
var() EWeaponType BulletType;

event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	local ZombieRushPawn P;
	P = ZombieRushPawn(Other);
	if( P != None )
	{
	    P.AddWeaponAmmo(BulletType,BulletNum);
	    Destroy();
	}
}
defaultproperties
{
	BulletNum=20
	BulletType=EWT_Pistol
	Begin Object Class=StaticMeshComponent Name=BulletPickUpComp
		//model of bullet
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