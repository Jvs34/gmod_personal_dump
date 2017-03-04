AddCSLuaFile()

DEFINE_BASECLASS( "weapon_base" )

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true
SWEP.Category = "Jvs"
SWEP.Author = "Jvs"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Spawnable = false
SWEP.UseHands = false
SWEP.ViewModel = "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel = ""

SWEP.ViewModelFOV		= 54
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.PrintName			= "Leap Motion"
SWEP.Slot				= 0
SWEP.SlotPos			= 5
SWEP.DrawAmmo			= true
SWEP.DrawCrosshair		= true


function SWEP:Initialize()
	self:SetHoldType( "normal" )
	self.LeapFrames = {}
	if SERVER then
		for i = HAND_LEFT , HAND_RIGHT do
			local arm = ents.Create( "sent_leap_arm" )
			if IsValid( arm ) then
				arm:SetIsLeft( i == HAND_LEFT )
				arm:SetScale( self:GetScale() )
				arm:SetController( self )
				arm:SetParent( self )
				arm:SetPos( self:GetPos() )
				arm:Spawn()
				
				self:SetArm( i , arm )
			end
		end
		--[[
		local handsent = ents.Create( "sent_leap_hands" )
		if IsValid( handsent ) then
			handsent:SetParent( self )
			handsent:SetOwner( self )
			handsent:SetController( self )
			handsent:SetPos( self:GetPos() )
			handsent:Spawn()
			
			self:SetHandsEnt( handsent )
		end
		]]
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Float" , 0 , "Scale" )
	self:NetworkVar( "Entity" , 0 , "HandsEnt" )
	self:NetworkVar( "Entity" , 1 , "LeftArm" )
	self:NetworkVar( "Entity" , 2 , "RightArm" )
end

function SWEP:GetArm( handid )
	if handid == HAND_LEFT then
		return self:GetLeftArm()
	else
		return self:GetRightArm()
	end
end

function SWEP:SetArm( handid , handent )
	if handid == HAND_LEFT then
		return self:SetLeftArm( handent )
	else
		return self:SetRightArm( handent )
	end
end


function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end



function SWEP:CleanOrphanData( currenttick )
	for i ,v in pairs( self.LeapFrames ) do
		if i < currenttick then
			self.LeapFrames[i] = nil
		end
	end
end

function SWEP:Think()
	if CLIENT and game.SinglePlayer() then
		return
	end
	
	if leap.IsPredictionEnabled then
		local usercmd = self.Owner:GetCurrentCommand()
		local currenttick = usercmd:TickCount()
		
		self:CleanOrphanData( currenttick )
		
		local frame = self.LeapFrames[currenttick]

		if frame then
			--print( "Received message, " .. currenttick , " and the frame is "..frame.TickCount )
			self:ProcessLeapFrame( frame )
		end
	end
end


function SWEP:AnalyzeLeapData( framedata )
	if not self.Owner then
		return
	end
	
	if self.Owner:GetActiveWeapon() ~= self then
		return
	end
	
	--we shouldn't be here in the first place but you never know
	if CLIENT and not leap.IsPredictionEnabled then
		return
	end
	
	if leap.IsPredictionEnabled then
		self.LeapFrames[framedata.TickCount] = framedata
	else
		self:ProcessLeapFrame( framedata )
	end
end

function SWEP:ProcessLeapFrame( frame )
	
	if CLIENT and not leap.IsPredictionEnabled then
		return
	end
	
	for i , v in pairs( frame.Hands ) do
		local arment = self:GetArm( v.IsLeft and HAND_LEFT or HAND_RIGHT )
		
		if not IsValid( arment ) then
			continue
		end
		
		arment:SetIsHandValid( v.IsValid )
		
		if v.IsValid then
			--make our arms predictable if they aren't
			if CLIENT and not arment:GetPredictable() then
				arment:SetPredictable( true )
			end
			
			arment:SetScale( self:GetScale() )
			arment:SetGrabStrength( v.GrabStrength )
			arment:SetPinchStrength( v.PinchStrength )
			arment:SetPalmPosition( v.PalmPosition )
			arment:SetPalmDirection( v.PalmDirection:Angle() )
			
			local armtab = v.Arm
			if armtab.IsValid then
				arment:SetArmWidth( armtab.ArmWidth )
				arment:SetArmPosition( armtab.ArmPosition )
				arment:SetWristPosition( armtab.WristPosition )
				arment:SetElbowPosition( armtab.ElbowPosition )
				arment:SetArmDirection( armtab.ArmDirection:Angle() )
			end
			
			--do -1 to get the correct fingerid
			for fingerid , finger in pairs( v.Fingers ) do
				
				for boneid , bone in pairs( finger.Bones ) do
					local fid = fingerid - 1
					local bid = boneid - 1
					
					
					arment:SetFingerBonePosition( fid , bid , bone.BonePosition )
					arment:SetFingerBoneDirection( fid , bid , bone.BoneDirection:Angle() )
					arment:SetFingerBoneLength( fid , bid , bone.BoneLength )
				end
				
			end
			
		end
		
		
	end
	
	
	for i=1,frame.HandsNumber do
		if frame.Hands[i].IsValid then
			if frame.Hands[i].Arm.IsValid then
				local arm = frame.Hands[i].Arm
				
				local armpos = frame.Hands[i].Arm.ArmPosition
				local armang = frame.Hands[i].Arm.ArmDirection:Angle()
				local armwidth = frame.Hands[i].Arm.ArmWidth
				local armlength = ( frame.Hands[i].Arm.ElbowPosition - frame.Hands[i].Arm.WristPosition ):Length()
					
				local minb = Vector( armlength * 0.5 , armwidth * 0.5 , armwidth * 0.5 )
				local maxbb = minb * -1
				--debugoverlay.BoxAngles( armpos , maxbb, minb, armang , 0.05 )

			end
			
			for j = 1 , frame.Hands[i].FingersNumber do
				for k=1,frame.Hands[i].Fingers[j].BonesNumber do
				local bone = frame.Hands[i].Fingers[j].Bones[k]
					--debugoverlay.BoxAngles( bone.BonePosition , Vector(bone.BoneLength * .5, bone.BoneWidth *.5, bone.BoneWidth*.5), Vector(-bone.BoneLength*.5, -bone.BoneWidth*.5, -bone.BoneWidth*.5), bone.BoneDirection:Angle() , 0.05 )

				end
			end
		end
		
	
	end
	
	self.LeapFrames[frame.TickCount] = nil
end

function SWEP:GetPlayerOffset()
	return LocalToWorld( Vector( 24 , 0, -10 ) , Angle( 0 , 90 , 0 ) , self.Owner:EyePos() , self.Owner:EyeAngles() )
end

function SWEP:TranslateToPlayerPos( localpos , localang )
	local plypos , plyang = self:GetPlayerOffset()
	return LocalToWorld( localpos , localang , plypos , plyang )
end

function SWEP:GetArmElbowPosAng( handid )
	local arment = self:GetArm( handid )
	if IsValid( arment ) then
		return self:TranslateToPlayerPos( arment:GetElbowPosition() * self:GetScale() , arment:GetPalmDirection() )
	end
end

function SWEP:GetArmWristPosAng( handid )
	local arment = self:GetArm( handid )
	if IsValid( arment ) then
		return self:TranslateToPlayerPos( arment:GetWristPosition() * self:GetScale() , arment:GetArmDirection() )
	end
end

function SWEP:Deploy()
	return true
end

function SWEP:Holster()
	return true
end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:OnRemove()
	if SERVER then
		if IsValid( self:GetLeftArm() ) then
			self:GetLeftArm():Remove()
		end
		
		if IsValid( self:GetRightArm() ) then
			self:GetRightArm():Remove()
		end
		
		if IsValid( self:GetHandsEnt() ) then
			self:GetHandsEnt():Remove()
		end
	end
end