AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" );
include( "shared.lua" );

ENT.RadioStation=1;//the station is 1 by default,you can change it before ent:Spawn() in your script

function ENT:SpawnFunction( Player, Trace )

	if ( !Trace.Hit ) then return end
	
	local SpawnPos = Trace.HitPos + ( Trace.HitNormal * 32 );
	
	local Entity = ents.Create( "tds_radio" );
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
	self:UpdateClientStation(self.RadioStation)
	self.NextUse=CurTime()
end

function ENT:UpdateClientStation(radio)
	self.RadioStation=radio
	self:SetNWInt("station",self.RadioStation)
end

function ENT:UpdateClientRadio()
	local number=0;
	for k, Entity in pairs( ents.FindByClass(self:GetClass()) ) do
		if Entity.RadioStation == self.RadioStation && Entity != self then
			number=number+1;
		end
	end
	self:SetNWInt("radios",number)
end

function ENT:Think()
self:UpdateClientRadio()
self:NextThink(CurTime()+2);//so we don't spam the server
return true
end

function ENT:CicleStations()
	if self.RadioStation < RADIO_MAX_CHANNELS then
		self:UpdateClientStation(self.RadioStation+1)
	else
		self:UpdateClientStation(1)
	end
end

function ENT:Use(activator)
	if self.NextUse < CurTime() then
	self:CicleStations()
	self:UpdateClientRadio()
	self:EmitSound("buttons/button18.wav")
	self.NextUse = CurTime()+0.5
	end
end

function ENT:ListenToSound(emitter,sound,concept)
		self:BroadCastSoundToStation(self.RadioStation,emitter,sound,concept)
end

function ENT:BroadCastSoundToStation(station,emitter,sound,concept)
	for k, Entity in pairs( ents.FindByClass(self:GetClass()) ) do
		if IsValid(Entity) && Entity.RadioStation == station && Entity != self then
		Entity:OnReceiveSound(emitter,sound,concept)
		end
	end
end

function ENT:OnReceiveSound(emitter,sound,concept)
	self:SpeakSimple(sound,concept)
end