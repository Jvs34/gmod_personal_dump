if SERVER then
include("server/penis.lua")
print(GCELL)
if(GCELL) then return end
AddCSLuaFile("autorun/imview.lua")

else

local ImmersiveView = CreateClientConVar("immersiveview", 0)
local znear = CreateClientConVar("znear", 0.1)
local function DrawCross(x,y)
if ImmersiveView:GetBool() then

surface.SetDrawColor(255,255,255,255)
surface.DrawLine(x - 10,y,x - 5,y)
surface.DrawLine(x + 5,y,x + 10,y)
surface.DrawLine(x,y - 10,x,y - 5)
surface.DrawLine(x,y + 5,x,y + 10)

surface.DrawLine(x - 10,y,x - 10,y - 10)
surface.DrawLine(x + 10,y + 10,x + 10,y)
surface.DrawLine(x,y - 10,x+10,y - 10)
surface.DrawLine(x-10,y + 10,x,y + 10)

end
end


local function DrawHUD()
local p = LocalPlayer():GetEyeTrace().HitPos:ToScreen()
DrawCross(p.x, p.y)
end
hook.Add([[HUDPaint]], [[crosshair]], DrawHUD)
hook.Add([[ShouldDrawLocalPlayer]], [[ImmersiveView]], function() if ImmersiveView:GetBool() then return true end end)


hook.Add([[CalcView]], [[ImmersiveView]], function(p,o,ang,fov)
if(ImmersiveView:GetBool() == false) then return end
local r = p:GetRagdollEntity()
if(IsValid(r)) then
p = r
end
local a = p:GetAttachment(p:LookupAttachment([[eyes]]))
if(not a) then
	a = {}
	a = p:GetAttachment(p:LookupAttachment([[head]]))
end
p=a
local v = {}
v.origin = p.Pos
v.angles = ang
v.fov = fov
v.znear=znear:GetFloat() or 0.01
return v
end)

end
