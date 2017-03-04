AddCSLuaFile()

--[[
]]

DEFINE_BASECLASS( "base_predictedent" )

ENT.Spawnable = true
ENT.PrintName = "Oculus"
ENT.AttachesToPlayer = false

ENT.OculusBounds = {
	Min = Vector( -10 , -10 , -10 ),
	Max = Vector( 10 , 10 , 10 )
}

function ENT:SpawnFunction( ply, tr, ClassName )

	if not tr.Hit then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 36

	local ent = ents.Create( ClassName )
	ent:SetSlotName( ClassName )	--this is the best place to set the slot, don't modify it dynamically ingame
	ent:SetPos( SpawnPos )
	ent:SetAngles( angle_zero )
	ent:Spawn()
	return ent

end

function ENT:Initialize()
	BaseClass.Initialize( self )
	if SERVER then
		self:SetModel( "models/props_wasteland/controlroom_filecabinet001a.mdl" )
		
		self:SetAcceleration( 5 )
		self:SetMaxSpeed( 500 )
		self:SetTurnRate( Angle( 200 , 250 , 350 ) )
		
		self:InitPhysics()
	else
		self:InstallHook( "CalcView" , self.HandleCalcView )
	end
	self:DrawShadow( false )
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables( self )
	self:DefineNWVar( "Float" , "Acceleration" , true , nil , 0 , 1000)
	self:DefineNWVar( "Float" , "MaxSpeed" , true , nil ,0 , 1000 )
	self:DefineNWVar( "Angle" , "TurnRate" , true , nil , 0 , 1000 )
	self:DefineNWVar( "Vector" , "Vel" )
end

function ENT:Think()
	
	if CLIENT then
		self:HandleModels()
		self:HandleSounds()
	end
	
	return BaseClass.Think( self )
end

if SERVER then
	
	function ENT:DoInitPhysics()
		self:SetCollisionBounds( self.OculusBounds.Min , self.OculusBounds.Max )
		self:SetMoveType( MOVETYPE_FLYGRAVITY )
		self:SetSolid( SOLID_BBOX )
		self:SetMoveCollide( MOVECOLLIDE_FLY_BOUNCE )
	end
	
	function ENT:DoRemovePhysics()
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_BBOX )
		self:SetMoveCollide( MOVECOLLIDE_DEFAULT )
	end
	
	function ENT:OnInitPhysics()
		self:SetGravity( 1 )
	end
	
	function ENT:OnAttach( ply , forced )
		self:RemovePhysics()
		self:SetOwner( ply )
	end
	
	function ENT:OnDrop( ply , forced )
		self:InitPhysics()
		self:SetOwner( NULL )
	end
	
else
	function ENT:RenderScene( origin, angles, fov )
		if not self:IsCarriedByLocalPlayer() then
			return
		end
		
		cam.Start3D2D( origin, angles, 1 )
			surface.SetDrawColor( 255 , 255 , 255 , 255 )
			surface.DrawRect( 25, 25, 100, 100 )
		cam.End3D2D()
	end
	
	function ENT:HandleCalcView( ply, pos, ang, fov, nearZ, farZ )
		if self:IsCarriedBy( ply ) then
			
			local p , _ = self:GetCameraOffsets()
			
			local plyang = ang + Angle( 0 , 90 , 0 )
			local entang = self:GetAngles()
			
			local _ , finalang = LocalToWorld( vector_origin , plyang , vector_origin , entang )
			
			
			
			local view = {}
			view.origin = p
			view.angles = finalang
			view.fov = fov + 20
			view.znear = 0.5
			view.drawviewer = true
			return view
		end
	end
	
	function ENT:Draw( flags )
		self:DrawModels( flags )
	end
	
	function ENT:DrawModels( flags )
		--[[
		if IsValid( self.PlaneModel ) then
			self.PlaneModel:SetPos( self:GetPos() )
			self.PlaneModel:SetAngles( self:GetAngles() )
			self.PlaneModel:SetupBones()
			self.PlaneModel:DrawModel( flags )
		end
		]]
		--debugoverlay.Axis( self:GetPos(),angle_zero, 5,0.01,true )
	end
	
	function ENT:HandleModels()
		self:SetRenderBounds( self.OculusBounds.Min , self.OculusBounds.Max )
		--[[
		if not IsValid( self.PlaneModel ) then
			self.PlaneModel = ClientsideModel( "models/xqm/jetbody3.mdl" )
			self.PlaneModel:SetNoDraw( true )
			self.PlaneModel.RM = Matrix()
			self.PlaneModel.RM:Scale( Vector( 1 , 1 , 1 ) * 0.15 )
			self.PlaneModel.RM:SetAngles( Angle( 0 , 90 , 0 ) )
			self.PlaneModel.RM:Translate( Vector( 5 , 0 , 0 ) )
			self.PlaneModel:EnableMatrix( "RenderMultiply" , self.PlaneModel.RM )
		end
		]]
	end
	
	function ENT:HandleSounds()
	
	end
	
end

function ENT:PredictedSetupMove( ply , mv )
	
	local oldbtns = mv:GetButtons()
	
	local mvbackup = self:BackupMoveData( mv )
	
	mv:SetButtons( oldbtns )
	mv:SetOrigin( self:GetPos() )
	mv:SetAngles( self:GetAngles() )
	mv:SetMoveAngles( self:GetAngles() )
	mv:SetVelocity( self:GetVel() )
	
	self:PredictedOculusMove( ply , mv )
	
	self:SetNetworkOrigin( mv:GetOrigin() )
	self:SetAngles( mv:GetAngles() )
	self:SetVel( mv:GetVelocity() )
	
		
	self:RestoreMoveData( mv , mvbackup )
	mv:SetButtons( 0 )
end

function ENT:PredictedOculusMove( ply , mv )
	local turn = self:GetTurnRate() * FrameTime()
	
	
	local entity_angle = mv:GetAngles()
	local old_angle = entity_angle * 1
	
	
	if mv:KeyDown( IN_MOVELEFT ) then
		entity_angle:RotateAroundAxis( entity_angle:Forward() * -1 , turn.r )
		--entity_angle.r = entity_angle.r - turn
	end
	
	if mv:KeyDown( IN_MOVERIGHT ) then
		entity_angle:RotateAroundAxis( entity_angle:Forward() , turn.r )
		--entity_angle.r = entity_angle.r + turn
	end
	
	if mv:KeyDown( IN_FORWARD ) then
		entity_angle:RotateAroundAxis( entity_angle:Right() * -1 , turn.p )
		--entity_angle.p = entity_angle.p + turn
	end
	
	if mv:KeyDown( IN_BACK ) then
		entity_angle:RotateAroundAxis( entity_angle:Right() , turn.p )
		--entity_angle.p = entity_angle.p - turn
	end
	
	
	local entturn = self:GetTurnRate()
	
	--[[
	entity_angle.p = math.ApproachAngle( old_angle.p, entity_angle.p, entturn.p * FrameTime() ) 
	entity_angle.y = math.ApproachAngle( old_angle.y, entity_angle.y, entturn.y * FrameTime() ) 
	entity_angle.r = math.ApproachAngle( old_angle.r, entity_angle.r, entturn.r * FrameTime() )
	]]
	mv:SetAngles( entity_angle )
	
	local vel = mv:GetVelocity()
	
	mv:SetVelocity( vel )
	--self:ApplyGravity( ply , mv )
	vel = mv:GetVelocity()
	
	if mv:KeyDown( IN_JUMP ) then
		vel:Add( mv:GetAngles():Forward() * self:GetMaxSpeed() * FrameTime() )
	end
	
	mv:SetVelocity( vel )
	self:ClampVelocity( ply , mv )
	mv:SetOrigin( mv:GetOrigin() + mv:GetVelocity() )
end

function ENT:ApplyGravity( ply , mv )
	local gravityvec = Vector( 0 , 0 , -10 ) * self:GetGravity() * FrameTime()
	local vel = mv:GetVelocity()
	vel:Add( gravityvec )
	mv:SetVelocity( vel )
end

function ENT:GetCameraOffsets()
	return LocalToWorld( Vector( 8.7 , 0 , 2 ) , angle_zero , self:GetPos() , self:GetAngles() )
end

function ENT:ClampVelocity( ply , mv )
	local vel = mv:GetVelocity()
	if vel:Length() > self:GetMaxSpeed() * FrameTime() then
		local normal = vel:GetNormal()
		vel = normal * self:GetMaxSpeed()
		mv:SetVelocity( vel * FrameTime() )
	end
end

function ENT:OnRemove()

	BaseClass.OnRemove( self )
end