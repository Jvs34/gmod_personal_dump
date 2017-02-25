
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
FRAG_GRENADE_BLIP_FREQUENCY			= 1.0
ENT.Warning=4;
ENT.ExpTime=5.2;
ENT.CanExp=0;
function ENT:SpawnFunction( ply, tr )
	self.Owner=ply;
	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "grenade_combball" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end


/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()
	self.Entity:SetModel( "models/Items/combine_rifle_ammo01.mdl" )

	// Use the model's physics
	self.Entity:PhysicsInit( SOLID_VPHYSICS, "metal" )

	// Wake the physics object up. It's time to have fun!
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:AddGameFlag( FVPHYSICS_NO_NPC_IMPACT_DMG );
		phys:AddGameFlag( FVPHYSICS_NO_IMPACT_DMG );
	
	end
	self.Warning=CurTime() +self.Warning;
	self.ExpTime=CurTime() +self.ExpTime;//Color( 224, 49, 49, 255 )
	self.m_flNextBlipTime = CurTime(); //+ FRAG_GRENADE_BLIP_FREQUENCY;
	util.SpriteTrail( self.Entity,0,Color( 255, 0, 0, 255 ),true,4.0,0,2,1 / (4 * 0.5),"sprites/bluelaser1.vmt")//trails/laser.vmt
end


/*---------------------------------------------------------
   Name: PhysicsCollide
---------------------------------------------------------*/
function ENT:Distruggi( )
			local effect = EffectData()
			effect:SetStart(self:GetPos())
			effect:SetOrigin(self:GetPos()+ Vector(0, 0, 10))
			effect:SetScale(10)
			util.Effect("cball_explode", effect)
			local DMG=DamageInfo();
			DMG:SetDamage(325);
			DMG:SetDamageType(DMG_DISSOLVE);
			DMG:SetAttacker(self:GetOwner());
			DMG:SetInflictor(self:GetOwner());
			for k,ent in pairs(ents.FindInSphere(self:GetPos(), 300)) do
				if( ent:IsValid()) then
				DMG:SetDamage(325-(ent:GetPos():Distance( self.Entity:GetPos() )     )      )
				ent:TakeDamageInfo(DMG);
				end
			end				
			self:EmitSound( "weapons/physcannon/energy_sing_explosion2.wav" )
			self:Remove();
end

/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )

	
end

function ENT:Think( )
	if( CurTime() > self.m_flNextBlipTime && self.CanExp == 0 ) then
		self:EmitSound("Grenade.Blip");
		self.m_flNextBlipTime = CurTime() + FRAG_GRENADE_BLIP_FREQUENCY;
	end
	
	
	if(self.Warning <= CurTime())then
	self:EmitSound("Weapon_CombineGuard.Special1")
	self.Warning= CurTime() + 99
	self.CanExp=1;
	end
	if(self.ExpTime <= CurTime())then self:Distruggi() end
	
end

function ENT:OnRemove( )
end

function ENT:Use( Player )

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