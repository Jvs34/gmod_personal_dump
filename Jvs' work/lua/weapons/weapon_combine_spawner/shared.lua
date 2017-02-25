if (SERVER) then
	AddCSLuaFile( "shared.lua" )
	SWEP.Weight		= 5
	SWEP.AutoSwitchTo	= true
	SWEP.AutoSwitchFrom	= true
end

if ( CLIENT ) then
	SWEP.DrawAmmo			= true
	SWEP.PrintName			= "Combine Spawner"
	SWEP.Author				= "Jvs"
	SWEP.DrawCrosshair		= true
	
end

SWEP.Category = "Jvs" 

SWEP.Spawnable     			= true
SWEP.AdminSpawnable  		= true
 
SWEP.ViewModel="models/weapons/v_grenade.mdl";
SWEP.WorldModel="models/weapons/w_grenade.mdl";

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic		= false

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo = false
SWEP.Secondary.Automatic = false

function SWEP:Initialize()
	if (CLIENT) then return end
	self:SetWeaponHoldType("grenade")
	self.NextReload=CurTime()
	self.NextChange=CurTime();
end 

function SWEP:Holster()
	return true
end

function SWEP:PrimaryAttack()
	if !self.Owner.Combine or !IsValid(self.Owner.Combine) then
		self.Weapon:SendWeaponAnim( ACT_VM_THROW )
		local cball = ents.Create("sent_combine_spawner")  
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
	else
		local tr=self.Owner:GetEyeTrace()
		local Pos=tr.HitPos
		self.Owner.Combine:SetLastPosition(Pos)
		self.Owner.Combine:SetSchedule(SCHED_FORCED_GO_RUN)
	end
end

function SWEP:Deploy()
self.Weapon:SendWeaponAnim( ACT_VM_THROW )
		
return true
end

function SWEP:Think()
	if CLIENT then return end
	if !self.Owner.CombineType then self.Owner.CombineType=1; end
	if self.Owner.Combine && IsValid(self.Owner.Combine) then return end
	if(self.NextChange < CurTime())then
		if self.Owner:KeyDown(IN_USE)then
			if(self.Owner.CombineType<4)then
			self.Owner.CombineType=self.Owner.CombineType+1;
			else
			self.Owner.CombineType=1;
			end
			Msg("Combine Set to "..self.Owner.CombineType.."\n")
			self.NextChange=CurTime()+1;
			self:EmitSound("Buttons.snd9")
		end
	end
end

function SWEP:Reload()
	if self.Owner.Combine and IsValid(self.Owner.Combine) && self.NextReload<CurTime() then
		local tr=self.Owner:GetEyeTrace()
		if(tr.Entity && IsValid(tr.Entity) && tr.Entity != self.Owner.Combine)then
			tr.Entity:SetName("targett"..tr.Entity:EntIndex())
			self.Owner.Combine:Fire("throwgrenadeattarget",tr.Entity:GetName())
		else
			self.Owner:GetActiveWeapon():SetName("targett"..self.Owner:GetActiveWeapon():EntIndex())
			self.Owner.Combine:Fire("throwgrenadeattarget",self.Owner:GetActiveWeapon():GetName())
		end
			self.NextReload=CurTime()+0.7
	end
end

function SWEP:SecondaryAttack()
	if self.Owner.Combine and IsValid(self.Owner.Combine) then
		local tr=self.Owner:GetEyeTrace()
		if(tr.Entity && IsValid(tr.Entity))then
			self.Owner.Combine:AddEntityRelationship(tr.Entity,D_HT,99)
			if(tr.Entity:IsNPC())then
			tr.Entity:AddEntityRelationship(self.Owner.Combine,D_HT,99)
			end
		end
	end
end
