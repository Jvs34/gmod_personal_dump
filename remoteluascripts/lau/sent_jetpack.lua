local ClassName="sent_jetpack"
local ENT={}

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.PrintName        = "Jetpack"
ENT.Author            = "Jvs"
ENT.Information        = ""
ENT.Category        = "Other"
ENT.Spawnable            = true
ENT.AdminOnly        = true

util.PrecacheSound("Missile.Ignite")
util.PrecacheSound("Weapon_PhysCannon.Launch")

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end
	
	local size = math.random( 16, 48 )
	local SpawnPos = tr.HitPos + tr.HitNormal * size
	
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

function ENT:Initialize()
	if SERVER then
		self:SetModel( "models/thrusters/jetpack.mdl" )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
	end
	self.Seed = math.Rand( 0, 10000 )
	self.missilesound=CreateSound( self, "Missile.Ignite" )
end

function ENT:SetupDataTables()
    self:DTVar( "Int", 0, "Fuel" )
	self:DTVar( "Bool", 0, "IsFlying" )
end

function ENT:Use(activator)
	if IsValid(self:GetOwner()) or IsValid(activator:GetNWEntity("JetPack")) then return end
	
	if SERVER then
		self:SetOwner(activator)
		self:SetPos(self:GetOwner():GetPos())
		self:SetAngles(self:GetOwner():EyeAngles())
		self:SetParent(self:GetOwner())
		self:GetOwner():SetNWEntity("JetPack",self)
		self:DrawShadow(false)
		self:SetNoDraw(true)
		--self:SetMoveType(MOVETYPE_VPHYSICS)	--not needed, the parenting system will take care of it
		self:SetSolid(SOLID_NONE)
	end
	
end


local matHeatWave		= Material( "sprites/heatwave" )
local matFire			= Material( "effects/fire_cloud1" )

function ENT:drawFire(pos,normal,scale,vOffset2)
	local vOffset = pos or vector_origin
	local vNormal = normal or vector_origin

	local scroll = self.Seed + (CurTime() * -10) --math.random(50,1000)
	
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

	
	if not self.ParticleEmitter then 
		self.ParticleEmitter = ParticleEmitter( pos )
	return 
	end
	
	if not self.NextParticle then self.NextParticle=CurTime() end
	
	
	if self.NextParticle>CurTime() then return end
	local particle = self.ParticleEmitter:Add("particle/particle_noisesphere", vOffset2)
    if not particle then return end
	particle:SetVelocity(normal*20)
	particle:SetDieTime(0.5)
	particle:SetStartAlpha(200)
	particle:SetEndAlpha(0)
	particle:SetStartSize(3)
	particle:SetEndSize( 16 )
	particle:SetRoll( math.Rand( -10,10  ) )
	particle:SetRollDelta(math.Rand( -0.2, 0.2 ))
	particle:SetColor(200,200,200)
	
	self.NextParticle=CurTime()+0.02
	
end

hook.Add("PostPlayerDraw", "Jetpack", function(ply)
	if not IsValid(ply:GetNWEntity("JetPack")) then return end
	local matrix = ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_Spine2"))
	if not matrix then return end
	local pos = matrix:GetTranslation()
	if not pos then return end
	local ang = matrix:GetAngles()
	if not ang then return end
	if not ply:GetNWEntity("JetPack").DrawJetpack then return end
	ply:GetNWEntity("JetPack"):DrawJetpack(matrix)
end)

function ENT:Draw()
	--if IsValid(self:GetOwner()) then return end
	self:DrawModel()
end

local offsetvec=Vector(3,-5.6,0)
local offsetang=Angle(180,90,-90)
local particleoffset=Vector(-5.5,-5.6,0)
function ENT:DrawJetpack(matrix)
	if not matrix then return end
	local pos = matrix:GetTranslation()
	local ang = matrix:GetAngles()
	local off = matrix:GetTranslation()
	pos,ang=LocalToWorld(offsetvec,offsetang,pos,ang)
	self:SetRenderOrigin(pos)
	self:SetRenderAngles(ang)
	self:DrawModel()
	if self.dt.IsFlying then
		local p,a=LocalToWorld(particleoffset,Angle(0,0,0),matrix:GetTranslation(),matrix:GetAngles())
		self:drawFire(pos,ang:Up(),0.2,p)
	end
end

function ENT:Think()
	if not self.dt then return end
	local ply=self:GetOwner()
	if not IsValid(ply) then return end

	if ply:Alive() and ply:KeyDown(IN_JUMP) and ply:WaterLevel()<=0 and self:CanFly() then 
		if SERVER or  (CLIENT and LocalPlayer()==self:GetOwner()) then 
			self.missilesound:PlayEx(0.3,250)
			self.dt.IsFlying=true
		end
	else
		if SERVER or  (CLIENT and LocalPlayer()==self:GetOwner()) then 
			self.missilesound:Stop()
			self.dt.IsFlying=false
		end
	end

end

function ENT:CanFly()
	return true		--for now
end

function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end 

function ENT:OnRemove()
	self.missilesound:Stop()
end



function LPGB(dotrace)
	if not dotrace then
	for i=0,LocalPlayer():GetBoneCount()-1 do
		print(LocalPlayer():GetBoneName(i))
	end
	else
	local entity=LocalPlayer():GetEyeTrace().Entity
	if not IsValid(entity) then return end
	for i=0,entity:GetBoneCount()-1 do
		print(entity:GetBoneName(i))
	end
	end
end


hook.Add("Move","Jetpack",function(ply,data)
	if not ply:Alive() or ply:WaterLevel()>0 then return end
	if not IsValid(ply:GetNWEntity("JetPack")) then return end
	if data:KeyDown(IN_JUMP) and ply:GetNWEntity("JetPack"):CanFly() then
		ply:SetGroundEntity(NULL)
		local oldspeed=data:GetVelocity()
		local sight=ply:EyeAngles()
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
		return
	end
end)



scripted_ents.Register(ENT,ClassName,true)