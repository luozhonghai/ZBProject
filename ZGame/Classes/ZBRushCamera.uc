class ZBRushCamera extends ZBPlayerCamera;


event PostBeginPlay()
{
	local class<ZBCameraTypeAbstract> lCameraType;

	Super.PostBeginPlay();

	ClientMessage("PostBeginPlay:"$CameraStyle);

	CurrentCameraType = CreateCamera(class 'ZBCameraTypeRushFix');


}
DefaultProperties
{
	DefaultCameraType="ZGame.ZBCameraTypeRushFix"
}
