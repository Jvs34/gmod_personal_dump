

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )

end

SWEP.PrintName			= "Stalker Beam (with ammo)"
SWEP.Base				= "swep_stalker_beam"
SWEP.Category			= "Jvs"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 500
SWEP.Primary.Ammo 		= "AR2"
SWEP.Primary.Automatic 	= true

function SWEP:HasPrimaryAmmo()
	return self:Ammo1()>=self.dt.power;	
end

function SWEP:EatAmmo()
	self:TakePrimaryAmmo(self.dt.power);
end

function SWEP:CanUpgrade()
	return self:Ammo1()>=50;	
end

function SWEP:UpgradeAmmo()
	self:TakePrimaryAmmo(50);
end