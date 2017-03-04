local screen = CreateMaterial( "fb0", "unlitgeneric", { ["$basetexture"] = render.GetScreenEffectTexture(), ["$nolod"] = 1 } )

screen:SetTexture( "$basetexture", render.GetScreenEffectTexture( 0 ) )

hook.Add( "HUDPaint", "BlurryCam", function()
	for i = 1, math.abs( math.floor( math.sin( CurTime()  ) * 50 ) ) do
		--render.DrawTextureToScreen( screen:GetTexture( "$basetexture" ) )
		--[[
		render.UpdateScreenEffectTexture()
		render.SetMaterial( screen )
		render.DrawScreenQuad()
		]]
		surface.SetMaterial( screen )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
		
	end
end )