
if IsValid( OFFSCREENPANEL ) then
	OFFSCREENPANEL:Remove()
	OFFSCREENPANEL = nil
end

local PANEL = {}
AccessorFunc(	PANEL	, "_RT"	,	"RenderTarget"	)


function PANEL:Init()
	self:SetPaintedManually( true )
	self.Avatar = self:Add( "AvatarImage" )

	self.Avatar:SetPos( 0 , 0 )
	self.Avatar:Dock( FILL )
	self.Avatar:SetSteamID( "76561197960279927" , 184 )
end

function PANEL:Think()
end

derma.DefineControl( "DOffscreenPanel", "An offscreen display panel.", PANEL, "DPanel" )


OFFSCREENPANEL = vgui.Create( "DOffscreenPanel" )
OFFSCREENPANEL:SetWide( 1920 )
OFFSCREENPANEL:SetTall( 1200 )

--missing some flags perhaps?
OFFSCREENPANEL:SetRenderTarget( GetRenderTargetEx( "DOffscreenPanelRT6", OFFSCREENPANEL:GetWide() , OFFSCREENPANEL:GetTall() , -1 , MATERIAL_RT_DEPTH_NONE , 0 , CREATERENDERTARGETFLAGS_UNFILTERABLE_OK , IMAGE_FORMAT_DEFAULT ) )

hook.Add( "PostRenderVGUI" , "Render offscreen shit" , function()
	if IsValid( OFFSCREENPANEL ) then
		local oldrt = render.GetRenderTarget()
		local oldw = ScrW()
		local oldh = ScrH()
		
		local rt = OFFSCREENPANEL:GetRenderTarget()
		render.SetRenderTarget( rt )
		render.SetViewPort( 0, 0, OFFSCREENPANEL:GetWide(), OFFSCREENPANEL:GetTall() )
		
		OFFSCREENPANEL:SetPaintedManually( false )
		OFFSCREENPANEL:PaintManual()
		OFFSCREENPANEL:SetPaintedManually( true )
		
		render.SetRenderTarget( oldrt )
		render.SetViewPort( 0 , 0 , oldw , oldh )
	end
end)