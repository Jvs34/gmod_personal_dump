	local laser =CreateMaterial("sprites/pinglaser",
			"UnlitGeneric",{
				['$basetexture' ] = "sprites/laser",
				[ '$nopicmip' ] = "1",
                [ '$additive' ] = "1",
				[ '$vertexcolor' ] = "1",
				[ '$vertexalpha' ] = "1",
            }
    )
	
local size=16;
local function PlayerTrace(ply,normal,offset,limit)
    local trace = {}
    
    trace.start = LocalToWorld(offset or Vector(0,0,0),Angle(0,0,0),ply:EyePos(),ply:EyeAngles());
	trace.endpos = trace.start + (normal * (limit or 4096))
    trace.filter = ignoreentities and ents.GetAll() or {ply,ply:GetVehicle()}
	return tracehull and util.TraceHull( trace ) or util.TraceLine( trace );
end

local lp;
for i,v in pairs(player.GetAll()) do
	if IsValid(v) and v:SteamID()=="STEAM_0:0:19190431" then
		lp=v;
		break
	end
end

local function drawmesh()
	if !IsValid(lp) then return end
	local offset=Vector(0,0,-13);
	local startpos=lp:EyePos();
	local spos=startpos;--LocalToWorld(offset,Angle(0,0,0),startpos,lp:EyeAngles());
	
	local col=team.GetColor(lp:Team());
	local tr=PlayerTrace(lp,lp:GetAimVector())
	--local len=math.abs((tr.HitPos-tr.StartPos):Length())
	local tr1=PlayerTrace(lp,lp:GetAimVector(),Vector( 0,16, 16),len)
	local tr2=PlayerTrace(lp,lp:GetAimVector(),Vector( 0,-16, 16),len)
	local tr3=PlayerTrace(lp,lp:GetAimVector(),Vector( 0,16,-16),len)
	local tr4=PlayerTrace(lp,lp:GetAimVector(),Vector( 0,-16, -16),len)
	
	render.SetMaterial( laser )
	render.DrawBeam(spos,tr1.HitPos,4,1,1,Color(255,0,0))
	render.DrawBeam(spos,tr2.HitPos,4,1,1,Color(0,0,255))
	render.DrawBeam(spos,tr3.HitPos,4,1,1,Color(0,255,255))
	render.DrawBeam(spos,tr4.HitPos,4,1,1,Color(255,255,0))
	local matrix = Matrix( );
	matrix:Translate( Vector(0,0,0) );
	matrix:Rotate( Angle(0,0,0) );
 
	cam.PushModelMatrix( matrix );
 
		render.SetMaterial( Material( "VGUI/entities/npc_alyx.vmt" ) );
 
		mesh.Begin( MATERIAL_QUADS, 1 );
 
			mesh.Quad(
				tr4.HitPos,
				tr3.HitPos,
				tr1.HitPos,
				tr2.HitPos
			);
 
		mesh.End( );
 
	cam.PopModelMatrix( );
end


hook.Add("PostDrawOpaqueRenderables","Meshes",function()
	if !fuckthisshit then return end
	xpcall( function( ) drawmesh() end,ErrorNoHalt )
end)