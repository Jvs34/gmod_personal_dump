if not IsValid( LocalPlayer() ) --[[or LocalPlayer():SteamID() ~= "STEAM_0:0:19190431"]] then
	return
end

if IsValid( BREENDUMMY ) then
	BREENDUMMY:Remove()
	BREENDUMMY = nil
	return
end



--models/props_junk/shoe001a.mdl

local pos = Vector( 491.733856, -463.690765 , -12223.968750 )

--[[
local boot = {
	transform = { Vector( 0 , 0 , 0 ), Angle(0,0,0), Vector( 1 , 1 , 1 ) * 1.25 },
	children = {
		
	}
}
]]


local leftboot = {	
	bone = "ValveBiped.Bip01_L_Foot",
	transform = { Vector( 3 , -3 , -1.9 ), Angle( 0 , -30 , 90 ), Vector( 1 , 1.25 , 1 ) * 1.15 },
	children = {
		{
			transform = { Vector(0,0,0), Angle(0,0,0), Vector(1,1,1) },
			model = "models/props_junk/shoe001a.mdl",
			clipplanes = {
				{
					Vector( 0 , 0 , 1 ) , Vector( 0 , 0 , 0 ),
				}
			},
			material = Material( "models/shiny" ),
			color = Color( 0 , 133 , 163 , 255 ),
			children = {
				{
					model = "models/maxofs2d/thruster_projector.mdl",
					transform = { Vector( -3 , 1 , -2.5 ), Angle( 180 , 0 , 0 ), Vector( 1 , 1 , 1 ) * 0.2 },
					clipplanes = {
						{
							Vector( 0 , 0 , 1 ) , Vector( 0 , 0 , 90 ),
						}
					}
				},
				{
					model = "models/maxofs2d/thruster_projector.mdl",
					transform = { Vector( 3 , 1 , -2.5 ), Angle( 180 , 0 , 0 ), Vector( 1 , 1 , 1 ) * 0.2 },
					clipplanes = {
						{
							Vector( 0 , 0 , 1 ) , Vector( 0 , 0 , 90 ),
						}
					}
				},
			}
		},
	}
}

rightboot = multimodel.Copy( leftboot )
rightboot.bone = "ValveBiped.Bip01_R_Foot"
rightboot.transform[1].z = rightboot.transform[1].z * -1
rightboot.transform[3].y = rightboot.transform[3].y * -1

function RecursiveSetReverseCullNiceMeme( tab )
	if tab.model and not tab.reversecull then
		tab.reversecull = true
	end
	
	for i , v in pairs( tab ) do
		if type( v ) == "table" then
			RecursiveSetReverseCullNiceMeme( v )
		end
	end
end

RecursiveSetReverseCullNiceMeme( rightboot )
local mmtab = {
	leftboot,
	rightboot,
}

multimodel.Register( "mm_hoverboots" , mmtab )
local mm = multimodel.CreateInstance("mm_hoverboots")

BREENDUMMY = ClientsideModel( "models/player/breen.mdl" )
BREENDUMMY:SetSequence( "walk_all" )
BREENDUMMY:SetPoseParameter( "move_x" , 1 )
BREENDUMMY:SetCycle( 1 )
BREENDUMMY:SetPos( pos )
BREENDUMMY:SetPlaybackRate( 1 )

BREENDUMMY.RenderOverride = function( self )
	self:FrameAdvance()
	render.SetBlend( 1 )
	self:DrawModel()
	render.SetBlend( 1 )
	
	if mm then
		multimodel.Draw( mm , self ,
		{
			origin=self:GetPos(),
			angles=self:GetAngles()
		})
	end
end