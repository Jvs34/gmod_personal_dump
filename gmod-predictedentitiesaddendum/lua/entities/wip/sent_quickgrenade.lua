AddCSLuaFile()

DEFINE_BASECLASS( "base_predictedent" )

ENT.Spawnable = true
ENT.PrintName = "Quick Grenade"
ENT.KeyAllowedFlags = ENT.KeyAllowedKeyboard
ENT.AttachesToPlayer = true

ENT.AttachmentInfo = {
	BoneName = "ValveBiped.Bip01_L_Forearm",
	OffsetVec = Vector( 0 , 0 , 0 ),
	OffsetAng = Angle( 0 , 0 , 0 ),
}

ENT.FakeViewModelAttachmentInfo = {
	OffsetVec = Vector( 0 , 0 , 0 ),
	OffsetAng = Angle( 0 , 0 , 0 )
}

ENT.GrenadeStates = {
	DRAWING = 1,	--quickly moves the viewmodel down, moves over to PULLPIN
	PULLPIN = 2,	--quickly does the pin pulling animation 
}

function ENT:SpawnFunction( ply, tr, ClassName )

	if not tr.Hit then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 36

	local ent = ents.Create( ClassName )
	ent:SetSlotName( ClassName )
	ent:Spawn()
	if not ent:Attach( ply , true ) then
		ent:Remove()
		return nil
	end
	return ent

end

function ENT:Initialize()
	BaseClass.Initialize( self )
	if SERVER then
		self:DrawShadow( false )
		self:SetKey( KEY_G )
		self:InitPhysics()
	end
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables( self )
	self:DefineNWVar( "Int" , "GrenadeState" )	--the state of our animation and what we need to do
												--we'll use this to sync up the clientside animations and the viewmodel stuff
	
end

function ENT:Think()
	if CLIENT then
		self:HandleFakeViewModel()
	end
	return BaseClass.Think( self )
end

function ENT:GetFakeViewModelAttachment()
	local ply = self:GetControllingPlayer()
	if IsValid( ply ) then
		return LocalToWorld( self.FakeViewModelAttachmentInfo.OffsetVec , self.FakeViewModelAttachmentInfo.OffsetAng , ply:EyePos() , ply:EyeAngles() )
	end
end

if SERVER then

	function ENT:DoInitPhysics()
	end
	
	function ENT:DoRemovePhysics()
	end
	
	function ENT:OnDrop( ply , forced )
		if forced and IsValid( ply ) then
			self:Remove()
		end
	end
	
else
	
	function ENT:HandleFakeViewModel()
		--create the c_ frag viewmodel
		if not IsValid( self.FakeViewModel ) then
			self.FakeViewModel = ClientsideModel( "models/weapons/c_grenade.mdl" )
			self.FakeViewModel:SetNoDraw( true )
			self.FakeViewModel:SetOwner( self )
			--render matrix to invert the drawing
			local mat = Matrix()
			mat:Scale( Vector( 1 , -1 , 1 ) )
			self.FakeViewModel:EnableMatrix( "RenderMultiply" , mat )
		end
		
		if not IsValid( self.FakeViewModelHands ) then
			local plyhands = self:GetControllingPlayer():GetHands()
			
			if not IsValid( plyhands ) then
				return
			end
			
			self.FakeViewModelHands = ClientsideModel( plyhands:GetModel() )
			self.FakeViewModelHands:SetOwner( self )
			self.FakeViewModelHands:SetNoDraw( true )
			self.FakeViewModelHands:SetParent( self.FakeViewModel )
			self.FakeViewModelHands:AddEffects( EF_BONEMERGE )
			self.FakeViewModelHands.GetPlayerColor = function( vmhands )
				if IsValid( self:GetOwner() ) and self:GetOwner().IsCarried and self:GetOwner():IsCarried() then
					return self:GetOwner():GetControllingPlayer():GetPlayerColor()
				end
			end
		end
	end
	
	function ENT:DrawFakeViewModel()
		if not self:IsCarriedByLocalPlayer( true ) then
			return
		end
		
		local pos , ang = self:GetFakeViewModelAttachment()
		
		render.CullMode( MATERIAL_CULLMODE_CW )
		
		if IsValid( self.FakeViewModel ) and pos and ang then
			self.FakeViewModel:SetPos( pos )
			self.FakeViewModel:SetAngles( ang )
			self.FakeViewModel:SetupBones()
			self.FakeViewModel:DrawModel()
		end
		
		if IsValid( self.FakeViewModelHands ) then
			self.FakeViewModelHands:DrawModel()
		end
		
		render.CullMode( MATERIAL_CULLMODE_CCW )
	end
	
	function ENT:Draw( flags )
	end
	
	function ENT:DrawFirstPerson( ply )
		self:DrawFakeViewModel()
	end
end

function ENT:OnRemove()
	if CLIENT then
		if IsValid( self.FakeViewModel ) then
			self.FakeViewModel:Remove()
		end
		
		if IsValid( self.FakeViewModelHands ) then
			self.FakeViewModelHands:Remove()
		end
	end
end
