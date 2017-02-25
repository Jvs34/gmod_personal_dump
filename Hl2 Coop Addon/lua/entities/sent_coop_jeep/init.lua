AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" );
include( "shared.lua" );
//DAVANTI
//ruota sinistra
//OFFSET 47.3346 20.4640 -0.7070
//ruota destra
//OFFSET 47.3346 -20.4640 -0.7070

//DIETRO
//ruota sinistra
//OFFSET -55.4775 19.9722 -0.7070
//ruota sinistra
//OFFSET -55.4775 -19.9722 -0.7070

//INTERNO
//sedile guidatore
//OFFSET -12.4621 12.2407 2.1975

//sedile passeggero
//OFFSET -12.4621 -12.2407 2.1975

//posizione motore
//OFFSET 40.9808 0 17.4865

//posizione cassa.
//OFFSET -54.7417 0.8822 23.2828

//posizione torretta
//OFFSET 22.0662 -27.3955 24.5242

//posizione monitor
//OFFSET 5.8911 0 2.1976

ENT.WheelModel=false;//true for new tires,false for old

function ENT:SpawnFunction( Player, Trace )

	if ( !Trace.Hit ) then return end
	
	local SpawnPos = Trace.HitPos + ( Trace.HitNormal * 32 );
	
	local Entity = ents.Create( "sent_coop_jeep" );
	Entity:SetPos( SpawnPos );
	Entity:Spawn();
	Entity:Activate();
	Entity:SetPhysicsAttacker( Player );
	Entity.Owner = Player;
	return Entity;
	
end
	local function HandleDriver( vehicle, player )
	return player:SelectWeightedSequence( ACT_HL2MP_SIT)
	end
	
	local function HandlePassenger( vehicle, player )
	return player:SelectWeightedSequence( ACT_HL2MP_SIT)
	end
	
function ENT:Initialize( )

	self:SetModel( "models/offroadframe/model.mdl");
	self:SetUseType( SIMPLE_USE );
	self:SetMoveType( MOVETYPE_VPHYSICS );
	self:PhysicsInit( SOLID_VPHYSICS );
	self:PhysWake();
	
	if(self.WheelModel)then
	self.WheelAng=Angle(0,90,0)
	self.ContAng=Vector(90,0,0)
	self.TireModel="models/xeon133/offroad/Off-road-30.mdl"
	else
	self.WheelAng=Angle(0,0,0)
	self.ContAng=Vector(0,90,0)
	self.TireModel="models/props_vehicles/carparts_wheel01a.mdl"	
	end
	//FRONT
		self.LeftFrontWheel = ents.Create( "prop_physics" )
		self.LeftFrontWheel:SetPos(self:GetPos()+ Vector(47.3346,30.4640,-0.7070))
		self.LeftFrontWheel:SetModel(self.TireModel)	
		self.LeftFrontWheel:SetAngles(self.WheelAng)
		self.LeftFrontWheel:Spawn()
		constraint.Axis( self, self.LeftFrontWheel, 0, 0,Vector(47.3346,30.4640,-0.7070), self.ContAng  , 0, 0, 0, 1 )	
		
		self.RightFrontWheel = ents.Create( "prop_physics" )
		self.RightFrontWheel:SetPos(self:GetPos()+ Vector(47.3346,-30.4640,-0.7070))
		self.RightFrontWheel:SetModel(self.TireModel)	
		self.RightFrontWheel:SetAngles(self.WheelAng)
		self.RightFrontWheel:Spawn()
		constraint.Axis( self, self.RightFrontWheel, 0, 0,Vector(47.3346,-30.4640,-0.7070), self.ContAng  , 0, 0, 0, 1 )	
		//REAR
		self.LeftRearWheel = ents.Create( "prop_physics" )
		self.LeftRearWheel:SetPos(self:GetPos()+ Vector(-55.4775,29.9722,-0.7070))
		self.LeftRearWheel:SetModel(self.TireModel)	
		self.LeftRearWheel:SetAngles(self.WheelAng)
		self.LeftRearWheel:Spawn()
		constraint.Axis( self, self.LeftRearWheel, 0, 0,Vector(-55.4775,29.9722,-0.7070), self.ContAng  , 0, 0, 0, 1 )	
		
		self.RightRearWheel = ents.Create( "prop_physics" )
		self.RightRearWheel:SetPos(self:GetPos()+ Vector(-55.4775,-29.9722,-0.7070))
		self.RightRearWheel:SetModel(self.TireModel)	
		self.RightRearWheel:SetAngles(self.WheelAng)
		self.RightRearWheel:Spawn()
		constraint.Axis( self, self.RightRearWheel, 0, 0,Vector(-55.4775,-29.9722,-0.7070), self.ContAng , 0, 0, 0, 1 )	
		

		
		self.DriverSeat = ents.Create("prop_vehicle_prisoner_pod")  
		self.DriverSeat:SetKeyValue("vehiclescript","scripts/vehicles/prisoner_pod.txt")  
		self.DriverSeat:SetModel( "models/nova/airboat_seat.mdl" ) 
		self.DriverSeat:SetPos( self:GetPos()+Vector(-12.4621,12.2407,2.1975) )  
		self.DriverSeat:SetAngles(self.Entity:GetAngles() + Angle(0,-90,0))
		self.DriverSeat:SetKeyValue("limitview", "0")  
		self.DriverSeat:Spawn()  
		self.DriverSeat.HandleAnimation=HandleDriver;
		constraint.Weld(self,self.DriverSeat,0,0,0,true)
		
		self.PassengerSeat = ents.Create("prop_vehicle_prisoner_pod")  
		self.PassengerSeat:SetKeyValue("vehiclescript","scripts/vehicles/prisoner_pod.txt")  
		self.PassengerSeat:SetModel( "models/nova/airboat_seat.mdl" ) 
		self.PassengerSeat:SetPos( self:GetPos()+Vector(-12.4621,-12.2407,2.1975) )  
		self.PassengerSeat:SetAngles(self.Entity:GetAngles() + Angle(0,-90,0))
		self.PassengerSeat:SetKeyValue("limitview", "0")  
		self.PassengerSeat:Spawn()  
		self.PassengerSeat.HandleAnimation=HandlePassenger;
		constraint.Weld(self,self.PassengerSeat,0,0,0,true)
		
		
		self.Engine = ents.Create( "sent_ee_jeep" )
		self.Engine:SetPos(self:GetPos()+ Vector(40.9808,0,12.4865))
		self.Engine:Spawn()
		self.Engine.Owner=self.Owner;
		self.Engine.Entity.Owner=self.Owner;
			self.Engine.VehicleValid = self.DriverSeat
			self.Engine.VehicleConnected = 1
			self.Engine.Pod = self.DriverSeat
			self.Engine.VehicleValid.ConnectedEngine = self.Engine.Entity
		constraint.Weld(self,self.Engine,0,0,0,true)
		
		self.CrateSpawn = ents.Create("info_target")  
		self.CrateSpawn:SetPos(self:GetPos() + Vector(-54.7417,0,24.2828)  )
		self.CrateSpawn:Spawn()  
		self.CrateSpawn:SetParent(self);
		
		self.Turret = ents.Create("sent_turret_airboat")  
		self.Turret:SetPos(self:GetPos() + Vector(22.0662,-27.3955,24.5242)  )
		self.Turret:Spawn()  
		self.Turret:SetParent(self);
		
		self.Monitor = ents.Create( "prop_physics" )
		self.Monitor:SetPos(self:GetPos()+ Vector(5.8911,0,2.1976))
		self.Monitor:SetModel("models/kobilica/wiremonitorbig.mdl")	
		self.Monitor:SetAngles(Angle(25+180,0,180))
		self.Monitor:Spawn()
		constraint.Weld(self,self.Monitor,0,0,0,true)
		self:SetNWEntity("monitor",self.Monitor)
		self:CreateCrate(true)
		self:DeleteOnRemove(self.LeftFrontWheel)
		self:DeleteOnRemove(self.RightFrontWheel)
		self:DeleteOnRemove(self.LeftRearWheel)
		self:DeleteOnRemove(self.RightRearWheel)
		
		self:DeleteOnRemove(self.Engine)
		self:DeleteOnRemove(self.DriverSeat)
		self:DeleteOnRemove(self.PassengerSeat)
		self:DeleteOnRemove(self.Turret)
		self:DeleteOnRemove(self.CrateSpawn)
		self:DeleteOnRemove(self.Monitor)
end


function ENT:OnTakeDamage(dmg)
	if(!dmg:IsDamageType(DMG_CRUSH) && !dmg:IsDamageType(DMG_BLAST) && dmg:GetInflictor()!=self.Turret)then 
		//don't transfer turret,crush and blast damage,the blast one will be transfered directly to the seats.
		dmg:ScaleDamage(0.5)//scale the damage.
		if IsValid(self.DriverSeat:GetDriver())then self.DriverSeat:GetDriver():TakeDamageInfo(dmg) end;
		if IsValid(self.PassengerSeat:GetDriver())then self.PassengerSeat:GetDriver():TakeDamageInfo(dmg) end;
	end
end

function ENT:CreateCrate(ff) 
		self.Crate = ents.Create("item_item_crate")  
		self.Crate:SetPos(self.CrateSpawn:GetPos() )
		self.Crate:SetAngles(self:GetAngles())
		self.Crate:SetKeyValue("ItemClass", "item_dynamic_resupply")
		local count=1;
		//allright,we will increment the content of the crate if the players are in they'r seats.
		if IsValid(self.DriverSeat:GetDriver())then count=count+1 end;
		if IsValid(self.PassengerSeat:GetDriver())then count=count+1 end;
		self.Crate:SetKeyValue("ItemCount", count)  
		self.Crate:Spawn()  
		self.Crate:Activate()
		if !ff then
		self.Crate:EmitSound("Item.Materialize")
		end
		constraint.Weld(self,self.Crate,0,0,0,true)
		self.NextCrate=CurTime()+5;
		self.CanCrateSpawn=false;
	self:DeleteOnRemove(self.Crate)
end

function FChangeOwner(ply,ent)
	if ent.ConnectedEngine then
	ent:EmitSound("Easy_Engine_Sounds/OpenCloseCarDoor.wav")
    ent.ConnectedEngine.Owner = ply
	end
end

hook.Add("PlayerEnteredVehicle","EEVehicleEntered",FChangeOwner)

function ENT:Think()
	if CLIENT then return end
	if(self.DriverSeat:GetDriver() && IsValid(self.DriverSeat:GetDriver()))then
		self.Entity:SetPhysicsAttacker(self.DriverSeat:GetDriver())
		self:SetNWEntity("driver",self.DriverSeat:GetDriver())
	else
		self.Entity:SetPhysicsAttacker(self)
		self:SetNWEntity("driver",nil)
	end
		
		if(self.PassengerSeat:GetDriver() && IsValid(self.PassengerSeat:GetDriver()) )then
			self.Turret.Owner=self.PassengerSeat:GetDriver()
			self:SetNWEntity("passenger",self.PassengerSeat:GetDriver())
		else
			self.Turret.Owner=nil;
			self:SetNWEntity("passenger",nil)
		end
	
	if !IsValid(self.Crate) && !self.CanCrateSpawn then
		self.NextCrate=CurTime()+5;
		self.CanCrateSpawn=true;
	end
	
	if self.CanCrateSpawn && self.NextCrate<CurTime() then
		self:CreateCrate(false);
	end
end