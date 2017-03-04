
newsa=nil
newsa=SA:New("Teleporter","sa_teleporter","Im over here, zip zap, ahh~")
newsa.TPCooldown=2
newsa.Range=16000
function newsa:ResetVars(entity,owner)
	entity:SetActionVector1(Vector(0,0,0))
	entity:SetActionVector2(Vector(0,0,0))
	entity:SetActionFloat1(CurTime())
	entity:SetActionFloat2(CurTime())
end

function newsa:Attack(entity,owner)
	entity:SetNextAction(CurTime()+self.TPCooldown)
	

	
	local tr=self:DoTeleporterTrace(entity,owner)

	if not tr.HitSky and tr.Hit then
		
		local len=(owner:EyePos():Distance(tr.HitPos))/self.Range
		local timetoreach=Lerp(tr.Fraction,0.1,0.7)
		
		entity:SetNextAction(CurTime()+timetoreach + 0.4)
		
		local effectdata = EffectData()
		effectdata:SetEntity(owner)
		effectdata:SetOrigin(owner:GetPos())
		effectdata:SetAngles(owner:EyeAngles())
		effectdata:SetFlags( 0 )
		effectdata:SetScale(timetoreach)
		util.Effect( "sa_tp_effect", effectdata )
		
		local effectdata = EffectData()
		effectdata:SetEntity(owner)
		effectdata:SetOrigin(tr.HitPos)
		effectdata:SetAngles(owner:EyeAngles())
		effectdata:SetFlags( 1 )
		effectdata:SetScale(timetoreach)
		util.Effect( "sa_tp_effect", effectdata )
		
		
		
		if SERVER then
			owner:EmitSound("ambient/energy/weld2.wav")
		end
		
		entity:SetActionVector1(tr.HitPos)
		entity:SetActionVector2(owner:GetPos())
		entity:SetActionFloat1(CurTime()+timetoreach)
		entity:SetActionFloat2(CurTime())
		
	end
	
end

function newsa:Think(entity,owner,mv)
	local tr=self:DoTeleporterTrace(entity,owner)
	if tr.Hit then
		debugoverlay.BoxAngles( tr.HitPos,owner:OBBMins() , owner:OBBMaxs(), angle_zero, 0.1, Color( 255, 255, 0, 100 ) )
	end
	if entity:GetActionFloat1()< CurTime() and entity:GetActionVector1()~=vector_origin then
		entity:SetActionVector1(Vector(0,0,0))
		entity:SetActionVector2(Vector(0,0,0))
		entity:SetActionFloat1(CurTime())
		entity:SetActionFloat2(CurTime())

	end
	
end

function newsa:SetupMove(entity,owner,mv)
	if entity:GetActionVector1()~=vector_origin and entity:GetActionFloat1()>=CurTime() then
		owner:SetGroundEntity(NULL)
		local movelerp=LerpVector(math.TimeFraction(entity:GetActionFloat2(),entity:GetActionFloat1(), CurTime() ),entity:GetActionVector2(),entity:GetActionVector1())
		mv:SetOrigin(movelerp)
		mv:SetVelocity(vector_origin)
	end
end

function newsa:DoTeleporterTrace(entity,owner)
	local tr={}
	tr.filter=owner
	tr.mask=MASK_SOLID_BRUSHONLY
	tr.start=owner:EyePos()
	tr.endpos=(owner:EyePos()+owner:GetAimVector()*self.Range)
	
	tr.mins=owner:OBBMins()
	tr.maxs=owner:OBBMaxs()
	return util.TraceHull(tr)
end


if CLIENT then
	newsa.TPHUDEffect=CreateMaterial("tphudeyeeffect"..CurTime(),"UnlitGeneric",{
	["$basetexture"] = "effects/tp_eyefx/tp_eyefx-i",
	["$nocull"] = 1,
	["$vertexalpha"] = 1,
	["$vertexcolor"] = 1,
})



    local EFFECT={}
    EFFECT.Mat = Material("models/wireframe")
    EFFECT.DieT=0.3
    EFFECT.Color=Color(100,160,255,255)

    function EFFECT:Init( data )
		self.DieTime = CurTime() + data:GetScale() + self.DieT--self.DieT
		self.StartTime = CurTime()
		self.Ent =    data:GetEntity()
		self.Pos = data:GetOrigin()
		self.Ang = data:GetAngles()
		self.Ang.p = 0
		self.Ang.r = 0
		self.FollowEntity = data:GetFlags()==1
	
		
		if not IsValid(self.Ent) then return end
		
		self:SetPos(self.Pos)
		if not self.FollowEntity then
			self.Ent:SetupBones()
			self.EffectModel=ClientsideModel(self.Ent:GetModel())
			self.EffectModel:SetMaterial("models/wireframe")
			self.EffectModel:SetNoDraw(true)
			self.EffectModel:SetPos(self.Pos)
			self.EffectModel:SetAngles(self.Ang)
			self.EffectModel:SetSequence(self.Ent:GetSequence())
			self.EffectModel:ClearPoseParameters()
			self.EffectModel.AutomaticFrameAdvance=false
			self.EffectModel.Cycle=self.Ent:GetCycle()
			--[[
			for i=0,self.Ent:GetNumPoseParameters()-1 do
				local n=self.Ent:GetPoseParameterName(i)
				if not n then continue end
				local a,b=self.Ent:GetPoseParameterRange(i)
				local rang=(b/a)/2
				
				local val=self.Ent:GetPoseParameter(n)
				
				self.EffectModel:SetPoseParameter(n,val)
			end]]
		
		end
		
		local vOffset = vector_origin

			
		self.emitter = ParticleEmitter( self.Pos )
		self.NextParticleEmit=0
		if not self.FollowEntity then
			self:EmitParticles()
		end
		
		
		self:SetRenderBounds( self.Ent:OBBMins(),self.Ent:OBBMaxs() )
		

    end
	
	function EFFECT:EmitParticles()
		if self.NextParticleEmit > CurTime() then return end
		local Low, High = self.Ent:OBBMins(),self.Ent:OBBMaxs()
		
		NumParticles = self.Ent:BoundingRadius()
		NumParticles = NumParticles * 4
		
		NumParticles = math.Clamp( NumParticles, 32, 256 )
		
		vOffset = self.Pos
		for i=0, NumParticles do
		
			local vPos = Vector( math.Rand(Low.x,High.x), math.Rand(Low.y,High.y), math.Rand(Low.z,High.z) )
			local particle = self.emitter:Add( "effects/spark",  vPos + vOffset )
			if (particle) then
			
				particle:SetVelocity( self.Ent:GetVelocity() )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( math.Rand( 0.5, 1.0 ) )
				particle:SetStartAlpha( math.Rand( 200, 255 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 2 )
				particle:SetEndSize( 0 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( 0 )
				
				particle:SetAirResistance( 100 )
				particle:SetGravity( Vector( 0, 0, -300 ) )
				particle:SetCollide( true )
				particle:SetBounce( 0.3 )
				
			end
		end
		self.NextParticleEmit=CurTime()+0.05
		self.emitter:Finish()
	end
	
    function EFFECT:Think( )

		
        if ( CurTime() > self.DieTime and IsValid(self.Ent) ) then 
			

			
			return false
        end
        return true

    end
    function EFFECT:Render( )
		if not IsValid(self.Ent) then return end
		
		if self.FollowEntity then
			self:SetPos(self.Ent:GetPos())
			--self:EmitParticles()
		end
		
		local alpha=Lerp(math.TimeFraction(self.StartTime,self.DieTime, CurTime() ),255,0)/255
		
		render.SetBlend(alpha)
		if not self.FollowEntity and IsValid(self.EffectModel) then
			self.EffectModel:SetCycle(self.EffectModel.Cycle)
			self.EffectModel:DrawModel()
		else
			render.MaterialOverride(self.Mat)
			self.Ent:DrawModel()
			render.MaterialOverride(nil)
		end
		render.SetBlend(1)
    end
    effects.Register(EFFECT,"sa_tp_effect")

end


function newsa:HUDDraw(entity,owner)
	--[[
	surface.SetMaterial(self.TPHUDEffect)
	surface.SetDrawColor( color_white )
	surface.DrawTexturedRect( 0,0,ScrW(), ScrH() )
	]]
end

function newsa:PrePlayerDraw(entity,owner)

end

function newsa:PostPlayerDraw(entity,owner)

end