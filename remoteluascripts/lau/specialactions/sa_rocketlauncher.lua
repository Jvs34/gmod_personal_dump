
local newsa=SA:New("Shoulder Rocket Launcher","sa_rocketlauncher","Launches homing rockets, woo, also uses rpg ammo.")
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
		material = "models/props_c17/FurnitureMetal001a",
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

local submodel_barrel = {
	{
		model = "models/hunter/tubes/tube1x1x2.mdl",
		material = "models/props_c17/FurnitureMetal001a",
		color = Color(180, 180, 220),
		transform = {Vector(0, 5.8, -9.5), Angle(0,0,0), Vector(0.22,0.22,0.22)},
	},
	{
		model = "models/hunter/misc/shell2x2a.mdl",
		material = "models/props_c17/FurnitureMetal001a",
		color = Color(100, 100, 120),
		transform = {Vector(0, 5.8, -8), Angle(0,0,0), Vector(0.11,0.11,0.1)},
	},
	{
		model = "models/hunter/tubes/tube2x2x025.mdl",
		material = sa_rocket_hazardstripes,
		transform = {Vector(0, 5.8, -4), Angle(0,0,0), Vector(0.112,0.112,0.4)},
	},
	
	{
		model = "models/props_borealis/bluebarrel001.mdl",
		material = "models/props_c17/FurnitureMetal001a",
		color = Color(180, 80, 80),
		transform = {Vector(0, 5.8, -5), Angle(0,0,0), Vector(0.2,0.2,0.2)},
	},
}


local sa_rocket_Think = function(self, time, ent)
	local x = math.cos(self._phase1+time*self._freq1)
	local y = math.sin(self._phase1+time*self._freq1)
	local r = self._amp * math.sin(self._phase2+time*self._freq2)
	
	self.transform[1].y = r*x
	self.transform[1].z = r*y
	self.transform[2].p = math.NormalizeAngle(time*200)
end

local sa_rocket = {
	{
		outputname = "rocket_1",
		transform = {Vector(0,0,0), Angle(0,90,90), Vector(0.2,0.2,0.2)},
		children = submodel_rocket,
		
		_phase1 = 0,
		_freq1 = 3,
		_phase2 = 0,
		_freq2 = 9,
		_amp = 8,
		Think = sa_rocket_Think,
	},
	{
		outputname = "rocket_2",
		transform = {Vector(0,0,0), Angle(0,90,90), Vector(0.2,0.2,0.2)},
		children = submodel_rocket,
		
		_phase1 = math.pi/3,
		_freq1 = 3,
		_phase2 = 2*math.pi/3,
		_freq2 = 9,
		_amp = 9,
		Think = sa_rocket_Think,
	},
	{
		outputname = "rocket_3",
		transform = {Vector(0,0,0), Angle(0,90,90), Vector(0.2,0.2,0.2)},
		children = submodel_rocket,
		
		_phase1 = 2*math.pi/3,
		_freq1 = 3,
		_phase2 = 4*math.pi/3,
		_freq2 = 9,
		_amp = 10,
		Think = sa_rocket_Think,
	},
}
multimodel.Register("sa_rocket", sa_rocket)

local sa_rocketlauncher = {
	{
		transform = {Vector(5.4,-2,-1.2),Angle(70,90,0),Vector(1,1,1)},
		children = {
			{
				-- front plate
				model = "models/props_combine/combine_barricade_med01a.mdl",
				transform = {Vector(0, 0, 0), Angle(0,0,0), Vector(0.07,0.07,0.07)},
			},
			{
				-- back plate
				model = "models/props_combine/combine_emitter01.mdl",
				transform = {Vector(-2, 0, 0), Angle(100,180,0), Vector(0.3,0.2,0.3)},
			},
			{
				-- main axis
				model = "models/props_pipes/valve001.mdl",
				transform = {Vector(-1, 0, 6), Angle(180,0,0), Vector(0.18,0.18,0.18)},
				children = {
					{
						-- right arm
						model = "models/props_wasteland/gear02.mdl",
						transform = {Vector(0, -6, 7), Angle(-arm_angle_1,180,0), Vector(2,2,2)},
						children = {
							{
								model = "models/props_trainstation/pole_448Connection002b.mdl",
								transform = {Vector(0, 2, -10), Angle(0,90,180), Vector(0.06,0.06,0.06)},
								material = "models/props_pipes/GutterMetal01a",
							},
							{
								model = "models/props_wasteland/gear02.mdl",
								transform = {Vector(0, 0, -25), Angle(-arm_angle_2,0,0), Vector(1,1,1)},
								children = {
									{
										model = "models/props_trainstation/pole_448Connection002b.mdl",
										transform = {Vector(0, 2, -10), Angle(0,90,180), Vector(0.06,0.06,0.06)},
										material = "models/props_pipes/GutterMetal01a",
									},
									{
										model = "models/props_wasteland/gear02.mdl",
										transform = {Vector(0, 0, -25), Angle(-arm_angle_3,0,0), Vector(1,1,1)},
									},
									{
										-- rocket launcher
										transform = {Vector(3, -1.9, -25), Angle(0,0,0), Vector(1,1,1)},
										children = {
											-- test
											--[[
											{
												transform = {Vector(11.4, -0.4, -40), Angle(90,0,0), Vector(1, 1, 1)},
												children = sa_rocket
											},
											]]
											
											{
												-- main body
												model = "models/props_wasteland/laundry_washer001a.mdl",
												transform = {Vector(10, 0, 2), Angle(0,80,0), Vector(0.3,0.3,0.3)},
											},
											{
												-- laser pointer
												model = "models/props_c17/canister01a.mdl",
												transform = {Vector(3, -12, 2), Angle(0,110,0), Vector(0.5,0.5,0.3)},
												children = {
													{
														model = "models/hunter/tubes/circle2x2.mdl",
														transform = {Vector(0, 0, -30), Angle(0,0,0), Vector(0.05,0.05,0.3)},
														material = "models/debug/debugwhite",
														color = Color(255, 0, 0, 255),
														selfillum = true,
													},
													{
														outputname="laser_muzzle",
														color = Color(255, 0, 0, 255),
														transform = {Vector(0,0,-32),Angle(0, 0,0),Vector(22,22,22)},
														translucent = true,
													},
												},
											},
											{
												-- barrels
												transform = {Vector(11.4, -0.4, 2), Angle(0,0,0), Vector(1,1,1)},
												children = {
													{
														model = "models/hunter/tubes/circle2x2.mdl",
														material = sa_rocket_hazardstripes,
														transform = {Vector(0, 0, 0), Angle(0,0,0), Vector(0.26,0.26,1.5)},
													},
													{
														model = "models/props_phx/construct/metal_wire_angle360x1.mdl",
														transform = {Vector(0, 0, -20), Angle(0,0,0), Vector(0.25,0.25,0.25)},
													},
													{
														transform = {Vector(0, 0, -12), Angle(0,0,0), Vector(1,1,1)},
														children = submodel_barrel,
													},
													{
														transform = {Vector(0, 0, -12), Angle(0,120,0), Vector(1,1,1)},
														children = submodel_barrel,
													},
													{
														transform = {Vector(0, 0, -12), Angle(0,240,0), Vector(1,1,1)},
														children = submodel_barrel,
													},
												},
											},
										},
									},
								}
							},
						}
					},
					{
						-- left arm
						model = "models/props_wasteland/gear02.mdl",
						transform = {Vector(0, 4, 7), Angle(arm_angle_1,0,0), Vector(2,2,2)},
						children = {
							{
								model = "models/props_trainstation/pole_448Connection002b.mdl",
								transform = {Vector(0, 2, -10), Angle(0,90,180), Vector(0.06,0.06,0.06)},
								material = "models/props_pipes/GutterMetal01a",
							},
							{
								model = "models/props_wasteland/gear02.mdl",
								transform = {Vector(0, 0, -25), Angle(arm_angle_2,0,0), Vector(1,1,1)},
								children = {
									{
										model = "models/props_trainstation/pole_448Connection002b.mdl",
										transform = {Vector(0, 2, -10), Angle(0,90,180), Vector(0.06,0.06,0.06)},
										material = "models/props_pipes/GutterMetal01a",
									},
									{
										model = "models/props_wasteland/gear02.mdl",
										transform = {Vector(0, 0, -25), Angle(arm_angle_3,0,0), Vector(1,1,1)},
									},
								}
							},
						}
					},
				},
			},
		},
	},
}

multimodel.Register("sa_rocketlauncher", sa_rocketlauncher)

end


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
local CollisionBounds = {Vector(-5,-5,5), Vector(5,5,5)}

function ENT2:Initialize()
	self:SetCustomCollisionCheck(true)
	if SERVER then
		if not IsValid(self:GetOwner()) then
			local randomply=table.Random(player.GetAll())
			if IsValid(randomply) then
				self:SetTarget(randomply)
			end
		end
		
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
	end
	
	if CLIENT then
		self.mm = multimodel.CreateInstance("sa_rocket")
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
    --self:DrawModel()
	if not self.Attachments then
		self.Attachments = {}
	end
	
	multimodel.DoFrameAdvance(self.mm, CurTime(), self)
	
	multimodel.SetOutputTarget(self.Attachments)
	multimodel.Draw(self.mm, self)
	multimodel.SetOutputTarget(nil)
	
	--[[
	local atch=self:GetAttachment(1)
	if not atch then return end
	
	self:drawFire(atch.Pos+atch.Ang:Forward()*5,atch.Ang:Forward()*-1,0.2,self:GetPos()+self:GetAngles():Forward()*-15)
	]]
	
	local doParticles = false
	if not self.NextParticle then self.NextParticle=CurTime() end
	if CurTime() > self.NextParticle then
		doParticles = true
		self.NextParticle=CurTime()+0.01
	end
	
	for i=1, 3 do
		local atch = self.Attachments["rocket_"..i]
		if atch then
			self:drawFire(atch.pos, -1 * atch.ang:Up(), 0.2, atch.pos, doParticles)
		end
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
	
	if CLIENT and IsValid(self:GetTarget())then
		if self:GetTarget():IsPlayer() and self:GetTarget()==LocalPlayer() then
			--do a lerp between the distance between us and the target
			--then use that to increase the rate at which the ping plays
			local pingrate=1
			local dist=self:GetPos():Distance(self:GetTarget():GetPos())
			dist=math.Clamp(dist,0,3000)
			pingrate=Lerp(dist/3000,0.1,1)
			if self.NextPing < CurTime() then
				LocalPlayer():EmitSound("NPC_Turret.Ping",200)
				self.NextPing = CurTime() + pingrate
			end
		end
	end
	
	if SERVER and IsValid(self:GetTarget())then
		if self:GetTarget():IsPlayer() and not self:GetTarget():Alive() then 
			--we don't want the rocket to follow the player after death, so disjoint the target
			self:SetTarget(NULL)
			return 
		end
		--get the obb center and target that
		local targetpos=LocalToWorld(self:GetTarget():OBBCenter(),Angle(),self:GetTarget():GetPos(),Angle())
		local direction=(targetpos-self:GetPos()):GetNormal()
		self:SetLocalVelocity(direction * self.SpeedModifier *self.RocketSpeed )
		self:SetAngles(direction:Angle())
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
		util.BlastDamage( self ,self:GetOwner() or self , self:GetPos(),200, 150 )
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
	killicon.AddFont( "sa_rocket", "HL2MPTypeDeath","3", Color( 255, 80, 0, 255 ) )
	
end
scripted_ents.Register(ENT2,"sa_rocket",true)

 


function newsa:Initialize(entity,owner)
	if CLIENT then
		entity.mm=multimodel.CreateInstance("sa_rocketlauncher")
	end
	--entity:GetActionBool1() is the rocketready status
	--entity:GetActionEntity1() is the current target, if there's any
	--entity:GetActionEntity2() is the current rocket, you can't fire if it's still in flight
	
end

function newsa:Attack(entity,owner) 
	if owner:KeyDown(IN_ATTACK2) then
		owner:EmitSound("Buttons.snd19")
		entity:SetNextAction(CurTime()+1)
		entity:SetActionEntity1(NULL)
		entity:SetActionBool2(false)
		return
	end
	if --[[IsValid(entity:GetActionEntity2()) or]] entity:GetActionBool2() then return end
	
	if owner:GetAmmoCount( 8 ) <= 0 then 
		owner:EmitSound("Weapon_SMG1.Empty")
		entity:SetNextAction(CurTime()+1)
		return 
	end
	--we tell the think hook to start tracking or something
	entity:SetActionBool2(true)
	

	entity:SetNextAction(CurTime()+1)
end

function newsa:ShootRocket(entity,owner,target)
    if SERVER then
		
		local rocket=ents.Create("sa_rocket")
		rocket:SetOwner(owner)
		local pos,ang=LocalToWorld(Vector(0,-7,-2),Angle(0,0,0),owner:GetShootPos(),owner:GetAimVector():Angle())--owner:EyeAngles())
		rocket:SetPos(pos)
		rocket:SetAngles(ang)
		if IsValid(target) then
			rocket.SpeedModifier=0.75
		end
		rocket:Spawn()
		rocket:SetTarget(target)

		entity:SetActionEntity2(rocket)
	end
end

if CLIENT then
	newsa.ReticleMat=Material("VGUI/hud/autoaim")--Material("Sprites/reticle.vmt")
	newsa.Red=Color(233,32,32)
	newsa.White=color_white
	newsa.CurCol=color_white
	newsa.ReticleSize=64
end

function newsa:HUDDraw(entity,owner)
	local rotate=false
	
	if entity:GetActionBool2() then
		--draw a white reticle on the center of the screen
		local posx,posy=0,0
		if IsValid(entity:GetActionEntity1()) then
			--local pos=entity:GetActionEntity1():GetPos()
			local pos=LocalToWorld(entity:GetActionEntity1():OBBCenter(),Angle(),entity:GetActionEntity1():GetPos(),Angle())
		
			local toscreenpos=pos:ToScreen()
			if toscreenpos.visible then
				posx=toscreenpos.x
				posy=toscreenpos.y
				
				--self.CurCol=self.Red
			end
			rotate=true
			--draw a red reticle over the target if it's in sight
		else
			posx=ScrW()/2
			posy=ScrH()/2
			--self.CurCol=self.White
		end
		surface.SetMaterial(self.ReticleMat)
		surface.SetDrawColor(self.CurCol.r,self.CurCol.g,self.CurCol.b,self.CurCol.a)
		if rotate then
			surface.DrawTexturedRectRotated(posx,posy,self.ReticleSize,self.ReticleSize,CurTime()*300)
		else
			surface.DrawTexturedRect(posx-(self.ReticleSize/2),posy-(self.ReticleSize/2),self.ReticleSize,self.ReticleSize )
		end
	end

end

function newsa:ResetVars(entity,owner)
	entity:SetNextAction(CurTime()+1)
	entity:SetActionEntity1(NULL)
	entity:SetActionBool2(false)
end


function newsa:Think(entity,owner) 
	
	entity:SetActionBool1(not IsValid(entity:GetActionEntity2()))
	
	if entity:IsKeyDown() and entity:GetActionBool2() then
		--start tracking shit
		if not IsValid(entity:GetActionEntity1()) then 
			local tracedata = {}
			tracedata.start = owner:GetShootPos()
			tracedata.endpos = owner:GetShootPos() + ( owner:GetAimVector() * 8192 )
			tracedata.filter = owner
			tracedata.mins =  Vector( -16, -16, -16 )
			tracedata.maxs =  Vector( 16, 16, 16 )
			if SERVER then
				owner:LagCompensation(true)
			end
			local tr = util.TraceHull( tracedata )
			if SERVER then
				owner:LagCompensation(false)
			end
			if tr.Hit and IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer()) then
				owner:EmitSound("npc/scanner/combat_scan3.wav")
				entity:SetActionEntity1(tr.Entity)
				if CLIENT then
					owner:EmitSound("npc/scanner/combat_scan3.wav")
				end
				
			end
		end
	else
		if entity:GetActionBool2() then
			--fire the rocket, whether our target is valid or not
			if owner:GetAmmoCount( 8 ) >= 1 then
				owner:EmitSound("Weapon_RPG.Single")
				if IsValid(entity:GetActionEntity1()) then
					entity:SetNextAction(CurTime()+2)
				else
					entity:SetNextAction(CurTime()+1)
				end
				self:ShootRocket(entity,owner,entity:GetActionEntity1())
				owner:RemoveAmmo(1,8)
			end
			entity:SetActionEntity1(NULL)
			entity:SetActionBool2(false)
		end
	end
	--we start the tracking only if the player is holding the action button,because we need a reason to start lag compensating
	--do a "big" hulltrace here, check if the player has locked in the reticle on that target for more than two seconds
	--and then set the target to valid
end

function newsa:DrawWorldModel(entity,owner)
	local bone=owner:LookupBone("ValveBiped.Bip01_R_Clavicle")
	if not bone then return end
	local matrix = owner:GetBoneMatrix(bone)
	if not matrix then return end
	local pos = matrix:GetTranslation()
	if not pos then return end
	local ang = matrix:GetAngles()
	if not ang then return end
	if not entity.mm then return end
	multimodel.Draw(entity.mm,owner,{origin=pos,angles=ang})
	
end

newsa.offpos=Vector(12,-12,-6)
newsa.offang=Angle(0,-90,90)

function newsa:PostDrawViewModel(entity,owner,weapon,viewmodel)
	if not entity.mm then return end
	local usevmforposition=false
	--[[
	if not IsValid(viewmodel) then
		usevmforposition=true
	end
	]]
	local pos=usevmforposition and viewmodel:GetPos() or owner:EyePos()
	local ang=usevmforposition and viewmodel:GetAngles() or owner:EyeAngles()
	
	pos,ang=LocalToWorld(self.offpos,self.offang,pos,ang)
	multimodel.Draw(entity.mm,owner,{origin=pos,angles=ang})
end
