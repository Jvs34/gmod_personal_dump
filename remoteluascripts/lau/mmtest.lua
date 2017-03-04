if IsValid(MMTESTFAG) then
	MMTESTFAG:Remove()
end
--[[
multimodel.Register("worms_grenade", {
	{
		model = "models/maxofs2d/hover_classic.mdl",
		material = "models/props_c17/FurnitureMetal001a",
		color=Color(29,127,0),
		transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,1)/3},
	},
	{
		model = "models/props_pipes/concrete_pipe001a.mdl",
		material = "models/props_c17/FurnitureMetal001a",
		color=Color(255,255,255),
		transform = {Vector(0,0,2.2), Angle(90,0,0), Vector(0.5,1,1)/35},
	},
	{
		model = "models/props_c17/clock01.mdl",
		material = "models/props_c17/FurnitureMetal001a",
		color=Color(255,0,0),
		transform = {Vector(0,0,2.8), Angle(0,0,0), Vector(1,1,1)/8},
	},
	{
		model = "models/props_phx/wheels/magnetic_small.mdl",
		material = "models/props_c17/FurnitureMetal001a",
		transform = {Vector(1.6,1.6,1.8), Angle(45,45,0), Vector(1,0.3,1)/7},
	},
	--
	{
		model = "models/gibs/metal_gib1.mdl",
		material = "models/props_c17/FurnitureMetal001a",
		transform = {Vector(-2.6,0,0.7), Angle(0,90,0), Vector(1,0.4,1)},
	},
	{
		model = "models/hunter/misc/sphere025x025.mdl",
		material = "models/props_c17/FurnitureMetal001a",
		transform = {Vector(1,1,2.6), Angle(45,45,0), Vector(1,1,1)/15},
	},
	
	
})


multimodel.Register("worms_bazooka", {
	{
		model = "models/hunter/tubes/tube1x1x1.mdl",
		material = "models/props_c17/paper01",
		transform = {Vector(0,-0.5,5), Angle(90,0,0), Vector(1,1,5)/10},
	},
}
)

multimodel.Register("joystick", {
	{
				model = "models/weapons/w_slam.mdl",
				transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,1)},
				color=Color(255,255,255,255),
	},
	{
	transform = {Vector(0,0,-1), Angle(0,0,0), Vector(1,1,1)*0.9},
	children={
			
			{
				model = "models/hunter/misc/roundthing1.mdl",
				transform = {Vector(0,0,0), Angle(0,0,0), Vector(0.6,0.5,0.3)/15},
				material=Material("phoenix_storms/gear"),
			},
			{
				model = "models/hunter/tubes/circle2x2.mdl",
				transform = {Vector(0.45,-3,0.47), Angle(0,0,0), Vector(1,1,6.45)/20},
				material=Material("phoenix_storms/gear"),
			},
			{
				model = "models/hunter/tubes/circle2x2.mdl",
				transform = {Vector(0.45,3,0.47), Angle(0,0,0), Vector(1,1,6.45)/20},
				material=Material("phoenix_storms/gear"),
			},
			
			{
				model = "models/hunter/blocks/cube025x075x025.mdl",
				transform = {Vector(0.85,-1.85,0.3), Angle(0,0,0), Vector(1,1,1)/15},
				color=Color(50,50,50,255)
			},
			{
				model = "models/hunter/blocks/cube025x075x025.mdl",
				transform = {Vector(1.65,-3.45,0.3), Angle(0,-90,0), Vector(1,1,1)/15},
				color=Color(50,50,50,255)
			},
			
			{
				model = "models/props_c17/clock01.mdl",
				transform = {Vector(-0.3,3,1), Angle(0,0,0), Vector(1,1,1)/20},
				material=Material("phoenix_storms/gear"),
				color=Color(0,0,255,255)
			},
			
			{
				model = "models/props_c17/clock01.mdl",
				transform = {Vector(1.3,3,1), Angle(0,0,0), Vector(1,1,1)/20},
				material=Material("phoenix_storms/gear"),
				color=Color(255,255,0,255)
			},
			
			{
				model = "models/props_c17/clock01.mdl",
				transform = {Vector(0.5,4,1), Angle(0,0,0), Vector(1,1,1)/20},
				material=Material("phoenix_storms/gear"),
				color=Color(255,0,0,255)
			},
			
			{
				model = "models/props_c17/clock01.mdl",
				transform = {Vector(0.5,2,1), Angle(0,0,0), Vector(1,1,1)/20},
				material=Material("phoenix_storms/gear"),
				color=Color(0,255,0,255)
			},
			
			
			
			{
				model = "models/hunter/misc/shell2x2e.mdl",
				transform = {Vector(-1.1,-2.45,0.5), Angle(67.5,0,90), Vector(0.6,0.6,1.5)/30},
				material=Material("phoenix_storms/gear"),
				color=Color(80,80,80,255)
			},
			
			{
				model = "models/hunter/misc/shell2x2e.mdl",
				transform = {Vector(-1.1,2.45,0.5), Angle(-67.5,0,-90), Vector(0.6,0.6,1.5)/30},
				material=Material("phoenix_storms/gear"),
				color=Color(80,80,80,255)
			},
			
			{
				model = "models/props_junk/PopCan01a.mdl",
				transform = {Vector(0.6,-0.7,0.9), Angle(0,45,90), Vector(1,1,1.5)/12},
				material=Material("phoenix_storms/gear"),
				color=Color(80,80,80,255)
			},
			{
				model = "models/props_junk/PopCan01a.mdl",
				transform = {Vector(0.6,0.7,0.9), Angle(0,45,90), Vector(1,1,1.5)/12},
				material=Material("phoenix_storms/gear"),
				color=Color(80,80,80,255)
			},
			
			{
			transform = {Vector(4.05,0,-0.2), Angle(0,0,0), Vector(1,1,1)/3},
			children={
					{
						model = "models/props_phx/construct/metal_angle360.mdl",
						transform = {Vector(-17.8,0,2), Angle(-90,0,0), Vector(1,1,1)/30},
					},
					{
						model = "models/props_c17/signpole001.mdl",
						transform = {Vector(-17.8,0,2), Angle(-90,0,0), Vector(1.5,1.5,1)/10},
						material="models/shiny",
						color=Color(259,259,259)
					},
					{
						model = "models/props_c17/signpole001.mdl",
						transform = {Vector(-17.8,0,2), Angle(-90,0,0), Vector(3,3,0.4)/10},
						material="models/shiny",
						color=Color(239,239,239)
					},
					{
						model = "models/props_c17/signpole001.mdl",
						transform = {Vector(-17.8,0,2), Angle(-90,0,0), Vector(4,4,0.2)/10},
						material="models/shiny",
						color=Color(239,239,239)
					},
					{
						model = "models/props_c17/signpole001.mdl",
						transform = {Vector(-28,0,2), Angle(-90,0,0), Vector(4,4,0.1)/10},
						material="models/shiny",
						color=Color(239,239,239)
					},	
				}
			}
	}
	}
})
]]
--[[


	{
		model = "models/hunter/misc/roundthing1.mdl",
		transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,1)},
	},


	
]]

multimodel.Register("dick_copter", {

	{
		transform = {Vector(0,0,1), Angle(0,0,0), Vector(1,1,1)},
		children={
			{
					model = "models/weapons/w_slam.mdl",
					transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,1)},
					color=Color(255,255,255,255),
			},
		}
	}
})

multimodel.Register("wormssss_shotgun", {

	{
		transform = {Vector(0,0,1), Angle(0,0,0), Vector(1,1,1)},
		children={
			{
					model = "models/weapons/w_shotgun.mdl",
					transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,1)},
					color=Color(255,255,255,255),
			},
		}
	}
})

multimodel.Register("mm_test", {

	{
		transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,1)},
		children =	{
					
				{
					model = "models/gibs/glass_shard04.mdl",
					material = "models/props_combine/portalball001_sheet",
					transform = {Vector(-10.256665,-0.425160,-0.648039), Angle(80.937866,-179.999939,90.000031), Vector(0.402607,0.594940,1.000000)},
					color = Color(127,234,255),
				},				
				{
					model = "models/props_combine/headcrabcannister01a.mdl",
					material = "",
					transform = {Vector(-1.511000,-0.191000,-1.144446), Angle(0.000000,0.000000,0.000000), Vector(0.086214,0.034228,0.055763)},
					color = Color(255,255,255),
				},				
				{
					model = "models/props_c17/utilityconnecter006.mdl",
					material = "",
					transform = {Vector(4.035201,-0.178589,-1.282349), Angle(0.000000,90.000000,0.000000), Vector(0.100000,0.100000,0.100000)},
					color = Color(255,255,255),
				},		
		
		}
	},
})


local mm=multimodel.CreateInstance("mm_test")



MMTESTFAG=ClientsideModel("models/props_junk/watermelon01.mdl")
MMTESTFAG:SetPos(Vector(0,100,0))
MMTESTFAG:Spawn()
MMTESTFAG.RenderOverride=function(self)
	multimodel.Draw(mm,self,{origin=Vector(0,100,0),angles=angle_zero})
	render.SetBlend(0)
	self:DrawModel()
	render.SetBlend(1)
end