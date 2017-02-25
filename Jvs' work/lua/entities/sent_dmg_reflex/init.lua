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
	local ent = ents.Create( "sent_dmg_reflex" )
		ent:SetPos( SpawnPos )
		ent:Spawn()
		ent:Activate()
	return ent
end

function ENT:StartTouch(ent)
	if(ent:GetClass()=="prop_combine_ball" || ent:GetClass()=="sent_combine_ball")then
		local DMG=DamageInfo();
		DMG:SetDamage(10000);//dissolver damage
		DMG:SetDamageType(DMG_DISSOLVE)
		DMG:SetAttacker(self)
		DMG:SetInflictor(ent)
		ent:GetOwner():TakeDamageInfo(DMG)
		ent:Remove();
	end
	
end

function ENT:Think()
end


function ENT:OnTakeDamage( DmgInfo )
		local attacker=DmgInfo:GetAttacker();
		self.DamageType=DmgInfo:GetDamageType();
		if ( IsValid(attacker) ) then
				if(DmgInfo:GetInflictor():GetClass()=="player")then
					DmgInfo:SetInflictor(DmgInfo:GetInflictor():GetActiveWeapon())
				end
				DmgInfo:SetAttacker(self);
				attacker:TakeDamageInfo(DmgInfo);

		end
	
end