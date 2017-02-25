if SERVER then return end
ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.RenderGroup     = RENDERGROUP_OPAQUE
ENT.PrintName        = "Soccerball"
ENT.Author="Jvs"
ENT.Spawnable = true  
ENT.AdminSpawnable = true  

function ENT:Initialize()
	self:InitializeAsClientEntity()
	self:SetModel( "models/props_phx/misc/soccerball.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	if IsValid(self:GetPhysicsObject()) then
		self:GetPhysicsObject():AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
		self:GetPhysicsObject():AddGameFlag(FVPHYSICS_NO_NPC_IMPACT_DMG)
		self:GetPhysicsObject():Wake()
		self:GetPhysicsObject():SetMaterial("gm_ps_soccerball");
	end
	self:SetTrigger(true)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self.NextImpact=CurTime();
	self.NextKickSound=CurTime();
	self:InitializeAsClientEntity()
end



function ENT:OnTakeDamage( dmginfo )
	if dmginfo:GetDamage()<2 then return end

	
	local r, g, b = 0,0,0
	
	local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetStart( Vector( r, g, b ) )
	util.Effect( "balloon_pop", effectdata )
	r, g, b = 255,255,255
	effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetStart( Vector( r, g, b ) )
	util.Effect( "balloon_pop", effectdata )
	
	
	self:Remove()
	
end


function ENT:PhysicsCollide( data, physobj )
	if self.NextImpact<CurTime() && data.DeltaTime>0.2 && data.OurOldVelocity:Length()>100 && !self:IsPlayerHolding() then 
		self:EmitSound("Rubber.ImpactHard")
		self.NextImpact=CurTime()+0.1;
	end
end
function ENT:StartTouch(ent)
	if !IsValid(ent) || !ent:IsPlayer() then return end

	if ent:GetVelocity():Length()<40 then
		return
	end
	
	if IsValid(self:GetPhysicsObject()) then
		local velocity;
		local mult=3
		velocity=ent:GetVelocity()*mult

		self:GetPhysicsObject():AddVelocity(velocity+Vector(0,0,90))
		
		if self.NextKickSound<CurTime() then 
			self:EmitSound("Rubber.BulletImpact")
			self.NextKickSound=CurTime()+0.1;
		return 
		end
	end
end