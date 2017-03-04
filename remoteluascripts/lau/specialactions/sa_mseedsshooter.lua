

newsa=nil
newsa=SA:New("Melon seeds shooter","sa_mseedsshooter","Because when we run out of bullets, we gotta improvise")
newsa.MaxAmmo=200
if CLIENT then

	local EFFECT={}
	EFFECT.Mat = Material( "effects/spark" )

	--[[---------------------------------------------------------
	   Init( data table )
	-----------------------------------------------------------]]
	function EFFECT:Init( data )
		self.Entity:SetModel("models/props_junk/watermelon01.mdl")
		--self.Entity:SetModel("models/props_junk/PopCan01a.mdl")
		self.Entity:SetMaterial("models/shiny")
		self.Entity:SetColor(Color(0,0,0,255))
		self.Entity:SetModelScale(0.05,0)
		
		self.Owner	=	data:GetEntity()
		self.EndPos 	= data:GetOrigin()
		
		self.StartPos 	= data:GetStart()	
		self.Dir 		= self.EndPos - self.StartPos
		
		if IsValid(self.Owner) then
			if (self.Owner==LocalPlayer() and self.Owner:ShouldDrawLocalPlayer()) or self.Owner~=LocalPlayer() then
				local atch=self.Owner:GetAttachment(self.Owner:LookupAttachment("mouth"))
				if atch then
					self.StartPos=atch.Pos
					
					--emit a spit particle here
					
					local emitter = ParticleEmitter( self.StartPos )
					for i=1,5 do    
						local particle = emitter:Add( "particle/particle_noisesphere", self.StartPos )
							particle:SetVelocity( VectorRand()+(self.Dir:GetNormal()) )
							particle:SetDieTime(0.1)
							particle:SetStartAlpha(200)
							particle:SetEndAlpha(0)
							particle:SetStartSize(math.random(2,4))
							particle:SetEndSize( 0 )
							particle:SetRoll( math.Rand( -10,10  ) )
							particle:SetRollDelta(math.Rand( -0.2, 0.2 ))
							local cola=196	--/3
							local colb=255	--/3
							local colr=255	--/3
							particle:SetColor( cola, colb, colr)            
							particle:SetGravity( Vector( 0, 0, -15*i ) )
							particle:SetCollide( true )
							particle:SetBounce( 0.2 )
					end            
				emitter:Finish()
				end
			end
		end

		self.Dir 		= (self.EndPos - self.StartPos):GetNormal()
		
		self.Speed = (self.EndPos - self.StartPos):Length()
		
		if self.Speed < 250 then
			self.Speed=250
		end
		
		self:SetRenderBoundsWS( self.StartPos, self.EndPos )
		
		self.TracerTime = math.Rand( 0.1, 0.2 )
		self.Length = math.Rand( 0.1, 0.15 )
		
		-- Die when it reaches its target
		self.DieTime = CurTime() + self.TracerTime
		
	end

	--[[---------------------------------------------------------
	   THINK
	-----------------------------------------------------------]]
	function EFFECT:Think( )

		if ( CurTime() > self.DieTime ) then
			return false
		end
		
		return true

	end

	--[[---------------------------------------------------------
	   Draw the effect
	-----------------------------------------------------------]]
	function EFFECT:Render( )
		local fDelta = (self.DieTime - CurTime()) / self.TracerTime
		fDelta = math.Clamp( fDelta, 0, 1 ) ^ 0.5
				
		render.SetMaterial( self.Mat )
		
		local sinWave = math.sin( fDelta * math.pi )
		--
		self.Entity:SetRenderOrigin(self.EndPos - self.Dir  * self.Speed * (fDelta - sinWave * self.Length ))
		self.Entity:SetRenderAngles(self.Dir:Angle())
		self.Entity:DrawModel()
	end
	effects.Register(EFFECT,"melonseed",true)
end

function newsa:Initialize(entity,owner)
end

function newsa:ResetVars(entity,owner)
	entity:SetActionInt1((self.MaxAmmo*25)/100)
	entity:SetActionFloat1(CurTime())
	entity:SetActionFloat2(CurTime())
	
end

function newsa:Attack(entity,owner)
	if entity:GetActionInt1()<=0 then return end
	if SERVER then
		--SuppressHostEvents(owner)
	end
	owner:EmitSound("Weapon_SMG1.Double",70,80) --temporary until I find a better spit sound
	if SERVER then
		--SuppressHostEvents(NULL)
	end
	local bullet = {}
	bullet.Attacker = owner
	bullet.Inflictor= entity
	bullet.Num 		= 1
	bullet.Src 		= owner:GetShootPos()			
	bullet.Dir 		= owner:GetAimVector()
	bullet.Spread 	= vector_origin
	bullet.Tracer	= 0
	bullet.Force	= 1	
	bullet.Damage	= 7
	bullet.AmmoType = "Pistol"
	--bullet.TracerName = "LaserGunTracer"
    bullet.Callback = function( attacker, tr, dmginfo )
		--dmginfo:SetDamageType( DMG_DISSOLVE )
		
		local effect = EffectData()
		effect:SetStart(attacker:GetShootPos())
		effect:SetOrigin( tr.HitPos )
		effect:SetEntity( attacker )
		util.Effect( "melonseed", effect )
		
		--[[
		local effect = EffectData()
		effect:SetAttachment(attacker:LookupAttachment("mouth"))
		effect:SetEntity( attacker )
		util.Effect( "AirboatMuzzleFlash", effect )
		]]
	end
		
	owner:FireBullets( bullet )
	
	entity:SetActionInt1(entity:GetActionInt1()-1)
	entity:SetNextAction(CurTime()+0.15)
	entity:SetActionFloat1(CurTime())
	entity:SetActionFloat2(CurTime()+0.3)
	
end


function newsa:UpdateAnimation(entity,owner)
	if SERVER then return end
	if entity:GetActionFloat1() >= CurTime() or entity:GetActionFloat2()< CurTime() then return end 
	
	--right_funneler, left_funneler,jaw_drop, right_puckerer, left_puckerer
	local value=Lerp(math.TimeFraction(entity:GetActionFloat1(),entity:GetActionFloat2(), CurTime() ),2,0)
	if value<=0 then return end
	local FlexNum = owner:GetFlexNum() - 1
	if ( FlexNum <= 0 ) then return end
	
	for i=0, FlexNum-1 do
		
		local Name = owner:GetFlexName( i )

		if ( Name == "right_funneler" or Name == "left_funneler" or Name == "jaw_drop" or Name == "left_puckerer" or Name == "right_puckerer") then
			owner:SetFlexWeight( i, value )
		end
		
	end
	
end

function newsa:PlayerUse(entity,owner,targetentity)
	if IsValid(targetentity) and self:IsMelon(targetentity) and entity:GetActionInt1() < self.MaxAmmo then
		--add 50 ammo
		local ammo=(self.MaxAmmo*25)/100
		entity:SetActionInt1(math.Clamp(entity:GetActionInt1()+ammo,0,self.MaxAmmo))
		owner:EmitSound("Watermelon.BulletImpact")
		entity:SetNextAction(CurTime()+2)
		targetentity:Remove()
	end
	
end

function newsa:IsMelon(entity)
	return entity:GetModel()=="models/props_junk/watermelon01.mdl"
end
