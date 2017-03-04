if SERVER then return end
local spawnpos=Vector("0 0 0")--Vector(849.096252,-59.586578,-12250)
local entstoremove={
	
	BREEN,KARTBASE --,GUN,ARMS,WGUN
}

for i,v in pairs(entstoremove) do
	if IsValid(v) then v:Remove() end
end

--models/nova/airboat_seat.mdl

multimodel.Register("GoKart", {
	{
		transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,1)},
		Think=function(self, time, ent)
			--self.transform[2].y = math.sin(CurTime())*90
		end,
		children = {
			{
				model = "models/nova/airboat_seat.mdl",
				transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,1)},
				--color=Color(255,0,255,200),
				children = {
					--
					{
						model = "models/props_borealis/door_wheel001a.mdl",
						transform = {Vector(0,20,22), Angle(-40,-90,0), Vector(0.85,0.90,0.90)},
						color=Color(100,100,100),
						Think=function(self, time, ent)
							self.transform[2].r = math.sin(CurTime()*2) * -10
						end,
						
					},
					{
						outputname = "seatpos",
						transform = {Vector(0,-12,2), Angle(0,90,0), Vector(1,1,1)},
					}
				}
			},
			--kart body
			{
				transform = {Vector(0,15,-8), Angle(0,0,0), Vector(1,1,1)},
				children = {
					{
						model = "models/mechanics/solid_steel/type_a_2_4.mdl",
						transform = {Vector(0,0,0), Angle(0,90,0), Vector(1,1,1)},
					},
					{
						model = "models/props_phx/construct/plastic/plastic_panel1x1.mdl",
						transform = {Vector(0,20,17), Angle(0,0,-45), Vector(0.8,0.3,0.3)},

					},
					--
					{
						model = "models/props_phx/construct/plastic/plastic_angle_90.mdl",
						transform = {Vector(0,13,2), Angle(0,180+45,0), Vector(0.47,0.65,0.47)},

					},
					{
						model = "models/props_phx/construct/plastic/plastic_panel1x2.mdl",
						transform = {Vector(0,-2,2), Angle(0,0,0), Vector(0.65,0.75,0.65)},

					},
					{
						model = "models/props_c17/trappropeller_engine.mdl",
						transform = {Vector(-2,-33,11.5), Angle(-90,0,90), Vector(0.6,0.7,0.4)},

					},
					
					
					{--this one never moves
						model = "models/mechanics/solid_steel/type_b_2_4.mdl",
						transform = {Vector(0,-24,0), Angle(0,0,0), Vector(1,1,1)},
						children={
							{
								model = "models/xeon133/racewheel/race-wheel-30.mdl",
								transform = {Vector(-25,0,0), Angle(0,90,0), Vector(0.7,0.7,0.7)},
							},
							{
								model = "models/xeon133/racewheel/race-wheel-30.mdl",
								transform = {Vector(25,0,0), Angle(0,-90,0), Vector(0.7,0.7,0.7)},
							}
						}
					},
					{--this one does tho
						model = "models/mechanics/solid_steel/type_b_2_4.mdl",
						transform = {Vector(0,24,0), Angle(0,0,0), Vector(1,1,1)},
						Think=function(self, time, ent)
							self.transform[2].y = math.sin(CurTime()*2)*-20
						end,
						
						children={
							{
								model = "models/xeon133/racewheel/race-wheel-30.mdl",
								transform = {Vector(-25,0,0), Angle(0,90,0), Vector(0.7,0.7,0.7)},
								Think=function(self, time, ent)
									--self.transform[2].y = 90 + math.sin(CurTime()*2)*-20
								end,
						
							},
							{
								model = "models/xeon133/racewheel/race-wheel-30.mdl",
								transform = {Vector(25,0,0), Angle(0,-90,0), Vector(0.7,0.7,0.7)},
								Think=function(self, time, ent)
									--self.transform[2].y = -90 + math.sin(CurTime()*2)*-20
								end,
							}
						}
					},
					--
				
				}
			},
		}
	}
})	




mm=multimodel.CreateInstance("GoKart")

KARTBASE=ClientsideModel("models/props_junk/watermelon01.mdl")
KARTBASE:SetPos(spawnpos)
KARTBASE:Spawn()
KARTBASE.Atch={}
KARTBASE.RenderOverride=function(self)
	if not mm then return end
	--self:DrawModel()
	multimodel.DoFrameAdvance(mm, CurTime(), self)
	multimodel.SetOutputTarget(self.Atch)
	multimodel.Draw(mm,self,{origin=self:GetRenderOrigin(),angles=self:GetRenderAngles()})
	multimodel.SetOutputTarget(nil)
	if IsValid(BREEN) and self.Atch.seatpos then
		BREEN:SetRenderOrigin(self.Atch.seatpos.pos)
		BREEN:SetRenderAngles(self.Atch.seatpos.ang)
		BREEN:DrawModel()
	end
	
	if IsValid(BREEN) then
		BREEN:SetPoseParameter( "vehicle_steer", math.sin(CurTime()*2) * 0.2  ) 
	end
end

local model,shit=table.Random(player_manager.AllValidModels())

BREEN=ClientsideModel(model or "models/player/breen.mdl")
--BREEN:SetPos(spawnpos)
BREEN.GetPlayerColor=function() return Vector(0.5,0,0) end
BREEN:SetNoDraw(true)
BREEN:Spawn()
BREEN:ResetSequence( BREEN:LookupSequence( "drive_jeep" ) )
BREEN:SetPoseParameter( "vehicle_steer", 0  ) 
--sit_rollercoaster
--drive_jeep

