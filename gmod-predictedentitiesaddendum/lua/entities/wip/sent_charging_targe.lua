AddCSLuaFile()

--[[
]]

DEFINE_BASECLASS( "base_predictedent" )

ENT.Spawnable = true
ENT.PrintName = "Charging Targe"
ENT.AttachesToPlayer = true

if CLIENT then
	ENT.WireFrame = Material( "models/wireframe" )
end

ENT.MinBounds = Vector( -8 , -9 , -0.7 )
ENT.MaxBounds = Vector( 8 , 8 , 0.8 )

ENT.AttachmentInfo = {
	BoneName = "ValveBiped.Bip01_L_Forearm",
	OffsetVec = Vector( 6 , 0 , 2.2 ),
	OffsetAng = Angle( 0 , 0 , -20 ),
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
		self:SetModel( "models/props_wasteland/laundry_washer001a.mdl" )
		self:InitPhysics()
	else
		local mat = Matrix()
		mat:Scale( Vector( 0.2 , 0.2 ,0.025 ) ) 
		self:EnableMatrix( "RenderMultiply" , mat )
	end
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables( self )
end

function ENT:Think()
	return BaseClass.Think( self )
end

if SERVER then

	function ENT:DoInitPhysics()
		self:PhysicsInitBox( self.MinBounds , self.MaxBounds )
		self:SetCollisionBounds( self.MinBounds , self.MaxBounds )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysWake()
	end
	
else
	
	function ENT:Draw( flags )
		local pos , ang = self:GetCustomParentOrigin()
		
		--even though the calcabsoluteposition hook should already prevent this, it doesn't on other players
		--might as well not give it the benefit of the doubt in the first place
		if pos and ang then
			self:SetPos( pos )
			self:SetAngles( ang )
			self:SetupBones()	--seems to be needed since we're never technically drawing the model
		end
		
		self:DrawModel()
		
	end
end
