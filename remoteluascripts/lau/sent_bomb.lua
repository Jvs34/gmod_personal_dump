local ClassName="sent_bomb"
local ENT = {}
ENT.Base             = "base_anim"
ENT.PrintName		= "A BOMB"
ENT.Author			= "Jvs"
ENT.Information		= "Oh my god JC!"
ENT.Category		= "Fun + Games"

ENT.Editable			= false
ENT.Spawnable			= true
ENT.AdminOnly			= true
ENT.RenderGroup 		= RENDERGROUP_TRANSLUCENT

function ENT:SpawnFunction( ply, tr, ClassName )

	if !tr.Hit then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 36
	
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

function ENT:SetupDataTables()
	self:NetworkVar( "Float" , 0 , "Timer")
	self:NetworkVar( "Float" , 1 , "FuseLength" )
	self:NetworkVar( "Bool" , 0 , "Activated" )
	self:NetworkVar( "Entity" , 0 , "Activator" )
end

function ENT:Initialize()
	if SERVER then

		self:SetActivated( false )
		self:SetTimer( 0 )
		self:SetFuseLength( 5 )
		self:SetUseType( SIMPLE_USE )
		self:SetModel( "models/dynamite/dynamite.mdl" )
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:SetSolid( SOLID_VPHYSICS )
		
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
			phys:AddGameFlag(FVPHYSICS_NO_NPC_IMPACT_DMG)
			phys:SetMaterial("metal")
			phys:Wake()
		end
	else
		self.NextParticle = CurTime()
		self.NextBlink = CurTime()
		self.PreviousBlink = CurTime()
		self.DoBlink = false
	end
	
	
	
end


if CLIENT then
	
	ENT.SparkMat = "Effects/spark"
	ENT.SmokeParticle = "particle/particle_noisesphere"
	ENT.OffsetPos = Vector(2.3,1.3,20.1)
	ENT.OffsetAng = Angle(0,0,0)
	
	ENT.WirePos = {
		Vector(2.5,1.3,19.5),
		Vector(1.5,1,19),
		Vector(0.9,0.4,18.25),
		Vector(0.3,0.2,17.25),
		Vector(-0.1,-0.1,16.25),
		Vector(-0.1,-0.1,14.25),
	}
	
	function ENT:Draw()
		self:DrawModel()
		
		
		--[[
		for i ,v in pairs( self.WirePos ) do
			local pos , ang = LocalToWorld( v , angle_zero , self:GetPos() , self:GetAngles() )
			render.DrawWireframeSphere( pos, 0.5 , 8, 8, color_white, false )
		end
		]]
		
		if self:GetActivated() then
			
			local frac = ( self:GetTimer() - CurTime() ) / self:GetFuseLength()
			
			if frac < 0 then
				frac = 0
			end
			
			
			--[[
			if not gay then
				return
			end
			]]
			
			if not self.ParticleEmitter then
				self.ParticleEmitter = ParticleEmitter( self:GetPos() )
			end
			
			if not self.ParticleEmitter then
				return
			end
			
			--draw sparks and smoke
			local pos = self:GetPos()
			local ang = self:GetAngles()
			pos , ang = LocalToWorld( self.OffsetPos , self.OffsetAng , pos , ang )
			
			if self.NextParticle < CurTime() then 
				local particle = self.ParticleEmitter:Add(self.SmokeParticle,pos)
				if not particle then return end
				particle:SetVelocity(vector_origin)
				particle:SetDieTime(0.5)
				particle:SetStartAlpha(200)
				particle:SetEndAlpha(0)
				particle:SetStartSize(3)
				particle:SetEndSize( 16 )
				particle:SetRoll( math.Rand( -10,10  ) )
				particle:SetRollDelta(math.Rand( -0.2, 0.2 ))
				particle:SetColor(200,200,200)
				
				for i = 0 , 4 do
					particle = self.ParticleEmitter:Add( self.SparkMat , pos )
					if not particle then 
						continue 
					end
					particle:SetVelocity(vector_origin)
					particle:SetDieTime(0.02)
					particle:SetStartAlpha(200)
					particle:SetEndAlpha(0)
					particle:SetStartSize(3)
					particle:SetEndSize( 4 )
					particle:SetRoll( math.Rand( -10,10  ) )
					particle:SetRollDelta(math.Rand( -0.2, 0.2 ))
					particle:SetColor(200,200,200)
				end
				
				self.NextParticle = CurTime() + 0.02
			end
		end
	end

else
	
	function ENT:OnTakeDamage( dmginfo )
		
		
		if not self:GetActivated() and ( dmginfo:IsDamageType( DMG_CLUB ) or dmginfo:IsDamageType( DMG_BURN ) or dmginfo:IsDamageType( DMG_DIRECT ) ) then
			self:ActivateBomb( dmginfo:GetAttacker() )
		else
			--only take physics damage from attacks that don't trigger us
			self:TakePhysicsDamage( dmginfo )
		end
		
	end

	function ENT:Use( activator, caller )
		if self:IsPlayerHolding() then 
			return 
		end
		
		if IsValid( activator ) and activator:IsPlayer() then
			activator:PickupObject( self )
		end
	end
	
	function ENT:ActivateBomb( activator )
		if not self:GetActivated() then
			self:SetTimer( CurTime() + self:GetFuseLength() )
			self:SetActivated( true )
			self:SetActivator( activator )
		end
	end
	
	function ENT:Explode()
		self:SetActivated( false )
		self:SetTimer( 0 )
		
		--[[
		if not gay then
			return
		end
		]]
		
		util.BlastDamage( self , IsValid(self:GetActivator()) and self:GetActivator() or self , self:GetPos() , 150 , 150 )
		util.ScreenShake( self:GetPos(), 25, 150.0, 1.0, 350 )
		
		local effectstring = ( self:WaterLevel() > 2 ) and "WaterSurfaceExplosion" or "Explosion"
		local effectdata = EffectData()
		effectdata:SetScale(128)
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetMagnitude(128)
		util.Effect( effectstring, effectdata )
		
		self:Remove()
	end

end

function ENT:Think()

	if CLIENT then
		
		if not self.HissSound then
			self.HissSound = CreateSound( self, "Weapon_FlareGun.Burn" )
		end
		
		if self:GetActivated() then
			self.HissSound:PlayEx( 1 , 125 )
		else
			self.HissSound:Stop()
		end
		
	else
		
		if self:GetActivated() then
			
			if self:WaterLevel() > 0 then
				self:SetActivated( false )
				self:SetTimer( 0 )
			end
			
			if self:GetTimer() ~= 0 and self:GetTimer() <= CurTime() then
				self:Explode()
			end
		end
	
	end
end

function ENT:OnRemove()
	if CLIENT then
		if self.HissSound then
			self.HissSound:Stop()
		end
		
		if self.ParticleEmitter then
			self.ParticleEmitter:Finish()
			self.ParticleEmitter = nil
		end
	end
end

scripted_ents.Register( ENT , ClassName , true )