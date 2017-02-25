AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" );
include( "shared.lua" );

function ENT:SpawnFunction( Player, Trace )

	if ( !Trace.Hit ) then return end
	
	local SpawnPos = Trace.HitPos + ( Trace.HitNormal * 32 );
	
	local Entity = ents.Create( "sent_battery_maker" );
	Entity:SetPos( SpawnPos );
	Entity:Spawn();
	Entity:Activate();
	Entity:SetPhysicsAttacker( Player );
	Entity.Owner = Player; 
	return Entity;
	
end
					
function ENT:Initialize( )

	self:SetModel( "models/Items/car_battery01.mdl" );
	self:SetSkin(skn);
	self:SetUseType( SIMPLE_USE );
	self:SetMoveType( MOVETYPE_VPHYSICS );
	self:PhysicsInit( SOLID_VPHYSICS );
	self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_NPC_IMPACT_DMG );
	self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_IMPACT_DMG );
	self:PhysWake();
	self.Battery=0;
	self.BLimit=100;
end

function ENT:Think()
if CLIENT then return end
	if(self.Battery<=(self.BLimit-1) )then
	self.Battery=self.Battery+1;
	self:EmitSound("HL1/fvox/blip.wav",50,100);
	self:SetNWInt("battery",self.Battery);
	end
	self:NextThink(CurTime()+0.5)
return true;
end


function ENT:OnTakeDamage(dmg)
	self.Entity:TakePhysicsDamage(dmg); -- React physically when getting shot/blown
		if (self.BLimit > 1)then
			if self.Battery == self.BLimit then self.Battery=self.Battery-1;
			self:SetNWInt("battery",self.Battery);
			end
			self.BLimit=self.BLimit-1;
			self:EmitSound("items/battery_pickup.wav",100,200);
		end
end

function ENT:Use(ent)
	if!(ent:IsPlayer())then return end
	if self.Battery <= 0 then return end
	if(self.Battery >=15 && ent:KeyDown(IN_DUCK) )then
		local bat=ents.Create("item_battery");
		bat:SetPos(self:GetPos());
		bat:SetOwner(self);
		bat:Spawn();
		bat:Activate();
		self.Battery=self.Battery-15;
		self:EmitSound("items/battery_pickup.wav",100,150);
	elseif(ent:Armor()<100)then
		local used;
			local current = ent:Armor()
			local max = 100
			if current <= (max - self.Battery) then
				used=self.Battery;
				ent:SetArmor( current + self.Battery )
			else
				used=max-ent:Armor();
				ent:SetArmor( max )
			end
		self.Battery=self.Battery-used;
		self:SetNWInt("battery",self.Battery);
		self:EmitSound("items/battery_pickup.wav",100,80);

	end
end
