AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" );
include( "shared.lua" );
ENT.Heal=25;

function ENT:SpawnFunction( Player, Trace )

	if ( !Trace.Hit ) then return end
	
	local SpawnPos = Trace.HitPos + ( Trace.HitNormal * 32 );
	
	local Entity = ents.Create( "sent_medkit" );
	Entity:SetPos( SpawnPos );
	Entity:Spawn();
	Entity:Activate();
	Entity:SetPhysicsAttacker( Player );
	Entity.Owner = Player;
	return Entity;
	
end
					
function ENT:Initialize( )
	self:SetModel( "models/items/healthkit.mdl" );
	self:SetUseType( SIMPLE_USE );
	self:SetMoveType( MOVETYPE_VPHYSICS );
	self:PhysicsInit( SOLID_VPHYSICS );
	self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_NPC_IMPACT_DMG );
	self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_IMPACT_DMG );
	self:SetNetworkedInt("hl",self.Heal);
	self:PhysWake();

	
end

function ENT:Think( )
	if(self:WaterLevel()==3)then
		self.Heal=25;
		self:SetNetworkedInt("hl",self.Heal);
	end
end

function ENT:OnRemove( )

end

function ENT:Use( Player )
end

function ENT:PhysicsUpdate( PhysObj )
end

function ENT:TouchingWorld( )

	local Data, Trace;

	Data = {};
	Data.start = self:GetPos();
	Data.endpos = Data.start - Vector( 0, 0, 30 );
	Data.filter = self;
	
	Trace = util.TraceLine( Data );
	
	return Trace.Hit;

end

function ENT:OnTakeDamage( DmgInfo )

end

function ENT:PhysicsCollide( data, physobj )
if(IsValid( data.HitEntity ) ) then
	local current = data.HitEntity:Health()
	local max = data.HitEntity:GetMaxHealth()
	local vit = max - current;
	if!(self.Heal==0)then
		if( vit >0) then
				if !(self.Heal < vit)then
				data.HitEntity:SetHealth( current + vit );
				self.Heal = self.Heal - vit;
				self:EmitSound("items/smallmedkit1.wav")
				else
				data.HitEntity:SetHealth( current + self.Heal );
				self.Heal = 0;
				self:EmitSound("items/smallmedkit1.wav")
				end
				self:SetNetworkedInt("hl",self.Heal);
		end
	end
	end
end