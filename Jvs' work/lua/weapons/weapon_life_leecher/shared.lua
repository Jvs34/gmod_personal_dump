if (SERVER) then
	AddCSLuaFile( "shared.lua" )
	SWEP.Weight		= 5
	SWEP.AutoSwitchTo	= true
	SWEP.AutoSwitchFrom	= true
	SWEP.Slot				= 0
	SWEP.SlotPos			= 5
end

if ( CLIENT ) then
	SWEP.DrawAmmo			= false
	SWEP.PrintName			= "Life Leecher"
	SWEP.Author				= "Jvs"
	SWEP.Instructions = "Primary: Launch a life Leecher."
	SWEP.DrawCrosshair		= true
end

SWEP.Category = "Jvs" 

SWEP.Spawnable     			= false
SWEP.AdminSpawnable  		= true
 
SWEP.ViewModel="models/weapons/v_pistol.mdl";
SWEP.WorldModel="models/weapons/w_pistol.mdl";

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic		= true

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo = false
SWEP.Secondary.Automatic = false


function SWEP:Initialize()
	if (CLIENT) then return end
	self.LL=nil;
end 
function SWEP:Think()
if (CLIENT) then return end

end

function SWEP:Holster()
	if (CLIENT) then return end
	if(self.LL && IsValid(self.LL))then
	return false
	else
		return true
	end
end

function SWEP:PrimaryAttack()
	if(self.LL && IsValid(self.LL))then
		self.Weapon:SendWeaponAnim(ACT_VM_DRYFIRE);
	else
		self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK);
		self.LL=ents.Create("sent_life_leecher")
		self.LL:SetOwner(self.Owner);
		self.LL.Owner=self.Owner;
		self.LL:SetPos(self:GetPos()+Vector(0,0,50));
		self.LL:Spawn();
		self.LL.Owner=self.Owner;
		self.LL:Activate();
		self.LL.Owner=self.Owner;
		self.LL:GetPhysicsObject():SetVelocity( self.Owner:GetAimVector() * 5000.0 );
		self.LL.Owner=self.Owner;
		constraint.Elastic( self.Owner, self.LL, 0, 0, Vector( 0, 0, 0 ) , Vector( 0, 0, 0 ) , 0, 0, 0, "cable/cable2", 3, 0 )
	end
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
end

function SWEP:SecondaryAttack()

end

function SWEP:Deploy()
self:SetDeploySpeed(1);
self.Weapon:SendWeaponAnim( ACT_VM_DEPLOY )


return true
end

function SWEP:Reload()

end