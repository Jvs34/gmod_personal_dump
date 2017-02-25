if (SERVER) then
	AddCSLuaFile( "shared.lua" )
	SWEP.Weight		= 5
	SWEP.AutoSwitchTo	= true
	SWEP.AutoSwitchFrom	= true
end

if ( CLIENT ) then
	SWEP.DrawAmmo			= true
	SWEP.PrintName			= "Rebel Ammunitioner"
	SWEP.Author				= "Jvs"
	SWEP.DrawCrosshair		= false

end

SWEP.Category = "Jvs" 

SWEP.Spawnable     			= true
SWEP.AdminSpawnable  		= true
 
SWEP.ViewModel="models/weapons/v_grenade.mdl";
SWEP.WorldModel="";

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Ammo = "none"
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
		local trace = self.Owner:GetEyeTrace()
		if trace.HitPos:Distance(self.Owner:GetShootPos()) <= 200 then

		local ent = self.Owner:GetEyeTrace().Entity
      
		if ent:IsValid() && ent:IsPlayer() then
				self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
				if CLIENT then return end
				ent:GiveAmmo(45,"smg1");
				self.Owner:SetAnimation(PLAYER_ATTACK1)
				self.Owner:Speak(true,"/male",TLK_CIT_MALE_AMMO,"/female",TLK_CIT_FEMALE_AMMO)
				self.Weapon:SetNextPrimaryFire(CurTime()+3)
		end
	end
end

function SWEP:Deploy()
self.Weapon:SendWeaponAnim( ACT_VM_THROW )
return true
end
function SWEP:Reload()

end

function SWEP:Think()

end

function SWEP:SecondaryAttack()

end
