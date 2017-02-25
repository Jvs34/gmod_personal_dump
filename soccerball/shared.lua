ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.RenderGroup     = RENDERGROUP_OPAQUE
ENT.PrintName        = "Soccerball"
ENT.Author="Jvs"
ENT.Spawnable = true  
ENT.AdminSpawnable = true  

function ENT:SpawnFunction( ply, tr )
    if ( !tr.Hit ) then return end
    
    local SpawnPos = tr.HitPos + tr.HitNormal * 40
    
    local ent = ents.Create(ClassName or "soccerball")
    ent:SetPos( SpawnPos )
    ent:Spawn()
    ent:Activate()
    ent.Owner = ply
    ent.LastKicker=ply
    return ent
end

function ENT:Initialize()

    if SERVER then
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
		self.LastKicker=self.Owner
		self:SetTrigger(true)
	end
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	self.NextImpact=CurTime();
	self.NextKickSound=CurTime();
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

function ENT:DamageNPC(ent)
	if !IsValid(self.LastKicker) then return end
	if ent:Disposition(self.LastKicker)!=D_HT then return end
	if type(DamageInfo)=="table" then return end
	local dmginfo=DamageInfo();
	dmginfo:SetDamageType(DMG_CRUSH)
	dmginfo:SetDamage(50);
	dmginfo:SetInflictor(self)
	dmginfo:SetAttacker(self.LastKicker || self)
	dmginfo:SetDamageForce((ent:GetPos()-self:GetPos())*9000)
	ent:TakeDamageInfo(dmginfo)
end


function ENT:PhysicsCollide( data, physobj )
	
	local ent=data.HitEntity
	if SERVER && IsValid(ent)  && ent:IsNPC() && data.OurOldVelocity:Length()>50 && !self:IsPlayerHolding() then
	self:DamageNPC(ent)
	return
	end
	
		if self.NextImpact<CurTime() && data.DeltaTime>0.2 && data.OurOldVelocity:Length()>100 && !self:IsPlayerHolding() then 
		self:EmitSound("Rubber.ImpactHard")
		self.NextImpact=CurTime()+0.1;
		end

end
function ENT:StartTouch(ent)
	if !IsValid(ent) || !ent:IsPlayer() && !self:IsPlayerHolding() then return end

	
	self.LastKicker=ent;
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