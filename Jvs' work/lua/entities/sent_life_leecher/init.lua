AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
function ENT:Initialize()
	//self.Entity:SetModel("models/props_c17/light_cagelight02_on.mdl")
	self.Entity:SetModel("models/weapons/w_grenade.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS) 
	self.Entity:SetCollisionGroup( COLLISION_GROUP_NONE );
	self.LifeTime=CurTime()+10;
	self.Dmg=3;
	self.DmgType=DMG_SHOCK;
	self.Target=nil;
	self.Owner=nil;
end


function ENT:Think()
	if(self.LifeTime<CurTime())then self:Remove();end
	if(self.Target && IsValid(self.Target) && self.Owner && IsValid(self.Owner))then

			local DMG=DamageInfo();
			DMG:SetDamage(self.Dmg);
			DMG:SetDamageType(self.DmgType);
			DMG:SetAttacker(self.Owner);
			DMG:SetInflictor(self.Owner);
			self.Target:TakeDamageInfo(DMG);
			self:EmitSound("NPC_RollerMine.Shock");
			self.Owner:SetHealth(self.Owner:Health()+(self.Dmg-1));
				if(self.Owner:Alive() )then//&& self.Owner:GetWeapon("weapon_life_leecher")==self.Owner:GetActiveWeapon()
					self.Owner:GetActiveWeapon():SendWeaponAnim(ACT_VM_DRYFIRE);
				end
		self.Entity:NextThink(CurTime()+1)//Damage EverySecond
		return true
	end
end


function ENT:OnTakeDamage( DmgInfo )

end

function ENT:PhysicsCollide( data, physobj )

	if(IsValid(data.HitEntity) && !IsValid(self.Target) && !(data.HitEntity:GetClass()=="npc_turret_floor"))then 
		self.Target=data.HitEntity;
		self:SetParent(self.Target);
	else
	self:Remove();
	end
	
end