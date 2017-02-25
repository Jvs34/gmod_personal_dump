if (SERVER) then
	AddCSLuaFile( "shared.lua" )
	SWEP.Weight		= 5
	SWEP.AutoSwitchTo	= true
	SWEP.AutoSwitchFrom	= true
end

if ( CLIENT ) then
	SWEP.DrawAmmo			= false
	SWEP.PrintName			= "Nade launcher"
	SWEP.Author				= "Jvs"
	SWEP.DrawCrosshair		= true
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	surface.SetDrawColor( color_transparent )
	surface.SetTextColor( 255, 220, 0, alpha )
	surface.SetFont( "TitleFont" )
	local w, h = surface.GetTextSize( "a" )
	surface.SetTextPos( x + ( wide / 2 ) - ( w / 2 ),y + ( tall / 2 ) - ( h / 2 ) )
	surface.DrawText( "a" )
	end
end

SWEP.Category = "Jvs" 

SWEP.Spawnable     			= true
SWEP.AdminSpawnable  		= true
 
SWEP.ViewModel				= "models/weapons/v_smg1.mdl"
SWEP.WorldModel				= "models/weapons/w_smg1.mdl"
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic		= true

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = true
SWEP.SUPERMODE=false;
SWEP.SUPFT=true;
function SWEP:Initialize()
	if (CLIENT) then return end
	self:SetWeaponHoldType("smg")
end 

function SWEP:Holster()
return true
end

function SWEP:PrimaryAttack()

self.Weapon:SetNextPrimaryFire( CurTime() + 1 );
local ang=self.Owner:GetAimVector();
self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK );
self.Owner:SetAnimation( PLAYER_ATTACK1 );
if (CLIENT) then return end
self:ShootNade(1000,ang)

end

function SWEP:Reload()

end

function SWEP:Think()
end	
function SWEP:ShootNade(vec,angles)
		local pOwner=self.Owner;
		local pos=pOwner:GetShootPos();
		
		local nade=ents.Create("grenade_ar2");
		if !nade:IsValid() then return false end
		nade:SetPos(pos);
		nade:SetAngles(self.Owner:EyeAngles())
		nade:SetVelocity(angles*vec);
		nade:SetOwner(pOwner);
		nade:Spawn();
		self.Owner:EmitSound("Weapon_SMG1.Double");
end
function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetDeploySpeed( self.Weapon:SequenceDuration() )
	return true
end

function SWEP:SecondaryAttack()

self.Weapon:SetNextSecondaryFire( CurTime() + 1 );
local ang=self.Owner:GetAimVector();
self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK );
self.Owner:SetAnimation( PLAYER_ATTACK1 );
if (CLIENT) then return end
self:ShootNade(1000,ang+Angle(0,0.1,0))
self:ShootNade(1000,ang+Angle(0,0.0,0))
self:ShootNade(1000,ang+Angle(0,-0.1,0))


end 

