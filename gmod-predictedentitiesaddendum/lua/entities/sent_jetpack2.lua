AddCSLuaFile()

DEFINE_BASECLASS( "sent_jetpack" )

ENT.Spawnable = true
ENT.PrintName = "Jetpack 2.0"

function ENT:SpawnFunction( ply, tr, ClassName )

	if not tr.Hit then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 36

	local ent = ents.Create( ClassName )
	ent:SetSlotName( "sent_jetpack" )	--this is the best place to set the slot, don't modify it dynamically ingame
	ent:SetPos( SpawnPos )
	ent:SetAngles( Angle( 0 , 0 , 180 ) )
	ent:Spawn()
	return ent

end

function ENT:Initialize()
	BaseClass.Initialize( self )
	
	if SERVER then
		self:SetInputVector( vector_origin )
	else
	
	end

end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables( self )
	
	self:DefineNWVar( "Vector" , "InputVector" ) --set during setupmove, this is where we actually want to go, based on both AIM and input data
end

if SERVER then
	function ENT:OnAttach( ply )
		BaseClass.OnAttach( self )
		self:SetInputVector( vector_origin )
	end
end

--TODO: override CanFly so we can start flying when pressing the movement keys in midair
function ENT:CanFly( owner , mv )
	
	
	if IsValid( owner ) then
	
		--don't care about player inputs in this case, the player's jetpack is going craaazy
		
		if self:GetGoneApeshit() then
			return owner:WaterLevel() == 0 and owner:GetMoveType() == MOVETYPE_WALK and self:HasFuel()
		end
		
		return ( mv:KeyDown( IN_JUMP ) ) and not owner:OnGround() and owner:WaterLevel() == 0 and owner:GetMoveType() == MOVETYPE_WALK and owner:Alive() and self:HasFuel()
	end

	--making it so the jetpack can also fly on its own without an owner ( in the case we want it go go nuts if the player dies or some shit )
	if self:GetGoneApeshit() then
		return self:WaterLevel() == 0 and self:HasFuel()
	end

	return false
end


function ENT:PredictedSetupMove( owner , mv , usercmd )
	

	self:HandleFly( true , owner , mv , usercmd )
	self:HandleFuel( true )
	
	if self:GetActive() then
		owner:SetGroundEntity( NULL )
		local oldspeed = mv:GetVelocity()
		local sight = owner:EyeAngles()
		local factor = 1.5
		local sidespeed = math.Clamp( mv:GetSideSpeed() , -mv:GetMaxClientSpeed() * factor , mv:GetMaxClientSpeed() * factor )
		local forwardspeed = math.Clamp( mv:GetForwardSpeed() , -mv:GetMaxClientSpeed() * factor , mv:GetMaxClientSpeed() * factor )
		local upspeed = mv:GetVelocity().z
		sight.pitch = 0
		sight.roll = 0
		sight.yaw = sight.yaw - 90
		local upspeed=( sidespeed <= 200 and forwardspeed<= 100 ) and 22 or 12
		
		local moveang = Vector( sidespeed / 70 , forwardspeed / 70 , upspeed )
		
		moveang:Rotate(sight)
		local horizontalspeed=moveang
		mv:SetVelocity( oldspeed + horizontalspeed )
		--[[
		local vel = mv:GetVelocity()
		
		local eyeang = owner:EyeAngles()
		
		--TODO: make an input vector from AIM and movement keys, then set that to InputVector
		local inputvec = Vector( mv:GetForwardSpeed() , mv:GetSideSpeed() * -1 , 0 ) --upspeed is only used underwater if I recall correctly --mv:GetUpSpeed() )
		inputvec:Normalize()
		
		--now rotate by the eyeangles
		inputvec:Rotate( eyeang )
		
		--debugoverlay.Line( vector_origin, inputvec * 3000, 0.1, color_white, true )
		
		self:SetInputVector( inputvec )
		
		--after making the input vector, zero out the player's input movedata, we don't want him to have access to source's default air control
		mv:SetForwardSpeed( 0 )
		mv:SetSideSpeed( 0 )
		mv:SetUpSpeed( 0 )
		
		
		--TODO: holding space: hover mode from willox's code?
		
		--apply velocity
		local applyvel = inputvec * self:GetJetpackStrafeVelocity() * FrameTime()
		vel:Add( applyvel )
		
		--TODO: air friction
		vel.x = math.Approach( vel.x, 0, FrameTime() * self:GetAirResistance() * vel.x )
		vel.y = math.Approach( vel.y, 0, FrameTime() * self:GetAirResistance() * vel.y )
		vel.z = math.Approach( vel.z, 0, FrameTime() * self:GetAirResistance() * vel.z )
		
		
		mv:SetVelocity( vel )
		]]
	end
end

function ENT:PredictedMove( owner , data )

end

function ENT:PredictedFinishMove( owner , movedata )
	if self:GetActive() then
		--TODO: clamp velocity? what if the player releases the keys after reaching max speed?
	end
end

function ENT:PredictedHitGround( ply , inwater , onfloater , speed )
end

function ENT:HandleUpdateAnimationOverride( ply , velocity , maxseqgroundspeed )
	local ret = BaseClass.HandleUpdateAnimationOverride( self , ply , velocity , maxseqgroundspeed )
	if self:GetActive() then
		--set the pose parameters to where we're actually trying to move to, not to our actual velocity
		local vec = self:GetInputVector()
		--TODO: convert to 2d from the player angle and then setposeparameter move_x and move_y
	end
	
	return ret
end







