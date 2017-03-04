AddCSLuaFile()

DEFINE_BASECLASS( "base_predictedent" )

ENT.Spawnable = true
ENT.PrintName = "Shoulder mounted RPG"
ENT.AttachesToPlayer = true

ENT.AttachmentInfo = {
	BoneName = "ValveBiped.Bip01_R_Clavicle",
	OffsetVec = Vector( 0 , 0 , 0 ),
	OffsetAng = Angle( 0 , 0 , 0 ),
}

if CLIENT then
	ENT.FirstPersonAttachmentInfo = {
		OffsetVec = Vector( 10 , -12 , -6 ),
		OffsetAng = Angle( 0 , -90 , 90 ),
	}
end



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
		--show a rocket here instead
		{
			transform = {Vector(0, 5.8, 3 ), Angle(180,0,0), Vector(0.2,0.2,0.2)},
			children = submodel_rocket
		},
		
		
		-- {
			-- model = "models/props_borealis/bluebarrel001.mdl",
			-- material = "models/props_c17/FurnitureMetal001a",
			-- color = Color(180, 80, 80),
			-- transform = {Vector(0, 5.8, -5), Angle(0,0,0), Vector(0.2,0.2,0.2)},
		-- },
	}


	local sa_rocket_Think = function( self , time , ent )
		
		if not IsValid( ent ) then
			return
		end
		
		local x = math.cos( self._phase1 + time * self._freq1 )
		local y = math.sin( self._phase1 + time * self._freq1 )
		local r = self._amp * math.sin(self._phase2+time*self._freq2)
		
		self.transform[1].y = r * x
		self.transform[1].z = r * y
		self.transform[2].p = math.NormalizeAngle( time * 200 )
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

if SERVER then

	function ENT:SpawnFunction( ply, tr, ClassName )

		if not tr.Hit then 
			return 
		end

		local SpawnPos = tr.HitPos + tr.HitNormal * 36

		local ent = ents.Create( ClassName )
		ent:SetSlotName( ClassName )
		ent:SetPos( SpawnPos )
		ent:SetAngles( angle_zero )
		ent:Spawn()
		return ent

	end

end

function ENT:Initialize()
	BaseClass.Initialize( self )
	if SERVER then
		self:SetModel( "models/props_lab/partsbin01.mdl" )
		self:InitPhysics()
	else
		self.MultiModels = {}
	end
	
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables( self )
	
end

function ENT:Think()
	if CLIENT then
		self:HandleMultiModel()
	end
	
	return BaseClass.Think( self )
end

function ENT:GetCustomParentOrigin()
	local defretpos , defretang = BaseClass.GetCustomParentOrigin( self )
	
	local ply = self:GetControllingPlayer()
	
	if not self:IsCarriedBy( ply ) then
		return
	end
	
	if CLIENT and self:IsCarriedByLocalPlayer( true ) and not self:ShouldDrawLocalPlayer( true ) then
		return
	end
	
	
	return defretpos , defretang
end

if SERVER then
	
	function ENT:OnAttach( ply )
	
	end
	
	function ENT:OnDrop( ply )

	end
	
else

	
	function ENT:HandleMultiModel()
		if not self.MultiModels then
			self.MultiModels = {}
		end
		
		if not self.MultiModels.RPG then
			self.MultiModels.RPG = multimodel.CreateInstance( "sa_rocketlauncher" )
		end
		
		if not self.MultiModels.Rockets then
			
		end
	end
	
	function ENT:DrawFirstPerson( ply )
		local eyepos = ply:EyePos()
		local eyeang = ply:EyeAngles()
		
		local pos , ang = LocalToWorld( self.FirstPersonAttachmentInfo.OffsetVec , self.FirstPersonAttachmentInfo.OffsetAng , eyepos , eyeang )
		
		self:SetPos( pos )
		self:SetAngles( ang )
		self:SetupBones()
		self:DrawModel()
	end
	
	function ENT:Draw( flags )
		local pos , ang = self:GetCustomParentOrigin()
		
		--even though the calcabsoluteposition hook should already prevent this, it doesn't on other players
		--might as well not give it the benefit of the doubt in the first place
		if pos and ang then
			self:SetPos( pos )
			self:SetAngles( ang )
			self:SetupBones()	--seems to be needed since we're never technically drawing the model
		end
		
		pos = self:GetPos()
		ang = self:GetAngles()
		
		if self.MultiModels then
			if self.MultiModels.RPG then
				multimodel.Draw( self.MultiModels.RPG , self ,
				{
					origin = pos,
					angles = ang
				})
			end
		end
	end
end