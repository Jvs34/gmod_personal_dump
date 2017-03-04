if SERVER then
	AddCSLuaFile()
	util.AddNetworkString( "leap" )
	
	--serverside the module doesn't exist, create it manually
	leap = leap or {}

else
	--load the module
	
	local leapversion = ""

	if system.IsWindows() then
		leapversion = "win32.dll"
	elseif system.IsOSX() then
		leapversion = ""	--TODO: at some point
	elseif system.IsLinux() then
		leapversion = ""	--TODO: at some point, *cough* lenny *cough*
	else
		error( "OS not recognized by gmod?" )
	end

	if file.Exists( "lua/bin/gmcl_leap_" .. leapversion , "GAME" ) then 
		require( "leap" )
		leap.ModuleLoaded = true
	else
		leap = leap or {}
		leap.ModuleLoaded = false
	end
	
	
end

leap.IsPredictionEnabled = false

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

leap.ControllerClass = "swep_leap_controller"
leap.IsControllerWeapon = true

leap.FingerToString = {
	[FINGER_TYPE_THUMB] = "Thumb",
	[FINGER_TYPE_INDEX] = "Index",
	[FINGER_TYPE_MIDDLE] = "Middle",
	[FINGER_TYPE_RING] = "Ring",
	[FINGER_TYPE_PINKY] = "Pinky"
}

leap.FingerBoneToString = {
	[BONE_TYPE_METACARPAL] = "Metacarpal",
	[BONE_TYPE_PROXIMAL] = "Proximal",
	[BONE_TYPE_INTERMEDIATE] = "Intermediate",
	[BONE_TYPE_DISTAL] = "Distal"
}

--this function takes a table, not the actual frame userdata
function leap.WriteNetFrame( frame )
	net.WriteUInt( frame.TickCount , 32 )
	net.WriteUInt( frame.HandsNumber , 8 )	--a byte is fine
	
	for i = 1 , frame.HandsNumber do
		net.WriteBit( frame.Hands[i].IsValid )
		if frame.Hands[i].IsValid then
			net.WriteBit( frame.Hands[i].IsLeft )
			net.WriteVector( frame.Hands[i].PalmPosition )
			net.WriteNormal( frame.Hands[i].PalmDirection )
			net.WriteVector( frame.Hands[i].PalmVelocity )
			net.WriteFloat( frame.Hands[i].PinchStrength )
			net.WriteFloat( frame.Hands[i].GrabStrength )
			net.WriteFloat( frame.Hands[i].PalmWidth )
			
			net.WriteBit( frame.Hands[i].Arm.IsValid )
			if frame.Hands[i].Arm.IsValid then
				net.WriteVector( frame.Hands[i].Arm.ArmPosition )
				net.WriteNormal( frame.Hands[i].Arm.ArmDirection )
				net.WriteVector( frame.Hands[i].Arm.ElbowPosition )
				net.WriteVector( frame.Hands[i].Arm.WristPosition )
				net.WriteFloat( frame.Hands[i].Arm.ArmWidth )
			end			
			
			net.WriteUInt( frame.Hands[i].FingersNumber , 8 )
			for j = 1 , frame.Hands[i].FingersNumber do
				net.WriteUInt( frame.Hands[i].Fingers[j].BonesNumber , 8 )
				
				for k=1,frame.Hands[i].Fingers[j].BonesNumber do
					net.WriteVector( frame.Hands[i].Fingers[j].Bones[k].BonePosition )
					net.WriteNormal( frame.Hands[i].Fingers[j].Bones[k].BoneDirection )
					net.WriteFloat( frame.Hands[i].Fingers[j].Bones[k].BoneLength )
					net.WriteFloat( frame.Hands[i].Fingers[j].Bones[k].BoneWidth )
				end
			end
		end
	end	

end

function leap.ReadNetFrame()
	local frame = {}
	frame.TickCount = net.ReadUInt( 32 )
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
			
			
			frame.Hands[i].Arm = {}
			frame.Hands[i].Arm.IsValid = tobool( net.ReadBit() )
			if frame.Hands[i].Arm.IsValid then
				frame.Hands[i].Arm.ArmPosition = net.ReadVector()
				frame.Hands[i].Arm.ArmDirection = net.ReadNormal()
				frame.Hands[i].Arm.ElbowPosition = net.ReadVector()
				frame.Hands[i].Arm.WristPosition = net.ReadVector()
				frame.Hands[i].Arm.ArmWidth = net.ReadFloat()
			end
			
			
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
					
				end
			end
		end
	end
	
	return frame
end

function leap.HasController( ply )
	return IsValid( leap.GetController( ply ) )
end

function leap.GetController( ply )
	if not leap.IsControllerWeapon then
		return ply:GetNWEntity( "LeapController" )
	else
		return ply:GetWeapon( leap.ControllerClass )
	end
end

function leap.AnalyzeData( ply , framedata )
	--TODO: clamp all the values we've got from the framedata
	--otherwise people might maliciously exploit it and send their own positions and fuck shit up with global positions
	
	--there's no other way to go with this, since we're pretty much trusting the client anyway
	
	if CLIENT and game.SinglePlayer() then
		return
	end
	
	if leap.HasController( ply ) and leap.GetController( ply ).AnalyzeLeapData then
		leap.GetController( ply ):AnalyzeLeapData( framedata )
	end
end

if CLIENT then
	leap.convars = {
		scale = CreateConVar( "cl_leap_scale" , "0.1" , FCVAR_ARCHIVE + FCVAR_USERINFO ),
		updaterate = CreateConVar( "cl_leap_updaterate" , "0.1" , FCVAR_ARCHIVE + FCVAR_USERINFO ),
		fakebot = CreateConVar( "cl_leap_fakebotid" , "-1" ),	--this will be removed when I'm done testing the networking
	}
	
	leap.updatethrottle = 0
	leap.framedelay = 10
	
	function leap.HasLeapMotion()
		if not leap.ModuleLoaded then
			return false
		end

		return leap.IsConnected()
	end
	
	--this function puts all the userdata we need into a table
	function leap.FrameToTable( userdataframe )
		
		local frame = {}
		local hands = userdataframe:GetHands()
		
		frame.HandsNumber = #hands
		frame.Hands = {}
		
		for i , v in pairs( hands ) do
			frame.Hands[i] = {}
			frame.Hands[i].IsValid = IsValid( v )
			if frame.Hands[i].IsValid then
				frame.Hands[i].IsLeft = v:IsLeft()
				frame.Hands[i].IsRight = not frame.Hands[i].IsLeft
				frame.Hands[i].PalmPosition = v:PalmPosition()
				frame.Hands[i].PalmDirection = v:PalmNormal()
				frame.Hands[i].PalmVelocity = v:PalmVelocity()
				frame.Hands[i].PinchStrength = v:PinchStrength()
				frame.Hands[i].GrabStrength = v:GrabStrength()
				frame.Hands[i].PalmWidth = v:PalmWidth()
				
				
				local arm = v:GetArm()
				
				frame.Hands[i].Arm = {}
				frame.Hands[i].Arm.IsValid = arm:IsValid()
				if frame.Hands[i].Arm.IsValid then
					frame.Hands[i].Arm.ArmPosition = arm:Center()
					frame.Hands[i].Arm.ArmDirection = arm:Direction()
					frame.Hands[i].Arm.ElbowPosition = arm:ElbowPosition()
					frame.Hands[i].Arm.WristPosition = arm:WristPosition()
					frame.Hands[i].Arm.ArmWidth = arm:Width()
				end
				
				local fingers = v:GetFingers()
				
				frame.Hands[i].FingersNumber = 	#fingers
				frame.Hands[i].Fingers = {}
				for j, finger in pairs( fingers ) do
					local bones = finger:GetBones()
					
					frame.Hands[i].Fingers[j] = {}
					frame.Hands[i].Fingers[j].BonesNumber = #bones	--a byte is fine
					frame.Hands[i].Fingers[j].Bones = {}
					
					for k , _k in pairs( bones ) do
						frame.Hands[i].Fingers[j].Bones[k] = {}
						frame.Hands[i].Fingers[j].Bones[k].BonePosition = _k:Center()
						frame.Hands[i].Fingers[j].Bones[k].BoneDirection = _k:Direction()
						frame.Hands[i].Fingers[j].Bones[k].BoneLength = _k:Length()
						frame.Hands[i].Fingers[j].Bones[k].BoneWidth = _k:Width()
					end
				end
			end
		end
		
		return frame
	end
	
	function leap.Input( ply , cmd )
		
		local tickcount = cmd:TickCount()
		if tickcount == 0 or not leap.HasLeapMotion() then
			return
		end
		
		if not game.SinglePlayer() and leap.updatethrottle > CurTime() then
			return
		end
		
		leap.updatethrottle = CurTime() + 0.025
		
		local frame = leap.Frame()
		
		if not IsValid( frame ) then 
			return
		end
		
		local luaframe = leap.FrameToTable( frame )
		
		if leap.IsPredictionEnabled then
			luaframe.TickCount = tickcount + leap.framedelay	--TESTING WEOOO WEOOOOO
			leap.AnalyzeData( LocalPlayer() , luaframe )
		else
			luaframe.TickCount = 0
		end
		
		
		
		--if game.SinglePlayer() or ( not game.SinglePlayer() and IsFirstTimePredicted() ) then
		net.Start( "leap" )
			net.WriteEntity( NULL )
			leap.WriteNetFrame( luaframe )
		net.SendToServer()
		--end
		
	end
	hook.Add( "StartCommand" , "LeapMotionInput" , leap.Input )

else

	function leap.CreateController( ply )
		local controller = nil
		
		if not leap.IsControllerWeapon then
			controller = ents.Create( leap.ControllerClass )
			if not IsValid( controller ) then 
				return 
			end
			
			controller:SetParent( ply )
			controller:SetTransmitWithParent( true )
			controller:SetOwner( ply )
			controller:SetPos( ply:EyePos() )
			controller:SetScale( ply:GetInfoNum( "cl_leap_scale" , 0.25 ) )
			controller:Spawn()
			ply:SetNWEntity( "LeapController" , controller )
		else
			controller = ply:Give( leap.ControllerClass )
			if not IsValid( controller ) then 
				return 
			end
			controller:SetScale( 0.05 )
		end
		
		return controller
	end
	
	function leap.NetReceive( len , ply )
		local overrideply = net.ReadEntity()
		
		if IsValid( overrideply ) and overrideply:IsPlayer() and overrideply:IsBot() then
			ply = overrideply
		end
		
		if not IsValid( ply ) then
			return
		end
		
		if not leap.HasController( ply ) then
			leap.CreateController( ply )
		end
		
		local frame = leap.ReadNetFrame()
		
		leap.AnalyzeData( ply , frame )
		
	end
	net.Receive( "leap" , leap.NetReceive )
end