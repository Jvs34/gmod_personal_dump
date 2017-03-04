
local DRAWREALLEGS = false

hook.Add( "PreDrawEffects" , "REAL LEGS" , function()
	DRAWREALLEGS = true
	
	if LocalPlayer():ShouldDrawLocalPlayer() then
		return
	end
	--[[
	
			--same depth hack valve uses in source!
		self:DrawFirstPerson( ply )
	
	]]
	
	local fwdoffset = -22
	local clipvector = vector_up * -1
	local radangle = math.rad( LocalPlayer():EyeAngles().y )
	local pos = LocalPlayer():GetPos()
	local ang = LocalPlayer():EyeAngles()
	ang.p = 0
	ang.r = 0
	
	pos.x = pos.x + math.cos( radangle ) * fwdoffset
	pos.y = pos.y + math.sin( radangle ) * fwdoffset
	
	local oldpos = LocalPlayer():GetPos()
	local oldang = LocalPlayer():GetAngles()
	
	LocalPlayer():SetPos( pos )
	LocalPlayer():SetAngles( angle_zero )
	LocalPlayer():SetPoseParameter( "aim_pitch" , 0 )
	
	LocalPlayer():SetupBones()
	
	cam.Start3D( nil , nil , nil , nil , nil , nil , nil , 1 , -1 )
	render.DepthRange( 0 , 0.1 )
	render.EnableClipping( true )
	render.PushCustomClipPlane( clipvector, clipvector:Dot( EyePos() ) ) -- Clip the model so if we look up we should never see any part of the legs model
		
		LocalPlayer():DrawModel()
		
	render.PopCustomClipPlane()
	render.EnableClipping( false )
	render.DepthRange( 0 , 1 )		--they don't even set these back to the original values
	cam.End3D()
	
	LocalPlayer():SetPos( oldpos )
	LocalPlayer():SetAngles( oldang )
	LocalPlayer():SetupBones()
	
	DRAWREALLEGS = false
end)