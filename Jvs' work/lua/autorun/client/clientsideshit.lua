	

 
local function OriginCam()
/*
	local CamData = {}
	CamData.angles = LocalPlayer():EyeAngles()
	CamData.origin = LocalPlayer():EyePos()
	CamData.x = 0
	CamData.y = 0
	CamData.w = ScrW() * 0.3
	CamData.h = ScrH() * 0.3
	render.RenderView( CamData )
	*/
end
hook.Add("HUDPaint", "OriginCam", OriginCam)
 