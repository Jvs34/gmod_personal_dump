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
	SWEP.PrintName			= "Ammo thrower"
	SWEP.Author				= "Jvs"
	SWEP.DrawCrosshair		= false
end

SWEP.Category = "Jvs" 

SWEP.Spawnable     			= true
SWEP.AdminSpawnable  		= true
 
SWEP.ViewModel="models/weapons/v_grenade.mdl";
SWEP.WorldModel="models/weapons/w_grenade.mdl";

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Ammo = "none"
SWEP.Primary.AmmoTh = "Pistol"
SWEP.Primary.Automatic		= true

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo = false
SWEP.Secondary.Automatic = false

function SWEP:Initialize()
	if (CLIENT) then return end
	self:SetWeaponHoldType("grenade")
	
end 

function SWEP:Holster()
	if (CLIENT) then return end
	return true
end

function SWEP:PrimaryAttack()

	if (self.Primary.AmmoTh == "Pistol") then//pistola
		if ( self.Owner:GetAmmoCount(self.Primary.AmmoTh) > 19 ) then
		self.Weapon:SendWeaponAnim( ACT_VM_THROW )
		local cammo = ents.Create("item_ammo_pistol")  
		local vecAiming = self.Owner:GetAimVector();
		local vecVelocity = vecAiming * 1000.0;
		local vecSrc	 = self.Owner:GetShootPos();
		if (CLIENT) then return end
		cammo:SetPos( self.Owner:EyePos() + (self.Owner:GetAimVector() * 64)  );
		cammo:Spawn();
		cammo:GetPhysicsObject():SetVelocity( vecVelocity );
		self.Weapon:SetNextPrimaryFire(CurTime() + 1.1)
		self.Owner:RemoveAmmo (20, "Pistol")
		end
	elseif (self.Primary.AmmoTh == "357") then //magnum
		if ( self.Owner:GetAmmoCount(self.Primary.AmmoTh) > 5 ) then
		self.Weapon:SendWeaponAnim( ACT_VM_THROW )
		local cammo = ents.Create("item_ammo_357")  
		local vecAiming = self.Owner:GetAimVector();
		local vecVelocity = vecAiming * 1000.0;
		local vecSrc	 = self.Owner:GetShootPos();
		if (CLIENT) then return end
		cammo:SetPos( self.Owner:EyePos() + (self.Owner:GetAimVector() * 64)  );
		cammo:Spawn();
		cammo:GetPhysicsObject():SetVelocity( vecVelocity );
		self.Weapon:SetNextPrimaryFire(CurTime() + 1.1)
		self.Owner:RemoveAmmo (6, "357")
		end
	elseif (self.Primary.AmmoTh == "smg1") then //smg1
		if ( self.Owner:GetAmmoCount(self.Primary.AmmoTh) > 44 ) then
		self.Weapon:SendWeaponAnim( ACT_VM_THROW )
		local cammo = ents.Create("item_ammo_smg1")  
		local vecAiming = self.Owner:GetAimVector();
		local vecVelocity = vecAiming * 1000.0;
		local vecSrc	 = self.Owner:GetShootPos();
		if (CLIENT) then return end
		cammo:SetPos( self.Owner:EyePos() + (self.Owner:GetAimVector() * 64)  );
		cammo:Spawn();
		cammo:GetPhysicsObject():SetVelocity( vecVelocity );
		self.Weapon:SetNextPrimaryFire(CurTime() + 1.1)
		self.Owner:RemoveAmmo (45, "smg1")
		
		end
	elseif (self.Primary.AmmoTh == "AR2") then //ar2
		if ( self.Owner:GetAmmoCount(self.Primary.AmmoTh) > 19 ) then
		self.Weapon:SendWeaponAnim( ACT_VM_THROW )
		local cammo = ents.Create("item_ammo_ar2")  
		local vecAiming = self.Owner:GetAimVector();
		local vecVelocity = vecAiming * 1000.0;
		local vecSrc	 = self.Owner:GetShootPos();
		if (CLIENT) then return end
		cammo:SetPos( self.Owner:EyePos() + (self.Owner:GetAimVector() * 64)  );
		cammo:Spawn();
		cammo:GetPhysicsObject():SetVelocity( vecVelocity );
		self.Weapon:SetNextPrimaryFire(CurTime() + 1.1)
		self.Owner:RemoveAmmo (20, "AR2")
		end
	elseif (self.Primary.AmmoTh == "Buckshot") then //fucile a pompa
		if ( self.Owner:GetAmmoCount(self.Primary.AmmoTh) > 19 ) then
		self.Weapon:SendWeaponAnim( ACT_VM_THROW )
		local cammo = ents.Create("item_box_buckshot")  
		local vecAiming = self.Owner:GetAimVector();
		local vecVelocity = vecAiming * 1000.0;
		local vecSrc	 = self.Owner:GetShootPos();
		if (CLIENT) then return end
		cammo:SetPos( self.Owner:EyePos() + (self.Owner:GetAimVector() * 64)  );
		cammo:Spawn();
		cammo:GetPhysicsObject():SetVelocity( vecVelocity );
		self.Weapon:SetNextPrimaryFire(CurTime() + 1.1)
		self.Owner:RemoveAmmo (20, "Buckshot")
		
		end
	elseif (self.Primary.AmmoTh == "XBowBolt") then //balestra
		if ( self.Owner:GetAmmoCount(self.Primary.AmmoTh) > 5 ) then
		self.Weapon:SendWeaponAnim( ACT_VM_THROW )
		local cammo = ents.Create("item_ammo_crossbow")  
		local vecAiming = self.Owner:GetAimVector();
		local vecVelocity = vecAiming * 1000.0;
		local vecSrc	 = self.Owner:GetShootPos();
		if (CLIENT) then return end
		cammo:SetPos( self.Owner:EyePos() + (self.Owner:GetAimVector() * 64)  );
		cammo:Spawn();
		cammo:GetPhysicsObject():SetVelocity( vecVelocity );
		self.Weapon:SetNextPrimaryFire(CurTime() + 1.1)
		self.Owner:RemoveAmmo (6, "XBowBolt")	
		end
	end
end

function SWEP:Deploy()
self.Weapon:SendWeaponAnim( ACT_VM_THROW )
return true
end
function SWEP:Reload()

end
function SWEP:SecondaryAttack()
	if (self.Primary.AmmoTh == "Pistol") then//pistola
		self.Primary.AmmoTh = "357"
	elseif (self.Primary.AmmoTh == "357") then //magnum
		self.Primary.AmmoTh = "smg1"
	elseif (self.Primary.AmmoTh == "smg1") then //smg1
		self.Primary.AmmoTh = "AR2"
	elseif (self.Primary.AmmoTh == "AR2") then //ar2
		self.Primary.AmmoTh = "Buckshot"
	elseif (self.Primary.AmmoTh == "Buckshot") then //fucile a pompa
		self.Primary.AmmoTh = "XBowBolt"
	elseif (self.Primary.AmmoTh == "XBowBolt") then //balestra
		self.Primary.AmmoTh = "Pistol"
	else self.Primary.AmmoTh = "Pistol" end
	self.Weapon:SetNextSecondaryFire(CurTime() + 1.1)
end
