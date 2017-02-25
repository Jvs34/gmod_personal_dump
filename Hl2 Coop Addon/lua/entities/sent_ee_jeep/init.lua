AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')
----------variables------------
ENT.StartDel = CurTime()
-----------FUEL INTAKE
ENT.FuelIntakeConnected = 0
ENT.FuelIntakeEnt = NULL
ENT.CheckFuelIntakeDel = CurTime()
-----------FUEL INTAKE
-----------TURBO  (don't ask me why the variables are called nos)
ENT.NosConnected = 0
ENT.MoveTheModel = 0
ENT.NosValid = NULL
ENT.NosConMessage = 0
ENT.NosNotConMessage = 0
ENT.NosIsUsed = 0

----------TURBO

-----------VEHICLE
ENT.VehicleConnected = 0
ENT.VehicleValid = NULL
ENT.VehiclePhys = NULL
-----------VEHICLE

-----------FUEL
ENT.FuelValid = NULL
ENT.MakeStopSound = 0
-----------FUEL

-----------RADIATOR
ENT.RadiatorConnected = 0
ENT.RadiatorValid = NULL
ENT.RadiatorPhys = NULL
-----------RADIATOR

-----------BATTERY
ENT.BatteryConnected = 0
ENT.BatteryValid = NULL
ENT.BatteryPhys = NULL
-----------BATTERY

-----------RADIO
ENT.RadioConnected = 0
ENT.RadioValid = NULL
ENT.RadioPhys = NULL
-----------RADIO

-----------CAR HORN
ENT.CarHornConnected = 0
ENT.CarHornValid = NULL
-----------CAR HORN
-----------Misc
ENT.Force = 6000
ENT.SteerForce = 3373
ENT.OnOrOff = 0

ENT.IsThereOwner = 0

ENT.BreakPower = 0.5 
ENT.AutoStraight =  0.0002

ENT.ForSound = 0
ENT.BackSound = 0
ENT.Fuel = 500
ENT.MaxFuel = 500
ENT.FuelTankEnt = NULL
ENT.FuelTankEnt2 = NULL
ENT.EngineHeat = 255
ENT.EngineDestroyed = 0
ENT.HornDelay = CurTime()
-----------Misc end
----Sounds
 ENT.FirstGear = NULL 
 ENT.ReverseGear = NULL
 ENT.TomGang = NULL
 ENT.NOS = NULL
 ENT.EngineOff = NULL
 ENT.EngineOverheat = NULL
 ENT.FuelingUp = NULL
 ENT.FuelingReady = NULL

 ENT.FirstGearOnce = 0 
 ENT.FirstGearLoopOnce = 0 
 ENT.ReverseGearOnce = 0
 ENT.TomGangOnce = 0
 ENT.NosOnce = 0
 ENT.EngineOffOnce = 0

--Radio music
ENT.RadioSong1 = NULL
ENT.RadioSong2 = NULL
ENT.RadioSong3 = NULL
ENT.RadioSong4 = NULL
ENT.RadioSong5 = NULL
ENT.RadioSong6 = NULL
ENT.RadioSong7 = NULL
ENT.RadioSong8 = NULL

ENT.SongNr = 0
ENT.UsingRopes = 1
ENT.EngineSound = 1

ENT.Xpos = 100
ENT.Ypos = 0
ENT.Zpos = 0
ENT.XYZangle = NULL

------------------------------------VARIABLES END

function ENT:Initialize()

	self.Entity:SetModel("models/vehicle/vehicle_engine_block.mdl")
	self.Entity:SetColor(255, 255, 255, 255)
	self.Entity:SetOwner(self.Owner)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)

	self.Entity:SetSolid(SOLID_VPHYSICS)	
    local phys = self.Entity:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end



 self.FirstGear = CreateSound(self.Entity,"vehicles/v8/v8_firstgear_rev_loop1.wav") 
 self.ReverseGear = CreateSound(self.Entity,"vehicles/v8/fourth_cruise_loop2.wav") 
 self.TomGang = CreateSound(self.Entity,"vehicles/v8/v8_idle_loop1.wav")
 self.NOS = CreateSound(self.Entity,"vehicles/v8/v8_turbo_on_loop1.wav")
 self.EngineOff = CreateSound(self.Entity,"vehicles/v8/v8_stop1.wav")
 self.EngineOverheat = CreateSound(self.Entity,"vehicles/digger_grinder_stop1.wav")
 self.FuelingUp = CreateSound(self.Entity,"ambient/water/leak_1.wav")
 self.FuelingReady = CreateSound(self.Entity,"buttons/button10.wav")

--

self.Entity:SetNetworkedInt("SakariasFuelIntake", 0 ) 
self.Entity:SetNetworkedInt( "IsConnectedWithFuelIntake", 0)
	self.Entity.force	 = self.Force / 2
	self.Entity.Steering = self.SteerForce
	self.Entity.breakpower = self.BreakPower
	self.Entity.autostraight = self.AutoStraight
	self.Entity.ropes	 = self.UsingRopes
	self.Entity.sound	 = self.EngineSound
	self.Entity.enginexpos = self.Xpos
	self.Entity.engineypos = self.Ypos
	self.Entity.enginezpos = self.Zpos	
	self.Xpos = self.Xpos * -1
end
-------------STOOL FUNCTIONS
function ENT:SetForceAng( XXpos, YYpos, ZZpos )

	if XXpos and YYpos and ZZpos then
	self.Xpos = XXpos * -1
	self.Ypos = YYpos * -1
	self.Zpos = ZZpos * -1	

	end

end

function ENT:SetForce( force )

	if (force) then	
			self.Force = force
	end

end

function ENT:SetSteering( steering )
	if steering then
		self.SteerForce = steering
	end
end

function ENT:SetAutoStraight( autostraight )
	if autostraight then
		self.AutoStraight = autostraight
	end
end

function ENT:SetBreakPower( breakpower )
	if breakpower then
		self.BreakPower = breakpower
	end
end

function ENT:SetSound( sound )
	if (sound) then	
			 self.EngineSound = sound	
	end
end
----------------Applying force to the engine
function ENT:PhysicsUpdate( physics )
	if self.OnOrOff == 1 and self.IsThereOwner == 1 then
		local phys = self.Entity:GetPhysicsObject()

			--------------------FORWARD
			if self.Entity.Owner:KeyDown( IN_FORWARD ) and self.BackSound == 0 then
					local forward = self.XYZangle
					local speed = phys:GetVelocity()
					speed = (speed * self.AutoStraight) + forward
					speed = speed:Normalize()
					phys:ApplyForceCenter(speed * self.Force)	
			end
			--------------------
			--------------------TURBO
			if( self.Entity.Owner:KeyDown( IN_SPEED ) and self.BackSound == 0 and self.ForSound == 1 ) then	
					local forward = self.XYZangle
					local speed = phys:GetVelocity()
					speed = (speed * self.AutoStraight) + forward
					speed = speed:Normalize()				
					phys:ApplyForceCenter(speed * self.Force)	
			end
			--------------------
			--------------------BACK
			if self.Entity.Owner:KeyDown( IN_BACK ) and self.ForSound == 0 and self.NosIsUsed == 0 then
					local forward = self.XYZangle
					local speed = phys:GetVelocity()
					phys:ApplyForceCenter( forward * (self.Force * (self.BreakPower * -1) ) )
			end
			--------------------
			--------------------RIGHT
			if self.Entity.Owner:KeyDown( IN_MOVERIGHT ) then
				phys:AddAngleVelocity(Vector(0,0, (self.SteerForce * -1) ))
			end
			--------------------
			--------------------LEFT
			if self.Entity.Owner:KeyDown( IN_MOVELEFT) then
				phys:AddAngleVelocity(Vector(0,0,self.SteerForce))
			end
			--------------------
	end
end
-------------------------------------------THINK
function ENT:Think()
	self.Entity:SetNWInt( "IsItOn", self.OnOrOff )
	self.Entity:SetNWInt( "IsNosConnected", self.NosConnected )
	self.Entity:SetNWInt( "IsBatteryConnected", self.BatteryConnected )

---Calculating force angle

	local EngineAngPos 		= (self.Entity:GetPos()) + ( ((self.Entity:GetForward()) * self.Xpos) ) + ( ((self.Entity:GetRight()) * self.Ypos) ) + ( ((self.Entity:GetUp()) * self.Zpos) )	
	local EngineAngle		= self.Entity:GetPos() - EngineAngPos
	EngineAngle:Normalize()
	
	self.XYZangle = EngineAngle
----	
	
--If the engine gets under water i will stop
if self.Entity:WaterLevel() > 0 then
self.OnOrOff = 0
end





self.Entity:SetNetworkedInt( "SakariasMaxFuel", self.MaxFuel )
self.Entity:SetNetworkedInt( "SakariasCurFuel", self.Fuel )


self.MaxFuel = 5000


--Checking if the vehicle is connected
if not (self.VehicleValid:IsValid()) then 
	self.VehicleConnected = 0
end

if self.Entity.Owner and self.Entity.Owner:IsValid() && self.Entity.Owner:InVehicle() then
self.IsThereOwner = 1
else
self.IsThereOwner = 0
end

if self.IsThereOwner == 0 then
self.OnOrOff = 0
end

if self.IsThereOwner == 1 then
if self.Entity.Owner:InVehicle() and not ( self.Entity.Owner:KeyDown( IN_SPEED ) ) then
self.NosIsUsed = 0
self.NosOnce = 0
self.NOS:Stop()
self.NOSSound = 0
self.ForSound = 1
self.FirstGearOnce = 0
--self.FirstGear:Stop()
end
-------
if not ( self.Entity.Owner:KeyDown( IN_FORWARD ) ) then
self.ForSound = 0
self.FirstGearOnce = 0
self.NOS:Stop()
self.NosOnce = 0
 self.FirstGear:Stop()
end
-------
if not ( self.Entity.Owner:KeyDown( IN_BACK ) ) then
self.BackSound = 0
self.ReverseGearOnce = 0
self.ReverseGear:Stop() 
end


if ( self.Entity.Owner:KeyDown( IN_SPEED ) ) and not ( self.Entity.Owner:KeyDown( IN_FORWARD ) ) then 
self.NOSSound = 0
end
else
	return
end
--------------------
--------------------IF THE ENGINE IS ON
--------------------MAKE SOUNDS

--If the engine isn't on some sounds will stop
---TomGang
if self.OnOrOff == 0 then
 self.TomGang:Stop()
    self.FirstGear:Stop()
	self.ReverseGear:Stop()
	self.NOS:Stop()
	self.TomGangOnce = 0
end


--Checkign if the player is in the right vehicle
if self.IsThereOwner == 1 then
if self.VehicleConnected == 0 or not (self.Entity.Owner:InVehicle()) then
self.OnOrOff = 0
end
end

--If the engine is on

--If the forward sound and the back sound aren't played the TomGang sound should be played. 
if self.ForSound == 0 and self.BackSound == 0 and self.TomGangOnce == 0 and self.EngineSound == 1 then
	self.TomGangOnce = 1
	self.TomGang:Play()
end
---
---Forward Sound
if self.ForSound == 1 and  self.FirstGearOnce == 0 and self.NOSSound == 0 and self.BackSound == 0 and self.EngineSound == 1 then 
	self.TomGang:Stop()
	self.FirstGearOnce = 1
    self.FirstGear:Play()
end
---
---Turbo sound
if self.NOSSound == 1 and self.NosOnce == 0 and self.EngineSound == 1 then
	self.TomGang:Stop()
	self.FirstGear:Stop()
	self.NosOnce = 1
	self.NOS:Play()
end
---
---Backward Sound
if self.BackSound == 1 and self.ReverseGearOnce == 0 and self.NOSSound == 0 and self.EngineSound == 1 then
	self.TomGang:Stop()
	self.ReverseGearOnce = 1
	self.ReverseGear:Play()
	self.ReverseGearOnce = 0
	self.BackSound = 0
end
---
if self.Entity.Owner:KeyDown( IN_FORWARD ) and self.Entity.Owner:KeyDown( IN_BACK ) and self.TomGangOnce == 0 and self.FirstGearOnce == 0 and self.EngineSound == 1 then
self.ReverseGear:Stop()
	self.TomGangOnce = 1
	self.TomGang:Play()
end
--------------------
--Checking if the buttons are pressed
--------------------CAR HORN
--------------------
--------------------FORWARD
if self.Entity.Owner:KeyDown( IN_FORWARD ) and self.BackSound == 0 then
	self.TomGangOnce = 0
	self.ForSound = 1
	
		local phys = self.Entity:GetPhysicsObject()
		phys:Wake()	
	
end
--------------------
--------------------TURBO
if( self.Entity.Owner:KeyDown( IN_SPEED ) and self.BackSound == 0 and self.ForSound == 1) then
	self.NosIsUsed = 1
	self.TomGangOnce = 0
	self.NOSSound = 1
	
		local phys = self.Entity:GetPhysicsObject()
		phys:Wake()	
	
end
--------------------
--------------------BACK
if self.Entity.Owner:KeyDown( IN_BACK ) and self.ForSound == 0 and self.NosIsUsed == 0 then
	self.Entity:SetNWInt( "IsBatteryConnected", self.BatteryConnected )
	self.TomGangOnce = 0
	self.BackSound = 1
	
		local phys = self.Entity:GetPhysicsObject()
		phys:Wake()	
	
end
--------------------
--------------------IF THE ENGINE IS ON END
--------------------TOGGLE ENGINE ON AND OFF
--If you press both walk and duck the engine should start
if self.IsThereOwner == 1 then
if (self.Entity.Owner:KeyDownLast( IN_JUMP ) ) and self.VehicleConnected == 1 and self.StartDel < CurTime() then
if self.Entity.Owner:GetVehicle() == self.VehicleValid then
self.StartDel = CurTime() + 1

		self.OnOrOff = self.OnOrOff + 1
		
			if self.OnOrOff > 1 then 
			self.OnOrOff = 0 
			self.DoItOnce = 0
			end
end
end
end

if self.OnOrOff == 1 then
self.EngineOffOnce = 0
end

if self.Fuel < 0 then
self.OnOrOff = 0
end

if self.OnOrOff == 0 and self.EngineOffOnce == 0 and self.EngineSound == 1 then
 self.EngineOff:Stop()
 self.EngineOff:Play()
 self.EngineOffOnce = 1
end
--------------------
--------------------
end
--------------------


--This function will stop all sounds if the engine is removed
--Why? because the sounds will stay if i don't even if the engine is removed. 
function ENT:OnRemove()
 self.FirstGear:Stop()
 self.ReverseGear:Stop()
 self.TomGang:Stop()
 self.NOS:Stop()
 self.EngineOff:Stop()
 self.EngineOverheat:Stop()
 self.FuelingUp:Stop()
 self.FuelingReady:Stop()


--If the engine is removed and the turbo is connected it will remove it aswell.
--The turbo is nocollided so you couldn't connect it to another engine anyway.
if self.NosConnected == 1 then
self.NosValid:Remove()
end
end
