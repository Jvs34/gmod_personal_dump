
local wireframe = Material( "models/wireframe" )
local miniphysscale = 1

MINIPHYSENTS = MINIPHYSENTS or {}

for i , v in pairs( MINIPHYSENTS ) do
	if IsValid( v ) then
		v:Remove()
		MINIPHYSENTS[i] = nil
	end
end

local function CreateSphere( pos , scale )
	
	local sphere = ClientsideModel( "models/error.mdl" )
	sphere.MiniPhysScale = 5 * miniphysscale
	sphere:PhysicsInitSphere( sphere.MiniPhysScale , "metal" )
	sphere.RenderOverride = function( self )
		local spheresize = self.MiniPhysScale
		render.SetMaterial( wireframe )
		render.DrawSphere( self:GetPos() , spheresize, 16, 16, color_white )
	end
	sphere:SetCollisionGroup( 0 )
	
	local physobj = sphere:GetPhysicsObject()
	if IsValid( physobj ) then
		physobj:Wake()
	end
	
	return sphere
end

local function CreateTable( pos , scale )
	
	local tableent = ClientsideModel( "models/error.mdl" )
	tableent.MiniPhysScale = 5 * miniphysscale
	
end

MINIPHYSENTS[ #MINIPHYSENTS + 1 ] = CreateSphere( vector_origin , miniphysscale )