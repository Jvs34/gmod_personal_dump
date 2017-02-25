if (SERVER) then
	AddCSLuaFile( "shared.lua" )
	SWEP.Weight		= 5
	SWEP.AutoSwitchTo	= true
	SWEP.AutoSwitchFrom	= true
	SWEP.Slot				= 0
	SWEP.SlotPos			= 5
end

if ( CLIENT ) then
	SWEP.DrawAmmo			= true
	SWEP.PrintName			= "BrickBat"
	SWEP.Author				= "Jvs"
	SWEP.DrawCrosshair		= true
end

SWEP.Category = "Jvs" 

SWEP.Spawnable     			= true
SWEP.AdminSpawnable  		= true
 
SWEP.ViewModel="models/weapons/v_grenade.mdl";
SWEP.WorldModel="models/props_junk/Rock001a.mdl";

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic		= false

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo = false
SWEP.Secondary.Automatic = false

SWEP.Lancio="models/props_junk/Rock001a.mdl"
function SWEP:Initialize()
	if (CLIENT) then return end
end 

function SWEP:Holster()
	if (CLIENT) then return end
	return true
end

function SWEP:PrimaryAttack()
if(CLIENT) then return end
		if ( util.IsValidModel(self.Lancio) ) then
			self.Weapon:SendWeaponAnim( ACT_VM_THROW )
			local cammo = ents.Create("prop_physics")
			cammo:SetModel(self.Lancio);
			local vecAiming = self.Owner:GetAimVector();
			local vecVelocity = vecAiming * 1000.0;
			local vecSrc	 = self.Owner:GetShootPos();
			cammo:SetPos( self.Owner:EyePos() + (self.Owner:GetAimVector() * 64)  );
			cammo:Spawn();
			
			cammo:GetPhysicsObject():AddGameFlag( FVPHYSICS_WAS_THROWN );
			cammo:GetPhysicsObject():SetVelocity( vecVelocity );
			self.Weapon:SetNextPrimaryFire(CurTime() + 1.1)
			self.Lancio=""
		end
end

function SWEP:Deploy()
self.Weapon:SendWeaponAnim( ACT_VM_THROW )
return true
end
function SWEP:Reload()

end
function SWEP:SecondaryAttack()
	if SERVER then
		local pos = self.Owner:GetShootPos() 
		local ang = self.Owner:GetAimVector() 
		local tracedata = {} 
		tracedata.start = pos 
		tracedata.endpos = pos+(ang*80) 
		tracedata.filter = self.Owner 
		local trace = util.TraceLine(tracedata) 
		if trace.Entity and trace.Entity:IsValid() and self.Lancio == "" and trace.Entity:GetPhysicsObject():GetMass( )< 50 && string.find(trace.Entity:GetClass(),"prop_physics") then
			self.Lancio=trace.Entity:GetModel()
			trace.Entity:Remove();
		end  
			
	end
end
