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



local ClassName="sent_kartthing"
local ENT={}

ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.RenderGroup     = RENDERGROUP_OPAQUE
ENT.PrintName        = "Kartttttttt"
ENT.Author="Jvs"
ENT.Spawnable = true  
ENT.AdminOnly = true  
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
		
		self:SetDTEyeAngles(angle_zero)
		self:SetDTGroundEntity(NULL)

		self:SetSteer(0)
		self:SetThrottle(0)
		
		self:EnableCustomCollisions(true)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid( SOLID_BBOX )
		self:PhysicsInitBox( self:FakeOBBMins() , self:FakeOBBMaxs() )
		self:SetCollisionBounds( self:FakeOBBMins() , self:FakeOBBMaxs() )
		
		self:MakePhysicsObjectAShadow( )

		if IsValid(self:GetPhysicsObject())then
			self:GetPhysicsObject():SetMass(500)
			self:GetPhysicsObject():SetMaterial("flesh")
		end
		
	else

		
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
		
		if SERVER then
			self:GetSAC().DefaultKeys={IN_ATTACK,IN_ATTACK2,IN_JUMP,IN_GRENADE}
			--[[
			local left=self:GetSAC():CreateSpecialaction("sa_rbt_laser",0)
			if IsValid(left) then
				left:SetReservedString("leftarm")
			end
			
			local right=self:GetSAC():CreateSpecialaction("sa_rbt_laser",1)
			
			if IsValid(right) then
				right:SetReservedString("rightarm")
			end
			]]
		end
		
	end
	
	
	
end





function ENT:SetupDataTables()
	
	self:NetworkVar("String",0,"OwnerModel")
	self:NetworkVar("Entity",0,"DTGroundEntity")
	self:NetworkVar("Angle",0,"DTEyeAngles")
	
	self:NetworkVar("Float",0,"Steer")
	self:NetworkVar("Float",1,"Throttle")
	
	self:NetworkVar("Entity",1,"SAC")
end

function ENT:FakeOBBMins()
	return Vector(-40,-40,0)
end

function ENT:FakeOBBMaxs()
	return Vector(40,40,60)
end
 
if CLIENT then

	multimodel.Register("GoKart_mm", {
		{
			transform = {Vector(-14,0,18), Angle(0,-90,0), Vector(1,1,1)},
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
								self.transform[2].r = ent:GetSteer()*20
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
									Think=function(self, time, ent)
										self.transform[2].p = self.transform[2].p + ent:GetCurSpeed()*FrameTime()
									end,
								},
								{
									model = "models/xeon133/racewheel/race-wheel-30.mdl",
									transform = {Vector(25,0,0), Angle(0,-90,0), Vector(0.7,0.7,0.7)},
									Think=function(self, time, ent)
										self.transform[2].p = self.transform[2].p + ent:GetCurSpeed()*FrameTime()*-1
									end,
								}
							}
						},
						{--this one does tho
							model = "models/mechanics/solid_steel/type_b_2_4.mdl",
							transform = {Vector(0,24,0), Angle(0,0,0), Vector(1,1,1)},
							Think=function(self, time, ent)
								self.transform[2].y = ent:GetSteer()*20
							end,
							
							children={
								{
									model = "models/xeon133/racewheel/race-wheel-30.mdl",
									transform = {Vector(-25,0,0), Angle(0,90,0), Vector(0.7,0.7,0.7)},
									Think=function(self, time, ent)
										self.transform[2].p = self.transform[2].p + ent:GetCurSpeed()*FrameTime()
									end,
							
								},
								{
									model = "models/xeon133/racewheel/race-wheel-30.mdl",
									transform = {Vector(25,0,0), Angle(0,-90,0), Vector(0.7,0.7,0.7)},
									Think=function(self, time, ent)
										self.transform[2].p = self.transform[2].p + ent:GetCurSpeed()*FrameTime()*-1
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
end



function ENT:DrawTranslucent()
	self:Draw(1)
end

function ENT:Draw(flags)
	self:SetRenderBounds(self:FakeOBBMins(),self:FakeOBBMaxs())
	--we usually draw it
	if not self.mm then
		self.mm = multimodel.CreateInstance("GoKart_mm")
	end
	--debugoverlay.BoxAngles( self:GetPos(),self:FakeOBBMins() , self:FakeOBBMaxs(), angle_zero, 0.01, Color( 255, 255, 0, 100 ) )
	
	debugoverlay.Axis( self:SEyePos(),angle_zero, 5,0.01,true )
	
	
	
	if not self.Atch then
		self.Atch={}
	end
	
	if self.mm then 
		multimodel.SetOutputTarget(self.Atch)
		multimodel.Draw(self.mm, self)
		multimodel.DoFrameAdvance(self.mm, CurTime(), self)
		multimodel.SetOutputTarget(nil)
	end
	

	if IsValid(self.PlaceHolder) and self.Atch.seatpos and IsValid(self:GetOwner()) then	--self:GetOwner()~=LocalPlayer()				then
		if self.PlaceHolder:GetModel()~= self:GetOwnerModel() then
			self.PlaceHolder:SetModel(self:GetOwnerModel())
			self.PlaceHolder:SetupBones()
		end
		
		self.PlaceHolder:ResetSequence( self.PlaceHolder:LookupSequence( "drive_jeep" ) )
		self.PlaceHolder:SetRenderOrigin(self.Atch.seatpos.pos)
		self.PlaceHolder:SetRenderAngles(self.Atch.seatpos.ang)
		self.PlaceHolder:SetPoseParameter( "vehicle_steer", self:GetSteer() * -0.5  )
		self.PlaceHolder:FrameAdvance(FrameTime())
		self.PlaceHolder:DrawModel()
		
	end
	
	if IsValid(self:GetSAC()) then
		self:GetSAC():DoSpecialAction("DrawWorldModel")
	end
	
end

ENT.EyeOffset=Vector(0,0,60)
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

function ENT:GetCameraPos()
	
end

local function sign(x)
	return x < 0 and -1 or 1
end


ENT.SteerDecayRate=2
ENT.SteerRate=5
function ENT:HandleSteer(mv,cmd)
	local oldval=self:GetSteer()
	local val=0
	
	
	if mv:KeyDown(IN_MOVELEFT) then	
		val=self.SteerRate*FrameTime()
	elseif mv:KeyDown(IN_MOVERIGHT) then	
		val=self.SteerRate*-1*FrameTime()
	else
		--decay it
		val=math.Approach( oldval, 0, self.SteerDecayRate*FrameTime() )-oldval
	end
	self:SetSteer(math.Clamp(oldval+val,-1,1))
end

ENT.ThrottleDecayRate=1
ENT.ThrottleRate=2
function ENT:HandleThrottle(mv,cmd)
	local oldval=self:GetThrottle()
	local val=0
	if mv:KeyDown(IN_FORWARD) then	
		val=self.ThrottleRate*FrameTime()
	elseif mv:KeyDown(IN_BACK) then	
		val=self.ThrottleRate*-1*FrameTime()
	else
		--decay it
		val=math.Approach( oldval, 0, self.ThrottleDecayRate*FrameTime() )-oldval
	end
	self:SetThrottle(math.Clamp(oldval+val,-1,1))
end

function ENT:OnTakeDamage(dmginfo)
	if IsValid(self:GetOwner()) then
		self:GetOwner():TakeDamageInfo(dmginfo)
	end
end

function ENT:GetGravityVector()
	return self.GravityVector or Vector(0, 0, -800)
end

function ENT:SetGravityVector(v)
	self.GravityVector = v or Vector(0, 0, -800)
end

function ENT:GetJumpPower()
	return 300
end

function ENT:GetStepSize()
	return 32
end

function ENT:GetMaxSpeed()
	return 400
end

function ENT:GetCurSpeed()
	return self:GetMaxSpeed() * self:GetThrottle() 
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




function ENT:Use(act)
	self:StartDriving(act)
end

function ENT:StartDriving(act)
	if not IsValid(self:GetOwner()) and IsValid(act) and act:IsPlayer() and not act:IsDrivingEntity() then
		drive.PlayerStartDriving( act, self, "drive_kart" )
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
		--self:HandleAnimations()
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
	self.SurfaceFriction = 5

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

drive.Register( "drive_kart", 
{
	--
	-- Called on creation
	--
	Init = function( self ) end,
	
	CalcView =  function( self, view )
		if not IsValid(self.Entity)  then return end
		local eyeang=self.Player:EyeAngles()
		view.origin=self.Entity:SEyePos()
		view.angles=eyeang
		
		
		
	end,
	
	SetupControls = function( self, cmd )				

	end,
	StartMove =  function( self, mv, cmd )

		local ent=self.Entity
		if SERVER then
			self.Player:SetViewEntity(ent)
		end
		self.Player:SetObserverMode( OBS_MODE_CHASE )
		local entity_angle		= self.Entity:GetAngles()--self.Entity:GetAngles()

		entity_angle.p=0
		entity_angle.r=0
		
		--we don't need to pass up the driver yet
		ent:HandleThrottle(mv,cmd)
		ent:HandleSteer(mv,cmd)
		
		local steer=ent.SteerRate*15
		
		if ent:GetThrottle()<0 then
			steer=steer*-1
		end
		
		local steer_angle=Angle(0,ent:GetSteer()*steer,0)*FrameTime()
		
		--[[
			calculate the steer angle by getting the current ent:GetSteer() and increasing or decreasing
			if the player is holding IN_MOVELEFT or IN_MOVERIGHT
		]]
		
		--only apply the steering to the movement if we're actually moving
		
		if ent:GetThrottle()~=0 then
		
			entity_angle=entity_angle+steer_angle
	
		end
		
		mv:SetSideSpeed(0)
		
		mv:SetForwardSpeed(ent:GetCurSpeed())
		
		mv:SetMaxClientSpeed(math.abs(self.Entity:GetCurSpeed()))
		mv:SetMaxSpeed(math.abs(self.Entity:GetCurSpeed()))
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
		--ent:SetDTEyeAngles(self.Player:EyeAngles())
		
		if IsValid(ent:GetSAC()) then
			if ent:GetSAC():GetNextTick() < CurTime() then
				ent:GetSAC():DoSpecialAction("AttackThink",mv)
				ent:GetSAC():DoSpecialAction("Think",mv)
				ent:GetSAC():SetNextTick(CurTime()+ent:GetSAC():GetTickRate())
			end
		end
	end


}, "drive_base" )





