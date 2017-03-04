AddCSLuaFile()

--[[
	A portable flashlight, when not used in conjunction with swep_predictedswep, it'll be held on your back

]]

DEFINE_BASECLASS( "base_predictedent" )

ENT.Spawnable = true
ENT.PrintName = "Flashlight"
ENT.AttachesToPlayer = true

ENT.AttachmentInfo = {
	BoneName = "ValveBiped.Bip01_Spine1",
	OffsetVec = Vector( 5.5 , -5 , 0 ),
	OffsetAng = Angle( 0 , 0 , 0 ),
}

ENT.FlashlightOffset = {
	OffsetVec = Vector( 7 , 0 , 0 ),
	OffsetAng = Angle( 0 , 0 , 0 ),
}

if CLIENT then
	AccessorFunc( ENT , "_fh" , "FlashlightHandle" )
	AccessorFunc( ENT , "_pixvis" , "PixelVisibilityHandle" )
	AccessorFunc( ENT , "_fc" , "FlashlightColorCached" )
	AccessorFunc( ENT , "_lu" , "LastFlashlightUpdate" )
	
	--gmod_lamp
	ENT.MatLight = Material( "sprites/light_ignorez" )
	ENT.MatBeam = Material( "effects/lamp_beam" )
end

function ENT:SpawnFunction( ply, tr, ClassName )

	if not tr.Hit then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 36

	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:SetSlotName( ClassName )
	ent:Spawn()

	return ent

end

function ENT:Initialize()
	BaseClass.Initialize( self )
	if SERVER then
		self:SetModel( "models/maxofs2d/lamp_flashlight.mdl" )
		
		self:SetActive( true )
		self:SetDistance( 1024 )
		self:SetLightFOV( 90 )
		self:SetBrightness( 255 )
		self:SetFlashlightColor( Vector( 1 , 1 , 1 ) )
		self:SetBrightness( 1 )
		self:SetFlashlightTexture( "effects/flashlight001" )
		
		self:InitPhysics()
	else
		self:SetFlashlightHandle( nil )
		self:SetPixelVisibilityHandle( util.GetPixelVisibleHandle() )
		self:SetFlashlightColorCached( Color( 255 , 255 , 255 , 255 ) )
		self:SetLastFlashlightUpdate( 0 )
	end
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables( self )
	self:DefineNWVar( "Bool" , "Active" , true )
	
	self:DefineNWVar( "Float" , "LightFOV" , true , "FOV" , 1 , 100 )
	self:DefineNWVar( "Float" , "Brightness" , true , "Brightness" ,  0 , 1 )
	self:DefineNWVar( "Int" , "Distance" , true , "Distance" , 10 , 2048 )
	self:DefineNWVar( "String" , "FlashlightTexture" )
	self:DefineNWVar( "Vector" , "FlashlightColor" , true , "Color" , nil , nil , "VectorColor" )
end

function ENT:Think()
	if CLIENT then
		self:HandleFlashlight()
	end
	
	return BaseClass.Think( self )
end

function ENT:GetFlashlightPosAng()
	return LocalToWorld( self.FlashlightOffset.OffsetVec , self.FlashlightOffset.OffsetAng , self:GetPos() , self:GetAngles() )
end

if CLIENT then
	--client only
	function ENT:HandleFlashlight()
	
		if self:GetActive() then
			if not IsValid( self:GetFlashlightHandle() ) then
				local projtext = ProjectedTexture()
				projtext:SetNearZ( 1 )
				projtext:SetEnableShadows( false ) --gmod_lamp has this as true
				projtext:SetTexture( self:GetFlashlightTexture() ) --texture should only be set once, this may change
				projtext:Update()
				self:SetFlashlightHandle( projtext )
			end
		else
			self:RemoveFlashlight()
		end
		
		if IsValid( self:GetFlashlightHandle() ) then
			local projtext = self:GetFlashlightHandle()
			
			local updatedata = self:GetLastFlashlightUpdate() < CurTime()
			
			if updatedata then
				local coltb = self:GetFlashlightColorCached()
				local colvec = self:GetFlashlightColor()
				
				coltb.r = colvec.r * 255 --* self:GetBrightness()
				coltb.g = colvec.g * 255 --* self:GetBrightness()
				coltb.b = colvec.b * 255 --* self:GetBrightness()
				--coltb.a = self:GetBrightness() * 255 --we're gonna set it anyway, even though alpha is ignored
				
				projtext:SetBrightness( self:GetBrightness() )
				projtext:SetFOV( self:GetLightFOV() )
				projtext:SetColor( self:GetFlashlightColorCached() )
				projtext:SetFarZ( self:GetDistance() )
				
				self:SetLastFlashlightUpdate( CurTime() )
			end
			
			local fpos , fang = self:GetFlashlightPosAng()
			projtext:SetPos( fpos )
			projtext:SetAngles( fang )
			projtext:Update()
		end
	end
	
	function ENT:RemoveFlashlight()
		if IsValid( self:GetFlashlightHandle() ) then
			self:GetFlashlightHandle():Remove()
		end
	end
	
	function ENT:Draw( flags )
		local pos , ang = self:GetCustomParentOrigin()
		--even though the calcabsoluteposition hook should already prevent this, it doesn't on other players
		--might as well not give it the benefit of the doubt in the first place
		if pos and ang then
			self:SetPos( pos )
			self:SetAngles( ang )
			self:SetupBones()
		end
		
		self:DrawModel( flags )
		
		if self:GetActive() then
			local col = self:GetFlashlightColorCached()
			local oldalpha = col.a
			
			local fpos , fang = self:GetFlashlightPosAng()
			--from gmod_lamp
			
			local lightnrm = self:GetAngles():Forward()
			local viewnormal = self:GetPos() - EyePos()
			local distance = viewnormal:Length()
			viewnormal:Normalize()
			
			local viewdot = viewnormal:Dot( fang:Forward() * -1 )
			local lightpos = fpos
			
			
			--light
			--if viewdot >= 0 then
				
			local visible = util.PixelVisible( lightpos , 16 , self:GetPixelVisibilityHandle() )
			
			
			
			if visible > 0 then
				render.SetMaterial( self.MatLight )
				local size = math.Clamp( distance * visible * viewdot * 2 , 64 * 1.5 , 512 )
				distance = math.Clamp( distance , 32 , 800 )
				local alpha = math.Clamp( ( 1000 - distance ) * visible * viewdot , 0 , 100 )
				col.a = alpha * self:GetBrightness()
				
				render.DrawSprite( lightpos , size , size , col , visible * viewdot )
				render.DrawSprite( lightpos , size * 0.4 , size * 0.4 , col , visible * viewdot )
			end
			--end
			
			
			render.SetMaterial( self.MatBeam )

			--beam is visible when the light itself isn't visible
			--[[
			local beamalpha = 1 - visible-- * self:GetBrightness()	--TODO: CHANGE
			
			local beamsize = self:GetLightFOV() * 1.422 --almost equal to 128
			local beamdistance = 100
			
			render.StartBeam( 3 )
				col.a = 120 * beamalpha
				render.AddBeam( lightpos + lightnrm * -1 , beamsize , 0 , col )
				
				col.a = 64 * beamalpha
				render.AddBeam( lightpos - lightnrm * ( beamdistance / 2 ) * -1 , beamsize , 0.5 , col )
				
				col.a = 0
				render.AddBeam( lightpos - lightnrm * beamdistance * -1 , beamsize , 1 , col )
				
			render.EndBeam()
			]]
			
			col.a = oldalpha
		end
	end
	

else

	
end


function ENT:OnRemove()
	if CLIENT then
		self:RemoveFlashlight()
	end
	
	return BaseClass.OnRemove( self )
end
