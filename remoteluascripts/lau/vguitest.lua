VGUIS = {
}

local function IsOKPanel( v )
	return ispanel( v ) and IsValid( v ) and not v:IsMarkedForDeletion()
end

function GetVGUI( panel )
	
	panel = panel or vgui.GetWorldPanel()
	if IsOKPanel( panel ) and panel.GetBackgroundColor and panel:IsVisible() then
		VGUIS[panel] = {}
		
		local x , y = panel:GetPos()
		local w , h = panel:GetSize()
		
		VGUIS[panel].x = x
		VGUIS[panel].y = y
		VGUIS[panel].w = w
		VGUIS[panel].h = h
		VGUIS[panel].color = panel:GetBackgroundColor()
	end
	
	for i ,v in pairs( panel:GetChildren() ) do
		GetVGUI( v )
	end
	
	return VGUIS
end

hook.Add( "HUDPaint" , "VGUI TEST", function()
	for i , v in pairs( VGUIS ) do
		surface.SetDrawColor( v.color or color_white )
		surface.DrawOutlinedRect( v.x , v.y , v.w , v.h )
	end
end)
