if (SERVER) then
	AddCSLuaFile( "shared.lua" )

	SWEP.AutoSwitchTo	= true
	SWEP.AutoSwitchFrom	= true
end

if ( CLIENT ) then
	SWEP.DrawAmmo			= true
	SWEP.PrintName			= "Alyx Gun"
	SWEP.Author				= "Jvs"
	SWEP.DrawCrosshair		= true
end

SWEP.Category = "Jvs" 
SWEP.Slot				= 1
SWEP.SlotPos			= 5
SWEP.Weight				= 5
SWEP.Spawnable     			= true
SWEP.AdminSpawnable  		= true
 
SWEP.ViewModel 			= "models/weapons/v_ocpalx.mdl"
SWEP.WorldModel 			= "models/weapons/w_alyx_gun.mdl"

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Automatic		= false

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo = false
SWEP.Secondary.Automatic = false

function SWEP:Initialize()
	if (CLIENT) then return end
	self:SetWeaponHoldType("pistol")
end 

function SWEP:Holster()
	return true
end


function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetDeploySpeed( 1 )
	return true
end

function SWEP:Think()
	if CLIENT then return end
end

function SWEP:PrimaryAttack()

	if ( !self:CanPrimaryAttack() ) then return end
	self.Weapon:EmitSound("weapons/swep_alyxgun/alyxgun.wav")
	self:ShootBullet( 15, 1, 0.02 )
	
	self:TakePrimaryAmmo( 1 )
	local viewPunch;
	viewPunch = Angle( 0, 0, 0 );

	viewPunch.x = math.Rand( .2, -.2 );
	viewPunch.y = math.Rand( -.2, .2 );
	viewPunch.z = 0.0;
	if(self.Owner:IsPlayer())then
	self.Owner:ViewPunch(viewPunch );
	end
	self.Weapon:SetNextPrimaryFire(CurTime()+0.1)
end

function SWEP:CanPrimaryAttack()

	if ( self.Weapon:Clip1() <= 0 ) then
		self:EmitSound( "Weapon_Pistol.Empty" )
		self:SetNextPrimaryFire( CurTime() + 0.5 )
		self:Reload()
		return false
	end
	return true
end

function SWEP:Reload()
	self.Weapon:DefaultReload( ACT_VM_RELOAD );
	if(self:Clip1()<self.Primary.ClipSize && self.Owner:GetAmmoCount(self.Primary.Ammo)!=0)then
		self.Weapon:EmitSound("weapons/swep_alyxgun/alyxgun_reload.wav")
	end
end

//Overriden because we don't want a shotgun!
function SWEP:SecondaryAttack()
end
//Overriden because i need the tracer every boolet.
function SWEP:ShootBullet( damage, num_bullets, aimcone )
	
	local bullet = {}
	bullet.Num 		= num_bullets
	bullet.Src 		= self.Owner:GetShootPos()			// Source
	bullet.Dir 		= self.Owner:GetAimVector()			// Dir of bullet
	bullet.Spread 	= Vector( aimcone, aimcone, 0 )		// Aim Cone
	bullet.Tracer	= 1									// Show a tracer on every x bullets 
	bullet.Force	= damage*0.5									// Amount of force to give to phys objects
	bullet.Damage	= damage
	bullet.AmmoType = "Pistol"
	self.Owner:FireBullets( bullet )
	self:ShootEffects()
end