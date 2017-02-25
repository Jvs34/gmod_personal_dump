AddCSLuaFile( "shared.lua" );
include( "shared.lua" );

function ENT:SpawnFunction( Player, Trace )

	if ( !Trace.Hit ) then return end
	
	local SpawnPos = Trace.HitPos + ( Trace.HitNormal * 32 );
	
	local Entity = ents.Create( "sent_crater" );
	Entity:SetPos( SpawnPos );
	Entity:Spawn();
	Entity:Activate();
	Entity:SetPhysicsAttacker( Player );
	Entity.Owner = Player;
	return Entity;
	
end
					
function ENT:Initialize( )

	self:SetModel( "models/Items/item_item_crate.mdl" );
	self:PrecacheGibs()
	self:SetUseType( SIMPLE_USE );
	self:SetMoveType( MOVETYPE_VPHYSICS );
	self:PhysicsInit( SOLID_VPHYSICS );
	self:PhysWake();
	
	
	
end

function ENT:Think( )
end

function ENT:OnRemove( )

end

function ENT:Use( Player )
		if ( Player:IsPlayer() && IsValid(Player:GetActiveWeapon()) ) then
			local launcher = ents.Create("item_item_crate")  
			launcher:SetPos(self:GetPos() + Vector( 0, 0, 0 ))  
			launcher:SetKeyValue("ItemClass", Player:GetActiveWeapon():GetClass())
			launcher:SetKeyValue("ItemCount", 1)  
			Player:GetActiveWeapon():Remove()
			launcher:Spawn()  
			launcher:Activate() 
		end
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
	if  IsValid( data.HitEntity ) && (data.HitEntity:IsWeapon() or string.find(data.HitEntity:GetClass(),"item_"))  then
		local launcher = ents.Create("item_item_crate")  
		launcher:SetPos(self:GetPos() + Vector( 0, 0, 0 ))  
		launcher:SetKeyValue("ItemClass", data.HitEntity:GetClass())
		data.HitEntity:Remove()
		launcher:SetKeyValue("ItemCount", "1")  
		launcher:Spawn()  
		launcher:Activate()
		self:Remove();
	end
end