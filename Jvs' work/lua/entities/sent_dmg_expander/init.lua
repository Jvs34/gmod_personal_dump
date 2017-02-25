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
	local ent = ents.Create( "sent_dmg_expander" )
		ent:SetPos( SpawnPos )
		ent:Spawn()
		ent:Activate()
	return ent
end

function ENT:Think()
end


function ENT:OnTakeDamage( DmgInfo )
		local attacker=DmgInfo:GetAttacker();
		self.DamageType=DmgInfo:GetDamageType();
		if ( IsValid(attacker) ) then
				local entz=ents.FindInSphere(self.Entity:GetPos(), 250)
				for _,ent in pairs(entz) do
					if IsValid(ent) && ent!= self then
					
					local effect = EffectData()
					effect:SetStart(ent:GetPos())
					effect:SetOrigin(ent:GetPos())
					effect:SetScale(25)
					effect:SetRadius(25);
					util.Effect("cball_explode", effect)
					
					ent:TakeDamageInfo(DmgInfo);
					end
				end

		end
end