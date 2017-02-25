AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
ENT.Missile=nil;

local Enemy = {

	"rpg_missile",
	"sent_homingmissile",
	"npc_combine_s",
	"npc_metropolice",
	"npc_rollermine",
	"npc_manhack",
	"npc_crow",
	"npc_strider",
	"npc_pigeon",
	"npc_seagull",
	"npc_metropolice",
	"npc_antilion",
	"npc_antilionguard",
	"npc_fastzombie",
	"npc_barnacle",
	"npc_zombie",
	"npc_headcrab",
	"npc_headcrab_fast",
	"npc_headcrab_poison",
	"npc_poisonzombie"
}

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
	local ent = ents.Create( "sent_missile_attacker" )
		ent:SetPos( SpawnPos )
		ent:Spawn()
		ent:Activate()
		self.Owner=ply;
	return ent
end

function ENT:Use(ply)
	self.Owner=ply;
end
function ENT:Think()
		local entz=ents.FindInSphere(self.Entity:GetPos(), 1000)
			for _,ent in pairs(entz) do
				if   table.HasValue( Enemy, ent:GetClass() )  && !IsValid(self.Missile) && self.MissTime<=CurTime() then
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
								if(ent:IsNPC())then
								Missil.Laser=ent;
								end
							end
						Missil:SetPhysicsAttacker(self);

						Missil:SetPos( self:GetPos() + Vector(0,0,50));
						Missil:SetAngles( shootAngles );
						Missil:Spawn()
						if self.Owner && IsValid(self.Owner)then
						Missil.Owner=self.Owner
						Missil:SetOwner( self.Owner );
						else
						Missil.Owner=self;
						Missil:SetOwner( self );
						end
						self.MissTime=CurTime()+3;
						end
				end
			end
end
function ENT:PhysicsCollide( data, physobj )
				
end