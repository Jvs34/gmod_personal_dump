AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" );
include( "shared.lua" );

function ENT:SpawnFunction( Player, Trace )

	if ( !Trace.Hit ) then return end
	
	local SpawnPos = Trace.HitPos + ( Trace.HitNormal * 32 );
	
	local Entity = ents.Create( "sent_sodacan" );
	Entity:SetPos( SpawnPos );
	Entity:Spawn();
	Entity:Activate();
	Entity:SetPhysicsAttacker( Player );
	Entity.Owner = Player;
	return Entity;
	
end
					
function ENT:Initialize( )

	self:SetModel( "models/props_junk/popcan01a.mdl" );
	local skn=math.random(1,3);
	self:SetSkin(skn);
	self:SetUseType( SIMPLE_USE );
	self:SetMoveType( MOVETYPE_VPHYSICS );
	self:PhysicsInit( SOLID_VPHYSICS );
	self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_NPC_IMPACT_DMG );
	self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_IMPACT_DMG );
	self:PhysWake();

	
end


function ENT:OnTakeDamage(dmg)
	self.Entity:TakePhysicsDamage(dmg); -- React physically when getting shot/blown
end

function ENT:StartTouch(ent)
	if(ent:IsPlayer() && ent:Health()<ent:GetMaxHealth())then
			local current = ent:Health()
			local max = ent:GetMaxHealth()
			if current <= (max - 1) then
				ent:SetHealth( current + 1 )
			else
				ent:SetHealth( max )
			end
	
		self:EmitSound("Popcan.ImpactHard");
		self:Remove();
	end
end
