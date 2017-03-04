AddCSLuaFile()

if SERVER then
	umsg.PoolString("dv_killannounce")
end

drive.Register( "drive_crow", 
{
	--
	-- Called on creation
	--
	Init = function( self )
		self.TurnRate = Angle(250,175,150)
		self.CameraDist 	= 4
		self.CameraDistVel 	= 0.1
		self.MaxModes = 2
		self.ViewMode = 0 -- 0 being normal, 1 being firstperson
		self.NextCameraChange=CurTime()
	end,
	
	ToggleView=function(self)
		self.ViewMode = (self.ViewMode<self.MaxModes) and self.ViewMode +1 or 0 
	end,
	--
	-- Calculates the view when driving the entity
	--
	CrowModeOffs={
		pos1=Vector(-3.1,0,12),
		ang1=Angle(0,0,0),
		pos2=Vector(2.5,0,0),
		ang2=Angle(0,0,0),
	},
	CalcView =  function( self, view )

		--
		-- Use the utility method on drive_base.lua to give us a 3rd person view
		--
		local idealdist = math.max( 10, self.Entity:BoundingRadius() ) * self.CameraDist
		
		if not self.Entity:GetDead() then
			view.angles=self.Entity:GetAngles()
			if self.Player:KeyPressed(IN_DUCK) and self.NextCameraChange<=CurTime() then
				self:ToggleView()
				self.NextCameraChange=CurTime()+0.3
			end
			
			if self.ViewMode == 1 and IsValid(self.Entity.LittleOwner) then 
				view.origin=LocalToWorld(self.CrowModeOffs.pos1,self.CrowModeOffs.ang1,view.origin,view.angles)
				idealdist=0
				--[[
				self.Entity.LittleOwner:SetupBones()
				local atch=self.Entity.LittleOwner:GetAttachment(self.Entity.LittleOwner:LookupAttachment("eyes"))
				if atch then
					view.origin=atch.Pos
				end
				idealdist=0
				]]
			elseif self.ViewMode == 2 then
				view.origin=LocalToWorld(self.CrowModeOffs.pos2,self.CrowModeOffs.ang2,view.origin,view.angles)
				idealdist=0
			end
		elseif self.Entity:GetDead() and IsValid(self.Entity.Rag) then
			view.origin=self.Entity.Rag:GetPos()
		end
		
		
		
		
		self:CalcView_ThirdPerson( view, idealdist, 2, { self.Entity, LocalPlayer() } )
		
		
		

	end,
	
	SetupControls = function( self, cmd )				

	end,
	--
	-- Called before each move. You should use your entity and cmd to 
	-- fill mv with information you need for your move.
	--
	StartMove =  function( self, mv, cmd )

		--
		-- Set the observer mode to chase so that the entity is drawn
		--
		self.Player:SetObserverMode( OBS_MODE_CHASE )


		--
		-- Update move position and velocity from our entity
		--
		local old_angle 		= self.Entity:GetAngles()
		local entity_angle		= mv:GetAngles()
		
		--[[
		if mv:KeyDown(IN_MOVELEFT) then
			entity_angle.y = entity_angle.y + 20
		end
		
		if mv:KeyDown(IN_MOVERIGHT) then
			entity_angle.y = entity_angle.y - 20
		end
		
		if mv:KeyDown(IN_FORWARD) then
			entity_angle.p = entity_angle.p + 20
		end
		
		if mv:KeyDown(IN_BACK) then
			entity_angle.p = entity_angle.p - 20
		end
		
		]]
		local rot_difference = math.Clamp(math.AngleDifference(self.Entity:GetAngles().y,entity_angle.y),-60,60)
		
		entity_angle.r=rot_difference
		
		
		entity_angle.p=math.ApproachAngle( old_angle.p, entity_angle.p, self.TurnRate.p * FrameTime()) 
		entity_angle.y=math.ApproachAngle( old_angle.y, entity_angle.y, self.TurnRate.y * FrameTime() ) 
		entity_angle.r=math.ApproachAngle( old_angle.r, entity_angle.r, self.TurnRate.r * FrameTime() ) 
		
		mv:SetOrigin( self.Entity:GetNetworkOrigin() )
		mv:SetVelocity( self.Entity:GetAbsVelocity() )
		
		mv:SetMoveAngles( entity_angle )		-- Always move relative to the player's eyes

		mv:SetAngles( entity_angle )

	end,

	--
	-- Runs the actual move. On the client when there's 
	-- prediction errors this can be run multiple times.
	-- You should try to only change mv.
	--
	Move = function( self, mv )
		
		local ang = mv:GetMoveAngles()
		local pos = mv:GetOrigin()
		local vel = mv:GetVelocity()

		-- Cancel out the roll
		self.Entity:SetFlying(ang.pitch <= 0)
		
		local spd = math.abs(ang.pitch / 90)
		
		local extraspeed = 1
		if ang.pitch >= 0 then
			extraspeed=Lerp(spd,1,3)
			local differentspeed=Lerp(spd,0.9,2)
			self.Entity:AddMomentum(differentspeed*FrameTime()*100)
		else
			extraspeed=Lerp(spd,1,0.3)
			local differentspeed=Lerp(spd,0.9,2)
			self.Entity:RemoveMomentum(differentspeed*FrameTime()*70)
		end
		
		local momentum=self.Entity:GetMomentum()

		
		vel = ang:Forward()	* 440 * extraspeed 
		
		vel = vel + ang:Forward() * momentum
		
		vel = vel*FrameTime()
		
		
		
		local tr=self.Entity:Collide(pos,ang)
		

		
		if tr and (tr.Hit or tr.StartSolid) and not self.Entity:GetDead() then
			self.Entity:EmitSound("NPC_Crow.Pain")
			if SERVER then
				self.Entity:TakeDamage(1,IsValid(tr.Entity) and tr.Entity)
			end
			--print(vel:DotProduct(tr.Normal))
			vel=vector_origin
		end
		
		
		if self.Entity:GetDead() then
			vel=vector_origin
		end

		
		pos = pos + vel
		
		
		mv:SetVelocity( vel )
		mv:SetOrigin( pos )
		
	end,

	--
	-- The move is finished. Use mv to set the new positions
	-- on your entities/players.
	--
	FinishMove =  function( self, mv )

		--
		-- Update our entity!
		--

		self.Entity:SetNetworkOrigin( mv:GetOrigin() )
		self.Entity:SetAbsVelocity( mv:GetVelocity() )
		self.Entity:SetAngles( mv:GetAngles() )
		--
		-- If we have a physics object update that too. But only on the server.
		--
		if ( IsValid( self.Entity:GetPhysicsObject() ) ) then

			self.Entity:GetPhysicsObject():EnableMotion( true )
			self.Entity:GetPhysicsObject():SetPos( mv:GetOrigin() );
			self.Entity:GetPhysicsObject():Wake()
			self.Entity:GetPhysicsObject():EnableMotion( false )

		end

	end
	


}, "drive_base" );


if CLIENT then
	local sa_rocket_hazardstripes = CreateMaterial("sa_rocket_hazardstripes", "VertexLitGeneric", {
		["$basetexture"] = "dev/dev_hazzardstripe01a",
	})

	local sa_rocket_laserglow = CreateMaterial("sa_rocket_laserglow","UnlitGeneric",{
		["$basetexture"] = "sprites/light_glow02",
		["$nocull"] = 1,
		["$additive"] = 1,
		["$vertexalpha"] = 1,
		["$vertexcolor"] = 1,
		["$spriterendermode"] = RENDERMODE_GLOW,
	})

	local arm_angle_1 = 45
	local arm_angle_2 = 60
	local arm_angle_3 = 45

	local submodel_rocket_fins = {}
	for i=1,4 do
		submodel_rocket_fins[i] = {
			transform = {Vector(0, 0, 0), Angle(90,(i-1)*90,0), Vector(1,1,1)},
			children = {{
				model = "models/hunter/triangles/05x05.mdl",
				material = "models/props_c17/FurnitureMetal001a",
				color = Color(180, 80, 80),
				transform = {Vector(-10, 20, 0), Angle(0,0,0), Vector(1,0.6,1)},
			}}
		}
	end
	submodel_rocket_fins = multimodel.Flatten(submodel_rocket_fins)

	local submodel_rocket = {
		{
			model = "models/props_c17/oildrum001.mdl",
			material = "models/props_c17/FurnitureMetal001a",
			color = Color(180, 80, 80),
			transform = {Vector(0, 0, 0), Angle(0,0,0), Vector(1,1,0.5)},
		},
		
		{children = submodel_rocket_fins},
		
		{
			model = "models/props_c17/oildrum001.mdl",
			--material = "models/props_c17/FurnitureMetal001a",
			material = sa_rocket_hazardstripes,
			
			color = Color(255, 255, 255),
			transform = {Vector(0, 0, 20), Angle(0,0,0), Vector(0.8,0.8,0.5)},
		},
		{
			model = "models/props_borealis/bluebarrel001.mdl",
			material = "models/props_c17/FurnitureMetal001a",
			color = Color(180, 80, 80),
			transform = {Vector(0, 0, 50), Angle(180,0,0), Vector(1,1,0.5)},
		},
		{
			model = "models/hunter/tubes/circle2x2.mdl",
			transform = {Vector(0, 0, 0), Angle(0,0,0), Vector(0.2,0.2,0.3)},
			material = "models/debug/debugwhite",
			color = Color(255, 100, 40, 255),
			selfillum = true,
		},
		{
			sprite = sa_rocket_laserglow,
			color = Color(255, 150, 0, 255),
			transform = {Vector(0,0,-2),Angle(0, 0,0),Vector(100,100,100)},
			translucent = true,
		},
	}
	multimodel.Register("sdv_rocket", {
		{
			outputname = "rocket",
			transform = {Vector(0,0,0), Angle(0,90,90), Vector(1,1,1)/12},
			children = submodel_rocket,
		},
	
	})
end







local ClassName="sent_driveable_crow"
local ENT={}

ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.RenderGroup     = RENDERGROUP_OPAQUE
ENT.PrintName        = "Controllable Crow"
ENT.Author="Jvs"
ENT.Spawnable = true  
ENT.AdminOnly = false  
ENT.MaxSpeed = 1000


function ENT:SpawnFunction( ply, tr )
    if ( not tr.Hit or ply:IsDrivingEntity() ) then return end
    
    local SpawnPos = tr.HitPos + tr.HitNormal * 100     
    local ent = ents.Create("sent_driveable_crow")
    ent:SetPos( SpawnPos )
    ent:SetOwner(ply)
	ent:SetOwnerModel(ply:GetModel())
	ent:SetAngles(ply:EyeAngles())
	ent:Spawn()
    ent:Activate()
	
	return ent
end




function ENT:Initialize()
	if SERVER then
		self:SetModel("models/crow.mdl") --"models/props_borealis/bluebarrel001.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetDead(false)
		self:SetNextCaw(CurTime()+1)
		self:SetMomentum(0)
		self:SetHasBomb(true)
		self:SetHasRocket(true)
		self:SetNextRocket(CurTime()+0.5)
		self:SetSpawnPosition(self:GetPos())
	else
		self.LittleOwner = ClientsideModel(self:GetOwnerModel())
		self.LittleOwner:SetOwner(self:GetOwner())
		self.LittleOwner.GetPlayerColor=function(self) return self:GetOwner():GetPlayerColor() end
		self.LittleOwner:SetModelScale(0.2,0)
		self.LittleOwner:SetNoDraw(true)
		self.LittleOwner:ResetSequence( self.LittleOwner:LookupSequence( "sit_zen" ) )
		
		self.MiniBomb = ClientsideModel("models/props_phx/ww2bomb.mdl")
		self.MiniBomb:SetModelScale(0.5,0)
		self.MiniBomb:SetNoDraw(true)
		
		self.Rocket = multimodel.CreateInstance("sdv_rocket")
		
		
		
		--self.LittleOwner:ResetSequence( self.LittleOwner:LookupSequence( "sit_rollercoaster" ) )
		--self.LittleOwner:SetPoseParameter( "vertical_velocity", 1  )
	end
	self.FlapSound = CreateSound( self, "NPC_Crow.Flap" )
	self.WindSound = CreateSound( self, "vehicles/fast_windloop1.wav")
	
	
	self:SetSequence("Fly01")
	self:SetPlaybackRate(1)
	self.CycleFrame = 0

end

function ENT:SetupDataTables()
	self:NetworkVar("Bool",0,"Flying")
	self:NetworkVar("Bool",1,"Dead")
	self:NetworkVar("Bool",2,"HasBomb")
	self:NetworkVar("Bool",3,"HasRocket")
	
	self:NetworkVar("Float",0,"NextCaw")
	self:NetworkVar("Float",1,"Momentum")
	self:NetworkVar("Float",2,"NextRocket")
	self:NetworkVar("Float",3,"NextRespawn")
	
	
	self:NetworkVar("String",0,"OwnerModel")
	self:NetworkVar("Entity",0,"LastObject")
	
	self:NetworkVar("Vector",0,"SpawnPosition")
end

function ENT:OnTakeDamage(dmginfo)
	if not self:GetDead() then
		net.Start("dv_killannounce")
			net.WriteString((IsValid(dmginfo:GetAttacker())and dmginfo:GetAttacker().Name) and dmginfo:GetAttacker():Name() or self:Name())
			net.WriteString((IsValid(dmginfo:GetInflictor()) and dmginfo:GetAttacker().Name) and dmginfo:GetInflictor():GetClass() or "prop_physics")
			net.WriteString(self:Name())
		net.Broadcast()
		self:SetNextRespawn(CurTime()+2)
		self:SetDead(true)
		self:SetNoDraw(true)
		--SafeRemoveEntityDelayed(self,1)
	end
end

function ENT:Name()
	return self:GetOwner():Name().."'s Crow"
end

function ENT:Team()
	return self:GetOwner():Team()
end

if CLIENT then
	net.Receive("dv_killannounce", function(len)
		local attacker=net.ReadString()
		local inflictor=net.ReadString()
		local victim=net.ReadString()
		
		GAMEMODE:AddDeathNotice( attacker, 0, inflictor, victim, 0 )
	end)
end

function ENT:Collide(pos,ang)
	local tracedata = {}
	local offset=Vector(0,0,5)
	tracedata.start = offset + pos
	tracedata.endpos = offset + pos + ang:Forward()	* 25
	tracedata.filter = {self,self:GetLastObject()}
	tracedata.mins = Vector(-12,-17,-9)
	tracedata.maxs = Vector(12,17,9)
	tracedata.mask	=	MASK_SOLID + MASK_WATER
	return util.TraceHull( tracedata )
end




--[[
--sit_zen bitch
ENT.LO_Offsets={
	pos=Vector(0,0,7),
	ang=Angle(0,0,0)
}
]]
--[[
--this is for the normal sit_rollercoaster
ENT.LO_Offsets={
	pos=Vector(0,0,8),
	ang=Angle(0,0,0)
}
]]

ENT.LO_Offsets={
	pos=Vector(0,1.7,-2),
	ang=Angle(-110,-90,0)
}

ENT.MB_Offsets={
	pos=Vector(0,-2,-1),
	ang=Angle(-65,90,0)
}

ENT.MR_Offsets={
	pos=Vector(0,-3.8,-2),
	ang=Angle(-65,90,0)
}

function ENT:Draw()
	if self:GetDead() then return end
	self:DrawModel()
	local pos=Vector(0,0,0)
	local ang=Angle(0,0,0)
	local bm=self:GetBoneMatrix(self:LookupBone("Crow.Body"))
	if bm then
		pos=bm:GetTranslation()
		ang=bm:GetAngles()
	end
	if IsValid(self.LittleOwner) then

		
		local p,a=LocalToWorld(self.LO_Offsets.pos,self.LO_Offsets.ang,pos,ang)
		self.LittleOwner:SetRenderOrigin(p)
		self.LittleOwner:SetRenderAngles(a)
		--self.LittleOwner:SetPoseParameter( "vertical_velocity",0 ) 
		self.LittleOwner:SetEyeTarget(self:GetOwner():EyePos())
		self.LittleOwner:DrawModel()
		
	end
	
	--[[
	if IsValid(self.MiniBomb) and self:GetHasBomb() then
		local p,a=LocalToWorld(self.MB_Offsets.pos,self.MB_Offsets.ang,pos,ang)
		self.MiniBomb:SetRenderOrigin(p)
		self.MiniBomb:SetRenderAngles(a)
		self.MiniBomb:DrawModel()
		
	end
	]]
	if self.Rocket and not IsValid(self:GetLastObject()) then--self:GetHasRocket() then
		local p,a=LocalToWorld(self.MR_Offsets.pos,self.MR_Offsets.ang,pos,ang)
		multimodel.Draw(self.Rocket,self:GetOwner(),{origin=p,angles=a})
	end
end

function ENT:AddMomentum(m)
	local addm= (m) and math.abs(m) or 0
	addm=self:GetMomentum() + addm
	addm=math.Clamp(addm,0,self.MaxSpeed)
	self:SetMomentum(addm)
end

function ENT:RemoveMomentum(m)
	local addm= (m) and math.abs(m) or 0
	addm=self:GetMomentum() - addm
	addm=math.Clamp(addm,0,self.MaxSpeed)
	self:SetMomentum(addm)
end



function ENT:Use(activator)

end

function ENT:Think()
	if SERVER and IsValid(self:GetOwner()) and not self:GetOwner():IsDrivingEntity() then
		drive.PlayerStartDriving( self:GetOwner(), self, "drive_crow" )
	end
	
	
	if self:GetDead() then
		if self:GetNextRespawn() < CurTime() then
			self:SetNoDraw(false)
			if CLIENT then
				if IsValid(self.Rag) then
					self.Rag:Remove()
				end
			end
			self:SetDead(false)
			self:SetMomentum(0)
			self:SetPos(self:GetSpawnPosition())
			self:SetNetworkOrigin(self:GetSpawnPosition())
			self:SetNextRespawn(CurTime()+2)
		end
	else
		if not self.Cycle then

			self.Cycle = 0

		end
		
		if self.WindSound then
			self.WindSound:Play()
			self.WindSound:ChangeVolume(0.3,0)
		end
		if self:GetFlying() then
			self:SetSequence("Fly01")
			if self.FlapSound then
				self.FlapSound:Play()
				self.FlapSound:ChangeVolume(1,0)
			end
		else
			self:SetSequence("soar")
			if self.FlapSound then
				self.FlapSound:Stop()
				self.FlapSound:ChangeVolume(1,0)
			end
		end
		self:SetCycle(self.Cycle)
		self.Cycle = (self.Cycle + 1.5*FrameTime()) % 1
	end
	
	if CLIENT and self:GetDead() and not IsValid(self.Rag) then
		if self.MyLastVelocity then
			self:SetAbsVelocity(self.MyLastVelocity)
		end
		self.Rag=self:BecomeRagdollOnClient()
		if self.FlapSound then
			self.FlapSound:Stop()
		end
		if self.WindSound then
			self.WindSound:Stop()
		end
	end
	
	if CLIENT and LocalPlayer()~=self:GetOwner() then return end
	
	
	if self:GetDead() then return end	--we don't want to do any of this when dead
	
	if self:GetVelocity():Length() > 0 then
		self.MyLastVelocity=self:GetVelocity()
	end
	
	if self:GetNextCaw() < CurTime() and self:GetOwner():KeyPressed(IN_ATTACK2) then
		self:EmitSound("NPC_Crow.Pain")
		if SERVER then
			local tracedata = {}
			tracedata.start =  self:GetPos()
			tracedata.endpos = self:GetPos() + Vector(0,0,-1) * 16000
			tracedata.filter = {self,self:GetOwner(),self:GetLastObject()}
			local trace = util.TraceLine( tracedata )
			local pos1 = trace.HitPos + trace.HitNormal
			local pos2 = trace.HitPos - trace.HitNormal
			util.Decal( "birdpoop", pos1, pos2 )
		end
		self:SetNextCaw(CurTime()+1)
	end
	
	--if self:GetHasRocket() and self:GetOwner():KeyDown(IN_ATTACK2) then
	if not IsValid(self:GetLastObject()) and self:GetOwner():KeyPressed(IN_ATTACK) and self:GetNextRocket() < CurTime() then
		
		if SERVER then
			
			local target=NULL
			local potentialtargets=ents.FindInSphere( self:GetPos(), 2048 )
			for i,v in pairs(potentialtargets) do
				if v==self then continue end
				if v:GetClass()==self:GetClass() and not v:GetDead() --[[or v:IsPlayer()]] or v:IsNPC() then
				--if v:GetClass()==self:GetClass() or v:IsPlayer() or v:IsNPC() then
					target=v
					break
				end
			end
			if not IsValid(target) then return end
			self:EmitSound("NPC_Crow.Alert")
			local rocket=ents.Create("sdv_rocket")
			rocket:SetOwner(self)
			local pos,ang=LocalToWorld(Vector(-3,0,2.7),Angle(0,0,0),self:GetPos(),self:GetAngles())
			rocket:SetPos(pos)
			rocket:SetAngles(ang)
			--[[
			if IsValid(target) then
				rocket.SpeedModifier=0.75
			end
			]]
			rocket:Spawn()
			rocket:SetTarget(target)
			self:SetHasRocket(false)
			self:SetLastObject(rocket)
			self:SetNextRocket(CurTime()+2)
		end
		
	end
	
end

function ENT:OnRemove()
	if self.FlapSound then
		self.FlapSound:Stop()
	end
	if self.WindSound then
		self.WindSound:Stop()
	end
	if IsValid(self.LittleOwner) then
		self.LittleOwner:Remove()
	end	
	if IsValid(self.MiniBomb) then
		self.MiniBomb:Remove()
	end	
	
	--[[
	if CLIENT then
		self.Rag=self:BecomeRagdollOnClient()

	end
	]]
end

scripted_ents.Register(ENT,ClassName,true)










local ENT2={}
ENT2.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT2.Type             = "anim"
ENT2.Base             = "base_anim"
ENT2.PrintName        = ""
ENT2.Author            = "Jvs"
ENT2.Information        = ""
ENT2.Category        = ""
ENT2.Spawnable            = false
ENT2.AdminSpawnable        = false
ENT2.RocketSpeed=1000
ENT2.SpeedModifier=1
ENT2.TurnRate = 30
local CollisionBounds = {Vector(-5,-5,5), Vector(5,5,5)}



function ENT2:Initialize()
	self:SetCustomCollisionCheck(true)
	if SERVER then
		self:SetModel("models/weapons/w_missile.mdl")
		self:SetMoveType(MOVETYPE_NONE)
		self:DrawShadow(false)
		
		self:SetNotSolid(false)
		self:SetSolid(SOLID_BBOX)
		self:SetCollisionBounds(unpack(CollisionBounds))
		self:SetTrigger(true)
		
		self:SetMoveType(MOVETYPE_FLY)
		self:SetMoveCollide(MOVECOLLIDE_FLY_CUSTOM)
		self:SetLocalVelocity( self.RocketSpeed * self.SpeedModifier * self:GetForward())
		
		self.TimeCreated = CurTime()
		self.ReachMaximumSpeedAt = self.TimeCreated + 4
	end
	if CLIENT then
		self.mm = multimodel.CreateInstance("sdv_rocket")
	end
	self.missilesound=CreateSound( self, "Missile.Ignite" )
	self.Seed = math.Rand( 0, 10000 )
	self.NextPing=CurTime()
end
local matHeatWave		= Material( "sprites/heatwave" )
local matFire			= Material( "effects/fire_cloud1" )

function ENT2:drawFire(pos,normal,scale,vOffset2,particles)
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
	
	if particles then
		if not self.ParticleEmitter then 
			self.ParticleEmitter = ParticleEmitter( pos )
			return 
		end
		
		local particle = self.ParticleEmitter:Add("particle/particle_noisesphere", vOffset2)
		if not particle then return end
		particle:SetVelocity(normal*20)
		particle:SetDieTime(0.5)
		particle:SetStartAlpha(150)
		particle:SetEndAlpha(0)
		particle:SetStartSize(2)
		particle:SetEndSize(10)
		particle:SetRoll( math.Rand( -10,10  ) )
		particle:SetRollDelta(math.Rand( -0.2, 0.2 ))
		particle:SetColor(200,200,200)
	end
end

function ENT2:Draw()
    self:DrawModel()
	if not self.Attachments then
		self.Attachments = {}
	end
	
	multimodel.DoFrameAdvance(self.mm, CurTime(), self)
	
	multimodel.SetOutputTarget(self.Attachments)
	multimodel.Draw(self.mm, self)
	multimodel.SetOutputTarget(nil)
	
	local doParticles = false
	if not self.NextParticle then self.NextParticle=CurTime() end
	if CurTime() > self.NextParticle then
		doParticles = true
		self.NextParticle=CurTime()+0.01
	end
	
	local atch = self.Attachments.rocket
	if atch then
		self:drawFire(atch.pos, -1 * atch.ang:Up(), 0.2, atch.pos, doParticles)
	end
end

function ENT2:SetupDataTables()

	self:NetworkVar( "Entity", 0, "Target")
	self:NetworkVar( "Bool", 0, "Detonated")
end


function ENT2:Think()
	if not self:GetDetonated() and self.missilesound then
		self.missilesound:PlayEx(1,100)
	else
		self.missilesound:Stop()
	end
	if self:GetDetonated() then return end
	
	
	if CLIENT and IsValid(self:GetTarget()) then
		if self:GetTarget():GetOwner() == LocalPlayer() or self:GetTarget() == LocalPlayer() then
			--do a lerp between the distance between us and the target
			--then use that to increase the rate at which the ping plays
			local pingrate=1
			local dist=self:GetPos():Distance(self:GetTarget():GetPos())
			dist=math.Clamp(dist,0,3000)
			pingrate=Lerp(dist/3000,0.1,1)
			if self.NextPing < CurTime() then
				self:GetTarget():EmitSound("NPC_Turret.Ping",200)
				self.NextPing = CurTime() + pingrate
			end
		end
	end
	
	if SERVER and IsValid(self:GetTarget())then
		
		if (self:GetTarget():IsPlayer() and not self:GetTarget():Alive() or self:GetTarget().GetDead and self:GetTarget():GetDead()) then 
			--we don't want the rocket to follow the entity after death, so disjoint the target
			self:SetTarget(NULL)
			return 
		end
		--increase the speed up to 1.5 when we're tracking
		self.SpeedModifier=Lerp(math.TimeFraction(self.TimeCreated,self.ReachMaximumSpeedAt, CurTime() ),1,1.5)
		--get the obb center and target that
		local targetpos=LocalToWorld(self:GetTarget():OBBCenter(),Angle(),self:GetTarget():GetPos(),Angle())
		local direction=(targetpos-self:GetPos()):GetNormal()
		--self:SetLocalVelocity(direction * self.SpeedModifier *self.RocketSpeed )
		
		
		local old_angle=self:GetAngles()
		local entity_angle=direction:Angle()
		entity_angle.p=math.ApproachAngle( old_angle.p, entity_angle.p, self.TurnRate   ) 
		entity_angle.y=math.ApproachAngle( old_angle.y, entity_angle.y, self.TurnRate  ) 
		entity_angle.r=math.ApproachAngle( old_angle.r, entity_angle.r, self.TurnRate  ) 
	
		
		self:SetLocalVelocity(entity_angle:Forward() * self.SpeedModifier * self.RocketSpeed )
		self:SetAngles(entity_angle)
		
		--self:SetAngles(direction:Angle())
		--self:PointAtEntity(self:GetTarget())
		--self:SetLocalVelocity( self.SpeedModifier *self.RocketSpeed * self:GetForward())
	end
	

end

function ENT2:OnTakeDamage(dmgfo)
	self:Detonate()
end

function ENT2:Detonate()
    if self:GetDetonated() then return end
	self:SetDetonated(true)
	if SERVER then
		util.BlastDamage( self ,IsValid(self:GetOwner()) and self:GetOwner() or self , self:GetPos(),75, 5 )
	end
	util.ScreenShake( self:GetPos(), 25, 150.0, 1.0, 350 )
	local effectdata = EffectData()
	effectdata:SetScale(128)
	effectdata:SetOrigin( self:GetPos())
	effectdata:SetMagnitude(128)
	local effectstring=(self:WaterLevel()>2) and "WaterSurfaceExplosion" or "Explosion"
	local filter = RecipientFilter()
	filter:AddAllPlayers()
	
	util.Effect( effectstring, effectdata,false,filter)
	if self:WaterLevel()<1 then self:EmitSound("BaseExplosionEffect.Sound") end
	if SERVER then
		self:Remove()
	end
end

function ENT2:Touch( ent )
	if ent~=self:GetOwner() then
        self:Detonate()
    end
end

function ENT2:OnRemove()
	if self.missilesound then
		self.missilesound:Stop()
	end
end
if CLIENT then
	killicon.AddFont( "sdv_rocket", "HL2MPTypeDeath","3", Color( 255, 80, 0, 255 ) )
end
scripted_ents.Register(ENT2,"sdv_rocket",true)

