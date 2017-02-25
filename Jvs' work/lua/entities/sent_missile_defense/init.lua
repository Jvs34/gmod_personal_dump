AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
ENT.Missile=nil;
function ENT:Initialize()
	util.PrecacheModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self.Entity:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetCollisionGroup( COLLISION_GROUP_NONE );
	self.Missile=nil;
	self.MissTime=CurTime();
	self.Owner=nil;
end

function ENT:SpawnFunction( ply, tr )
if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	SpawnPos.z = SpawnPos.z + 50
	local ent = ents.Create( "sent_missile_defense" )
		ent:SetPos( SpawnPos )
		ent:Spawn()
		ent:Activate()
	return ent
end

function ENT:Use(ply)
	self.Owner=ply;
end
function ENT:Think()
		local entz=ents.FindInSphere(self.Entity:GetPos(), 500)
			for _,ent in pairs(entz) do
				if (ent:GetClass()=="sent_homingmissile" || ent:GetClass()=="rpg_missile") && !IsValid(self.Missile) && self.MissTime<=CurTime() then
						if(self.Owner && IsValid(self.Owner) && (ent.Owner == self.Owner || ent:GetOwner() == self.Owner))then
						
						else
						self:EmitSound( "Weapon_RPG.NPC_Single" )
						local shootAngles = self.Entity:GetAngles()
						local Missil = ents.Create( "sent_homingmissile" );
						self.Missile=Missil;
							if(ent:GetClass()=="sent_homingmissile")then
							Missil.Laser=ent.Owner;
							else
							Missil.Laser=ent:GetOwner();
							end
						Missil:SetPhysicsAttacker(self);
						Missil:SetOwner( self );
						Missil:SetPos( self:GetPos() + Vector(0,0,50));
						Missil:SetAngles( shootAngles );
						Missil:Spawn()
						Missil.Owner=self;
						Missil.speed=500;
						self.MissTime=CurTime()+3;
						end
				end
			end
end

function ENT:OnTakeDamage( dmginfo )
 if	!IsValid(self.Missile) && self.MissTime<=CurTime() then
						self:EmitSound( "Weapon_RPG.NPC_Single" )
						local shootAngles = self.Entity:GetAngles()
						local Missil = ents.Create( "sent_homingmissile" );
						self.Missile=Missil;
						Missil.Laser=dmginfo:GetAttacker()
						Missil:SetPhysicsAttacker(self);
						Missil:SetOwner( self );
						Missil:SetPos( self:GetPos() + Vector(0,0,50));
						Missil:SetAngles( shootAngles );
						Missil.Owner=self;
						Missil:Spawn()
						Missil.Owner=self;
						Missil.speed=500;
						self.MissTime=CurTime()+3;
	end
end