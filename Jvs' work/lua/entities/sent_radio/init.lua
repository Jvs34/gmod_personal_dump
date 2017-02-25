AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" );
include( "shared.lua" );

function ENT:SpawnFunction( Player, Trace )

	if ( !Trace.Hit ) then return end
	
	local SpawnPos = Trace.HitPos + ( Trace.HitNormal * 32 );
	
	local Entity = ents.Create( "sent_radio" );
	Entity:SetPos( SpawnPos );
	Entity:Spawn();
	Entity:Activate();
	Entity:SetPhysicsAttacker( Player );
	Entity.Owner = Player;
	return Entity;
	
end
					
function ENT:Initialize( )

	self:SetModel( "models/props_lab/citizenradio.mdl" );
	self:SetUseType( SIMPLE_USE );
	self:SetMoveType( MOVETYPE_VPHYSICS );
	self:PhysicsInit( SOLID_VPHYSICS );
	self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_NPC_IMPACT_DMG );
	self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_IMPACT_DMG );
	self:PhysWake();
	self.Radio=nil
	self.Roped=false;
	
end

function ENT:Think()
	if(self.Radio && IsValid(self.Radio) && self.Roped==false)then
		constraint.Elastic( self, self.Radio, 0, 0, Vector( 0, 0, 0 ) , Vector( 0, 0, 0 ) , 0, 0, 0, "cable/cable2", 3, 0 )
		self.Roped=true;
	end

end


function ENT:StartTouch(ent)
	if(IsValid(ent) && ent:GetClass()==self:GetClass() && self.Radio==nil)then
		self.Radio=ent;
	end
end

function ENT:ListenToSound(emitter,sound,concept)
	print("Emitter: "..emitter:GetClass());
	print("Sound: "..sound);
	print("Concept: "..concept);
	if(self.Radio && IsValid(self.Radio))then
	self.Radio:SpeakSimple(sound,concept)
	end
end
