if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	SWEP.Weight				= 5
	SWEP.Slot				= 5
	SWEP.SlotPos			= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end

if ( CLIENT ) then

	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true
	SWEP.ViewModelFOV		= 85
	SWEP.ViewModelFlip		= false

end

SWEP.Category				= "Jvs"
	SWEP.Slot				= 5
	SWEP.SlotPos			= 5
SWEP.PrintName		= "Rebel Medikit"
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= true
SWEP.Weight			= 5
SWEP.AutoSwitchTo	= false
SWEP.AutoSwitchFrom	= false

SWEP.Author			= "Jvs,credits to the View model creator."
SWEP.Contact		= "jvsthebest@hotmail.it"
SWEP.Purpose		= "Healing Rebels"

SWEP.BatteryPerUse=1
SWEP.HealPerUse=10;

SWEP.Instructions		= "Heals "..SWEP.HealPerUse.." and\nconsumes "..SWEP.BatteryPerUse.." battery per use."

SWEP.Spawnable		= true
SWEP.AdminSpawnable	= true

SWEP.ViewModel		= "models/items/v_medkit2.mdl"
SWEP.WorldModel		= "models/items/w_medkit.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"



function SWEP:Reload()

end

function SWEP.Think()
end

function SWEP:Initialize()
	if ( SERVER ) then
		self:SetWeaponHoldType( "slam" )
	end
end 

function SWEP:Holster()
	if (CLIENT) then return end
	return true
end
function SWEP:Deploy()
return true
end

function SWEP:PrimaryAttack()
	if ( self.Owner:Armor() > self.BatteryPerUse ) then

		local trace = self.Owner:GetEyeTrace()
		if trace.HitPos:Distance(self.Owner:GetShootPos()) <= 100 then

			local ent2 = self.Owner:GetEyeTrace().Entity
      
			if (ent2:IsValid() && (ent2:IsPlayer() || ent2:IsNPC())) then
				local current = ent2:Health()
				local max = ent2:GetMaxHealth()
				if(current>=max)then
				elseif current <= (max - self.HealPerUse) then
				self:Heal()
				ent2:SetHealth( current + self.HealPerUse )
				self.Owner:SetArmor(self.Owner:Armor()-self.BatteryPerUse)
				self.Weapon:SetNextPrimaryFire(CurTime() + 1.5)
				else
				self:Heal()
				ent2:SetHealth( max )
				self.Owner:SetArmor(self.Owner:Armor()-self.BatteryPerUse)
				self.Weapon:SetNextPrimaryFire(CurTime() + 1.5)
				end
			end
		end
	end
end



function SWEP:SecondaryAttack()

end

function SWEP:Heal()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:SendWeaponAnim(ACT_VM_HOLSTER)
	timer.Simple(0.1, function()
		if (not self.Owner:Alive() or self.Weapon:GetOwner():GetActiveWeapon():GetClass() ~= "rebel_healer" or not IsFirstTimePredicted()) then return end
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW) 			// View model animation
	end)
	
	self.Weapon:EmitSound( "items/smallmedkit1.wav") 
	if CLIENT then return end
	self.Owner:Speak(true,"/male",TLK_CIT_MALE_HEAL,"/female",TLK_CIT_FEMALE_HEAL)
end
