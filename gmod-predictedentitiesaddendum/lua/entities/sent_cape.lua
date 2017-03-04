AddCSLuaFile()

--[[
	It's a cape! It makes you look cool and lets you fly I think?
]]

DEFINE_BASECLASS( "base_predictedent" )

ENT.Spawnable = true
ENT.PrintName = "Cape"

if SERVER then
	ENT.ShowPickupNotice = true
end

ENT.RagdollModel = Model( "models/props_c17/furnituremattress001a.mdl" )	--also calls the precache function

ENT.AttachmentInfo = {
	BoneName = "ValveBiped.Bip01_Spine2",
	OffsetVec = Vector( -5 , -3 , 0 ),
	OffsetAng = Angle( 90 , 0 , 0 )
}

function ENT:SpawnFunction( ply, tr, ClassName )

	local ent = ents.Create( ClassName )
	ent:SetSlotName( ClassName )
	ent:SetPos( vector_origin )
	ent:SetAngles( angle_zero )
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
		self:SetCapeColor( Vector( 0.7 , 0.25 , 0.25 ) )
		self:InitPhysics()
	else
		self.CapePhysobjs = {}
	end
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables( self )
	self:DefineNWVar( "Vector" , "CapeColor" )
	self:DefineNWVar( "Bool" , "Flying" )
end

function ENT:Think()
	if CLIENT then
		self:HandleFakeViewmodel()
		self:HandleCape()
	end
	
	return BaseClass.Think( self )
end

function ENT:HandleFlying( ply , mv )
	self:SetFlying( self:IsKeyDown( mv ) )
end

function ENT:PredictedMove( ply , mv )
	--self:HandleFlying( ply , mv )
	
	if self:GetFlying() then
		ply:SetGroundEntity( NULL )
		local aimvec = ply:GetAimVector()
		mv:SetVelocity( aimvec * 1000 )
	end
end

if SERVER then
	
	function ENT:OnAttach( ply )
		self:SetCapeColor( ply:GetPlayerColor() )
	end

	function ENT:OnDrop( ply , forced )
		self:Remove()
	end

	function ENT:DoInitPhysics()
		
	end

else

	function ENT:HandleFakeViewmodel()
	
	end
	
	function ENT:IsMainIndex( index )
		return index == 4 or index == 5
	end
	
	function ENT:GetPhysobjIndex( physobj )
		local idx = nil
		
		for i , v in pairs( self.CapePhysobjs ) do
			if v == physobj then
				idx = i - 1
				break
			end
		end
		
		return idx
	end
	
	function ENT:HandleFullPacketUpdate( ent , shouldtransmit )
		BaseClass.HandleFullPacketUpdate( self , ent , shouldtransmit )
		if self == ent and not shouldtransmit then
			self:RemoveCape()
		end
	end
	
	function ENT:HandleCape()
		if IsValid( self.CapeRagdoll ) then
			--go through all the physobjs and wake them up, because the clientside code of ragdoll of course has to make them sleep for optimisation?
			--can't do this from physicssimulate, as it's not called for physobjs that are asleep
			local shouldcollide
			
			if self:IsCarried() then
				shouldcollide = self:GetControllingPlayer():GetMoveType() == MOVETYPE_WALK
			end
			
			for i , v in pairs( self.CapePhysobjs ) do
				if IsValid( v ) then
					if v:IsAsleep() then
						v:Wake()
					end
					
					if shouldcollide ~= nil then
						v:EnableGravity( shouldcollide )
						v:EnableCollisions( shouldcollide )
					end

				end
			end
			
			return
		end		
		
		self:StopMotionController()
		self:StartMotionController()
		self.CapePhysobjs = {}
		
		local pos = self:GetPos()
		local ang = self:GetAngles()
		
		self.CapeRagdoll = ClientsideRagdoll( self.RagdollModel )
		self.CapeRagdoll:SetMaterial( "models/debug/debugwhite" )
		self.CapeRagdoll:SetNoDraw( false )
		self.CapeRagdoll:DrawShadow( true )
		self.CapeRagdoll:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE )
		self.CapeRagdoll:AddCallback( "BuildBonePositions" , function( cape , nbones )
			local owner = cape.RealOwner	--GetOwner() keeps returning the LocalPlayer()?????????????
			if IsValid( owner ) and owner.CapeBuildBonePositions then
				owner:CapeBuildBonePositions( cape , nbones )
			end
		end)
		
		self.CapeRagdoll.RealOwner = self
		
		self.CapeRagdoll.RenderOverride = function( cape )
			--should we draw the shadow if we're in first person
			local owner = cape.RealOwner
			
			cape:CreateShadow()
			
			if IsValid( owner ) and owner.IsCarried and owner:IsCarried() then
				if not owner:ShouldDrawLocalPlayer( true ) then
					cape:DestroyShadow()
				end
			end
			
			if cape.CanDraw then
				cape:DrawModel()
			end
			
		end
		
		for i = 0 , self.CapeRagdoll:GetPhysicsObjectCount() - 1 do
		
			local physobj = self.CapeRagdoll:GetPhysicsObjectNum( i )
			
			if IsValid( physobj ) then
				
				self.CapePhysobjs[ i + 1 ] = physobj
				
				if self:IsMainIndex( i ) then
					physobj:SetMass( 5000 )
				else
					physobj:SetMass( 1 )
				end
				
				physobj:SetPos( pos )
				physobj:SetAngles( ang )
				self:AddToMotionController( physobj )
			end
		end
		
	end
	
	function ENT:CapeBuildBonePositions( cape , nbones )
		if not self:IsCarried() then
			return
		end
		
		for i = 0 , nbones - 1 do
			
			local bm = cape:GetBoneMatrix( i )
			
			if bm then
				local physbone = cape:TranslateBoneToPhysBone( i )
				
				if self:IsMainIndex( physbone ) then
					--physics will never match up the bones perfectly, so we have to force that, at least for the attachment ones
					local pos , ang = self:GetCustomParentOrigin()
					
					bm:SetTranslation( pos )
					bm:SetAngles( ang )
					bm:Scale( Vector( 0.4 , 0.1 , 0.7 ) )
				else
					bm:Scale( Vector( 0.8 , 0.05 , 0.7 ) )
				end
				
				cape:SetBoneMatrix( i , bm )
			end

		end
		
	end

	function ENT:Draw( flags )
		local pos , ang = self:GetCustomParentOrigin()

		if pos and ang then
			self:SetPos( pos )
			self:SetAngles( ang )
			self:SetupBones()
		end

		if IsValid( self.CapeRagdoll ) then
		
			self.CapeRagdoll:SetupBones()
			
			local colormult = 0.10
			local col = self:GetCapeColor()

			local r , g , b = render.GetColorModulation()
			render.SetColorModulation( r * colormult + col.x , g * colormult + col.y , b * colormult + col.z )
			
			self.CapeRagdoll.CanDraw = true
			self.CapeRagdoll:DrawModel()
			self.CapeRagdoll.CanDraw = false
			
			
			render.SetColorModulation( r,g,b )
			
		end
		
	end
	
	local shadowControlTable = {
		delta = 0,
		secondstoarrive = 1,
		maxangular = 999999,
		maxangulardamp = 999999,
		maxspeed = 999999,
		maxspeeddamp = 999999,
		dampfactor = 1,
		teleportdistance = 100,
	}
	
	function ENT:PhysicsSimulate( physobj , delta )
		
		if not self:IsCarried() then
			return
		end
		

		shadowControlTable.secondstoarrive = engine.TickInterval() * 2 --just like it's used by the gravity gun
		shadowControlTable.delta = delta
		
		local physobjindex = self:GetPhysobjIndex( physobj )
		
		--not a tracked physobj?
		if not physobjindex then
			self:RemoveFromMotionController( physobj )
			return vector_origin , vector_origin , SIM_NOTHING
		end
		
		local pos , ang = self:GetCustomParentOrigin()
		
		if not pos or not ang then
			return vector_origin , vector_origin , SIM_NOTHING 
		end
		
		if self:IsMainIndex( physobjindex ) then
			--[[
				physobj:SetPos( pos )
				physobj:SetAngles( ang )
			]]
			shadowControlTable.pos = pos
			shadowControlTable.angle = ang
			
			physobj:ComputeShadowControl( shadowControlTable )
		else
			--is this physobj too far away from this position? teleport it
			if physobj:GetPos():Distance( pos ) > shadowControlTable.teleportdistance then
				physobj:SetPos( pos )
				physobj:SetAngles( ang )
			end
		end
		--TODO: affected by wind????
		return vector_origin , vector_origin , SIM_GLOBAL_ACCELERATION
	end
	
	function ENT:RemoveCape()
		if IsValid( self.CapeRagdoll ) then
		
			for i = 0 , self.CapeRagdoll:GetPhysicsObjectCount() - 1 do
		
				local physobj = self.CapeRagdoll:GetPhysicsObjectNum( i )
				if IsValid( physobj ) then
					self:RemoveFromMotionController( physobj )
				end
			end
			
			self.CapePhysobjs = {}
			
			self.CapeRagdoll:Remove()
		end
	end
end

function ENT:OnRemove()
	if CLIENT then
		self:RemoveCape()
	end
	
	return BaseClass.OnRemove( self )
end

function ENT:HandleMainActivityOverride( ply , velocity )
	if self:GetFlying() then
		local vel2d = velocity:Length2D()
		local idealact = ACT_INVALID
		
		idealact = ACT_HL2MP_IDLE + 9
		
		return idealact , ACT_INVALID
	end
end

function ENT:HandleUpdateAnimationOverride( ply , velocity , maxseqgroundspeed )
	if self:GetFlying() then
		ply:SetCycle( 0 )
		ply:SetPlaybackRate( 0 )	--don't do the full swimming animation
		return true
	end
end