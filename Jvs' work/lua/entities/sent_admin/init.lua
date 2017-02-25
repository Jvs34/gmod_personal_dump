AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	util.PrecacheModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self.Entity:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetCollisionGroup( COLLISION_GROUP_NONE );
end

function ENT:SpawnFunction( ply, tr )
if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	SpawnPos.z = SpawnPos.z + 10
	local ent = ents.Create( "sent_admin" )
		ent:SetPos( SpawnPos )
		ent:Spawn()
		ent:Activate()
		self.Owner=ply;
	return ent
end
function ENT:Think()
	if(self.Owner)then
					self.Owner:SetHealth(666);
					self.Owner:SetArmor(666);
					if ( self.Owner:GetActiveWeapon() == NULL ) then return end
					self.Owner:GetActiveWeapon():SetClip1(666);
					self.Owner:GetActiveWeapon():SetClip2(666);
					end
self.Entity:NextThink(CurTime())
return true
end
function ENT:PhysicsCollide( data, physobj )
		
end