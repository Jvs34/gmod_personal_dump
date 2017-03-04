newsa=nil
newsa=SA:New("Jetpack","sa_jetpack","Look at me spamming the thruster sound when I am bored, wooo")
newsa.CooldownBeforeRecharge=1
newsa.MaxFuel=100
newsa.ChargeRate=10

sound.Add( {
	name = "jetpack.thruster_loop",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 0.1,
	sound = "^thrusters/jet02.wav"
})

function newsa:Initialize(entity,owner)
	if CLIENT then
		entity.jetpackmodel=ClientsideModel("models/thrusters/jetpack.mdl")
		entity.jetpackmodel:SetNoDraw(true)
		entity.jetpackmodel:Spawn()
	end

	entity.Seed = math.Rand( 0, 10000 )
	entity.jetpacksound=CreateSound( entity, "jetpack.thruster_loop" )	--Missile.Ignite
	
	--entity
end

function newsa:ResetVars(entity,owner)
	entity:SetActionBool1(false)
	
	entity:SetActionFloat1(CurTime() + self.CooldownBeforeRecharge)
	entity:SetActionFloat2(self.MaxFuel)
	if entity.jetpacksound then
		entity.jetpacksound:Stop()
	end
	
end

function newsa:Attack(entity,owner)
end

function newsa:Think(entity,owner)
	
	if entity:GetKey()~=IN_JUMP then
		entity:SetKey(IN_JUMP)
	end
	
	if entity:IsKeyDown() and owner:WaterLevel()<=0 and self:CanFly(entity,owner) and owner:GetMoveType()==MOVETYPE_WALK then 
		if entity.jetpacksound then
			entity.jetpacksound:PlayEx(0.3,125)
		end
		if entity:GetActionFloat2() > 0 then
			
			local current=entity:GetActionFloat2()
			local add=(self.MaxFuel/self.ChargeRate)*((self.MaxFuel/self.ChargeRate)*engine.TickInterval())
			local finaladd=math.Clamp(current-add,0,self.MaxFuel)
			entity:SetActionFloat1(CurTime() + self.CooldownBeforeRecharge)
			entity:SetActionFloat2(finaladd)
			
		end
		entity:SetActionBool1(true)
	else
		if entity.jetpacksound then
			entity.jetpacksound:Stop()
		end
		if entity:GetActionFloat2() < self.MaxFuel and entity:GetActionFloat1()<CurTime() then
			local current=entity:GetActionFloat2()
			local add=(self.MaxFuel/self.ChargeRate)*((self.MaxFuel/self.ChargeRate)*engine.TickInterval())
			local finaladd=math.Clamp(current+add,0,self.MaxFuel)
			entity:SetActionFloat2(finaladd)
		end
		entity:SetActionBool1(false)
	end

end

function newsa:CanFly(entity,owner)
	return entity:GetActionFloat2()>0 
end

function newsa:SetupMove(entity,owner,data,cmddata)
	if owner:GetMoveType()~=MOVETYPE_WALK then return end
	if entity:IsKeyDown(data) and self:CanFly(entity,owner) then
		owner:SetGroundEntity(NULL)
	end
end

function newsa:CalcMainActivity(entity,owner,velocity)
	
	--[[
	if not dick then
		owner.SA_CalcIdeal=ACT_HL2MP_IDLE + 9
		owner.SA_CalcSeqOverride = -1
	end
	]]
	
	
	
	if entity:GetActionBool1() and owner:GetMoveType()==MOVETYPE_WALK then
		local vel=velocity:Length2D()
		
		
		if vel>=5 then
			owner.SA_CalcIdeal = IsValid(owner:GetActiveWeapon()) and ACT_MP_SWIM or ACT_HL2MP_IDLE + 9
			
		else
			owner.SA_CalcIdeal = IsValid(owner:GetActiveWeapon()) and ACT_MP_SWIM_IDLE or ACT_HL2MP_IDLE + 9
		end
		
		
		owner.SA_CalcSeqOverride = -1
	end
end

--[[
function newsa:UpdateAnimation(entity,owner,velocity, maxseqgroundspeed)
	if entity:GetActionBool1() and owner:GetMoveType()==MOVETYPE_WALK then
		owner:SetPlaybackRate( 0.1 )
	
	end
end
]]

function newsa:Move(entity,owner,data)
	if owner:GetMoveType()~=MOVETYPE_WALK then return end
	if owner:WaterLevel()>0 then return end
	
	if entity:IsKeyDown(data) and self:CanFly(entity,owner) then
		local oldspeed=data:GetVelocity()
		local sight=owner:EyeAngles()
		local factor=1.5
		local sidespeed=math.Clamp(data:GetSideSpeed(),-data:GetMaxClientSpeed()*factor,data:GetMaxClientSpeed()*factor)
		local forwardspeed=math.Clamp(data:GetForwardSpeed(),-data:GetMaxClientSpeed()*factor,data:GetMaxClientSpeed()*factor)
		local upspeed=data:GetVelocity().z
		sight.pitch=0;
		sight.roll=0;
		sight.yaw=sight.yaw-90;
		local upspeed=(sidespeed<=200 and forwardspeed<=100) and 22 or 12
		
		local moveang=Vector(sidespeed/70,forwardspeed/70,upspeed)
		
		moveang:Rotate(sight)
		local horizontalspeed=moveang
		data:SetVelocity(oldspeed+horizontalspeed)

	end
end

function newsa:Deinitialize(entity,owner)
	if entity.jetpacksound then
		entity.jetpacksound:Stop()
		entity.jetpacksound=nil
	end
	--entity:ResetKey()
	if CLIENT then
		if IsValid(entity.jetpackmodel) then
			entity.jetpackmodel:Remove()
		end
	end
end


newsa.offsetvec=Vector(3,-5.6,0)
newsa.offsetang=Angle(180,90,-90)
newsa.particleoffset=Vector(-5.5,-5.6,0)


local matHeatWave		= Material( "sprites/heatwave" )
local matFire			= Material( "effects/fire_cloud1" )

function newsa:drawFire(entity,owner,pos,normal,scale,vOffset2)
	local vOffset = pos or vector_origin
	local vNormal = normal or vector_origin

	local scroll = entity.Seed + (CurTime() * -10)
	
	local Scale = scale or 1
		
	render.SetMaterial( matFire )
	
	render.StartBeam( 3 )
		render.AddBeam( vOffset, 8 * Scale, scroll, Color( 0, 0, 255, 128) )
		render.AddBeam( vOffset + vNormal * 60 * Scale, 32 * Scale, scroll + 1, Color( 255, 255, 255, 128) )
		render.AddBeam( vOffset + vNormal * 148 * Scale, 32 * Scale, scroll + 3, Color( 255, 255, 255, 0) )
	render.EndBeam()
	
	scroll = scroll * 0.5
	
	render.UpdateRefractTexture()
	render.SetMaterial( matHeatWave )
	render.StartBeam( 3 )
		render.AddBeam( vOffset, 8 * Scale, scroll, Color( 0, 0, 255, 128) )
		render.AddBeam( vOffset + vNormal * 32 * Scale, 32 * Scale, scroll + 2, Color( 255, 255, 255, 255) )
		render.AddBeam( vOffset + vNormal * 128 * Scale, 48 * Scale, scroll + 5, Color( 0, 0, 0, 0) )
	render.EndBeam()
	
	
	scroll = scroll * 1.3
	render.SetMaterial( matFire )
	render.StartBeam( 3 )
		render.AddBeam( vOffset, 8 * Scale, scroll, Color( 0, 0, 255, 128) )
		render.AddBeam( vOffset + vNormal * 60 * Scale, 16 * Scale, scroll + 1, Color( 255, 255, 255, 128) )
		render.AddBeam( vOffset + vNormal * 148 * Scale, 16 * Scale, scroll + 3, Color( 255, 255, 255, 0) )
	render.EndBeam()

	
	if not entity.ParticleEmitter then 
		entity.ParticleEmitter = ParticleEmitter( pos )
	return 
	end
	
	if not entity.NextParticle then entity.NextParticle=CurTime() end
	
	
	if entity.NextParticle>CurTime() then return end
	local particle = entity.ParticleEmitter:Add("particle/particle_noisesphere", vOffset2)
    if not particle then return end
	particle:SetVelocity(normal*20)
	particle:SetDieTime(0.3)
	particle:SetStartAlpha(200)
	particle:SetEndAlpha(0)
	particle:SetStartSize(3)
	particle:SetEndSize( 16 )
	particle:SetRoll( math.Rand( -10,10  ) )
	particle:SetRollDelta(math.Rand( -0.2, 0.2 ))
	particle:SetColor(200,200,200)
	
	entity.NextParticle=CurTime()+0.01
end


function newsa:HUDDraw(entity,owner)
	local fuel=(entity:GetActionFloat2())--math.Round
	local x=ScrW()/2
	local y=ScrH()-(ScrH()/10)
	local maxw=ScrW()/4
	local maxh=ScrH()/25
	surface.SetDrawColor( 0,0,255,255 )
	surface.DrawRect( x-(maxw/2), y, maxw, maxh )
	
	surface.SetDrawColor( 0,250,255,255 )
	surface.DrawRect( x-(maxw/2), y, (maxw *fuel)/100, maxh )
end

--surface.DrawRect( 25, 25, 100, 100 )
function newsa:DrawWorldModel(entity,owner)
	if not IsValid(entity.jetpackmodel) then return end
	local bone=owner:LookupBone("ValveBiped.Bip01_Spine2")
	if not bone then return end
	local matrix = owner:GetBoneMatrix(bone)
	if not matrix then return end
	local pos = matrix:GetTranslation()
	local ang = matrix:GetAngles()
	local off = matrix:GetTranslation()
	pos,ang=LocalToWorld(self.offsetvec,self.offsetang,pos,ang)
	entity.jetpackmodel:SetRenderOrigin(pos)
	entity.jetpackmodel:SetRenderAngles(ang)
	entity.jetpackmodel:DrawModel()
	if entity:GetActionBool1() and self:CanFly(entity,owner) then
		local p,a=LocalToWorld(self.particleoffset,Angle(0,0,0),matrix:GetTranslation(),matrix:GetAngles())
		self:drawFire(entity,owner,pos,ang:Up(),0.2,p)
	end
	
end
