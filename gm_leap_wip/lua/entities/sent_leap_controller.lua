AddCSLuaFile()

ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.RenderGroup     = RENDERGROUP_OPAQUE

function ENT:Initialize()
	if SERVER then
		self:SetSolid( SOLID_NONE )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetNoDraw( true )
		
		--[[
		self.LastFrame = nil
		self.LastFrameReceiveTime = 0
		self.OlderFrameReceiveTime = 0
		self.CurrentFrame = nil
		]]
		
		self:SetScale( math.Clamp( self:GetScale() , 0.1 , 3 ) )
	end
end

function ENT:SetupDataTables()
	self:NetworkVar( "Float" , 0 , "Scale" )
	self:NetworkVar( "Entity" , 0 , "HandsEnt" )
	self:NetworkVar( "Entity" , 1 , "SimpleEntLeft" )
	self:NetworkVar( "Entity" , 2 , "SimpleEntRight" )
end

function ENT:GetSimpleEnt( handid )
	if handid == HAND_LEFT then
		return self:GetSimpleEntLeft()
	else
		return self:GetSimpleEntRight()
	end
end

function ENT:SetSimpleEnt( handid , handent )
	if handid == HAND_LEFT then
		return self:SetSimpleEntLeft( handent )
	else
		return self:SetSimpleEntRight( handent )
	end
end

function ENT:Think()
	
	self:InterpCurFrame()
	
	local frame = self.CurrentFrame
	if not frame then return end
	
	--self:PhysicsModeThink( frame )

	
	self:NextThink( CurTime() + engine.TickInterval() )
	return true
end


--this function should interpolate the positions and angles on the current frame based on the last frame received
--and use the time difference from the last frame receive
function ENT:InterpCurFrame()
	--local rate = self.LastFrameReceiveTime - self.OlderFrameReceiveTime
	
end


--TODO: called when the hand detects a pinch over the threshold
function ENT:OnPinch( value )

end

function ENT:OnPinchRelease( value )

end

--TODO: called when the hand detects a grab over the threshold
function ENT:OnGrab( value )

end

function ENT:OnGrabRelease( value )

end
	

function ENT:AnalyzeLeapData( leapdata )
	--self.LastFrame = self.CurrentFrame
	
	self.CurrentFrame = leapdata
	
	--[[
	self.OlderFrameReceiveTime = self.LastFrameReceiveTime
	self.LastFrameReceiveTime = CurTime()
	]]
end