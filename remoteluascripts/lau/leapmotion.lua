if SERVER then
	util.AddNetworkString( "leap" )
end

--TODO: add these defines to the leap table on the server, and merge them on the leap module table on the client

SHADOWTYPE_PALM = 0
SHADOWTYPE_FINGERBONE = 1
SHADOWTYPE_ARM = 2

HAND_LEFT = 0
HAND_RIGHT = 1

FINGER_TYPE_THUMB 		= 0
FINGER_TYPE_INDEX		= 1
FINGER_TYPE_MIDDLE		= 2
FINGER_TYPE_RING		= 3
FINGER_TYPE_PINKY		= 4

BONE_TYPE_METACARPAL		= 0
BONE_TYPE_PROXIMAL			= 1
BONE_TYPE_INTERMEDIATE		= 2
BONE_TYPE_DISTAL			= 3

GESTURE_TYPE_INVALID		= 0
GESTURE_TYPE_SWIPE			= 1
GESTURE_TYPE_CIRCLE			= 2
GESTURE_TYPE_SCREEN_TAP		= 3
GESTURE_TYPE_KEY_TAP		= 4


if CLIENT then
	local leap_convars = {
		scale = CreateConVar( "cl_leap_scale" , "0.1" , FCVAR_ARCHIVE + FCVAR_USERINFO ),
		updaterate = CreateConVar( "cl_leap_updaterate" , "0.1" , FCVAR_ARCHIVE + FCVAR_USERINFO ),
		fakebot = CreateConVar( "cl_leap_fakebotid" , "-1" ),	--this will be removed when I'm done testing the networking
		posefromfile = CreateConVar( "cl_leap_posefromfile" , "" , FCVAR_ARCHIVE + FCVAR_USERINFO ),
	}
	
	local leap_updatethrottle = 0
	local leap_version = ""
	local leap_lastframe = nil
	
	if system.IsWindows() then
		leap_version = "win32.dll"
	elseif system.IsOSX() then
		leap_version = ""	--TODO: at some point
	elseif system.IsLinux() then
		leap_version = ""	--TODO: at some point
	else
		error( "OS not recognized by gmod?" )
	end
	
	if file.Exists( "lua/bin/gmcl_leap_" .. leap_version , "GAME" ) then 
		require( "leap" )
	end
	
	local function HasLeapMotion()
		
		if not leap then
			return false
		end
		
		--we count the player as having the leap if he's using a serialized frame, the module still needs to be loaded though
		if leap_convars.posefromfile:GetString() and #leap_convars.posefromfile:GetString() > 0 then
			return true
		end
		
		return leap.IsConnected()
	end
	
	local function LeapWriteFrameData( frame )
		
		local hands = frame:GetHands()
		local handsnumber = #hands
		
		net.WriteUInt( handsnumber, 8 )	--a byte is fine
		
		for i , v in pairs( hands ) do
			
			net.WriteBit( IsValid( v ) )
			
			if IsValid( v ) then
				net.WriteBit( v:IsLeft() )
				net.WriteVector( v:PalmPosition() )
				net.WriteNormal( v:PalmNormal() )
				net.WriteVector( v:PalmVelocity() )
				net.WriteFloat( v:PinchStrength() )
				net.WriteFloat( v:GrabStrength() )
				net.WriteFloat( v:PalmWidth() )
				
				--TODO:enable once we have arms support
				--[[
				local arm = v:GetArm()
				net.WriteBit( arm:IsValid() )
				if IsValid( arm ) then
					net.WriteVector( arm:Center() )
					net.WriteNormal( arm:Direction() )
					net.WriteVector( arm:ElbowPosition() )
					net.WriteVector( arm:WristPosition() )
					net.WriteFloat( arm:Width() )
				end
				]]
				
				local fingers = v:GetFingers()
				net.WriteUInt( #fingers, 8 )	--a byte is fine
				
				for j,k in pairs( fingers ) do
					
					local bones = k:GetBones()
					
					net.WriteUInt( #bones , 8 )	-- a byte is fine
					
					for _ , _k in pairs( bones ) do
						
						net.WriteVector( _k:Center() )
						net.WriteNormal( _k:Direction() )
						net.WriteFloat( _k:Length() )
						net.WriteFloat( _k:Width() )
						
					end
				end
			end
		end
	end
	
	local function LeapGetFrameFromFile( path )
		local frame = nil
		-- read the file from "DATA" in binary mode and then feed the string to leap.DeserializeFrame()
		
		local framefile = file.Open( path , "rb" , "DATA" )
		
		if framefile then
			local str = framefile:Read( framefile:Size() )
			frame = leap.DeserializeFrame( str )
			framefile:Close()
		end
		
		return frame
	end
	
	local function LeapMotionThink()
		if not IsValid( LocalPlayer() ) then
			return
		end
		
		if leap_updatethrottle > CurTime() then
			return
		end
		
		leap_updatethrottle = CurTime() + math.Clamp( leap_convars.updaterate:GetFloat() , 0.01 , 1 )
		
		if not HasLeapMotion() then
			return
		end
		
		local frame = nil
		
		local serializedframepath = leap_convars.posefromfile:GetString()
		
		if serializedframepath and #serializedframepath > 1 then
			frame = LeapGetFrameFromFile( serializedframepath )
		end
		
		--default back to getting it from the leap
		
		if not IsValid( frame ) then
			frame = leap.Frame()
		end
		
		if not IsValid( frame ) then 
			return
		end
		
		net.Start( "leap" , true )	--send an unreliable message
			
			--"redirect" the command to the bot, this is also checked serverside
			
			local botid = leap_convars.fakebot:GetInt()
			local botent = Player( botid )
			
			net.WriteEntity( IsValid( botent ) and botent or NULL )
			
			LeapWriteFrameData( frame )
			leap_lastframe = frame
		net.SendToServer()

	end
	hook.Add( "Think" , "LeapMotionThink" , LeapMotionThink )
	
	concommand.Add( "leap_writeframe" , function( ply , cmd , args , fullstr )
		if not HasLeapMotion() then
			return
		end
		
		local path = args[1]
		
		if not path then
			MsgN( "leap_writeframe <filename.txt>" )
			return
		end
			
		local currentframe = leap_lastframe
		
		if not IsValid( currentframe ) then
			return
		end
		
		local serializedframe = currentframe:Serialize()
		
		local framefile = file.Open( path , "wb" , "DATA" )
		if framefile then
			framefile:Write( serializedframe )
			framefile:Close()
		end
		
	end )
	
else
	
	local function CreateLeapController( ply )
		local controller = ents.Create( "sent_leap_controller" )
		if not IsValid( controller ) then return end
		
		controller:SetParent( ply )
		controller:SetTransmitWithParent( true )
		controller:SetOwner( ply )
		controller:SetPos( ply:EyePos() )
		controller:SetScale( ply:GetInfoNum( "cl_leap_scale" , 0.25 ) )
		controller:Spawn()
		ply._LeapController = controller
	end
	
	local function HasLeapController( ply )
		return IsValid( ply._LeapController )
	end
	
	concommand.Add( "leap_remove" , function( ply , cmd , args , fullstr )
		for i , v in pairs( ents.FindByClass( "sent_leap_controller" ) ) do
			if IsValid( v ) then
				v:Remove()
			end
		end
		
		for i , v in pairs( ents.FindByClass( "sent_leap_physhadow" ) ) do
			if IsValid( v ) then
				v:Remove()
			end
		end
		
	end )
	
	local function AnalyzeLeapData( ply , framedata )
		--TODO: clamp all the values we've got from the framedata
		--otherwise people might maliciously exploit it and send their own positions and fuck shit up with global positions
		
		--there's no other way to go with this, since we're pretty much trusting the client anyway
		
		if HasLeapController( ply ) then
			ply._LeapController:AnalyzeLeapData( framedata )
		end
		
	end
	
	local function LeapMotionReceive( len , ply )
		local overrideply = net.ReadEntity()
		
		if IsValid( overrideply ) and overrideply:IsPlayer() and overrideply:IsBot() then
			ply = overrideply
		end
		
		if not IsValid( ply ) then
			return
		end
		
		if not HasLeapController( ply ) then
			CreateLeapController( ply )
		end
		
		local frame = {}
		frame.HandsNumber = net.ReadUInt( 8 )	--a byte is fine
		frame.Hands = {}
		
		for i=1,frame.HandsNumber do
			frame.Hands[i] = {}
			frame.Hands[i].IsValid = tobool( net.ReadBit() )
			if frame.Hands[i].IsValid then
				frame.Hands[i].IsLeft = tobool( net.ReadBit() )
				frame.Hands[i].IsRight = not frame.Hands[i].IsLeft
				frame.Hands[i].PalmPosition = net.ReadVector()
				frame.Hands[i].PalmDirection = net.ReadNormal()
				frame.Hands[i].PalmVelocity = net.ReadVector()
				frame.Hands[i].PinchStrength = net.ReadFloat()
				frame.Hands[i].GrabStrength = net.ReadFloat()
				frame.Hands[i].PalmWidth = net.ReadFloat()
				
				--TODO:enable once we have arms support
				--[[
				frame.Hands[i].Arm = {}
				frame.Hands[i].Arm.IsValid = tobool( net.ReadBit() )
				if frame.Hands[i].Arm.IsValid then
					frame.Hands[i].Arm.ArmPosition = net.ReadVector()
					frame.Hands[i].Arm.ArmDirection = net.ReadNormal()
					frame.Hands[i].Arm.ElbowPosition = net.ReadVector()
					frame.Hands[i].Arm.WristPosition = net.ReadVector()
					frame.Hands[i].Arm.ArmWidth = net.ReadFloat()
				end
				]]
				
				frame.Hands[i].FingersNumber = 	net.ReadUInt( 8 )	--a byte is fine
				frame.Hands[i].Fingers = {}
				for j = 1 , frame.Hands[i].FingersNumber do
					frame.Hands[i].Fingers[j] = {}
					frame.Hands[i].Fingers[j].BonesNumber = net.ReadUInt( 8 )	--a byte is fine
					frame.Hands[i].Fingers[j].Bones = {}
					
					for k=1,frame.Hands[i].Fingers[j].BonesNumber do
						frame.Hands[i].Fingers[j].Bones[k] = {}
						frame.Hands[i].Fingers[j].Bones[k].BonePosition = net.ReadVector()
						frame.Hands[i].Fingers[j].Bones[k].BoneDirection = net.ReadNormal()
						frame.Hands[i].Fingers[j].Bones[k].BoneLength = net.ReadFloat()
						frame.Hands[i].Fingers[j].Bones[k].BoneWidth = net.ReadFloat()
						
						local bone = frame.Hands[i].Fingers[j].Bones[k]
						--debugoverlay.BoxAngles( bone.BonePosition , Vector(bone.BoneLength * .5, bone.BoneWidth *.5, bone.BoneWidth*.5), Vector(-bone.BoneLength*.5, -bone.BoneWidth*.5, -bone.BoneWidth*.5), bone.BoneDirection:Angle() , 0.15 )
					end
				
				end
			end
		end
		
		AnalyzeLeapData( ply , frame )
		
	end
	net.Receive( "leap" , LeapMotionReceive)
end

local ENT = {}

ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.RenderGroup     = RENDERGROUP_OPAQUE
--[[

	["ValveBiped.Bip01_L_Hand"]=HAND_LEFT,
	["ValveBiped.Bip01_R_Hand"]=HAND_RIGHT,
	
	["ValveBiped.Bip01_L_Finger4"]=true,
	["ValveBiped.Bip01_L_Finger41"]=true,
	["ValveBiped.Bip01_L_Finger42"]=true,
	
	["ValveBiped.Bip01_L_Finger3"]=true,
	["ValveBiped.Bip01_L_Finger31"]=true,
	["ValveBiped.Bip01_L_Finger32"]=true,
	
	["ValveBiped.Bip01_L_Finger2"]=true,
	["ValveBiped.Bip01_L_Finger21"]=true,
	["ValveBiped.Bip01_L_Finger22"]=true,
	
	["ValveBiped.Bip01_L_Finger1"]=true,
	["ValveBiped.Bip01_L_Finger11"]=true,
	["ValveBiped.Bip01_L_Finger12"]=true,
	
	["ValveBiped.Bip01_L_Finger0"]=true,
	["ValveBiped.Bip01_L_Finger01"]=true,
	["ValveBiped.Bip01_L_Finger02"]=true,
	
	["ValveBiped.Bip01_R_Finger4"]=true,
	["ValveBiped.Bip01_R_Finger41"]=true,
	["ValveBiped.Bip01_R_Finger42"]=true,
	
	["ValveBiped.Bip01_R_Finger3"]=true,
	["ValveBiped.Bip01_R_Finger31"]=true,
	["ValveBiped.Bip01_R_Finger32"]=true,
	
	["ValveBiped.Bip01_R_Finger2"]=true,
	["ValveBiped.Bip01_R_Finger21"]=true,
	["ValveBiped.Bip01_R_Finger22"]=true,
	
	["ValveBiped.Bip01_R_Finger1"]=true,
	["ValveBiped.Bip01_R_Finger11"]=true,
	["ValveBiped.Bip01_R_Finger12"]=true,
	
	["ValveBiped.Bip01_R_Finger0"]=true,
	["ValveBiped.Bip01_R_Finger01"]=true,
	["ValveBiped.Bip01_R_Finger02"]=true,
]]

	
--	["ValveBiped.Bip01_R_Wrist"]=true,
--	["ValveBiped.Bip01_L_Wrist"]=true,

--[[
local FINGER_TYPE_THUMB 	= 1
local FINGER_TYPE_INDEX		= 2
local FINGER_TYPE_MIDDLE	= 3
local FINGER_TYPE_RING		= 4
local FINGER_TYPE_PINKY		= 5

local BONE_TYPE_METACARPAL			= 1
local BONE_TYPE_PROXIMAL			= 2
local BONE_TYPE_INTERMEDIATE		= 3
local BONE_TYPE_DISTAL				= 4
]]

--Used when each bone is created to assign them to a bone in max's c_hands model

ENT.LeapToValveBipedBones = {
	
	[HAND_LEFT] = {
		bone = "ValveBiped.Bip01_L_Hand",	--technically for the palm
		Fingers = {
			[FINGER_TYPE_THUMB] = {
				Bones = {
					[BONE_TYPE_METACARPAL] = {
					},
				}
			},
						
		}
	},
	
	[HAND_RIGHT] = {
		bone = "ValveBiped.Bip01_R_Hand",
		Fingers = {
			Bones = {
				
			}
		}		
	}

}

function ENT:Initialize()
	if SERVER then
		self:SetSolid( SOLID_NONE )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetNoDraw( true )
		
		self.LastFrame = nil
		self.LastFrameReceiveTime = 0
		self.OlderFrameReceiveTime = 0
		self.LastShadow = 0
		self.CurrentFrame = nil
		self.GrabbedPhysObj = nil
		
		self:SetScale( math.Clamp( self:GetScale() , 0.1 , 3 ) )
		
		
		
		--future proofing for when the leap supports more than 2 hands
		self.LeapShadowControllers = {}
		for i = 0 , 3 do
			self.LeapShadowControllers[i] = {}
			self.LeapShadowControllers[i].Fingers = {}
			for j = FINGER_TYPE_THUMB , FINGER_TYPE_PINKY do
				self.LeapShadowControllers[i].Fingers[j] = {}
				self.LeapShadowControllers[i].Fingers[j].Bones = {}
				for k = BONE_TYPE_METACARPAL , BONE_TYPE_DISTAL do
					self.LeapShadowControllers[i].Fingers[j].Bones[k] = {}
				end
			end
		end
		
		--TODO:
		--[[
		local hands = ents.Create( "sent_leap_hands" )
		hands:SetParent( self:GetParent() )
		hands:SetOwner( self:GetParent() )
		hands:SetTransmitWithParent( true )
		hands:SetController( self )
		hands:SetLocalPos( vector_origin )
		hands:Spawn()
		
		self:SetHandsEnt( hands )
		]]
	end
end

function ENT:SetupDataTables()
	self:NetworkVar( "Float" , 0 , "Scale" )
	self:NetworkVar( "Entity" , 0 , "HandsEnt" )
	--loop through the bone table, create a NetworkVar( "Entity" , id , "" ) with the name tied to the bone name itself
	--so on the client we can get the entity by the bone name
	
	for i = 1 , GMOD_MAXDTVARS - 1 do
		self:NetworkVar( "Entity" , i , "LeapBone"..i )
	end
end

if SERVER then

	function ENT:Think()
		
		self:InterpCurFrame()
		
		local frame = self.CurrentFrame
		if not frame then return end
		
		for i = 1 , frame.HandsNumber do
			if frame.Hands[i].IsValid then
				
				local plypos = self:GetOwner():EyePos()
				local plyang = self:GetOwner():EyeAngles() 
				
				plypos , plyang = LocalToWorld( Vector( 50 , 0, -30 ) , Angle( 0 , 90 , 0 ) , plypos , plyang )
				
				local palmpos = frame.Hands[i].PalmPosition * self:GetScale()
				local palmang = frame.Hands[i].PalmDirection:Angle()
				local palmwith = frame.Hands[i].PalmWidth
				local palment = self.LeapShadowControllers[i - 1].Hand
				
				if not IsValid( palment ) then
					local minb = Vector( 2 * 0.5 , palmwith * 0.5 , palmwith * 0.5 )
					local maxbb = minb * -1
					
					--palm direction is fucked up?
					--palment = self:CreatePhysShadow( minb , maxbb )
					self.LeapShadowControllers[i - 1].Hand = palment
				end
				
				palmpos , palmang = LocalToWorld( palmpos , palmang  , plypos , plyang )

				if IsValid( palment ) then
					palment:SetIsLeft( frame.Hands[i].IsLeft )
					palment:Update( palmpos , palmang , FrameTime() , self.OlderFrameReceiveTime , self.LastFrameReceiveTime )
				end
				
				if frame.Hands[i].Arm and frame.Hands[i].Arm.IsValid then
					local armpos = frame.Hands[i].ArmPosition * self:GetScale()
					local armang = frame.Hands[i].ArmDirection:Angle()
					local armwidth = frame.Hands[i].Arm.ArmWidth
					local armlength = ( frame.Hands[i].Arm.ElbowPosition - frame.Hands[i].Arm.WristPosition ):Length()
					local arment = self.LeapShadowControllers[i - 1].Arm
					
					if not IsValid( arment ) then
						local minb = Vector( 2 , armwidth * 0.5 , armlength * 0.5 )
						local maxbb = minb * -1
						
						arment = self:CreatePhysShadow( minb , maxbb )
						self.LeapShadowControllers[i - 1].Arm = arment
					end
					
					armpos , armang = LocalToWorld( armpos , armang , plypos , plyang )
					
					if IsValid( arment ) then
						arment:SetIsLeft( frame.Hands[i].IsLeft )
						arment:Update( armpos , armang , FrameTime() , self.OlderFrameReceiveTime , self.LastFrameReceiveTime )
					end
				
				end
				
				for j=1, frame.Hands[i].FingersNumber do
					for k=1,frame.Hands[i].Fingers[j].BonesNumber do
						local bonepos = frame.Hands[i].Fingers[j].Bones[k].BonePosition * self:GetScale()
						local boneang = frame.Hands[i].Fingers[j].Bones[k].BoneDirection:Angle()
						local boneent = self.LeapShadowControllers[i - 1].Fingers[j - 1].Bones[k - 1].Bone
						local length = frame.Hands[i].Fingers[j].Bones[k].BoneLength * self:GetScale()
						local width = frame.Hands[i].Fingers[j].Bones[k].BoneWidth * self:GetScale()
						
						bonepos , boneang = LocalToWorld( bonepos , boneang  , plypos , plyang )
						

						if not IsValid( boneent ) then
							local maxbb = Vector( frame.Hands[i].Fingers[j].Bones[k].BoneLength * 0.5 , frame.Hands[i].Fingers[j].Bones[k].BoneWidth * 0.5 , frame.Hands[i].Fingers[j].Bones[k].BoneWidth * 0.5 )
							local minbb = maxbb * -1
							
							--ignore bones that have 0 length or 0 width, happens with the metacarpal thumb bone
							if length ~= 0 and width ~= 0 then
								self.LeapShadowControllers[i - 1].Fingers[j - 1].Bones[k - 1].Bone = self:CreatePhysShadow( maxbb , minbb )
							end
							
							boneent = self.LeapShadowControllers[i - 1].Fingers[j - 1].Bones[k - 1].Bone
						end
						
						if IsValid( boneent ) then
							boneent:SetGrabStrength( frame.Hands[i].GrabStrength )
							boneent:SetIsLeft( frame.Hands[i].IsLeft )
							boneent:Update( bonepos , boneang , FrameTime() , self.OlderFrameReceiveTime , self.LastFrameReceiveTime )
							
							--debugoverlay.BoxAngles( boneent:GetPos() , boneent:GetMinSize(), boneent:GetMaxSize(), boneent:GetAngles() , 0.15 )
						end
					end
				end
			end
		end
		self:NextThink( CurTime() + engine.TickInterval() )
		return true
	end
	
	--this function should interpolate the positions and angles on the current frame based on the last frame received
	--and use the time difference from the last frame receive
	function ENT:InterpCurFrame()
		local rate = self.LastFrameReceiveTime - self.OlderFrameReceiveTime
		
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
	
	function ENT:CreatePhysShadow( minb, maxb , handindex , fingertype , bonetype )
		
		local shadow = ents.Create( "sent_leap_physhadow" )
		
		if not shadow then
			return
		end
		
		local bipedbone = nil
		
		--Find the bone name from the hand index and bonetype
		
		if not fingertype or not bonetype then
			if self.LeapToValveBipedBones[handindex] then
				bipedbone = self.LeapToValveBipedBones[handindex].bone
			end
		else
			if self.LeapToValveBipedBones[handindex].Fingers[fingertype] and self.LeapToValveBipedBones[handindex].Fingers[fingertype].Bones[bonetype] then
				bipedbone = self.LeapToValveBipedBones[handindex].Fingers[fingertype].Bones[bonetype].bone
			end
		end
		
		--self["SetLeapBone"..self.LastShadow + 1]( self , shadow )
		shadow:SetOwner( self:GetOwner() )
		shadow:SetMinBounds( minb )
		shadow:SetMaxBounds( maxb )
		shadow:SetPos( self:GetOwner():GetPos() )
		shadow:SetScale( self:GetScale() )
		shadow:SetController( self )
		
		if bipedbone then
			shadow:SetAssociatedBone( bipedbone )
		end
		
		shadow:Spawn()
		
		--[[
		self.LastShadow = self.LastShadow + 1
		
		if self.LastShadow >= GMOD_MAXDTVARS then
			self.LastShadow = 0
		end
		]]
		
		return shadow
	end

	function ENT:AnalyzeLeapData( leapdata )
		self.LastFrame = self.CurrentFrame
		
		self.CurrentFrame = leapdata
		
		self.OlderFrameReceiveTime = self.LastFrameReceiveTime
		self.LastFrameReceiveTime = CurTime()
	end
	
end


function ENT:GetAllPhysBones()

	local tb = {}
	
	for i = 1 , GMOD_MAXDTVARS - 1 do
		tb[1] = self["GetLeapBone"..i]( self )
	end
	
	return tb
end

scripted_ents.Register(ENT,"sent_leap_controller",true)

local ENT = {}


ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.RenderGroup     = RENDERGROUP_OPAQUE

function ENT:Initialize()
	if SERVER then
		self:SetModel( "models/props_junk/wood_crate001a.mdl" )
		self:PhysicsInitBox( self:GetMinSize() , self:GetMaxSize() )
		self:SetCollisionBounds( self:GetMinSize() , self:GetMaxSize() )
		self:SetSolid( SOLID_VPHYSICS )
		self:MakePhysicsObjectAShadow( true, true )
		if IsValid( self:GetPhysicsObject() ) then
			self:GetPhysicsObject():SetMaterial( "flesh" )
		end
	else
		self:SetRenderBounds( self:GetMinSize() , self:GetMaxSize() )
	end
	self:SetCustomCollisionCheck( true )
	hook.Add( "ShouldCollide" , self , self.HandleCollisons )
end

function ENT:SetupDataTables()
	self:NetworkVar( "Int" , 0 , "ShadowType" )
	self:NetworkVar( "Float" , 0 , "Scale" )
	
	self:NetworkVar( "Vector" , 0 , "MinBounds" )
	self:NetworkVar( "Vector" , 1 , "MaxBounds" )
	
	self:NetworkVar( "String" , 0 , "AssociatedBone" )
	self:NetworkVar( "Entity" , 0 , "Controller" )
	
	self:NetworkVar( "Float" , 1 , "GrabStrength" )
	
	self:NetworkVar( "Bool" , 0 , "IsLeft" )

end

function ENT:HandleCollisons( ent1 , ent2 )
	if self == ent1 then
		if ent1:GetClass() == ent2:GetClass() and IsValid( ent1:GetOwner() ) and ent1:GetOwner() == ent2:GetOwner() then
			return false
		end
		
		if ent2 == self:GetOwner() then
			return false
		end
	end
end

function ENT:IsLeft()
	return self:GetIsLeft()
end

function ENT:IsRight()
	return not self:GetIsLeft()
end

function ENT:GetMinSize()
	return self:GetMinBounds() * self:GetScale()
end

function ENT:GetMaxSize()
	return self:GetMaxBounds() * self:GetScale()
end

function ENT:Update( pos , ang , delta , olderlastframereceivedtime , lastframereceivedtime )
	local physobj = self:GetPhysicsObject()
	
	if not IsValid( physobj ) then return end
	
	physobj:Wake()
	physobj:SetMass( 500 * self:GetScale() )
	physobj:UpdateShadow( pos , ang , delta )
end

if CLIENT then
	ENT.Mat = Material( "models/wireframe" )

	function ENT:Draw()
		local cmin , cmax = self:GetCollisionBounds()
		
		render.SetMaterial( self.Mat )
		render.DrawBox( self:GetPos(), self:GetAngles(), cmin, cmax, color_white, true )
	end
end

scripted_ents.Register(ENT,"sent_leap_physhadow",true)


