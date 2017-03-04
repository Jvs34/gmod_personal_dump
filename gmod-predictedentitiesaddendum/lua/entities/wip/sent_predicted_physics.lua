AddCSLuaFile()

--[[
]]

DEFINE_BASECLASS( "base_predictedent" )

ENT.Spawnable = true
ENT.PrintName = "Predicted ball test"
ENT.AttachesToPlayer = false

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
		self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
		self:InitPhysics()
	end
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables( self )
	
	--used for prediction, so that we reset the physobj pos during a prediction error
	self:DefineNWVar( "Vector" , "PPPos" )
	self:DefineNWVar( "Angle" , "PPAngles" )
	self:DefineNWVar( "Vector" , "PPInputVelocity" )
	self:DefineNWVar( "Vector" , "PPAngleVelocity" ) --there's no direct set for this on the physobj, this might be a problem
	
	--synced one way from the server
	self:DefineNWVar( "Float" , "PPMass" )
	self:DefineNWVar( "Bool" , "PPMotionEnabled" ) 
	self:DefineNWVar( "Bool" , "PPGravityEnabled" )
	self:DefineNWVar( "Bool" , "PPDragEnabled" )
	self:DefineNWVar( "Bool" , "PPCollisionEnabled" )
	self:DefineNWVar( "String" , "PPMaterial" )	--in case someone makes this ultra bouncy or some shit
end

function ENT:Think()
	if CLIENT then
		self:HandleClientPhysObj()
	end
	
	return BaseClass.Think( self )
end

function ENT:InitSharedPhysObject()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:PhysWake()
	self:StartMotionController()
end

function ENT:RemoveSharedPhysObject()
	self:PhysicsDestroy()
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	self:StopMotionController()
end

if SERVER then
	function ENT:DoInitPhysics()
		self:InitSharedPhysObject()
	end
	
	function ENT:DoRemovePhysics()
		self:RemoveSharedPhysObject()
	end
else

	function ENT:HandleClientPhysObj()
		--same check from HandlePrediction
		if self:GetBeingHeld() or game.SinglePlayer() then
			return
		end
		
		if self:IsCarriedByLocalPlayer() then
			if not IsValid( self:GetPhysicsObject() ) then
				self:InitSharedPhysObject()
			end
		else
			if IsValid( self:GetPhysicsObject() ) then
				self:RemoveSharedPhysObject()
			end
		end
	end
	
end

function ENT:PredictedFinishMove( ply , mv )
	--local cando = ( CLIENT and not IsFirstTimePredicted() ) or SERVER
	if IsValid( self:GetPhysicsObject() ) then
		self:SetNetworkOrigin( vector_origin )
		self:SetAbsVelocity( vector_origin )
		self:SetAngles( angle_zero )
	
		if CLIENT then
			--self:GetPhysicsObject():SetPos( self:GetPPPos() )
			--self:GetPhysicsObject():SetAngles( self:GetPPAngles() )
		end
		
		if mv:KeyDown( IN_ATTACK ) then
			self:GetPhysicsObject():SetVelocity( Vector( 0 , 0 , 100 ) )
		end
	end
end

function ENT:PhysicsUpdate()
	print( "GAY" , CurTime() )
end