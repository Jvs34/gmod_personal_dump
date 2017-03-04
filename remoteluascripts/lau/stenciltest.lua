local thing = Material( "entities/npc_monk.png" )
local mask = Material( "entities/npc_monk.png" )
--[[
"UnlitGeneric" 
{ 
	"$basetexture"		"sprites/sent_ball" 
	"$vertexcolor" 		1 
	"$vertexalpha" 		1 
} 

]]

--Material( "sprites/sent_ball" )

local function GenerateCircleVertices( x, y, radius, ang_start, ang_size )

    local vertices = {}
    local passes = radius -- Seems to look pretty enough
    
    -- Ensure vertices resemble sector and not a chord
    vertices[ 1 ] = { 
        x = x,
        y = y
    }

    for i = 0, passes do

        local ang = math.rad( -90 + ang_start + ang_size * i / passes )

        vertices[ i + 2 ] = {
            x = x + math.cos( ang ) * radius,
            y = y + math.sin( ang ) * radius
        }

    end

    return vertices

end


local RADAR_RADIUS = 128
local RADAR_X, RADAR_Y = RADAR_RADIUS + 32, RADAR_RADIUS + 32

local inner_vertices = GenerateCircleVertices( RADAR_X, RADAR_Y, RADAR_RADIUS , 0, 360 )
local inner_color = Color( 0, 0, 0, 210 )

local tex_white = surface.GetTextureID( "vgui/white" )


hook.Add( "HUDPaint" , "fuc" , function()
		
		render.SetStencilEnable( true )

			render.SetStencilReferenceValue( 1 )
			render.SetStencilWriteMask( 1 )
			render.SetStencilTestMask( 1 )

			render.SetStencilPassOperation( STENCIL_REPLACE )
			render.SetStencilFailOperation( STENCIL_KEEP )
			render.SetStencilZFailOperation( STENCIL_KEEP )

			render.ClearStencil()

			render.SetStencilCompareFunction( STENCIL_NOTEQUAL )
				
				surface.SetTexture( tex_white )
				surface.SetDrawColor( inner_color )
				surface.DrawPoly( inner_vertices )

			render.SetStencilCompareFunction( STENCIL_EQUAL ) -- Stop drawing from writing to the buffer for our MINIMAP!

				surface.SetMaterial( thing )
				surface.SetDrawColor( color_white )
				surface.DrawTexturedRect( RADAR_X - RADAR_RADIUS, RADAR_Y - RADAR_RADIUS, RADAR_RADIUS * 2, RADAR_RADIUS * 2 )

			render.ClearStencil()

		render.SetStencilEnable( false )
end)