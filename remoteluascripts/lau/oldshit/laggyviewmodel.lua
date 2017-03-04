--This code was ported to Lua by Disseminate,me,Jvs just made it working for any swep

local function LaggyGetViewModelPosition(ply , pos, ang )
    --[[
		Jvs:I set the veclastfacing to the player itself so that the viewmodel lag is consistent between weapon switching
	]]
    local vOriginalOrigin = pos;
    local vOriginalAngles = ang;
     
    if( not ply.m_vecLastFacing ) then
         
        ply.m_vecLastFacing = vOriginalOrigin;
         
    end
     
    local forward = vOriginalAngles:Forward();
    local right = vOriginalAngles:Right();
    local up = vOriginalAngles:Up();
     
    local vDifference = ply.m_vecLastFacing - forward;
     
    local flSpeed = 7;
     
    local flDiff = vDifference:Length();
    if( flDiff > 1.5 ) then
         
        flSpeed = flSpeed * ( flDiff / 1.5 );
         
    end
     
    ply.m_vecLastFacing = ply.m_vecLastFacing + vDifference:Normalize() * flSpeed * FrameTime();
    ply.m_vecLastFacing = ply.m_vecLastFacing:Normalize();
    pos = pos + ( vDifference * -1 ) * 5;
     
    return pos, ang;
     
end

local laggyviewmodel = CreateConVar( "cl_laggyviewmodels", "1", { FCVAR_ARCHIVE, }, "Enable/Disable the original hl2 viewmodel lag" )
local baseswepfunction=nil;

hook.Add("CalcView","laggyswep",function( ply, origin, angles, fov, znear, zfar,avoidloopoverflow)
	if avoidloopoverflow then return end
	
	if not baseswepfunction then
		baseswepfunction=weapons.Get("weapon_base").GetViewModelPosition
	end
	
	local wep = ply:GetActiveWeapon()
	local originalview=gamemode.Call("CalcView",ply, origin, angles, fov, znear, zfar,true)
	local view = originalview or {}
	if not originalview then
		view.origin 	= origin
		view.angles		= angles
		view.fov 		= fov 
		view.znear		= znear
		view.zfar		= zfar
	end
	
	-- Give the active weapon a go at changing the viewmodel position
	-- Jvs: we check if the weapon has a new getviewmodelposition function,if it doesn't then use Disseminate's (thanks to Gran PC for the idea)
	if ( IsValid( wep ) and laggyviewmodel:GetBool() and baseswepfunction) then
	
		local func = (baseswepfunction ~= wep.GetViewModelPosition) and wep.GetViewModelPosition  or LaggyGetViewModelPosition 
		if ( func ) then
			view.vm_origin,  view.vm_angles = func( ply, origin*1, angles*1 ) -- Note: *1 to copy the object so the child function can't edit it.
		end
		return view
	end

end)