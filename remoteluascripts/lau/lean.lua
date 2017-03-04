
local LEAN_DT_ID = 15

local MAXIMUM_EYE_ROTATION = 30
local MAXIMUM_LEAN_UNITS = 30

local LEAN_SPEED = 3
local UNLEAN_SPEED = 2


local function CanLean(ply, pos, viewlerp )
	--trace against whatever the player can collide with, use the player solid mask or something idk
	
	
	local leftvec = ply:GetDTAngle(LEAN_DT_ID):Right() * - (MAXIMUM_LEAN_UNITS  * 2)
	local rightvec = ply:GetDTAngle(LEAN_DT_ID):Right() * ( MAXIMUM_LEAN_UNITS  * 2)
	
	local offset = Vector( Lerp( viewlerp , leftvec.x , rightvec.x ) , Lerp( viewlerp , leftvec.y , rightvec.y ) , ply:GetViewOffset().z )
	
	local trace = {
		start = pos,
		endpos = pos + offset,
		mask = MASK_PLAYERSOLID,
		colgroup = COLLISION_GROUP_PLAYER_MOVEMENT,
		mins = ply:OBBMins(),
		maxs = ply:OBBMaxs(),
		filter = function(ent)
			return ent ~= ply and ent:GetOwner() ~= ply
		end,
	}
	
	local tr = util.TraceHull( trace )
	
	if tr.Hit or tr.HitWorld or tr.HitSky or tr.StartSolid then
		return false
	end
	return true
end



if CLIENT then
	local function CanApplyLean(ply)
		return ply:GetViewEntity() == ply and ply:GetDTFloat(LEAN_DT_ID) ~= 0.5 and not ply:IsDrivingEntity() and ply:GetObserverMode() == 0 and not ply:InVehicle() and not ply:ShouldDrawLocalPlayer()
	end
	
	--TODO: the viewmodel angle should only be modified if we're actually looking straight ahead and not up or down
	--do a dot product on the angle we started leaning maybe?
	
	hook.Add("CalcViewModelView","Leaning",function( wep , vm , oldPos , oldAng ,pos , ang )
		local ply = vm:GetOwner()
		if CanApplyLean(ply) then
			ang.r = Lerp( vm:GetOwner():GetDTFloat(LEAN_DT_ID), -MAXIMUM_EYE_ROTATION ,MAXIMUM_EYE_ROTATION )
		end
	end)
	
end


hook.Add("PlayerSpawn","Leaning",function(ply)
	ply:SetDTFloat(LEAN_DT_ID,0.5)
	ply:SetDTAngle(LEAN_DT_ID, Angle() )
end)

hook.Add("StartCommand","Leaning",function(ply,cmd)

	--changed to +speed right now because +walk gives prediction errors which spam the console
	local leanconditions = ply:Alive() and cmd:KeyDown(IN_GRENADE1) and ply:OnGround() and not IsValid( ply:IsDrivingEntity()) and ply:GetObserverMode() == 0 and not ply:InVehicle()
	if leanconditions then
		cmd:ClearMovement()
		
		if not ply:GetDTBool( LEAN_DT_ID ) then
			ply:SetDTAngle(LEAN_DT_ID, ply:EyeAngles() )
			ply:SetDTBool( LEAN_DT_ID, true )
		end
	else
		ply:SetDTBool( LEAN_DT_ID, false )
	end
	
	
	local viewlerp = ply:GetDTFloat(LEAN_DT_ID)	-- 0.5 means middle, 0 means left and 1 means right
	
	local oldviewlerp = viewlerp
	
	local leanvec = ply:GetCurrentViewOffset()
	local eyeaim = ply:GetDTAngle(LEAN_DT_ID)
	
	local pressedthisframe = false
	
	local xcameramovement = leanvec.x
	local ycameramovement = leanvec.y
	
	if leanconditions then
	
		if cmd:KeyDown(IN_MOVERIGHT) then
			viewlerp = viewlerp + LEAN_SPEED * FrameTime()
			pressedthisframe = true
		end
		
		if cmd:KeyDown(IN_MOVELEFT) then
			viewlerp = viewlerp - LEAN_SPEED * FrameTime()
			pressedthisframe = true
		end
		
	end
	
	viewlerp = math.Clamp( viewlerp, 0 , 1 )
	
	if not CanLean(ply , ply:GetPos() , viewlerp) and pressedthisframe then
		viewlerp = oldviewlerp
	end
	
	if pressedthisframe then
		local leftvec = eyeaim:Right() * - MAXIMUM_LEAN_UNITS
		local rightvec = eyeaim:Right() * MAXIMUM_LEAN_UNITS
		xcameramovement = Lerp( viewlerp , leftvec.x , rightvec.x )
		ycameramovement = Lerp( viewlerp , leftvec.y , rightvec.y )
	end
	
	if (viewlerp~= 0.5 or xcameramovement ~= 0 or ycameramovement~= 0 ) and not pressedthisframe then
		viewlerp = math.Approach( viewlerp, 0.5, UNLEAN_SPEED * FrameTime() )
		xcameramovement = math.Approach( xcameramovement, 0, UNLEAN_SPEED * FrameTime() * 100)
		ycameramovement = math.Approach( ycameramovement, 0, UNLEAN_SPEED * FrameTime() * 100)
	end
	

	ply:SetDTFloat(LEAN_DT_ID,viewlerp)
	
	local leanang = Angle()
	leanang.p = Lerp( viewlerp, -MAXIMUM_EYE_ROTATION ,MAXIMUM_EYE_ROTATION )
	
	ply:ManipulateBoneAngles(1,leanang)
	
	leanvec.x = xcameramovement
	leanvec.y = ycameramovement
	
	ply:SetCurrentViewOffset(leanvec)
	
	local visvecmov = vector_origin
	
	if pressedthisframe and (ply:GetDTAngle(LEAN_DT_ID):Forward()):Dot(cmd:GetViewAngles():Forward() ) < 0.8 then
		cmd:SetViewAngles( ply:GetDTAngle(LEAN_DT_ID + 1) )
	else
		ply:SetDTAngle(LEAN_DT_ID + 1 , cmd:GetViewAngles() ) 
	end
	
	--[[
		local approachang = cmd:GetViewAngles()
		approachang.p = math.ApproachAngle( approachang.p, ply:GetDTAngle(LEAN_DT_ID).p, UNLEAN_SPEED * FrameTime() * 50)
		approachang.y = math.ApproachAngle( approachang.y, ply:GetDTAngle(LEAN_DT_ID).y, UNLEAN_SPEED * FrameTime() * 50)
		cmd:SetViewAngles( approachang )
	]]
	
	local viewang = cmd:GetViewAngles()
	viewang.r = Lerp( viewlerp, -MAXIMUM_EYE_ROTATION ,MAXIMUM_EYE_ROTATION )
	cmd:SetViewAngles(viewang)
	
	--if the player is world clicking then prevent him from shooting at least
	--as that would allow him to kind of bypass the viewangles lock
	
	if ply:IsWorldClicking() and ( cmd:KeyDown( IN_ATTACK ) or cmd:KeyDown( IN_ATTACK2 ) ) and leanconditions then
		
		cmd:SetButtons( bit.xor( cmd:GetButtons() , IN_ATTACK ) )
		cmd:SetButtons( bit.xor( cmd:GetButtons() , IN_ATTACK2 ) )
		
	end
	--ply:ManipulateBonePosition(0, leanvec )
	
end)
