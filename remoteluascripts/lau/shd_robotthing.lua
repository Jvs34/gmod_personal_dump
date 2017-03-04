--if not fuckoff then return end

local META = FindMetaTable("Vector")

-- self = self + vec * m
local tmpvec = Vector()
function META:MulAdd(vec, m)
	tmpvec:Set(vec)
	tmpvec:Mul(m)
	self:Add(tmpvec)
end


META=nil



local ClassName="sent_robotthing"
local ENT={}

ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.RenderGroup     = RENDERGROUP_OPAQUE
ENT.PrintName        = "Robotthingidk"
ENT.Author="Jvs"
ENT.Spawnable = true  
ENT.AdminOnly = false  
ENT.AutomaticFrameAdvance=false






--[[
ValveBiped.Bip01_Pelvis
ValveBiped.Bip01_Spine
ValveBiped.Bip01_Spine1
ValveBiped.Bip01_Spine2
ValveBiped.Bip01_Spine4
ValveBiped.Bip01_Neck1
ValveBiped.Bip01_Head1
ValveBiped.Bip01_R_Clavicle
ValveBiped.Bip01_R_UpperArm
ValveBiped.Bip01_R_Forearm
ValveBiped.Bip01_R_Hand
ValveBiped.Bip01_L_Clavicle
ValveBiped.Bip01_L_UpperArm
ValveBiped.Bip01_L_Forearm
ValveBiped.Bip01_L_Hand
ValveBiped.Bip01_R_Thigh
ValveBiped.Bip01_R_Calf
ValveBiped.Bip01_R_Foot
ValveBiped.Bip01_R_Toe0
ValveBiped.Bip01_L_Thigh
ValveBiped.Bip01_L_Calf
ValveBiped.Bip01_L_Foot
ValveBiped.Bip01_L_Toe0
ValveBiped.Bip01_L_Finger2
ValveBiped.Bip01_L_Finger21
ValveBiped.Bip01_L_Finger1
ValveBiped.Bip01_L_Finger11
ValveBiped.Bip01_L_Finger0
ValveBiped.Bip01_L_Finger01
ValveBiped.Bip01_R_Finger2
ValveBiped.Bip01_R_Finger21
ValveBiped.Bip01_R_Finger1
ValveBiped.Bip01_R_Finger11
ValveBiped.Bip01_R_Finger0
ValveBiped.Bip01_R_Finger01

]]

function ENT:SpawnFunction( ply, tr )
    if ( not tr.Hit ) then return end
    
    local SpawnPos = tr.HitPos + tr.HitNormal * 1
    
    local ent = ents.Create(ClassName)
    ent:SetPos( SpawnPos )
	ent:Spawn()
    ent:Activate()
    return ent
end

function ENT:Alive()
	return true
end

function ENT:Initialize()

    if SERVER then
        
		if SA then
			local en=SA:CreateController(self)
			if IsValid(en) then
				self:SetSAC(en)
			end
		end
		
		self:SetModel( "models/props_phx/construct/metal_plate1.mdl" )
		
		self:SetBloodColor(BLOOD_COLOR_MECH)
		
		
		self:SetOwnerModel("models/player/breen.mdl")
		
		
		self:SetDTVelocity(vector_origin)
		self:SetDTEyeAngles(angle_zero)
		self:SetDTGroundEntity(NULL)

		
		
	else
			
		self.Skeleton=ClientsideModel("models/player/skeleton.mdl")
		self.Skeleton:SetOwner(self)
		self.Skeleton:SetNoDraw(true)
		self.Skeleton:SetModelScale(3,0)
		self.Skeleton:Spawn()

		
		if IsValid(self.PlaceHolder) then self.PlaceHolder:Remove() end
		
		self.PlaceHolder=ClientsideModel("models/player/magnusson.mdl")
		self.PlaceHolder.GetPlayerColor=function(self)
			if IsValid(self:GetOwner()) and IsValid(self:GetOwner():GetOwner()) then
				return self:GetOwner():GetOwner():GetPlayerColor()
			else
				return Vector(0.5,0,0) 
			end
		end
		self.PlaceHolder:SetOwner(self)
		self.PlaceHolder:SetNoDraw(true)
		self.PlaceHolder:Spawn()
		self.LastFoot=true
		self.StepSoundTime=CurTime()
	
	end
	
	if IsValid(self:GetSAC()) then
		print(self:GetSAC())
		
		if SERVER then
			self:GetSAC().DefaultKeys={IN_ATTACK,IN_ATTACK2,IN_JUMP,IN_GRENADE}
			local left=self:GetSAC():CreateSpecialaction("sa_rbt_laser",0)
			if IsValid(left) then
				left:SetReservedString("leftarm")
			end
			
			local right=self:GetSAC():CreateSpecialaction("sa_rbt_laser",1)
			
			if IsValid(right) then
				right:SetReservedString("rightarm")
			end
		end
		
	end
	
	
	
end





function ENT:SetupDataTables()
	
	self:NetworkVar("String",0,"OwnerModel")
	self:NetworkVar("Vector",0,"DTVelocity")
	self:NetworkVar("Entity",0,"DTGroundEntity")
	self:NetworkVar("Angle",0,"DTEyeAngles")
	
	
	self:NetworkVar("Entity",1,"SAC")
end

function ENT:FakeOBBMins()
	return Vector(-60,-60,0)
end

function ENT:FakeOBBMaxs()
	return Vector(60,60,190)
end
 
multimodel.Register("mechhull", {
	{
		transform = {Vector(-15,0,0),Angle(0,0,0),Vector(1,1,1)},
		children={

			{
				model='models/mechanics/solid_steel/sheetmetal_h90_4.mdl',
				transform = {Vector('	17.539063 7.510864 -27.468842	'),	Angle('	-0.000 139.950 -134.984	'),Vector(1,1,1)}
			},
			{
				model='models/props_phx/construct/windows/window_curve90x1.mdl',
				transform = {Vector('	47.625977 25.201172 -24.531403	'),	Angle('	-0.011 -175.056 0.033	'),Vector(1,1,1)}
			},
			{
				model='models/mechanics/wheels/wheel_rounded_36s.mdl',
				transform = {Vector('	30.528320 -23.704712 -0.031525	'),	Angle('	-0.000 -175.045 -89.671	'),Vector(1,1,1)/1.3}
			},
			{
				model='models/mechanics/wheels/wheel_smooth_18r.mdl',
				transform = {Vector('	51.422852 -41.532349 -25.906677	'),	Angle('	-0.011 -175.056 -0.011	'),Vector(1,1,1)}
			},
			{
				model='models/mechanics/wheels/wheel_smooth_18r.mdl',
				transform = {Vector('	50.612305 -40.128662 26.187073	'),	Angle('	0.011 -175.056 179.791	'),Vector(1,1,1)}
			},
			{
				model='models/mechanics/solid_steel/sheetmetal_h90_4.mdl',
				transform = {Vector('	-0.591797 18.394775 0.031250	'),	Angle('	89.989 94.955 0.000	'),Vector(1,1,1)}
			},
			{
				model='models/mechanics/solid_steel/sheetmetal_h90_4.mdl',
				transform = {Vector('	19.518555 8.560181 26.249878	'),	Angle('	-0.031 139.950 44.963	'),Vector(1,1,1)}
			},
			{
				model='models/mechanics/solid_steel/type_d_3_4.mdl',
				transform = {Vector('	30.674805 -1.107788 -29.343933	'),	Angle('	-0.000 49.939 -0.011	'),Vector(1,1,1)}
			},
			{
				model='models/mechanics/solid_steel/type_d_3_4.mdl',
				transform = {Vector('	29.897461 0.989014 28.124817	'),	Angle('	-0.011 4.944 -179.989	'),Vector(1,1,1)}
			},
			{
				model='models/mechanics/robotics/h2.mdl',
				transform = {Vector('	10.563477 -10.846069 -23.187653	'),	Angle('	-0.450 -40.048 -90.451	'),Vector(1,1,1)}
			},
			{
				model='models/mechanics/robotics/h2.mdl',
				transform = {Vector('	10.008789 -8.416382 23.874878	'),	Angle('	-0.000 139.950 -90.022	'),Vector(1,1,1)}
			},
			{
				model='models/mechanics/robotics/h2.mdl',
				transform = {Vector('	33.440430 19.864502 22.562408	'),	Angle('	-0.000 139.950 -90.022	'),Vector(1,1,1)}
			},
			{
				model='models/mechanics/robotics/h2.mdl',
				transform = {Vector('	33.203125 18.244751 -23.468842	'),	Angle('	-0.094 139.950 89.907	'),Vector(1,1,1)}
			},
			{
				model='models/mechanics/solid_steel/sheetmetal_u_4.mdl',
				transform = {Vector('	2.038086 20.629761 -0.218750	'),	Angle('	0.217 49.939 89.783	'),Vector(1,1,1)}
			},
			{
				model='models/mechanics/solid_steel/sheetmetal_h90_4.mdl',
				transform = {Vector('	5.700195 18.907715 0.343750	'),	Angle('	89.989 94.955 0.000	'),Vector(1,1,1)}
			},
		}
	}
})


multimodel.Register("mecharms", {
	{
		transform = {Vector(36,-41.5,-30),Angle(-40,-30,0),Vector(1,1,1)},
		children={
			{
				transform = {Vector(0,0,0),Angle(0,0,0),Vector(1,1,1)},
				children={
					{
						model = "models/hunter/misc/sphere025x025.mdl",
						transform = {Vector(0,0,0),Angle(0,0,0),Vector(1,1,1)*1.5},
					},
					{
						model = "models/Mechanics/roboticslarge/a1.mdl",
						transform = {Vector(-20,0,0),Angle(0,0,0),Vector(2,1,1)/2},
					},
					{
						model = "models/hunter/misc/sphere025x025.mdl",
						transform = {Vector(-40,0,0),Angle(0,0,0),Vector(1,1,1)*1.5},
					},
					{
						model = "models/Mechanics/roboticslarge/a1.mdl",
						transform = {Vector(-44,10,4),Angle(20,-70,0),Vector(1,1,1)/2},
						children={
							{
								transform = {Vector(-24,0,0),Angle(180,90,90),Vector(1,1,1)},
								outputname = "rightarm",
							}
						}
					},
				}
			},
		}
	},
	{
		transform = {Vector(36,-40,30),Angle(40,-30,-43),Vector(1,1,1)},
		children={
			{
				transform = {Vector(0,0,0),Angle(0,0,0),Vector(1,1,1)},
				children={
					{
						model = "models/hunter/misc/sphere025x025.mdl",
						transform = {Vector(0,0,0),Angle(0,0,0),Vector(1,1,1)*1.5},
					},
					{
						model = "models/Mechanics/roboticslarge/a1.mdl",
						transform = {Vector(-20,0,0),Angle(0,0,0),Vector(2,1,1)/2},
					},
					{
						model = "models/hunter/misc/sphere025x025.mdl",
						transform = {Vector(-40,0,0),Angle(0,0,0),Vector(1,1,1)*1.5},
					},
					{
						model = "models/Mechanics/roboticslarge/a1.mdl",
						transform = {Vector(-44,10,4),Angle(20,-70,0),Vector(1,1,1)/2},
						children={
							{
								transform = {Vector(-24,0,0),Angle(90,0,0),Vector(1,1,1)},
								outputname = "leftarm",
							}
						}
					},
				}
			},
		}
	}
})
	


multimodel.Register("robotthingy", {


	--spine
	{
		bone = "ValveBiped.Bip01_Spine1",
		transform = {Vector(-5,3,0),Angle(0,95,90),Vector(1,1,1)/2},
		model = "models/Mechanics/roboticslarge/k1.mdl",
		children={
			{
				transform = {Vector(-5,0,35),Angle(0,0,0),Vector(1,1,1)*1.5},
				outputname = "eyepos",
			},

			{
				model = "models/Mechanics/roboticslarge/k1.mdl",
				transform = {Vector(0,0,0),Angle(0,0,0),Vector(1,1,1)},
			},
			{
				model = "models/Mechanics/robotics/g1.mdl",
				transform = {Vector(8.7,0,-3.5),Angle(0,90,135),Vector(0.6,1,1)*2},
			},
			{
				model = "models/Mechanics/robotics/g1.mdl",
				transform = {Vector(-8.7,0,-3.5),Angle(0,90,45),Vector(0.6,1,1)*2},
			},
			{
				model = "models/nova/airboat_seat.mdl",
				transform = {Vector(-5,0,13), Angle(0,-90,0), Vector(1,1,1)*2},
				children ={
					{
						outputname = "seatpos",
						transform = {Vector(0,-1,2), Angle(0,90,0), Vector(1,1,1)},
					}
				}
			},
			{
				model = "models/Mechanics/robotics/j1.mdl",
				transform = {Vector(-17.5,0,18),Angle(90,180,0),Vector(1,1,1)*2},
			},
		}
	},
	
	--tighs
	{
		bone = "ValveBiped.Bip01_R_Thigh",
		transform = {Vector(16,0,0),Angle(0,0,-85),Vector(0.8,1,1)/2},
		children={
			{
				transform = {Vector(0,0,0),Angle(0,0,0),Vector(1,1,1)},
				model = "models/Mechanics/roboticslarge/b1.mdl",
			},

			{
				transform = {Vector(-17,0,0),Angle(0,0,0),Vector(1,1,1)},
				model = "models/Mechanics/roboticslarge/a1.mdl",
			},
			{
				transform = {Vector(-30,0,0),Angle(0,180,0),Vector(1,1,1)},
				model = "models/Mechanics/roboticslarge/b1.mdl",
			},
			{
				transform = {Vector(-35,-2,0),Angle(0,0,0),Vector(1.2,1,1)*2},
				model = "models/hunter/misc/sphere025x025.mdl",
			},
			--
		}
	},
	{
		bone = "ValveBiped.Bip01_L_Thigh",
		transform = {Vector(16,0,0),Angle(0,0,-95),Vector(0.8,1,1)/2},
		children={
			{
				transform = {Vector(0,0,0),Angle(0,0,180),Vector(1,1,1)},
				model = "models/Mechanics/roboticslarge/b1.mdl",
			},

			{
				transform = {Vector(-17,0,0),Angle(0,0,0),Vector(1,1,1)},
				model = "models/Mechanics/roboticslarge/a1.mdl",
			},
			{
				transform = {Vector(-30,0,0),Angle(0,180,180),Vector(1,1,1)},
				model = "models/Mechanics/roboticslarge/b1.mdl",
			},
			{
				transform = {Vector(-35,2,0),Angle(0,0,0),Vector(1.2,1,1)*2},
				model = "models/hunter/misc/sphere025x025.mdl",
			},
		}
	},
	
	--calfs
	{
		bone = "ValveBiped.Bip01_R_Calf",
		transform = {Vector(14,-0.5,0),Angle(0,0,-85),Vector(0.8,1,1)/2},
		children={
			{
				transform = {Vector(0,0,0),Angle(0,0,0),Vector(1,1,1)},
				model = "models/Mechanics/roboticslarge/b1.mdl",
			},
			{
				transform = {Vector(0,0,0),Angle(0,0,180),Vector(1,1,1)},
				model = "models/Mechanics/roboticslarge/b1.mdl",
			},

			{
				transform = {Vector(-17,0,0),Angle(0,0,0),Vector(1,1,1)},
				model = "models/Mechanics/roboticslarge/a1.mdl",
			},
			{
				transform = {Vector(-30,0,0),Angle(0,180,0),Vector(1,1,1)},
				model = "models/Mechanics/roboticslarge/b1.mdl",
			},
		}
	},
	{
		bone = "ValveBiped.Bip01_L_Calf",
		transform = {Vector(14,-0.5,0),Angle(0,0,-95),Vector(0.8,1,1)/2},
		children={
			{
				transform = {Vector(0,0,0),Angle(0,0,0),Vector(1,1,1)},
				model = "models/Mechanics/roboticslarge/b1.mdl",
			},
			{
				transform = {Vector(0,0,0),Angle(0,0,180),Vector(1,1,1)},
				model = "models/Mechanics/roboticslarge/b1.mdl",
			},

			{
				transform = {Vector(-17,0,0),Angle(0,0,0),Vector(1,1,1)},
				model = "models/Mechanics/roboticslarge/a1.mdl",
			},
			{
				transform = {Vector(-30,0,0),Angle(0,180,180),Vector(1,1,1)},
				model = "models/Mechanics/roboticslarge/b1.mdl",
			},
		}
	},
	
	--feet
	{
		transform = {Vector(3,-1,0),Angle(0,-32,90),Vector(1,1,1)/2},
		model = "models/Mechanics/robotics/foot.mdl",
		bone = "ValveBiped.Bip01_R_Foot",
	},
	{
		transform = {Vector(3,-1,0),Angle(-5,-32,90),Vector(1,1,1)/2},
		model = "models/Mechanics/robotics/foot.mdl",
		bone = "ValveBiped.Bip01_L_Foot",
	},
})
if CLIENT then

end

hook.Add("PlayerDriveAnimate","robotting",function( ply ) 
	local driving = ply:GetDrivingEntity()
	
	if ( not IsValid( driving ) ) then return end
	if driving:GetClass()=="sent_robotthing" then  
		--[[
		ply:SetPlaybackRate( 1 )
		ply:ResetSequence( ply:SelectWeightedSequence( ACT_GMOD_SIT_ROLLERCOASTER ) )


		ply:SetPoseParameter( "aim_yaw",		0 )
		ply:SetPoseParameter( "aim_pitch",		0 )
		ply:SetPoseParameter( "move_x",			0 )
		ply:SetPoseParameter( "move_y",			0 )
		ply:SetPoseParameter( "move_yaw",		0 )
		ply:SetPoseParameter( "move_scale",		0 )
		ply:SetPoseParameter( "vertical_velocity", -0.3 ) 
			
		if driving.Atch and driving.Atch.seatpos then
			ply:SetRenderOrigin(driving.Atch.seatpos.pos)
			ply:SetPos(driving.Atch.seatpos.pos)
			ply:SetNetworkOrigin(driving.Atch.seatpos.pos)
			ply:SetRenderAngles(driving.Atch.seatpos.ang)

			ply:DrawModel()
		end
		]]
		return true
	end
	
end)

--print("Warning for that Jvs faggot: remember to uncomment the multimodel creation when you work on it")
hook.Add("PreDrawTranslucentRenderables","firstpersonmech",function( bDrawingDepth,bDrawingSkybox )
	if LocalPlayer():IsDrivingEntity() and LocalPlayer():GetDrivingEntity():GetClass()=="sent_robotthing" and LocalPlayer():GetObserverMode()==OBS_MODE_IN_EYE then
		LocalPlayer():GetDrivingEntity():Draw(0)
	end
end)

hook.Add("PostPlayerDraw","firstpersonmech",function( ply )

end)


function ENT:DrawTranslucent()
	self:Draw(1)
end

function ENT:Draw(flags)
	self:SetRenderBounds(self:FakeOBBMins(),self:FakeOBBMaxs())
	--we usually draw it
	local drawlp=true
	if flags==0 then drawlp=false end
	if not self.mm or not self.hull or not self.arms then
		self.mm = multimodel.CreateInstance("robotthingy")
		self.hull = multimodel.CreateInstance("mechhull")
		self.arms = multimodel.CreateInstance("mecharms")
	end
	
	if not IsValid(self.Skeleton) then return end
	--debugoverlay.BoxAngles( self:GetPos(),self:FakeOBBMins() , self:FakeOBBMaxs(), angle_zero, 0.01, Color( 255, 255, 0, 100 ) )
	
	debugoverlay.Axis( self:SEyePos(),angle_zero, 5,0.01,true )
	
	--render.PushFlashlightMode( false )
	render.SetBlend(0)
	self.Skeleton:SetRenderOrigin(self:GetPos())
	self.Skeleton:SetRenderAngles(self:GetAngles())
	self.Skeleton:DrawModel()
	render.SetBlend(1)
	--render.PopFlashlightMode( )
	
	
	
	if not self.Atch then
		self.Atch={}
	end
	
	if self.mm then 
		multimodel.SetOutputTarget(self.Atch)
		multimodel.Draw(self.mm, self.Skeleton)
		multimodel.DoFrameAdvance(self.mm, CurTime(), self.Skeleton)
		multimodel.SetOutputTarget(nil)
	end
	
	if self.hull then
		local bone=self.Skeleton:LookupBone("ValveBiped.Bip01_Spine1")
		local m=self.Skeleton:GetBoneMatrix(bone)
		if m then
			multimodel.SetOutputTarget(self.Atch)
			multimodel.Draw(self.hull, self.Skeleton,{origin=m:GetTranslation(),angles=m:GetAngles()})
			multimodel.DoFrameAdvance(self.hull, CurTime(), self.Skeleton)
			multimodel.SetOutputTarget(nil)
		end
	end
	
	if self.arms then
		local bone=self.Skeleton:LookupBone("ValveBiped.Bip01_Spine1")
		local m=self.Skeleton:GetBoneMatrix(bone)
		if m then
			multimodel.SetOutputTarget(self.Atch)
			multimodel.Draw(self.arms, self.Skeleton,{origin=m:GetTranslation(),angles=m:GetAngles()})
			multimodel.DoFrameAdvance(self.arms, CurTime(), self.Skeleton)
			multimodel.SetOutputTarget(nil)
		end
	end

	if IsValid(self.PlaceHolder) and self.Atch.seatpos and drawlp and IsValid(self:GetOwner()) then	--self:GetOwner()~=LocalPlayer()				then
		if self.PlaceHolder:GetModel()~= self:GetOwnerModel() then
			self.PlaceHolder:SetModel(self:GetOwnerModel())
			self.PlaceHolder:SetupBones()
		end
		
		self.PlaceHolder:ResetSequence( self.PlaceHolder:LookupSequence( "sit_rollercoaster" ) )
		self.PlaceHolder:SetRenderOrigin(self.Atch.seatpos.pos)
		self.PlaceHolder:SetRenderAngles(self.Atch.seatpos.ang)
		self.PlaceHolder:DrawModel()
		self.PlaceHolder:SetPoseParameter( "vertical_velocity", -0.3 ) 
		
	end
	
	--[[
	for i,v in pairs(self.Atch) do
		debugoverlay.Axis( v.pos,v.ang, 5,0.01,true )
	end
	]]
	
	if IsValid(self:GetSAC()) then
		self:GetSAC():DoSpecialAction("DrawWorldModel")
	end

	
	--[[
	local bonecount=self:GetBoneCount()-1
	for i=0,bonecount do
		local matr=self:GetBoneMatrix(i)
		if not matr then continue end
		local pos=matr:GetTranslation()
		local ang=matr:GetAngles()
		debugoverlay.Axis( pos,ang, 5,0.01,true )
		debugoverlay.Text( pos, self:GetBoneName(i) , 0.01 )
		--self:GetBoneName(i)
	end
	]]
end

ENT.EyeOffset=Vector(15,0,160)
ENT.AngleOffset=Angle(0,0,0)

function ENT:SEyePos()
	local p,a
	p,a=LocalToWorld(self.EyeOffset,self.AngleOffset,self:GetPos(),self:GetAngles())
	return p
end

ENT.GetShootPos=ENT.SEyePos

function ENT:GetAimVector()
	return self:GetDTEyeAngles():Forward()
end

function ENT:OnTakeDamage(dmginfo)
	if IsValid(self:GetOwner()) then
		self:GetOwner():TakeDamageInfo(dmginfo)
	end
end

function ENT:GetGravityVector()
	return self.GravityVector or Vector(0, 0, -600)
end

function ENT:SetGravityVector(v)
	self.GravityVector = v or Vector(0, 0, -600)
end

function ENT:GetJumpPower()
	return 350
end

function ENT:GetStepSize()
	return 32
end

function ENT:GetMaxSpeed()
	return 150
end

function ENT:GetGroundSeqSpeed()
	--the commented part is actually right :v, but since I don't know how to actually handle it correctly, fuck it
	return self:GetMaxSpeed()	--return self:GetSequenceGroundSpeed(self:GetSequence())
end

--[[

lua_run_cl for i=0, LocalPlayer():GetNumPoseParameters() do print(LocalPlayer():GetPoseParameterName(i),LocalPlayer():GetPoseParameterRange(i)) end
move_y	-1	1
move_x	-1	1
aim_yaw	-63.396041870117	71.294631958008
aim_pitch	-84.490516662598	81.741363525391
vertical_velocity	-1	1
vehicle_steer	-1	1
head_yaw	-75	75
head_pitch	-60	60
]]

local MOVING_MINIMUM_SPEED = 0.1
function ENT:CalcMovementPlaybackRate()
	// Determine ideal playback rate
	local vel=self:GetAbsVelocity()

	local speed = vel:Length2D();
	local isMoving = ( speed > MOVING_MINIMUM_SPEED );
	bIsMoving = false;
	local flReturnValue = 1;

	if ( isMoving ) then 
		local flGroundSpeed = self:GetGroundSeqSpeed();
		if ( flGroundSpeed < 0.001 ) then
			flReturnValue = 0.01;
		else
			// Note this gets set back to 1.0 if sequence changes due to ResetSequenceInfo below
			flReturnValue = speed / flGroundSpeed;
			flReturnValue = math.Clamp( flReturnValue, 0.01, 10 );	// don't go nuts here.
		end
		bIsMoving = true;
	end
	
	return flReturnValue,bIsMoving;
end

--[[
function ENT:SendAnimation(act)
	local seq = self:SelectWeightedSequence( act ) 
	if self:GetSequence() != seq then
		self:SetPlaybackRate( 1.0 )
		self:ResetSequence( seq )
		self:SetCycle( 0 )
	end
end
]]





function ENT:HandleFootsteps()
	
	--only do this if we're on the ground, or clientside
	if self:GetDTGroundEntity()==NULL then return end
	if SERVER then return end
	local playback,moving=self:CalcMovementPlaybackRate()
	
	if not moving then return end
	
	
	local bone=self:LookupBone("ValveBiped.Bip01_Spine4")
	local m=self:GetBoneMatrix(bone)
	if m then
		if self.StepSoundTime < CurTime() then
			self.LastFoot=not self.LastFoot
			self:Footstep(self.LastFoot,m:GetTranslation())
			local speed=self:GetAbsVelocity():Length2D()
			if speed > 2 then
				self.StepSoundTime=CurTime() + 0.55 * playback
			end
		end
		
	end
	
end

function ENT:Footstep(footstep,pos)
	self:EmitSound(foot and "NPC_dog.FootstepLeft" or "NPC_dog.FootstepRight")
	--EmitSound( "vo/citadel/br_no.wav", m:GetTranslation(), self:EntIndex(), CHAN_BODY, 1, 4, 0, 100 )
	
end



function ENT:HandleAnimations()
	if not IsValid(self.Skeleton) then return end
	if not self.Cycle then
		self.Cycle = 0
	end
	
	local playback,moving=1,false

	if IsValid(self:GetOwner()) then
		if self:GetDTGroundEntity()==NULL then
			--self.Cycle=0.2
			self.Skeleton:ResetSequence( self.Skeleton:LookupSequence( "jump_dual" ) )
		else
			self.Skeleton:ResetSequence( self.Skeleton:LookupSequence( "walk_dual" ) )
		end
	else
		self.Skeleton:ResetSequence( self.Skeleton:LookupSequence( "pose_ducking_01" ) )
	end
	
	playback,moving=self:CalcMovementPlaybackRate()
	
	
	
	
	local vel=self:GetAbsVelocity():GetNormal()
	local an=Angle(0,-self:GetAngles().y,0)
	vel:Rotate(an)
	vel.z=0
	
	
	self.Skeleton:SetPoseParameter( "move_x", vel.x * playback) 
	self.Skeleton:SetPoseParameter( "move_y", vel.y * -1 * playback) 
	
	local ownerpitch=0
	if IsValid(self:GetOwner()) then
		ownerpitch=math.Clamp(self:GetDTEyeAngles().p-20,-84,81)
	end
	self.Skeleton:SetPoseParameter( "aim_pitch", ownerpitch)

	local ftime=FrameTime()--engine.TickInterval()--
	if moving then
		self.Cycle = (self.Cycle + playback * ftime) % 1
	else
		self.Cycle = (self.Cycle + 1*ftime) % 1
	end
	
	self.Skeleton:SetCycle(self.Cycle)
end


function ENT:Use(act)
	self:StartDriving(act)
end

function ENT:StartDriving(act)
	if not IsValid(self:GetOwner()) and IsValid(act) and act:IsPlayer() and not act:IsDrivingEntity() then
		drive.PlayerStartDriving( act, self, "drive_robot" )
		self:SetOwnerModel(act:GetModel())
		self:SetOwner(act)
	end
end


function ENT:StopDriving()
	if IsValid(self:GetOwner()) then
		drive.PlayerStopDriving(self:GetOwner())
	end
	--self:DropToFloor()
	self:SetAbsVelocity(Vector(0,0,0))
	self:SetOwner(NULL)
end

function ENT:ThinkDriving()
	if CLIENT then return end
	if not IsValid(self:GetOwner()) or not self:GetOwner():Alive() then
		self:StopDriving()
	end
	
	if IsValid(self:GetOwner()) and self:GetOwner():KeyDown(IN_RELOAD) then
		self:DropToFloor()
		self:StopDriving()
	end
	
end

function ENT:Think()
	if CLIENT then
		self:HandleAnimations()
	end
	--self:HandleFootsteps()
	self:ThinkDriving()
	

end



scripted_ents.Register(ENT,ClassName,true)






local META = {}

-----------------------------------------------------------
-- Constants and convars

local COORD_RESOLUTION = 1 / 32
local DIST_EPSILON = 0.03125
local NON_JUMP_VELOCITY = 140
local CHECKSTUCK_MINTIME = 0.05
local AIR_SPEEDCAP = 30

local sv_accelerate = GetConVar("sv_accelerate")
local sv_airaccelerate = GetConVar("sv_airaccelerate")
local sv_gravity = GetConVar("sv_gravity")
local sv_friction = GetConVar("sv_friction")
local sv_maxvelocity = GetConVar("sv_maxvelocity")
local sv_bounce = GetConVar("sv_bounce")
local sv_stopspeed = GetConVar("sv_stopspeed")

local GRAVITY_OVERRIDE = Vector(0, 0, 1)

-----------------------------------------------------------
-- Preallocated vectors

local tmpvec1 = Vector()
local tmpvec2 = Vector()
local tmpvec3 = Vector()
local tmpvec4 = Vector()

-----------------------------------------------------------
-- Stuck table

local function CreateStuckTable()
	local tab = {}
	
	-- Little moves
	local s = 0.125
	for x=-1, 1 do
		for y=-1, 1 do
			for z=-1, 1 do
				if x~=0 or y~=0 or z~=0 then
					table.insert(tab, Vector(x*s, y*s, z*s))
				end
			end
		end
	end
	
	-- Big moves
	s = 2
	local zi = {0, 1, 6}
	for x=-1, 1 do
		for y=-1, 1 do
			for i=1, 3 do
				local z = zi[i]
				if x~=0 or y~=0 or z~=0 then
					table.insert(tab, Vector(x*s, y*s, z))
				end
			end
		end
	end
	
	tab.n = #tab
	return tab
end

local STUCKTABLE = CreateStuckTable()

local function IsNotNull(ent)
	return ent ~= NULL
end

local function IsNull(ent)
	return ent == NULL
end

-----------------------------------------------------------
-- Helper functions for working with unconventional gravity

function META:GetZ(vec)
	return vec:Dot(self.ZVector)
end

function META:AddZ(vec, z)
	vec:Add(self.ZVector * z)
	return vec
end

function META:SetZ(vec, z)
	return self:AddZ(vec, z - self:GetZ(vec))
end

-----------------------------------------------------------
-- Touch list management

function META:AddToTouched(tr, vel)
	if not IsNotNull(tr.Entity) then return false end
	if self.TouchList[tr.Entity] then return false end
	if not self.TouchList then self:ResetTouchList() end
	
	self.TouchList[tr.Entity] = {trace = tr, deltavelocity = 1*vel}
	return true
end

function META:ResetTouchList()
	self.TouchList = {}
end

-----------------------------------------------------------
-- Stuck check utilities

function META:GetRandomStuckOffsets()
	self.StuckLast = (self.StuckLast or 0) + 1
	local i = ((self.StuckLast - 1) % STUCKTABLE.n) + 1
	
	return 1 * STUCKTABLE[i], i
end

function META:ResetStuckOffsets()
	self.StuckLast = nil
end

-----------------------------------------------------------
-- Sets the player's ground entity using a trace result

function META:SetGroundEntity(tr)
	local newground = NULL
	if tr and IsNotNull(tr.Entity) then
		newground = tr.Entity
	end
	
	local oldground = self.Player:GetDTGroundEntity()
	
	if not IsNotNull(oldground) and IsNotNull(newground) then
		-- Hit ground after jumping, subtract ground velocity
		self.BaseVelocity:Sub(newground:GetVelocity())
		self:SetZ(self.BaseVelocity, self:GetZ(newground:GetVelocity()))
	elseif IsNotNull(oldground) and not IsNotNull(newground) then
		-- Jumped off ground, add in ground velocity
		self.BaseVelocity:Add(oldground:GetVelocity())
		self:SetZ(self.BaseVelocity, self:GetZ(oldground:GetVelocity()))
	end
	

	self.Player:SetDTGroundEntity(newground)
	
	--[[
	if IsNotNull(newground) then
		-- TEST: Gravity
		self.Player:SetGravityVector(-self.Gravity * tr.HitNormal)
		
		-- Standing on something
		self:CategorizeGroundSurface(tr)
		if not tr.HitWorld then
			self:AddToTouched(tr, self.Velocity)
		end
		self:SetZ(self.Velocity, 0)
	end
	]]
end

-----------------------------------------------------------
-- Get surface data from whatever we're standing on

function META:CategorizeGroundSurface(tr)
	-- todo
end

-----------------------------------------------------------
-- Checks move data

function META:CheckParameters()
	local xspeed = self.MoveData:GetForwardSpeed()
	local yspeed = self.MoveData:GetSideSpeed()
	local zspeed = self.MoveData:GetUpSpeed()
	
	local spd = xspeed*xspeed + yspeed*yspeed + zspeed*zspeed
	local maxspeed = self.MoveData:GetMaxClientSpeed()
	if maxspeed ~= 0 then
		self.MoveData:SetMaxSpeed(math.min(maxspeed, self.MoveData:GetMaxSpeed()))
	end
	
	spd = math.sqrt(spd)
	if spd ~= 0 and spd > maxspeed then
		local ratio = maxspeed / spd
		self.MoveData:SetForwardSpeed(xspeed * ratio)
		self.MoveData:SetSideSpeed(yspeed * ratio)
		self.MoveData:SetUpSpeed(zspeed * ratio)
	end
end

-----------------------------------------------------------
-- Updates ground entity

function META:CategorizePosition()
	self.SurfaceFriction = 1.5
	
	local offset = 2
	local point = 1 * self.Origin
	self:AddZ(point, -offset)
	
	local bumpOrigin = 1 * self.Origin
	local zvel = self:GetZ(self.Velocity)
	
	local movingUp = zvel > 0
	local movingUpRapidly = zvel > NON_JUMP_VELOCITY
	local groundEntityVelZ = 0
	
	-- fixes some kind of issue that would happen when saving
	-- on a moving lift or something
	if movingUpRapidly then
		local ground = self.Player:GetDTGroundEntity()
		if IsNotNull(ground) then
			groundEntityVelZ = self:GetZ(ground:GetVelocity())
			movingUpRapidly = (zvel - groundEntityVelZ) > NON_JUMP_VELOCITY
		end
	end
	
	if movingUpRapidly then
		-- Moving up rapidly, not standing on ground
		self:SetGroundEntity(nil)
	else
		-- Try and move down
		local tr = self:TryTouchGround(bumpOrigin, point)
		
		if not IsNotNull(tr.Entity) or self:GetZ(tr.HitNormal) < 0.7 then
			-- Perform a finer test to detect potential slopes we could
			-- actually stand on
			tr = self:TryTouchGroundInQuadrants(tr, bumpOrigin, point)
		end
		
		if not IsNotNull(tr.Entity) or self:GetZ(tr.HitNormal) < 0.7 then
			-- Not on ground anymore (steep slopes don't count as being on the ground)
			self:SetGroundEntity(nil)
			if self:GetZ(self.Velocity) > 0 then
				self.SurfaceFriction = 0.25
			end
		else
			-- On ground, set ground entity accordingly
			self:SetGroundEntity(tr)
		end
	end
end

-----------------------------------------------------------
-- Performs a hull trace using the player's bounding box

--[[
function(ent)

	return ent ~= self.Player and ent:GetOwner() ~= self.Player and ent ~= self.Player:GetOwner() and ent:GetOwner() ~= self.Player:GetOwner()

end
]]
function META:TracePlayerBBox(start, endpos, mask, colgroup)
	return util.TraceHull{
		start = start;
		endpos = endpos;
		mask = mask or MASK_PLAYERSOLID;
		colgroup = colgroup or COLLISION_GROUP_PLAYER_MOVEMENT;
		mins = self:OBBMins();
		maxs = self:OBBMaxs();
		filter = function(ent)

			return ent ~= self.Player and ent:GetOwner() ~= self.Player and ent ~= self.Player:GetOwner() and ent:GetOwner() ~= self.Player:GetOwner()

		end
	}
end

-----------------------------------------------------------
-- Tests the player's position

function META:TestPlayerPosition(start, colgroup)
	local tr = util.TraceHull{
		start = start;
		endpos = start;
		mask = MASK_PLAYERSOLID;
		colgroup = colgroup or COLLISION_GROUP_PLAYER_MOVEMENT;
		mins = self:OBBMins();
		maxs = self:OBBMaxs();
		filter = function(ent)

			return ent ~= self.Player and ent:GetOwner() ~= self.Player and ent ~= self.Player:GetOwner() and ent:GetOwner() ~= self.Player:GetOwner()

		end
	}
	
	return tr.Entity, tr
end

-----------------------------------------------------------
-- Pretty much the same as TracePlayerBBox?

function META:TryTouchGround(start, endpos, mins, maxs, mask, colgroup)
	return util.TraceHull{
		start = start;
		endpos = endpos;
		mask = mask or MASK_PLAYERSOLID;
		colgroup = colgroup or COLLISION_GROUP_PLAYER_MOVEMENT;
		mins = mins or self:OBBMins();
		maxs = maxs or self:OBBMaxs();
		filter = function(ent)

			return ent ~= self.Player and ent:GetOwner() ~= self.Player and ent ~= self.Player:GetOwner() and ent:GetOwner() ~= self.Player:GetOwner()

		end
	}
end

-----------------------------------------------------------
-- Traces the player's hull in quadrants

function META:TryTouchGroundInQuadrants(tr0, start, endpos, mask, colgroup)
	local fraction0 = tr0.Fraction
	local endpos0 = tr0.HitPos
	
	local mins = Vector(0, 0, 0)
	local maxs = Vector(0, 0, 0)
	local minsSrc = self:OBBMins()
	local maxsSrc = self:OBBMaxs()
	
	-- -x -y quadrant
	mins.x = minsSrc.x
	mins.y = minsSrc.y
	mins.z = minsSrc.z
	maxs.x = math.min(maxsSrc.x, 0)
	maxs.y = math.min(maxsSrc.y, 0)
	maxs.z = maxsSrc.z
	
	tr = self:TryTouchGround(start, endpos, mins, maxs)
	if IsNotNull(tr.Entity) and self:GetZ(tr.HitNormal) >= 0.7 then
		tr.Fraction = fraction0
		tr.HitPos = endpos0
		return tr
	end
	
	-- +x +y quadrant
	mins.x = math.max(minsSrc.x, 0)
	mins.y = math.max(minsSrc.y, 0)
	mins.z = minsSrc.z
	maxs.x = maxsSrc.x
	maxs.y = maxsSrc.y
	maxs.z = maxsSrc.z
	
	tr = self:TryTouchGround(start, endpos, mins, maxs)
	if IsNotNull(tr.Entity) and self:GetZ(tr.HitNormal) >= 0.7 then
		tr.Fraction = fraction0
		tr.HitPos = endpos0
		return tr
	end
	
	-- -x +y quadrant
	mins.x = minsSrc.x
	mins.y = math.max(minsSrc.y, 0)
	mins.z = minsSrc.z
	maxs.x = math.min(maxsSrc.x, 0)
	maxs.y = maxsSrc.y
	maxs.z = maxsSrc.z
	
	tr = self:TryTouchGround(start, endpos, mins, maxs)
	if IsNotNull(tr.Entity) and self:GetZ(tr.HitNormal) >= 0.7 then
		tr.Fraction = fraction0
		tr.HitPos = endpos0
		return tr
	end
	
	-- +x -y quadrant
	mins.x = math.max(minsSrc.x, 0)
	mins.y = minsSrc.y
	mins.z = minsSrc.z
	maxs.x = maxsSrc.x
	maxs.y = math.min(maxsSrc.y, 0)
	maxs.z = maxsSrc.z
	
	tr = self:TryTouchGround(start, endpos, mins, maxs)
	if IsNotNull(tr.Entity) and self:GetZ(tr.HitNormal) >= 0.7 then
		tr.Fraction = fraction0
		tr.HitPos = endpos0
		return tr
	end
	
	tr.Fraction = fraction0
	tr.HitPos = endpos0
	return tr
end

-----------------------------------------------------------
-- Clamps the movement velocity

function META:CheckVelocity()
	local maxvel = sv_maxvelocity:GetFloat()
	
	self.Velocity.x = math.Clamp(self.Velocity.x, -maxvel, maxvel)
	self.Velocity.y = math.Clamp(self.Velocity.y, -maxvel, maxvel)
	self.Velocity.z = math.Clamp(self.Velocity.z, -maxvel, maxvel)
end

-----------------------------------------------------------
-- Makes a velocity vector follow a given clipping plane

function META:ClipVelocity(vel, normal, out, overbounce)
	local angle = self:GetZ(normal)
	local blocked = 0
	
	if angle > 0 then
		-- Blocked by floor
		blocked = bit.bor(blocked, 1)
	end
	
	if angle == 0 then
		-- Blocked by vertical obstacle
		blocked = bit.bor(blocked, 2)
	end
	
	-- Slide velocity along the plane defined by its normal
	local backoff = vel:Dot(normal) * overbounce
	
	out:Set(vel)
	out:MulAdd(normal, -backoff)
	
	-- Do it again to make sure
	-- todo: just clamp overbounce to make sure it's not less than 1?
	local adjust = out:Dot(normal)
	if adjust < 0 then
		out:MulAdd(normal, -adjust)
	end
	
	return blocked
end

-----------------------------------------------------------
-- Attempt to unstick a player if they get stuck

function META:CheckStuck()
	if true then return false end
	
	local ent, tr = self:TestPlayerPosition(self.Origin)
	if not IsNotNull(ent) then
		self:ResetStuckOffsets()
		return false
	end
	
	local base = 1 * self.Origin
	if CLIENT then
		-- Deal with precision errors in network
		if ent:IsWorld() then
			self:ResetStuckOffsets()
			for i=1, #STUCKTABLE do
				local offset = self:GetRandomStuckOffsets()
				local test = base + offset
				ent, tr = self:TestPlayerPosition(test)
				if not IsNotNull(ent) then
					self:ResetStuckOffsets()
					self.Origin:Set(test)
					return false
				end
			end
		end
	end
	
	if	CLIENT and
		self.LastStuckCheckTime and
		CurTime() < self.LastStuckCheckTime + CHECKSTUCK_MINTIME
	then
		-- too soon
		return true
	end
	self.LastStuckCheckTime = CurTime()
	
	self:AddToTouched(tr, self.Velocity)
	local offset = self:GetRandomStuckOffsets()
	local test = base + offset
	ent, tr = self:TestPlayerPosition(test)
	if not IsNotNull(ent) then
		self:ResetStuckOffsets()
		self.Origin:Set(test)
		return false
	end
	
	return true
end

--------------------------------------------------------------------------
-- Stay on the ground when running down a slope

function META:StayOnGround()
	local start = 1 * self.Origin
	local endpos = 1 * self.Origin
	
	self:AddZ(start, 2)
	self:AddZ(endpos, -self.Player:GetStepSize())
	
	-- Trace upwards first to see how far up we can go without
	-- getting stuck
	local tr = self:TracePlayerBBox(self.Origin, start)
	start:Set(tr.HitPos)
	
	-- Trace downwards from the previously found safe position
	tr = self:TracePlayerBBox(start, endpos)
	if	tr.Fraction > 0 and
		tr.Fraction < 1 and
		not tr.StartSolid and
		self:GetZ(tr.HitNormal) >= 0.7
	then
		local delta = math.abs(self:GetZ(self.Origin) - self:GetZ(tr.HitPos))
		
		-- incredibly hacky shit according to valve or something
		-- because of the trace potentially returning weird values
		-- that can't be networked
		if delta > 0.5 * COORD_RESOLUTION then
			self.Origin:Set(tr.HitPos)
		end
	end
end

--------------------------------------------------------------------------
-- Apply half gravity

function META:StartGravity()
	local grav = self.Player:GetGravity()
	if grav == 0 then
		grav = 1
	end
	
	--grav = grav * sv_gravity:GetFloat()
	grav = grav * self.Gravity
	
	self:AddZ(self.Velocity, (self:GetZ(self.BaseVelocity) - grav * 0.5) * FrameTime())
	self:SetZ(self.BaseVelocity, 0)
	
	self:CheckVelocity()
end

--------------------------------------------------------------------------
-- Apply remaining half of gravity

function META:FinishGravity()
	local grav = self.Player:GetGravity()
	if grav == 0 then
		grav = 1
	end
	
	--grav = grav * sv_gravity:GetFloat()
	grav = grav * self.Gravity
	
	self:AddZ(self.Velocity, - grav * 0.5 * FrameTime())
	
	self:CheckVelocity()
end

--------------------------------------------------------------------------
-- Apply ground friction

function META:Friction()
	local speed = self.Velocity:Length()
	
	if speed < 0.1 then
		return
	end
	
	local drop = 0
	
	if self:OnGround() then
		local friction = sv_friction:GetFloat() * self.SurfaceFriction
		local control = math.max(speed, sv_stopspeed:GetFloat())
		
		drop = drop + control * friction * FrameTime()
	end
	
	local newspeed = math.max(0, speed - drop)
	
	if newspeed ~= speed then
		local frac = newspeed / speed
		self.Velocity:Mul(frac)
		self.OutWishVel:MulAdd(self.Velocity, frac-1)
	end
end

--------------------------------------------------------------------------
-- Ground acceleration

function META:Accelerate(wishdir, wishspeed, accel)
	local curspeed = self.Velocity:Dot(wishdir)
	local addspeed = wishspeed - curspeed
	
	if addspeed <= 0 then return end
	
	local accelspeed = accel * wishspeed * FrameTime() * self.SurfaceFriction
	
	if accelspeed > addspeed then
		accelspeed = addspeed
	end
	
	self.Velocity:MulAdd(wishdir, accelspeed)
end

--------------------------------------------------------------------------
-- Air acceleration

function META:AirAccelerate(wishdir, wishspeed, accel)
	local wishspd = math.min(wishspeed, AIR_SPEEDCAP)
	
	local curspeed = self.Velocity:Dot(wishdir)
	local addspeed = wishspd - curspeed
	
	if addspeed <= 0 then return end
	
	local accelspeed = accel * wishspeed * FrameTime() * self.SurfaceFriction
	
	if accelspeed > addspeed then
		accelspeed = addspeed
	end
	
	self.Velocity:MulAdd(wishdir, accelspeed)
	self.OutWishVel:MulAdd(wishdir, accelspeed)
end

--------------------------------------------------------------------------
-- Jumping

function META:CheckJumpButton()
	-- Not on the ground, can't jump
	if not self:OnGround() then
		self.JumpWasPressed = true
		return false
	end
	
	-- Don't pogo stick
	if self.JumpWasPressed then
		return false
	end
	
	-- Jumping, so not standing on the ground anymore
	self:SetGroundEntity(nil)
	
	-- todo: jump sound
	--player->PlayStepSound( (Vector &)mv->GetAbsOrigin(), player->m_pSurfaceData, 1.0, true );
	if IsFirstTimePredicted() then
		--self.Player:Footstep(0)
	end
	
	-- Send jump animation
	--self.Player:DoAnimationEvent(PLAYERANIMEVENT_JUMP, true)
	
	-- Maybe for sticky floors?
	local groundFactor = 1
	
	-- Jump power (jumps about 21 units up at 600 gravity)
	-- can also be calculated using sqrt(2 * gravity * desired_height)
	local power = self.Player:GetJumpPower()
	
	-- Apply jump force
	local startz = self:GetZ(self.Velocity)
	self:AddZ(self.Velocity, groundFactor * power)
	
	-- Apply gravity
	self:FinishGravity()
	
	self:AddZ(self.OutJumpVel, self:GetZ(self.Velocity) - startz)
	self.OutStepHeight = self.OutStepHeight + 0.15
	
	self.JumpWasPressed = true
	return true
end

--------------------------------------------------------------------------
-- Try to move to destination point

function META:TryPlayerMove(first_dest, first_trace)
	local original_vel = tmpvec1
	local primal_vel = tmpvec2
	local endpos = tmpvec3
	
	original_vel:Set(self.Velocity)
	primal_vel:Set(self.Velocity)
	
	local numbumps = 4
	local timeleft = FrameTime()
	
	local numplanes = 0
	local planes = {}
	
	local new_vel = Vector(0, 0, 0)
	local allFraction = 0
	local blocked = 0
	
	for bumps=1, numbumps do
		if self.Velocity:Length() == 0 then break end
		
		-- Try to move all the way from current origin to end point
		endpos:Set(self.Origin)
		endpos:MulAdd(self.Velocity, timeleft)
		
		local tr
		
		if first_dest and first_dest == endpos then
			tr = first_trace
		else
			--[[
			tr = self:TracePlayerBBox(self.Origin, self.Origin)
			if tr.StartSolid or tr.Fraction ~= 1 then
				MsgN("bah")
			end
			]]
			
			tr = self:TracePlayerBBox(self.Origin, endpos)
		end
		
		allFraction = allFraction + tr.Fraction
		
		-- Started in a solid object, we're blocked
		if tr.StartSolid then
			--print("Blocked inside solid object")
			self.Velocity:Zero()
			return 3
		end
		
		-- Actually covered some distance
		if tr.Fraction > 0 then
			if numbumps > 0 and tr.Fraction == 1 then
				-- Fixes a minor issue with tracehulls where the hitpos
				-- would be stuck in map geometry
				local stuck = self:TracePlayerBBox(tr.HitPos, tr.HitPos)
				if stuck.StartSolid or stuck.Fraction ~= 1 then
					MsgN("Player will become stuck!!!")
					self.Velocity:Zero()
					break
				end
			end
			
			-- Update position
			self.Origin:Set(tr.HitPos)
			original_vel:Set(self.Velocity)
			numplanes = 0
		end
		
		-- Covered the entire distance, nothing left to do
		if tr.Fraction == 1 then
			break
		end
		
		-- Blocked by an entity, register that entity
		self:AddToTouched(tr, self.Velocity)
		
		-- Blocked by a floor
		if self:GetZ(tr.HitNormal) > 0.7 then
			blocked = bit.bor(blocked, 1)
		end
		
		-- Blocked by a step or a wall
		if self:GetZ(tr.HitNormal) == 0 then
			blocked = bit.bor(blocked, 2)
		end
		
		-- Reduce amount of time left
		timeleft = timeleft * (1 - tr.Fraction)
		
		-- Add clipping plane
		numplanes = numplanes + 1
		planes[numplanes] = tr.HitNormal
		
		if numplanes == 1 and not self:OnGround() then
			-- Prevents the player from getting stuck by jumping into acute corners
			-- (apparently)
			for i=1, numplanes do
				if self:GetZ(planes[i]) > 0.7 then
					-- floor or slope
					self:ClipVelocity(original_vel, planes[i], new_vel, 1)
				else
					-- wall
					local bounce = 1 + sv_bounce:GetFloat() * (1 - self.SurfaceFriction)
					self:ClipVelocity(original_vel, planes[i], new_vel, bounce)
				end
			end
			
			self.Velocity:Set(new_vel)
			original_vel:Set(new_vel)
		else
			-- Make original_vel parallel to all the clip planes
			local lasti
			for i=1, numplanes do
				self:ClipVelocity(original_vel, planes[i], self.Velocity, 1)
				
				-- Check if we're still moving against a plane
				local ok = true
				for j=1, numplanes do
					if j ~= i and self.Velocity:Dot(planes[j]) < 0 then
						ok = false
						break
					end
				end
				
				-- Nope, no need to clip further
				if ok then
					break
				end
				lasti = i
			end
			
			-- Did we go all the way through the plane set
			if lasti ~= numplanes then
				
			else
				-- Go along the crease
				if numplanes ~= 2 then
					--print("More than two planes")
					self.Velocity:Zero()
					break
				end
				
				local dir = planes[1]:Cross(planes[2])
				dir:Normalize()
				dir:Mul(dir:Dot(self.Velocity))
				self.Velocity:Set(dir)
			end
			
			-- If the new velocity is against the initial velocity, stop moving
			if self.Velocity:Dot(primal_vel) <= 0 then
				--print("New velocity against initial velocity")
				self.Velocity:Zero()
				break
			end
		end
	end
	
	if allFraction == 0 then
		self.Velocity:Zero()
	end
	
	return blocked
end

--------------------------------------------------------------------------
-- Walking movement step

function META:StepMove(dest, tr)
	local endpos = 1 * dest
	local pos = 1 * self.Origin
	local vel = 1 * self.Velocity
	
	-- Try to slide move down
	self:TryPlayerMove(endpos, tr)
	local downpos = 1 * self.Origin
	local downvel = 1 * self.Velocity
	
	-- Restore original values
	self.Origin:Set(pos)
	self.Velocity:Set(vel)
	
	-- Move up a stair
	endpos:Set(self.Origin)
	self:AddZ(endpos, self.Player:GetStepSize() + DIST_EPSILON)
	tr = self:TracePlayerBBox(self.Origin, endpos)
	if not tr.StartSolid then
		self.Origin:Set(tr.HitPos)
	end
	
	-- Slide move up
	self:TryPlayerMove()
	
	-- Move down a stair
	endpos:Set(self.Origin)
	self:AddZ(endpos, - self.Player:GetStepSize() - DIST_EPSILON)
	tr = self:TracePlayerBBox(self.Origin, endpos)
	
	-- Not on the ground anymore, use the first movement attempt
	if self:GetZ(tr.HitNormal) < 0.7 then
		self.Origin:Set(downpos)
		self.Velocity:Set(downvel)
		
		local stepdist = self:GetZ(self.Origin) - self:GetZ(pos)
		if stepdist > 0 then
			self.OutStepHeight = self.OutStepHeight + stepdist
		end
		
		return
	end
	
	-- Trace ended up in empty space, move towards the endpos
	if not tr.StartSolid then
		self.Origin:Set(tr.HitPos)
	end
	
	local uppos = 1 * self.Origin
	
	-- Decide which attempt went farther
	local downdist = self:SetZ(downpos - pos, 0):LengthSqr()
	local updist = self:SetZ(uppos - pos, 0):LengthSqr()
	
	if downdist > updist then
		self.Origin:Set(downpos)
		self.Velocity:Set(downvel)
	else
		self:SetZ(self.Velocity, self:GetZ(downvel))
	end
	
	local stepdist = self:GetZ(self.Origin) - self:GetZ(pos)
	if stepdist > 0 then
		self.OutStepHeight = self.OutStepHeight + stepdist
	end
end

--------------------------------------------------------------------------
-- Walk movement

function META:WalkMove()
	local ang = self.MoveAngles
	local forward, right, up = ang:Forward(), ang:Right(), ang:Up()
	
	local fmove = self.MoveData:GetForwardSpeed()
	local smove = self.MoveData:GetSideSpeed()
	
	local oldground = self.Player:GetDTGroundEntity()
	
	-- Project movement vectors onto Z plane
	self:SetZ(forward, 0)
	forward:Normalize()
	
	self:SetZ(right, 0)
	right:Normalize()
	
	-- Compute desired velocity
	local wishvel = forward * fmove + right * smove
	self:SetZ(wishvel, 0)
	
	local wishdir = wishvel:GetNormal()
	local wishspeed = wishvel:Length()
	
	-- Clamp to max speed
	if wishspeed ~= 0 and wishspeed > self.MoveData:GetMaxSpeed() then
		wishvel:Mul(self.MoveData:GetMaxSpeed() / wishspeed)
		wishspeed = self.MoveData:GetMaxSpeed()
	end
	
	-- Accelerate
	self:SetZ(self.Velocity, 0)
	self:Accelerate(wishdir, wishspeed, sv_accelerate:GetFloat())
	self:SetZ(self.Velocity, 0)
	
	-- Add base velocity
	self.Velocity:Add(self.BaseVelocity)
	
	local spd = self.Velocity:Length()
	if spd < 1 then
		self.Velocity:Zero()
		self.Velocity:Sub(self.BaseVelocity)
		return
	end
	
	-- Try moving directly to the destination
	local dest = tmpvec1
	dest.x = self.Origin.x + self.Velocity.x * FrameTime()
	dest.y = self.Origin.y + self.Velocity.y * FrameTime()
	dest.z = self.Origin.z + self.Velocity.z * FrameTime()
	
	local tr = self:TracePlayerBBox(self.Origin, dest)
	
	-- Made it all the way, done
	self.OutWishVel:Add(wishdir * wishspeed)
	
	if tr.Fraction == 1 then
		self.Origin:Set(tr.HitPos)
		self.Velocity:Sub(self.BaseVelocity)
		
		self:StayOnGround()
		return
	end
	
	-- Not on ground, don't walk up stairs
	-- (but that shouldn't happen anyway?)
	if IsNull(oldground) then
		self.Velocity:Sub(self.BaseVelocity)
		return
	end
	
	-- Perform step movement
	self:StepMove(dest, tr)
	
	-- Done
	self.Velocity:Sub(self.BaseVelocity)
	self:StayOnGround()
end

--------------------------------------------------------------------------
-- Air movement

function META:AirMove()
	local ang = self.MoveAngles
	local forward, right, up = ang:Forward(), ang:Right(), ang:Up()
	
	local fmove = self.MoveData:GetForwardSpeed()
	local smove = self.MoveData:GetSideSpeed()
	
	-- Project movement vectors onto Z plane
	self:SetZ(forward, 0)
	forward:Normalize()
	
	self:SetZ(right, 0)
	right:Normalize()
	
	-- Compute desired velocity
	local wishvel = forward * fmove + right * smove
	self:SetZ(wishvel, 0)
	
	local wishdir = wishvel:GetNormal()
	local wishspeed = wishvel:Length()
	
	-- Clamp to max speed
	if wishspeed ~= 0 and wishspeed > self.MoveData:GetMaxSpeed() then
		wishvel:Mul(self.MoveData:GetMaxSpeed() / wishspeed)
		wishspeed = self.MoveData:GetMaxSpeed()
	end
	
	self:AirAccelerate(wishdir, wishspeed, sv_airaccelerate:GetFloat())
	self.Velocity:Add(self.BaseVelocity)
	
	self:TryPlayerMove()
	
	self.Velocity:Sub(self.BaseVelocity)
end

function META:OnGround()
	if self.Player:IsPlayer() then
		return self.Player:OnGround()
	else
		return self.Player:GetDTGroundEntity()~=NULL
	end
end

--------------------------------------------------------------------------
-- Full walking movement
function META:FullWalkMove()
	-- Apply gravity
	self:StartGravity()
	
	if self.MoveData:KeyDown(IN_JUMP) then
		self:CheckJumpButton()
	else
		self.JumpWasPressed = false
	end
	
	if self:OnGround() then
		self:SetZ(self.Velocity, 0)
		self:Friction()
	end
	
	self:CheckVelocity()
	
	if self:OnGround() then
		self:WalkMove()
	else
		self:AirMove()
	end
	
	-- Set final flags
	self:CategorizePosition()

	-- Make sure velocity is valid
	self:CheckVelocity()
	
	self:FinishGravity()

	-- If we are on ground, no downward velocity
	if self:OnGround() then
		self:SetZ(self.Velocity, 0)
	end
	
	-- self:CheckFalling()
end

-----------------------------------------------------------
-- Initialize the move controller

function META:SetupMove(move)
	self.MoveData = move
	local grav=Vector(0,0,-200)
	if self.Player.GetGravityVector then
		grav = self.Player:GetGravityVector()
	end
	
	self.ZVector = -1 * grav:GetNormal()
	self.Gravity = grav:Length()
	
	self.Velocity = move:GetVelocity()
	self.Origin = move:GetOrigin()
	self.Angles = move:GetAngles()
	self.MoveAngles = move:GetMoveAngles()
	
	self.OutWishVel = Vector(0, 0, 0)
	self.OutJumpVel = Vector(0, 0, 0)
	self.OutStepHeight = 0
	
	self.BaseVelocity = Vector(0, 0, 0)
	self.SurfaceFriction = 1

end

function META:OBBMins()
	return (self.Player.FakeOBBMins) and self.Player:FakeOBBMins() or self.Player:OBBMins()
end

function META:OBBMaxs()
	return (self.Player.FakeOBBMaxs) and self.Player:FakeOBBMaxs() or self.Player:OBBMaxs()
end


-----------------------------------------------------------
-- Do movement calculations

function META:Move()
	self:CheckParameters()
	self:ResetTouchList()
	
	self:FullWalkMove()
	
	self.MoveData:SetVelocity(self.Velocity)
	self.MoveData:SetOrigin(self.Origin)
	self.MoveData:SetAngles(self.Angles)

end

-----------------------------------------------------------
-- Finish moving

function META:FinishMove()
	if self.Player:IsPlayer() then
		self.Player:SetNetworkOrigin( self.MoveData:GetOrigin() )
		self.Player:SetLocalVelocity(self.MoveData:GetVelocity())
	else
		self.Player:SetNetworkOrigin( self.MoveData:GetOrigin() )
		self.Player:SetAbsVelocity( self.MoveData:GetVelocity() )
		
		local ang=self.MoveData:GetAngles()
		ang.p=0
		ang.r=0
		self.Player:SetAngles( ang )

		
		if ( IsValid( self.Player:GetPhysicsObject() ) ) then

			self.Player:GetPhysicsObject():EnableMotion( true )
			--we use angle_zero because, well, the hull never rotates, it'd be strange if it suddenly happened on the
			--physobj, might as well reflect that on the shadow
			--self.Player:GetPhysicsObject():UpdateShadow(self.MoveData:GetOrigin(),self.MoveData:GetAngles(),FrameTime())
			self.Player:GetPhysicsObject():SetPos(self.MoveData:GetOrigin())
			self.Player:GetPhysicsObject():SetAngles(self.MoveData:GetMoveAngles())
			self.Player:GetPhysicsObject():Wake()
			self.Player:GetPhysicsObject():EnableMotion( false )

		end
		
	end
end

-----------------------------------------------------------
-----------------------------------------------------------

local function CreateMoveController(pl)
	return setmetatable({
		Player = pl;
	}, {__index=META})
end

drive.Register( "drive_robot", 
{
	--
	-- Called on creation
	--
	Init = function( self ) end,
	
	CalcView =  function( self, view )
		if not IsValid(self.Entity)  then return end
		
		local eyeang=self.Player:EyeAngles()
		view.origin=self.Entity:SEyePos()
		view.angles.p=eyeang.p
		
		--[[
		if not IsValid(self.Entity.Skeleton) then return end
		local bone=self.Entity.Skeleton:LookupBone("ValveBiped.Bip01_Spine4")
		local m=self.Entity.Skeleton:GetBoneMatrix(bone)
		if m then
			view.origin=m:GetTranslation()
			view.angles=self.Player:EyeAngles()
		end
		]]
		
		--[[
		if self.Entity.Atch and self.Entity.Atch.eyepos then
			view.origin=self.Entity.Atch.eyepos.pos
			view.angles=self.Player:EyeAngles()
		end
		]]
		
		
		
	end,
	
	SetupControls = function( self, cmd )				

	end,
	StartMove =  function( self, mv, cmd )

		local ent=self.Entity
		if SERVER then
			self.Player:SetViewEntity(ent)
		end
		self.Player:SetObserverMode( OBS_MODE_IN_EYE )
		local entity_angle		= mv:GetAngles()--self.Entity:GetAngles()

		entity_angle.p=0
		entity_angle.r=0

		mv:SetMaxClientSpeed(self.Entity:GetMaxSpeed())
		mv:SetMaxSpeed(self.Entity:GetMaxSpeed())
		mv:SetOrigin( self.Entity:GetNetworkOrigin() )
		mv:SetVelocity( self.Entity:GetAbsVelocity())
		mv:SetMoveAngles( entity_angle )

		mv:SetAngles( entity_angle )
		
		self.Entity.MoveController = CreateMoveController(ent)
		self.Entity.MoveController:SetupMove(mv)
		self.Entity.MoveController:Move()
		self.Entity.MoveController:FinishMove()
		
		--leave these like this
	end,
	Move = function( self, mv )
	
	end,

	FinishMove =  function( self, mv )
		--this can be seen as a playertick hook
		local ent=self.Entity
		ent:SetDTEyeAngles(self.Player:EyeAngles())
		
		if IsValid(ent:GetSAC()) then
			if ent:GetSAC():GetNextTick() < CurTime() then
				ent:GetSAC():DoSpecialAction("AttackThink",mv)
				ent:GetSAC():DoSpecialAction("Think",mv)
				ent:GetSAC():SetNextTick(CurTime()+ent:GetSAC():GetTickRate())
			end
		end
	end


}, "drive_base" )






newsa=SA:New("Mech's Laser","sa_rbt_laser")
if CLIENT then

local sa_rocket_laserglow = CreateMaterial("sa_rocket_laserglow","UnlitGeneric",{
	["$basetexture"] = "sprites/light_glow02",
	["$nocull"] = 1,
	["$additive"] = 1,
	["$vertexalpha"] = 1,
	["$vertexcolor"] = 1,
	["$spriterendermode"] = RENDERMODE_GLOW,
})

local sa_laser_color = Color(150, 200, 255, 255)

local sa_laser_dotlight = {
	{
		model = "models/props_c17/light_domelight02_on.mdl",
		transform = {Vector(0, 0, -40), Angle(0,0,0), Vector(0.5,0.5,0.5)},
		color = sa_laser_color,
	},
	{
		transform = {Vector(0,0,-43),Angle(0,0,0),Vector(40,40,40)},
		sprite = sa_rocket_laserglow,
		color = sa_laser_color,
		translucent = true,
	},
}

local sa_lasercannon_body = {
	{
		-- main body
		model = "models/props_wasteland/laundry_basket001.mdl",
		transform = {Vector(11.5, -0.3, 0), Angle(0,90,0), Vector(0.48,0.48,0.3)},
		
		-- circular lights
		children = {
			{
				transform = {Vector(0, 0, 0), Angle(90,45,0), Vector(1,1,1)},
				children = sa_laser_dotlight,
			},
			{
				transform = {Vector(0, 0, 0), Angle(90,45+90,0), Vector(1,1,1)},
				children = sa_laser_dotlight,
			},
			{
				transform = {Vector(0, 0, 0), Angle(90,45+180,0), Vector(1,1,1)},
				children = sa_laser_dotlight,
			},
			{
				transform = {Vector(0, 0, 0), Angle(90,45-90,0), Vector(1,1,1)},
				children = sa_laser_dotlight,
			},
		},
	},
	{
		-- back
		model = "models/props_wasteland/light_spotlight02_lamp.mdl",
		transform = {Vector(11.5, -0.5, 10), Angle(90,90,0), Vector(1,2.5,2.5)},
		color = Color(230, 210, 190, 255),
	},
	{
		-- barrel
		model = "models/props_wasteland/buoy01.mdl",
		transform = {Vector(11.5, -0.5, -15), Angle(180,90,0), Vector(0.4,0.4,0.2)},
		children = {
			{
				model = "models/props_wasteland/coolingtank02.mdl",
				transform = {Vector(0, 0, 20), Angle(0,90,0), Vector(0.2,0.2,0.32)},
				color = sa_laser_color,
				selfillum = true,
			},
			{
				model = "models/props_rooftop/roof_vent001.mdl",
				transform = {Vector(0, 0, 82), Angle(0,90,0), Vector(1.5,1.5,1.5)},
			},
			{
				model = "models/hunter/tubes/circle2x2.mdl",
				transform = {Vector(0, 0, 146), Angle(0,0,0), Vector(0.1,0.1,0.1)},
				outputname="laser_muzzle",
				material = "models/debug/debugwhite",
				color = sa_laser_color,
				selfillum = true,
			},
			{
				transform = {Vector(0,0,150),Angle(0,0,0),Vector(40,40,40)},
				sprite = sa_rocket_laserglow,
				color = sa_laser_color,
				translucent = true,
			},
		},
	},
	
	-- barrel glow
	{
		transform = {Vector(11.5,-0.5,-18),Angle(0,0,0),Vector(40,40,40)},
		sprite = sa_rocket_laserglow,
		color = sa_laser_color,
		translucent = true,
	},
	{
		transform = {Vector(11.5,-0.5,-24),Angle(0,0,0),Vector(40,40,40)},
		sprite = sa_rocket_laserglow,
		color = sa_laser_color,
		translucent = true,
	},
	{
		transform = {Vector(11.5,-0.5,-30),Angle(0,0,0),Vector(40,40,40)},
		sprite = sa_rocket_laserglow,
		color = sa_laser_color,
		translucent = true,
	},
}



multimodel.Register("sa_rbt_laser", {
	{
		transform = {Vector(-11,0,0), Angle(0,0,0), Vector(1,1,1)},
		
		-- circular lights
		children = sa_lasercannon_body
	}
})

end

function newsa:Initialize(entity,owner)
	if CLIENT then
		entity.mm=multimodel.CreateInstance("sa_rbt_laser")
	end
	entity.chargesound=CreateSound(entity,"SuitRecharge.ChargingLoop")
	
end


function newsa:Deinitialize(entity,owner)
	if entity.chargesound then
		entity.chargesound:Stop()
	end
end



newsa.NextAttackDelay=1
newsa.MaxCharge = 100	--equals to max damage too in this case
newsa.ChargeRate = 5	--reach 100 in 5 seconds

function newsa:ResetVars(entity,owner)
	entity:SetActionBool1(false)	--charging
	entity:SetActionFloat1(CurTime()+self.NextAttackDelay)
	entity:SetActionFloat2(0)	--charge
end


function newsa:Think(entity,owner,mv)
	entity:SetActionBool1(mv:KeyDown(entity:GetKey()) and entity:GetActionFloat1()<CurTime())

	if mv:KeyDown(entity:GetKey()) and entity:GetActionFloat1()<CurTime() then
		--we're clearly charging, do it if we can
		
		--we need to charge for self.MaxCharge/self.ChargeRate every second

		if entity.chargesound then
			local extrapitch=Lerp(entity:GetActionFloat2()/self.MaxCharge,0,50)
			entity.chargesound:PlayEx(0.6,100+extrapitch)
		end
		
		if entity:GetActionFloat2() < self.MaxCharge then
			local current=entity:GetActionFloat2()
			local add=(self.MaxCharge/self.ChargeRate)*((self.MaxCharge/self.ChargeRate)*engine.TickInterval())
			local finaladd=math.Clamp(current+add,0,self.MaxCharge)
			entity:SetActionFloat2(finaladd)
			
		end
		
	else
		if entity.chargesound then
			entity.chargesound:Stop()
		end
		if entity:GetActionFloat2()>0 then
			--release the shot, reset vars and add a cooldown
			local tr=nil
			
			
			--for i=0,2 do 
			tr=self:DoLaserTrace(entity,owner,owner:GetShootPos(),owner:GetAimVector())
			
			
			if IsFirstTimePredicted() then
				local effectdata = EffectData()
				effectdata:SetEntity(owner)
				effectdata:SetScale(entity:GetActionFloat2())
				--effectdata:SetStart( owner:GetShootPos() )
				effectdata:SetOrigin( tr.HitPos )
				--util.Effect( "salaserbeam", effectdata )
				owner:EmitSound("PropJeep.FireCannon")
			end
			--end
			
			if SERVER and IsValid(tr.Entity) then
				local hitent=tr.Entity
				local dmgnf=DamageInfo()
				local dmg=5+Lerp(entity:GetActionFloat2()/self.MaxCharge,5,105)
				dmgnf:SetAttacker(owner)
				dmgnf:SetDamage(dmg)
				dmgnf:SetInflictor(entity)
				dmgnf:SetDamageType(DMG_SHOCK)
				dmgnf:SetDamagePosition(owner:GetShootPos())
				dmgnf:SetDamageForce(owner:GetAimVector() * dmg * 20)
				hitent:TakeDamageInfo(dmgnf)
			end
			
			
			
			entity:SetActionFloat2(0)
			entity:SetActionFloat1(CurTime()+self.NextAttackDelay)
	
		end
		
	end


end

function newsa:DrawWorldModel(entity,owner)
	if not owner.Atch then return end
	
	local atchstr=entity:GetReservedString()
	
	local atchtab=owner.Atch[atchstr]
	if not atchtab then return end
	
	multimodel.SetOutputTarget(owner.LaserAtch)
	multimodel.Draw(entity.mm,owner,{origin=atchtab.pos,angles=atchtab.ang})
	multimodel.SetOutputTarget(nil)
	--self:DrawEffects(entity,owner)
end

function newsa:DoLaserTrace(entity,owner,pos,normal)
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos + ( normal * 16000 )
	tracedata.filter = owner
	tracedata.mins =  Vector( -4, -4, -4 )
	tracedata.maxs =  Vector( 4, 4, 4 )
	
	local tr = util.TraceHull( tracedata )
	return tr
end



