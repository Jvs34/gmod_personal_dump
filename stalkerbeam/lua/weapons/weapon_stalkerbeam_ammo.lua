AddCSLuaFile()

SWEP.PrintName			= "Stalker Beam (with ammo)"
DEFINE_BASECLASS( "weapon_stalkerbeam" )

if CLIENT then
	resource.AddFile("materials/entities/weapon_stalkerbeam_ammo.png")
	killicon.Add( "weapon_stalkerbeam_ammo" , "hud/killicons/weapon_stalkerbeam", color_white )
end

SWEP.Category			= "Jvs"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 500
SWEP.Primary.Ammo 		= "AR2"
SWEP.Primary.Automatic 	= true

function SWEP:HasPrimaryAmmo()
	return self:Ammo1()>=self:GetPower()	
end

function SWEP:EatAmmo()
	self:TakePrimaryAmmo(self:GetPower())
end

function SWEP:CanUpgrade()
	return self:Ammo1() >= 50
end

function SWEP:UpgradeAmmo()
	self:TakePrimaryAmmo( 50 )
end