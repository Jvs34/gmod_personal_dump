if (SERVER) then
	AddCSLuaFile( "shared.lua" )
	SWEP.Weight		= 5
	SWEP.AutoSwitchTo	= true
	SWEP.AutoSwitchFrom	= true
end

if ( CLIENT ) then
	SWEP.DrawAmmo			= true
	SWEP.PrintName			= "Combine ball Grenade"
	SWEP.Author				= "Jvs"
	SWEP.DrawCrosshair		= false
	killicon.AddFont( "weapon_grenade_combine", "HL2MPTypeDeath", 8, Color( 255, 80, 0, 255 ) )

end

SWEP.Category = "Jvs" 

SWEP.Spawnable     			= true
SWEP.AdminSpawnable  		= true
 
SWEP.ViewModel="models/weapons/v_grenade.mdl";
SWEP.WorldModel="models/Items/combine_rifle_ammo01.mdl";

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Ammo = "AR2AltFire"
SWEP.Primary.Automatic		= false

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo = false
SWEP.Secondary.Automatic = false

function SWEP:Initialize()
	if (CLIENT) then return end
	self:SetWeaponHoldType("slam")
end 

function SWEP:Holster()
	return true
end

function SWEP:PrimaryAttack()
	if ( self:Ammo1() > 0 ) then
	self.Weapon:SendWeaponAnim( ACT_VM_THROW )
	local cball = ents.Create("grenade_combball")  
     local vecAiming = self.Owner:GetAimVector();
	 local vecVelocity = vecAiming * 1000.0;
	local vecSrc	 = self.Owner:GetShootPos();
	if (CLIENT) then return end
	cball:SetOwner( self.Owner );
	cball:SetPhysicsAttacker( self.Owner );
	cball:SetPos( vecSrc );
	cball:Spawn();
	cball:GetPhysicsObject():SetVelocity( vecVelocity );
	self.Weapon:SetNextPrimaryFire(CurTime() + 1.1)
	self.Weapon:SetNextSecondaryFire(CurTime() + 1.1)
	self:TakePrimaryAmmo( 1 );
	end
end

function SWEP:Deploy()
self.Weapon:SendWeaponAnim( ACT_VM_THROW )
		
return true
end
function SWEP:Reload()

end
function SWEP:SecondaryAttack()
if ( self:Ammo1() > 0 ) then
	self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	local cball = ents.Create("grenade_combball")  
     local vecAiming = self.Owner:GetAimVector();
	 local vecVelocity = vecAiming * 300.0;
	local vecSrc	 = self.Owner:GetShootPos();
	if (CLIENT) then return end
	cball:SetOwner( self.Owner );
	cball:SetPhysicsAttacker( self.Owner );
	cball:SetPos( vecSrc );
	cball:Spawn();
	cball:GetPhysicsObject():SetVelocity( vecVelocity );
	self.Weapon:SetNextSecondaryFire(CurTime() + 1.1)
	self.Weapon:SetNextPrimaryFire(CurTime() + 1.1)
		self:TakePrimaryAmmo( 1 );
	end
end
