--This code was ported to Lua by Disseminate,me,Jvs just made it working for any swep

local function LaggyGetViewModelPosition(ply , pos, ang )
    --[[
		Jvs:I set the veclastfacing to the player itself so that the viewmodel lag is consistent between weapon switching
	]]
    local vOriginalOrigin = pos
    local vOriginalAngles = ang
     
    if( not ply.m_vecLastFacing ) then
         
        ply.m_vecLastFacing = vOriginalOrigin
         
    end
     
    local forward = vOriginalAngles:Forward()
    local right = vOriginalAngles:Right()
    local up = vOriginalAngles:Up()
     
    local vDifference = ply.m_vecLastFacing - forward
     
    local flSpeed = 7
     
    local flDiff = vDifference:Length()
    if( flDiff > 1.5 ) then
         
        flSpeed = flSpeed * ( flDiff / 1.5 )
         
    end
     
    ply.m_vecLastFacing = ply.m_vecLastFacing + vDifference:GetNormal() * flSpeed * FrameTime()
    ply.m_vecLastFacing = ply.m_vecLastFacing:GetNormal()
    pos = pos + ( vDifference * -2) 
     
    return pos, ang
     
end

local laggyviewmodel = CreateConVar( "cl_laggyviewmodels", "1", { FCVAR_ARCHIVE, }, "Enable/Disable the original hl2 viewmodel lag" )
local baseswepfunction=nil

hook.Add("Think","LaggyViewmodel",function()
	if not IsValid(LocalPlayer()) or LocalPlayer():GetActiveWeapon()==NULL or not IsValid(LocalPlayer():GetActiveWeapon()) then return end
	local weapon=LocalPlayer():GetActiveWeapon()
	
	if weapon.GetViewModelPosition then 
		if weapon.GetViewModelPosition==LaggyGetViewModelPosition and not laggyviewmodel:GetBool() then
			weapon.GetViewModelPosition=nil
		end
		return
	end
	
	if not laggyviewmodel:GetBool() then return end
	weapon.GetViewModelPosition=LaggyGetViewModelPosition
	
end)