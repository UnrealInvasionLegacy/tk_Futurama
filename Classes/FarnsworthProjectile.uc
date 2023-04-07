class FarnsworthProjectile extends SeekingRocketProj;

//REWRITE THIS ENTIRE CLASS USING PROJECTILE AS A PARENT RATHER THAN SEEKINGROCKETPROJ

var Emitter FarnsworthProjectileEmitter;

simulated function Destroyed() 
{
	if (FarnsworthProjectileEmitter != None)
        FarnsworthProjectileEmitter.Destroy();
	
    Super.Destroyed();
}

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer)
	{
		FarnsworthProjectileEmitter = Spawn(class'FarnsworthProjectileFX',self);
        FarnsworthProjectileEmitter.SetBase(self);
	}

	Dir = vector(Rotation);
	Velocity = speed * Dir;

    if ( Level.bDropDetail )
	{
		bDynamicLight = false;
		LightType = LT_None;
	}
	 SetTimer(0.1, true);
	Super(Projectile).PostBeginPlay();
}

simulated function Landed( vector HitNormal )
{
	Explode(Location,HitNormal);
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if ( (Other != instigator) && (!Other.IsA('Projectile') || Other.bProjTarget) ) 
		Explode(HitLocation,Vect(0,0,1));
}

function BlowUp(vector HitLocation)
{
	HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
	MakeNoise(1.0);
}

simulated function Explode(vector HitLocation, vector HitNormal) 
{
	PlaySound(sound'WeaponSounds.BExplosion3',,2.5*TransientSoundVolume);
	spawn(class'FlakExplosion',,,HitLocation + HitNormal*16 );
	spawn(class'FlashExplosion',,,HitLocation + HitNormal*16 );
	if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
		Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
 	
	BlowUp(HitLocation);
	Destroy(); 
}

simulated function Timer()
{
    local vector ForceDir;
    local float VelMag;

    if ( InitialDir == vect(0,0,0) )
        InitialDir = Normal(Velocity);
         
	Acceleration = vect(0,0,0);
    Super.Timer();
    if ( (Seeking != None) && (Seeking != Instigator) ) 
    {
		// Do normal guidance to target.
		ForceDir = Normal(Seeking.Location - Location);
		
		if( (ForceDir Dot InitialDir) > 0 )
		{
			VelMag = VSize(Velocity);
		
			// track vehicles better
			if ( Seeking.Physics == PHYS_Karma )
				ForceDir = Normal(ForceDir * 4.8 * VelMag + Velocity);
			else
				ForceDir = Normal(ForceDir * 4.5 * VelMag + Velocity);
			Velocity =  VelMag * ForceDir;  
			Acceleration += 5 * ForceDir; 
		}
		// Update rocket so it faces in the direction its going.
		SetRotation(rotator(Velocity));
    }
}

defaultproperties
{
     Speed=1000.000000
     MaxSpeed=1000.000000
     Damage=300.000000
     DamageRadius=140.000000
     MyDamageType=Class'tk_Futurama.DamTypeFarnsworthProjectile'
     DrawType=DT_Sprite
     bHidden=True
     LifeSpan=6.000000
     Texture=Texture'XEffectMat.Link.link_muz_red'
     DrawScale=0.300000
     Style=STY_Translucent
}
